function newpath = normal(workPath, currentPath,name)
    maskpath = fullfile(workPath,'mask',name);

    cmd = sprintf('mtnormalise %s/wmfod.mif %s/wmfod_norm.mif %s/csffod.mif %s/csffod_norm.mif -mask %s/mask.mif -force', ... 
        currentPath, currentPath, currentPath, currentPath, maskpath);
    system(cmd);
    
    newpath = currentPath;
end