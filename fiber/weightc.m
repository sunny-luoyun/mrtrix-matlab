function newPath = weightc(workPath,subFolder,currentPath,startfloder,fodfolder)
    
    if strcmp(fodfolder,'')
        fodfolder = strrep(startfloder, 'fiber_', '');
    else
    end

    fod = fullfile(workPath,fodfolder,subFolder);

    cmd = sprintf('tcksift2 %s/tracks.tck %s/wmfod_norm_MNI.mif %s/sift_weight.txt -force', ... 
        currentPath,fod,currentPath);
    system(cmd);
    
    newPath = currentPath;

end