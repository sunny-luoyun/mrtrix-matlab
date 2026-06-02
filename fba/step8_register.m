function step8_register(workPath, subList, nlScale, nlNiter)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    templateDir = fullfile(workPath, 'fba', 'template');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'wmfod_norm.mif'), 'file')
            continue;
        end
        maskFile = fullfile(subDir, 'dwi_mask_upsampled.mif');
        if ~exist(maskFile, 'file')
            dwiFile = fullfile(subDir, 'dwi_upsampled.mif');
            if ~exist(dwiFile, 'file')
                dwiFile = fullfile(subDir, 'dwi.mif');
            end
            system(sprintf('dwi2mask %s %s -force', dwiFile, maskFile));
        end
        cmd = sprintf('mrregister %s/wmfod_norm.mif -mask1 %s %s/wmfod_template.mif -nl_warp %s/subject2template_warp.mif %s/template2subject_warp.mif -nl_scale %s -nl_niter %s -force', ...
            subDir, maskFile, templateDir, subDir, subDir, nlScale, nlNiter);
        system(cmd);
    end
end
