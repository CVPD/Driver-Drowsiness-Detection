%% Example parameters
PMLType = 'PML-COV';
subsampling_train = 10;
subsampling_test = 1;
pca_ratio = 0.95;

%% Create and reduce datasets
PreprocessDataset(subsampling_train, subsampling_test, PMLType);
fname_training = [pwd '/ProcessedData/' PMLType '/TrainingDataset_Sub' int2str(subsampling_train) ',.mat'];
dataset = BuildTrainDataset(fname_training);
pca_struct = DatasetPCA(dataset);
dataset_training = ReduceDataset(dataset, pca_struct, pca_ratio);

fname_test = [pwd '/ProcessedData/' PMLType '/Evaluation_Sub' int2str(subsampling_test) ',.mat'];
dataset = BuildTestDataset(fname_test);
dataset_test = ReduceDataset(dataset, pca_struct, pca_ratio);

% Reduced datataset file names must follow these structures
save([pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA' int2str(pca_ratio*100) '_Sub' int2str(subsampling_train) '.mat']);
save([pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA' int2str(pca_ratio*100) '_Sub' int2str(subsampling_train) '.mat']);

%% Train a classifier
results = TrainReducedDataset(PMLType, pca_ratio, subsampling_train);

