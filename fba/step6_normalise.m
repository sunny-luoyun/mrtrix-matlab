function step6_normalise(workPath, subList, csdAlgo)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    isMultiShell = false;
    if strcmp(csdAlgo, 'msmt_csd') && ~isempty(subList)
        sub = subList{1};
        dwiFile = fullfile(fbaSubDir, sub, 'dwi_upsampled.mif');
        if ~exist(dwiFile, 'file')
            dwiFile = fullfile(fbaSubDir, sub, 'dwi.mif');
        end
        if exist(dwiFile, 'file')
            [~, cmdout] = system(sprintf('mrinfo -shell_bvalues %s', dwiFile));
            bvals = sscanf(cmdout, '%f');
            isMultiShell = sum(bvals > 0) >= 2;
        end
    end
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        origMaskFile = fullfile(subDir, 'dwi_mask_upsampled.mif');
        if ~exist(fullfile(subDir, 'wmfod.mif'), 'file')
            continue;
        end
        if ~exist(origMaskFile, 'file')
            dwiFile = fullfile(subDir, 'dwi_upsampled.mif');
            if ~exist(dwiFile, 'file')
                dwiFile = fullfile(subDir, 'dwi.mif');
            end
            system(sprintf('dwi2mask %s %s -force', dwiFile, origMaskFile));
        end
        maskFile = fullfile(subDir, 'dwi_mask_conservative.mif');
        if ~exist(maskFile, 'file')
            system(sprintf('maskfilter %s erode %s -npass 1 -force', origMaskFile, maskFile));
        end
        if strcmp(csdAlgo, 'msmt_csd')
            if isMultiShell
                cmd = sprintf('mtnormalise %s/wmfod.mif %s/wmfod_norm.mif %s/gm.mif %s/gm_norm.mif %s/csf.mif %s/csf_norm.mif -mask %s -force', ...
                    subDir, subDir, subDir, subDir, subDir, subDir, maskFile);
            else
                cmd = sprintf('mtnormalise %s/wmfod.mif %s/wmfod_norm.mif %s/csf.mif %s/csf_norm.mif -mask %s -force', ...
                    subDir, subDir, subDir, subDir, maskFile);
            end
        else
            cmd = sprintf('mtnormalise %s/wmfod.mif %s/wmfod_norm.mif -mask %s -force', ...
                subDir, subDir, maskFile);
        end
        system(cmd);
    end
end
