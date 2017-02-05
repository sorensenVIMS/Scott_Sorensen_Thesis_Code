function [ refray ] = reflectRay( incomingRay,surfaceNormal )
%REFLECTRAY this function reflects a ray in 3D given and incident and a
%normal vector. note the rays should be normalized 
%incomingRay is the incident direction
%surfaceNormal is the reflecting surface orientation
% these parameters can be 1x3 or 3x1
c1 =dot(surfaceNormal,incomingRay);
refray = incomingRay + (2*surfaceNormal*-1*c1);
refray = refray/norm(refray);
end

