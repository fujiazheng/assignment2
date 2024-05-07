clc
clear all
imds_Image = imageDatastore('DeepLearningData', "FileExtensions", ".mat", 'ReadFcn', @(x) double(load(x) .ReturnArray{1}));
Boxes =  datastore('DeepLearningData', 'Type', 'file', 'ReadFcn', @ (x) (load(x). ReturnArray{2}));
Labels = datastore ('DeepLearningData', 'Type', 'file', 'ReadFcn', @ (x) categorical(load(x). ReturnArray{3}));
blds = boxLabelDatastore(table(readall(Boxes), readall(Labels)));
imds_Mask = imageDatastore('DeepLearningData', "FileExtensions", ".mat", 'ReadFcn', @(x) load (x). ReturnArray{4});
numTrainFiles = 12;
%[imdsTrain,imdsTest] = splitEachLabel(imds_Image,numTrainFiles,"randomized"); %changed imds to TrainingData, it is possible that imds_Image should be used here
LabelsData = read(Labels);
inputSize = [1940, 1460, 3]; %Not sure what the one represents
numClasses = numel(categories(LabelsData)); %changed imds.Labels to im
TrainingData =  combine(imds_Image,blds,imds_Mask);
preview(TrainingData)
layers = [
    imageInputLayer(inputSize)
    convolution2dLayer(5,20)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer];
options = trainingOptions("sgdm", ...
    MaxEpochs=4, ...
    Verbose=false, ...
    Plots="training-progress", ...
    Metrics="accuracy");
net = trainnet(imds_Image,layers,"crossentropy",options); %changed imdsTrain to imds_Image
XTest = readall(imds_Image); %changed imdsTest to imds_Image
TTest = LabelsData; %changed imdsTest.Labels to Labels
classNames = categories(TTest);
XTest = cat(4,XTest{:});
XTest = single(XTest);
YTest = minibatchpredict(net,XTest);
YTest = onehotdecode(YTest,classNames,2);
confusionchart(TTest,YTest)