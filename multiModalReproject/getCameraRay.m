function [dirs] = getCameraRay( C, R, pts2d )
%pts2d is nx2 matrix with 3D pts [X Y Z]
%C = 3x3 intrinsic matrix
%R is 3x3 rotation matrix
%T is 3x1 translation vector

dirs = zeros(3, size(pts2d,1));
pts3d = zeros(3, size(pts2d,1));
%for each pt, project it
%can probably vectorize this process
for i=1:size(pts2d,1)
    
    pt3d = [pts2d(i,:)';1];
    pt3d = inv(C')*pt3d; 
    pt3d = R'*pt3d;
 
   
    pts3d(:,i) = pt3d;
    d = pt3d/norm(pt3d);
    dirs(:, i) = [d(1);d(2);d(3)];
end

dirs = -dirs'; 

end

