PML = {'PML-COV', 'PML-HOG', 'PML-LBP'};
pca_ratios = [0.95,0.85,0.95];
situations_PML = [1,3,6,7,9;1,3,6,7,10;2,3,5,7,10]';
SVMClassifier = cell(size(situations_PML,1),3);
predictedLabels = cell(size(situations_PML,1), length(PML));

for PML_index=1:length(PML)
    PMLType = PML{PML_index};
    subsampling = 10;
    PCA_Ratio = pca_ratios(PML_index);
    SVMClassifierPML = cell(size(situations_PML,1),1);
    situations = situations_PML(:,PML_index);
    fprintf('Selected PML: %s\n', PMLType);
    
    fname_train = [pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA'...
        int2str(PCA_Ratio*100) '_Sub' int2str(subsampling) '.mat'];
    
    fname_results = [pwd '/ProcessedData/' PMLType '/Results_ReducedPCA' ...
        int2str(PCA_Ratio*100) '_Sub' int2str(subsampling) '.mat'];
    
    fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA'...
        int2str(PCA_Ratio*100) '_Sub' int2str(subsampling) '.mat'];
    
    load(fname_train);
    load(fname_results);
    load(fname_test);
    
    best_results = BestAccuracyValues(Results);
    
    for j=1:length(situations)
        situation_index = situations(j);
        fprintf('Selected situation: %s\n', dataset_training(situation_index).situation);
        TrainData = dataset_training(situation_index).descriptors;
        TrainLabels = dataset_training(situation_index).labels;
        TestData = dataset_test(situation_index).descriptors;
        TestLabels = dataset_test(situation_index).labels;
        fisher_index = best_results(situation_index).best_fisher_index;
        
        kernel_scale = best_results(situation_index).best_box_constraint_gamma;
        box_constraint = best_results(situation_index).best_box_constraint_index;
        
        [TrainData,index_i] = ArrangeByFisherScore(TrainData,TrainLabels);
        TestData = TestData(:,index_i);
        train_length = size(TrainData, 2);
        test_length = size(TestData, 2);
        
        TestData = TestData(:, 1:ceil(0.01 * fisher_index * test_length));
            
        TrainData= TrainData(:, 1:ceil(0.01 * fisher_index * train_length));
        
        SVMClassifierPML{j} = fitcsvm(TrainData, TrainLabels, 'KernelFunction',...
            'rbf', 'KernelScale', kernel_scale, 'IterationLimit', 50000, ...
            'BoxConstraint', box_constraint);
        predictedLabels{j, PML_index} = SVMClassifierPML{j}.predict(TestData);        
    end
    SVMClassifier(:,PML_index) = SVMClassifierPML;
end


% for situation_order=1:size(situations_PML,1)
%     
%     fprintf('Selected situation: %d\n', situation_order);
%     for PML_index=1:length(PML)
%         situation_index = situations_PML(situation_order, PML_index);
%         PMLType = PML{PML_index};
%         subsampling = 10;
%         PCA_Ratio = pca_ratios(PML_index);
%         fprintf('Selected PML: %s\n', PMLType);
%         fname_train = [pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA'...
%             int2str(PCA_Ratio*100) '_Sub' int2str(subsampling) '.mat'];
%         
%         fname_results = [pwd '/ProcessedData/' PMLType '/Results_ReducedPCA' ...
%             int2str(PCA_Ratio*100) '_Sub' int2str(subsampling) '.mat'];
%         
%         fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA'...
%             int2str(PCA_Ratio*100) '_Sub' int2str(subsampling) '.mat'];
%         
%         load(fname_results);
%         load(fname_train);
%         load(fname_test);
%         
%         TrainData = dataset_training(situation_index).descriptors;
%         TrainLabels = dataset_training(situation_index).labels;
%         TestData = dataset_test(situation_index).descriptors;
%         TestLabels = dataset_test(situation_index).labels;
%         [TrainData,index_i] = ArrangeByFisherScore(TrainData,TrainLabels);
%         TestData = TestData(:,index_i);
%         
%         best_results = BestAccuracyValues(Results);
%         fisher_index = best_results(situation_index).best_fisher_index;
%         test_length = size(TestData, 2);
%         
%         TestData = TestData(:, 1:ceil(0.01 * fisher_index * test_length));
%         
%         predictedLabels{situation_order, PML_index} = SVMClassifier{situation_order,PML_index}.predict(TestData);
%     end
% end

fusion_classifier = cell(5,1);
% w = [1.01679 1.07459 0.90862;
%     0.97906	1.04386	0.97708;
%     0.92281	1.01593	1.06126;
%     0.98868	1.03975	0.97157;
%     0.97042	1.02958	1.00000];
weight = ones(5,3);
for i=1:size(predictedLabels,1)
    for j=1:size(predictedLabels,2)
        if isempty(fusion_classifier{i})
            fusion_classifier{i} = predictedLabels{i,j} * weight(i,j);
        else
            fusion_classifier{i} = fusion_classifier{i} + predictedLabels{i,j}*weight(i,j);
        end
    end
    fusion_classifier{i} = round(fusion_classifier{i}/3);
end

TestAccuracy = zeros(5,1);
for situation_order=1:size(situations_PML,1)
    
    fprintf('Selected situation: %d\n', situation_order);
    for PML_index=1:length(PML)
        situation_index = situations_PML(situation_order, PML_index);
        PMLType = PML{PML_index};
        subsampling = 10;
        PCA_Ratio = pca_ratios(PML_index);
        fprintf('Selected PML: %s\n', PMLType);

        fname_test = [pwd '/ProcessedData/' PMLType '/EvaluationReducedPCA'...
            int2str(PCA_Ratio*100) '_Sub' int2str(subsampling) '.mat'];
        

        load(fname_test);

        TestLabels = dataset_test(situation_index).labels;
        
        TestAccuracy(situation_order) = 100 * (sum(fusion_classifier{situation_order}==TestLabels)...
            / length(TestLabels));
    end
end
