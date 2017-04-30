FeatureVectorImage=zeros(1,62);
mapping=getmapping(8,'u2');
path = path_files();
path_size = size(path,2);
for itr=1:path_size
img = imread(path{itr});
% I = rgb2gray(img);
% J = adapthisteq(I);
% img=medfilt2(J);
% img = imread('latimer-2-data.jpg');
[rows,cols,dim] = size(img);
[labels, numlabels] = slicomex(img,200);%numlabels is the same as number of superpixels
%figure;
%imagesc(labels);
reshapelabel=transpose(reshape(labels,1,prod(size((labels)))));
segmented_img=cell(1,numlabels);
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
% I = rgb2gray(img);
% J = adapthisteq(I);
% img=medfilt2(J);


%% final histogram for every super pixel
black= zeros(1,numlabels);
black(:,:)=(rows-2)*(cols-2);
black_final=black-nonblack;
hist = [];
for i=0:numlabels-1
    seg_gray=rgb2gray(segmented_img{i+1});
    J = adapthisteq(seg_gray);
    seg_gray = medfilt2(J);
    temp_hist=lbp(seg_gray,1,8,mapping,'h');
    temp_hist(1,58)=temp_hist(1,58)-(black_final(1,i+1));
    hist=cat(1,hist,temp_hist);
end
homovector = [];
for i=0:numlabels-1
    seg_gray=rgb2gray(segmented_img{i+1});
    % temp_hist=lbp(seg_gray,1,8,mapping,'h');
    glcm = graycomatrix(seg_gray);
    temp = graycoprops(glcm);
    homogeneity = temp.Homogeneity;
    homovector=cat(1,homovector,homogeneity);
end
%% final feature vector
%train=featurevector;
%train=featurevector;
I = rgb2gray(img);
J = adapthisteq(I);
K = medfilt2(J);
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
training_final = cat(2,training_final,hist);
FeatureVectorImage=cat(1,FeatureVectorImage,training_final);
%featurevector=traning_data;

FeatureVectorCell = FeatureVectorImage;
end
