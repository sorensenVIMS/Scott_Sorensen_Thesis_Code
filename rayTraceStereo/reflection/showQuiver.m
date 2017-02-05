function showQuiver( pointVec,normal,viewVec,reflectedvec,normColor,viewColor,reflectedColor )
%This function is to show the rays reflecting off the surface. It is for visualizing and debugging.
%It shows the view vector, the surface orientation and the reflected rays
%pointVec is the intersection point for the reflection
%normal is the surface normal of the reflecting surface
% viewVec is the incident ray directions
%reflectedVec is the reflected ray directions
%normColor is the color to draw the surface normal
%viewColor is the color to draw the incident rays
%reflectedColor is the color to draw the reflected rays

skip = 50;%used to subsample dense rays


normalVec = repmat(normal',size(pointVec,1),1);

quiver3(pointVec(1:skip:end,1),pointVec(1:skip:end,2),pointVec(1:skip:end,3),normalVec(1:skip:end,1),normalVec(1:skip:end,2),normalVec(1:skip:end,3),0,normColor)
hold on


pointVec2 = pointVec -viewVec;

quiver3(pointVec2(1:skip:end,1),pointVec2(1:skip:end,2),pointVec2(1:skip:end,3), viewVec(1:skip:end,1), viewVec(1:skip:end,2), viewVec(1:skip:end,3),0,viewColor)
quiver3(pointVec(1:skip:end,1),pointVec(1:skip:end,2),pointVec(1:skip:end,3), reflectedvec(1:skip:end,1), reflectedvec(1:skip:end,2), reflectedvec(1:skip:end,3),0,reflectedColor)
axis equal
end

