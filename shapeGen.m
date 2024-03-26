function [mask] = shapeGen(numCircles,numEllipses)
%UNTITLED2 Summary of this function goes here
imageSize=512;
intensityRange = [100,180]; 
ellipseAspect =0.8;
numObjects = numCircles+numEllipses;
mask=cell(1,numObjects);
canvas = zeros(imageSize,imageSize,3);
objects = NaN(numObjects,3);
minCircleSize = 20; % Minimum size of objects
maxCircleSize = 80; % Maximum size of objects
minEllipseMajor = 40;
maxEllipseMajor = 100;
for i = 1:numObjects
    % Random intensity
    intensity = randi([intensityRange(1), intensityRange(2)]);
    % Random position


    if i <=numObjects/2
        % Random size
        size = randi([minCircleSize, maxCircleSize]);
        objects(i,3) = size/2;
        objects(i,1) = randi([1+uint64(size/2), imageSize-uint64(size/2)]);
        objects(i,2) = randi([1+uint64(size/2), imageSize-uint64(size/2)]);
        center = [objects(i,1), objects(i,2)];
        
        
        if i > 1
            dist = sqrt((objects(1:i-1,1) - center(1)).^2+(objects(1:i-1,2)-center(2)).^2);
    
                while any(dist < (objects(1:i-1,3) + size/2)+10)
                    objects(i,1) = randi([1+uint64(max(objects(:,3))), imageSize-uint64(max(objects(:,3)))]);
                    objects(i,2) = randi([1+uint64(max(objects(:,3))), imageSize-uint64(max(objects(:,3)))]);
                    center = [objects(i,1), objects(i,2)];
                    dist = sqrt((objects(1:i-1,1) - center(1)).^2+(objects(1:i-1,2)-center(2)).^2);
                end
        end
                [X, Y] = meshgrid(1:imageSize, 1:imageSize);
                mask{1,i} = (X-center(1)).^2 + (Y-center(2)).^2 <= (size/2)^2;
                
                % Apply intensity to circle region
                canvas(mask{1,i}) = intensity(:,:,1);
                imshow(uint8(canvas), [])
    else
        majorAxis = randi([minEllipseMajor, maxEllipseMajor]);
        minorAxis = majorAxis*ellipseAspect;
        objects(i,1) = randi([1+majorAxis, imageSize-majorAxis]);
        objects(i,2) = randi([1+majorAxis, imageSize-majorAxis]);
        center = [objects(i,1),objects(i,2)];

        axisSelect = randi([1,2]);
        if axisSelect ==1
            a = majorAxis;
            b = minorAxis;
        else
            a = minorAxis;
            b = majorAxis;
        end
        objects(i,3) = majorAxis;
        if i>numCircles
            dist = sqrt((objects(1:i-1,1) - center(1)).^2+(objects(1:i-1,2)-center(2)).^2);
            while any(dist < (objects(1:i-1,3) + majorAxis))
                majorAxis = randi([minEllipseMajor, maxEllipseMajor]);
                minorAxis = majorAxis*0.8;
                axisSelect = randi([1,2]);
                if axisSelect ==1
                    a = majorAxis;
                    b = minorAxis;
                else
                    a = minorAxis;
                    b = majorAxis;
                end
                objects(i,3) = majorAxis;
                objects(i,1) = randi([1+majorAxis, imageSize-majorAxis]);
                objects(i,2) = randi([1+majorAxis, imageSize-majorAxis]);
                center = [objects(i,1), objects(i,2)];
                dist = sqrt((objects(1:i-1,1) - center(1)).^2+(objects(1:i-1,2)-center(2)).^2);
            end
        end
            [X, Y] = meshgrid(1:imageSize, 1:imageSize);
            mask{1,i} = ((X-center(1)).^2)./a^2 + ((Y-center(2)).^2)./b^2 <= 1;
            
            % Apply intensity to circle region
            canvas(mask{1,i}) = intensity(:,:,1);
            imshow(uint8(canvas), [])
        
    end
end
end
