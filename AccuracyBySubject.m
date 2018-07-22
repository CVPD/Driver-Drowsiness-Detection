PML_Type = 'PML-COV';
PCA_ratio = 0.95;
subsampling = 10;

fname_results = [pwd '/ProcessedData/' PML_Type '/Results_ReducedPCA' ...
    int2str(PCA_ratio * 100) '_Sub' int2str(subsampling) '.mat'];

fname_training = [pwd '/ProcessedData/' PML_Type '/TrainDataReducedByPCA' ...
    int2str(PCA_ratio * 100) '_Sub' int2str(subsampling) '.mat'];

fname_test = [pwd '/ProcessedData/' PML_Type '/EvaluationDataset_Sub1.mat'];

fname_pca = [pwd '/ProcessedData/' PML_Type '/PCA' int2str(PCA_ratio*100) ...
    'Train_DupData_Sub' int2str(subsampling) '.mat'];

fname_test_reduced = [pwd '/ProcessedData/' PML_Type '/EvaluationReducedPCA' ...
    int2str(PCA_ratio * 100) '_Sub' int2str(subsampling) '.mat'];


% Load Results
results = load(fname_results);
results = results.Results;
best_results = BestAccuracyValues(results);

% Load Data
data_test_subject = BuildTestDatasetBySubject(fname_test);
% load(fname_pca);
dataset_train = load(fname_training);
field_name = fieldnames (dataset_train);
dataset_train = dataset_train.(field_name{1});

dataset_test = load(fname_test_reduced);
field_name = fieldnames (dataset_test);
dataset_test = dataset_test.(field_name{1});

for i=1:length(data_test_subject)
    for j=1:length(data_test_subject(i).data)
        numFrames(j,i) = size(data_test_subject(i).data(j).Descriptors,1);
    end
end
sum(numFrames,2)

subject_frame_index = zeros(5,4);
for situation=1:size(numFrames,1)
    for subject=1:size(numFrames,2)
        if subject==1
            subject_frame_index(situation, subject) = 1;
        else
            subject_frame_index(situation, subject) = subject_frame_index(situation, subject-1) + numFrames(situation, subject-1);
        end
    end
end
subject_frame_index
for i=1:size(numFrames,1)
    subject_frame_index(i,5)=  sum(numFrames(i,:));
end

% for i=1:length(data_test_subject)
%     data_test_reduced(i).subject = data_test_subject(i).subject;
%     data_test_reduced(i).data = ReduceDatasetTest(data_test_subject(i).data, pca_training, PCA_ratio);
% end

test_accuracy = zeros(4, 10);
info = cell(4,10);
for i=1:size(numFrames,2)
    parfor j=1:length(dataset_train)
        situation = dataset_train(j).situation;
        fprintf('Situation: %s \t %s\n',situation, datetime('now'));
        train_data = dataset_train(j).descriptors;
        train_labels = dataset_train(j).labels;
        test_data = dataset_test(j).descriptors;
        test_labels = dataset_test(j).labels;
        subject_index = i;
        frames_index = [subject_frame_index(ceil(j/2),subject_index): subject_frame_index(ceil(j/2),subject_index+1)];
        test_data = test_data(frames_index,:);
        test_labels = dataset_test(j).labels;
        test_labels = test_labels(frames_index);
        
        fisher_index = best_results(j).best_fisher_index;
        if isfield(best_results, 'best_box_constraint_gamma')
            kernel_scale = best_results(j).best_box_constraint_gamma;
        else
            kernel_scale = best_results(j).best_fisher_gamma;
        end
        if isfield(best_results, 'best_box_constraint_index')
            box_constraint = best_results(j).best_box_constraint_index;
        else
            box_constraint = 1;
        end
        [test_accuracy(i,j),train_accuracy, info{i,j}] = trainSVMClassifier(train_data,train_labels,test_data,test_labels,...
            'kernelSVM', 'rbf', ...
            'kernelScale', kernel_scale,...
            'FisherIndex', fisher_index,...
            'BoxConstraint', box_constraint,...
            'verbose', false);
    end
end

for i=1:size(info,1)
    for j=1:size(info,2)
        conf_struct = info{i,j}.confusion;
        conf_cell{i,j} = conf_struct.confusion_matrix{:};
    end
end


for j=1:size(conf_cell,2)
    TPTF = 0;
    total = 0;
    for i=1:size(conf_cell,1)
        conf_mat = conf_cell{i,j};
        TPTF =  TPTF +conf_mat(1,1)+conf_mat(2,2);
        total = total + sum(sum(conf_mat));
    end
    overall(j,1) = TPTF;
    overall(j,2) = total;
    overall(j,3) = TPTF/total;
end
        