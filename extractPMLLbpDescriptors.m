function descriptors = extractPMLLbpDescriptors(path, decimateValue)

% Initialization of variables
DescriptorLength = 3245;
video = VideoReader(path);
TotalFrames = video.NumberOfFrames;
descriptors = zeros(floor((TotalFrames-1)/decimateValue)+1, DescriptorLength);
LBP_descriptor = zeros(1, DescriptorLength);
numberOfFrame = 1;
pyramid_level = 5;
blocksize = 32;

video = VideoReader(path); % It is necessary to reload the video because 
                           % the NumberOfFrames attribute has been accessed
while(hasFrame(video))
    frame=readFrame(video);
    % Process one frame each 'decimate' frames
    if ~mod((numberOfFrame-1), decimateValue)
        LBP_descriptor=getPmlLbpDescriptor(frame,pyramid_level,blocksize);        
        descriptors((numberOfFrame-1)/decimateValue+1,:) = LBP_descriptor';
    end
    numberOfFrame=numberOfFrame+1;
end
end