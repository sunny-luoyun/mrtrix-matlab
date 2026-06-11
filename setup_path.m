function setup_path()
rootDir = fileparts(mfilename('fullpath'));
folders = {
    'pre',     % 预处理
    'dti',     % 弥散指标计算
    'fod',     % 反卷积响应函数计算
    'fiber',   % 纤维重建
    'fba',     % FBA 纤维分析
    'map',     % 纤维网络矩阵构建
    'sort',    % 原始数据整理
    'stats',   % 统计分析
    'counter', % 使用计数
    };
addpath(rootDir);
for i = 1:numel(folders)
    addpath(fullfile(rootDir, folders{i}));
end
end
