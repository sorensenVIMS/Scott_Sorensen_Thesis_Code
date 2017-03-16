function [ intersection, error ] = intersectRays( origin1,dir1,origin2,dir2 )
%INTERSECTRAYS this function solves the least square intersection between
%rays. it will return the point of closest intersection, and the error of
%fit
%origin1, and origin2 are the ray orgins for both rays
%dir1 and dir2 are the ray directions for both rays

%direction components
a1= dir1(1);
a2= dir2(1);
b1= dir1(2);
b2= dir2(2);
c1= dir1(3);
c2= dir2(3);

%ray origin components
x1 = origin1(1);
x2 = origin2(1);
y1 = origin1(2);
y2 = origin2(2);
z1 = origin1(3);
z2 = origin2(3);

%setting up for multiplication of the form Ax = B

A =[1,0,0,-a1,0; ...
    1,0,0,0,-a2;...
    0,1,0,-b1,0;...
    0,1,0,0,-b2;...
    0,0,1,-c1,0;...
    0,0,1,0,-c2];

B=[x1;x2;y1;y2;z1;z2];

x = mldivide(A,B);

intersection = x(1:3)';
t1 = x(4);
pt1 = origin1 + t1*dir1;

error = sqrt(sum((intersection-pt1).^2));
end

