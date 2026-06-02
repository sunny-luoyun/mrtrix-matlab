function step14_corresp(workPath, subList)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    templateDir = fullfile(workPath, 'fba', 'template');
    fdDir = fullfile(templateDir, 'fd');
    mkdir(fdDir);
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'fixel_in_template_space', 'fd.mif'), 'file')
            continue;
        end
        cmd = sprintf('fixelcorrespondence %s/fixel_in_template_space/fd.mif %s/fixel_mask %s %s.mif -force', ...
            subDir, templateDir, fdDir, sub);
        system(cmd);
    end
end
