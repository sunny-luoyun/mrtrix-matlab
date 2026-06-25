function T1corg(path, name, work, startname)
    
    output = fullfile(work, 'T1_corg', name); 
    mkdir(output); % 创建目录

    T = fullfile(work,'T1mif',name);

    b0_path = fullfile(work, 'pred_b0', name);

    % 没配准的分割
    Tc = sprintf('5ttgen fsl %s/T1.nii.gz %s/5tt.mif -force', ... 
        T, output);
    system(Tc);

    Tc = sprintf('5tt2gmwmi %s/5tt.mif %s/gmwmSeed.mif -force', ... 
        output, output);
    system(Tc);

    % T1配准到个体DWI空间
    Tc = sprintf('flirt -in %s/T1.nii.gz -ref %s/mean_b0.nii.gz -dof 12 -out %s/T1_in_DWI.nii.gz -omat %s/T1_to_DWI_fsl.mat', ...
        T, b0_path, output, output);
    system(Tc);

    Tc = sprintf('transformconvert %s/T1_to_DWI_fsl.mat %s/T1.nii.gz %s/mean_b0.nii.gz flirt_import %s/T1_to_DWI_mrtrix.txt -force', ...
        output, T, b0_path, output);
    system(Tc);

    % 5tt和gmwmSeed从T1空间warp到DWI空间
    Tc = sprintf('mrtransform %s/5tt.mif -linear %s/T1_to_DWI_mrtrix.txt -template %s/mean_b0.nii.gz %s/5tt_in_dwi.mif -force', ...
        output, output, b0_path, output);
    system(Tc);

    Tc = sprintf('mrtransform %s/gmwmSeed.mif -linear %s/T1_to_DWI_mrtrix.txt -template %s/mean_b0.nii.gz %s/gmwmSeed_in_dwi.mif -force', ...
        output, output, b0_path, output);
    system(Tc);

end