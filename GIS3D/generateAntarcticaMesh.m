%this script uses data compiled by the Birtish Antarctic Survey's Bedmap2
%project and will generate a 3D model suitable to import into VR or a
%rendering platform. The Bedmap2 project can be found here:
%https://www.bas.ac.uk/project/bedmap-2/ a
clear;
clc;

zscale = 12; %scaling height (this is just for aesthetics and visualization)
meshDir = [pwd '/models/']; 
[bedRock, mapCellR] = geotiffread('https://www.dropbox.com/s/yblchfqtbtvhgop/bedmap2_bed.tif?raw=1'); 
[iceSurf, ~] = geotiffread('https://www.dropbox.com/s/g2btf6hexx8um54/bedmap2_surface.tif?raw=1');
waterMask = iceSurf > 32700;


%% generating vertices
ind = 1; 
stepSize = 50; %resolution of resulting model
 for x = 1:stepSize: size(bedRock,1)
     for y = 1:stepSize:size(bedRock,2)
         val(ind) = not(waterMask(x,y));
         rockPts(ind,:) = [x,y,bedRock(x,y)];
         icePts(ind,:) = [x,y,iceSurf(x,y)];
         ind = ind + 1;
     end
 end
 

%% generating faces
%upper triangles
xsteps = numel(1:stepSize: size(bedRock,1));
ysteps = numel(1:stepSize: size(bedRock,2));
meshInd = 0;
for x = 1:(xsteps)
    for y = 1:(ysteps-1);
        meshInd = meshInd + 1;
        ind1 = y + (ysteps*(x-1));
        ind2 = ind1 + 1;
        ind3 = ind1 + ysteps + 1;
        faces(meshInd,:)=[ind1,ind2,ind3];
    end
end

%lower triangular meshes
for x = 1:(xsteps +1)
    for y = 1:(ysteps-1);
        meshInd = meshInd + 1;
        ind1 = y + (ysteps*(x));
        ind3 = ind1 + 1;
        ind2 = ind1 - ysteps;
        faces(meshInd,:)=[ind1,ind2,ind3];
    end
end

%% Eliminating erroneous faces
[r,~] = find(faces>numel(rockPts(:,1)));
faces(r,:) = [];

notLand = find(not(val));
[Lia,Locb] = ismember(faces,notLand);
 [r,~] = find(Lia);
 
 faces(r,:) = [];
 
 %% visualizing mesh
 figure;
 trimesh(faces,rockPts(:,1),rockPts(:,2),rockPts(:,3)/zscale,'edgecolor','r','facealpha',0)
 
 hold on
 trimesh(faces,icePts(:,1),icePts(:,2),(icePts(:,3)+rockPts(:,3))/zscale,'edgecolor','b','facealpha',0)
axis equal
title('Mesh structure of Antarctica, Red = rock, Blue = ice');

%% Computing normals
iceCloud =  pointCloud(double([icePts(:,1),icePts(:,2),icePts(:,3)/1000]));
 icenormals = pcnormals(iceCloud);
 
rockCloud =  pointCloud(double([rockPts(:,1),rockPts(:,2),rockPts(:,3)/1000]));
rocknormals = pcnormals(rockCloud);


 
%% generating UV coordinates
texUV = []; 
im = customColormap(iceSurf);
texUV = [double(icePts(:,2))/double(size(iceSurf,1))...
    ,1-double(icePts(:,1))/double(size(iceSurf,2))];
iceVerts = [icePts(:,1),icePts(:,2),(icePts(:,3))/zscale];
 rockVerts = [rockPts(:,1),rockPts(:,2),rockPts(:,3)/zscale];
 
%% Creating and writing mesh
vertCell{1} = rockVerts;
vertCell{2} = iceVerts;

textureCoordCell{1} = texUV;
textureCoordCell{2} = texUV;

vnormalsCell{1} = rocknormals;
vnormalsCell{2} = icenormals;

facesCell{1} = faces;
facesCell{2} = faces;

imageCell{1} = uint8(round(customColormap2(bedRock)*255));
imageCell{2} = uint8(round(im*255));

%note this is OS dependent and the function may need modification
%writeMultiMatObj( vertCell, textureCoordCell, vnormalsCell, facesCell, imageCell, meshDir, 'AntarcticaMesh' );
 