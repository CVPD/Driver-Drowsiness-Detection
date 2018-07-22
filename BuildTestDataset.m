function [dataset_struct, subject] = BuildTestDataset(fname,varargin)

p = inputParser;
addRequired(p, 'fname', @ischar);
addParameter(p, 'subject', '', @ischar);
addParameter(p,'verbose', true, @islogical);
addParameter(p, 'dataset', [], @isstruct);

parse(p,fname,varargin{:});
subject = p.Results.subject;
dataset = p.Results.dataset;

dataset_struct = struct;
k=1;
% Load Dataset
if isempty(dataset)
    dataset= load(fname);
end
fields = fieldnames(dataset);
for s=1:numel(fields)
    if isstruct(dataset.(fields{s}))
        situation = fields{s};
        if isempty(subject)
            DataStruct = dataset.(situation);
        else
            for i=1:length(dataset.(situation))
                if strcmp(subject,dataset.(situation)(i).subject)
                    DataStruct = dataset.(situation)(i);
                    break
                end
            end
        end
        
        % Initialize arrays
        num_descriptors = 0;
        for i=1:length(DataStruct)
            [rows,cols] = size(DataStruct(i).descriptors);
            num_descriptors = num_descriptors + rows;
        end
        descriptors = zeros(num_descriptors, cols);
        labels = zeros(num_descriptors, 1);
        
        j=1;
        for i=1:length(DataStruct)
            object = DataStruct(i);
            num_descriptors = size(object.descriptors,1);
            descriptors(j:j+num_descriptors-1,:) = object.descriptors(1:num_descriptors,:);
            labels(j:j+num_descriptors-1) = object.labels(1:num_descriptors);
            
            j = j + num_descriptors;
        end
        if strcmp(situation, 'nightnoglasses')
            situation = 'night_noglasses';
        end
        dataset_struct(k).situation = situation;
        dataset_struct(k).Descriptors = descriptors;
        dataset_struct(k).Labels = labels;
        k = k+1;
    end
end
dataset_aux = struct();
% Sort situations according to training dataset
dataset_aux = dataset_struct(1);
dataset_aux(2) = dataset_struct(3);
dataset_aux(3) = dataset_struct(2);
dataset_aux(4) = dataset_struct(4);
dataset_aux(5) = dataset_struct(5);
dataset_struct = dataset_aux;
end
