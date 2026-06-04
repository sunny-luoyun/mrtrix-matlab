function [newpath,fodfolder] = fiberbuild(workPath,subFolder,currentPath,startfloder,optiontest,goin,angle,min,max,fod,trytime,fibernum,modetest,roi,mask,ROIDef)
    
    newfolder = sprintf('fiber_%s', ...
        startfloder);
    fodfilepath = fullfile(workPath,startfloder,subFolder);
    outputpath = fullfile(workPath,newfolder,subFolder);
    mkdir(outputpath);

    % 自动检测 FOD 文件（多组织 wmfod_norm_MNI 或单组织 fod_norm_MNI）
    fodfile_candidates = {'wmfod_norm_MNI.mif', 'fod_norm_MNI.mif'};
    fodfile_name = '';
    for fc = 1:length(fodfile_candidates)
        if exist(fullfile(fodfilepath, fodfile_candidates{fc}), 'file')
            fodfile_name = fodfile_candidates{fc};
            break;
        end
    end
    if isempty(fodfile_name)
        error('未找到 FOD 文件，请确认已执行 FOD 计算和配准步骤 (需 %s)', strjoin(fodfile_candidates, ' / '));
    end

    % 确保变量是整数类型
    angle = int32(angle);
    min = int32(min);
    max = int32(max);
    trytime = int32(trytime);

    if strcmp(modetest, '全脑追踪')
    
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_gmwmi %s/T1_corg/%s/gmwmSeed_coreg.mif -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/%s %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,workPath,subFolder,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,fodfile_name,outputpath);
        system(cmd);
    
    elseif strcmp(modetest,'基于单种子点')
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_sphere %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/%s %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,roi,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,fodfile_name,outputpath);
        system(cmd);

    elseif strcmp(modetest,'基于单mask')
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_image %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/%s %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,mask,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,fodfile_name,outputpath);
        system(cmd);
    elseif strcmp(modetest,'基于多roi')
        if isempty(ROIDef)
            disp('ROIDef is empty.');
            return;
        end

        if iscell(ROIDef) && ~isempty(ROIDef{1}) && ischar(ROIDef{1})
            ROIDefStrings = cellfun(@(x) string(x), ROIDef, 'UniformOutput', false);
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
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/%s %s/tracks.tck -force', ...
            optiontest,workPath,subFolder,formattedString,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,fodfile_name,outputpath);
        
        system(cmd);
    end
    newpath = outputpath;
    fodfolder = startfloder;
end