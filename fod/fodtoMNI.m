function fodtoMNI(workPath,name,currentPath)
    % 获取当前脚本的完整路径
    current_script_path = mfilename('fullpath');
    
    % 获取当前脚本所在的目录
    [current_dir, ~, ~] = fileparts(current_script_path);
    
    % 获取当前脚本所在目录的上一级目录
    parent_dir = fileparts(current_dir);
    
    % 构建相对路径
    template_path = fullfile(parent_dir, 'Templates', 'MNI152.nii.gz');

    warppath = fullfile(workPath,'dwi_coreg',name);

    cmd = sprintf('mrtransform %s/fod_norm.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/fod_norm_MNI.mif -reorient_fod yes -force', ... 
        currentPath, warppath, template_path, currentPath);
    system(cmd);

    cmd = sprintf('mrtransform %s/wmfod_norm.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/wmfod_norm_MNI.mif -reorient_fod yes -force', ... 
        currentPath, warppath, template_path, currentPath);
    system(cmd);

end