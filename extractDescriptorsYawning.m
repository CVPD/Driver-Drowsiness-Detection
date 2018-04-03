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

%Remove evaluation folder
Files = Files(~ismember(Files,{'evaluation'}));
rootDirectory=[pwd '/'];
parfor i = 1:length(Files)
   currentFile = char(Files(i));
   situation = dir(currentFile);
   situation = {situation([situation.isdir]).name};
   situation = situation(~ismember(situation,{'.','..'}));
   currentFile=[currentFile '/'];
   
   Descriptors = cell(1, length(situation));
   for j=1:length(situation)  
     ('start')

     fname = char(strcat(rootDirectory,currentFile,situation(j),'/yawning.avi'));
     allDescriptors=extractPMLDescriptor(fname);
     parsave([fileparts(fname) '/yawning.mat'], allDescriptors);
     
     ('end')
   end
   Files(i)
   
end

