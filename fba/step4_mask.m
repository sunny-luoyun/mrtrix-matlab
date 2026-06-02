function step4_mask(workPath, subList)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
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
        cmd = sprintf('dwi2mask %s %s/dwi_mask_upsampled.mif -force', ...
            dwiFile, subDir);
        system(cmd);
    end
end
