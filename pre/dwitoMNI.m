function dwitoMNI(name, work)
    
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

    path = fullfile(work, 'pre_b0', name);
    
    % dwi配准到MNI
    T1coreg = sprintf('flirt -in %s/mean_b0.nii.gz -ref %s -dof 6 -out %s/dwi_coreg.nii.gz -omat %s/dwi_to_MNI_fsl.mat', ... 
        path, template_path, dtoM, dtoM);
    system(T1coreg);

    T1coreg = sprintf('transformconvert %s/dwi_to_MNI_fsl.mat %s/mean_b0.nii.gz %s flirt_import %s/dwi_to_MNI_mrtrix.txt -force', ... 
        dtoM, path,template_path, dtoM);
    system(T1coreg);    
end