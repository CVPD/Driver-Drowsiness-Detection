function y = scan_folder(folder)


folder_data = dir(folder);
L=size(folder_data);
for i=1:L(1)
    if strcmp(folder_data(i).name,'.') || strcmp(folder_data(i).name, '..')
        continue
    end
    if folder_data(i).isdir
        subfolder= [folder_data(i).folder '/' folder_data(i).name];
        scan_folder(subfolder);
    else
        fname = [folder_data(i).folder '/' folder_data(i).name];
        split_underscore = strsplit(folder_data(i).name, '_');
        if numel(a) == 3
            % file is a ground truth file
            split_dot = strsplit(split_underscore{3}, '.');
            if strcmp(split_dot{1}, 'drowsiness')
                % file is a drowsiness file
                ground_truth = read_instance(fname, 3);
            end
        else
            split_C = strsplit(split_underscore{1}, 'C');
            if numel(split_C) == 1
            
        %y = read_instance(folder_data(i).name)
    end
end