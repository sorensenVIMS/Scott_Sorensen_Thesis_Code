function mask = meltSegment( image )
%%This function applies the colorspace transformation and vectorized
%thresholding scheme with parameters selected for metl ponds. 
%image is the input image (rgb)
%mask is the binary output mask with detected melt ponds.
rthresh = 0;
gthresh = 6;
bthresh = 7;
[mimage,~] = minusmin(image);
mask = filterBW(customThresh(mimage,[rthresh,gthresh,bthresh]));
end

