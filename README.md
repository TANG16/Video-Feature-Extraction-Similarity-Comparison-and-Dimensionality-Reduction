# Video-Feature-Extraction-Similarity-Comparison-and-Dimensionality-Reduction

Multimedia Information Retrieval can be divided into three different categories: Summarization of media content which is also called as feature extraction, filtration of media content and categorization of media content. Three features of video files are extracted: color histogram, SIFT vectors and motion vectors. They are compared using Euclidean distances and Chi squared Distances. Principal Component Analysis is applied on these features to reduce their dimensions. The features with reduced dimensions are stored and indexed using locality sensitive hashing. Finally, video similarity is obtained by comparing these features.

## Implementation

Following are the Matlab programs to implement the tasks described above.

1. color_histogram_extraction.m is a matlab file and is used to extract the color histogram for videos.

2. sift_vector_extraction.m is a matlab file and is used to extract sift vectors for videos in a given input directory.

3. ExtractMV.cpp is a cpp file used to extract motion vectors for videos in a given input directory.

4. sift_compare.py is a python file to comapre SIFT vectors using Euclidean distance.

5. pca_sift.m is a program to apply Principal Component Analysis on SIFT vectors.

6. Phase3Task2main.m is a Matlab program to generate k similarity graph using kd trees.

7. Phase3Task5main.m is a Matlab program to implement Locality Sensitive Hashing for Sift Vectors.

8. Phase3Task6main.m is a Matlab program to implement index based search of video frames.

## References and APIs

* Lowe, David G. "Distinctive image features from scale-invariant keypoints." International journal of computer vision 60.2 (2004): 91-110.
* https://www.mathworks.com/help/matlab/matlab_external/using-matlab-api-libraries.html
