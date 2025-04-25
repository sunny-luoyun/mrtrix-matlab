% 格式转换，将nii.gz以及nii格式转化为mrtrix可处理的mif格式

function change_format(path, name, work)
    rawmif = fullfile(work, 'rawmif',name); 
    mkdir(rawmif); % 创建目录

    % dwi转换
    dwiformat = sprintf('mrconvert -fslgrad %s/%sdwi.bvec %s/%sdwi.bval %s/%sdwi.nii.gz %s/%sdwi_raw.mif -force', ... 
        path, name, path, name, path, name, rawmif, name);
    system(dwiformat);
    
    % T1转换
    T1format = sprintf('mrconvert %s/%sT1.nii.gz %s/%sT1_raw.mif -force', ... 
        path, name, rawmif, name);
    system(T1format);
end

