function dataset_struct = BuildTrainDatasetBySubject(fname, varargin)

if exist(fname, 'file') ~= 2
    error('file does not exist');
end

p = inputParser;
addRequired(p, 'fname', @ischar);
addParameter(p, 'subject_list', [], @isvector);
addParameter(p, 'dataset', []);
addParameter(p, 'situation_choice', {}, @iscell);

parse(p,fname,varargin{:});

subject_list = p.Results.subject_list;
situation_choice = p.Results.situation_choice;

if isempty(p.Results.dataset)
    dataset = load(fname);
else
    dataset = p.Results.dataset;
end

dataset_struct = struct;
dataset = rmfield(dataset, 'subsampling_rate');% Do not process field subsampling_rate
fields = fieldnames(dataset);
for s=1:numel(fields)
    
    situation = fields{s};
    data_situation = dataset.(situation);
    
    % Initialize arrays
    num_descriptors = 0;
    for i=1:length(data_situation)
        subject = data_situation(i).subject;
        % Check if current subject is to be excluded. Do not process it in
        % that case
        if ~isempty(find(subject_list == str2double(subject),1))
            continue
        end
        [rows,cols] = size(data_situation(i).descriptors);
        num_descriptors = num_descriptors + rows;
    end
    descriptors = zeros(num_descriptors, cols+1);
    labels = zeros(num_descriptors, 2);

    % Fill arrays with data
    j=1;
    for i=1:length(data_situation)
        subject = data_situation(i).subject;
        % Check if current subject is to be excluded. Do not process it in
        % that case
        if ~isempty(find(subject_list == str2double(subject),1))
            continue
        end
        object = data_situation(i);
        filetype = object.file;
        num_descriptors = size(object.descriptors,1);
        descriptors(j:j+num_descriptors-1,2:end) = object.descriptors(1:num_descriptors,:);
        labels(j:j+num_descriptors-1,2) = object.labels(1:num_descriptors);
        
        % If file type is of incomplete dataset, assign 0 to the first
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
    
    % Select dataset type (complete=1, incomplete=0) depending on input
    % parameter situation_choice. Default selection is complete data
    if isempty(situation_choice)
        dataset_type = 1;
    else
        % Find if there is a choice over current situation
        situation_choice_index = strfind(situation_choice(:,1), situation);
        situation_choice_index = cell2mat(situation_choice_index);
        if situation_choice_index==1
            dataset_type = situation_choice{situation_choice_index==1, 2};
        else
            dataset_type = 1;
        end
    end
    
    if dataset_type
        dataset_struct(s).situation = situation;
        dataset_struct(s).Descriptors = descriptors(:, 2:end);
        dataset_struct(s).Labels = labels(:,2);
    else
        dataset_struct(s).situation = situation;
        dataset_struct(s).Descriptors = descriptors(descriptors(:,1)==0, 2:end);
        dataset_struct(s).Labels = labels(labels(:,1)==0,2);
    end
end

