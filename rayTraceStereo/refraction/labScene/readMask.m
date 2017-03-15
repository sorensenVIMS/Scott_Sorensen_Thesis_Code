function [ mask ] = readMask( fname )
%READMASK This function used to read in a mask made in MS Paint. It just
%reads in a file and looks for red portions
%fname is the filename to read
im = imread(fname);
redChan = im(:,:,1);
bluechan = im(:,:,2);
temp = bluechan <20; % just looking for red pixels not white

mask = redChan>220; % this is to allow for jpeg-y masks that aren't 255
mask = and(mask,temp); 

end

