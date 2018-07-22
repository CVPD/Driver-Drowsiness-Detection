function y = OrderByFileType(fname)

selectedSituation = [1,2,3,4,5];
situationOptionsTrain = {'glasses', 'night_noglasses', 'nightglasses',...
    'noglasses', 'sunglasses'};
y = struct;

for s=1:length(selectedSituation)
    
    situation = situationOptionsTrain{s};
    
    % Load Dataset
    TrainingPath = fname;
    DataStruct = load(TrainingPath, situation);
    DataStruct = DataStruct.(situation);
    
    % Initialize arrays
    num_descriptors = 0;
    for i=1:length(DataStruct)
        [rows,cols] = size(DataStruct(i).descriptors);
        num_descriptors = num_descriptors + rows;
    end
    descriptors = zeros(num_descriptors, cols+1);
    labels = zeros(num_descriptors, 2);
    
    j=1;
    for i=1:length(DataStruct)
        object = DataStruct(i);
        filetype = object.file;
        num_descriptors = size(object.descriptors,1);
        descriptors(j:j+num_descriptors-1,2:end) = object.descriptors;
        labels(j:j+num_descriptors-1,2) = object.labels;
        
        % If file type is of simplified dataset, assign 0 to the first
        % column, 1 otherwise
        if strcmp(filetype, 'rectifiedsleepyCombination') || strcmp(filetype, 'rectifiednonSleepyCombination')
            descriptors(j:j+num_descriptors-1,1) = 0;
            labels(j:j+num_descriptors-1:end,1) = 0;
        elseif strcmp(filetype, 'slowBlinkWithNodding') || strcmp(filetype, 'yawning')
            descriptors(j:j+num_descriptors-1,1) = 1;
            labels(j:j+num_descriptors-1,1) = 1;
        end
        j = j + num_descriptors;
    end



    %     V 0.2
    %     % Structs: one field per video type
    %     descriptors_struct = struct;
    %     labels_struct = struct;
    %     for i=1:length(DataStruct)
    %         filetype = DataStruct(i).file;
    %         if ~isfield(descriptors_struct, filetype)
    %             descriptors_struct.(filetype) = [];
    %             labels_struct.(filetype) = [];
    %         end
    %         descriptors_struct.(filetype) = cat(1,descriptors_struct.(filetype),DataStruct(i).descriptors);
    %         labels_struct.(filetype) = cat(1, labels_struct.(filetype),DataStruct(i).labels');
    %     end
    %
    %     % Position of each file type (cummulative sum)
    %     file_types = fieldnames(descriptors_struct);
    %     file_index = struct;
    %     j=1;
    %     for i=1:length(file_types)
    %         file_index.(file_types{i}) = j;
    %         j = j + size(descriptors_struct.(file_types{i}),1);
    %     end
    %
    %     descriptors = [];
    %     labels = [];
    %     for i=1:length(file_types)
    %         descriptors = cat(1,descriptors,descriptors_struct.(file_types{i}));
    %         labels = cat(1,labels,labels_struct.(file_types{i}));
    %     end

    %     V 0.1
    %     % Find index of files for each type of file
    %     FileIndex = struct; % Struct that contains an array with the file indices per file type
    %     for i=1:length(DataStruct)
    %         if ~isfield(FileIndex, DataStruct(i).file)
    %             FileIndex.(DataStruct(i).file) = [];
    %         end
    %         FileIndex.(DataStruct(i).file) = [FileIndex.(DataStruct(i).file) i];
    %     end
    %
    %     % Estimate matrix size
    %     FileTypes = fieldnames(FileIndex);
    %     DescriptorsSize = zeros(1, length(FileTypes));
    %     % Loop over file types
    %     for i=1:numel(fieldnames(FileIndex))
    %         % Loop over files of the same type
    %         numDescriptorsArray = zeros(1,length(FileIndex.(FileTypes{i})));
    %         for j=1:length(FileIndex.(FileTypes{i}))
    %             numDescriptorsArray(j) = size(DataStruct(FileIndex.(FileTypes{i})(j)).descriptors, 1);
    %         end
    %         DescriptorsSize(i) = sum(numDescriptorsArray);
    %     end
    %     DescriptorsLength = size(DataStruct(FileIndex.(FileTypes{1})(1)).descriptors, 2);
    %
    %     % Order descriptors and labels for each file type
    %     Descriptors = zeros(sum(DescriptorsSize), DescriptorsLength);
    %     Labels = zeros(sum(DescriptorsSize),1);
    %     % Loop over file types
    %     index = 1;
    %     for i=1:length(FileTypes)
    %         DescriptorIndex.(FileTypes{i}) = index;
    %         % Loop over files of the same type
    %         for j=1:length(FileIndex.(FileTypes{i}))
    %             % Loop over frames
    %             for k=1:size(DataStruct(FileIndex.(FileTypes{i})(j)).descriptors,1)
    %                 Descriptors(index, :) = DataStruct(FileIndex.(FileTypes{i})(j)).descriptors(k,:);
    %                 Labels(index) = DataStruct(FileIndex.(FileTypes{i})(j)).labels(k);
    %                 index = index + 1;
    %             end
    %         end
    %     end
    y(s).situation = situation;
    y(s).Descriptors = descriptors;%Descriptors;
    y(s).Labels = labels; %Labels;
    %y(s).FileIndices = file_index;%DescriptorIndex;
end
end
