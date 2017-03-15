function [ intersectionPoint ] = planeIntersect( planeCenter,planeNormal,rayOrigin,rayDir)
%PLANEINTERSECT This function will return the intersection of a 3D ray and
%plane as a 3D point
%planeCenter is a 3D point on the plane
%planeNormal is 3D surface normal of the plane
%rayOrigin is the 3D point of origin of the ray
%rayDir is the 3D direction of the ray

ldotn = dot(rayDir,planeNormal);

if ldotn == 0; %line and plane are parallel 
    disp('plane and ray are parallel!');
    disp('that shouldnt happen');
    intersectionPoint = [0,0,0];
else
   d = ((planeCenter - rayOrigin)*planeNormal')/(ldotn);
   intersectionPoint = d*rayDir+rayOrigin;
end

end

