function covDescript=CovarianceDescriptor(myImage,numblcks)

sqrtnumblcks=sqrt(numblcks);
% sqrtnumblcks=numblcks;

[r,c,~]=size(myImage);

if isstr(myImage)
    I=imread(myImage);
else
    I=myImage;
end

numpixels=ceil(r/sqrtnumblcks);

if length(I)~=numpixels*sqrtnumblcks
    I=imresize(I,[numpixels*sqrtnumblcks numpixels*sqrtnumblcks]);
end


%compute lbp images

lbpImages=ComputeLBPimages(I);

for i=1:9
    lpbchan=lbpImages{i};
    lbpchannels{i}=im2col(lpbchan,[numpixels numpixels],'distinct');
end
    
    
    
imhsv=rgb2hsv(I);

r=I(:,:,1);r=zscoreImage(r);
g=I(:,:,2);g=zscoreImage(g);
b=I(:,:,3);b=zscoreImage(b);
h=imhsv(:,:,1);h=zscoreImage(h);
s=imhsv(:,:,2);s=zscoreImage(s);
v=imhsv(:,:,3);v=zscoreImage(v);                

[x,y,Gx,Gy,Gxx,Gyy,Gxy,Gyx]=xyCoordinates(I);  

[~,qL1]=image2phases(I,[1 1 1]);


%define the different channels
chan0r=im2col(qL1(:,:,1),[numpixels numpixels],'distinct');
chan0g=im2col(qL1(:,:,2),[numpixels numpixels],'distinct');
chan0b=im2col(qL1(:,:,3),[numpixels numpixels],'distinct');


chan2=im2col(r,[numpixels numpixels],'distinct');
chan3=im2col(g,[numpixels numpixels],'distinct');
chan4=im2col(b,[numpixels numpixels],'distinct');
chan5=im2col(h,[numpixels numpixels],'distinct');
chan6=im2col(s,[numpixels numpixels],'distinct');
chan7=im2col(v,[numpixels numpixels],'distinct');
chan8=im2col(x,[numpixels numpixels],'distinct');
chan9=im2col(y,[numpixels numpixels],'distinct');
chan10=im2col(Gx,[numpixels numpixels],'distinct');
chan11=im2col(Gy,[numpixels numpixels],'distinct');
chan12=im2col(Gxx,[numpixels numpixels],'distinct');
chan13=im2col(Gyy,[numpixels numpixels],'distinct');
chan14=im2col(Gxy,[numpixels numpixels],'distinct');
chan15=im2col(Gyx,[numpixels numpixels],'distinct');



for kk=1:size(chan2,2)

    result=[chan0r(:,kk) chan0g(:,kk) chan0b(:,kk) lbpchannels{1}(:,kk) lbpchannels{2}(:,kk) lbpchannels{3}(:,kk),...
        chan2(:,kk) chan3(:,kk) chan4(:,kk) chan5(:,kk) chan6(:,kk) chan7(:,kk) chan8(:,kk) chan9(:,kk),...
        chan10(:,kk) chan11(:,kk) chan12(:,kk) chan13(:,kk) chan14(:,kk) chan15(:,kk)];
    
    
    [row,col]=size(result);
    covMatrice=cov(double(result))+10^-3*eye(col,col);
    covMat=logm(covMatrice);
    start=1;
    cM=[];
    for i=1:col                     
        cM=[cM covMat(i,start:end)];
        start=start+1;
    end
    covMatrix(kk,:)=cM;
end
                
covDescript=transpose(covMatrix(:));
   
end

 
%% compute lbp images

function lbpImages=ComputeLBPimages(I)


Mode={'u2','ri','riu2'};

I=rgb2gray(I);
k=1;
for r=1:3
    for m=1:3
            mode=Mode{m};
            mapping=getmapping(8,mode);  % 
            bins=mapping.num;
            lbpImage=lbp(I,r,8,mapping,mode); %LBP image in (8,1) neighborhood
            lbpImages{k}=resizedLbp(I,lbpImage,r); 
            k=k+1;
            
    end
end
end

%% compute gradient images

function [x,y,Gx,Gy,Gxx,Gyy,Gxy,Gyx]=xyCoordinates(I)
        I=rgb2gray(I);
        I=double(I);
        [row,col]=size(I);
        x=zeros(row,col);
        y=zeros(row,col);
        for i=1:row
            for j=1:col
              x(i,j)=j;
              y(i,j)=i;
            end
        end
%         x=x/col*255;
%         y=y/row*255;
        [Gx,Gy]=gradient(I);
        [Gxx,Gyx]=gradient(Gx);
        [Gxy,Gyy]=gradient(Gy);
        
        x=zscoreImage(x);
        y=zscoreImage(y);
        Gx=zscoreImage(Gx);
        Gy=zscoreImage(Gy);
        Gxx=zscoreImage(Gxx);
        Gyy=zscoreImage(Gyy);
        Gxy=zscoreImage(Gxy);
        Gyx=zscoreImage(Gyx);
        
end

%% zscore transformation

function Im=zscoreImage(I)
I=double(I);
        [row,col]=size(I);
        I=reshape(I,1,row*col);
        I=zscore(I);
        Im=reshape(I,row,col);
        
end


%% resize lbp images

function lbpImage=resizedLbp(I1,I2,r)
%I1 refers to original image in gray scale
%I2 refers to lbp image
% r: radio
[row,col]=size(I1);
lbpImage=zeros(row,col);
for i=1:row-2*r
    for j=1:col-2*r
      lbpImage(i+r,j+r)  =I2(i,j);
    end
end

end

%% compute quaternionic transformation

function [Phi,Gamma]=image2phases(myImage,alfa)

% myimage is a rgb image

%read the input image
if isstr(myImage)
    I=imread(myImage);I=im2double(I);
else
    I=myImage;I=im2double(I);
end
% we normalize the data such that the max value will be 1
%I=I./255;

r=I(:,:,1);
g=I(:,:,2);
b=I(:,:,3);
%


%we define the reference point for each channel
p=[1 0 0;0 1 0;0 0 1];

for i=1:3
    x=p(i,1);y=p(i,2);z=p(i,3);
    %we compute the phases
    
    %using L2 norm
    phi=atand(-(sqrt((g*z-b*y).^2+(b*x-r*z).^2+(r*y-g*x).^2))./(r*x+g*y+b*z));

    phi(isnan(phi))=pi/2;
    Phi(:,:,i)=phi;
    
    
    %using L1 norm
    gamma=atand(-(alfa(1)*abs(g*z-b*y)+alfa(2)*abs(b*x-r*z)+alfa(3)*abs(r*y-g*x)))./(r*x+g*y+b*z);
    gamma(isnan(gamma))=pi/2;
    gamma(isinf(gamma))=pi/2;
    Gamma(:,:,i)=gamma;

end

end

%% ---
%GETMAPPING returns a structure containing a mapping table for LBP codes.
%  MAPPING = GETMAPPING(SAMPLES,MAPPINGTYPE) returns a
%  structure containing a mapping table for
%  LBP codes in a neighbourhood of SAMPLES sampling
%  points. Possible values for MAPPINGTYPE are
%       'u2'   for uniform LBP
%       'ri'   for rotation-invariant LBP
%       'riu2' for uniform rotation-invariant LBP.
%
%  Example:
%       I=imread('rice.tif');
%       MAPPING=getmapping(16,'riu2');
%       LBPHIST=lbp(I,2,16,MAPPING,'hist');
%  Now LBPHIST contains a rotation-invariant uniform LBP
%  histogram in a (16,2) neighbourhood.
%

function mapping = getmapping(samples,mappingtype)
% Version 0.2
% Authors: Marko Heikkil?, Timo Ahonen and Xiaopeng Hong

% Changelog
% 0.1.1 Changed output to be a structure
% Fixed a bug causing out of memory errors when generating rotation
% invariant mappings with high number of sampling points.
% Lauge Sorensen is acknowledged for spotting this problem.

% Modified by Xiaopeng HONG and Guoying ZHAO
% Changelog
% 0.2
% Solved the compatible issue for the bitshift function in Matlab
% 2012 & higher

matlab_ver = ver('MATLAB');
matlab_ver = str2double(matlab_ver.Version);

if matlab_ver < 8
    mapping = getmapping_ver7(samples,mappingtype);
else
    mapping = getmapping_ver8(samples,mappingtype);
end

end

function mapping = getmapping_ver7(samples,mappingtype)

disp('For Matlab version 7.x and lower');

table = 0:2^samples-1;
newMax  = 0; %number of patterns in the resulting LBP code
index   = 0;

if strcmp(mappingtype,'u2') %Uniform 2
    newMax = samples*(samples-1) + 3;
    for i = 0:2^samples-1
        j = bitset(bitshift(i,1,samples),1,bitget(i,samples)); %rotate left
        numt = sum(bitget(bitxor(i,j),1:samples));  %number of 1->0 and
                                                    %0->1 transitions
                                                    %in binary string
                                                    %x is equal to the
                                                    %number of 1-bits in
                                                    %XOR(x,Rotate left(x))
        if numt <= 2
            table(i+1) = index;
            index = index + 1;
        else
            table(i+1) = newMax - 1;
        end
    end
end

if strcmp(mappingtype,'ri') %Rotation invariant
    tmpMap = zeros(2^samples,1) - 1;
    for i = 0:2^samples-1
        rm = i;
        r  = i;
        
        for j = 1:samples-1
            r = bitset(bitshift(r,1,samples),1,bitget(r,samples)); %rotate
            %left
            if r < rm
                rm = r;
            end
        end
        if tmpMap(rm+1) < 0
            tmpMap(rm+1) = newMax;
            newMax = newMax + 1;
        end
        table(i+1) = tmpMap(rm+1);
    end
end

if strcmp(mappingtype,'riu2') %Uniform & Rotation invariant
    newMax = samples + 2;
    for i = 0:2^samples - 1
        j = bitset(bitshift(i,1,samples),1,bitget(i,samples)); %rotate left
        numt = sum(bitget(bitxor(i,j),1:samples));
        if numt <= 2
            table(i+1) = sum(bitget(i,1:samples));
        else
            table(i+1) = samples+1;
        end
    end
end

mapping.table=table;
mapping.samples=samples;
mapping.num=newMax;
end



function mapping = getmapping_ver8(samples,mappingtype)

%disp('For Matlab version 8.0 and higher');

table = 0:2^samples-1;
newMax  = 0; %number of patterns in the resulting LBP code
index   = 0;

if strcmp(mappingtype,'u2') %Uniform 2
    newMax = samples*(samples-1) + 3;
    for i = 0:2^samples-1

        i_bin = dec2bin(i,samples);
        j_bin = circshift(i_bin',-1)';              %circularly rotate left
        numt = sum(i_bin~=j_bin);                   %number of 1->0 and
                                                    %0->1 transitions
                                                    %in binary string
                                                    %x is equal to the
                                                    %number of 1-bits in
                                                    %XOR(x,Rotate left(x))

        if numt <= 2
            table(i+1) = index;
            index = index + 1;
        else
            table(i+1) = newMax - 1;
        end
    end
end

if strcmp(mappingtype,'ri') %Rotation invariant
    tmpMap = zeros(2^samples,1) - 1;
    for i = 0:2^samples-1
        rm = i;
    
        r_bin = dec2bin(i,samples);

        for j = 1:samples-1

            r = bin2dec(circshift(r_bin',-1*j)'); %rotate left    
            if r < rm
                rm = r;
            end
        end
        if tmpMap(rm+1) < 0
            tmpMap(rm+1) = newMax;
            newMax = newMax + 1;
        end
        table(i+1) = tmpMap(rm+1);
    end
end

if strcmp(mappingtype,'riu2') %Uniform & Rotation invariant
    newMax = samples + 2;
    for i = 0:2^samples - 1
        
        i_bin =  dec2bin(i,samples);
        j_bin = circshift(i_bin',-1)';
        numt = sum(i_bin~=j_bin);
  
        if numt <= 2
            table(i+1) = sum(bitget(i,1:samples));
        else
            table(i+1) = samples+1;
        end
    end
end

mapping.table=table;
mapping.samples=samples;
mapping.num=newMax;
end


%% ---------
%LBP returns the local binary pattern image or LBP histogram of an image.
%  J = LBP(I,R,N,MAPPING,MODE) returns either a local binary pattern
%  coded image or the local binary pattern histogram of an intensity
%  image I. The LBP codes are computed using N sampling points on a 
%  circle of radius R and using mapping table defined by MAPPING. 
%  See the getmapping function for different mappings and use 0 for
%  no mapping. Possible values for MODE are
%       'h' or 'hist'  to get a histogram of LBP codes
%       'nh'           to get a normalized histogram
%  Otherwise an LBP code image is returned.
%
%  J = LBP(I) returns the original (basic) LBP histogram of image I
%
%  J = LBP(I,SP,MAPPING,MODE) computes the LBP codes using n sampling
%  points defined in (n * 2) matrix SP. The sampling points should be
%  defined around the origin (coordinates (0,0)).
%
%  Examples
%  --------
%       I=imread('rice.png');
%       mapping=getmapping(8,'u2'); 
%       H1=LBP(I,1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood
%                                  %using uniform patterns
%       subplot(2,1,1),stem(H1);
%
%       H2=LBP(I);
%       subplot(2,1,2),stem(H2);
%
%       SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
%       I2=LBP(I,SP,0,'i'); %LBP code image using sampling points in SP
%                           %and no mapping. Now H2 is equal to histogram
%                           %of I2.

function result = lbp(varargin) % image,radius,neighbors,mapping,mode)
% Version 0.3.3
% Authors: Marko Heikkil?and Timo Ahonen

% Changelog
% Version 0.3.2: A bug fix to enable using mappings together with a
% predefined spoints array
% Version 0.3.1: Changed MAPPING input to be a struct containing the mapping
% table and the number of bins to make the function run faster with high number
% of sampling points. Lauge Sorensen is acknowledged for spotting this problem.


% Check number of input arguments.
narginchk(1,5);

image=varargin{1};
d_image=double(image);

if nargin==1
    spoints=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
    neighbors=8;
    mapping=0;
    mode='h';
end

if (nargin == 2) && (length(varargin{2}) == 1)
    error('Input arguments');
end

if (nargin > 2) && (length(varargin{2}) == 1)
    radius=varargin{2};
    neighbors=varargin{3};
    
    spoints=zeros(neighbors,2);

    % Angle step.
    a = 2*pi/neighbors;
    
    for i = 1:neighbors
        spoints(i,1) = -radius*sin((i-1)*a);
        spoints(i,2) = radius*cos((i-1)*a);
    end
    
    if(nargin >= 4)
        mapping=varargin{4};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Incompatible mapping');
        end
    else
        mapping=0;
    end
    
    if(nargin >= 5)
        mode=varargin{5};
    else
        mode='h';
    end
end

if (nargin > 1) && (length(varargin{2}) > 1)
    spoints=varargin{2};
    neighbors=size(spoints,1);
    
    if(nargin >= 3)
        mapping=varargin{3};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Incompatible mapping');
        end
    else
        mapping=0;
    end
    
    if(nargin >= 4)
        mode=varargin{4};
    else
        mode='h';
    end   
end

% Determine the dimensions of the input image.
[ysize xsize] = size(image);



miny=min(spoints(:,1));
maxy=max(spoints(:,1));
minx=min(spoints(:,2));
maxx=max(spoints(:,2));

% Block size, each LBP code is computed within a block of size bsizey*bsizex
bsizey=ceil(max(maxy,0))-floor(min(miny,0))+1;
bsizex=ceil(max(maxx,0))-floor(min(minx,0))+1;

% Coordinates of origin (0,0) in the block
origy=1-floor(min(miny,0));
origx=1-floor(min(minx,0));

% Minimum allowed size for the input image depends
% on the radius of the used LBP operator.
if(xsize < bsizex || ysize < bsizey)
  error('Too small input image. Should be at least (2*radius+1) x (2*radius+1)');
end

% Calculate dx and dy;
dx = xsize - bsizex;
dy = ysize - bsizey;

% Fill the center pixel matrix C.
C = image(origy:origy+dy,origx:origx+dx);
d_C = double(C);

bins = 2^neighbors;

% Initialize the result matrix with zeros.
result=zeros(dy+1,dx+1);

%Compute the LBP code image

for i = 1:neighbors
  y = spoints(i,1)+origy;
  x = spoints(i,2)+origx;
  % Calculate floors, ceils and rounds for the x and y.
  fy = floor(y); cy = ceil(y); ry = round(y);
  fx = floor(x); cx = ceil(x); rx = round(x);
  % Check if interpolation is needed.
  if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
    % Interpolation is not needed, use original datatypes
    N = image(ry:ry+dy,rx:rx+dx);
    D = N >= C; 
  else
    % Interpolation needed, use double type images 
    ty = y - fy;
    tx = x - fx;

    % Calculate the interpolation weights.
    w1 = roundn((1 - tx) * (1 - ty),-6);
    w2 = roundn(tx * (1 - ty),-6);
    w3 = roundn((1 - tx) * ty,-6) ;
    % w4 = roundn(tx * ty,-6) ;
    w4 = roundn(1 - w1 - w2 - w3, -6);
            
    % Compute interpolated pixel values
    N = w1*d_image(fy:fy+dy,fx:fx+dx) + w2*d_image(fy:fy+dy,cx:cx+dx) + ...
w3*d_image(cy:cy+dy,fx:fx+dx) + w4*d_image(cy:cy+dy,cx:cx+dx);
    N = roundn(N,-4);
    D = N >= d_C; 
  end  
  % Update the result matrix.
  v = 2^(i-1);
  result = result + v*D;
end

%Apply mapping if it is defined
if isstruct(mapping)
    bins = mapping.num;
    for i = 1:size(result,1)
        for j = 1:size(result,2)
            result(i,j) = mapping.table(result(i,j)+1);
        end
    end
end

if (strcmp(mode,'h') || strcmp(mode,'hist') || strcmp(mode,'nh'))
    % Return with LBP histogram if mode equals 'hist'.
    result=hist(result(:),0:(bins-1));
    if (strcmp(mode,'nh'))
        result=result/sum(result);
    end
else
    %Otherwise return a matrix of unsigned integers
    if ((bins-1)<=intmax('uint8'))
        result=uint8(result);
    elseif ((bins-1)<=intmax('uint16'))
        result=uint16(result);
    else
        result=uint32(result);
    end
end

end

function x = roundn(x, n)

narginchk(2, 2)
validateattributes(x, {'single', 'double'}, {}, 'ROUNDN', 'X')
validateattributes(n, ...
    {'numeric'}, {'scalar', 'real', 'integer'}, 'ROUNDN', 'N')

if n < 0
    p = 10 ^ -n;
    x = round(p * x) / p;
elseif n > 0
    p = 10 ^ n;
    x = p * round(x / p);
else
    x = round(x);
end

end




