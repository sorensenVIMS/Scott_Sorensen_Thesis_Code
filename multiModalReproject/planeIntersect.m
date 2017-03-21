
function [ intersectionPoint ] = planeIntersect( planeCenter,planeNormal,rayOrigin,rayDir)
%PLANEINTERSECT Summary of this function goes here
%   Detailed explanation goes here
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


