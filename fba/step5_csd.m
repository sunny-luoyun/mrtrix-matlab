function step5_csd(workPath, subList, csdAlgo)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    fbaDir = fullfile(workPath, 'fba');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        dwiFile = fullfile(subDir, 'dwi_upsampled.mif');
        if ~exist(dwiFile, 'file')
            dwiFile = fullfile(subDir, 'dwi.mif');
        end
        if ~exist(dwiFile, 'file')
            continue;
        end
        maskFile = fullfile(subDir, 'dwi_mask_upsampled.mif');
        if ~exist(maskFile, 'file')
            system(sprintf('dwi2mask %s %s -force', dwiFile, maskFile));
        end
        if strcmp(csdAlgo, 'msmt_csd')
            cmd = sprintf('dwi2fod msmt_csd %s %s/group_average_response_wm.txt %s/wmfod.mif %s/group_average_response_gm.txt %s/gm.mif %s/group_average_response_csf.txt %s/csf.mif -mask %s -force', ...
                dwiFile, fbaDir, subDir, fbaDir, subDir, fbaDir, subDir, maskFile);
        else
            cmd = sprintf('dwi2fod csd %s %s/group_average_response_wm.txt %s/wmfod.mif -mask %s -force', ...
                dwiFile, fbaDir, subDir, maskFile);
        end
        system(cmd);
    end
end
