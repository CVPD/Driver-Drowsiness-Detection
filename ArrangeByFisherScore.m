%%%obnly for binary
function [arrangedFeatureMatrix,index]=ArrangeByFisherScore(descriptors,labels)

mu=mean(descriptors);
indexOf0Label=find(labels==0);
indexOf1Label=find(labels==1);
n0=length(indexOf0Label);
n1=length(indexOf1Label);
mu0=mean(descriptors(indexOf0Label,:));
mu1=mean(descriptors(indexOf1Label,:));
sigma0=std(descriptors(indexOf0Label,:));
sigma1=std(descriptors(indexOf1Label,:));
featureScores=(n0*(mu0-mu).^2+n1*(mu1-mu).^2)./(n0*sigma0.^2+n1*sigma1.^2);
[featureScores,index]=sort(featureScores,'descend');
arrangedFeatureMatrix=descriptors(:,index);
end
