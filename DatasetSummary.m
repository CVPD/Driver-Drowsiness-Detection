function subject_summary = DatasetSummary(fname, varargin)

if exist(fname, 'file') ~= 2
    error('file does not exist');
end

p = inputParser;
addRequired(p, 'fname', @ischar);
addParameter(p, 'dataset', []);

parse(p,fname,varargin{:});


if isempty(p.Results.dataset)
    dataset = load(fname);
else
    dataset = p.Results.dataset;
end

dataset = rmfield(dataset, 'subsampling_rate');% Do not process field subsampling_rate
fields = fieldnames(dataset);

% Find number of subjects in dataset
situation = fields{1};
data_situation = dataset.(situation);
subject_list = [];
for i=1:length(data_situation)
    subject = str2double(data_situation(i).subject);
    if isempty(find(subject_list==subject))
        if isempty(subject_list)
            subject_list(1) = subject;
        else
            subject_list(end+1) = subject;
        end
    end
end

subject_summary = cell(length(subject_list)+1,numel(fields)+1);
subject_summary{1,1} = 'subject';

% Loop over situations
for s=1:numel(fields)
    situation = fields{s};
    data_situation = dataset.(situation);
    % Loop over subjects
    for k=1:length(subject_list)
        num_descriptors = 0;
        % Loop over videos
        for i=1:length(data_situation)
            subject = str2double(data_situation(i).subject);
            if subject == subject_list(k)
                [rows,cols] = size(data_situation(i).descriptors);
                num_descriptors = num_descriptors + rows;
            end
        end
        subject_summary{k+1,1} = subject_list(k);
        subject_summary{1,s+1} = situation;
        subject_summary{k+1,s+1} = num_descriptors;
    end
end

