function newPath = tck2nii(workPath,subFolder,currentPath,startfloder,fodfolder,methodtest,smooth,weight,gaosmooth)

    % 个体空间模板（mean_b0）
    template_path = fullfile(workPath, 'pred_b0', subFolder, 'mean_b0.nii.gz');

    % MNI空间模板和变换
    current_script_path = mfilename('fullpath');
    [current_dir, ~, ~] = fileparts(current_script_path);
    parent_dir = fileparts(current_dir);
    mni_template = fullfile(parent_dir, 'Templates', 'MNI152.nii.gz');
    warppath = fullfile(workPath, 'dwi_coreg', subFolder);

    if gaosmooth 
        if weight
            cmd = sprintf('tckmap -contrast tdi -vox 1.0 -template %s -fwhm_tck %d -tck_weights_in %s/sift_weight.txt %s/tracks.tck %s/tracks_Map.mif -force', ... 
                template_path,smooth,currentPath,currentPath,currentPath);
            system(cmd)
        else
            cmd = sprintf('tckmap -contrast tdi -vox 1.0 -template %s -fwhm_tck %d %s/tracks.tck %s/tracks_Map.mif -force', ... 
                template_path,smooth,currentPath,currentPath);
            system(cmd);
        end
        cmd = sprintf('tckmap -contrast tdi -vox 1.0 -template %s -fwhm_tck %d %s/tracks_sift.tck %s/tracks_sift_Map.mif -force', ... 
                template_path,smooth,currentPath,currentPath);
            system(cmd);

        % 个体→MNI并输出到Results
        cmd = sprintf('mrtransform %s/tracks_Map.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/tracks_Map_MNI.mif -force', ...
            currentPath, warppath, mni_template, currentPath);
        system(cmd);

        outputpath = fullfile(workPath,'Results','tracksMap');
        mkdir(outputpath)
        cmd = sprintf('mrconvert %s/tracks_Map_MNI.mif %s/%s_tracks_%sMap_S%d.nii -force', ... 
                currentPath,outputpath,subFolder,methodtest,smooth);
        system(cmd)

        cmd = sprintf('mrtransform %s/tracks_sift_Map.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/tracks_sift_Map_MNI.mif -force', ...
            currentPath, warppath, mni_template, currentPath);
        system(cmd);

        outputpath = fullfile(workPath,'Results','trackssiftMap');
        mkdir(outputpath)
        cmd = sprintf('mrconvert %s/tracks_sift_Map_MNI.mif %s/%s_tracks_sift_%sMap_S%d.nii -force', ... 
                currentPath,outputpath,subFolder,methodtest,smooth);
        system(cmd)

    else
        if weight
            cmd = sprintf('tckmap -contrast %s -vox 1.0 -template %s -tck_weights_in %s/sift_weight.txt %s/tracks.tck %s/tracks_Map.mif -force', ... 
                methodtest,template_path,currentPath,currentPath,currentPath);
            system(cmd)
        else
            cmd = sprintf('tckmap -contrast %s -vox 1.0 -template %s %s/tracks.tck %s/tracks_Map.mif -force', ... 
                methodtest,template_path,currentPath,currentPath);
            system(cmd);
        end

        cmd = sprintf('tckmap -contrast %s -vox 1.0 -template %s %s/tracks_sift.tck %s/tracks_sift_Map.mif -force', ... 
                methodtest,template_path,currentPath,currentPath);
            system(cmd);

        % 个体→MNI并输出到Results
        cmd = sprintf('mrtransform %s/tracks_Map.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/tracks_Map_MNI.mif -force', ...
            currentPath, warppath, mni_template, currentPath);
        system(cmd);

        outputpath = fullfile(workPath,'Results','tracksMap');
        mkdir(outputpath)
        cmd = sprintf('mrconvert %s/tracks_Map_MNI.mif %s/%s_tracks_%sMap.nii -force', ... 
                currentPath,outputpath,subFolder,methodtest);
        system(cmd)

        cmd = sprintf('mrtransform %s/tracks_sift_Map.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/tracks_sift_Map_MNI.mif -force', ...
            currentPath, warppath, mni_template, currentPath);
        system(cmd);

        outputpath = fullfile(workPath,'Results','trackssiftMap');
        mkdir(outputpath)
        cmd = sprintf('mrconvert %s/tracks_sift_Map_MNI.mif %s/%s_tracks_sift_%sMap.nii -force', ... 
                currentPath,outputpath,subFolder,methodtest);
        system(cmd)
    end

    newPath = currentPath;

end