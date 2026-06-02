function step3_upsample(workPath, subList, voxelSize)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'dwi.mif'), 'file')
            continue;
        end
        cmd = sprintf('mrgrid %s/dwi.mif regrid -vox %s %s/dwi_upsampled.mif -force', ...
            subDir, voxelSize, subDir);
        system(cmd);
    end
end
