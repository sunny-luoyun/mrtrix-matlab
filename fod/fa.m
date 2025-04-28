function newpath = fa(workPath, subFolder, currentPath,maskedit,maxfa)
    
    outputpath = fullfile(workPath,'fod_f', subFolder);
    mkdir(outputpath)

    sourcefile = fullfile(currentPath,'dwi.mif');
    destinationfile = fullfile(outputpath, 'dwi.mif');

    copyfile(sourcefile,destinationfile);
    
    cmd = sprintf('dwi2response fa %s/dwi.mif %s/resp.txt -erode %d -number %d -force', ... 
        outputpath, outputpath, maskedit, maxfa);
    system(cmd);

    newpath = outputpath;

end