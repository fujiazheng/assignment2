tStart = tic; % start the time of the code so we can determine efficiency of code wrt time

for avg = 1:5
    clearvars -except tStart;
    clc;
    close all;
    % initialization of the parameters for the function
    numFrame=18;
    position=cell(1,numFrame);
    %initialize the image array
    frame=zeros(512,512,numFrame-1);
    %index variable copy the index in different frames
    index=zeros(numFrame,12);
    
    numObjects = 12; % initialize number of objects in the images

    %create denoised images
    denoisedFrame=zeros(512,512,numFrame); 
    denoisedFrame2=zeros(512,512,numFrame); 
    L = zeros(512,512,18);
    coord = zeros(12,2,18);
    %create a matrix to store 12 particles in different frames
    objectCrop = cell(numFrame,12);
    prevObjects = cell(numFrame-1,12);
    %have the code read the ground truth table so it can be used to compare
    %later on
    GT_table = readtable("ground_truth_positions.xlsx",'ReadVariableNames',false);
    
    for i=1:numFrame
        frame(:,:,i)=imread("Simulate_movie_hw2.tif",i); % have the code read all the frames of the images
        %remove the salt and pepper noise
        denoisedFrame(:,:,i)=medfilt2(frame(:,:,i), [5,5]);
        % h = [-1 -1 -1;-1 8 -1;-1 -1 -1];
        % denoisedFrame2(:,:,i) = imfilter(denoisedFrame(:,:,i),h);
        denoisedFrame2(:,:,i) = imbinarize(denoisedFrame(:,:,i)./255, 'global');
        
       %each of these parameters will be used for the ID vector. We figured
       %that the more parameters for the objects that we have, the better
       %the correlation coefficient accuracy will be. Therefore, we chose 4
       %parameters and will use all four to compare each of the objects
        center(:,:,i) = regionprops(denoisedFrame2(:,:,i), 'centroid');
        s = regionprops(logical(denoisedFrame2(:,:,i)), 'Centroid');
        bounding = regionprops(logical(denoisedFrame2(:,:,i)), 'BoundingBox');
        ss = regionprops(logical(denoisedFrame2(:,:,i)),'BoundingBox');
        sss = regionprops(logical(denoisedFrame2(:,:,i)), 'Circularity');
        ssss = regionprops(logical(denoisedFrame2(:,:,i)), 'Eccentricity');
        sizes(:,:,i) = cat(1,ss.BoundingBox); %extract sizes of objects based on bounding boxes
        centroids(:,:,i) = cat(1,s.Centroid); % extract centroid x and y position based on centroids
        circularity(:,:,i) = cat(1,sss.Circularity); % extract circularity of each object
        eccentricity(:,:,i) = cat(1,ssss.Eccentricity); % extract eccentricity of each object
    
        %% Plot - we did this so we could visualize our centroids/objects, not necessary for final code
        % figure(i)
        % imshow(denoisedFrame2(:,:,i))
        % hold on
        % plot(centroids(:,1,i),centroids(:,2,i),'*b')
        % plot(table2array(GT_table(i*1:18:216,4)),table2array(GT_table(i*1:18:216,3)), '*r')
        % hold off
        % L(:,:,i) = bwlabel(logical(denoisedFrame2(:,:,i)),8);
    
        
        for j = 1:height(centroids)
            objectCrop{i,j} = num2cell(imcrop(denoisedFrame2(:,:,i), bounding(j,:).BoundingBox));
            
% here, the order of particles was initialized so that we can reorder the
% arbitrary ordering that MATLAB did on its own for each particle. This way
% we could compare the distances of the objects. However, this was not
% needed for the correlation coefficient calculations as the objects would
% be compared to all objects so the order of them being compared should not
% matter.

            if i == 1
                order = [2, 5, 6, 8, 10, 9, 7, 12, 11, 4, 3, 1];
                orderedCentroids(order,:,i) = centroids(:,:,i);
                index(i,j)=j;
                list = orderedCentroids;
                % We multiply the sizes, circularity and eccentricity of
                % the objects because we want to weight the various values,
                % and we found the sizes was the most important aspect of
                % the ID vector, so the sizes became the driving part of
                % the correlation comparison
                IDvector(:,:,i) = horzcat(centroids(:,:,i),3.*sizes(:,3:4,i),3.*circularity(:,:,i),3.*eccentricity(:,:,i)); % create ID vector with centroids (x,y pos) and sizes (x,y pos of bounding box, circularity and eccentricity)
            end
            if i > 1 
            %% Compare the correlation coefficients
                    IDvector(:,:,i) = horzcat(centroids(:,:,i),3.*sizes(:,3:4,i),3.*circularity(:,:,i),3.*eccentricity(:,:,i)); % create ID vector with centroids (x,y pos) and sizes (x,y pos of bounding box, circularity and eccentricity)
            %Go through each object in the previous frame
                for k = 1:height(centroids)
                    oldIDobject = IDvector(k,:,i-1);
                    newIDobject = IDvector(j,:,i);
                    temp = corrcoef(newIDobject,oldIDobject); %calculate the correlation coefficient between the new object with each particle in the previous frame
                    correlation_coeffs(k,j,i) = temp(1,2); %arrange the correlation coefficients into an array so that the max corresponding coefficient can allow for the objects to be matched in the next line of code
                    k = find(correlation_coeffs(:,j,i)==max(correlation_coeffs(:,j,i))); % dupliate the particle index of the one that has the highest correlation coefficient
                end
                
                index(i,j)=index(i-1,k); %here, the index of objects is set so that the corresponding objects can be labeled using the correlation coefficients and which object matches best to the previous object in the previous frame                         
            end
        end   
        if i>1
            orderedCentroids(order,:,i) = centroids(index(i,:),:,i); 
            list = cat(1,list, orderedCentroids(:,:,i));            
        end
        newIDvector(:,:,i) = horzcat(orderedCentroids(:,:,i),sizes(:,3:4,i),circularity(:,:,i),eccentricity(:,:,i)); % create ID vector with centroids (x,y pos) and sizes (x,y pos of bounding box and x,y size)
    end

    

    % Here we calculate the false negative and false positive values
    
    %% Error
    reorder = list(1:12:end,:);
    for z=2:12
    reorder = cat(1, reorder, list(z:12:end,:));
    end
    
    % Initialize false negative count
    false_negative_count = 0;
    false_positive_count = 0;
    distance = zeros(12,1);
    
    % Iterate through each frame
    for i = 1:numFrame
        % Iterate through each object in the current frame
        for j = 1:numObjects
            % Get position and size of the current object
            obj_x = newIDvector(:, 1, i);
            obj_y = newIDvector(:, 2, i);
            for k = 1:numObjects
                other_obj_x(k,1) = GT_table{1*i+(k-1)*18,4};
                other_obj_y(k,1) = GT_table{1*i+(k-1)*18,3};
            end
            % Iterate through other objects in the same frame
            % Compute distance between the objects
            distance(:,:,i) = sqrt((obj_x - other_obj_x).^2 + (obj_y - other_obj_y).^2);
            
            %Compute error
            error_pixel(:,:,i) = diag(distance(:,:,i));
            
            % Check if the distance exceeds a threshold
            
    
        end
    end
    % if the pixel distance is larger than our threshold (which can be
    % changed depending on how precise we want to be), then it will be
    % identified as a false positive. If there are less objects detected
    % than are in the ground truth table, this will provide a false
    % negative.
    if any(any(any(error_pixel > 2))) && (any(obj_x ~=0) && any(other_obj_x ~= 0))
        false_positive_count = height(any(any(any(error_pixel > 2))) && (any(obj_x ~=0)));
        disp(['There are ', num2str(false_positive_count), ' false positives']);
    elseif any(any(any(error_pixel > 2))) && (any(obj_x ==0) && any(other_obj_x == 0))
        false_negative_count = height(any(obj_x==0));
        disp(['There are ', num2str(false_negative_count), ' false negatives']);
    end
    % Display total false negatives
    disp(['Total false negatives: ', num2str(false_negative_count)]);
    % Display total false positives
    disp(['Total false positives: ', num2str(false_positive_count)]);
    
end
ellapsedTime = toc(tStart); % the end of the tic-toc to calculate how long it took to run the program - this is our efficiency
disp(['Code runtime is: ', num2str(ellapsedTime/5), ' seconds over 5 iterations']) % proper statement of program efficiency
