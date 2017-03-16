import math
f = open("C:/Users/Vasudha/Documents/MATLAB/sift/abcdefghij", "r")

sift_video1_dict = {}
sift_video2_dict = {}
frame_dict = {}
tl = []
for lines in f:
    tl =lines.strip().split(";")
    video_number = int(tl[0])
    frame_number = int(tl[1])
    sift_string = tl[3].split(",")[4:132]
    sift_vector = [float(x) for x in sift_string]
    if video_number == 1:
        if not frame_number in sift_video1_dict:
            sift_video1_dict[frame_number] = [sift_vector]
        else:
            sift_video1_dict[frame_number].append(sift_vector)
    elif video_number == 2:
        if not frame_number in sift_video2_dict:
            sift_video2_dict[frame_number] = [sift_vector]
        else:
            sift_video2_dict[frame_number].append(sift_vector)

#print("sift_video1_dict",sift_video1_dict)
#print("sift_video2_dict",sift_video2_dict)

def sift_frame_compare(frame1, frame2):
    #list of all minimum distances for each sift1 
    min_sift_distance = []
    #for each sift vector in frame1
    for sift1 in frame1:
        #initialize a list to get minimum sift distance for sift1 with all sift2
        min_distance = []
        #for each sift vector in frame2
        for sift2 in frame2:
            #compute the euclidean distance between sift vectors
            a = [(i-j)**2 for i,j in zip(sift1, sift2)]
            sift_dist = math.sqrt(sum(a))
            min_distance.append(sift_dist)
        sort_min_distance = sorted(min_distance)
        if len(sort_min_distance) >1:
            min1 = sort_min_distance[0]
            min2 = sort_min_distance[1]
            if min1 > 0 and min2/min1 > 1.5:
                min1 = sort_min_distance[0]
                min_sift_distance.append(min1)
            elif sort_min_distance[0] == 0:
                min_sift_distance.append(sort_min_distance[0])
                
        elif len(sort_min_distance) == 1:
            min1 = sort_min_distance[0]
            min_sift_distance.append(min1)
        else:
            continue
    if(len(min_sift_distance) > 0):
        avg_dist = sum(min_sift_distance)/len(min_sift_distance)
    else:
        avg_dist = 10
    return avg_dist
            
    
#list of all frame distances
average_video_distance = []    


#for each frame in video1
for key1 in sift_video1_dict.keys():
    #distances of all frame1 with all frame2
    min_dist_frame = []
    #for each frame in video2
    for key2 in sift_video2_dict.keys():
        #comapre the frame distances
        print(key1, key2)
        d = sift_frame_compare(sift_video1_dict[key1],sift_video2_dict[key2])
        if d:
            min_dist_frame.append(d)
    min_min_dist_frame = sorted(min_dist_frame)
    average_video_distance.append(min_min_dist_frame[0])
    
#print(average_video_distance)
sum_average_video_distance = sum(average_video_distance)
print(sum_average_video_distance/len(average_video_distance)) 
        
