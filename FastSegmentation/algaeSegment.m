function mask = algaeSegment( image )
%%This function applies the colorspace transformation and vectorized
%thresholding scheme with parameters selected for algae. 
%image is the input image (rgb)
%mask is the binary output mask with detected algae
rthresh = 9;
gthresh = 7;
bthresh = 0;
[mimage,~] = minusmin(image);
mask = filterBW(customThresh(mimage,[rthresh,gthresh,bthresh]));
end
