current_dir = fileparts(mfilename('fullpath'));
template_path = fullfile(current_dir, 'Templates', 'MNI152.nii.gz');

function prep(path, list)
    start_time = tic;
    for i = 1:length(list)
        start_timee = tic;

        % 创建目录
        mkdir(fullfile(path, 'work', 'preprocess', list{i}));
        fprintf('现在开始处理 %s\n', list{i});

        % 转换 mif /1s
        fprintf('格式转换\n');
        cmd = sprintf('mrconvert -fslgrad %s/pre/%s/%sdwi.bvec %s/pre/%s/%sdwi.bval %s/pre/%s/%sdwi.nii.gz %s/work/preprocess/%s/dwi_raw.mif -force', ...
            path, list{i}, list{i}, path, list{i}, list{i}, path, list{i}, list{i}, path, list{i});
        [status, result] = system(cmd);
        fprintf('%s\n', result);

        % 降噪 /19s
        fprintf('降噪\n');
        cmd = sprintf('dwidenoise %s/work/preprocess/%s/dwi_raw.mif %s/work/preprocess/%s/dwi_raw_denoise.mif -noise %s/work/preprocess/%s/noiselevel.mif -force', ...
            path, list{i}, path, list{i}, path, list{i});
        [status, result] = system(cmd);
        fprintf('%s\n', result);

        % 消除 Gibbs Ring /23s
        fprintf('消除 Gibbs Ring\n');
        cmd = sprintf('mrdegibbs %s/work/preprocess/%s/dwi_raw_denoise.mif %s/work/preprocess/%s/dwi_raw_denoise_degibbs.mif -force', ...
            path, list{i}, path, list{i});
        [status, result] = system(cmd);
        fprintf('%s\n', result);

        % 建立 AP-PA 配对 /1s
        fprintf('建立 AP-PA 配对\n');
        cmd = sprintf('dwiextract %s/work/preprocess/%s/dwi_raw.mif - -bzero | mrconvert - -coord 3 0 %s/work/preprocess/%s/b0_PA.mif -force', ...
            path, list{i}, path, list{i});
        [status, result] = system(cmd);
        fprintf('%s\n', result);

        % 其他命令类似，依次转换为 MATLAB 的 system 调用
        % ...

        % 记录结束时间
        elapsed_time = toc(start_timee);
        hours = floor(elapsed_time / 3600);
        minutes = floor((elapsed_time - hours * 3600) / 60);
        seconds = mod(elapsed_time, 60);

        fprintf('处理 %s 结束，共花费时间：%d小时%d分%d秒\n', list{i}, hours, minutes, seconds);
    end

    % 总运行时间
    elapsed_time = toc(start_time);
    hours = floor(elapsed_time / 3600);
    minutes = floor((elapsed_time - hours * 3600) / 60);
    seconds = mod(elapsed_time, 60);

    fprintf('运行结束，共花费时间：%d小时%d分%d秒\n', hours, minutes, seconds);
end