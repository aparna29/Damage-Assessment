FeatureVectorImage=zeros(1,66);
%mapping=getmapping(8,'u2');
img = imread('cathedral2011.jpg');
% J = adapthisteq(img);
% %imshow(J);
% % Non linear median filter to remove noise
% img=medfilt2(J);
[rows,cols,dim] = size(img);
[labels, numlabels] = slicomex(img,200);%numlabels is the same as number of superpixels
%figure;
%imagesc(labels);
reshapelabel=transpose(reshape(labels,1,prod(size((labels)))));
segmented_img=cell(1,numlabels);
[rows,cols,dim] = size(img);
seg_label=repmat(labels,[1 1 3]);
black = zeros(1,numlabels);
for l=0:numlabels-1
    color = img;
    color(seg_label~=l) =0;
    segmented_img{l+1} = color;
end
nonblack = zeros(1,numlabels);
for i=0:numlabels-1
    for j=2:rows-1
        for k=2:cols-1
            if(i==labels(j,k))
                nonblack(1,i+1)=nonblack(1,i+1)+1;
            end
        end
    end
end

%final histogram for every super pixel
% final feature vector
homovector = [];
for i=0:numlabels-1
    seg_gray=rgb2gray(segmented_img{i+1});
    %temp_hist=lbp(seg_gray,1,8,mapping,'h');
    glcm = graycomatrix(seg_gray);
    temp = graycoprops(glcm);
    homogeneity = temp.Homogeneity;
    homovector=cat(1,homovector,homogeneity);
end
%train=featurevector;
I = rgb2gray(img);
% Adaptive histogram equalization - preprocessing for improving contrast in
% images by constructing several histograms to redistribute lightness
J = adapthisteq(I);
%imshow(J);
% Non linear median filter to remove noise
K=medfilt2(J);
% entropy value of 9*9 neighbourhood of the pixel. Entropy - histogram
% uniformity
L=entropyfilt(K);
reshapeL=transpose(reshape(L,1,prod(size((L)))));
% standard deviation of each pixel with 3*3 window size
M=stdfilt(K);
reshapeM=transpose(reshape(M,1,prod(size((M)))));
featurevector =  cat(2,reshapeL,reshapeM);
%featurevector = Extractfeature(img);
training_data=test(featurevector,rows,cols,numlabels,reshapelabel);
training_final = cat(2,training_data,homovector);
%FeatureVectorImage=cat(1,FeatureVectorImage,training_final);
%featurevector=traning_data;
