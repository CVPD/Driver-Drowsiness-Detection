%%READ ALL DESCRIPTORS FOR SLEEPY AND NON SLEEPY VIDEOS SAVED BY THE SCRIPT
%%EXTRACTDESCRIPTORS.M IN ADDITION TO READING ALL THE CORRESPONDING LABELS
%%AND SAVING THE WHOLE DESCRIPTORS IN A MAT FILE FOR TRAINING. TO DO THIS
%%FOR DIFFERENT SITUATION THE SITUATION VARIABLE MUST BE CHANGED
clc
close all
clear all

Files=dir()
Files={Files([Files.isdir]).name}
Files=Files(~ismember(Files,{'.','..'}))
rootDirectory=[pwd '\']

saveDescriptorsInThisWay='modulo10ALL'
fullDescriptors=[]
allLabels=[]
%saveDesriptorsInThisWay='module10OnlyDetectedFaces'
for i =1:length(Files)-1
   currentFile=char(Files(i));
   situation='night_noglasses';
   currentFile=[currentFile '/'];

   currentFile
   cd(strcat(currentFile,char((situation))));
   currentFile(end)='_';
   load 'SleepyCombination.mat';
   %%%%%%%%%%%%%%%%%%
    
   allFrames=fileread('rectifiedsleepyCombinationDetection.txt');
   allLabelsFrames=fileread(strcat(currentFile,'sleepyCombination_drowsiness.txt'));
   
   describedFrames=[];
   labelOfDescribedFrames=[];
   for i=1:10:length(allLabelsFrames)
       describedFrames=[describedFrames;str2num(allFrames(i))];
       labelOfDescribedFrames=[labelOfDescribedFrames;str2num(allLabelsFrames(i))];
   end
   if(strcmp(saveDescriptorsInThisWay,'modulo10ALL'))
       detectedFrames=ones(1,length(describedFrames))==1;
   elseif(strcmp(saveDescriptorsInThisWay,'module10OnlyDetectedFaces'))
       detectedFrames=describedFrames==1;
       
   end
   
   descriptorsThatAreGood=allDescriptors(detectedFrames,:);


   labelsThatAreGood=labelOfDescribedFrames(detectedFrames);
   
   labelsThatAreGood;
   fullDescriptors=[fullDescriptors;descriptorsThatAreGood];
   allLabels=[allLabels;labelsThatAreGood];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   load 'nonSleepyCombination.mat';
   allFrames=fileread('rectifiednonSleepyCombinationDetection.txt');
   allLabelsFrames=fileread(strcat(currentFile,'nonsleepyCombination_drowsiness.txt'));
size(allFrames)

   size(allLabelsFrames)

  describedFrames=[];
   labelOfDescribedFrames=[];
   for i=1:10:length(allLabelsFrames)
       describedFrames=[describedFrames;str2num(allFrames(i))];
       labelOfDescribedFrames=[labelOfDescribedFrames;str2num(allLabelsFrames(i))];
       

   end
   
   if(strcmp(saveDescriptorsInThisWay,'modulo10ALL'))
   detectedFrames=ones(1,length(describedFrames))==1;
   elseif(strcmp(saveDescriptorsInThisWay,'module10OnlyDetectedFaces')) 
   detectedFrames=describedFrames==1; 
   end
   
   size(allFrames)
   descriptorsThatAreGood=allDescriptors(detectedFrames,:);

   labelsThatAreGood=labelOfDescribedFrames(detectedFrames);

   
   fullDescriptors=[fullDescriptors;descriptorsThatAreGood];
   allLabels=[allLabels;labelsThatAreGood];
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 cd ..
   cd ..   

 
end 
 

save(strcat(saveDescriptorsInThisWay,strcat(situation,'AllTrainingDescriptors.mat')),'fullDescriptors','allLabels')



