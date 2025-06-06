% 格式转换，将nii.gz以及nii格式转化为mrtrix可处理的mif格式

function [newPath, newstart] = change_format(path, name, work)
    dwimif = fullfile(work, 'dwimif',name); 
    mkdir(dwimif); % 创建目录

    % dwi转换
    dwiformat = sprintf('mrconvert -fslgrad %s/%sdwi.bvec %s/%sdwi.bval %s/%sdwi.nii.gz %s/dwi.mif -force', ... 
        path, name, path, name, path, name, dwimif);
    system(dwiformat);

    T1mif = fullfile(work, 'T1mif',name); 
    mkdir(T1mif); % 创建目录
    
    % T1转换
    T1format = sprintf('mrconvert %s/%sT1.nii.gz %s/T1.mif -force', ... 
        path, name, T1mif);
    system(T1format);

    newPath = dwimif;
    newstart = 'dwimif';
end

