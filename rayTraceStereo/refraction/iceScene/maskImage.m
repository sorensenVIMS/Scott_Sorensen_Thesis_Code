function masked = maskImage(image, mask)
%This function outputs an image that is a result of darkening the mask it
%is used for visualizing a masked region
%image is the input image to mask off
%mask is the binary mask
masked = uint8(double(image) - double(image).*(8/10* double(cat(3,mask,mask,mask))));
end
