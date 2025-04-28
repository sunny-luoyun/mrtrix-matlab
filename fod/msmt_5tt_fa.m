function newpath = msmt_5tt_fa(workPath, subFolder, currentPath,wm_fa, voxel,farange)
    
    outputpath = fullfile(workPath,'fod_mfa', subFolder);
    mkdir(outputpath)

    tt_file = fullfile(workPath, 'T1_corg', subFolder);

    sourcefile = fullfile(currentPath,'dwi.mif');
    destinationfile = fullfile(outputpath, 'dwi.mif');

    copyfile(sourcefile,destinationfile);
    
    cmd = sprintf('dwi2response msmt_5tt %s/dwi.mif %s/5tt.mif %s/wm.txt %s/gm.txt %s/csf.txt -fa %f -pvf %f -wm_algo fa -sfwm_fa_threshold %s -force', ... 
        outputpath, tt_file,outputpath,outputpath,outputpath, wm_fa, voxel, farange);
    system(cmd);

    newpath = outputpath;

end