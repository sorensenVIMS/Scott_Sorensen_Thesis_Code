function [] = writeObj( vert, textureCoord, vnormals, faces, image, location, filename )
%WRITEOBJ this function will write an obj and mtl file from a 3D set of
%points their corresponding texture coordinates, 
%   this is based off the standard for a waverfront obj file see http://en.wikipedia.org/wiki/Wavefront_.obj_file for reference
%vert is a list of vertices  
%textureCoord are normalized texture coordinates for each vertex
%vnorms are normalized normals for each vertex
%faces are sets of vertices to make polygons
%image is the image to texture map
%location is the path to write in
%filename is the file to write to (note this will actually write 3 files


formatSpec = '%10.10f';
  
  currentWriteFile = fopen([location filename '.obj'],'w');
  imWidth = size(image,2);
  imHeight = size(image,1);


  
  fprintf(currentWriteFile,'%s\r\n',['o ' filename]);
  fprintf(currentWriteFile,'%s\r\n\r\n',['mtllib ' filename '.mtl']);
  
  %writing vertices
  for i = 1:size(vert,1)
      currpoint = vert(i,:);
      pointstr = [num2str(currpoint(1),formatSpec) ' ' num2str(currpoint(2),formatSpec)...
 ' ' num2str(currpoint(3),formatSpec)];
      fprintf(currentWriteFile,'%s\r\n',['v ' pointstr]);
  end
    fprintf(currentWriteFile,'\r\n');
  %writing texture coordinates
  for i = 1:size(textureCoord,1)
      currTexCoord = textureCoord(i,:);
      texString = [num2str(currTexCoord(1),formatSpec) ' ' num2str(currTexCoord(2),formatSpec)];
      fprintf(currentWriteFile,'%s\r\n',['vt ' texString]);
  end
    fprintf(currentWriteFile,'\r\n');  

  %writing normals
  for i = 1:size(textureCoord,1)
      currNorm = vnormals(i,:);
      normString = [num2str(currNorm(1),formatSpec) ' ' num2str(currNorm(2),formatSpec)...
 ' ' num2str(currNorm(3),formatSpec)];
      fprintf(currentWriteFile,'%s\r\n',['vn ' normString]);
  end
 fprintf(currentWriteFile,'\r\n');  

  %writing faces
  for i = 1:size(faces,1)
      currFace = faces(i,:); %list of vertex indices
      vert = num2str(currFace(1));
      vertex1str = [vert '/' vert '/' vert];
      vert = num2str(currFace(2));
      vertex2str = [vert '/' vert '/' vert];
      vert = num2str(currFace(3));
      vertex3str = [vert '/' vert '/' vert];
      faceString = [ vertex1str ' '  vertex2str ' '  vertex3str];
      fprintf(currentWriteFile,'%s\r\n',['f ' faceString]);
  end
 fprintf(currentWriteFile,'\r\n');
 fclose(currentWriteFile);
 
 
 %writing the .mtl file
 currentWriteFile = fopen([location filename '.mtl '],'w');
 fprintf(currentWriteFile,'%s\r\n',['newmtl ' filename]);
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
 
 

 fprintf(currentWriteFile,'\t%s\r\n',['map_Kd ' filename '.png']);
 fprintf(currentWriteFile,'\t%s\r\n',['map_Ka ' filename '.png']);
 fclose(currentWriteFile);
 
 imwrite(image,[location filename '.png']);
end

