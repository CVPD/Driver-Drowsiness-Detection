PMLType = 'PML-COV';
subsampling = 10;
pca_ratio = 0.95;
situation_choice = {'nightglases',0};

fname_train = [pwd '/ProcessedData/' PMLType '/TrainingDataset_Sub' int2str(subsampling) '.mat'];
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationDataset_Sub1.mat'];
% dataset_train_raw = load(fname_train);
% dataset_test_raw = load(fname_test);

subject_list = [4,22,26,30];
best_accuracy = zeros(5,4);

% Load train dataset and reduce it
dataset_train_raw = load(fname_train);
fprintf('Loading train dataset...\t\t%s\n', datetime('now'));
[dataset_train] = BuildTrainDataset(fname_train, 'dataset', dataset_train_raw,...
    'situation_choice', situation_choice);
clear dataset_train_raw
pca_struct = DatasetPCA(dataset_train);
dataset_train_reduced = ReduceDataset(dataset_train, pca_struct, pca_ratio);
clear dataset_train

% Load test dataset
dataset_test_raw = load(fname_test);
for fold=1:length(subject_list)
    fprintf('Selected fold: %d \t%s\n', fold, datetime('now'));
    
    % Select subjects to be excluded
    exclusion_list = subject_list(fold);
        
    % Load test dataset, add excluded subjects to it and reduce it
    fprintf('Loading test dataset...\t\t%s\n', datetime('now'));
    [dataset_test, exlcuded_test] = BuildTestDataset(fname_test, 'dataset', dataset_test_raw, ...
        'subject_exclusion_list', exclusion_list);
    clear datset_test_raw
    dataset_test_reduced = ReduceDatasetTest(dataset_test, pca_struct, pca_ratio);
    excluded_test_reduced = ReduceDatasetTest(exlcuded_test, pca_struct, pca_ratio);
    clear dataset_test
    
    % Find best classifier for current tain dataset
    Results = struct;
    for i=1:length(dataset_train_reduced)
        fprintf('Selected situation: %s\n', dataset_train_reduced(i).situation);
        
        TrainData = dataset_train_reduced(i).descriptors;
        TrainLabels = dataset_train_reduced(i).labels;
        TestData = dataset_test_reduced(i).descriptors;
        TestLabels = dataset_test_reduced(i).labels;
        
        % SVMClassifier
        kernel = 'rbf';
        kernelScale = [0.5:0.5:12 13:2:50];
        FisherIndex = [1:9 10:10:100];
        [TestAccuracy, TrainAccuracy, InfoStruct] = trainSVMClassifier(TrainData, ...
            TrainLabels, TestData, TestLabels, 'kernelSVM', kernel, ...
            'kernelScale', kernelScale,'BoxConstraint', 1, 'FisherIndex',FisherIndex);
        Results(i).situation = dataset_train_reduced(i).situation;
        Results(i).kernel = InfoStruct.kernel;
        Results(i).kernelScale = InfoStruct.kernelScale;
        Results(i).FisherPerc = InfoStruct.FisherPerc';
        Results(i).TestAccuracy = TestAccuracy;
        Results(i).TrainAccuracy = TrainAccuracy;
        Results(i).confusion_matrix = InfoStruct.confusion;
        Results(i).max_coordinates = InfoStruct.max_coordinates;
        
        % SVMClassifierBoxConstraint
        [best_fisher , maxIndex] = max(Results(i).TestAccuracy(:));
        [idxMaxRow, idxMaxCol] = ind2sub(size(Results(i).TestAccuracy), maxIndex);
        best_fisher_index = Results(i).FisherPerc(idxMaxRow);
        best_fisher_gamma = Results(i).kernelScale(idxMaxCol);
        kernelScale = best_fisher_gamma-1:0.1:best_fisher_gamma+1;
        FisherIndex = best_fisher_index;
        
        kernelScale = kernelScale(kernelScale>0);
        [TestAccuracyCbox, TrainAccuracyCbox, InfoStructDetail] = trainSVMClassifierBoxC(TrainData, ...
            TrainLabels, TestData, TestLabels, kernel, kernelScale, FisherIndex);
        Results(i).BoxConstraint = InfoStructDetail.box_constraint;
        Results(i).tunedKernelScale = InfoStructDetail.kernelScale;
        Results(i).tunedFisherPerc = InfoStructDetail.fisher_index;
        Results(i).tunedTestAccuracy = TestAccuracyCbox;
        Results(i).SVMModels = InfoStructDetail.SVMModels;
        
        % Store results
        [~, maxIndex] = max(Results(i).tunedTestAccuracy(:));
        [idxMaxRow, idxMaxCol] = ind2sub(size(Results(i).tunedTestAccuracy), maxIndex);
        box_constraint = Results(i).BoxConstraint(idxMaxRow);
        gamma = Results(i).tunedKernelScale(idxMaxCol);
        SVMmodel = Results(i).SVMModels{idxMaxRow, idxMaxCol};
        
        [~, maxIndex] = max(Results(i).TestAccuracy(:));
        [idxMaxRow, idxMaxCol] = ind2sub(size(Results(i).TestAccuracy), maxIndex);
        fisher_index = Results(i).FisherPerc(idxMaxRow);
        
        [TrainData,index_i] = ArrangeByFisherScore(TrainData,TrainLabels);
        excluded_test_reduced_data = excluded_test_reduced(i).descriptors(:,index_i);
        train_length = size(TrainData,2);
        excluded_data = excluded_test_reduced_data(:, 1:ceil(0.01 * fisher_index * train_length));
        
        predictedLabels = SVMmodel.predict(excluded_data);
        best_accuracy(i,fold) = 100 * (sum(predictedLabels==excluded_test_reduced(i).labels)...
            / length(excluded_test_reduced(i).labels));
        fprintf('Accuracy subject %d: %s%%\n', exclusion_list,int2str(best_accuracy(i,fold)));
    end
end
save([pwd '/ProcessedData/CrossValidation/Results' PMLType '2.mat'], 'best_accuracy');