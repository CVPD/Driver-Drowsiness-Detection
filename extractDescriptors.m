%%%%%%%%%EXTRACT DESCRIPTORS FOR ALL SITUATION FOR SLEEPY AND NONSLEEPY
%%%%%%%%%VIDEOS SAVING THE DESCRIPTORS IN A FILE IN EACH FOLDER
clc
close all
clear all
warning('off','all')
warning
Files=dir()
Files={Files([Files.isdir]).name}
Files=Files(~ismember(Files,{'.','..'}));
%Files=['023' '024' '031' '032' '033' '034' '035' '036']
rootDirectory=[pwd '/'];

%Files=cell(1,1)
%Files{1}='036'
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

