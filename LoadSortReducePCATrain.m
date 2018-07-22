
fprintf('---- Start LoadSortReducePCATrain \t%s ----\n', datetime('now'));

if ~exist('subsampling')
    error('Missing hyperparameter: subsampling')
elseif ~exist('PCA_Ratio')
    error('Missing hyperparameter: PCA_Ratio')
end
fname_training = [pwd '/ProcessedData/' PMLType '/TrainingDataset_Sub' int2str(subsampling) '.mat'];
training_data_struct = OrderByFileType(fname_training);
fprintf('Dataset sorted\n');
% Returns structure with fields: situation,Descriptors,Labels, FileIndices

fprintf('Start dataset reduction - \t%s\n', datetime('now'));
data_index = repelem(1:length(training_data_struct),2);
parfor i=1:2*length(training_data_struct)
    
    % COMPLETE DATASET
    if logical(mod(i,2)) %Odd values
        descriptors = training_data_struct(data_index(i)).Descriptors(:,2:end);
        labels = training_data_struct(data_index(i)).Labels(:,2);

        [coeff,~,eigVal,~,~,mu] = pca(descriptors);
        descriptors = (descriptors-mu) * coeff;    
        variance = cumsum(eigVal)./sum(eigVal);
        cumVariance = find(variance > PCA_Ratio);
        numComponentsPCA = cumVariance(1);
        descriptors = descriptors(:,1:numComponentsPCA);

        % Store descriptors and labels
        situation = [training_data_struct(data_index(i)).situation '_complete'];
        dataset_training(i).situation = situation;
        dataset_training(i).descriptors = descriptors;
        dataset_training(i).labels = labels;
        % Store values in PCA struct
        pca_training(i).situation = situation;
        pca_training(i).coeff = coeff;
        pca_training(i).eigVal = eigVal;
        pca_training(i).mu = mu;
    end

    % INCOMPLETE DATASET
    if ~mod(i,2) % Even values
        descriptors = training_data_struct(data_index(i)).Descriptors;
        descriptors = descriptors(descriptors(:,1)==0,2:end);
        labels = training_data_struct(data_index(i)).Labels;
        labels = labels(labels(:,1)==0,2);
        
        [coeff,~,eigVal,~,~,mu] = pca(descriptors);
        descriptors = (descriptors-mu) * coeff;   
        variance = cumsum(eigVal)./sum(eigVal);
        cumVariance = find(variance > PCA_Ratio);
        numComponentsPCA = cumVariance(1);
        descriptors = descriptors(:,1:numComponentsPCA);
        
        % Store descriptors and labels
        situation = [training_data_struct(data_index(i)).situation '_incomplete'];
        dataset_training(i).situation = situation;
        dataset_training(i).descriptors = descriptors;
        dataset_training(i).labels = labels;   
        % Store values in PCA struct
        pca_training(i).situation = situation;
        pca_training(i).coeff = coeff;
        pca_training(i).eigVal = eigVal;
        pca_training(i).mu = mu;
    end
    fprintf('Situation: %s processed - \t%s\n', situation, datetime('now'));
end

fprintf(' Saving data \t%s \n', datetime('now'));

save([pwd '/ProcessedData/' PMLType '/TrainDataReducedByPCA' int2str(PCA_Ratio*100)...
    '_Sub' int2str(subsampling) '.mat'], 'dataset_training');
save([pwd '/ProcessedData/' PMLType '/PCA' int2str(PCA_Ratio*100) ...
    'Train_DupData_Sub' int2str(subsampling) '.mat'], 'pca_training', '-v7.3');

fprintf('---- End LoadSortReducePCATrain \t%s ----\n', datetime('now'));

clear pca_training dataset_training variance cumVariance numComponentsPCA
clear descriptors labels coeff eigVal mu training_data_struct fname_training data_index