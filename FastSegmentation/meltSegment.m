function mask = meltSegment( image )
%CUSTOMSEGMENT Summary of this function goes here
%   Detailed explanation goes here
rthresh = 0;
gthresh = 6;
bthresh = 7;
mimage = minusmin(image);
mask = filterBW(customThresh(mimage,[rthresh,gthresh,bthresh]));
end

