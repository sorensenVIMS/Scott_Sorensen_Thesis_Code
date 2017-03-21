function [vert, textureCoord, vnormals, faces] = stereoReproject(texIm)
%this function will return mesh elements for the PSITRES stereo system
%aboard the RV Polarster. It uses the mean stereo plane and generates the
%mesh parametrically. It takes an input image from the camera system to so
%it can use the right size. It returns a set of vertices, corresponding texture
%coordinates, vertex normals, and faces. It is set up to be able to be
%written to an obj file. 
load('Ark27params')
load('meanPlane')


camMat = params.calib_params.left.A;
R = eye(3);
[height,width,~] = size(texIm);
xskip=50;
yskip = 50;
index = 0;
scale = 1/1000; % to convert to meters

for xi = 1:xskip:width %the full image in x direction
    for yi =1:yskip:height  % the full image in y direction
        %calculating vertex Location
        index = index + 1;
        
        rayDir = getCameraRay(camMat',R,[xi,yi]);
        intersectionPoint = planeIntersect(meanCentroid,meanPlaneNorm',[0,0,0],rayDir);
        vert(index,:)=scale*intersectionPoint.*[-1,-1,-1];
        
        %texture coordinates
        textureCoord(index,:) = [1-xi/width,1-yi/height];
        
        %vertex normals
        vnorm = [meanPlaneNorm];
        vnormals(index,:) = (vnorm/norm(vnorm));
        
    end
end
meshInd = 0;
ySteps = numel(1:yskip:height);
xSteps = numel(1:xskip:height);

%generating faces
%upper triangular meshes 
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
outVert = rotmat*vert';
outNorms = rotmat*vnormals';
vnormals = outNorms';


repTrans =repmat(psitresTranslation',1,size(outVert,2));
outVert = outVert + repTrans;
vert = outVert';
end
