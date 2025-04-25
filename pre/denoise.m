function [newpath,newstart] = denoise(path, name, work, startname)
    newstart = [startname 'N'];

    denoise = fullfile(work, newstart,name); 
    mkdir(denoise); % 创建目录
    
    dwidenoise = sprintf('dwidenoise %s/dwi.mif %s/dwi.mif -force', ... 
        path, denoise);
    system(dwidenoise);
    
    newpath = denoise;
    
end