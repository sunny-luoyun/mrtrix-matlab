function [newpath,newstart] = bias(path, name, work, startname)
    newstart = [startname 'B'];

    bi = fullfile(work, newstart, name); 
    mkdir(bi); % 创建目录
    
    dwibi = sprintf('dwibiascorrect ants %s/dwi.mif %s/dwi.mif -force', ... 
        path, bi);
    system(dwibi);
    
    newpath = bi;

    b0 = fullfile(work, 'pre_b0',name); 
    mkdir(b0); 

    dwib0 = sprintf('dwiextract %s/dwi.mif - -bzero | mrmath - mean %s/mean_b0.mif -axis 3 -force', ... 
        bi, b0);
    system(dwib0);

    dwib0 = sprintf('mrconvert %s/mean_b0.mif %s/mean_b0.nii.gz -force', ... 
        b0, b0);
    system(dwib0);
   
end