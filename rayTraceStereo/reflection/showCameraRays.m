function rays =  showCameraRays(C,T,R,xRes,yRes,color)
%this function is to visualize a camera as a cone of rays. It is helpful for 
%figuring out just what the heck is going on with the
%getCameraRay code
%C is the intrinsic matrix
%T is the camera position
%R is the camera rotation matrix
%xres and yres are the cameras resolution in x and y
%color is the color to draw the rays
% note: this function should be used in conjunction with hold on to draw
% multiple cameras
rayNum = 3;


princPt = [C(3,1),C(3,2)];
index = 1;


xstep = xRes/rayNum;
ystep = yRes/rayNum;

for x = 0:rayNum
    for y = 0:rayNum
        xind = x*xstep;
        yind = y*ystep;
        pt = [xind, yind];
        camRay = getCameraRay( C, R, pt);
        rays(index,:)= -1 * camRay(:);
        index = index + 1;
    end
end

orig = repmat(T,size(rays,1),1);

quiver3(orig(:,1),orig(:,2),orig(:,3),rays(:,1),rays(:,2),rays(:,3),25,'color',color);
end

