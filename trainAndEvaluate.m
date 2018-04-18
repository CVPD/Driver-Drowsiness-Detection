%%TRAIN MODELS USING PCA, FISHER AND SVM VARYING THE PARAMETER OF FISHER
%%AND SVM TO GET BEST RESULTS SAVING THE WHOME EXPERIMENT IN A MAT FILE
%%WITH CORRESPONDING PARAMETERS.
clc
clearvars
close all


% load modulo10ALLnightglassesAllTrainingDescriptors.mat
%
% Training=fullDescriptors;
% labels=allLabels;
%
% load nightglassesAllTestDescriptors.mat
% Test=fullDescriptors;
% testLabels=allLabels;
PCA_Ratio = 95.5;
Ncomp = 2;
    
situation = {'glasses', 'night_noglasses', 'nightglasses','noglasses'...
    ,'sunglasses'};
rootdirectory = [pwd, '/'];
for k=1:length(situation)
    fname_training = [rootdirectory 'Subsample10' situation{k} 'AllTrainingDescriptors.mat'];
    fname_test = [rootdirectory situation{k} 'AllTestDescriptors.mat'];
    
    fprintf('Loading data: %s\n', situation{k});  
    TrainingData=load(fname_training);
    training = TrainingData.descriptors;
    trainlabels = TrainingData.labels;
    TestData = load(fname_test);
    test = TestData.fullDescriptors;
    testLabels = TestData.allLabels;
    TrainingData = [];
    TestData = [];
    fprintf('Test and Training data loaded: %s\n', situation{k});
    
    [FeatureVector,LearnDBPCA,eigVal] = princomp(training);
    
    fprintf('PCA analysis finished: %s\n', situation{k});
    
    % Générer la sortie de la transformation utilisant les vecteurs propres
    % fournis à la sortie de l'ACP : appliquée à la base de test
    
    TestDBPCA = FeatureVector'*(test-(ones(size(test,1),1)*mean(training,1)))';
    TestDBPCA = TestDBPCA';    
    
    S = sum(eigVal);
    for l=1:length(eigVal)
        if (sum(eigVal(1:l)) >= PCA_Ratio/100*S)
            break
        end
    end
    NbComponentsPCA = l;
    LearnDBPCA = LearnDBPCA(:,1:NbComponentsPCA);
    TestDBPCA = TestDBPCA(:,1:NbComponentsPCA);
    
    [LearnDBPCA,index_i] = ArrangeByFisherScore(LearnDBPCA,trainlabels);
    TestDBPCA = TestDBPCA(:,index_i);
    
    allFisherPercentage = zeros(240,1);
    allrbfParameter = zeros(240,1);
    %index_i = 0;
    kernelSVM = 'rbf';
    if strcmp(kernelSVM, 'rbf')
        i=[1 1.5 2 2.5 3 4 5:5:20];
    elseif strcmp(kernelSVM, 'poly')
        i = 1:10;
    end
    j=[1 2 3 4 5:5:100];
    I = length(i);
    J = length(j);
    
    allAccuracy = zeros(J, I);
    Accuracy = zeros(J, I);
    fisherPercentage = zeros(J, I);
    rbfParameter = zeros(J, I);
    for index_j = 1:J
        Learn=LearnDBPCA(:, 1:ceil(j(index_j) * 0.01 * length(LearnDBPCA(1, :))));
        Test=TestDBPCA(:, 1:ceil(j(index_j) * 0.01 * length(TestDBPCA(1, :))));
        
        %optionss=optimset('Display','off','MaxIter',50000);
        
        parfor index_i = 1:I
            allFisherPercentage(index_i)= j(index_j);
            allrbfParameter(index_i) = i(index_i);
%             SVMStruct = svmtrain(Learn, trainlabels, 'kernel_function', 'rbf', ...
%                 'rbf_sigma', i, 'options', optionss);
            %SVMStruct = svmtrain(Learn,trainlabels,'kernel_function',...
            %   'polynomial','polyorder',i,'options',optionss);
            SVMClassifier = fitcsvm(Learn, trainlabels, 'KernelFunction', 'rbf', ...
                'KernelScale', i(index_i), 'IterationLimit', 50000);
%             SVMClassifier = fitcsvm(Learn, trainlabels, 'KernelFunction', 'Polynomial', ...
%                 'PolynomialOrder', i(index_i), 'IterationLimit', 50000);
%             predictedLabels = svmclassify(SVMStruct, Test);
%             predictedLabelsTrain = svmclassify(SVMStruct, Learn);
            predictedLabels = SVMClassifier.predict(Test);
            predictedLabelsTrain = SVMClassifier.predict(Learn);
            
            accuracy = 100 * (sum(predictedLabels==testLabels) / length(testLabels));
            allAccuracy(index_j, index_i) = accuracy;
            fisherPercentage(index_j, index_i) = j(index_j);
            rbfParameter(index_j, index_i) = i(index_i);
            fprintf('Situation: %s, i: %d, j:%d\n', situation{k}, i(index_i), j(index_j));
            fprintf('Accuracy test data: %.3f\t', accuracy);
            fprintf('Accuracy train data: %.3f\n', ...
                100 * (sum(predictedLabelsTrain==trainlabels) / length(trainlabels)));
        end
    end
    [maxAccuracy, maxIndex] = max(allAccuracy(:));
    [idxMaxRow, idxMaxCol] = ind2sub(size(allAccuracy), maxIndex);
    fisherPercentage = fisherPercentage(idxMaxRow, idxMaxCol);
    save_fname = ['PCASubsample10' kernelSVM situation{k} 'Results.mat'];
    parsaveResults(save_fname, maxAccuracy, fisherPercentage, rbfParameter, ... 
        allAccuracy, allFisherPercentage, allrbfParameter);
end

function parsaveResults(fname, maxAccuracy, fisherPercentage, rbfParameter, ...
    allAccuracy, allFisherPercentage, allrbfParameter)

    save(fname, 'maxAccuracy', 'fisherPercentage', 'rbfParameter', 'allAccuracy', ...
        'allFisherPercentage', 'allrbfParameter');
end