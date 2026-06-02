function step6_normalise(workPath, subList, csdAlgo)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        maskFile = fullfile(subDir, 'dwi_mask_upsampled.mif');
        if ~exist(fullfile(subDir, 'wmfod.mif'), 'file')
            continue;
        end
        if ~exist(maskFile, 'file')
            dwiFile = fullfile(subDir, 'dwi_upsampled.mif');
            if ~exist(dwiFile, 'file')
                dwiFile = fullfile(subDir, 'dwi.mif');
            end
            system(sprintf('dwi2mask %s %s -force', dwiFile, maskFile));
        end
        if strcmp(csdAlgo, 'msmt_csd')
            cmd = sprintf('mtnormalise %s/wmfod.mif %s/wmfod_norm.mif %s/gm.mif %s/gm_norm.mif %s/csf.mif %s/csf_norm.mif -mask %s -force', ...
                subDir, subDir, subDir, subDir, subDir, subDir, maskFile);
        else
            cmd = sprintf('mtnormalise %s/wmfod.mif %s/wmfod_norm.mif -mask %s -force', ...
                subDir, subDir, maskFile);
        end
        system(cmd);
    end
end
