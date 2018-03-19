%%EXTRACT DESCRIPTORS FOR TEST (SLEEPY AND NON SLEEPY ONLY)
clc
close all
clear all
warning('off','all')
warning
Files=dir('evaluation')
Files={Files([Files.isdir]).name}
Files=Files(~ismember(Files,{'.','..'}))
Files=['026' '030' ]
Files=cell(2)
Files{1}='026'
Files{2}='030'

rootDirectory=[pwd '/']

for i =1:length(Files)
   currentFile=char(Files(i))
   currentFile=[currentFile '/']
    
  'start1'    
   char(strcat(strcat(rootDirectory,currentFile),strcat(currentFile(1:end-1),'_glasses_mix.avi')))
   allDescriptors=extractPMLDescriptor(char(strcat(strcat(strcat(rootDirectory,'evaluation/'),currentFile),strcat(currentFile(1:end-1),'_glasses_mix.avi'))));
   'end1'
   cd(strcat(strcat(rootDirectory,'evaluation/'),currentFile)) 
   save('glasses.mat',char('allDescriptors'))
   cd ..
   cd ..
 
 'start2'
  allDescriptors=extractPMLDescriptor(char(strcat(strcat(strcat(rootDirectory,'evaluation/'),currentFile),strcat(currentFile(1:end-1),'_nightglasses_mix.avi'))));
  'end2'

  cd(strcat(strcat(rootDirectory,'evaluation/'),currentFile)) 
   save('nightglasses.mat',char('allDescriptors'))
  cd ..
   cd ..
   
%'start3'
%   allDescriptors=extractPMLDescriptor(char(strcat(strcat(strcat(rootDirectory,'evaluation/'),currentFile),strcat(currentFile(1:end-1),'_noglasses_mix.avi'))));
%   'end3'
%   cd(strcat(strcat(rootDirectory,'evaluation/'),currentFile)) 
%   save('noglasses.mat',char('allDescriptors'))

%   cd ..
 %  cd ..
   'start4'
   char(strcat(strcat(strcat(rootDirectory,'evaluation/'),currentFile),strcat(currentFile(1:end-1),'_nightnoglasses.avi')))
   allDescriptors=extractPMLDescriptor(char(strcat(strcat(strcat(rootDirectory,'evaluation/'),currentFile),strcat(currentFile(1:end-1),'_nightnoglasses.avi'))));
   'end4'
   cd(strcat(strcat(rootDirectory,'evaluation/'),currentFile)) 
   save('nightnoglasses.mat',char('allDescriptors'))
   cd ..
   cd ..
'start5'
   allDescriptors=extractPMLDescriptor(char(strcat(strcat(strcat(rootDirectory,'evaluation/'),currentFile),strcat(currentFile(1:end-1),'_sunglasses_mix.avi'))));
   'end5'
  cd(strcat(strcat(rootDirectory,'evaluation/'),currentFile)) 
   save('sunglasses.mat',char('allDescriptors'))
   
   cd ..
   cd .. 
   ('end')

   Files(i)
   
end
