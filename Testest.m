model = load("VIP_Actin_Training.mat");
detector = model.net;
i = load('Cell_64_Actin_new.mat');
imageProcessed = i.ReturnArray{1};
figure;
imshow(imageProcessed);
title('Original Image');
[masks,labels,scores,bboxes] = segmentObjects(detector,imageProcessed, Threshold=0.067);
if isempty(bboxes)
    disp('No objects detected.');
else
    for idx = 1:size(bboxes, 1)
        rectangle('Position', bboxes(idx, :), 'EdgeColor', 'r', 'LineWidth', 2);
    end
end
hold off;