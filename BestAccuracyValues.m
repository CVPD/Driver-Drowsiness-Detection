function [y] = BestAccuracyValues(results)

L = length(results);
y = struct;
for i=1:L
    y(i).situation = results(i).situation;
    [y(i).best_fisher , maxIndex] = max(results(i).TestAccuracy(:));
    [idxMaxRow, idxMaxCol] = ind2sub(size(results(i).TestAccuracy), maxIndex);
    y(i).best_fisher_index = results(i).FisherPerc(idxMaxRow);
    y(i).best_fisher_gamma = results(i).kernelScale(idxMaxCol);
    
    if isfield(results(i), 'tunedTestAccuracy')
        [y(i).best_box_constraint , maxIndex] = max(results(i).tunedTestAccuracy(:));
        [idxMaxRow, idxMaxCol] = ind2sub(size(results(i).tunedTestAccuracy), maxIndex);
        y(i).best_box_constraint_index = results(i).BoxConstraint(idxMaxRow);
        y(i).best_box_constraint_gamma = results(i).tunedKernelScale(idxMaxCol);
    end
    
end
