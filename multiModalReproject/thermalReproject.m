function [vert, textureCoord, vnormals, faces] = thermalReproject()
%thermalReproject will create mesh elements for a segment of a sphere for
%the polarstern infrared images. it will return vertices, corresponding
%texture coordinates, vertex normals and faces. These are set to be written
%to an obj file

xres = 5; %resolution in degrees
yres = 1; %resolution in degrees
pixelPitchy = 18/576; %degrees/pixels


%distance to horizon
h = 25.5; %height in meters
d = 3.57*sqrt(h); %d is in km
horizonDist = 1000*d;% converting to meters
angleFromHorizontal = -1*atand(h/horizonDist);


%finding minimum and maximum angle of declination
%determined specifically for this camera setup using the horizon and FOV
horizPixels = 40;
minY = deg2rad(angleFromHorizontal-((576-horizPixels)*pixelPitchy));
texmaxY = deg2rad((pixelPitchy*40)+(angleFromHorizontal));
maxY= deg2rad(angleFromHorizontal);

xres = deg2rad(xres);
yres = deg2rad(yres);
index = 0;

%vertex normals
vnorm = [0,0,1];
for theta = 0:xres:2*pi %the full sphere in x direction
    for phi= minY:yres:maxY % min to max y
        
        %calculating vertex Location
        index = index + 1;
        
        %intersecting the plane
        [x,y,z] = sph2cart((theta-pi/2),phi,1); %finds the vector
        intersectionPoint = planeIntersect( [0,0,(-1*h)],[0,0,1],[0,0,0],[x,y,z]);
        vert(index,:)=intersectionPoint;
        
        %calculating textureCoordinates
        xPos = 1-(theta/(2*pi));
        yPos = (phi -minY)/(texmaxY-minY);
        textureCoord(index,:) = [xPos,yPos];
        
        %vertex normals
        vnormals(index,:) = vnorm/norm(vnorm);
        
    end
end

xSteps = floor(2*pi/xres);
ySteps = floor((maxY - minY)/yres) + 1;

meshInd =0;
%upper triangular meshes
for x = 1:(xSteps)
    for y = 1:(ySteps-1)
        meshInd = meshInd + 1;
        ind1 = y + (ySteps*(x-1));
        ind2 = ind1 + 1;
        ind3 = ind1 + ySteps + 1;
        faces(meshInd,:)=[ind1,ind2,ind3];
    end
end
%lower triangular meshes
for x = 1:(xSteps)
    for y = 1:(ySteps-1)
        meshInd = meshInd + 1;
        ind1 = y + (ySteps*(x-1));
        ind2 = ind1 + ySteps + 1;
        ind3 = ind1 + ySteps;
        faces(meshInd,:)=[ind1,ind2,ind3];
    end
end
end



