function dwitoMNI(name, work,startname)
    bi = fullfile(work,startname,name);
    
    % 获取当前脚本的完整路径
    current_script_path = mfilename('fullpath');
    
    % 获取当前脚本所在的目录
    [current_dir, ~, ~] = fileparts(current_script_path);
    
    % 获取当前脚本所在目录的上一级目录
    parent_dir = fileparts(current_dir);
    
    % 构建相对路径
    template_path = fullfile(parent_dir, 'Templates', 'MNI152.nii.gz');
    
    dtoM = fullfile(work, 'dwi_coreg', name); 
    mkdir(dtoM); % 创建目录

    b0 = fullfile(work, 'pred_b0',name); 
    mkdir(b0); 

    dwib0 = sprintf('dwiextract %s/dwi.mif - -bzero | mrmath - mean %s/mean_b0.mif -axis 3 -force', ... 
        bi, b0);
    system(dwib0);

    dwib0 = sprintf('mrconvert %s/mean_b0.mif %s/mean_b0.nii.gz -force', ... 
        b0, b0);
    system(dwib0);
    
    % dwi配准到MNI
    T1coreg = sprintf('flirt -in %s/mean_b0.nii.gz -ref %s -dof 6 -out %s/dwi_coreg.nii.gz -omat %s/dwi_to_MNI_fsl.mat', ... 
        b0, template_path, dtoM, dtoM);
    system(T1coreg);

    T1coreg = sprintf('transformconvert %s/dwi_to_MNI_fsl.mat %s/mean_b0.nii.gz %s flirt_import %s/dwi_to_MNI_mrtrix.txt -force', ... 
        dtoM, b0,template_path, dtoM);
    system(T1coreg);    
end