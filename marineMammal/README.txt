This module illustrates the deep learning framework for detection of marine mammals. 
This module requires tensorflow installed and configured, see their site for details https://www.tensorflow.org/install/
The main script is deepbear_classify, but a test script is provided to illustrate a few examples.
To run the testScipt, simply navigate a terminal to this directory and execute the testScipt.sh
script. This will run through visible and thermal examples. 
The classify module was written by Wayne Treible and he will have more expertise.

To run the deepbear_classify script 

$ python deepbear_classify.py --help
usage: deepbear_classify.py [-h] [-s] [-t] [input_path] [output_path]

"DeepBear" CNN Classifier

positional arguments:
  input_path      Path to input image

optional arguments:
  -h, --help      show this help message and exit
  -s              Save the current model
  -t              Use the thermal model (Default: color model)
  -o OUTPUT_PATH  Output prediction path

