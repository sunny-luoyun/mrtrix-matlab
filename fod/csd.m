function newpath = csd(currentPath)
    
    cmd = sprintf('dwi2fod csd %s/dwi.mif %s/resp.txt %s/fod.mif -force', ... 
        currentPath, currentPath, currentPath);
    system(cmd);
    
    newpath = currentPath;
end