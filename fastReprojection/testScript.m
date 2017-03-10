%% this is the main test Script for 3D reprojection. It will download two
%% sample images, and perform a sparse feature based reconstruction followed
%% by 2D reprojection of the image.

load('odenCalParams');

imleft = imread('https://www.dropbox.com/s/2rrw9goniorfnb7/00008.jpg?raw=1');
imright = imread('https://www.dropbox.com/s/gj2g9xsx59mgz87/00008.jpg?raw=1');
scaleFactor = 40;

%pointcloud = SURFpcseq{x};
pointCloud= fastStereo( imleft, imright, calParams);
tform = computeHomography( calParams.left.A,pointCloud,scaleFactor);
warped = imtransform(imleft,tform);
imshow(warped);