function pointCloud= fastStereo( imleft, imright, calParams)
%FASTSTEREO this function performs a sparse 3D reconstruction based on
%feature points instead of a full disparity estimation
%imleft is the left stereo image
%imright is the right stereo image
%calParams are the stereo calibration parameters
%   the function has multiple methods built in that can be changed by the
%   user by commenting and uncommenting

grayleft = rgb2gray(imleft);
grayright = rgb2gray(imright);

%
%this is currently using SURF for a feature.
%cooment this section out and uncomment sift matching to change matching
%type
points1 = detectSURFFeatures(grayleft);
points2 = detectSURFFeatures(grayright);

 [features1, valid_points1] = extractFeatures(grayleft, points1);
 [features2, valid_points2] = extractFeatures(grayright, points2);
 
 indexPairs = matchFeatures(features1, features2);
 

 leftSURFpts = valid_points1(indexPairs(:, 1), :);
 leftpts = leftSURFpts.Location';
 rightSURFpts = valid_points2(indexPairs(:, 2), :);
 rightpts = rightSURFpts.Location';
 %}

%sift matching
%{
[fa, da] = vl_sift(single(grayleft));
[fb, db] = vl_sift(single(grayright));
[matches, scores] = vl_ubcmatch(da, db);
leftpts = fa(1:2, matches(1,:));
rightpts = fb(1:2, matches(2,:));
%}


%pulling out individual calibration parameters
%this is going to slow things down but makes it way more readable I think
leftA = calParams.left.A;
leftk2 = calParams.left.k2;
leftk1 = calParams.left.k1;
rightA = calParams.right.A;
rightk2 = calParams.right.k2;
rightk1 = calParams.right.k1;
T = calParams.T;
R = calParams.R;


XYZ=zeros(size(leftpts',1),4);
pall=undistort(rightpts,rightA,rightk1,rightk2)';
qall=undistort(leftpts,leftA,leftk1,leftk2)';

%triangulate the points
for ind=1:size(qall,1)
   p1=fastTri(qall(ind,:),pall(ind,:),leftA,rightA,[R' T']);
   XYZ(ind,:)=p1(1:4)';
end
 pointCloud = XYZ;
 
 


end

