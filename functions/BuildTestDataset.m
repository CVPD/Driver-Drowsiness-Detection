function [dataset_struct, excluded_dataset] = BuildTestDataset(fname,varargin)
%Builds a dataset from a file created by PreprocessDataset
%   [dataset_struct, excluded_dataset] = BuildTestDataset(fname, varargin)   
%
%   Name-Value paired arguments:
%    - subject_exclusion_list: array with subjects to be excluded in the
%      dataset. For example: [1,4,5]
%    - dataset: preloaded dataset if it is already in the workspace
%
%   Output:
%    - dataset_struct: struct with fields situation, descriptors, labels.
%       All descriptors and labels from every subject in the dataset are
%       vertically concatenated for each situation.
%    - excluded_dataset: struct with fields situation, descriptors, labels.
%       All descriptors and labels from every subject in the dataset are
%       vertically concatenated for each situation.

p = inputParser;
validate_fname = @(f) exist(f, 'file') == 2 && ischar(f);

addRequired(p, 'fname', validate_fname);
addParameter(p, 'subject_exclusion_list', [], @isvector);
addParameter(p, 'dataset', []);

parse(p,fname,varargin{:});
subject_exclusion_list = p.Results.subject_exclusion_list;

dataset_struct = struct;
excluded_dataset = struct;

% Load Dataset
if isempty(p.Results.dataset)
    dataset = load(fname);
else
    dataset = p.Results.dataset;
end
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
    descriptors = zeros(num_descriptors, cols);
    labels = zeros(num_descriptors, 1);
    descriptors_excluded = zeros(num_descriptors_exluded, cols);
    labels_excluded = zeros(num_descriptors_exluded, 1);
    
    % Fill arrays with data
    j = 1;
    k = 1;
    for i=1:length(data_situation)
        subject = data_situation(i).subject;
        object = data_situation(i);
        num_descriptors = size(object.descriptors,1);
        % Check if current subject is to be excluded. Do not process it in
        % that case
        if ~isempty(find(subject_exclusion_list == str2double(subject),1))
            descriptors_excluded(k:k+num_descriptors-1,:) = object.descriptors(1:num_descriptors,:);
            labels_excluded(k:k+num_descriptors-1) = object.labels(1:num_descriptors);
            k = k + num_descriptors;
        else
            descriptors(j:j+num_descriptors-1,:) = object.descriptors(1:num_descriptors,:);
            labels(j:j+num_descriptors-1) = object.labels(1:num_descriptors);
            j = j + num_descriptors;
        end
    end
    
    excluded_dataset(s).situation = situation;
    excluded_dataset(s).descriptors = descriptors_excluded;
    excluded_dataset(s).labels = labels_excluded;
    
    dataset_struct(s).situation = situation;
    dataset_struct(s).descriptors = descriptors;
    dataset_struct(s).labels = labels;
    
end
dataset_aux = struct();
dataset_excluded_aux = struct();
% Sort situations according to training dataset
dataset_aux = dataset_struct(1);
dataset_aux(2) = dataset_struct(3);
dataset_aux(3) = dataset_struct(2);
dataset_aux(4) = dataset_struct(4);
dataset_aux(5) = dataset_struct(5);

dataset_excluded_aux = excluded_dataset(1);
dataset_excluded_aux(2) = excluded_dataset(3);
dataset_excluded_aux(3) = excluded_dataset(2);
dataset_excluded_aux(4) = excluded_dataset(4);
dataset_excluded_aux(5) = excluded_dataset(5);

dataset_struct = dataset_aux;
excluded_dataset = dataset_excluded_aux;
end
