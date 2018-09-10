PMLType = 'PML-HOG';
subsampling = 10;
pca_ratio = 0.85;
situation_choice = {'nightglases',0, 'sunglasses', 0};

fname_train = [pwd '/ProcessedData/' PMLType '/TrainingDataset_Sub' int2str(subsampling) '.mat'];
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationDataset_Sub1.mat'];
% dataset_train_raw = load(fname_train);
% dataset_test_raw = load(fname_test);

subject_list = [1,2,5,6,8,9,12,13,15,20,23,24,31,32,33,34,35,36];
best_accuracy = zeros(5,9);

for fold=1:length(subject_list)/2
    fprintf('Selected fold: %d \t%s\n', fold, datetime('now'));
    
    % Select subjects to be excluded
    exclusion_list = subject_list(2*fold-1:2*fold);
    
    % Load train dataset and reduce it
    dataset_train_raw = load(fname_train);    
    fprintf('Loading train dataset...\t\t%s\n', datetime('now'));
    [dataset_train, excluded_data] = BuildTrainDatasetBySubject(fname_train, 'dataset', dataset_train_raw,...
        'subject_exclusion_list', exclusion_list, 'situation_choice', situation_choice);
    clear dataset_train_raw
    pca_struct = DatasetPCA(dataset_train);
    dataset_train_reduced = ReduceDataset(dataset_train, pca_struct, pca_ratio);
    clear dataset_train 
    
    % Load test datset, add excluded subjects to it and reduce it
    dataset_test_raw = load(fname_test);
    fprintf('Loading test dataset...\t\t%s\n', datetime('now'));
    dataset_test = BuildTestDataset(fname_test, 'dataset', dataset_test_raw);
    clear datset_test_raw
    for i=1:length(dataset_test)
        dataset_test(i).descriptors = cat(1,dataset_test(i).descriptors, excluded_data(i).descriptors);
        dataset_test(i).labels = cat(1,dataset_test(i).labels, excluded_data(i).labels);
    end
    dataset_test_reduced = ReduceDatasetTest(dataset_test, pca_struct, pca_ratio);
    clear dataset_test pca_struct
    
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
        Results.situation = dataset_train_reduced(i).situation;
        Results.kernel = InfoStruct.kernel;
        Results.kernelScale = InfoStruct.kernelScale;
        Results.FisherPerc = InfoStruct.FisherPerc';
        Results.TestAccuracy = TestAccuracy;
        Results.TrainAccuracy = TrainAccuracy;
        Results.confusion_matrix = InfoStruct.confusion;
        Results.max_coordinates = InfoStruct.max_coordinates;
        
        % SVMClassifierBoxConstraint
        [best_fisher , maxIndex] = max(Results.TestAccuracy(:));
        [idxMaxRow, idxMaxCol] = ind2sub(size(Results.TestAccuracy), maxIndex);
        best_fisher_index = Results.FisherPerc(idxMaxRow);
        best_fisher_gamma = Results.kernelScale(idxMaxCol);
        kernelScale = best_fisher_gamma-1:0.1:best_fisher_gamma+1;
        FisherIndex = best_fisher_index;
        
        kernelScale = kernelScale(kernelScale>0);
        [TestAccuracyCbox, TrainAccuracyCbox, InfoStructDetail] = trainSVMClassifierBoxC(TrainData, ...
            TrainLabels, TestData, TestLabels, kernel, kernelScale, FisherIndex);
        Results.BoxConstraint = InfoStructDetail.box_constraint;
        Results.tunedKernelScale = InfoStructDetail.kernelScale;
        Results.tunedFisherPerc = InfoStructDetail.fisher_index;
        Results.tunedTestAccuracy = TestAccuracyCbox;
        
        % Store results
        [best_accuracy(i, fold), maxIndex] = max(Results.tunedTestAccuracy(:));
    end
end
save([pwd '/ProcessedData/CrossValidation/Results' PMLType '.m'], 'best_accuracy');