function [TestAccuracy, TrainAccuracy, InfoStruct] = trainSVMClassifier(...
    descriptors_train, labels_train, descriptors_test, labels_test, varargin)

default_kernel_scale = 0.5:0.5:12;
default_box_constraint = 1;
default_fisher_index = [1:1:5 7 9 10:10:100];
default_kernel = 'rbf';

p = inputParser;
addRequired(p, 'descriptors_train', @ismatrix);
addRequired(p, 'labels_train', @isvector);
addRequired(p, 'descriptors_test', @ismatrix);
addRequired(p, 'labels_test', @isvector);
addParameter(p, 'kernelSVM', default_kernel, @ischar);
addParameter(p, 'kernelScale', default_kernel_scale, @isvector);
addParameter(p, 'BoxConstraint', default_box_constraint, @isscalar);
addParameter(p, 'FisherIndex', default_fisher_index);
addParameter(p,'verbose', true, @islogical);

parse(p,descriptors_train,labels_train,descriptors_test,labels_test,varargin{:});

kernelSVM = p.Results.kernelSVM;
kernelScale = p.Results.kernelScale;
box_constraint = p.Results.BoxConstraint;
fisher_index = p.Results.FisherIndex;
verbose = p.Results.verbose;

% Fisher score percentage
if fisher_index == -1  % fisher_index = -1: No Fisher sorting
    training = descriptors_train;
    test = descriptors_test;
    fisher_index = 1:10:100;
else                   % fisher_index = Fisher sorting
    [training,index_i] = ArrangeByFisherScore(descriptors_train,labels_train);
    test = descriptors_test(:,index_i);
end

K = length(kernelScale);
F = length(fisher_index);
TestAccuracy = zeros(F, K);
TrainAccuracy = zeros(F, K);

train_length = size(training, 2);
test_length = size(test, 2);
InfoStruct = struct;

if verbose
    disp(['Start: ' datestr(datetime('now'))]);
end

C_cell = cell(F, K);        % Confusion matrix
order_cell = cell(F, K);    % Confusion matrix
SVMModels = cell(F,K);
for index_j = 1:F
    Learn= training(:, 1:ceil(0.01 * fisher_index(index_j) * train_length));
    Test= test(:, 1:ceil(0.01 * fisher_index(index_j) * test_length));
    for index_i = 1:K
        if strcmp(kernelSVM, 'rbf')
            SVMClassifier = fitcsvm(Learn, labels_train, 'KernelFunction',...
                'rbf', 'KernelScale', kernelScale(index_i), 'IterationLimit', 50000, ...
                'BoxConstraint', box_constraint);
        elseif strcmp(kernelSVM, 'poly')
            SVMClassifier = fitcsvm(Learn, labels_train, 'KernelFunction',...
                'Polynomial', 'PolynomialOrder', i(index_i), 'IterationLimit', ...
                50000, 'BoxConstraint', box_constraint);
        end
        CVSVMModel = crossval(SVMClassifier);
        classLoss = kfoldLoss(CVSVMModel);
        SVMModels{index_j, index_i} = SVMClassifier;
        CrossVal{index_j, index_i} = classLoss;
        predictedLabels = SVMClassifier.predict(Test);
        predictedLabelsTrain = SVMClassifier.predict(Learn);
        TestAccuracy(index_j, index_i) = 100 * (sum(predictedLabels==labels_test)...
            / length(labels_test));
        TrainAccuracy(index_j, index_i) = 100 * (sum(predictedLabelsTrain==labels_train)...
            / length(labels_train));
        [C_cell{index_j,index_i},order_cell{index_j,index_i}] = confusionmat(labels_test, predictedLabels);
    end
end
[maxAccuracy, maxIndex] = max(TestAccuracy(:));
[idxMaxRow, idxMaxCol] = ind2sub(size(TestAccuracy), maxIndex);

InfoStruct.kernel = kernelSVM;
InfoStruct.kernelScale = kernelScale;
InfoStruct.FisherPerc = fisher_index;
InfoStruct.confusion.confusion_matrix = C_cell;
InfoStruct.confusion.order = order_cell;
InfoStruct.max_coordinates = [fisher_index(idxMaxRow), kernelScale(idxMaxCol)];
InfoStruct.SVMModels = SVMModels;
InfoStruct.CrossVal = CrossVal;
if verbose
    disp(['Max Accuracy: ' num2str(maxAccuracy)]);
    disp(['End: ' datestr(datetime('now'))]);
end
end