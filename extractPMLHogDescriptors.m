function descriptors = extractPMLHogDescriptors(path, decimateValue)

% Initialization of variables
DescriptorLength = 11440;
video = VideoReader(path);
TotalFrames = video.NumberOfFrames;
descriptors = zeros(floor((TotalFrames-1)/decimateValue)+1, DescriptorLength);
HOG_descriptor = zeros(1, DescriptorLength);
numberOfFrame = 1;
pyramid_level = 5;
blocksize = 32;

video = VideoReader(path); % It is necessary to reload the video because 
                           % the NumberOfFrames attribute has been accessed
while(hasFrame(video))
    frame=readFrame(video);
    % Process one frame each 'decimate' frames
    if ~mod((numberOfFrame-1), decimateValue)
        HOG_descriptor=getPmlHogDescriptor(frame,pyramid_level,blocksize);        
        descriptors((numberOfFrame-1)/decimateValue+1,:) = HOG_descriptor;
    end
    numberOfFrame=numberOfFrame+1;
end
end