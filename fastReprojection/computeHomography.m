function tform = computeHomography( camera,pointcloud,scaleFactor )
%this function computes the homography from the image plane to the ground
%plane. It does so using PCA and by generating correspondences between the
%image and ground
%camera is the camera calibration matrix
%pointcloud is the 3d pointcloud
%scalefactor is a scale relating reconstruction units to image units
[coeff,score,latent] = pca(pointcloud(:,1:3));
basis1 = coeff(:,1);
basis2 = coeff(:,2);
norm = coeff(:,3);
centroid = mean(pointcloud(:,1:3));
[ipts, gpts,r] = genCorrespondences(basis1,basis2,norm,centroid',camera,scaleFactor);
tform = cp2tform(ipts(:,1:2),r,'projective');


end

