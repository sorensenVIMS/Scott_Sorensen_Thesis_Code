function [refractedRay] = refractRay( incomingRay, surfaceNormal, ior1,ior2 )
%REFRACTRAY This function will refract a ray according to Snell's law.
%incomingRay is a 3D vector of the incident ray direction
%surface noraml is the refracting surface normal as a 3D vector
%ior1 and ior2 are the Index Of Refraction of the two mediums

c1 =dot(surfaceNormal,-1*incomingRay);
n = ior1/ior2;
c2 = sqrt(1-(n^2)*(1-c1^2));
refractedRay = (n * incomingRay) + ((n * c1 - c2) * surfaceNormal);
refractedRay = refractedRay/norm(refractedRay); %normalizing 
end

