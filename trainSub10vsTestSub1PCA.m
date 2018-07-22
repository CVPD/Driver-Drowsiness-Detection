if ~exist('subsampling')
    error('Missing hyperparameter: subsampling')
elseif ~exist('PCA_Ratio')
    error('Missing hyperparameter: PCA_Ratio')
elseif ~exist('PMLType')
    error('Missing hyperparameter: PMLType')
elseif ~exist('kernel')
    error('Missing hyperparameter: kernel')    
end
fprintf('---- Start trainSub10vsTestSub1PCA%s%d \t%s ----\n',PMLType, PCA_Ratio*100, datetime('now'));

% Load results file in case it exists
fname_results = [pwd '/ProcessedData/' PMLType '/Results_ReducedPCA' int2str(PCA_Ratio*100) ...
        kernel '_Sub' int2str(subsampling) '.mat'];
if exist(fname_results, 'file') == 2
    load(fname_results);
end
results_analysis = BestAccuracyValues(Results);

% Training Dataset
fprintf('Loading training dataset...\t%s\n', datetime('now'));
fname_training = [pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA' int2str(PCA_Ratio*100)...
    '_Sub' int2str(subsampling) '.mat'];
load(fname_training);
fprintf('Training dataset loaded \t%s\n', datetime('now'));

% Test Dataset
fprintf('Loading test dataset...\t\t%s\n', datetime('now'));
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA' int2str(PCA_Ratio*100)...
    '_Sub' int2str(subsampling) '.mat'];
load(fname_test);
fprintf('Test dataset loaded \t\t%s\n', datetime('now'));
for i=1:length(dataset_training)
    fprintf('Selected situation: %s\n', dataset_training(i).situation);
    
    TrainData = dataset_training(i).descriptors;
    TrainLabels = dataset_training(i).labels;
    TestData = dataset_test(i).descriptors;
    TestLabels = dataset_test(i).labels;
    % SVMClassifier
%     kernelScale = [0.5:0.5:12 13:2:50];
%     FisherIndex = [1:9 10:10:100];
%     [TestAccuracy, TrainAccuracy, InfoStruct] = trainSVMClassifier(TrainData, ...
%         TrainLabels, TestData, TestLabels, 'kernelSVM', 'rbf', ...
%         'kernelScale', kernelScale,'BoxConstraint', 1, 'FisherIndex',FisherIndex);
%     Results(i).situation = dataset_training(i).situation;
%     Results(i).kernel = InfoStruct.kernel;
%     Results(i).kernelScale = InfoStruct.kernelScale;
%     Results(i).FisherPerc = InfoStruct.FisherPerc';
%     Results(i).TestAccuracy = TestAccuracy;
%     Results(i).TrainAccuracy = TrainAccuracy;
%     Results(i).confusion_matrix = InfoStruct.confusion;
%     Results(i).max_coordinates = InfoStruct.max_coordinates;
    
    % SVMClassifierBoxConstraint
    %     fisher_index = [5, 9, 9, 3, 20, 20, 6, 2, 100, 20];
    %     kernelScale = {12:0.1:14, ...     % glasses_complete
    %         16.5:0.1:17.5, ...    % glasses_incomplete
    %         32:0.1:34, ...   % night_noglasses_complete
    %         48:0.1:50, ...      % night_noglasses_incomplete
    %         3.5:0.1:4.5, ...      % night_glasses_complete
    %         1.8:0.1:2.2, ...      % night_glasses_incomplete
    %         2.5:0.1:3, ....		% noglasses_complete
    %         3:0.1:4, ...		% noglasses_incomplete
    %         4.5:0.1:5.5, ...	% sunglasses_complete
    %         5:0.1:6};		% sunglasses_incomplete
    %     kernelScale = kernelScale{i};
    %     FisherIndex = fisher_index(i);
    kernelScale = results_analysis(i).best_fisher_gamma-1:0.1:results_analysis(i).best_fisher_gamma+1;
    FisherIndex = results_analysis(i).best_fisher_index;
    [TestAccuracyCbox, TrainAccuracyCbox, InfoStructDetail] = trainSVMClassifierBoxC(TrainData, ...
        TrainLabels, TestData, TestLabels, 'kernel', kernelScale, FisherIndex);
    Results(i).BoxConstraint = InfoStructDetail.box_constraint;
    Results(i).tunedKernelScale = InfoStructDetail.kernelScale;
    Results(i).tunedFisherPerc = InfoStructDetail.fisher_index;
    Results(i).tunedTestAccuracy = TestAccuracyCbox;
    
end
clear fnameTest fnameTraining

fprintf('Saving results \t%s ----\n', datetime('now'));

save([pwd '/ProcessedData/' PMLType '/Results_ReducedPCA' int2str(PCA_Ratio*100)...
    kernel '_Sub' int2str(subsampling) '.mat'], 'Results');

fprintf('----End trainSub10vsTestSub1PCA \t%s ----\n', datetime('now'));


