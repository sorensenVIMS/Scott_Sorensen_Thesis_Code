function [subMin,minpic] = minusmin( image )
%This function takes an image and computes the minimum color channel and
%then subtracts every channel from this minimum. It is used for rgbi
%thresholding.
%image is the input rgb image;
%subMin is the output 
minpic = min(image,[],3);
subMin = image - cat(3,minpic,minpic,minpic);

end

