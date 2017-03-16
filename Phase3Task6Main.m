%-------------------------------------------------------------------------%
clear variables;
close all;
clc;
%-------------------------------------------------------------------------%
%Matlab program to implement index based search

dirPrompt = 'Please enter the input directory of filename_d.lsh';
dirPath = input(dirPrompt, 's');
dirPromptKey = 'Please enter the input directory of filename_d.spc';
dirPathKey = input(dirPromptKey, 's');
nPrompt = 'Please enter the value of n';
n_val = input(nPrompt, 's');
objectprompt = 'Please enter the object description in the form video_no frame_no x1 y1 x2 y2';
object = input(objectprompt, 's');
all_desc = [];
unique_desc = [];
%the lsh file matrix
input = csvread(fullfile(dirPath, 'in_file_d.lsh'));
input_key = csvread(fullfile(dirPathKey, 'in_file_d.spc'));

splitObject = strsplit(object,' ');
video_no = splitObject{1};
frame_no = splitObject{2};
if str2num(splitObject{3}) < str2num(splitObject{5})
    xmin = str2num(splitObject{3});
    xmax = str2num(splitObject{5});
else
    xmin = str2num(splitObject{5});
    xmax = str2num(splitObject{3});
end
if str2num(splitObject{4}) < str2num(splitObject{6})
    ymin = str2num(splitObject{4});
    ymax = str2num(splitObject{6});
else
    ymin = str2num(splitObject{6});
    ymax = str2num(splitObject{4});
end
%all descriptors within the given rectangle with layer_no and bucket_no
in_matrix = [];

for i=1:size(input,1)
    if input(i,6)<xmax & input(i,6)>xmin & input(i,7)<ymax & input(i,7)>ymin & input(i,3) == str2num(video_no) & input(i,4) == str2num(frame_no)
        in_matrix(end+1,:) = input(i,:);
    end
end

no_of_layers = size(unique(in_matrix(:,1)),1);
%matrix of cells where each cell contains all descriptors of a bucket which
%the input descriptor is in
task6_matrix = [];
complete_matrix = [];

for j = 1: no_of_layers
    %contains all descriptors in that particular layer
    layer_matrix = input(input(:,1) == j, :);
    %visited_buckets = [];
    %contains all descriptors which have the buckets equal to unique
    %descriptors within rectangle
    in_layer_matrix = in_matrix(in_matrix(:,1) == j, :);
    bucket_desc = [];
    for i=1:size(in_layer_matrix,1)
        %query = input_key(input_key(:,4) == in_layer_matrix(i,6) & input_key(:,5) == in_layer_matrix(i,7) & input_key(:,1) == in_layer_matrix(i,3) & input_key(:,2) == in_layer_matrix(i,4),:);
        bucket = in_layer_matrix(i,2);
        desc_matrix = layer_matrix(layer_matrix(:,2) == bucket,:);
        desc_matrix(desc_matrix(:, 3)== str2num(video_no), :)= [];

        
        %all_desc = vertcat(all_desc,desc_matrix);
        video_frame_mat = unique(desc_matrix(:,3:4),'rows');
        
        task6_matrix{j,i}= video_frame_mat;
    end
    
end
layer_common=[];
for j = 1: size(task6_matrix,1)
    common_vf = [];
    for i = 2: size(task6_matrix,2)
        if i == 2
            [common_vf,ia,ib] = intersect(task6_matrix{j,1},task6_matrix{j,i},'rows');
        else
            [common_vf,ia,ib]=  intersect(common_vf,task6_matrix{j,i},'rows');
        end
        
    end
    %layer_common{1,j} = get_similarity_values(common_vf, 
    layer_common{1,j} = common_vf;
end

finalDistMat = [];
for i = 1: size(layer_common,2)
    in_layer_matrix = in_matrix(in_matrix(:,1) == i, :);
    bucket_layer_matrix = [];
    layer_matrix = input(input(:,1) == i, :);
    bucket_desc = [];
    %{
    for j = 1: size(layer_common{1,i},1)
        bucket_layer_matrix = vertcat(bucket_layer_matrix,layer_matrix(layer_matrix(:,3) == layer_common{1,i}(j,1) & layer_matrix(:,4) == layer_common{1,i}(j,2) , :));
    end

    for k = 1: size(bucket_layer_matrix,1)
        bucket_desc = vertcat(bucket_desc,input_key(input_key(:,4) == bucket_layer_matrix(k,6) & input_key(:,5) == bucket_layer_matrix(k,7) & input_key(:,1) == bucket_layer_matrix(k,3) & input_key(:,2) == bucket_layer_matrix(k,4),:));
    end
    %}
    for j = 1: size(layer_common{1,i},1)
        bucket_layer_matrix = vertcat(bucket_layer_matrix,input_key(input_key(:,1) == layer_common{1,i}(j,1) & input_key(:,2) == layer_common{1,i}(j,2) , :));
    end
    all_desc = vertcat(all_desc, bucket_layer_matrix);
    for m = 1:size(in_layer_matrix,1)
        distanceMatrix = [];
        query = input_key(input_key(:,4) == in_layer_matrix(m,6) & input_key(:,5) == in_layer_matrix(m,7) & input_key(:,1) == in_layer_matrix(m,3) & input_key(:,2) == in_layer_matrix(m,4),:);
        query = query(1,:);
        %disp(query);
        %for n = 1:size(bucket_layer_matrix,1)
        distanceMatrix = pdist2(query(:,6:end),bucket_layer_matrix(:,6:end),'euclidean');
        %end
        if size(bucket_layer_matrix,2)>0
            distanceMatrix =  horzcat(bucket_layer_matrix(:,1:5),distanceMatrix');
        end
        finalDistMat{i,m} =  distanceMatrix;
    end
    
    
end

n_similar_matrix = [];
%loop for layer
for i=1:size(task6_matrix,1)
    unique_video_frame = layer_common{1,i};
    
    %loop for unique video frame
    for j=1:size(unique_video_frame,1)
        video_buckets_sum = 0;
        %loop for every bucket in layer
        for k=1:size(finalDistMat,2)
            bucket_video_frame_sim = finalDistMat{i,k}(finalDistMat{i,k}(:,1) == unique_video_frame(j,1) & finalDistMat{i,k}(:,2) == unique_video_frame(j,2),:);
            [Y,I] = sort(bucket_video_frame_sim(:,6));
            bucket_video_frame_sim_sort = bucket_video_frame_sim(I,:);
            video_buckets_sum = video_buckets_sum + bucket_video_frame_sim_sort(1,6);
            
        end
        n_similar_matrix(end+1,:) = [unique_video_frame(j,1) unique_video_frame(j,2) video_buckets_sum ];
           
    end

end

n_sim_unique = unique(n_similar_matrix,'rows');
[Y,I] = sort(n_sim_unique(:,3));
n_sim_unique_sort = n_sim_unique(I,:);
if size(n_sim_unique_sort,1) > str2num(n_val)
    n_sim_final = n_sim_unique_sort(1:str2num(n_val),:);
else
    n_sim_final = n_sim_unique_sort(1:end,:);
end

unique_desc = unique(all_desc, 'rows');

X = sprintf('No of total descriptors: %d', size(all_desc,1));
disp(X);
X = sprintf('No of unique descriptors: %d', size(unique_desc,1));
disp(X);
Sdata = whos('unique_desc');
X = sprintf('No of bytes accessed: %d', Sdata.bytes);
disp(X);

dirPathFinal = 'C:\ASU\PROJECTS\MWDB Project\Phase3_New\Demo Videos';
%dirPathFinal = 'C:\ASU\PROJECTS\MWDB Project\Small_dataset';
videoFiles = dir(fullfile(dirPathFinal,'*.mp4'));

for i=1:length(videoFiles)
        if i == str2num(video_no);
            filePathAndName=fullfile(dirPathFinal,videoFiles(i).name);
            v=VideoReader(filePathAndName);
            image = read(v,str2num(frame_no));
            i2 = imcrop(image, [xmin ymin xmax-xmin ymax-ymin]);
            figure,imshow(i2);
            title('Cropped Image');
            break;
        end
end
for j = 1:size(n_sim_final,1)
    for i=1:length(videoFiles)
        if i == n_sim_final(j,1)
            filePathAndName=fullfile(dirPathFinal,videoFiles(i).name);
            vid1=VideoReader(filePathAndName);
            I = read(vid1, n_sim_final(j,2));
            figure,imshow(I);
            break;
        end
    end
end