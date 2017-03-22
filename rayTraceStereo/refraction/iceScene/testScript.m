% This script will run through an example of underwater reconstruction
% using PSITRES data. It will download the neccessary data not present in
% this repository from the internet, and will run automatically as long as
% VL_feat is installed and set up.

%% Setting everything up
close all
clear
clc

%loading in images and stereo parameters
disp('Loading images and 3D scene...');
load('OATRCCalParams.mat');
imleft = imread('https://www.dropbox.com/s/znlodxy7y1sjejh/20130821161622-cam12010988-1-15965-7488022.jpg?raw=1');
imright = imread('https://www.dropbox.com/s/vr1xyc5fknzovs6/20130821161622-cam12010990-0-15965-7488003.jpg?raw=1');
leftMask = imread('https://www.dropbox.com/s/yxpjsrypirgyc0v/regionMask.png?raw=1');

%displaying
figure;
subplot(1,2,1);imshow(imleft);
title('The original image');
subplot(1,2,2);imshow(maskImage(imleft,~leftMask));
title('The region to reconstruct');
pause(.5) %to force it to display image


%loading in reconstructed scene 
outfilename = websave('iceplanePts.mat','https://www.dropbox.com/s/la2wkjbnkv6ao9f/iceplanePts.mat?raw=1');
load(outfilename);
delete(outfilename); %getting rid of downloaded file to save space

%plane fitting
disp('Fitting plane to scene...');
planeCentroid = mean(pts3d);
[coeff,~,~] = pca(pts3d);
planeNorm = -coeff(:,3);


offset = 0;%allows for manually tuning the plane offset
a = planeNorm(1);
b = planeNorm(2);
c = planeNorm(3);
dVal = planeCentroid*planeNorm + offset ;

%building a parameter object
leftA = calParams.left.A';
leftK1 = calParams.left.k1;
leftK2 = calParams.left.k2;
lefttCameraParams = cameraParameters('IntrinsicMatrix',leftA,'RadialDistortion',[leftK1,leftK2]);
[undistLeft,leftOrigin] = undistortImage(imleft,lefttCameraParams);
[unLeftMask,lMaskOr] =undistortImage(leftMask,lefttCameraParams);

rightA = calParams.right.A';
rightK1 = calParams.right.k1;
rightK2 = calParams.right.k2;
rightCameraParams = cameraParameters('IntrinsicMatrix',rightA,'RadialDistortion',[rightK1,rightK2]);

%% Matching 
disp('Matching subsurface region...');
[undistRight,rightOrigin] = undistortImage(imright,rightCameraParams);
[leftpts,rightpts] = maskSift( undistLeft,undistRight, unLeftMask );

%% Ray trace reconstruction
disp('Reconstructing subsurface scene...');
airIOR = 1.002;
arcticIOR = 1.346;
for i =1:size(leftpts,2)
   xL =  leftpts(1,i);
   yL = leftpts(2,i);
   xR = rightpts(1,i);
   yR = rightpts(2,i);
   rayDirL = getCameraRay( leftA', eye(3), [xL,yL] );
   rayDirsL(i,:) = rayDirL;
   iptsL(i,:) = planeIntersect(planeCentroid,planeNorm',[0,0,0],rayDirL);
   
   dvalsL(i) = dot(planeNorm,iptsL(i,:));
   refRayL(i,:) = refractRay( rayDirL, planeNorm', airIOR,arcticIOR);
   rayDirR = getCameraRay(rightA',calParams.R,[xR,yR]);
   iptsR(i,:)= planeIntersect(planeCentroid,planeNorm',-calParams.T,rayDirR);
   
   dvalsR(i) = dot(planeNorm,iptsR(i,:));
   refRayR(i,:) = refractRay( rayDirR, planeNorm', airIOR,arcticIOR);
   [ intersection, error ] = intersectRays( iptsL(i,:),refRayL(i,:),iptsR(i,:),refRayR(i,:));
   refractedPts(i,:) = intersection;
   refractError(i) = error;
   col = undistLeft(round(xL),round(yL),:);
   refColors(i,:) = col;

end

%uncomment this to visualize triangulation error distribution
%figure; scatter(1:size(refractError,2),refractError);

errorThresh = 250;
rejectPts = find(refractError>errorThresh);
refractedPts(rejectPts,:) = [];
refColors(rejectPts,:) = [];

%% Extracting keel depth
%computing point plane distance
for x = 1:size(refractedPts,1)
    dval(x) = dot(refractedPts(x,:),planeNorm);
end

depth = min(dval)-dot(planeNorm,planeCentroid);
disp(['Maximum keel depth is ' num2str(abs(depth)) ' mm']);
disp('Done.');

