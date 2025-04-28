function newpath = tournier(workPath, subFolder, currentPath, number,iter_voxel,max_iters)
    
    outputpath = fullfile(workPath,'fod_to', subFolder);
    mkdir(outputpath)

    sourcefile = fullfile(currentPath,'dwi.mif');
    destinationfile = fullfile(outputpath, 'dwi.mif');

    copyfile(sourcefile,destinationfile);
    
    cmd = sprintf('dwi2response tournier %s/dwi.mif %s/resp.txt -number %d -iter_voxels %d -max_iters %d -force', ... 
        outputpath, outputpath,number,iter_voxel,max_iters);
    system(cmd);

    newpath = outputpath;

end