clear;
clc;
close all;
% initialization of the parameters for the function
global mat sigma   
mat = 15;                                      
sigma = 3;
numFrame=18;
position=cell(1,numFrame);
%initialize the image array
frame=zeros(512,512,numFrame);

denoisedFrame=zeros(512,512,numFrame);
denoisedFrame2=zeros(512,512,numFrame);
for i=numFrame
frame(:,:,i)=imread("Simulate_movie_hw2.tif",i);
figure(i)
denoisedFrame(:,:,i)=medfilt2(frame(:,:,i), [5,5]);
% h = [-1 -1 -1;-1 8 -1;-1 -1 -1];
% denoisedFrame2(:,:,i) = imfilter(denoisedFrame(:,:,i),h);
denoisedFrame2(:,:,i) = imbinarize(denoisedFrame(:,:,i)./255, 'global');

imshow(denoisedFrame2(:,:,i))
center(:,:,i) = regionprops(denoisedFrame2(:,:,i), 'centroid');
s = regionprops(logical(denoisedFrame2(:,:,i)), 'Centroid');
centroids = cat(1,s.Centroid);
hold on
plot(centroids(:,1),centroids(:,2),'*b')
p=FastPeakFind(denoisedFrame(:,:,i));
position(i)={[p(1:2:end),p(2:2:end)]};
end



%for finding peaks
% exampleFrame=denoisedFrame(:,:,1);
% p=FastPeakFind(exampleFrame);
% imagesc(exampleFrame); hold on;
% plot(p(1:2:end),p(2:2:end),'r+');
% position=[p(1:2:end),p(2:2:end)];

% frame_exp=frame(:,:,1);
% figure;
% imshow(uint8(frame(:,:,1)));
% figure;
% imshow(uint8(denoisedFrame(:,:,1)));
% figure;
% imshow(uint8(frame(:,:,2)));
% figure;
% imshow(uint8(denoisedFrame(:,:,2)))
% 





