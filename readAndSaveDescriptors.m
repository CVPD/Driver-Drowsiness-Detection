%%READ ALL DESCRIPTORS FOR SLEEPY AND NON SLEEPY VIDEOS SAVED BY THE SCRIPT
%%EXTRACTDESCRIPTORS.M IN ADDITION TO READING ALL THE CORRESPONDING LABELS
%%AND SAVING THE WHOLE DESCRIPTORS IN A MAT FILE FOR TRAINING. TO DO THIS
%%FOR DIFFERENT SITUATION THE SITUATION VARIABLE MUST BE CHANGED
clc
close all
clear all

Files = dir();
Files = {Files([Files.isdir]).name};
Files = Files(~ismember(Files,{'.','..'}));
Files = Files(~ismember(Files,{'evaluation'}));
rootDirectory = [pwd '/'];

ProcessedFileNames = {'nonSleepyCombination', 'SleepyCombination',...
    'slowBlinkWithNodding', 'yawning'};
DetectedFramesFileNames = {'rectifiednonSleepyCombination', ...
    'rectifiedsleepyCombination', 'slowBlinkWithNodding', 'yawning'};
LabelsFileNames = {'nonsleepyCombination', 'sleepyCombination',...
    'slowBlinkWithNodding', 'yawning'};

fullDescriptors = struct;
allLabels = struct;

% Process each subject
for i=1:length(Files)
    subject = Files{i};
    situation = dir(subject);
    situation = {situation([situation.isdir]).name};
    situation = situation(~ismember(situation,{'.','..'}));
    subject = [subject '/'];
    
    % Process each situation
    for j=1:length(situation)
        if ~isfield(fullDescriptors, situation{j})
            fullDescriptors.(situation{j}) = [];
            allLabels.(situation{j}) = [];
        end
        % Process each subject state file
        for k=1:length(ProcessedFileNames)       
            % Build data file name
            fname_data = [rootDirectory subject situation{j} '/'...
                ProcessedFileNames{k} '.mat'];
            % Build face-detected frames file name
            fname_DetectedFrames = [rootDirectory subject situation{j} '/' ...
                DetectedFramesFileNames{k} 'Detection.txt'];
            % Build labels file name
            fname_labels= [rootDirectory subject situation{j}  '/' ...
                subject(1:end-1) '_' LabelsFileNames{k} '_drowsiness.txt'];
            
            % Load data
            load(fname_data);
            DetectedFrames = read_instance(fname_DetectedFrames, 10);
            labels = read_instance(fname_labels, 10);
            
            % Remove all data frames and labels without a detected face
            if size(allDescriptors,1) >= size(DetectedFrames)
                allDescriptors = allDescriptors(logical(DetectedFrames),:);
                labels = labels(logical(DetectedFrames));
                % Add descriptors and labels
                fullDescriptors.(situation{j}) = [fullDescriptors.(situation{j}); allDescriptors];
                %fullDescriptors = [fullDescriptors; allDescriptors];
                allLabels.(situation{j}) = [allLabels.(situation{j}), labels];
                %allLabels = [allLabels, labels];
            else
                fprintf('File not processed: %s\n', fname_data);
            end
        end
        %SaveName = ['Subsample10' situation{j} 'AllTrainingDescriptors.mat'];
    end
    fprintf('Subject %s processed\n', subject(1:end-1));
end
for i=1:length(situation)
    SaveName = ['Subsample10' situation{i} 'AllTrainingDescriptors.mat'];
    descriptors  = fullDescriptors.(situation{i});
    labels = allLabels.(situation{i});
    parsaveDataset(SaveName, descriptors, labels');
end
clear DetectedFrames labels fname_data fname_DetectedFrames fname_labels
clear situation ProcessedFileNames DetectedFramesFileNames LabelsFileNames Files
clear i j k rootDirectory descriptors labels

function parsaveDataset(fname, descriptors, labels)

save(fname, 'descriptors', 'labels');

end