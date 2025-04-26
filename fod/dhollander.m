function newpath = dhollander(workPath, subFolder, currentPath,maskedit,wm_fa,wmvoxel,gmvoxel,csfvoxel)
    
    outputpath = fullfile(workPath,'fod_d', subFolder);
    mkdir(outputpath)
    
    sourcefile = fullfile(currentPath,'dwi.mif');
    destinationfile = fullfile(outputpath, 'dwi.mif');

    copyfile(sourcefile,destinationfile);
    
    cmd = sprintf('dwi2response dhollander %s/dwi.mif %s/wm.txt %s/gm.txt %s/csf.txt -erode %d -fa %f -sfwm %f -gm %d -csf %d -force', ... 
        outputpath, outputpath, outputpath, outputpath, maskedit, wm_fa, wmvoxel, gmvoxel, csfvoxel);
    system(cmd);

    newpath = outputpath;

end