%%TRAIN MODELS USING PCA, FISHER AND SVM VARYING THE PARAMETER OF FISHER
%%AND SVM TO GET BEST RESULTS SAVING THE WHOME EXPERIMENT IN A MAT FILE
%%WITH CORRESPONDING PARAMETERS.
clc
clear all
close all

load modulo10ALLnightglassesAllTrainingDescriptors.mat 

Training=fullDescriptors;
labels=allLabels;

load nightglassesAllTestDescriptors.mat

Test=fullDescriptors;
TestLabels=allLabels;
PCA_Ratio=95.5
%Test=
Ncomp=2;
[FeatureVector,LearnDBPCA,eigVal] = princomp(Training) ;
 
% 
 % Générer la sortie de la transformation utilisant les vecteurs propres 
 % fournis à la sortie de l'ACP : appliquée à la base de test
 
 TestDBPCA=FeatureVector'*(Test-(ones(size(Test,1),1)*mean(Training,1)))';
 TestDBPCA=TestDBPCA';
 
 
  S=sum(eigVal);
  for l=1:length(eigVal)
      if (sum(eigVal(1:l))>=PCA_Ratio/100*S)
          break
      end
     
 end
 NbComposantesPCA=l;
l
% NbComposantesPCA=500;
% 
% % 
% % 
  LearnDBPCA=LearnDBPCA(:,1:NbComposantesPCA);
% 
 TestDBPCA=TestDBPCA(:,1:NbComposantesPCA);


%LearnDBPCA=Training;
%TestDBPCA=Test;
[LearnDBPCA,index]=ArrangeByFisherScore(LearnDBPCA,labels);

TestDBPCA=TestDBPCA(:,index);
fisherPercentage=0;
rbfParameter=0;
maxTau=0;
allFisherPercentage=[]
allrbfParameter=[]
allTau=[]
for j=[1 2 3 4 5:5:100]

%SVMStruct = svmtrain(LearnDBPCA,labels,'kernel_function','rbf','rbf_sigma',1);
Learn=LearnDBPCA(:,1:ceil(j*0.01*length(LearnDBPCA(1,:))));
Test=TestDBPCA(:,1:ceil(j*0.01*length(TestDBPCA(1,:))));
j

optionss=optimset('Display','final','MaxIter',30000);
for i=[1 1.5 2 2.5 3 4 5:5:20]
i
allFisherPercentage=[allFisherPercentage;j];
allrbfParameter=[allrbfParameter;i];
SVMStruct = svmtrain(Learn,labels,'kernel_function','rbf','rbf_sigma',i,'options',optionss);
%SVMStruct = svmtrain(LearnDBPCA,labels,'kernel_function','polynomial','polyorder',i,'options',optionss);

predictedLabels=svmclassify(SVMStruct,Test);
predictedLabelsTrain=svmclassify(SVMStruct,Learn);

tau=100*(sum(predictedLabels==TestLabels)/length(TestLabels))
allTau=[allTau;tau];
if(tau>maxTau)
maxTau=tau;
fisherPercentage=j;
rbfParameter=i;
end
100*(sum(predictedLabelsTrain==labels)/length(labels))
end
end
save PCAnightglassesResults.mat maxTau fisherPercentage rbfParameter allTau allFisherPercentage allrbfParameter
%Group = svmclassify(SVMStruct,Test);

%save predictedLabels.mat Group
