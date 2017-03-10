%this script will calculate the homography and warp the images
clear
clc
load('C:\Users\Scott\Documents\MATLAB\fast3D\seqSPARSE.mat');
 A = [ 1638.21 -40.2222 1149.92; 0.000000 1611.84 1476.47; 0.000000 0.000000 1.00000]; %this is the oden left camera
 scaleFactor = 20;
 %im = imread('C:\Users\Chandra\Desktop\threstest\meltponds\positive\cam12010988-0-12717.jpg');
 imdir = 'D:\sequence\left\';
 outdir = 'C:\Users\Scott\Desktop\warpedSeq\';
 
 files = dir(imdir);
 files(1:2) = [];
 
 for x=1:size(SURFpcseq,2)
    pointcloud = SURFpcseq{x};
    ind = find(pointcloud(:,4)<1);
    pointcloud(ind,:)=[];
    SURFpcseq{x}=pointcloud;
 end

%just computing the homography for all 100 takes 0.3669
%to transform each of the 100 images 29.9608
tic;
for x=1:size(SURFpcseq,2)
   im =imread([imdir files(x).name]);
   pointcloud = SURFpcseq{x};
   tform = computeHomography( A,pointcloud,scaleFactor);
   warped = imtransform(im,tform);
   imwrite(warped,[outdir files(x).name]);
end
timeTransform = toc
