function newPath = sift(workPath, subFolder, currentPath, startfloder, fodfolder, decnum)
    
    if strcmp(fodfolder,'')
        fodfolder = strrep(startfloder, 'fiber_', '');
    end

    fod = fullfile(workPath, fodfolder, subFolder);

    fodfile = pickFODfile(fod);

    cmd = sprintf('tcksift -act %s/T1_corg/%s/5tt_in_dwi.mif -term_number %s %s/tracks.tck %s/%s %s/tracks_sift.tck -force', ...
        workPath, subFolder, decnum, currentPath, fod, fodfile, currentPath);
    system(cmd);
    
    newPath = currentPath;

end

function fodfile = pickFODfile(fod)
    candidates = {'wmfod_norm.mif', 'fod_norm.mif'};
    for fc = 1:length(candidates)
        if exist(fullfile(fod, candidates{fc}), 'file')
            fodfile = candidates{fc};
            return;
        end
    end
    error('未找到 FOD 文件，请确认已执行 FOD 计算步骤 (需 %s)', strjoin(candidates, ' / '));
end