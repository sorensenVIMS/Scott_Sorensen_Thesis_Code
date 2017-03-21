import sys,os
import urllib
import argparse
import numpy as np
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import tensorflow as tf


color_model_dropbox = 'https://www.dropbox.com/s/nraw91s89f55bs5/output_graph.pb?raw=1'
thermal_model_dropbox = 'https://www.dropbox.com/s/9fzaz4au8l7528j/output_graph.pb?raw=1'

color_labels_dropbox = 'https://www.dropbox.com/s/etwmnqsg2q2qx4y/output_labels.txt?raw=1'
thermal_labels_dropbox = 'https://www.dropbox.com/s/h2zosob3pwvyu8s/output_labels.txt?raw=1'


def get_graphdef(save_model,use_thermal):
	if use_thermal:
		print "Model selected: Thermal"
		fname = 'thermal_model.pb'
		model_dropbox = thermal_model_dropbox
	else:
		print "Model selected: Color"
		fname = 'color_model.pb'
		model_dropbox = color_model_dropbox
		
	if tf.gfile.Exists(fname):
		print "Current graph exists locally; using saved version..."
		with tf.gfile.FastGFile(fname, 'rb') as f:
			graph_def = tf.GraphDef()
			graph_def.ParseFromString(f.read())
			_ = tf.import_graph_def(graph_def, name='')
	else:
		print "Obtaining graph from Dropbox link..."
		url_data = urllib.urlopen(model_dropbox).read()
		graph_def = tf.GraphDef()
		graph_def.ParseFromString(url_data)
		_ = tf.import_graph_def(graph_def, name='')
		if save_model:
			print "Saving selected model to disk..."
			with tf.gfile.FastGFile(fname, 'wb') as f:
				f.write(url_data)

def run_inference_on_image(save_model, use_thermal, input_path, output_path):

	if not tf.gfile.Exists(input_path):
		tf.logging.fatal('File does not exist %s', input_path)
		return
	im = tf.gfile.FastGFile(input_path, 'rb').read()
	
	# Creates graph from saved GraphDef.
	get_graphdef(save_model,use_thermal)
	
	with tf.Session() as sess:
		# Unfortunately the best models were named with fold numbers appended, so we need to choose the right tensor name like so...
		softmax_tensor = sess.graph.get_tensor_by_name('final_result7:0') if use_thermal else sess.graph.get_tensor_by_name('final_result3:0')

		# Obtain labels from the internet always...
		labels_dropbox = urllib.urlopen(thermal_labels_dropbox) if use_thermal else urllib.urlopen(color_labels_dropbox)
		lines = labels_dropbox.readlines()
		labels = [str(w).replace("\n", "") for w in lines]
		predictions = sess.run(softmax_tensor, {'DecodeJpeg/contents:0': im})
		predictions = np.squeeze(predictions)
		top_k = predictions.argsort()[-5:][::-1]  # Getting top 5 predictions
		print "\nResults:"
		print "Image:", input_path
		for node_id in top_k:
			human_string = labels[node_id]
			score = predictions[node_id]
			print('%s (score = %.5f)' % (human_string, score))

		answer = labels[top_k[0]]
		if output_path:
			with open(output_path,'w') as f:
				f.write(answer)

if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='"DeepBear" CNN Classifier')
	parser.add_argument('-s', action='store_true', dest='save_model', help='Save the current model')
	parser.add_argument('-t', action='store_true', dest='use_thermal', help='Use the thermal model (Default: color model)')
	parser.add_argument('-o', action='store', dest='output_path', default=False, help='Output prediction path')
	
	parser.add_argument('input_path', nargs='?', default='', help='Path to input image')
	
	args = parser.parse_args()
	
	if args.input_path != '':
		run_inference_on_image(args.save_model, args.use_thermal, args.input_path, args.output_path)
	else:
		print "No input image selected"
	