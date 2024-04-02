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
frame=zeros(512,512,numFrame-1);

denoisedFrame=zeros(512,512,numFrame);
denoisedFrame2=zeros(512,512,numFrame);
comparison=zeros(1, 12,numFrame);

for i=1:numFrame
    frame(:,:,i)=imread("Simulate_movie_hw2.tif",i);
    figure(i)
    denoisedFrame(:,:,i)=medfilt2(frame(:,:,i), [5,5]);
    % h = [-1 -1 -1;-1 8 -1;-1 -1 -1];
    % denoisedFrame2(:,:,i) = imfilter(denoisedFrame(:,:,i),h);
    denoisedFrame2(:,:,i) = imbinarize(denoisedFrame(:,:,i)./255, 'global');
    
    imshow(denoisedFrame2(:,:,i))
    center(:,:,i) = regionprops(denoisedFrame2(:,:,i), 'centroid');
    s = regionprops(logical(denoisedFrame2(:,:,i)), 'Centroid');
    bounding = regionprops(logical(denoisedFrame2(:,:,i)), 'BoundingBox');
    centroids = cat(1,s.Centroid);
    hold on
    plot(centroids(:,1),centroids(:,2),'*b')
    hold off
    L = bwlabel(logical(denoisedFrame2(:,:,i)),8);
    objectCrop = cell(1,length(centroids));
    prevObjects = cell(1,length(centroids));
    
    for j = 1:length(centroids)
        objectCrop{1,j} = num2cell(imcrop(denoisedFrame2(:,:,i), bounding(j).BoundingBox));
        
        % if i > 1 
        %     if j > 1
        %         for k = 1:length(centroids)
        %             prevObjects{1,j} = objectCrop{1,j-1};
        %             size1 = size(cell2mat(objectCrop{1,j}));
        %             size0 =size(cell2mat(prevObjects{1,j}));
        %             padded1 = padarray(cell2mat(objectCrop{1,j}), ceil(([15 15]-size1)/2) , 0,'pre');
        %             padded1= padarray(padded1, floor(([15 15]-size1)/2), 0,'post');
        %             padded2 = padarray(cell2mat(prevObjects{1,j}), ceil(([15 15]-size0)/2) , 0,'pre');
        %             padded2= padarray(padded2, floor(([15 15]-size0)/2), 0,'post');
        %             comparison(1,j,i) = corr2(padded1,padded2);
        %         end
        %     end
        % end
    end



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





