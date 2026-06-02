function step11_warp_fod(workPath, subList)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    templateDir = fullfile(workPath, 'fba', 'template');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'subject2template_warp.mif'), 'file')
            continue;
        end
        cmd = sprintf('mrtransform %s/wmfod_norm.mif -warp %s/subject2template_warp.mif -reorient_fod no %s/fod_in_template_space_NOT_REORIENTED.mif -force', ...
            subDir, subDir, subDir);
        system(cmd);
    end
end
