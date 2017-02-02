clear
clc
imageDir =  'D:\meltPonds\';
files = dir(imageDir);
files(1:2)=[]; %gets rid of . and ..
C = makecform('srgb2cmyk');
for x =1:size(files,1)
    im = imread([imageDir files(x).name]);
    mp{x} = minusmin(im);
end
%%
for x =1:size(files,1)
    asdf{x} = customThresh( mp{x},[1,0,0]);
end
se = strel('diamond',12);
disp('starting morph');
%%
tic
for x =1:size(files,1)
     m = imerode(asdf{x},se);
     m = imdilate(m,se);
     m = imdilate(m,se);
     m = imerode(m,se);
end
toc
