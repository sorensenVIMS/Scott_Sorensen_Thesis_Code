close all
clear
clc

pointSkip = 100; %this is how many points to skip over in reconstruction
%decrease this for a denser reconstruction, however it will take some time

%load images
imleft = imread('https://www.dropbox.com/s/38yz17o4jq5gw46/IMG_9508.JPG?raw=1');
imright = imread('https://www.dropbox.com/s/1txetlh5c6mcrs1/IMG_9916.JPG?raw=1');
mask = readMask('https://www.dropbox.com/s/cg4ticsclt2qahh/IMG_9508mask.JPG?raw=1');
load('labSetup.mat');


%load parameters from previously reconstructed and modeled plane
load('brainPlaneParams.mat');
%load parameters for cropping and rectification
load('imageParams.mat'); 

%crop just the region of interest
croppedLeft = imleft(lypt1:lypt2,lxpt1:lxpt2,1:3);
croppedRight = imright(rypt1:rypt2,rxpt1:rxpt2,1:3);

tform1 = rect_params.tform1;
tform2 = rect_params.tform2;
tref1 = rect_params.tref1;
tref2 = rect_params.tref2;
outputView = rect_params.outputView;
T = params.calParams.T;
R = params.calParams.R;
left = params.calParams.left;
right = params.calParams.right;
widthL = size(croppedLeft, 2);
heightL = size(croppedLeft, 1);
widthR = size(croppedRight, 2);
heightR = size(croppedRight, 1);

% Setting up extrinsic parameters
%left Camera
left.T = [0,0,0];
left.R = eye(3);
%left.A = c;

%right Camera
right.T = T;
right.R = R;
%right.A = c;

%% stereo matching
I1 = imwarp(rgb2gray(croppedLeft), tform1, 'OutputView', outputView);
I2 = imwarp(rgb2gray(croppedRight), tform2, 'OutputView', outputView);


%the disparity range (for semiglobal this range must be divisible by 16
dispRange = [-16,48];
d = disparity(I1, I2, 'DisparityRange', dispRange,'UniquenessThreshold', 1);

marker_idx = (d == -realmax('single'));
[r, c] = find(d ~= -realmax('single'));
ind = sub2ind(size(d), r, c);
v = d(ind);
d(marker_idx) = min(d(~marker_idx));

extendedDisp = dispRange + [-10 10]; %helps visualization
figure;
imshow(d, extendedDisp);
title(['disparity range ' num2str(dispRange)]);
colorbar;
pause(.5);

%% unrectifying and uncropping to get pixel correspondences
xyLr = [c r ];
xyRr = [c-v r];

%unrectify points
[xWorldL,yWorldL] = intrinsicToWorld(tref1,xyLr(:,1),xyLr(:,2));
[xyLu, xyLv] = transformPointsInverse(tform1,xWorldL,yWorldL);
[xWorldR,yWorldR] = intrinsicToWorld(tref2,xyRr(:,1),xyRr(:,2));
[xyRu, xyRv] = transformPointsInverse(tform2,xWorldR,yWorldR);
%uncropping
xyL = [xyLu+lxpt1  xyLv+lypt1]/2;
xyR = [xyRu+rxpt1  xyRv+rypt1]/2;

%uncomment these lines to see matches from disparity
%figure;
%skipMatches = 600;
%showMatchedFeatures(imresize(imleft,.5), imresize(imright,.5),xyL(1:skipMatches:end, :),xyR(1:skipMatches:end, :), 'montage');

numPts = length(xyL);
resizedLeft = imresize(imleft,.5);

height = size(resizedLeft,1);
width = size(resizedLeft,2);

disp(['Total of ' num2str(numPts) ' matches found']);

%% Ray Trace Reconstruction
airIOR = 1; %air Index Of Refraction
waterIOR = 1.333; %fresh water Index Of Refraction

for i=1:pointSkip:numPts
            xl = xyL(i,2);
            yl = xyL(i,1);
            xr = xyR(i,2);
            yr = xyR(i,1);
            colorsl(i,:)= [resizedLeft(round(xl),round(yl),1),resizedLeft(round(xl),round(yl),2),resizedLeft(round(xl),round(yl),3)];
            
          
            
            rayDirl = getCameraRay( left.A, left.R, [yl,xl] );
            rayOrigl = left.T;
            [intersectionPointl] = planeIntersect( centroid,planeNormal,rayOrigl,rayDirl);
            viewVecl = (intersectionPointl-left.T)/norm(intersectionPointl-left.T);     
            [refractedRayl] = refractRay( viewVecl, planeNormal, airIOR,waterIOR);
            
             
            lnormalVec(i,:) = planeNormal;
            lviewVec(i,:) = viewVecl;
            lrefractedRayVec(i,:) = refractedRayl;
            lpointVec(i,:) = intersectionPointl;
            
            
            
            
            %right image
            rayDirr = getCameraRay( right.A, right.R, [yr,xr] );
            rayOrigr = right.T;
            [intersectionPointr] = planeIntersect( centroid,planeNormal,rayOrigr,rayDirr);
            viewVecr = (intersectionPointr-right.T)/norm(intersectionPointr-right.T);
            [refractedRayr] = refractRay( viewVecr, planeNormal, airIOR,waterIOR);
            
            rnormalVec(i,:) = planeNormal;
            rviewVec(i,:) = viewVecr;
            rrefractedRayVec(i,:) = refractedRayr;
            rpointVec(i,:) = intersectionPointr;
            
            % intersectingRays
            [ intersection, error ] = intersectRays(intersectionPointl,refractedRayl,intersectionPointr,refractedRayr);
            pts3D(i,:) = intersection;
            errorVec(i) = error;
           
end

 meanErr = mean(errorVec); 
 disp(['Mean triangulation error: ' num2str(meanErr) ' mm']);
 makePly(pts3D,colorsl,'brainRefracted')