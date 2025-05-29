function newPath = tck2nii(workPath,subFolder,currentPath,startfloder,fodfolder,methodtest,smooth,weight)

    % 获取当前脚本的完整路径
    current_script_path = mfilename('fullpath');
    
    % 获取当前脚本所在的目录
    [current_dir, ~, ~] = fileparts(current_script_path);
    
    % 获取当前脚本所在目录的上一级目录
    parent_dir = fileparts(current_dir);

    % 构建相对路径
    template_path = fullfile(parent_dir, 'Templates', 'MNI152.nii.gz');
    
    if weight
        cmd = sprintf('tckmap -contrast %s -vox 1.0 -template %s -fwhm_tck %d -tck_weights_in %/tracks_sift.tck %s/tracks.tck %s/tracks_Map.mif -force', ... 
            methodtest,template_path,smooth,currentPath,currentPath,currentPath);
        system(cmd)
    else
        cmd = sprintf('tckmap -contrast %s -vox 1.0 -template %s -fwhm_tck %d %s/tracks.tck %s/tracks_Map.mif -force', ... 
            methodtest,template_path,smooth,currentPath,currentPath);
        system(cmd);
    end

    outputpath = fullfile(workPath,'Results','tracksMap');
    mkdir(outputpath)

    cmd = sprintf('mrconvert %s/tracks_Map.mif %s/%s_tracks_%sMap_S%d.nii -force', ... 
            currentPath,outputpath,subFolder,methodtest,smooth);
    system(cmd)
    
    newPath = currentPath;

end