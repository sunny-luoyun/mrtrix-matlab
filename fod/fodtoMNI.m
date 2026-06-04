function fodtoMNI(workPath, name, currentPath, isMulti)
    current_script_path = mfilename('fullpath');
    [current_dir, ~, ~] = fileparts(current_script_path);
    parent_dir = fileparts(current_dir);
    template_path = fullfile(parent_dir, 'Templates', 'MNI152.nii.gz');

    warppath = fullfile(workPath, 'dwi_coreg', name);

    if isMulti
        cmd = sprintf('mrtransform %s/wmfod_norm.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/wmfod_norm_MNI.mif -reorient_fod yes -force', ...
            currentPath, warppath, template_path, currentPath);
        system(cmd);
    else
        cmd = sprintf('mrtransform %s/fod_norm.mif -linear %s/dwi_to_MNI_mrtrix.txt -template %s %s/fod_norm_MNI.mif -reorient_fod yes -force', ...
            currentPath, warppath, template_path, currentPath);
        system(cmd);
    end

end