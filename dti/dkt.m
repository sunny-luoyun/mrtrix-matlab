function dkt(name, work, startname)

    inputmaskpath = fullfile(work, 'mask', name); 
    inputdwipath = fullfile(work, startname, name);
    outputpath = fullfile(work,'tensor', name, 'dkt');
    mkdir(outputpath)
    
    cmd = sprintf('dwi2tensor -mask %s/mask.mif -dkt %s/dkt.mif %s/dwi.mif %s/dt.mif  -force', ... 
        inputmaskpath, outputpath, inputdwipath, outputpath);
    system(cmd);
    
end