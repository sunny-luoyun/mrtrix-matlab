function newPath = sift(workPath,subFolder,currentPath,startfloder,fodfolder,decnum)
    
    if strcmp(fodfolder,'')
        fodfolder = strrep(startfloder, 'fiber_', '');
    else
    end

    fod = fullfile(workPath,fodfolder,subFolder);

    cmd = sprintf('tcksift -act %s/T1_corg/%s/5tt_coreg.mif -term_number %s %s/tracks.tck %s/wmfod_norm_MNI.mif %s/tracks_sift.tck -force', ... 
        workPath,subFolder,decnum,currentPath,fod,currentPath);
    system(cmd);
    
    newPath = currentPath;

end