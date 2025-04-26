function mk(name, work)

    % 获取当前脚本的完整路径
    current_script_path = mfilename('fullpath');
    
    % 获取当前脚本所在的目录
    [current_dir, ~, ~] = fileparts(current_script_path);
    
    % 获取当前脚本所在目录的上一级目录
    parent_dir = fileparts(current_dir);
    
    % 构建相对路径
    template_path = fullfile(parent_dir, 'Templates', 'MNI152.nii.gz');
    
    inputdtpath = fullfile(work,'tensor', name, 'dkt');
    outputresultpath = fullfile(work, 'Results', 'tensormetric','MK'); 
    swappath = fullfile(work,'dwi_coreg',name);
    mkdir(outputresultpath)
    % 计算指标
    cmd = sprintf('tensor2metric %s/dkt.mif -mk %s/MK.mif -force', ... 
        inputdtpath, inputdtpath);
    system(cmd);
    % 配准
    cmd = sprintf('mrtransform %s/MK.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/MK_coreg.mif -force', ... 
        inputdtpath, swappath, template_path, inputdtpath);
    system(cmd);
    % 转换
    cmd = sprintf('mrconvert %s/MK_coreg.mif %s/%s_MKmap.nii -force', ... 
        inputdtpath, outputresultpath, name);
    system(cmd);
    
    
    
end