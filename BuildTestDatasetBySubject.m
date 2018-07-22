function dataset = BuildTestDatasetBySubject(fname)

dataset = load(fname,'glasses');

subjects = cell(1, length(dataset.glasses));
for i=1:length(dataset.glasses)
    subjects{i} = dataset.glasses(i).subject;
end

dataset = struct([]);
for i=1:length(subjects)
    if isempty(dataset)
        dataset = BuildTestDataset(fname, 'subject', subjects{i});
        dataset = struct('subject', subjects{i}, 'data', dataset);
    else
        dataset(i).subject = subjects{i};
        dataset(i).data = BuildTestDataset(fname, 'subject', subjects{i});
    end
end
end
