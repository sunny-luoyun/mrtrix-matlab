function step12_fd(workPath, subList, fmlsPeak)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    templateDir = fullfile(workPath, 'fba', 'template');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'fod_in_template_space_NOT_REORIENTED.mif'), 'file')
            continue;
        end
        cmd = sprintf('fod2fixel -mask %s/template_mask.mif %s/fod_in_template_space_NOT_REORIENTED.mif %s/fixel_in_template_space_NOT_REORIENTED -afd fd.mif -fmls_peak_value %f -force', ...
            templateDir, subDir, subDir, fmlsPeak);
        system(cmd);
    end
end
