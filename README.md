# Driver-Drowsiness-Detection

## List of scripts:

### **Main Pipeline**
Preprocess, reduce and train classifier for one PML technique. It is composed of the scripts:

1. PreprocessData: gathers all videos from each training dataset subject and situation and applies the desired PML preprocessing. 
    - Paremeters:
      * decimateValueTrain: subsampling rate to be applied on the training dataset.
      * decimateValueTest: subsampling rate to be applied on the test dataset.
      * PMLType: technique to be applied: PML-COV, PML-HOG or PML-LBP.

    The result are two mat files: *TrainingDataset_Sub'decimateValueTrain'.mat* and *EvaluationDataset_Sub'decimateValueTest'.mat*. Both files contain five data structures and one field  with the decimation value applied and are saved in a folder named *ProcessedData*. Each data structure corresponds to one situation of the dataset, containing the following fields:
    - Raw data structure:
      * subject: subject number
      * file: type of file (rectifiedsleepyCombination, rectifiednonSleepyCombination, slowBlinkWithNodding, yawning)
      * descriptors: descriptors of the file
      * labels: labels of the file
    
2. LoadSortReducePCATrain: extract descriptors and labels from raw data structures and applies PCA dimensionality reduction of the training dataset. 
    - Parameters:
       * PCA_Ratio
       * PMLType: technique to be applied: PML-COV, PML-HOG or PML-LBP.
       * subsampling: decimation applied to the training dataset.
       
    The reduced dataset is saved in a file named *TrainDataReducedByPCA'PCA_Ratio'_Sub'subsampling'.mat*. Another file is is also generated with the results of the PCA analysis, *PCA'PCA_Ratio'Train_DupData_Sub'subsampling'.mat*. Both files are saved in a folder named *ProcessedData*.       
     
3. ReduceTestPCA: loads the PCA anlysis from the training dataset and applies it to the test dataset. 
    - Parameters:
       * PCA_Ratio
       * PMLType: technique to be applied: PML-COV, PML-HOG or PML-LBP.
       * subsampling: decimation applied to the training dataset.
       
    The reduced test dataset is saved as *EvaluationReducedPCA'PCA_Ratio_Sub'subsampling'.mat* in the folder *ProcessedData*.       

4. trainSub10vsTestSub1PCA: loads the reduced training and test datasets and build SVM classifiers modifying the number of training features, the SVM kernel parameters and the SVM C parameter.
    - Parameters:
       * PCA_Ratio
       * PMLType: technique to be applied: PML-COV, PML-HOG or PML-LBP.
       * subsampling: decimation applied to the training dataset.
       * kernel: kernel to be applied (rbf or poly)
       
    A file with relevance data from the result of each trained classifier is saved as *Results_ReducedPCA'PCA_Ratio''kernel'_Sub'subsampling'.mat*. 
    This file contains a data structure with the following fields:
      * situation
      * kernel
      * kernelScale: kernel Scale applied to the SVM classifiers
      * FisherPerc: percentage of features according to Fisher Score
      * TestAccuracy: accuracy of classifiers on test dataset for the combination of the two previous parameters
      * TrainAccuracy: accuracy of classifiers on train dataset for the combination of the two previous parameters
      * confusion_matrix: confusion matrix for each classifier
      * max_coordinates: best percentage of features to be selected and best kernelScale.
      * BoxConstraint: values of C applied to the SVM classifiers once the number of selected features number is fixed based on results on previous field.
      * tunedKernelScale: kernelScale applied to the SVM classifiers once the selected features number is fixed.
      * tunedFisherPerc: best percentage of features selected
      * tunedTestAccuracy: accuracy of classifiers on test dataset for the combination of BoxConstraint, tunedKernelScale and tunedFisherPerc.
