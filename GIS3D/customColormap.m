function [ cmapped ] = customColormap( inputIm )
%This is a helper function to colormap texture for the Antarctica mesh
minT = 250;
maxT = 4000;
inputIm(inputIm < minT) = minT;
inputIm(inputIm > maxT) = maxT;
cmapped = grs2rgb((round(inputIm/255)),jet);
end

