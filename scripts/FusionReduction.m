subsampling = 10;

PMLType = 'PML-COV';
fname_train = [pwd '/ProcessedData/' PMLType '/TrainingDataset_Sub' int2str(subsampling) '.mat'];
dataset_train = load(fname_train);
situation_choice = {'nightglasses', 0};
train_data_COV = BuildTrainDatasetBySubject(fname_train, 'dataset', dataset_train, 'situation_choice', situation_choice);
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationDataset_Sub1.mat']; 
dataset_test = load(fname_test);
test_data_COV = BuildTestDataset(fname_test, 'dataset', dataset_test);

PMLType = 'PML-HOG';
fname_train = [pwd '/ProcessedData/' PMLType '/TrainingDataset_Sub' int2str(subsampling) '.mat'];
dataset_train = load(fname_train);
situation_choice = {'nightglasses', 0};
train_data_HOG = BuildTrainDatasetBySubject(fname_train, 'dataset', dataset_train, 'situation_choice', situation_choice);
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationDataset_Sub1.mat']; 
dataset_test = load(fname_test);
test_data_HOG = BuildTestDataset(fname_test, 'dataset', dataset_test);

PMLType = 'PML-LBP';
fname_train = [pwd '/ProcessedData/' PMLType '/TrainingDataset_Sub' int2str(subsampling) '.mat'];
dataset_train = load(fname_train);
situation_choice = {'nightglasses', 0};
train_data_LBP = BuildTrainDatasetBySubject(fname_train, 'dataset', dataset_train, 'situation_choice', situation_choice);
fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationDataset_Sub1.mat']; 
dataset_test = load(fname_test);
test_data_LBP = BuildTestDataset(fname_test, 'dataset', dataset_test);

dataset_train = FusionDescriptors(train_data_COV, train_data_HOG, train_data_LBP);
dataset_test = FusionDescriptors(test_data_COV, test_data_HOG, test_data_LBP);
[dataset_train, norm_values] = NormL2dataset(dataset_train);
pca_ratio = 0.85;
[dataset_train_reduced, pca_struct] = ReduceTrainDatasetPCA(dataset_train, pca_ratio);
for i=1:size(norm_values,1)
    dataset_test(i).descriptors = dataset_test(i).descriptors./norm_values(i,:);
end
dataset_test_reduced = ReduceDatasetTest(dataset_test, pca_struct, pca_ratio);
save([pwd '/ProcessedData/Fusion/EvaluationReducedPCA' int2str(pca_ratio*100) ...
    '_Sub' int2str(subsampling) '.mat'], 'dataset_test_reduced', '-v7.3');

save([pwd '/ProcessedData/Fusion/TrainingDataset'...
    '_Sub' int2str(subsampling) '.mat'], 'dataset_train', '-v7.3');
save([pwd '/ProcessedData/Fusion/TrainDataReducedByPCA' int2str(pca_ratio*100)...
    '_Sub' int2str(subsampling) '.mat'], 'dataset_train_reduced');
save([pwd '/ProcessedData/Fusion/PCA' int2str(pca_ratio*100) ...
    'Train_DupData_Sub' int2str(subsampling) '.mat'], 'pca_struct', '-v7.3');
save([pwd '/ProcessedData/Fusion/EvaluationDataset_Sub1.mat'], 'dataset_test', '-v7.3');
