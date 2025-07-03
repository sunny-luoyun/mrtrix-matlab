function [newpath,fodfolder] = fiberbuild(workPath,subFolder,currentPath,startfloder,optiontest,goin,angle,min,max,fod,trytime,fibernum,modetest,roi,mask,ROIDef)
    
    newfolder = sprintf('fiber_%s', ...
        startfloder);
    fodfilepath = fullfile(workPath,startfloder,subFolder);
    outputpath = fullfile(workPath,newfolder,subFolder);
    mkdir(outputpath);

    % 确保变量是整数类型
    angle = int32(angle);
    min = int32(min);
    max = int32(max);
    trytime = int32(trytime);

    if strcmp(modetest, '全脑追踪')
    
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_gmwmi %s/T1_corg/%s/gmwmSeed_coreg.mif -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/wmfod_norm_MNI.mif %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,workPath,subFolder,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,outputpath);
        system(cmd);
    
    elseif strcmp(modetest,'基于单种子点')
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_sphere %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/wmfod_norm_MNI.mif %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,roi,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,outputpath);
        system(cmd);

    elseif strcmp(modetest,'基于单mask')
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_image %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/wmfod_norm_MNI.mif %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,mask,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,outputpath);
        system(cmd);
    elseif strcmp(modetest,'基于多roi')
        % 检查 ROIDef 是否为空
        if isempty(ROIDef)
            disp('ROIDef is empty.');
            return;
        end

        % 检查 ROIDef 中的元素类型
        if iscell(ROIDef) && ~isempty(ROIDef{1}) && ischar(ROIDef{1})
            % 如果 ROIDef 中的元素是字符串（文件路径）
            ROIDefStrings = cellfun(@(x) string(x), ROIDef, 'UniformOutput', false);
            formattedString = "-seed_image " + ROIDefStrings{1};
            for i = 2:length(ROIDefStrings)
                formattedString = [formattedString " -include " ROIDefStrings{i}];
            end
        elseif iscell(ROIDef) && ~isempty(ROIDef{1}) && isnumeric(ROIDef{1})
            % 如果 ROIDef 中的元素是数值（坐标）
            ROIDefStrings = cellfun(@(x) strrep(mat2str(x), ' ', ','), ROIDef, 'UniformOutput', false);
            % 去掉括号
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
    
        % 确保 formattedString 是一个单一的字符串
        formattedString = strjoin(formattedString, ' ');

        % 确保 fibernum 是字符串类型
        if ischar(fibernum)
            fibernum = string(fibernum);
        end

        % 显示结果
        fprintf('%s\n', formattedString);
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/wmfod_norm_MNI.mif %s/tracks.tck -force', ...
            optiontest,workPath,subFolder,formattedString,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,outputpath);
        
        system(cmd);
    end
    newpath = outputpath;
    fodfolder = startfloder;
end