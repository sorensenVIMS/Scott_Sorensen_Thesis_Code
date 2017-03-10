function [ imagepts, groundpts, r] = genCorrespondences( gbasis1,gbasis2,gnormal,gpoint, camera,scaleFactor )
%GENCORRESPONDENCES This function will generate random correspondences
%between the camera plane and ground plane. it requires a basis in the
%ground plane, a plane normal, and plane center point as well as the camera
%calibration matrix and a scale factor
%gbasis1 and gbasis2 are basis vectors in the ground plane
%gnormal is the ground plane normal
%gpoint is the ground plane center
%camera is the camera calibration matrix
%scalefactor is a scale to relate image to real reconstruction units

numCorr = 4; 
r1 = randi(2000,numCorr,1);
r2 = randi(200,numCorr,1);
r = [r2,r1];

for x=1:numCorr;
       q1 = scaleFactor*r1(x);
       q2 = scaleFactor*r2(x);
       pt1 = q1*gbasis1+q2*gbasis2+gpoint;
       pt2 = camera*pt1;
       pt2 = pt2/pt2(3);
       
       imagepts(x,:) = pt2;
        
       groundpts(x,:) = pt1;

end

