%-------------------------------------------------------------------------%
clear variables;
close all;
clc;
%-------------------------------------------------------------------------%
%Matlab program to generate k similarity graph

dirPrompt = 'Please enter the input directory';
dirPath = input(dirPrompt, 's');
kPrompt = 'Please enter the value of k';
k = input(kPrompt, 's');
%input = csvread('C:\ASU\PROJECTS\MWDB Project\Phase3\Task2\in_file_d.spca');
input = csvread(fullfile(dirPath, 'in_file_d.spc'));

%A = csvread('C:\ASU\PROJECTS\MWDB Project\Phase3\Task2\in_file_d.spca');
A = input;
countsA = hist(A(:,1),unique(A(:,1)));
vidObjA = mat2cell(A,countsA,size(A,2));
vidObjByFrameA = cellfun(@(x)...
    mat2cell(x,hist(x(:,2),unique(x(:,2)),size(x,2))),...
    vidObjA,'uniformOutput',false);
%build a matrix of KD trees where each KD tree contains all descriptors for
%a frame
for l=1:size(vidObjByFrameA,1)
    for m=1:size(vidObjByFrameA{l,1},1)
        kdtree{l,m} = vl_kdtreebuild(vidObjByFrameA{l,1}{m,1}') ;
    end
end

similarity_matrix = [];
similarity_row = [];
%for every video in the query space
for i=1:size(vidObjByFrameA,1)
    tic;
    %for every frame in the query video
    for j=1:size(vidObjByFrameA{i,1},1)
        similarity_count = 0;
        all_similarity = [];
        sim_achieved = 0;
        %for every video in the object space
        for l=1:size(vidObjByFrameA,1)
            %if query video equals object video then continue
            if i == l
                continue;
            end
            %for every frame in the object video
            for m=1:size(vidObjByFrameA{l,1},1)
                [index, distance] = vl_kdtreequery(kdtree{l,m},vidObjByFrameA{l,1}{m,1}', vidObjByFrameA{i,1}{j,1}','NumNeighbors', 2) ;
                out_distance = bsxfun(@rdivide, distance(1,:), distance(2,:));
                less_distance = out_distance < 0.8;
                out_distance = out_distance(less_distance);
                similarity = size(out_distance,2)/ size(distance,2);
                all_similarity_row = [i j l m similarity];
                all_similarity = [all_similarity; all_similarity_row];
                if similarity == 1
                    similarity_count = similarity_count + 1;
                    similarity_row = [i j l m similarity];
                    similarity_matrix = [similarity_matrix;similarity_row];
                end
                if similarity_count == str2num(k)
                    sim_achieved = 1;
                    break;
                end
            end
            if similarity_count == str2num(k)
                sim_achieved = 1;
                break;
            end
            
        end
        if sim_achieved == 0
                sort_all_similarity = sortrows(all_similarity,5);
                similarity_matrix = similarity_matrix(1:end-similarity_count,:);
                sorted_k_similarity = sort_all_similarity(end-str2num(k)+1:end,:);
                similarity_matrix = vertcat(similarity_matrix, sorted_k_similarity);
                %similarity_matrix = [similarity_matrix;similarity_row];
        end  
        
    end
    elapsed = toc;
    disp(toc);
end

csvwrite(fullfile(dirPath, 'in_file_d_k.gspc'), similarity_matrix);


