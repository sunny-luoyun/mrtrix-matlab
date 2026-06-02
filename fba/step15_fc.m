function step15_fc(workPath, subList)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    templateDir = fullfile(workPath, 'fba', 'template');
    fcDir = fullfile(templateDir, 'fc');
    mkdir(fcDir);
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'subject2template_warp.mif'), 'file')
            continue;
        end
        cmd = sprintf('warp2metric %s/subject2template_warp.mif -fc %s/fixel_mask %s %s.mif -force', ...
            subDir, templateDir, fcDir, sub);
        system(cmd);
    end
end
