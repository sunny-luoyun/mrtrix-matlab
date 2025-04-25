function T1toMNI(name, work)
    
    % 获取当前脚本的完整路径
    current_script_path = mfilename('fullpath');
    
    % 获取当前脚本所在的目录
    [current_dir, ~, ~] = fileparts(current_script_path);
    
    % 获取当前脚本所在目录的上一级目录
    parent_dir = fileparts(current_dir);
    
    % 构建相对路径
    template_path = fullfile(parent_dir, 'Templates', 'MNI152.nii.gz');
    
    TtoM = fullfile(work, 'T1_coreg', name); 
    mkdir(TtoM); % 创建目录

    path = fullfile(work, 'T1mif', name);
    % T1转换格式
    T1coreg = sprintf('mrconvert %s/T1.mif %s/T1.nii.gz -force', ... 
        path, path);
    system(T1coreg);
    
    % T1配准到MNI
    T1coreg = sprintf('flirt -in %s/T1.nii.gz -ref %s -dof 12 -out %s/T1_coreg.nii.gz -omat %s/T1_to_MNI_fsl.mat', ... 
        path, template_path, TtoM, TtoM);
    system(T1coreg);

    T1coreg = sprintf('transformconvert %s/T1_to_MNI_fsl.mat %s/T1.nii.gz %s flirt_import %s/T1_to_MNI_mrtrix.txt -force', ... 
        TtoM, path,template_path, TtoM);
    system(T1coreg);    
end