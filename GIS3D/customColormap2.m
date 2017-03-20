function [ cmapped ] = customColormap( inputIm )
%This is a helper function used to colormap the texture file for the
%antarctica mesh
minT = 100;
maxT = 3500;
inputIm(inputIm < minT) = minT;
inputIm(inputIm > maxT) = maxT;
cmapped = grs2rgb((round(inputIm/255)),jet);
end

