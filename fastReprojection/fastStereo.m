function pointCloud= fastStereo( imleft, imright, calParams)
%FASTSTEREO this function performs a sparse 3D reconstruction based on
%feature points instead of a full disparity estimation
%   the function has multiple methods built in

grayleft = rgb2gray(imleft);
grayright = rgb2gray(imright);

%
%this is currently using SURF for a feature.
%
points1 = detectSURFFeatures(grayleft);
points2 = detectSURFFeatures(grayright);

 [features1, valid_points1] = extractFeatures(grayleft, points1);
 [features2, valid_points2] = extractFeatures(grayright, points2);
 
 indexPairs = matchFeatures(features1, features2);
 
 %matched_points1 = valid_points1(indexPairs(:, 1), :);
 %matched_points2 = valid_points2(indexPairs(:, 2), :);
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

% leftA = calParams.leftA;
% leftk2 = calParams.leftk2;
% leftk1 = calParams.leftk1;
% T = calParams.T;
% rightA = calParams.rightA;
% R = calParams.R;
% rightk2 = calParams.rightk2;
% rightk1 = calParams.rightk1;

leftA = calParams.left.A;
leftk2 = calParams.left.k2;
leftk1 = calParams.left.k1;
rightA = calParams.right.A;
rightk2 = calParams.right.k2;
rightk1 = calParams.right.k1;
T = calParams.T;
R = calParams.R;


XYZ=zeros(size(leftpts',1),4);
pall=fastUndistort(rightpts,rightA,rightk1,rightk2)';
qall=fastUndistort(leftpts,leftA,leftk1,leftk2)';

%myparams = repmat(calParams,size(pall,1));


%xyz = arrayfun(@arrayTri,qall(:,1),qall(:,2),pall(:,1),pall(:,2),myparams)
    %XYZ(ind,:)=p1(1:4)';

%triangulate the points
for ind=1:size(qall,1)
   p1=fastTri(qall(ind,:),pall(ind,:),leftA,rightA,[R' T']);
   XYZ(ind,:)=p1(1:4)';
end
% size(XYZ)


%%this is to get rid of the points with large triangulation error
%subpts = XYZ(:,4);
%index = find(~subpts);
%XYZ(index,:) = [];



% size(XYZ)
% figure;scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3));

 pointCloud = XYZ;
%figure; showMatchedFeatures(grayleft, grayright, matched_points1, matched_points2); 
%pointCloud = toc;


end

