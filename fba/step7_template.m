function step7_template(workPath, subList, voxelSize)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    templateDir = fullfile(workPath, 'fba', 'template');
    fodInput = fullfile(templateDir, 'fod_input');
    maskInput = fullfile(templateDir, 'mask_input');
    mkdir(fodInput);
    mkdir(maskInput);
    for i = 1:length(subList)
        sub = subList{i};
        fodSrc = fullfile(fbaSubDir, sub, 'wmfod_norm.mif');
        maskSrc = fullfile(fbaSubDir, sub, 'dwi_mask_upsampled.mif');
        if exist(fodSrc, 'file')
            cmd1 = sprintf('ln -sf %s %s/%s.mif', fodSrc, fodInput, sub);
            system(cmd1);
        end
        if exist(maskSrc, 'file')
            cmd2 = sprintf('ln -sf %s %s/%s.mif', maskSrc, maskInput, sub);
            system(cmd2);
        end
    end
    cmd = sprintf('population_template %s -mask_dir %s %s/wmfod_template.mif -voxel_size %s', ...
        fodInput, maskInput, templateDir, voxelSize);
    system(cmd);
end
