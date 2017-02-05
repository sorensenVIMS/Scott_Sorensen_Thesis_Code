function [rect_params] = siftRectify( imleft,imright,mask )
%This function is to rectify a set of images (with a masked ROI) using SIFT
%imleft is the left image
%imright is the right image
%mask is the mask for the region of interest (in left image coordinates)

%NOTE: this requires VLFeat and you must run the the setup before running
%this function. This can be done like this:
%VLFEATROOT = 'PATH/TOVLFEAT/vlfeat-0.9.20';
%run([VLFEATROOT '/toolbox/vl_setup']);

if size(imleft,3)>1;
        grayleft = rgb2gray(imleft);
        grayright = rgb2gray(imright);
else
    grayleft = imleft;
    grayright = imright;
end
        [fa, da] = vl_sift(single(grayleft)) ;
        [fb, db] = vl_sift(single(grayright)) ;
        [matches, ~] = vl_ubcmatch(da, db) ;
        matchedPoints1 = fa(1:2, matches(1,:));
        matchedPoints2 = fb(1:2, matches(2,:));
        for x = 1:size(matchedPoints1,2)
           ex = matchedPoints1(1,x);
           ey = matchedPoints1(2,x);
           approx = round([ex,ey]);
           temp = mask(approx(2),approx(1));
           inmask(x) = temp;
        end
        invalid = find(~inmask);
        matchedPoints1(:,invalid) = [];
        matchedPoints2(:,invalid) = [];
         matchedPoints1 = matchedPoints1';
        matchedPoints2 = matchedPoints2';
        %uncomment these lines to show matching results
        %showMatchedFeatures(imleft,imright,matchedPoints1,matchedPoints2,'montage');
        %pause(0.1);
       
        
        gte = vision.GeometricTransformEstimator('PixelDistanceThreshold', 50);
[~, geometricInliers] = step(gte, matchedPoints1, matchedPoints2);
refinedPoints1 = matchedPoints1(geometricInliers, :);
refinedPoints2 = matchedPoints2(geometricInliers, :);
%remove outliers using epipolar constraint
[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
    refinedPoints1, refinedPoints2, 'Method', 'RANSAC', ...
    'NumTrials', 10000, 'DistanceThreshold', 0.3, 'Confidence', 97);
if status ~= 0 || isEpipoleInImage(fMatrix, size(grayleft)) ...
        || isEpipoleInImage(fMatrix', size(grayright))
    error(['For the rectification to succeed, the images must have enough '...
        'corresponding points and the epipoles must be outside the images.']);
end
inlierPoints1 = refinedPoints1(epipolarInliers, :);
inlierPoints2 = refinedPoints2(epipolarInliers, :);
%calculate the rectification
[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
    inlierPoints1, inlierPoints2, size(grayright));
tform1 = projective2d(t1);
tform2 = projective2d(t2);
% Compute the transformed location of image corners.
numRows = size(grayleft, 1);
numCols = size(grayleft, 2);
inPts = [1, 1; 1, numRows; numCols, numRows; numCols, 1];
outPts(1:4,1:2) = transformPointsForward(tform1, inPts);
numRows = size(grayleft, 1);
numCols = size(grayright, 2);
inPts = [1, 1; 1, numRows; numCols, numRows; numCols, 1];
outPts(5:8,1:2) = transformPointsForward(tform2, inPts);
%--------------------------------------------------------------------------
% Compute the common rectangular area of the transformed images.
xSort   = sort(outPts(:,1));
ySort   = sort(outPts(:,2));
xLim(1) = ceil(xSort(1)) - 0.5;
xLim(2) = floor(xSort(end)) + 0.5;
yLim(1) = ceil(ySort(1)) - 0.5;
yLim(2) = floor(ySort(end)) + 0.5;
width   = round(xLim(2) - xLim(1) - 1);
height  = round(yLim(2) - yLim(1) - 1);
outputView = imref2d([height, width], xLim, yLim);
im1ref = imref2d(size(grayleft));
im2ref = imref2d(size(grayright));

%--------------------------------------------------------------------------
% Generate a composite made by the common rectangular area of the
% transformed images.
[imageTransformed1, tref1] = imwarp(grayleft, im1ref, tform1, 'OutputView', outputView);
[imageTransformed2, tref2] = imwarp(grayright, im2ref, tform2, 'OutputView', outputView);
Irectified = [];

Irectified(:,:,1) = uint8(imageTransformed1);
Irectified(:,:,2) = uint8(imageTransformed2);
Irectified(:,:,3) = uint8(imageTransformed2);
size(Irectified)
figure, imshow(uint8(Irectified));
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');

rect_params.tform1 = tform1;
rect_params.tform2 = tform2;
rect_params.outputView = outputView;
rect_params.tref1 = tref1;
rect_params.tref2 = tref2;


end

