function output=pyramid(image,pyramid_level,blocksize)
% author : Beaudoin Maxime
% 07/20/2016
% for example output=pyramid('cat.jpg',4,30)

%%%I CHANGED THIS
if isstr(image)
    im=imread(image);
else
    im=image;
end
%im = imread(image);

output = cell(1,pyramid_level);
n=pyramid_level;

if nargin == 3
    output{1,1} = imresize (im, [pyramid_level*blocksize pyramid_level*blocksize]);
else
    error('Input arguments');
end

for i=2:pyramid_level
    output{1,i} = imresize (output{1,i-1},(n-1)/n);
    n=n-1;
end
