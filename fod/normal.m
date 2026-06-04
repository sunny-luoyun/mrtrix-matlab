function newpath = normal(workPath, currentPath, name, isMulti)
    maskpath = fullfile(workPath,'mask',name);

    if isMulti
        cmd = sprintf('mtnormalise %s/wmfod.mif %s/wmfod_norm.mif %s/csffod.mif %s/csffod_norm.mif -mask %s/mask.mif -force', ...
            currentPath, currentPath, currentPath, currentPath, maskpath);
        system(cmd);
    else
        cmd = sprintf('mtnormalise %s/fod.mif %s/fod_norm.mif -mask %s/mask.mif -force', ...
            currentPath, currentPath, maskpath);
        system(cmd);
    end

    newpath = currentPath;
end