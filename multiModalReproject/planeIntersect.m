function [ intersectionPoint ] = planeIntersect( planeCenter,planeNormal,rayOrigin,rayDir)
%This function will find the intersection of a ray and a plane.
%planecenter is a point on the plane
%planeNormal is the surface normal of the plane
%rayOrigin is the origin of the ray
%rayDir is the direction of the ray
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


