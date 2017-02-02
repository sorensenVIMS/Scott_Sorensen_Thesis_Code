function mask = christianSeg( image )
%CUSTOMSEGMENT Summary of this function goes here
%   Detailed explanation goes here
rthresh = 0;
gthresh = 4;
bthresh = 4;
mimage = minusmin(image);
mask = filterbw2(customThresh(mimage,[rthresh,gthresh,bthresh]));
end
