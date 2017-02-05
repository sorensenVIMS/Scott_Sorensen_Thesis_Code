function masked = maskImage(image, mask)
%This function outputs an image that is a result of darkening the mask. It is used for visualization
%image is the input rgb image
%mask is the binary mask
%masked is the output masked image (rgb)
masked = uint8(double(image) - double(image).*(3/5 * double(cat(3,mask,mask,mask))));
end
