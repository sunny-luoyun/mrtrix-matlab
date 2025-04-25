function newpath = denoise(path, name, work)
    denoise = fullfile(work, 'dwimifN',name); 
    mkdir(denoise); % 创建目录
    
    dwidenoise = sprintf('dwidenoise %s/dwi.mif %s/dwi.mif -force', ... 
        path, denoise);
    system(dwidenoise);
    newpath = denoise;
end