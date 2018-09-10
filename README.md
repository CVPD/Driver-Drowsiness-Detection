# Driver-Drowsiness-Detection

## List of scripts:

### **Main Pipeline Example**
Preprocess, reduce and train classifier for one PML technique. It makes use of the following functions:

1. PreprocessDataset: collects all videos from each training/test dataset subject and situation and applies the desired PML preprocessing. 
    
2. BuildTrainDataset: Builds a dataset from a file created by PreprocessDataset
    
3. DatasetPCA: Performs PCA analysis on given dataset

4. ReduceDataset: Reduces a dataset using the structure returned by DatasetPCA

5. TrainReducedDataset: loads the reduced training and test datasets and build SVM classifiers modifying the number of training features, the SVM kernel parameters and the SVM C parameter.
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
