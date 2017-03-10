function [ imagepts, groundpts, r] = genCorrespondences( gbasis1,gbasis2,gnormal,gpoint, camera,scaleFactor )
%GENCORRESPONDENCES Summary of this function goes here
%   Detailed explanation goes here
numCorr = 4;
r1 = randi(2000,numCorr,1);
r2 = randi(200,numCorr,1);
r = [r2,r1];
multfact = scaleFactor;
for x=1:numCorr;
       q1 = multfact*r1(x);
       q2 = multfact*r2(x);
       pt1 = q1*gbasis1+q2*gbasis2+gpoint;
       pt2 = camera*pt1;
       pt2 = pt2/pt2(3);
       
       imagepts(x,:) = pt2;
        
       groundpts(x,:) = pt1;

end

