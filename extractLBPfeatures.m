
% Load current directory and extract all folder names
Files=dir();
Files = {Files([Files.isdir]).name};
Files = Files(~ismember(Files,{'.','..'}));

%Remove evaluation folder
Files = Files(~ismember(Files,{'evaluation'}));
rootDirectory=[pwd '/'];

neighbors = 8;
CellSize = [31 31];
numbins = neighbors + 2;
videoType = {'recitfiednonSleepyCombination.avi', 'rectifiedsleepyCombination.avi', ...
    'slowBlinkWithNodding.avi', 'yawning.avi'};

parfor i=1:length(Files)
    currentFile = char(Files(i));
    situation = dir(currentFile);
    situation = {situation([situation.isdir]).name};
    situation = situation(~ismember(situation,{'.','..'}));
    currentFile=[currentFile '/'];
        
    for j=1:length(situation)
        for k=1:length(videoType)
            fname = [rootDirectory currentFile situation{j} videoType{k}];
            videoFrames = read_instance(fname, 10);
            [x,y,z,w] = size(videoFrames);
            numCells = prod(floor([x y]./CellSize));
            lbp = zeros(w, numCells * numbins);
            videoGray = zeros(x,y,w, 'uint8');
            for m=1:w
                videoGray(:,:,m) = rgb2gray(videoFrames(:,:,:,m));
            end
            for m=1:w
                lbp(m,:) = extractLBPFeatures(videoGray(:,:,m), 'CellSize', CellSize, 'Upright', 0);
                fprintf('Frame: %d / %d. Situation: %s/%s\n', m, w, situation{j}, Files{i});
            end
            parsave([fileparts(fname) '/LBPFeatures' videoType{k} '.mat'], lbp);
        end
    end
end
