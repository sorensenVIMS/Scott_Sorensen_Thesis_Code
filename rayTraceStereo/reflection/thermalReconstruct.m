%this is a test script is to illustrate the stereo rig and reconstruct an
%object under reflection. It uses the images packaged in the sampleImages
%directory

%clearing all the variables etc 
clear;
clc;
close('all');
tic

%reading all the images from dropbox
thermL = imread('https://www.dropbox.com/s/786hksp482gky2j/thermL.png?raw=1');
thermR = imread('https://www.dropbox.com/s/qc91fsptti1b0ef/thermR.png?raw=1');
visL = imread('https://www.dropbox.com/s/6dss7drla4bzzzq/visL.png?raw=1');
visR = imread('https://www.dropbox.com/s/e9op76zpdwmrao4/visR.png?raw=1');

visMask = imread('https://www.dropbox.com/s/ipt5ijzs532xsqp/mask.png?raw=1');
thermMask = imread('https://www.dropbox.com/s/a5jodvks241bx9a/thermMask.png?raw=1');
cmappedTex = imread('https://www.dropbox.com/s/319e4pucy6ng3u9/colormapped.png?raw=1');

%% Reconstructing the reflecting surface in visible band
load('colorStereoParams'); 
[matched_pts1,matched_pts2] = maskSURF(rgb2gray(visL),rgb2gray(visR), [355,1,774,861], true );
[planePts,error]= triangulate(matched_pts2,matched_pts1,stereoParams);
%figure;
%scatter(1:size(error,1),error);
errThresh = 5;
highErr = find(error>errThresh);
planePts(highErr,:) = [];
matched_pts1(highErr) =[];
matched_pts2(highErr)=[];
%figure;
showMatchedFeatures(visL,visR,matched_pts1,matched_pts2,'montage');

%% Drawing the camera system and experimental setup 
% starting with the color this is straightForward, because the coordinates
% are unchanged

left.A = stereoParams.CameraParameters1.IntrinsicMatrix;
left.R = eye(3);
left.T = [0,0,0];

figure;
showCameraRays(left.A,left.T,left.R,1280,960,[0,0,1]);
title('The experimental setup');
hold on;

right.A = stereoParams.CameraParameters1.IntrinsicMatrix;
right.R = stereoParams.RotationOfCamera2;
right.T = 1* stereoParams.TranslationOfCamera2;

showCameraRays(right.A,right.T,right.R,1280,960,[0,0,.7]);

%% moving on to the infrared cameras
load('scott_color_infrared_calib');
infraredBaseT = stereoParams.TranslationOfCamera2;
infraredBaseR = stereoParams.RotationOfCamera2;

load('infraredStereoParams');

LeftT = infraredBaseT;
LeftR= infraredBaseR;


left.A = stereoParams.CameraParameters1.IntrinsicMatrix;
showCameraRays(left.A,LeftT,LeftR,640,480,[1,0,0]);

right.A = stereoParams.CameraParameters1.IntrinsicMatrix;
right.R = stereoParams.RotationOfCamera2 + infraredBaseR;
right.T = stereoParams.TranslationOfCamera2  + infraredBaseT;
showCameraRays(right.A,right.T,right.R,640,480,[0.7,0,0]);


%% Showing the reflected plane
scatter3(planePts(:,1),planePts(:,2),planePts(:,3))
[coeff,score,latent] = pca(planePts);
initialNorm = coeff(:,3)';
initialCentroid = mean(planePts);
quiver3(initialCentroid(1),initialCentroid(2),initialCentroid(3),...
    initialNorm(1),initialNorm(2),initialNorm(3),50);

%% Rectification parameters 
leftMask = thermMask;


%This can be uncommented to find new rectification parameters, but I
%have included them here because finding these parameters can be very hard.
%This runs multiple times since it is a stochastic process and could give 
%bad results. Also the images sampled here do not have many correspondences, 
%so it is suggested you use the pre-calculated parameters.
%{
continu = true;
index = 0;
while continu
    try
        index = index + 1
    [rect_params] = siftRectify( thermL,thermR,leftMask );
    continu = false;
    catch
    end
end
%save('rectParams.mat');
%}
%% Rectifying the images


load('rectParams.mat');

tform1 = rectParams.tform1;
tform2 = rectParams.tform2;
tref1 = rectParams.tref1;
tref2 = rectParams.tref2;
outputView = rectParams.outputView;

im1ref = imref2d(size(thermL));


[imageTransformed1, tref1] = imwarp(thermL, im1ref, tform1, 'OutputView', outputView);
[imageTransformed2, tref2] = imwarp(thermR, im1ref, tform2, 'OutputView', outputView);


%uncomment these lines to visualize rectification as an anaglyph
%{
Irectified = [];
Irectified(:,:,1) = uint8(imageTransformed1/255);
Irectified(:,:,2) = uint8(imageTransformed2/255);
Irectified(:,:,3) = uint8(imageTransformed2/255);
figure, imshow(uint8(Irectified));
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');
%}
%% Computing dense disparity

I1 = imwarp(thermL, tform1, 'OutputView', outputView);
I2 = imwarp(thermR, tform2, 'OutputView', outputView);

%the disparity range (for semiglobal this range must be divisible by 16)
dispRange = [-32,32];

d = disparity(I1, I2, 'DisparityRange', dispRange,'UniquenessThreshold', 15);

%masking off region without overlap
premask = ones(size(thermL));
warpedMask = imwarp(premask,tform1,'OutputView', outputView);
d = maskDisparity(d,warpedMask);


marker_idx = (d == -realmax('single'));


[r, c] = find(d ~= -realmax('single'));
ind = sub2ind(size(d), r, c);
v = d(ind);
d(marker_idx) = min(d(~marker_idx));

%uncomment these lines to visualize the disparity map
%{
extendedDisp = dispRange + [-10 10]; %helps visualization
figure;
imshow(d, extendedDisp);
title(['disparity range ' num2str(dispRange)]);
%}

xyLr = [c r ];
xyRr = [c-v r];

%unrectify points
[xWorldL,yWorldL] = intrinsicToWorld(tref1,xyLr(:,1),xyLr(:,2));
[xyLu, xyLv] = transformPointsInverse(tform1,xWorldL,yWorldL);
[xWorldR,yWorldR] = intrinsicToWorld(tref2,xyRr(:,1),xyRr(:,2));
[xyRu, xyRv] = transformPointsInverse(tform2,xWorldR,yWorldR);
xyL = [xyLu xyLv];
xyR = [xyRu xyRv];

numPts = length(xyL);
pts3d = zeros(numPts, 3);
colors = zeros(numPts, 3);

%% Ray tracing

raysL = getCameraRay(left.A,left.R,xyL);


for x = 1: size(raysL,1)
    isectL(x,:) = planeIntersect(initialCentroid,initialNorm,LeftT,raysL(x,:));
end
for x = 1:size(xyL,1)
    i = round(xyL(x,1));
    if i > 640
        i = 640;
    elseif i <1
        i = 1;
    end
    
    j = round(xyL(x,2));
    if j > 480
        j = 480;
    elseif j <1
        j = 1;
    end
    colors(x,:) = cmappedTex(j,i,:);
   
end

%drawing left intersection points
skip = 7;
scatter3(isectL(1:skip:end,1),isectL(1:skip:end,2),isectL(1:skip:end,3),30,colors(1:skip:end,:)/256,'filled');

%%
raysR = getCameraRay(right.A,right.R,xyR);
for x = 1: size(raysL,1)
    isectR(x,:) = planeIntersect(initialCentroid,initialNorm,right.T,raysR(x,:));
end
%uncomment this to draw the right intersection points for debugging
%scatter3(isectR(1:skip:end,1),isectR(1:skip:end,2),isectR(1:skip:end,3));

%%  Reflecting the rays.

for x =1:size(raysL,1)
    refRaysL(x,:) = reflectRay( raysL(x,:),initialNorm );
end

for x =1:size(raysR,1)
    refRaysR(x,:) = reflectRay( raysR(x,:),initialNorm);
end


%% Intersecting the points
clear pts3d;

for x = 1:size(raysL,1)
    [ intersection, error ] = intersectRays( isectL(x,:),refRaysL(x,:),isectR(x,:),refRaysR(x,:) );
    pts3d(x,:) = intersection;
    errors(x) = error;
end

% uncomment to visualize triangulation errors
%{
figure;
hist(errors,2);
%}

%getting rid of points with high error
errThresh = 10;
highErr = find(errors > errThresh);
tempPts = pts3d;
tempPts(highErr,:) = [];
tempColors = round(colors);
tempColors(highErr,:) = [];
totalTime = toc
makePly(tempPts,tempColors,'thermalReflectCup');