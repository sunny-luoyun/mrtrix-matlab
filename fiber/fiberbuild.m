function [newpath,fodfolder] = fiberbuild(workPath,subFolder,currentPath,startfloder,optiontest,goin,angle,min,max,fod,trytime,fibernum,modetest,roi,mask,ROIDef,seeds)
    
    newfolder = sprintf('fiber_%s', ...
        startfloder);
    fodfilepath = fullfile(workPath,startfloder,subFolder);
    outputpath = fullfile(workPath,newfolder,subFolder);
    mkdir(outputpath);

    % 自动检测 FOD 文件（多组织 wmfod_norm 或单组织 fod_norm）
    fodfile_candidates = {'wmfod_norm.mif', 'fod_norm.mif'};
    fodfile_name = '';
    for fc = 1:length(fodfile_candidates)
        if exist(fullfile(fodfilepath, fodfile_candidates{fc}), 'file')
            fodfile_name = fodfile_candidates{fc};
            break;
        end
    end
    if isempty(fodfile_name)
        error('未找到 FOD 文件，请确认已执行 FOD 计算步骤 (需 %s)', strjoin(fodfile_candidates, ' / '));
    end

    % 确保变量是整数类型
    angle = int32(angle);
    min = int32(min);
    max = int32(max);
    trytime = int32(trytime);

    if strcmp(modetest, '全脑追踪')
    
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_in_dwi.mif -backtrack -seed_gmwmi %s/T1_corg/%s/gmwmSeed_in_dwi.mif -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -seeds %s -trials %d -select %s %s/%s %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,workPath,subFolder,goin,angle,min,max,fod,seeds,trytime,fibernum,fodfilepath,fodfile_name,outputpath);
        system(cmd);
    
    elseif strcmp(modetest,'基于单种子点')
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_in_dwi.mif -backtrack -seed_sphere %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -seeds %s -trials %d -select %s %s/%s %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,roi,goin,angle,min,max,fod,seeds,trytime,fibernum,fodfilepath,fodfile_name,outputpath);
        system(cmd);

    elseif strcmp(modetest,'基于单mask')
        % 将MNI空间mask warp到个体DWI空间
        warppath = fullfile(workPath, 'dwi_coreg', subFolder);
        b0_path = fullfile(workPath, 'pred_b0', subFolder);
        mask_dwi = fullfile(outputpath, 'mask_in_dwi.nii.gz');
        cmd = sprintf('mrtransform %s -linear %s/dwi_to_MNI_mrtrix.txt -inverse -target %s/mean_b0.nii.gz %s -interp nearest -datatype int32 -force', ...
            mask, warppath, b0_path, mask_dwi);
        system(cmd);
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_in_dwi.mif -backtrack -seed_image %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -seeds %s -trials %d -select %s %s/%s %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,mask_dwi,goin,angle,min,max,fod,seeds,trytime,fibernum,fodfilepath,fodfile_name,outputpath);
        system(cmd);
    elseif strcmp(modetest,'基于多roi')
        if isempty(ROIDef)
            disp('ROIDef is empty.');
            return;
        end

        warppath = fullfile(workPath, 'dwi_coreg', subFolder);
        b0_path = fullfile(workPath, 'pred_b0', subFolder);

        if iscell(ROIDef) && ~isempty(ROIDef{1}) && ischar(ROIDef{1})
            % 将MNI空间的ROI文件逐个warp到个体DWI空间
            ROIDef_warped = cell(size(ROIDef));
            for i = 1:length(ROIDef)
                [~, fname, fext] = fileparts(ROIDef{i});
                roi_dwi = fullfile(outputpath, [fname '_in_dwi' fext]);
                cmd = sprintf('mrtransform %s -linear %s/dwi_to_MNI_mrtrix.txt -inverse -target %s/mean_b0.nii.gz %s -interp nearest -datatype int32 -force', ...
                    ROIDef{i}, warppath, b0_path, roi_dwi);
                system(cmd);
                ROIDef_warped{i} = roi_dwi;
            end
            ROIDefStrings = cellfun(@(x) string(x), ROIDef_warped, 'UniformOutput', false);
            formattedString = "-seed_image " + ROIDefStrings{1};
            for i = 2:length(ROIDefStrings)
                formattedString = [formattedString " -include " ROIDefStrings{i}];
            end
        elseif iscell(ROIDef) && ~isempty(ROIDef{1}) && isnumeric(ROIDef{1})
            ROIDefStrings = cellfun(@(x) strrep(mat2str(x), ' ', ','), ROIDef, 'UniformOutput', false);
            ROIDefStrings = cellfun(@(x) strrep(x, '[', ''), ROIDefStrings, 'UniformOutput', false);
            ROIDefStrings = cellfun(@(x) strrep(x, ']', ''), ROIDefStrings, 'UniformOutput', false);
            formattedString = "-seed_sphere " + ROIDefStrings{1};
            for i = 2:length(ROIDefStrings)
                formattedString = [formattedString " -include " ROIDefStrings{i}];
            end
        else
            disp('ROIDef contains unsupported data type.');
            return;
        end
    
        formattedString = strjoin(formattedString, ' ');

        if ischar(fibernum)
            fibernum = string(fibernum);
        end

        fprintf('%s\n', formattedString);
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_in_dwi.mif -backtrack %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -seeds %s -trials %d -select %s %s/%s %s/tracks.tck -force', ...
            optiontest,workPath,subFolder,formattedString,goin,angle,min,max,fod,seeds,trytime,fibernum,fodfilepath,fodfile_name,outputpath);
        
        system(cmd);
    end
    newpath = outputpath;
    fodfolder = startfloder;
end