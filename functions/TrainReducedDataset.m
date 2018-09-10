function results = TrainReducedDataset(PMLType, pca_ratio, subsampling, varargin)
% Func

default_kernel_scale = 0.5:0.5:12;
box_constraint_boundaries = [-3,3];
default_fisher_index = [1:1:9 10:10:100];
default_kernel = 'rbf';

p = inputParser;
addRequired(p, 'PMLType', @ischar);
addRequired(p, 'PCA_Ratio', @isnumeric);
addRequired(p, 'subsampling', @isnumeric);
addParameter(p, 'kernel', default_kernel, @ischar);
addParameter(p, 'kernelScale', default_kernel_scale, @isvector);
addParameter(p, 'box_constraint_boundaries', box_constraint_boundaries, @isvector);
addParameter(p, 'FisherIndex', default_fisher_index);
addParameter(p,'verbose', true, @islogical);

parse(p,PMLType,pca_ratio,subsampling,varargin{:});

kernel = p.Results.kernel;
kernelScale = p.Results.kernelScale;
box_constraint_boundaries = p.Results.box_constraint_boundaries;
fisher_index = p.Results.FisherIndex;
verbose = p.Results.verbose;


fprintf('---- Start TrainReducedDataset \t%s ----\n', datetime('now'));

% Training Dataset
fprintf('Loading training dataset...\t%s\n', datetime('now'));
fname_training = [pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA' int2str(pca_ratio*100)...
    '_Sub' int2str(subsampling) '.mat'];
load(fname_training);
fprintf('Training dataset loaded \t%s\n', datetime('now'));

% Test Dataset
fprintf('Loading test dataset...\t\t%s\n', datetime('now'));
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA' int2str(pca_ratio*100)...
    '_Sub' int2str(subsampling) '.mat'];
load(fname_test);
fprintf('Test dataset loaded \t\t%s\n', datetime('now'));
results = struct;

for i=1:length(dataset_training)
    fprintf('Selected situation: %s\n', dataset_training(i).situation);
    
    train_data = dataset_training(i).descriptors;
    train_labels = dataset_training(i).labels;
    test_data = dataset_test(i).descriptors;
    test_labels = dataset_test(i).labels;
    
    % SVMClassifier
    [test_accuracy, train_accuracy, info_struct] = trainSVMClassifier(train_data, ...
        train_labels, test_data, test_labels, 'kernelSVM', kernel, ...
        'kernelScale', kernelScale,'BoxConstraint', 1, 'FisherIndex',fisher_index);
    
    results(i).situation = dataset_training(i).situation;
    results(i).kernel = info_struct.kernel;
    results(i).kernelScale = info_struct.kernelScale;
    results(i).FisherPerc = info_struct.FisherPerc';
    results(i).TestAccuracy = test_accuracy;
    results(i).TrainAccuracy = train_accuracy;
    results(i).confusion_matrix = info_struct.confusion;
    results(i).max_coordinates = info_struct.max_coordinates;
    
    % SVMClassifierBoxConstraint
    [~ , maxIndex] = max(results(i).TestAccuracy(:));
    [idxMaxRow, idxMaxCol] = ind2sub(size(results(i).TestAccuracy), maxIndex);
    best_fisher_index = results(i).FisherPerc(idxMaxRow);
    best_fisher_gamma = results(i).kernelScale(idxMaxCol);
    kernelScale = best_fisher_gamma-1:0.1:best_fisher_gamma+1;
    kernelScale = kernelScale(kernelScale>0); % Ensure kernelScale is positive
    FisherIndex = best_fisher_index;
        
    [test_accuracy_C, ~, InfoStructDetail] = trainSVMClassifierBoxC(train_data, ...
        train_labels, test_data, test_labels, kernel, kernelScale, FisherIndex, ...
        'box_constraint_boundaries', box_constraint_boundaries);
    results(i).BoxConstraint = InfoStructDetail.box_constraint;
    results(i).tunedKernelScale = InfoStructDetail.kernelScale;
    results(i).tunedFisherPerc = InfoStructDetail.fisher_index;
    results(i).tunedTestAccuracy = test_accuracy_C;
    
end

fprintf('Saving results \t%s ----\n', datetime('now'));
save([pwd '/ProcessedData/' PMLType '/Results_ReducedPCA' int2str(pca_ratio*100)...
    kernel '_Sub' int2str(subsampling) '.mat'], 'results');

fprintf('----End trainSub10vsTestSub1PCA \t%s ----\n', datetime('now'));

end