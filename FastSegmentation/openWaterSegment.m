function mask = openWaterSegment( image )
%%This function segments open water using the minimum intensity channel
%image is the input image (rgb)
%mask is the binary output mask with detected algae
[~,minChan] = minusmin(image);
mask = minChan < 100;
end

