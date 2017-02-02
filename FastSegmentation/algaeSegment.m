function mask = algaeSegment( image )
%CUSTOMSEGMENT Summary of this function goes here
%   Detailed explanation goes here
rthresh = 9;
gthresh = 7;
bthresh = 0;
mimage = minusmin(image);
mask = filterBW(customThresh(mimage,[rthresh,gthresh,bthresh]));
end
