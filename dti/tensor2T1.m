function tensor2T1(name, work, startname)

    tensor_path = fullfile(work,'tensor',name);

    % tensor格式转换
    tensor = sprintf('mrconvert %s/dt.mif %s/dt.nii.gz -force', ... 
        tensor_path, tensor_path);
    system(tensor);

    dwib0_path = fullfile(work, 'pred_b0', name);

    % tensor配准到T1
    tensor_coreg = sprintf('flirt -in %s/dt.nii.gz -ref %s/mean_b0.nii.gz -dof 12 -out %s/DTI_coregT1_tensor.nii.gz', ... 
        tensor_path, dwib0_path, tensor_path);
    system(tensor_coreg);
    
end