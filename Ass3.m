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
for i=1:numFrame
frame(:,:,i)=imread("Simulate_movie_hw2.tif",i);
denoisedFrame(:,:,i)=medfilt2(frame(:,:,i));
p=FastPeakFind(denoisedFrame(:,:,i));
position(i)={[p(1:2:end),p(2:2:end)]};
end



%for finding peaks
% exampleFrame=denoisedFrame(:,:,1);
% p=FastPeakFind(exampleFrame);
% imagesc(exampleFrame); hold on;
% plot(p(1:2:end),p(2:2:end),'r+');
% position=[p(1:2:end),p(2:2:end)];

%for testing 
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





