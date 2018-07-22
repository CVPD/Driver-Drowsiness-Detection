function comparison = CompareErrors(PML_type, PCA_ratio, subsampling)

fname_results = [pwd '/ProcessedData/' PML_type '/Results_ReducedPCA' ...
    int2str(PCA_ratio * 100) '_Sub' int2str(subsampling) '.mat'];

fname_training = [pwd '/ProcessedData/' PML_type '/TrainDataReducedByPCA' ...
    int2str(PCA_ratio * 100) '_Sub' int2str(subsampling) '.mat'];

fname_test = [pwd '/ProcessedData/' PML_type '/EvaluationReducedPCA' ...
    int2str(PCA_ratio * 100) '_Sub' int2str(subsampling) '.mat'];


% Load Results
results = load(fname_results);
results = results.Results;
best_results = BestAccuracyValues(results);

% Load Data
dataset_train = load(fname_training);
field_name = fieldnames (dataset_train);
dataset_train = dataset_train.(field_name{1});

dataset_test = load(fname_test);
field_name = fieldnames (dataset_test);
dataset_test = dataset_test.(field_name{1});

test_error = zeros(1,length(dataset_train));
CV_error = zeros(1,length(dataset_train));

for i=1:length(dataset_train)
    situation = dataset_train(i).situation;
    fprintf('Situation: %s \t %s\n',situation, datetime('now'));
    train_data = dataset_train(i).descriptors;
    train_labels = dataset_train(i).labels;
    test_data = dataset_test(i).descriptors;
    test_labels = dataset_test(i).labels;
    fisher_index = best_results(i).best_fisher_index;
    if isfield(best_results, 'best_box_constraint_gamma')
        kernel_scale = best_results(i).best_box_constraint_gamma;
    else
        kernel_scale = best_results(i).best_fisher_gamma;
    end
    if isfield(best_results, 'best_box_constraint_index')
        box_constraint = best_results(i).best_box_constraint_index;
    else
        box_constraint = 1;
    end
    [test_accuracy,train_accuracy, info] = trainSVMClassifier(train_data,train_labels,test_data,test_labels,...
        'kernelSVM', 'rbf', ...
        'kernelScale', kernel_scale,...
        'FisherIndex', fisher_index,...
        'BoxConstraint', box_constraint,...
        'verbose', false);
    test_error(i) = 1 - test_accuracy/100;
    CV_error(i) = info.CrossVal{:};
end
comparison = table(test_error', CV_error');

end