%This script will write a 3D mesh of the Conterminus USA with correspond
%texture from MODIS satelite surface temperature from March 2001

meshDir = [pwd '/meshDir/'];
states = shaperead('usastatelo', 'UseGeoCoords', true); % reading in US states
states([2,11]) = [];
lat = [states.Lat];
lon = [states.Lon];
[Z, R] = vec2mtx(lat, lon, 25, 'filled');

%uncomment to visualize the states
%figure; worldmap(Z, R);geoshow(Z, R, 'DisplayType', 'texturemap');
im = imread('https://www.dropbox.com/s/rtxiww3mxtb983e/Colormapped.png?raw=1');
colormap(flag(3));
load topo % topo map of the USA
%% generating vertices
pts = [];
for x =1:numel(states)
    state = states(x);
    tpts = [state.Lat;state.Lon]';
    pts = [pts;tpts];
    
end
%elimanting bad points
inv = find(isnan(pts(:,1)));
pts(inv,:) = [];
inv = find(isnan(pts(:,2)));
pts(inv,:) = [];

%%
padding = 5;
minLat = min(pts(:,1)-padding);
minLon = min(pts(:,2)-padding);
maxLat = max(pts(:,1)+padding);
maxLon = max(pts(:,2)+padding);


gridStep = 1;
gridPts = [];
valid = [];
elevs = [];
for la = minLat:gridStep:maxLat
    for lo = minLon:gridStep:maxLon
        gridPts = [gridPts;la,lo];
        val = ltln2val(Z, R, la, lo);
        valid = [valid;val];
        elev = ltln2val(topo,topolegend,la,lo);
        elevs = [elevs;elev];
    end
end


%% Creating faces
xsteps = numel(minLat:gridStep:maxLat);
ysteps = numel(minLon:gridStep:maxLon);
meshInd = 0;
%upper triangular faces
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
for x = 1:(xsteps)
    for y = 1:(ysteps-1);
        meshInd = meshInd + 1;
        ind1 = y + (ysteps*(x-1));
        ind2 = ind1 + ysteps + 1;
        ind3 = ind1 + ysteps;
        faces(meshInd,:)=[ind1,ind2,ind3];
    end
end

[r,~] = find(faces>numel(elevs));
faces(r,:) = [];
notUSA = find(not(or(valid == 0,valid==1)));
[Lia,Locb] = ismember(faces,notUSA);
[r,~] = find(Lia);

faces(r,:) = [];
%visualizing the mesh
figure;
trimesh(faces,gridPts(:,1),gridPts(:,2),elevs/1000)
axis ij;
axis equal;
title('Elevation map of the USA');

%% Generating vertex normals
ptCloud =  pointCloud([gridPts(:,1),gridPts(:,2),elevs/1000]);
normals = pcnormals(ptCloud);




%% generating texture coordinates
texUV = [];
for x = 1:size(gridPts,1)
    ptLat = gridPts(x,1);
    ptLon = gridPts(x,2);
    texX = ((ptLon/180)+1)/2;
    texY = ((ptLat/90)+1)/2;
    texUV(x,:) = [texX,texY];
end

vert = [gridPts(:,1),-1*gridPts(:,2),elevs/1000,normals(:,1)];

%% Writing Mesh
%note this is OS dependent and you may need to modify this function
%writeObj( vert, texUV, normals, faces, im, meshDir,'mesh2' );


