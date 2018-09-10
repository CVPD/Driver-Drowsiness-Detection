function data=construct_pyramid(directory,label,pyramide_level,blocksize)
% author : Beaudoin Maxime
% 07/20/2016
% for example : data=construct_pyramid('C:\Users\Maxime\Documents\MATLAB\lfw1\',label,4,30)

myfolder = strcat(directory,'*.jpg');
liste = dir(myfolder);
images = zeros(length(liste),floor(59*(norm(1:pyramide_level)^2)));
histo = cell(1,4);
trace = zeros(floor(norm(1:pyramide_level)^2+0.01),2); % trace{j}= [3 6];means the histogram j represents the 6th block in level 3  

tic;
for i=1:length(liste)  % go on the record images
    temp=[];
    im = (strcat(directory,liste(i).name));
        output= pyramide(im,pyramide_level,blocksize);
        
    for j=1:pyramide_level       
        histo{1,j} = getHistograms(output{1,j},pyramide_level+1-j);   
    end
    
    for k=1:pyramide_level
      temp  =[temp histo{1,k}];
    end
    
    images(i,:)= temp;
end
toc;

for m=1:pyramide_level
   for n=1:m^2
        trace(floor(norm(1:pyramide_level)^2+0.01)-floor(norm(1:m)^2+0.01)+n,:)= [m n]; 
   end
end

data=struct('image',images,'trace',trace,'label',label);

filename = 'data7.mat';  % Save 'data' variable from the workspace in a binary MAT-file, data.mat.
save(filename,'data7') ;