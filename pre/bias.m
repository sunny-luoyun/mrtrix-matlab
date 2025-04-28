function [newpath,newstart] = bias(path, name, work, startname)
    newstart = [startname 'B'];

    bi = fullfile(work, newstart, name); 
    mkdir(bi); % 创建目录
    
    dwibi = sprintf('dwibiascorrect ants %s/dwi.mif %s/dwi.mif -force', ... 
        path, bi);
    system(dwibi);
    
    newpath = bi;
   
end