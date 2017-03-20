function [ ] = writeMultiMatObj( vertCell, textureCoordCell, vnormalsCell, facesCell, imageCell, location, filename )
%function [] = writeObj( vert, textureCoord, vnormals, faces, image, location, filename )
%writeMultMatObj this function will write an obj and mtl files for an obj with multiple elements that have different textures etc. from a 3D set of
%points their corresponding texture coordinates,
%   this is based off the standard for a waverfront obj file see http://en.wikipedia.org/wiki/Wavefront_.obj_file for reference
%vert is a list of vertices
%textureCoord are normalized texture coordinates for each vertex
%vnorms are normalized normals for each vertex
%faces... Need to edit this
%image is the image to texture map
%location is the path to write in
%filename is the file to write to (note this will actually write 3 files


formatSpec = '%10.10f';
numComp = size(vertCell,2);

%this may need to be modified depending on your OS
currentWriteFile = fopen([location filename '.obj'],'w');



fprintf(currentWriteFile,'%s\r\n',['o ' filename]);
fprintf(currentWriteFile,'%s\r\n\r\n',['mtllib ' filename '.mtl']);

%writing vertices
for currEl = 1:numComp
    vert = vertCell{currEl};
    for i = 1:size(vert,1)
        currpoint = vert(i,:);
        pointstr = [num2str(currpoint(1),formatSpec) ' ' num2str(currpoint(2),formatSpec)...
            ' ' num2str(currpoint(3),formatSpec)];
        fprintf(currentWriteFile,'%s\r\n',['v ' pointstr]);
    end
end
fprintf(currentWriteFile,'\r\n');
%writing texture coordinates
for currEl = 1:numComp
    textureCoord = textureCoordCell{currEl};
    for i = 1:size(textureCoord,1)
        currTexCoord = textureCoord(i,:);
        texString = [num2str(currTexCoord(1),formatSpec) ' ' num2str(currTexCoord(2),formatSpec)];
        fprintf(currentWriteFile,'%s\r\n',['vt ' texString]);
    end
end
fprintf(currentWriteFile,'\r\n');

%writing normals
for currEl = 1:numComp
    vnormals = vnormalsCell{currEl};
    for i = 1:size(vnormals,1)
        currNorm = vnormals(i,:);
        normString = [num2str(currNorm(1),formatSpec) ' ' num2str(currNorm(2),formatSpec)...
            ' ' num2str(currNorm(3),formatSpec)];
        fprintf(currentWriteFile,'%s\r\n',['vn ' normString]);
    end
end
fprintf(currentWriteFile,'\r\n');

%writing faces
offset = 0;
for currEl = 1:numComp
    faces = facesCell{currEl};
    fprintf(currentWriteFile,'%s\r\n',['usemtl ' filename num2str(currEl)]);
    for i = 1:size(faces,1)
        currFace = faces(i,:); %list of vertex indices
        vert = num2str(currFace(1) + offset);
        vertex1str = [vert '/' vert '/' vert];
        vert = num2str(currFace(2) + offset);
        vertex2str = [vert '/' vert '/' vert];
        vert = num2str(currFace(3) + offset);
        vertex3str = [vert '/' vert '/' vert];
        faceString = [ vertex1str ' '  vertex2str ' '  vertex3str];
        fprintf(currentWriteFile,'%s\r\n',['f ' faceString]);
    end
    offset = offset + size(vertCell{currEl},1);
end
fprintf(currentWriteFile,'\r\n');
fclose(currentWriteFile);


%writing the .mtl file
currentWriteFile = fopen([location filename '.mtl '],'w');
for currEl = 1:numComp
    im = imageCell{currEl};
    subFile = [filename num2str(currEl)];
    fprintf(currentWriteFile,'%s\r\n',['newmtl ' subFile]);
    fprintf(currentWriteFile,'\t%s\r\n','Ns 10.000');
    fprintf(currentWriteFile,'\t%s\r\n','Ni 1.000');
    fprintf(currentWriteFile,'\t%s\r\n','d 1.0');
    fprintf(currentWriteFile,'\t%ts\r\n','tr 0.000');
    fprintf(currentWriteFile,'\t%s\r\n','tf 1.0000 1.0000 1.0000');
    
    
    fprintf(currentWriteFile,'\t%s\r\n','illum 2');
    
    fprintf(currentWriteFile,'\t%s\r\n','Ka 0.0000 0.0000 0.0000');
    fprintf(currentWriteFile,'\t%s\r\n','Kd 1.0000 1.0000 1.0000');
    fprintf(currentWriteFile,'\t%s\r\n','Ks 0.0000 0.0000 0.0000');
    fprintf(currentWriteFile,'\t%s\r\n','Ke 0.0000 0.0000 0.0000');
    
    
    
    fprintf(currentWriteFile,'\t%s\r\n',['map_Kd ' subFile '.png']);
    fprintf(currentWriteFile,'\t%s\r\n',['map_Ka ' subFile '.png']);
    
    imwrite(im,[location subFile '.png']);
    
end
fclose(currentWriteFile);
end

