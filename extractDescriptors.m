%%%%%%%%%EXTRACT DESCRIPTORS FOR ALL SITUATION FOR SLEEPY AND NONSLEEPY
%%%%%%%%%VIDEOS SAVING THE DESCRIPTORS IN A FILE IN EACH FOLDER
clc
close all
clear all
warning('off','all')
warning
% Load current directory and extract all folder names
Files=dir();
Files = {Files([Files.isdir]).name};
Files = Files(~ismember(Files,{'.','..'}));

for i =1:length(Files)
   currentFile=char(Files(i))
   situation=dir(currentFile);
   situation={situation([situation.isdir]).name};
   situation=situation(~ismember(situation,{'.','..'}))
   currentFile=[currentFile '/']
   
   for j=1:length(situation)  
     ('start')
     allDescriptors=extractPMLDescriptor(char(strcat(strcat(rootDirectory,currentFile),strcat(situation(j),'/rectifiednonSleepyCombination.avi'))));

     cd(strcat(currentFile,char((situation(j)))))
     save('nonSleepyCombination.mat',char('allDescriptors'))
     cd ..
     cd ..
     
     allDescriptors=extractPMLDescriptor(char(strcat(strcat(rootDirectory,currentFile),strcat(situation(j),'/rectifiedsleepyCombination.avi'))));
     cd(strcat(currentFile,char(situation(j))))
     save('SleepyCombination.mat',char('allDescriptors'))
     cd ..
     cd .. 
     ('end')
   end
   Files(i)
   
end

parfor i = 1:length(Files)
   currentFile = char(Files(i));
   situation = dir(currentFile);
   situation = {situation([situation.isdir]).name};
   situation = situation(~ismember(situation,{'.','..'}));
   currentFile=[currentFile '/'];
   
   Descriptors = cell(1, length(situation));
   for j=1:length(situation)  
     ('start')

     fname = char(strcat(rootDirectory,currentFile,situation(j),'/slowBlinkWithNodding.avi'));
     allDescriptors=extractPMLDescriptor(fname);
     parsave([fileparts(fname) '/slowBlinkWithNodding.mat'], allDescriptors);
      
     ('end')
   end
   Files(i)
   
end