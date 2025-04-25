function [newpath,newstart] = headmove(path, name, work, startname)
    
    b0 = fullfile(work, 'raw_b0',name); 
    mkdir(b0); 
    
    % 建立AP-PA配对
    APA = sprintf('dwiextract %s/dwimif/%s/dwi.mif - -bzero | mrconvert - -coord 3 0 %s/b0_PA.mif -force', ... 
        work, name, b0);
    system(APA);
    APA = sprintf('dwiextract %s/dwimif/%s/dwi.mif - -bzero | mrconvert - -coord 3 0 %s/b0_AP.mif -force', ... 
        work, name, b0);
    system(APA);
    APA = sprintf('mrcat %s/b0_PA.mif %s/b0_AP.mif %s/b0_pair.mif -force', ... 
        b0, b0, b0);
    system(APA);

    newstart = [startname 'H'];
    head = fullfile(work, newstart, name); 
    mkdir(head); % 创建目录

    dwigibbs = sprintf('dwifslpreproc %s/dwi.mif %s/dwi.mif -pe_dir AP -rpe_pair -se_epi %s/b0_pair.mif -eddy_options " --data_is_shelled --slm=linear --niter=5 "  -force', ... 
        path, head, b0);
    system(dwigibbs);

    newpath = head;
    
end