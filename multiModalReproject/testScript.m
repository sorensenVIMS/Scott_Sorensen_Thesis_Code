%This script will generate both models with correspond UV coordinates so
%that they can be loaded into VR or for rendering.
clear; clc; close all

%thermal model
disp('Generating thermal model...');
[vert1, textureCoord1, vnormals1, faces1] = thermalReproject();
thermTex = imread('https://www.dropbox.com/s/x0qxfjbxtakzrfa/20120917-091218-8.tif?raw=1');
writeObj(vert1, textureCoord1, vnormals1, faces1, thermTex, [pwd '/meshes/'],'thermMesh');
disp('Done.');

%stereo model
disp('Generating stereo model...');
stereoTex = imread('https://www.dropbox.com/s/k2l8wfd1jhr4lko/00000.jpg?raw=1');
[vert2, textureCoord2, vnormals2, faces2] = stereoReproject(stereoTex);
writeObj(vert2, textureCoord2, vnormals2, faces2, stereoTex, [pwd '/meshes/'],'stereoMesh');
disp('Done.');