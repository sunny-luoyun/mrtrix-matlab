function step13_reorient(workPath, subList)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'fixel_in_template_space_NOT_REORIENTED'), 'dir')
            continue;
        end
        cmd = sprintf('fixelreorient %s/fixel_in_template_space_NOT_REORIENTED %s/subject2template_warp.mif %s/fixel_in_template_space -force', ...
            subDir, subDir, subDir);
        system(cmd);
    end
end
