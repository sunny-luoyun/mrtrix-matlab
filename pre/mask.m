function mask(path, name, work, startname)
    
    maskpath = fullfile(work, 'mask', name); 
    mkdir(maskpath); % 创建目录

    outputmask = fullfile(work, startname, name);
    
    dwigibbs = sprintf('dwi2mask %s/dwi.mif %s/raw_mask.mif -force', ... 
        outputmask, maskpath);
    system(dwigibbs);
    
    dwigibbs = sprintf('maskfilter %s/raw_mask.mif dilate %s/mask.mif -npass 6 -force', ... 
        maskpath, maskpath);
    system(dwigibbs);

end