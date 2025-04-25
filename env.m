% 获取当前的PATH环境变量
currentPath = getenv("PATH");
disp('当前PATH:');
disp(currentPath);

% 定义需要添加的路径
mrtrixPath = '/Users/langqin/software/mrtrix3/bin';
fslPath = '/Users/langqin/software/fsl/bin';
freesurferPath = '/Users/langqin/software/freesurfer/freesurfer/bin';
installPath = '/Users/langqin/software/install/bin';

% 构造新的PATH
newPath = [mrtrixPath, ':', fslPath, ':', freesurferPath, ':', installPath, ':', currentPath];

% 设置新的PATH环境变量
setenv('PATH', newPath);

% 验证新的PATH
currentPath = getenv('PATH');
disp('更新后的PATH:');
disp(currentPath);