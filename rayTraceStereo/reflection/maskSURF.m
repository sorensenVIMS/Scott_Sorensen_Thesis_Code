function [ matched_pts1,matched_pts2 ] = maskSURF( imleft,imright, maskpts, leftBool )
%SURFMATCH this function returns surf correspondences in a masked region of
%one of the images.
%   imleft and imright are the left and right images to match
%   maskpts is the mask 
%   leftbool is a boolean stating whether or not it is the left image being
%   masked off

    metThresh = 8; %matching metric threshod
    if leftBool     
        points = detectSURFFeatures(imleft,'MetricThreshold', metThresh, 'ROI', maskpts);
    else
        points = detectSURFFeatures(imleft,'MetricThreshold', metThresh);
    end
    [featuresL, vptsL] = extractFeatures(imleft, points);
    
    
    if leftBool
    points = detectSURFFeatures(imright,'MetricThreshold', metThresh);
    else
     points = detectSURFFeatures(imright,'MetricThreshold', metThresh, 'ROI', maskpts);
    end
    [featuresR, vptsR] = extractFeatures(imright, points);
    
    indexPairs = matchFeatures(featuresL,featuresR);
    
    matched_pts1 = vptsL(indexPairs(:, 1));
    matched_pts2 = vptsR(indexPairs(:, 2));
   
    figure; showMatchedFeatures(imleft,imright,matched_pts1,matched_pts2,'montage');
    title('point matches');
    
end

