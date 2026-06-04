function newPath = weightc(workPath, subFolder, currentPath, startfloder, fodfolder)
    
    if strcmp(fodfolder,'')
        fodfolder = strrep(startfloder, 'fiber_', '');
    end

    fod = fullfile(workPath, fodfolder, subFolder);

    fodfile = pickFODfile(fod);

    cmd = sprintf('tcksift2 %s/tracks.tck %s/%s %s/sift_weight.txt -force', ...
        currentPath, fod, fodfile, currentPath);
    system(cmd);
    
    newPath = currentPath;

end

function fodfile = pickFODfile(fod)
    candidates = {'wmfod_norm_MNI.mif', 'fod_norm_MNI.mif'};
    for fc = 1:length(candidates)
        if exist(fullfile(fod, candidates{fc}), 'file')
            fodfile = candidates{fc};
            return;
        end
    end
    error('未找到 FOD 文件，请确认已执行 FOD 计算和配准步骤 (需 %s)', strjoin(candidates, ' / '));
end