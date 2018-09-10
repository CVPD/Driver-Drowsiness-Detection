function dataset = FusionDescriptors(train_data_COV, train_data_HOG, train_data_LBP)


situation = cell(1,length(train_data_COV));
for i=1:length(train_data_COV)
    situation{i} = train_data_COV(i).situation;
end

dataset = struct;
for i=1:length(situation)
    for j=1:length(train_data_COV)
        if strcmp(situation{i},train_data_COV(j).situation)
            data_COV = train_data_COV(j).descriptors;
            break
        end
    end
    for j=1:length(train_data_HOG)
        if strcmp(situation{i},train_data_HOG(j).situation)
            data_HOG = train_data_HOG(j).descriptors;
            break
        end
    end
    for j=1:length(train_data_LBP)
        if strcmp(situation{i},train_data_LBP(j).situation)
            data_LBP = train_data_LBP(j).descriptors;
            break
        end
    end
    dataset(i).situation = situation{i};
    dataset(i).descriptors = horzcat(data_COV, data_HOG, data_LBP);
    dataset(i).labels = train_data_LBP(j).labels;
end
end
    
            