%Program to convert each frame in video to grayscale, split into r cells,
%and extract SIFT vectors

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

prompt = 'Enter the output filename';
file_name = input(prompt, 's');

%-------------------------------------------------------------------------%
Files=dir(fullfile(video_input_directory,'*mp4'));
File_names = sort_nat({Files.name});
fileID = fopen(file_name,'w');
video_no = 1;

for fl=1:length(File_names)
    video_file = strcat(video_input_directory, '\', File_names(fl));
    vOb = VideoReader(char(video_file));
        
    %setting up the vectors to divide frames into cells logically
    
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
       
        [frames,descr] = sift(grayframe) ;
            for w=1:size(frames,1)
                    for u=1:size(frames,2)
                        sift_1 = frames(:,u);
                        coord = [sift_1(1), sift_1(2)];
                        for v=1:size(descr,2)
                            sift_2 = descr(:,v);
                        end
                        sift_vector = [sift_1' sift_2'] ;
                        x = ceil((coord(1)/column_divider));
                        y= ceil((coord(2)/row_divider));
                        cell_no = (x-1)*(floor(size(grayframe,2)/column_divider)) + y;
                        fprintf(fileID,'%g , %g , %g , [%s] \n',video_no, frame_no, cell_no, num2str(sift_vector));  
                    end
            end
                
                
            frame_no = frame_no + 1;
    end
    video_no = video_no + 1;
    close all;
end
   