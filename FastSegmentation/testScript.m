%% this script is designed to illustrate the technique for segmentation that
%% employs a colorspace transformation and vectorized thresholding this
%% script can simply be executed and sample data will be retrieved from the
%% internet via dropbox.

%clearing and closing everything
clear
clc
close all

%% algae
im = imread('https://www.dropbox.com/s/qlud5vwghms4v9g/cam12010990-1-24036.jpg?raw=1');
mask = algaeSegment(im);
figure;
subplot(1,2,1);
imshow(im);
title('Input Image');
subplot(1,2,2);
imshow(maskImage(im,~mask));
title('Algae Segmentation Results')

%% melt pond
im = imread('https://www.dropbox.com/s/m175u0azuntvz35/cam12010988-0-676.jpg?raw=1');
mask = meltSegment(im);
figure;
subplot(1,2,1);
imshow(im);
title('Input Image');
subplot(1,2,2);
imshow(maskImage(im,~mask));
title('Melt Pond Segmentation Results')
%% open water fraction
im = imread('https://www.dropbox.com/s/09vto8s1lh7fyvv/cam12010988-0-9885.jpg?raw=1');
mask = openWaterSegment(im);
figure;
subplot(1,2,1);
imshow(im);
title('Input Image');
subplot(1,2,2);
imshow(maskImage(im,mask));
title('Open Water Segmentation Results')
