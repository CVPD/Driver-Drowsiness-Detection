
%% BUILD FILE NAMES CELL ARRAY
% Load current directory and extract all folder names
Files=dir();
Files = {Files([Files.isdir]).name};

% Remove evaluation folder from training dataset
FilesEvaluation = Files{ismember(Files,{'evaluation'})};
FilesEvaluation = dir(FilesEvaluation);
FilesEvaluation = {FilesEvaluation([FilesEvaluation.isdir]).name};
FilesEvaluation = FilesEvaluation(~ismember(FilesEvaluation,{'.','..'}));

% Remove folders not belonging to training dataset
for i=1:length(Files)
    if isnan(str2double(Files{i}))
        Files{i} = '.';
    end
end
Files = Files(~ismember(Files,{'.','..'}));
rootDirectory=[pwd '/'];

% Build a cell array containing all filenames to be processed
videoNames = {'rectifiedsleepyCombination.avi','rectifiednonSleepyCombination.avi', ...
    'slowBlinkWithNodding.avi', 'yawning.avi'};
evaluationVideoNames = {'_glasses_mix','_nightglasses_mix', '_nightnoglasses_mix'...
    '_noglasses_mix','_sunglasses_mix'};

% Training Dataset
NbSituations = 5;
FileNames = cell(length(Files)*NbSituations*length(videoNames),1);
l = 1;
for i=1:length(Files)
    subject = Files{i};
    situation = dir(subject);
    situation = {situation([situation.isdir]).name};
    situation = situation(~ismember(situation,{'.','..'}));
    subject = [subject '/'];
    
    for j=1:length(situation)
        for k=1:length(videoNames)
            FileNames{l} = [rootDirectory subject situation{j} '/' videoNames{k}];
            l = l+1;
        end
    end
end

% Evaluation Dataset
FileNamesEvaluation = cell(length(FilesEvaluation)*length(evaluationVideoNames),1);
l = 1;
for i=1:length(FilesEvaluation)
    subject = FilesEvaluation{i};
    subject = [subject '/'];
    
    for j=1:length(evaluationVideoNames)
        FileNamesEvaluation{l} = [rootDirectory 'evaluation/' subject subject(1:end-1) evaluationVideoNames{j} '.avi'];
        l = l+1;
    end
end

% Remove cells from cellarray that are empty: i.e. some subjects don't
% include all situations
FileNames = FileNames(~cellfun(@isempty, FileNames));
FileNamesEvaluation = FileNamesEvaluation(~cellfun(@isempty, FileNamesEvaluation));
% Check if all videos exist
for i=1:length(FileNames)
    if exist(FileNames{i}, 'file') ~= 2
        fprintf('File does not exist: %s\n', FileNamesEvaluation{i});
    end
end
for i=1:length(FileNamesEvaluation)
    if exist(FileNamesEvaluation{i}, 'file') ~= 2
        fprintf('File does not exist: %s\n', FileNamesEvaluation{i});
    end
end
clear NbSituations l i j subject situation Files

%% PROCESS TRAINING DATASET

% Create dictionaries to translate the name of the video file in the names
% of the labels and detected frames files
DetectedFramesDict = struct('rectifiedsleepyCombination','rectifiedsleepyCombinationDetection',...
    'rectifiednonSleepyCombination','rectifiednonSleepyCombinationDetection',...
    'slowBlinkWithNodding','slowBlinkWithNoddingDetection',...
    'yawning','yawningDetection');

LabelsDict = struct('rectifiedsleepyCombination','sleepyCombination_drowsiness',...
    'rectifiednonSleepyCombination','nonsleepyCombination_drowsiness',...
    'slowBlinkWithNodding','slowBlinkWithNodding_drowsiness',...
    'yawning','yawning_drowsiness');

% Build training dataset as a cell array
TempDataset = cell(1,length(FileNames));
notprocessedFiles = cell(1,length(FileNames));

parfor i=1:length(FileNames)
    if strcmp(PMLType, 'PML-COV')
        descriptors = extractPMLCovDescriptors(FileNames{i}, decimateValueTrain);
    elseif strcmp(PMLType, 'PML-HOG')
        descriptors = extractPMLHogDescriptors(FileNames{i}, decimateValueTrain);
    elseif strcmp(PMLType, 'PML-LBP')
        descriptors = extractPMLLbpDescriptors(FileNames{i}, decimateValueTrain);
    end
    
    pathParts = split(FileNames{i}, filesep);
    subject = pathParts{end-2};
    situation = pathParts{end-1};
    [~,filename,~] = fileparts(pathParts{end});
    fname_DetectedFrames = [rootDirectory subject '/' situation '/' DetectedFramesDict.(filename) '.txt'];
    fname_labels = [rootDirectory subject '/' situation '/' subject '_' LabelsDict.(filename) '.txt'];
    
    DetectedFrames = read_instance(fname_DetectedFrames, decimateValueTrain);
    labels = read_instance(fname_labels, decimateValueTrain);
    
    % Remove all data frames and labels without a detected face
    if size(descriptors,1) >= size(DetectedFrames,2) && size(labels,1) >= size(DetectedFrames,1)
        descriptors = descriptors(logical(DetectedFrames),:);
        labels = labels(logical(DetectedFrames));
        [~,filename] = fileparts(FileNames{i});
        subjectData = struct('subject',subject,'situation',situation, 'file', filename,  'descriptors',descriptors,'labels',labels);
        TempDataset{i} = subjectData;
    else
        fprintf('File not processed: %s\n', FileNames{i});
        notprocessedFiles{i} = FileNames{i};
    end
    fprintf('File: %s. Item: %d\n',[subject '/' situation '/' filename], i);
end
% Transform training dataset to a struct array
TempDataset = TempDataset(~cellfun(@isempty, TempDataset));
notprocessedFiles = notprocessedFiles(~cellfun(@isempty, notprocessedFiles));
TrainingDataset = struct;
for i=1:length(TempDataset)
    subjectData = struct(...
        'subject', TempDataset{i}.subject, ...
        'file', TempDataset{i}.file, ...
        'descriptors',TempDataset{i}.descriptors,...
        'labels',TempDataset{i}.labels);
    if ~isfield(TrainingDataset, (TempDataset{i}.situation))
        TrainingDataset.(TempDataset{i}.situation) = subjectData;
    else
        TrainingDataset.(TempDataset{i}.situation)(end+1) = subjectData;
    end
end
fprintf('Not processed files:\n');
for i=1:length(notprocessedFiles)
    fprintf('\tFile: %s\n', notprocessedFiles{i});
end
TrainingDataset.subsampling_rate = decimateValueTrain;
clear TempDataset subjectData subject situaion i descriptors fname_DetectedFrames fname_labels
clear labels DetectedFrames pathParts filename

%% PROCESS EVALUATION DATASET
ProcessedMatDictEval = struct('glasses','_glasses_mixing_drowsiness'...
    ,'nightglasses','_nightglasses_mixing_drowsiness',...
    'nightnoglasses','_nightnoglasses_mixing_drowsiness',...
    'noglasses','_noglasses_mixing_drowsiness',...
    'sunglasses', '_sunglasses_mixing_drowsiness');
% Build evaluation dataset as a cell array
TempDataset = cell(1,length(FileNamesEvaluation));
notprocessedEvalFiles = cell(1,length(FileNamesEvaluation));

parfor i=1:length(FileNamesEvaluation)
    
    pathParts = split(FileNamesEvaluation{i}, filesep);
    subject = pathParts{end-1};
    situation = pathParts{end};
    situation = split(situation,'_');
    situation = situation{2};
    [~,filename,~] = fileparts(pathParts{end});
    fprintf('Processing file: %s. Item: %d\n',[subject '/' situation '/' filename], i);
    if strcmp(PMLType, 'PML-COV')
        descriptors= extractPMLCovDescriptors(FileNamesEvaluation{i}, decimateValueTest);
    elseif strcmp(PMLType, 'PML-HOG')
        descriptors= extractPMLHogDescriptors(FileNamesEvaluation{i}, decimateValueTest);
    elseif strcmp(PMLType, 'PML-LBP')
        descriptors= extractPMLLbpDescriptors(FileNamesEvaluation{i}, decimateValueTest);
    end    

    fname_DetectedFrames = [rootDirectory 'evaluation/' subject '/' situation '_Detection.txt'];
    fname_labels = [rootDirectory 'evaluation/' subject  '/' subject ProcessedMatDictEval.(situation) '.txt'];
    DetectedFrames = read_instance(fname_DetectedFrames, decimateValueTest);
    labels = read_instance(fname_labels, decimateValueTest);
    
    % Remove all data frames and labels without a detected face
    if size(descriptors,1) == size(DetectedFrames,2) ...
            && size(labels,1) == size(DetectedFrames,1)
        descriptors = descriptors(logical(DetectedFrames(3:end)),:);
        labels = labels(logical(DetectedFrames(3:end)));
        subjectData = struct('subject',subject,'situation',situation,'descriptors',descriptors,'labels',labels);
        TempDataset{i} = subjectData;
        fprintf('File: %s. Item: %d\n',[subject '/' situation '/' filename], i);
    else
        fprintf('File not processed: %s\n', FileNamesEvaluation{i});
        notprocessedEvalFiles{i} = FileNamesEvaluation{i};
    end
end

% Transform evaluation dataset to a struct array
TempDataset = TempDataset(~cellfun(@isempty, TempDataset)); % Remove empty cells
notprocessedEvalFiles = notprocessedEvalFiles(~cellfun(@isempty, notprocessedEvalFiles));
EvaluationDataset = struct;
for i=1:length(TempDataset)
    subjectData = struct(...
        'subject', TempDataset{i}.subject, ...
        'descriptors',TempDataset{i}.descriptors,...
        'labels',TempDataset{i}.labels);
    if ~isfield(EvaluationDataset, (TempDataset{i}.situation))
        EvaluationDataset.(TempDataset{i}.situation) = subjectData;
    else
        EvaluationDataset.(TempDataset{i}.situation)(end+1) = subjectData;
    end
end

fprintf('Not processed files:\n');
for i=1:length(notprocessedEvalFiles)
    fprintf('\tFile: %s\n', notprocessedEvalFiles{i});
end
EvaluationDataset.subsampling_rate = decimateValueTest;
clear TempDataset subjectData subject situaion i descriptors fname_DetectedFrames fname_labels
clear labels DetectedFrames pathParts filename

%% SAVE TRAINING/TEST DATASET

% Save results
fname = [rootDirectory 'ProcessedData/' PMLType '/TrainingDataset_Sub' int2str(decimateValueTrain) '.mat'];
if exist([rootDirectory 'ProcessedData/' PMLType '/'], 'dir') ~= 7
    status = mkdir([rootDirectory 'ProcessedData/' PMLType '/']);
    if ~status
        error(['Unable to create folder: ' [rootDirectory 'ProcessedData/' PMLType '/']])
    end
end

save(fname, '-struct', 'TrainingDataset')

fname = [rootDirectory 'ProcessedData/' PMLType '/EvaluationDataset_Sub' int2str(decimateValueTest) '.mat'];
if exist([rootDirectory 'ProcessedData/'], 'dir') ~= 7
    status = mkdir([rootDirectory 'ProcessedData/' PMLType '/']);
    if ~status
        error(['Unable to create folder: ' [rootDirectory 'ProcessedData/' PMLType '/']])
    end
end
save(fname, '-struct', 'EvaluationDataset', '-v7.3')

