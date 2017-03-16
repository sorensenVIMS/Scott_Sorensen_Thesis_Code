function [ leftpts,rightpts] = maskSift( imleft,imright, mask )
%MASKSIFT This function matches points between two images and ignores
%points outside of a masked area
%imleft and imright are the two images to match (this was developed for
%stereo, hence the names)
%mask is the binary mask, 0 means reject points in this region

%NOTE: This function requires vl_feat to be configured see their website
%for more info: http://www.vlfeat.org/install-matlab.html

        grayleft = rgb2gray(imleft);
        grayright = rgb2gray(imright);
        [fa, da] = vl_sift(single(grayleft)) ;
        [fb, db] = vl_sift(single(grayright)) ;
        [matches, scores] = vl_ubcmatch(da, db) ;
        leftpts = fa(1:2, matches(1,:));
        rightpts = fb(1:2, matches(2,:));
        for x = 1:size(leftpts,2)
           ex = leftpts(1,x);
           ey = leftpts(2,x);
           approx = round([ex,ey]);
           temp = mask(approx(2),approx(1));
           inmask(x) = temp;
        end
        invalid = find(~inmask);
        leftpts(:,invalid) = [];
        rightpts(:,invalid) = [];
        pause(1);
end

