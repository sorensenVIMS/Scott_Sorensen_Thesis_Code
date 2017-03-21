#Downloading the test images
wget -O ./ambient.jpg 'https://www.dropbox.com/s/n6og5svjr8f2mjd/ambient.jpg?raw=1'
wget -O ./bear.jpg 'https://www.dropbox.com/s/u5awdw39krpx3ud/bear.jpg?raw=1'
wget -O ./bird.jpg 'https://www.dropbox.com/s/p0xon2bjtgbzgkl/bird.jpg?raw=1'

wget -O ./pos.jpg 'https://www.dropbox.com/s/85y48qw4ofb1qoo/00008.jpg?raw=1'
wget -O ./neg.jpg 'https://www.dropbox.com/s/y8lgaa6kunrmhbg/00005.jpg?raw=1'

#classifying
python deepbear_classify.py -t ./ambient.jpg ambientResult.txt
python deepbear_classify.py -t ./bear.jpg bearResult.txt
python deepbear_classify.py -t ./bird.jpg birdResult.txt

python deepbear_classify.py ./pos.jpg 
python deepbear_classify.py ./neg.jpg 

#removing downloaded files
rm ambient.jpg
rm bear.jpg
rm bird.jpg
rm pos.jpg
rm neg.jpg
