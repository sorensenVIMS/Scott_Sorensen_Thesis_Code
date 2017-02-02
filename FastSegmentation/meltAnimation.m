%this script is to animate some images of meltponds and their masks
imdir = 'C:\Users\Scott\Desktop\mappingDir\algaeDetectedImages\melt\original\';
outdir = 'C:\Users\Scott\Desktop\mappingDir\algaeDetectedImages\melt\originalAndDetected\';
files = dir(imdir);
files(1:2)=[];
ind = 1;
numNon = 10;
numBlend = 10;
for x = 1:size(files)
    im = imread([imdir files(x).name]);
    algMask = meltSegment(im);
    mask = maskImage(im,~algMask);
    %imshow(maskImage(im,~algMask));
    for i = 1:numNon
        imwrite(im,[outdir num2str(ind,'%04d') '.png']);
        ind = ind+1;
    end
    for i = 1:numBlend
        blend = i/numBlend;
        blended = blendImages( im,mask, blend);
        imwrite(blended,[outdir num2str(ind,'%04d') '.png']);
        ind = ind+1;
    end
    for i=1:numNon
        
        imwrite(mask,[outdir num2str(ind,'%04d') '.png']);
        ind = ind+1;
    end
end