clear;
clc;
close all;
% initialization of the parameters for the function
numFrame=18;
position=cell(1,numFrame);
%initialize the image array
frame=zeros(512,512,numFrame-1);
%index variable copy the index in different frames
index=zeros(numFrame,12);

numObjects = 12;

denoisedFrame=zeros(512,512,numFrame);
denoisedFrame2=zeros(512,512,numFrame);
comparison=zeros(1, 12,numFrame);
L = zeros(512,512,18);
coord = zeros(12,2,18);
objectCrop = cell(numFrame,12);
prevObjects = cell(numFrame-1,12);

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
    ss = regionprops(logical(denoisedFrame2(:,:,i)),'BoundingBox');
    sizes(:,:,i) = cat(1,ss.BoundingBox)
    centroids(:,:,i) = cat(1,s.Centroid);


    hold on
    plot(centroids(:,1,i),centroids(:,2,i),'*b')
    hold off
    L(:,:,i) = bwlabel(logical(denoisedFrame2(:,:,i)),8);

    
    for j = 1:height(centroids)
        objectCrop{i,j} = num2cell(imcrop(denoisedFrame2(:,:,i), bounding(j,:).BoundingBox));
        
        if i == 1
            order = [2, 5, 6, 8, 10, 9, 7, 12, 11, 4, 3, 1];
            orderedCentroids(order,:,i) = centroids(:,:,i);
            index(i,j)=j;
            list = orderedCentroids;
        end
        if i > 1 
        %% Compare the distance
            dist= (centroids(j,1,i)-centroids(:,1,i-1)).^2 + (centroids(j,2,i)-centroids(:,2,i-1)).^2;
            k=find(dist==min(dist(:)));
            index(i,j)=index(i-1,k);
            
            
        %% below is for correlation
            prevObjects{i,j} = objectCrop{i-1,j};
                for k = 1:height(centroids)
                    size1 = size(cell2mat(objectCrop{i,k}));
                    size0 =size(cell2mat(prevObjects{i,j}));
                    padded1 = padarray(cell2mat(objectCrop{i,k}), ceil(([15 15]-size1)/2) , 0,'pre');
                    padded1= padarray(padded1, floor(([15 15]-size1)/2), 0,'post');
                    padded2 = padarray(cell2mat(prevObjects{i,j}), ceil(([15 15]-size0)/2) , 0,'pre');
                    padded2 = padarray(padded2, floor(([15 15]-size0)/2), 0,'post');
                    comparison(k,j,i) = corr2(padded1,padded2);
                end
        end
    end
    if i>1
    orderedCentroids(order,:,i) = centroids(index(i,:),:,i);
    list = cat(1,list, orderedCentroids(:,:,i));
    end

IDvector(:,:,i) = horzcat(centroids(:,:,i),sizes(:,:,i)); % create ID vector with centroids (x,y pos) and sizes (x,y pos of bounding box and x,y size)

        for c=2:12
            for d = 1:12
                if i >= 2
                oldIDvector = IDvector(:,:,i-1);
                newIDVector = IDvector(:,:,i);
                oldIDobject = IDvector(c-1,:,i-1);
                newIDobject = IDvector(c,:,i);
                correlation_coeffs(:,:,i) = corrcoef(newIDobject,IDvector(d,:,i-1));
                end
            end    
        end
end


%% Error
reorder = list(1:12:end,:);
for z=2:12
reorder = cat(1, reorder, list(z:12:end,:));
end

GT_table = readtable("ground_truth_positions.xlsx");

errorX = ((reorder(:,1)-GT_table(:,4))./GT_table(:,4)).*100;
errorY = ((reorder(:,2)-GT_table(:,3))./GT_table(:,3)).*100;

%% False negative test
for i = 1:numObjects
    for j = 1:numFrame
        for k = 1:numObjects*numFrame
GT_X = GT_table{k,4};
GT_Y = GT_table{k,3};

tracked_pos_x = IDvector(i,1,j);
tracked_pos_y = IDvector(i,2,j);

error_percentage(k) = (dist(i)/ sqrt((tracked_pos_x-GT_X)^2 + (tracked_pos_y-GT_Y)^2))*100; %dist array from earlier step

false_negative_count = 0;

if error_percentage > 10
    disp(['Object ', num2str(i), ' is not a false negative.'])
else
    false_negative_count = false_negative_count + 1;
    disp(['Object ', num2str(i), ' is a false negative.']);
end

        end
    end
end

disp(['There are ', num2str(false_negative_count), 'false negatives.'])

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
