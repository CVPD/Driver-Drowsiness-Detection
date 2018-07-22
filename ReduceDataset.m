function dataset_reduced = ReduceDataset(dataset, pca_struct, pca_ratio)

L = length(dataset);
for i=1:length(pca_struct)
    mu = pca_struct(i).mu;
    coeff = pca_struct(i).coeff;
    eigVal = pca_struct(i).eigVal;
    
    variance = cumsum(eigVal)./sum(eigVal);
    cumVariance = find(variance > pca_ratio);
    numComponentsPCA = cumVariance(1);
    
    descriptors = dataset(mod(i-1,L)+1).Descriptors;
    descriptors = (descriptors - mu) * coeff;
    descriptors = descriptors(:,1:numComponentsPCA);
    labels = dataset(mod(i-1,L)+1).Labels;
    
    dataset_reduced(i).situation = dataset(mod(i-1,L)+1).situation;
    dataset_reduced(i).descriptors = descriptors;
    dataset_reduced(i).labels = labels;
    
end
end