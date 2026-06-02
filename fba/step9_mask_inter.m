function step9_mask_inter(workPath, subList)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    templateDir = fullfile(workPath, 'fba', 'template');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'subject2template_warp.mif'), 'file')
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
        cmd = sprintf('mrtransform %s -warp %s/subject2template_warp.mif -interp nearest -datatype bit %s/dwi_mask_in_template_space.mif -force', ...
            maskFile, subDir, subDir);
        system(cmd);
    end
    maskList = '';
    for i = 1:length(subList)
        sub = subList{i};
        maskFile = fullfile(fbaSubDir, sub, 'dwi_mask_in_template_space.mif');
        if exist(maskFile, 'file')
            maskList = sprintf('%s %s', maskList, maskFile);
        end
    end
    cmd = sprintf('mrmath %s min %s/template_mask.mif -datatype bit -force', ...
        maskList, templateDir);
    system(cmd);
end
