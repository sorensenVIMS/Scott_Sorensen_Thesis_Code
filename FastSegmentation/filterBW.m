function filtered = filterBW( binImage)
%This function is used to get rid of some of the noise from a binary image
% by opening and closing the image ususing a morphological structuring. It
% is basically a wrapper for a few morphological operations
%binImage is the input binary image
%filtered is the output binary image

% element se determined experimentally
rad = 13;
se = strel('diamond',rad);

%opening
filtered = imerode(binImage,se);
filtered = imdilate(filtered,se);

%closing
filtered = imdilate(filtered,se);
filtered = imerode(filtered,se);

end

