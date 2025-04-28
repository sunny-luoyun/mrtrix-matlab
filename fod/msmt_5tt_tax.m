function newpath = msmt_5tt_tax(workPath, subFolder, currentPath,wm_fa, voxel)
    
    outputpath = fullfile(workPath,'fod_mta', subFolder);
    mkdir(outputpath)

    tt_file = fullfile(workPath, 'T1_corg', subFolder);

    sourcefile = fullfile(currentPath,'dwi.mif');
    destinationfile = fullfile(outputpath, 'dwi.mif');

    copyfile(sourcefile,destinationfile);
    
    cmd = sprintf('dwi2response msmt_5tt %s/dwi.mif %s/5tt.mif %s/wm.txt %s/gm.txt %s/csf.txt -fa %f -pvf %f -wm_algo tax -force', ... 
        outputpath, tt_file,outputpath,outputpath,outputpath, wm_fa, voxel);
    system(cmd);

    newpath = outputpath;

end