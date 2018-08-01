function pca_struct = DatasetPCA(dataset)
%pca_struct = DatasetPCA(dataset)
%   Performs PCA analysis on given dataset   
pca_struct = struct;
parfor i=1:length(dataset)
    descriptors = dataset(i).Descriptors;
    [coeff,~,eigVal,~,~,mu] = pca(descriptors);
    % Store values in PCA struct
    pca_struct(i).situation = dataset(i).situation;
    pca_struct(i).coeff = coeff;
    pca_struct(i).eigVal = eigVal;
    pca_struct(i).mu = mu;
    fprintf('Situation: %s processed - \t%s\n', dataset(i).situation, datetime('now'));    
end