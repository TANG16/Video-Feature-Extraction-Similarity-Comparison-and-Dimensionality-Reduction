%PCA for Sift Vectors

clear variables;
close all;
clc;


dirPrompt='Please enter full path of your directory';
dirPath=input(dirPrompt,'s');
newdimensionPrompt='enter new dimension';
new_dimensions=input(newdimensionPrompt);
outputpath2=fullfile(dirPath,'in_file_d_index.spca');
outPutFileId2 = fopen(outputpath2,'W');
in_file = csvread(fullfile(dirPath,'in_file.sift'));
sift_desc = in_file(:,6:end-1);
%sift_desc_z = zhrhrhscore(sift_desc);
correlationMat = corrcoef(sift_desc);
[coeff,latent,explained] = pcacov(correlationMat);
score = sift_desc * coeff;
reducedDimension = score(:,(1:new_dimensions));
order=[1:new_dimensions];
coeff = coeff(:,order(1:new_dimensions));
[len breadth]=size(coeff);
for val=1:breadth
    [scores, original_index] = sort(abs(coeff(:,val)), 'descend');
    for i=1:len
        fprintf(outPutFileId2,'%f\t',val);
        fprintf(outPutFileId2,'<%f,',original_index(i,:));
        fprintf(outPutFileId2,'%f>\n',scores(i,:));
    end
end
curMat = in_file(:,1:5);
finalMatrix = horzcat(curMat, reducedDimension);
csvwrite(fullfile(dirPath,'in_file_d.spc'),finalMatrix);
fclose(outPutFileId2);