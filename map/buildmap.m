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

    mk = sprintf('mrconvert %s %s/mask.nii.gz -datatype int32 -force',maskpath,outputpath);
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
        matrix_125x125 = mat_data.NetworkMatrix;  % 假设 mat 文件中矩阵变量名为 NetworkMatrix
    
        % 将索引调整为 MATLAB 的索引（MATLAB 默认是 1-based 索引）
        node_indices = str2num(brainnet) - 1;  % 假设 brain_mask 是以逗号分隔的字符串
        node_indices = node_indices + 1;  % 转换为 1-based 索引
    
        % 提取子矩阵
        matrix_32x32 = matrix_125x125(node_indices, node_indices);
    
        % 保存为新的 mat 文件
        output_mat_file_path = fullfile(path_results, [subFolder '_ROIBN.mat']);
        save(output_mat_file_path, 'matrix_32x32', '-mat');
    end

end