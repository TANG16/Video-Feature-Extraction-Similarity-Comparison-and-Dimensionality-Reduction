%Program to convert each frame in video to grayscale, split into r cells,
%and plot histogram 

%-------------------------------------------------------------------------%
clear variables;
close all;
clc;
%-------------------------------------------------------------------------%

%get input variables and initialize them
%-------------------------------------------------------------------------%
prompt = 'Enter the video input directory' ;
video_input_directory = input(prompt, 's');

prompt = 'Enter the resolution vector r';
r = input(prompt);

n = input('Enter the size of color histogram  n(1-256)');
if isnan(n) || n>256
  n = input('Please enter an INTEGER: between 1-256');
end

prompt = 'Enter the output filename';
file_name = input(prompt, 's');

%-------------------------------------------------------------------------%
Files=dir(fullfile(video_input_directory,'*mp4'));
File_names = sort_nat({Files.name});

video_no = 1;
fileID = fopen(file_name,'w');

for fl=1:length(File_names)
    video_file = strcat(video_input_directory, '\', File_names(fl));
    vOb = VideoReader(char(video_file));
        
    %setting up the vectors for mat2cell function
    row_divider = floor(vOb.height/r);
    column_divider = floor(vOb.width/r);
    row_divider_vector = [];
    column_divider_vector = [];
    row_divider_vector = row_divider*ones(1,r-1);
    row_divider_vector(end+1) = row_divider + rem(vOb.height,r);
    column_divider_vector = column_divider*ones(1,r-1);
    column_divider_vector(end+1) = column_divider + rem(vOb.width,r);
    frame_no = 1;
    
    while hasFrame(vOb)  
      
        rgbframe = readFrame(vOb);                                             %read frame
        grayframe = rgb2gray(rgbframe);                                        %convert frame to grayscale
       
        c = mat2cell(grayframe, row_divider_vector, column_divider_vector);    %divide frame into 4 cells
        cell_no = 1;
        for j=1:size(c,1)
            for k=1:size(c,2)
                h = imhist(c{j,k},n);
                fprintf(fileID,'%g , %g , %g , %s \n',video_no, frame_no, cell_no, mat2str(h'));
                cell_no = cell_no + 1;
            end
        end
        frame_no = frame_no + 1;
    end
    video_no = video_no + 1;
    close all;
end
   