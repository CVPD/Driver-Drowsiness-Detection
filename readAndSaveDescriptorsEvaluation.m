%%%%SCRIPT AS READANDSEAVEDESCRIPTORS.M BUT FOR TEST DATA
clc
close all
clear all

Files=dir('evaluation')
Files={Files([Files.isdir]).name}
Files=Files(~ismember(Files,{'.','..'}))
rootDirectory=[pwd '\']
allDetectedFrames=[]
fullDescriptors=[]
allLabels=[]
%saveDesriptorsInThisWay='module10OnlyDetectedFaces'
for i =1:length(Files)
   currentFile=char(Files(i));
   situation='night_noglasses';
   currentFile=[currentFile '/'];
   cd(strcat('evaluation/',currentFile));
   currentFile(end)='_';
   %load(strcat(situation,'.mat'));
   load(strcat('nightnoglasses','.mat'));
   %%%%%%%%%%%%%%%%%%
   
   %allFrames=fileread(strcat(situation,'_Detection.txt'));
   allFrames=fileread(strcat('nightnoglasses_','Detection.txt'));
   allLabelsFrames=fileread(strcat(strcat(currentFile,situation),'_mixing_drowsiness.txt'));
   detectedFrames=[];
   labelOfDescribedFrames=[];
   for i=1:1:length(allLabelsFrames)
       detectedFrames=[detectedFrames;str2num(allFrames(i))];
       labelOfDescribedFrames=[labelOfDescribedFrames;str2num(allLabelsFrames(i))];
   end
   
   size(allDescriptors)      
   size(allLabelsFrames)
   descriptorsThatAreGood=allDescriptors(3:end,:);
   labelsThatAreGood=labelOfDescribedFrames;

   fullDescriptors=[fullDescriptors;descriptorsThatAreGood];
   allLabels=[allLabels;labelsThatAreGood];
   allDetectedFrames=[allDetectedFrames;detectedFrames];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd ..
    cd ..
     
   
end
save(strcat(situation,'AllTestDescriptors.mat'),'fullDescriptors','allLabels','allDetectedFrames','-v7.3')



