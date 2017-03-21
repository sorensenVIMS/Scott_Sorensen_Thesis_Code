%This script will generate both models with correspond UV coordinates so
%that they can be loaded into VR or for rendering.

%thermal model
[vert, textureCoord, vnormals, faces] = thermalReproject();
thermTex = imread('https://www.dropbox.com/s/x0qxfjbxtakzrfa/20120917-091218-8.tif?raw=1');
writeObj(vert, textureCoord, vnormals, faces, thermTex, [pwd '/meshes/'],'thermMesh');

%stereo model
stereoReproject