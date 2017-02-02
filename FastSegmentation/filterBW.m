function filtered = filterBW( binImage)
%This function is used to get rid of some of the noise from a binary image
% by opening and closing the image ususing a morphological structuring
% element se
rad = 13;
se = strel('diamond',rad);

%opening
filtered = imerode(binImage,se);
filtered = imdilate(filtered,se);

%closing
filtered = imdilate(filtered,se);
filtered = imerode(filtered,se);

end

