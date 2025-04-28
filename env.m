% 获取当前的PATH环境变量
currentPath = getenv("PATH");
disp('当前PATH:');
disp(currentPath);

% 定义需要添加的路径
mrtrixPath = '/Users/langqin/software/mrtrix3/bin';
fslPath = '/Users/langqin/software/fsl/bin';
freesurferPath = '/Users/langqin/software/freesurfer/freesurfer/bin';
ANTsPath = '/Users/langqin/software/install/bin';

% 构造新的PATH
newPath = [mrtrixPath, ':', fslPath, ':', freesurferPath, ':', ANTsPath, ':', currentPath];

% 设置新的PATH环境变量
setenv('PATH', newPath);

% 设置 FSLDIR 环境变量
setenv('FSLDIR', '/Users/langqin/software/fsl');

% 执行 FSL 的初始化脚本
fslInitScript = '/Users/langqin/software/fsl/etc/fslconf/fsl.sh';
system(['source ', fslInitScript]);

% 验证新的PATH
currentPath = getenv('PATH');
disp('更新后的PATH:');
disp(currentPath);