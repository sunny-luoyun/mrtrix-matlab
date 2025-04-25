function T1corg(path, name, work, startname)
    
    T1cut = fullfile(work, 'T1_corg', name); 
    mkdir(T1cut); % 创建目录

    TtoM = fullfile(work, 'T1_coreg', name); 
    
    Tc = sprintf('5ttgen fsl %s/T1_coreg.nii.gz %s/T1_coreg_5tt.mif -force', ... 
        TtoM, T1cut);
    system(Tc);

    Tc = sprintf('5tt2gmwmi %s/T1_coreg_5tt.mif %s/gmwmSeed_coreg.mif -force', ... 
        T1cut, T1cut);
    system(Tc);

end