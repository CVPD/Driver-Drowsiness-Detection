function [dataset_struct, excluded_dataset] = BuildTrainDataset(fname, varargin)
%Builds a dataset from a file created by PreprocessDataset
%   [dataset_struct, excluded_dataset] = BuildTrainDataset(fname, varargin)   
%
%   Name-Value paired arguments:
%    - subject_exclusion_list: array with subjects to be excluded in the
%      dataset. For example: [1,4,5]
%    - dataset: preloaded dataset if it is already in the workspace
%    - situation_choice: pairwise cell with situation name and type of dataset 
%        for that situation (complete -1-, incomplete -0-). If no situation is detailed,
%        default choice for that situation is -complete-. For example:
%        {'glasses', 0;'sunglasses', 0}
%
%   Output:
%    - dataset_struct: struct with fields situation, descriptors, labels.
%       All descriptors and labels from every subject in the dataset are
%       vertically concatenated for each situation.
%    - excluded_dataset: 

p = inputParser;
validate_fname = @(f) exist(f, 'file') == 2 && ischar(f);

addRequired(p, 'fname', validate_fname);
addParameter(p, 'subject_exclusion_list', [], @isvector);
addParameter(p, 'dataset', []);
addParameter(p, 'situation_choice', {}, @iscell);

parse(p,fname,varargin{:});

subject_exclusion_list = p.Results.subject_exclusion_list;
situation_choice = p.Results.situation_choice;

if isempty(p.Results.dataset)
    dataset = load(fname);
else
    dataset = p.Results.dataset;
end

dataset_struct = struct;
excluded_dataset = struct;
dataset = rmfield(dataset, 'subsampling_rate');% Do not process field subsampling_rate
fields = fieldnames(dataset);
for s=1:numel(fields)
    
    situation = fields{s};
    data_situation = dataset.(situation);
    
    % Initialize arrays
    num_descriptors = 0;
    num_descriptors_exluded = 0;
    for i=1:length(data_situation)
        subject = data_situation(i).subject;
        % Check if current subject is to be excluded. Do not process it in
        % that case
        if ~isempty(find(subject_exclusion_list == str2double(subject),1))
            [rows,cols] = size(data_situation(i).descriptors);
            num_descriptors_exluded = num_descriptors_exluded + rows;
        else
            [rows,cols] = size(data_situation(i).descriptors);
            num_descriptors = num_descriptors + rows;
        end
    end
    descriptors = zeros(num_descriptors, cols+1);
    labels = zeros(num_descriptors, 2);
    descriptors_excluded = zeros(num_descriptors_exluded, cols+1);
    labels_excluded = zeros(num_descriptors_exluded, 2);
    
    % Fill arrays with data
    j = 1;
    k = 1;
    for i=1:length(data_situation)
        subject = data_situation(i).subject;
        object = data_situation(i);
        filetype = object.file;
        num_descriptors = size(object.descriptors,1);
        % Check if current subject is to be excluded. Do not process it in
        % that case
        if ~isempty(find(subject_exclusion_list == str2double(subject),1))
            descriptors_excluded(k:k+num_descriptors-1,2:end) = object.descriptors(1:num_descriptors,:);
            labels_excluded(k:k+num_descriptors-1,2) = object.labels(1:num_descriptors);
            
            % If file type is of incomplete dataset, assign 0 to the first
            % column, 1 otherwise
            if strcmp(filetype, 'rectifiedsleepyCombination') || strcmp(filetype, 'rectifiednonSleepyCombination')
                descriptors_excluded(k:k+num_descriptors-1,1) = 0;
                labels_excluded(k:k+num_descriptors-1,1) = 0;
            elseif strcmp(filetype, 'slowBlinkWithNodding') || strcmp(filetype, 'yawning')
                descriptors_excluded(k:k+num_descriptors-1,1) = 1;
                labels_excluded(k:k+num_descriptors-1,1) = 1;
            end
            k = k + num_descriptors;
        else
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
        excluded_dataset(s).situation = situation;
        excluded_dataset(s).descriptors = descriptors_excluded(:, 2:end);
        excluded_dataset(s).labels = labels_excluded(:,2);
        
        dataset_struct(s).situation = situation;
        dataset_struct(s).descriptors = descriptors(:, 2:end);
        dataset_struct(s).labels = labels(:,2);
    else
        excluded_dataset(s).situation = situation;
        excluded_dataset(s).descriptors = descriptors_excluded(descriptors_excluded(:,1)==0, 2:end);
        excluded_dataset(s).labels = labels_excluded(labels_excluded(:,1)==0,2);
        
        dataset_struct(s).situation = situation;
        dataset_struct(s).descriptors = descriptors(descriptors(:,1)==0, 2:end);
        dataset_struct(s).labels = labels(labels(:,1)==0,2);
    end
end

