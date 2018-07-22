%% Preprocess Data
PMLType = 'PML-LBP';
decimateValueTrain = 10;
decimateValueTest = 1;
PreprocessData;

%% PCA
PMLType = 'PML-LBP';
subsampling = 10;
PCA_Ratio = 0.95;
LoadSortReducePCATrain;
ReduceTestPCA;
trainSub10vsTestSub1PCA;

%% Fisher
subsampling = 10;
fisher_max_perc = 10;
LoadSortReduceFisherTrain;
ReduceTestFisher;
trainSub10vsTestSub1Fisher;