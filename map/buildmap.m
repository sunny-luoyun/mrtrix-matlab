function buildmap(workPath, subFolder, currentPath,maskpath,sy,zero,len,rare,zb,weigth,output,brainnet)
    
    outputpath = fullfile(workPath,'brainnet', subFolder);
    mkdir(outputpath)

    resultpath = fullfile(workPath,'Results','brainnet_Map','GlobalMap');
    mkdir(resultpath)

    sourcefile = fullfile(currentPath,'tracks.tck');

    if sy
        sy = '-symmetric';
    else
        sy = '';
    end

    if zero
        zero = '-zero_diagonal';
    else
        zero = '';
    end

    if strcmp(zb,'length')
        zb = '-scale_length';
    elseif strcmp(zb,'invlength')
        zb = '-scale_invlength';
    elseif strcmp(zb,'invnodevol')
        zb = '-scale_invnodevol';
    end
    
    if strcmp(rare,'voxels')
        rare = '-assignment_end_voxels';
    elseif strcmp(rare,'radial')
        rare = sprintf('-assignment_radial_search %d',len);
    elseif strcmp(rare,'reverse')
        rare = sprintf('-assignment_reverse_search %d',len);
    elseif strcmp(rare,'forward')
        rare = sprintf('-assignment_forward_search %d',len);
    end

    if weigth
        weigthpath = fullfile(currentPath,'sift_weight.txt');
        weigth = sprintf('-tck_weights_in %s',weigthpath);
    else
        weigth = '';
    end

    if output
        output = sprintf('-out_assignment %s/assign.csv',outputpath);
    else
        output = '';
    end

    warppath = fullfile(workPath, 'dwi_coreg', subFolder);
    b0_path = fullfile(workPath, 'pred_b0', subFolder);
    mk = sprintf('mrtransform %s -linear %s/dwi_to_MNI_mrtrix.txt -inverse -target %s/mean_b0.nii.gz %s/mask.nii.gz -interp nearest -datatype int32 -force', ...
        maskpath, warppath, b0_path, outputpath);
    system(mk)

    cmd = sprintf('tck2connectome %s %s %s %s %s %s/mask.nii.gz %s/BN.csv %s %s -force', ... 
        sy,zero,zb,rare,sourcefile,outputpath,outputpath,weigth,output);
    system(cmd);

    % CSV 文件路径
    csv_file = fullfile(outputpath,'BN.csv');
    
    % 读取 CSV 文件
    NetworkMatrix = readmatrix(csv_file);
    
    % 输出的 MAT 文件路径
    mat_file = fullfile(resultpath, [ subFolder '_BN.mat']);
    
    % 将变量保存为 MAT 文件
    save(mat_file, 'NetworkMatrix');

    % 复制 CSV 到 GlobalMap 文件夹
    csv_result = fullfile(resultpath, [subFolder '_BN.csv']);
    copyfile(csv_file, csv_result);

    % 检查 brain_mask 是否为空
    if isempty(brainnet)
        % 如果为空，直接跳过后续操作
    else
        % 创建目录
        path_results = fullfile(workPath, 'Results', 'brainnet_Map', 'ROIMAP');
        if ~exist(path_results, 'dir')
            mkdir(path_results);
        end
        
        % 加载 mat 文件数据
        mat_data = load(mat_file);
        full_matrix = mat_data.NetworkMatrix;
        num_nodes = size(full_matrix, 1);

        node_indices = str2double(strsplit(brainnet, ','));
        if any(isnan(node_indices)) || any(node_indices < 1) || any(node_indices > num_nodes)
            warning('脑区编号无效：编号超出范围 (1-%d) 或包含非数值字符，跳过提取', num_nodes);
        else
            % 提取子矩阵
            roi_matrix = full_matrix(node_indices, node_indices);

            % 保存为新的 mat 文件
            output_mat_file_path = fullfile(path_results, [subFolder '_ROIBN.mat']);
            save(output_mat_file_path, 'roi_matrix', '-mat');

            % 将子矩阵也写出为 CSV
            csv_roi_file = fullfile(path_results, [subFolder '_ROIBN.csv']);
            writematrix(roi_matrix, csv_roi_file);
        end
    end

end