function newpath = tax(workPath, subFolder, currentPath,peak_ratio, max_iters,convergence)
    
    outputpath = fullfile(workPath,'fod_ta', subFolder);
    mkdir(outputpath)

    sourcefile = fullfile(currentPath,'dwi.mif');
    destinationfile = fullfile(outputpath, 'dwi.mif');

    copyfile(sourcefile,destinationfile);
    
    cmd = sprintf('dwi2response tax %s/dwi.mif %s/resp.txt -peak_ratio %f -max_iters %d -convergence %d -force', ... 
        outputpath, outputpath,peak_ratio,max_iters,convergence);
    system(cmd);

    newpath = outputpath;

end