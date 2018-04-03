function allDescriptors=extractPMLDescriptor(path)

% Parameters
DescriptorLength = 11550;
decimate = 10;
pyramid_level = 5;
heightOfImage = 250;
blocksize = heightOfImage/pyramid_level;

% Initialization of variables
video = VideoReader(path);
TotalFrames = video.NumberOfFrames;
allDescriptors = zeros(floor((TotalFrames-1)/decimate)+1, DescriptorLength);
PMLDescriptors = zeros(1, DescriptorLength);
numberOfFrame = 1;
video = VideoReader(path); % It is necessary to reload the video because 
                           % the NumberOfFrames attribute has been accessed
while(hasFrame(video))
    frame=readFrame(video);
    % Process one frame each 'decimate' frames
    if ~mod((numberOfFrame-1), decimate)
        output=pyramid(frame,pyramid_level,blocksize);
        LastPos = 1;
        for i=1:pyramid_level
            covDescript=CovarianceDescriptor(output{1,i},(pyramid_level+1-i)^2);
            [~,length] = size(covDescript);
            PMLDescriptors(1, LastPos:LastPos+length-1) = covDescript;
            LastPos = LastPos + length;
        end
        
        allDescriptors((numberOfFrame-1)/decimate+1,:) = PMLDescriptors;
        % Print progress so far
        situation = strsplit(fileparts(path), '/');
        situation = strcat(situation{end-1}, '/', situation{end});
        fprintf('Frame: %d / %d. Situation: %s\n', ...
                (numberOfFrame-1)/decimate, floor(TotalFrames/decimate), ...
                situation);
    end
    numberOfFrame=numberOfFrame+1;
end
    
end

