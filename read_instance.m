%
% function y = read_instance(fname,decimate)
% Reads an instance for training/classification purposes and decimates it. 
% Instance can be a video file or a text file containing ground truth as as
% single character array with the corresponding label for each frame
% Input: fname - file name and path
%        decimate - decimation value of the read video frames
% Output:matrix/array containing the instance data
function y = read_instance(fname, decimate)

% Check number of input arguments
if nargin < 2
    error('Not enough input arguments')
elseif nargin > 2 
    error('Too many input arguments')
end

% Check data type of input arguments
if exist(fname, 'file') ~= 2
    error('File does not exist')
end
if decimate ~= floor(decimate)
    error('Argument decimate is not an integer')
end

[~,~,ext] = fileparts(fname);

if strcmp(ext, '.avi')
    % File is a video file
    v = VideoReader(fname);
    L = v.Duration * v.FrameRate; % number of video frames
    video = zeros(v.Height, v.Width, 3, ceil(L/decimate), 'uint8');
    i = 0;
    while hasFrame(v)
        frame = readFrame(v);
        i = i+1;        
        % Decimate video to 1/10
        if ~mod(i-1, decimate)
            video(:,:,:,(i-1)/decimate+1) = frame;
        end
    end
    y = video; %output
elseif strcmp(ext, '.txt')
    text = fileread(fname);
    L = length(text); % number of video frames
    labels = zeros(1,ceil(L/decimate));
    for i=1:length(text)
        if ~mod(i-1,decimate)
            labels((i-1)/decimate+1) = str2double(text(i));
        end
    end
    y = labels; % output
end
end