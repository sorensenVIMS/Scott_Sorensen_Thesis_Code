function masked = maskImage(image, mask)
%This function outputs an image that is a result of darkening the mask
masked = uint8(double(image) - double(image).*(3/5 * double(cat(3,mask,mask,mask))));
end
