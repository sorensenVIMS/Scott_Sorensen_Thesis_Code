%this script is used to generate a plane mesh  

clear
clc
load('Ark27params')
load('meanPlane')
%imleft = imread('E:\PSITRES\testingsubsets\3Dtests\polarstern\left\00000.jpg');
texIm = imread('https://www.dropbox.com/s/k2l8wfd1jhr4lko/00000.jpg?raw=1');

camMat = params.calib_params.left.A;
R = eye(3);
[height,width,~] = size(texIm);
xskip=50;
yskip = 50;
index = 0;
scale = 1/1000; % to convert to meters

for xi = 1:xskip:width %the full sphere in x direction
    for yi =1:yskip:height  % min to max y
        %calculating vertex Location
        index = index + 1;
        
        rayDir = getCameraRay(camMat',R,[xi,yi]);
        
        intersectionPoint = planeIntersect(meanCentroid,meanPlaneNorm',[0,0,0],rayDir);
        
        vert(index,:)=scale*intersectionPoint.*[-1,-1,-1];
        
 
        textureCoord(index,:) = [1-xi/width,1-yi/height];
        
        %calculating vertex normals
        vnorm = [meanPlaneNorm];
        vnormals(index,:) = (vnorm/norm(vnorm));
        
    end
end

%figure;
%scatter3(vert(:,1),vert(:,2),vert(:,3))

%%
meshInd = 0;
ySteps = numel(1:yskip:height);
xSteps = numel(1:xskip:height);


%upper triangular meshes       %dont mess with this its actually working
for x = 1:(xSteps-1)
    for y = 1:(ySteps-1);
        meshInd = meshInd + 1;
        ind1 = y + (ySteps*(x-1));
        ind2 = ind1 + 1;
        ind3 = ind1 + ySteps + 1;
        faces(meshInd,:)=[ind1,ind2,ind3];
    end
end




%lower triangular meshes
for x = 1:(xSteps-1)
    for y = 1:(ySteps-1);
        meshInd = meshInd + 1;
        ind1 = y + (ySteps*(x-1));
        ind2 = ind1 + ySteps + 1;
        ind3 = ind1 + ySteps;
        faces(meshInd,:)=[ind1,ind2,ind3];
    end
end

load('PSITREStransform.mat')
%load('minimizedRot')
outVert = rotmat*vert';
outNorms = rotmat*vnormals';

%load('TranslationPSITRES')
%psitresTranslation(2) = -1*psitresTranslation(2);

repTrans =repmat(psitresTranslation',1,size(outVert,2));
outVert = outVert + repTrans;

writeObj(outVert', textureCoord, outNorms', faces, texIm, '/Users/sorensen/Desktop/Scott_Sorensen_Thesis_Code/multiModalReproject/meshes/','stereoplane')

%}

