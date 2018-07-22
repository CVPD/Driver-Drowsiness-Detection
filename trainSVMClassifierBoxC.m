function [TestAccuracy, TrainAccuracy, InfoStruct] = trainSVMClassifierBoxC(...
    descriptors_train, labels_train, descriptors_test, labels_test, kernelSVM, ...
    kernel_scale, fisher_index)

% Kernel Scale
if strcmp(kernelSVM, 'rbf')
    kernelScale= 0.5:0.5:12;
elseif strcmp(kernelSVM, 'poly')
    kernelScale = 1:10;
end
if ~isscalar(kernel_scale)
    kernelScale = kernel_scale;
end

% Build BoxConstraint values 1e-3 to 1e+3
j=1;
for i=-3:3
    for k=1:9
        box_constraint(j) = k*10^(i);
        j = j + 1;
    end
end
box_constraint(j) = 10000;

I = length(kernelScale);
B = length(box_constraint);
TestAccuracy = zeros(B, I);
TrainAccuracy = zeros(B, I);


train_length = size(descriptors_train, 2);
test_length = size(descriptors_test, 2);
InfoStruct = struct;

disp(['Start: ' datestr(datetime('now'))]);
C_cell = cell(B, I);
order_cell = cell(B, I);
[training,index_i] = ArrangeByFisherScore(descriptors_train,labels_train);
test = descriptors_test(:,index_i);
Learn= training(:, 1:ceil(0.01 * fisher_index * train_length));
Test= test(:, 1:ceil(0.01 * fisher_index * test_length));
parfor index_b = 1:B    
    for index_i = 1:I
        if strcmp(kernelSVM, 'rbf')
            SVMClassifier = fitcsvm(Learn, labels_train, 'KernelFunction',...
                'rbf', 'KernelScale', kernelScale(index_i), 'IterationLimit', 50000, ...
                'BoxConstraint', box_constraint(index_b));
        elseif strcmp(kernelSVM, 'poly')
            SVMClassifier = fitcsvm(Learn, labels_train, 'KernelFunction',...
                'Polynomial', 'PolynomialOrder', kernelScale(index_i), 'IterationLimit', ...
                50000, 'BoxConstraint', box_constraint(index_b));
        end
        predictedLabels = SVMClassifier.predict(Test);
        predictedLabelsTrain = SVMClassifier.predict(Learn);
        TestAccuracy(index_b, index_i) = 100 * (sum(predictedLabels==labels_test)...
            / length(labels_test));
        TrainAccuracy(index_b, index_i) = 100 * (sum(predictedLabelsTrain==labels_train)...
            / length(labels_train));
        [C_cell{index_b,index_i},order_cell{index_b,index_i}] = confusionmat(labels_test, predictedLabels);
    end
end
[maxAccuracy, maxIndex] = max(TestAccuracy(:));
[idxMaxRow, idxMaxCol] = ind2sub(size(TestAccuracy), maxIndex);

InfoStruct.kernel = kernelSVM;
InfoStruct.kernelScale = kernelScale;
InfoStruct.fisher_index = fisher_index;
InfoStruct.box_constraint = box_constraint;
InfoStruct.confusion.confusion_matrix = C_cell;
InfoStruct.confusion.order = order_cell;
InfoStruct.max_coordinates = [box_constraint(idxMaxRow), kernelScale(idxMaxCol)];

disp(['Max Accuracy: ' num2str(maxAccuracy)]);
disp(['End: ' datestr(datetime('now'))]);
end