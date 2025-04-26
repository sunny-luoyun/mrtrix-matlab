function newpath = msmt(currentPath)
    
    cmd = sprintf('dwi2fod msmt_csd %s/dwi.mif %s/wm.txt %s/wmfod.mif %s/gm.txt %s/gmfod.mif %s/csf.txt %s/csffod.mif -force', ... 
        currentPath, currentPath, currentPath, currentPath, currentPath, currentPath, currentPath);
    system(cmd);
    
    newpath = currentPath;
end