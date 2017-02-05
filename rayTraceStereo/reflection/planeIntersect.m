function [ intersectionPoint ] = planeIntersect( planeCenter,planeNormal,rayOrigin,rayDir)
%PLANEINTERSECT this function computers the intersection of a ray and a
%plane
%planeCenter is the plane center 3D 
%planeNormal is the unit normal of the plane in 3D
%rayOrigin is the origin of the ray to intersect
%rayDir is the direction of the ray 
%all of these parameters can be either 1x3 or 3x1
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

