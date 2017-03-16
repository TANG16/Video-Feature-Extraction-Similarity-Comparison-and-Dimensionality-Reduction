%LSH for Sift Vectors

clear variables;
close all;
clc;


dirPrompt='Please enter full path of your directory';
dirPath=input(dirPrompt,'s');
layersPrompt='Enter the number of layers';
layers=input(layersPrompt);
bucketPrompt='Enter the number of buckets';
buckets=input(bucketPrompt);
outputpath=fullfile(dirPath,'in_file_d.lsh');
outPutFileId = fopen(outputpath,'W');
in_file = csvread(fullfile(dirPath,'in_file_d.spc'));
sift_desc = in_file(:,6:end);
noOfDim = size(sift_desc,2);
k = log2(buckets);
%hash = zeros(k,size(sift_desc,1));
kmat = [];
index_mat = [];
final_index_mat = [];
for l = 1:layers
    hash = zeros(k,size(sift_desc,1));
    for j = 1: k
        guassVec = randn(1,noOfDim);
        guassMag = abs(norm(guassVec));
        guassVec = guassVec/guassMag;
        %w = guassMag/buckets;
        %w = guassMag/2;
        %b = (w-0).*rand(1,1)+0;
        repGauss = repmat(guassVec,size(sift_desc,1),1);
        projectedVec = dot(sift_desc,repGauss,2);
        for i = 1: size(sift_desc,1)
             %hash(i) = mod(floor((projectedVec + b)/w), buckets);
             %{
             if floor((projectedVec + b)/w )== 2
                 hash(j,i) = 1;                     
             else
                 hash(j,i) = floor((projectedVec +b)/w);
             end
             %}
             if projectedVec(i) > 0 
                 hash(j,i) = 1;                     
             else
                 hash(j,i) = 0;
             end
             
        end
    end
    %kmat = getCollision(hash);
    for m = 1: size(hash,2)
        kmat(l,m) =   bi2de(hash(:,m)');  
    end
    layer(1:size(sift_desc,1)) = l;
    index_mat = horzcat([layer' kmat(l,:)' in_file(:,1:5)]);
    final_index_mat = vertcat(final_index_mat,index_mat);
end
csvwrite(fullfile(dirPath,'in_file_d.lsh'),final_index_mat);
fclose(outPutFileId);