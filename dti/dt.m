function dt(name, work, startname)

    inputmaskpath = fullfile(work, 'mask', name); 
    inputdwipath = fullfile(work, startname, name);
    outputpath = fullfile(work,'tensor', name);
    mkdir(outputpath)
    
    cmd = sprintf('dwi2tensor -mask %s/mask.mif %s/dwi.mif %s/dt.mif -force', ... 
        inputmaskpath, inputdwipath, outputpath);
    system(cmd);
    
end