
%% Load Training Dataset
situation = {'glasses', 'night_noglasses', 'nightglasses', 'noglasses', 'sunglasses'};
rootDirectory = [pwd '/'];

for i=1:length(situation)
    fprintf('Loading training dataset %s\n', situation{i});
    TrainingDataset.(situation{i}) = load([rootDirectory ...
        'ProcessedData/TrainingDataset.mat'], situation{i});
    TrainingDataset.(situation{i}) = TrainingDataset.(situation{i}).(situation{i});
end

% Check dataset
numDescriptorsTrain = zeros(length(situation),1);
numLabelsTrain = zeros(length(situation),1);
for i=1:length(situation)
    
    for j=1:length(TrainingDataset.(situation{i}))
        object = TrainingDataset.(situation{i})(j);
        numDescriptorsTrain(i) = numDescriptorsTrain(i) + size(object.descriptors,1);
    end
    
    for j=1:length(TrainingDataset.(situation{i}))
        object = TrainingDataset.(situation{i})(j);
        numLabelsTrain(i) = numLabelsTrain(i) + size(object.labels,2);
    end
    
    if numDescriptorsTrain(i) ~= numLabelsTrain(i)
        error('Different number of descriptors and labels');
    end
end

numelDescriptor = size(object.descriptors,2);

clear i j object

%% Load test dataset
situation = {'glasses', 'nightnoglasses', 'nightglasses', 'noglasses', 'sunglasses'};
rootDirectory = [pwd '/'];
fprintf('Loading test dataset %s\n', situation{1});


for i=1:length(situation)
    TestDataset.(situation{i}) = load([rootDirectory ...
        'ProcessedData/EvaluationDataset.mat'], situation{i});
    TestDataset.(situation{i}) = TestDataset.(situation{i}).(situation{i});
end

% Check dataset
numDescriptorsTest = zeros(length(situation),1); % Array with the number of descriptors per situation
numLabelsTest = zeros(length(situation),1); % Array with the number of labels per situation
for i=1:length(situation)
    
    for j=1:length(TestDataset.(situation{i}))
        object = TestDataset.(situation{i})(j);
        numDescriptorsTest(i) = numDescriptorsTest(i) + size(object.descriptors,1);
    end
    
    for j=1:length(TestDataset.(situation{i}))
        object = TestDataset.(situation{i})(j);
        numLabelsTest(i) = numLabelsTest(i) + size(object.labels,2);
    end
    
    if numDescriptorsTest(i) ~= numLabelsTest(i)
        error('Different number of descriptors and labels');
    end
end

clear i j
%% Perform PCA analysis and save results for each situation
PCAParams = struct;
fields = fieldnames(TrainingDataset);
for i=1:numel(fieldnames(TrainingDataset))
    
    % Preallocate memory according to the number of descriptors for current
    % situation
    j = strcmp(situation, fields{i});
    TrainDescriptors = zeros(numDescriptorsTrain(j), size(object.descriptors,2));
    
    % Extract descriptors from dataset
    j=1;
    for k=1:length(TrainingDataset.(situation{i}))
        object = TrainingDataset.(situation{i})(k);
        numDescriptors = size(object.descriptors,1);
        TrainDescriptors(j:j+numDescriptors-1,:) = object.descriptors;
        j = j + numDescriptors;
    end
    fprintf('Performing PCA analysis: %s\n', situation{i});
    [coeff,~,eigVal,~,~,mu] = pca(TrainDescriptors);
    
    % Store values in PCA struct
    PCAParams.(situation{i}) = struct;
    PCAParams.(situation{i}).coeff = coeff;
    PCAParams.(situation{i}).eigVal = eigVal;
    PCAParams.(situation{i}).mu = mu;
    TrainDescriptors = [];
end
% Save results
if ~exist([rootDirectory 'ProcessedData/'])
    status = mkdir([rootDirectory 'ProcessedData/']);
    if ~status
        error(['Unable to create folder: ' [rootDirectory 'ProcessedData/']])
    end
end
save([rootDirectory 'ProcessedData/PCATrain.mat'], '-struct', 'PCAParams');

fprintf('PCA analysis finished\n');

clear i j k TrainDescriptors numDescriptors coeff latent eigVal mu

%% BUILD ALTERNATIVE DATASET

% Extract descriptors from dataset
j=1;
alternate = [3,4];
m = alternate(1);
selection = [true, false];
TestDescriptors = [];
TestLabels = [];
TrainDescriptors = [];
TrainLabels = [];
l = 1;
t = 1;
for k=1:length(TrainingDataset.(situation{i}))
    object = TrainingDataset.(situation{i})(k);
    numDescriptors = size(object.descriptors,1);
    if ~mod(k,m) && t<=10
        TestDescriptors(l:l+numDescriptors-1,:) = object.descriptors;
        TestLabels(l:l+numDescriptors-1) = object.labels;
        l = l + numDescriptors;
        selection = ~selection;
        m = alternate(selection);
        t = t+1;
    else
        numDescriptors = size(object.descriptors,1);
        TrainDescriptors(j:j+numDescriptors-1,:) = object.descriptors;
        TrainLabels(j:j+numDescriptors-1) = object.labels;
        j = j + numDescriptors;
    end
end
fprintf('Performing PCA analysis: %s\n', situation{i});
[coeff,~,eigVal,~,~,mu] = pca(TrainDescriptors);

clear j k l m t alternate m selection TrainingDataset object
%% Load situation
i=1; % Situation number
situation = {'glasses', 'night_noglasses', 'nightglasses', 'noglasses', 'sunglasses'};

if (~exist('PCAParams'))
    PCAParams.(situation{i}) = load([rootDirectory ...
        'ProcessedData/PCATrain.mat'], situation{i});
    PCAParams.(situation{i}) = PCAParams.(situation{i}).(situation{i});
end
coeff = PCAParams.(situation{i}).coeff;
mu = PCAParams.(situation{i}).mu;
eigVal = PCAParams.(situation{i}).eigVal;

% Extract descriptors and labels from training dataset
fields = fieldnames(TrainingDataset);
j = strcmp(situation, fields{i});

TrainDescriptors = zeros(numDescriptorsTrain(j), numelDescriptor);
TrainLabels = zeros(numLabelsTrain(j), 1);

j=1;
for k=1:length(TrainingDataset.(situation{i}))
    object = TrainingDataset.(situation{i})(k);
    numDescriptors = size(object.descriptors,1);
    TrainDescriptors(j:j+numDescriptors-1,:) = object.descriptors;
    TrainLabels(j:j+numDescriptors-1) = object.labels;
    j = j + numDescriptors;
end

% Extract descriptors and labels from test dataset
situation = {'glasses', 'nightnoglasses', 'nightglasses', 'noglasses', 'sunglasses'};

% Extract descriptors and labels from training dataset
fields = fieldnames(TestDataset);
j = strcmp(situation, fields{i});

TestDescriptors = zeros(numDescriptorsTest(j), numelDescriptor);
TestLabels = zeros(numLabelsTest(j), 1);

j=1;
for k=1:length(TestDataset.(situation{i}))
    object = TestDataset.(situation{i})(k);
    numDescriptors = size(object.descriptors,1);
    TestDescriptors(j:j+numDescriptors-1,:) = object.descriptors;
    TestLabels(j:j+numDescriptors-1) = object.labels;
    j = j + numDescriptors;
end

training = (TrainDescriptors-mu) * coeff;
test = (TestDescriptors-mu) * coeff;

PCA_Ratio = 0.95;
variance = cumsum(eigVal)./sum(eigVal);
cumVariance = find(variance > PCA_Ratio);
numComponentsPCA = cumVariance(1);
training = training(:,1:numComponentsPCA);
test = test(:,1:numComponentsPCA);

clear TrainDescriptors TestDescriptors coeff mu eigVal numDescriptors numLabels

%% TRAIN SVM

[training,index_i] = ArrangeByFisherScore(training,TrainLabels);
test = test(:,index_i);
allFisherPercentage = zeros(240,1);
allrbfParameter = zeros(240,1);
kernelSVM = 'rbf';
if strcmp(kernelSVM, 'rbf')
    i=[1 1.5 2 2.5 3 4 5:5:20];
elseif strcmp(kernelSVM, 'poly')
    i = 1:10;
end
j=[1 2 3 4 5:5:100];
I = length(i);
J = length(j);

TestAccuracy = zeros(J, I);
TrainAccuracy = zeros(J, I);
Accuracy = zeros(J, I);
fisherPercentage = zeros(J, I);
rbfParameter = zeros(J, I);

for index_j = 1:J
    Learn= training(:, 1:ceil(j(index_j) * 0.01 * length(training(1, :))));
    Test= test(:, 1:ceil(j(index_j) * 0.01 * length(test(1, :))));
    
    parfor index_i = 1:I
        allFisherPercentage(index_i)= j(index_j);
        allrbfParameter(index_i) = i(index_i);
        if strcmp(kernelSVM, 'rbf')
            SVMClassifier = fitcsvm(Learn, TrainLabels, 'KernelFunction',...
                'rbf', 'KernelScale', i(index_i), 'IterationLimit', 50000);
        elseif strcmp(kernelSVM, 'poly')
            SVMClassifier = fitcsvm(Learn, TrainLabels, 'KernelFunction',...
                'Polynomial', 'PolynomialOrder', i(index_i), 'IterationLimit', 50000);
        end
        predictedLabels = SVMClassifier.predict(Test);
        predictedLabelsTrain = SVMClassifier.predict(Learn);
        
        TestAccuracy(index_j, index_i) = 100 * (sum(predictedLabels'==TestLabels)...
            / length(TestLabels));
        TrainAccuracy(index_j, index_i) = 100 * (sum(predictedLabelsTrain'==TrainLabels)...
            / length(TrainLabels));
        fisherPercentage(index_j, index_i) = j(index_j);
        rbfParameter(index_j, index_i) = i(index_i);
        fprintf('Situation: %s, i: %d, j:%d\n', situation{1}, i(index_i), j(index_j));
        fprintf('Accuracy test data: %.3f\t', TestAccuracy(index_j, index_i));
        fprintf('Accuracy train data: %.3f\n', TrainAccuracy(index_j, index_i));
    end
end
[maxAccuracy, maxIndex] = max(TestAccuracy(:));
[idxMaxRow, idxMaxCol] = ind2sub(size(TestAccuracy), maxIndex);
fisherPercentage = fisherPercentage(idxMaxRow, idxMaxCol);