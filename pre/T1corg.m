function T1corg(path, name, work, startname)
    
    output = fullfile(work, 'T1_corg', name); 
    mkdir(output); % 创建目录

    Tcoreg = fullfile(work, 'T1_coreg', name);

    T = fullfile(work,'T1mif',name);

    % 没配准的分割
    Tc = sprintf('5ttgen fsl %s/T1.nii.gz %s/5tt.mif -force', ... 
        T, output);
    system(Tc);

    Tc = sprintf('5tt2gmwmi %s/5tt.mif %s/gmwmSeed.mif -force', ... 
        output, output);
    system(Tc);

    % 配准的分割
    Tc = sprintf('5ttgen fsl %s/T1_coreg.nii.gz %s/5tt_coreg.mif -force', ... 
        Tcoreg, output);
    system(Tc);

    Tc = sprintf('5tt2gmwmi %s/5tt_coreg.mif %s/gmwmSeed_coreg.mif -force', ... 
        output, output);
    system(Tc);

end