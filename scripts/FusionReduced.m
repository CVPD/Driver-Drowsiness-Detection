subsampling = 10;
situation_exclude = [2,4,5,6,10];

PMLType = 'PML-COV';
pca_ratio = 0.95;
fname_train = [pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA' int2str(pca_ratio*100) '_Sub' int2str(subsampling) '.mat'];
load(fname_train);
dataset_training(situation_exclude) = [];
train_data_COV = dataset_training;
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA' int2str(pca_ratio*100) '_Sub' int2str(subsampling) '.mat'];
load(fname_test);
dataset_test(situation_exclude) = [];
test_data_COV = dataset_test;

PMLType = 'PML-HOG';
pca_ratio = 0.85;
fname_train = [pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA' int2str(pca_ratio*100) '_Sub' int2str(subsampling) '.mat'];
load(fname_train);
dataset_training(situation_exclude) = [];
train_data_HOG = dataset_training;
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA' int2str(pca_ratio*100) '_Sub' int2str(subsampling) '.mat'];
load(fname_test);
dataset_test(situation_exclude) = [];
test_data_HOG = dataset_test;

PMLType = 'PML-LBP';
pca_ratio = 0.95;
fname_train = [pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA' int2str(pca_ratio*100) '_Sub' int2str(subsampling) '.mat'];
load(fname_train);
dataset_training(situation_exclude) = [];
train_data_LBP = dataset_training;
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA' int2str(pca_ratio*100) '_Sub' int2str(subsampling) '.mat'];
load(fname_test);
dataset_test(situation_exclude) = [];
test_data_LBP = dataset_test;

dataset_train = FusionDescriptors(train_data_COV, train_data_HOG, train_data_LBP);
dataset_test = FusionDescriptors(test_data_COV, test_data_HOG, test_data_LBP);
[dataset_training, norm_values] = NormL2dataset(dataset_train);
save([pwd '/ProcessedData/Fusion/TrainDataReducedByPCA' int2str(0) '_Sub' int2str(subsampling) '.mat'], 'dataset_training');

for i=1:size(norm_values,1)
    dataset_test(i).descriptors = dataset_test(i).descriptors./norm_values{i,:};
end
save([pwd '/ProcessedData/Fusion/EvaluationReducedPCA' int2str(0) '_Sub' int2str(subsampling) '.mat'], 'dataset_test');
