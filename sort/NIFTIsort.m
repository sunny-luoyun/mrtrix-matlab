function NIFTIsort(T1file, dwifile, outputpath)
    % 输入参数：
    % T1file - 包含被试文件夹的父文件夹路径（例如 '/Users/langqin/data/T1raw'）
    % outputpath - 输出文件夹路径（例如 '/Users/langqin/data/output'）

    % 确保输入和输出路径是字符串
    inputDir = char(T1file);
    outputDir = char(outputpath);

    % 检查输出目录是否存在，如果不存在则创建
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % 获取输入目录下的所有子文件夹（被试文件夹）
    subDirs = dir(fullfile(inputDir, '*'));
    subDirs = {subDirs([subDirs.isdir]).name}';

    % 过滤掉当前目录（.）和上一级目录（..）
    subDirs = subDirs(~ismember(subDirs, {'.', '..'}));

    % 遍历每个被试文件夹
    for i = 1:length(subDirs)
        subDirName = subDirs{i}; % 当前被试文件夹名称（如 'Sub001'）
        subInputPath = fullfile(inputDir, subDirName); % 当前被试的输入路径
        subOutputPath = fullfile(outputDir, subDirName); % 当前被试的输出路径

        % 检查当前被试的输出目录是否存在，如果不存在则创建
        if ~exist(subOutputPath, 'dir')
            mkdir(subOutputPath);
        end

        % 输出调试信息
        fprintf('Input Path: %s\n', subInputPath);
        fprintf('Output Path: %s\n', subOutputPath);

        % 构造 dcm2niix 命令
        dcm2niixCommand = ['dcm2niix -o ' subOutputPath ' -f "%fT1" -z y -s y ' subInputPath];

        % 在终端中运行 dcm2niix 命令
        system(dcm2niixCommand);

        % 输出进度信息
        fprintf('Processed %s\n', subDirName);
    end

    inputDir = char(dwifile);
    outputDir = char(outputpath);

    % 检查输出目录是否存在，如果不存在则创建
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % 获取输入目录下的所有子文件夹（被试文件夹）
    subDirs = dir(fullfile(inputDir, '*'));
    subDirs = {subDirs([subDirs.isdir]).name}';

    % 过滤掉当前目录（.）和上一级目录（..）
    subDirs = subDirs(~ismember(subDirs, {'.', '..'}));

    % 遍历每个被试文件夹
    for i = 1:length(subDirs)
        subDirName = subDirs{i}; % 当前被试文件夹名称（如 'Sub001'）
        subInputPath = fullfile(inputDir, subDirName); % 当前被试的输入路径
        subOutputPath = fullfile(outputDir, subDirName); % 当前被试的输出路径

        % 检查当前被试的输出目录是否存在，如果不存在则创建
        if ~exist(subOutputPath, 'dir')
            mkdir(subOutputPath);
        end

        % 输出调试信息
        fprintf('Input Path: %s\n', subInputPath);
        fprintf('Output Path: %s\n', subOutputPath);

        % 构造 dcm2niix 命令
        dcm2niixCommand = ['dcm2niix -o ' subOutputPath ' -f "%fdwi" -z y -s y ' subInputPath];

        % 在终端中运行 dcm2niix 命令
        system(dcm2niixCommand);

        % 输出进度信息
        fprintf('Processed %s\n', subDirName);
    end

    fprintf('整理完成!!!.\n');
end