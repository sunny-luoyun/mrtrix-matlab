# MRtrix3-Matlab处理工具包

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020b+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![MRtrix3](https://img.shields.io/badge/MRtrix3-3.0+-green.svg)](https://www.mrtrix.org/)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

一个基于 MATLAB 和 MRtrix3 的图形化弥散加权成像(DWI)数据处理工具包，提供从原始数据整理到纤维束重建的完整处理流程。

## ✨ 功能特性

### 1. 原始数据整理模块
- **IMA 图像提取**: 从原始文件中批量提取 IMA 格式图像
- **NIFTI 格式转换**: 使用 dcm2niix 将 DICOM/IMA 转换为 NIFTI 格式
- **自动化文件组织**: 智能识别被试文件夹并按规范整理

### 2. 弥散像预处理模块
- **降噪处理**: 去除图像噪声，提高信噪比
- **Gibbs Ring 消除**: 消除 Gibbs 伪影
- **头动矫正**: 矫正扫描过程中的头部运动
- **变形矫正**: 校正图像畸变
- **Bias 场矫正**: 去除 B1 场不均匀性
- **格式转换**: NII 到 MIF 格式转换
- **脑膜提取**: 自动提取脑组织掩膜
- **配准**: T1/DWI 到 MNI 标准空间配准
- **T1 分割**: 脑组织自动分割

### 3. DTI 处理模块
- **扩散张量成像**: 计算 DTI 参数
- **FA/MD/AD/RD 图谱**: 生成多种扩散指标图
- **质量控制**: 自动化质量评估

### 4. FOD 计算模块
- **纤维方向分布**: 计算 Fiber Orientation Distribution
- **CSD 算法**: 约束球面反卷积
- **多壳层支持**: 支持单壳和多壳 DWI 数据

### 5. 纤维束重建模块
- **确定性追踪**: 基于张量的纤维追踪
- **概率性追踪**: 基于 FOD 的概率追踪
- **全脑追踪**: 高分辨率全脑纤维束重建
- **ROI 追踪**: 基于感兴趣区的定向追踪

### 6. 结构连接矩阵构建
- **脑网络构建**: 自动构建结构连接矩阵
- **图论分析**: 支持多种图论指标计算
- **可视化**: 网络矩阵可视化

## 🖥️ 系统要求

### 必需软件
- **MATLAB**: R2020b 或更高版本
- **MRtrix3**: 3.0 或更高版本
- **dcm2niix**: 最新版本（用于 DICOM 转换）
- **FSL**: 6.0 或更高版本（可选，用于配准）
- **ANTs**: 2.3 或更高版本（可选，用于高级配准）

### 操作系统
- macOS 10.14 或更高版本
- Linux (Ubuntu 18.04+ / CentOS 7+)
- Windows 10/11（需要 WSL2 支持 MRtrix3）

### 硬件建议
- **CPU**: 多核处理器（推荐 8 核以上）
- **内存**: 16 GB 或更多（推荐 32 GB）
- **存储**: 根据数据量，建议预留 100 GB 以上空间

## 📥 安装说明

### 1. 克隆仓库

```bash
git clone https://github.com/yourusername/mrtrix-toolbox.git
cd mrtrix-toolbox
```

### 2. 安装依赖软件

#### macOS 安装

```bash
# 安装 Homebrew（如果尚未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 MRtrix3
brew install mrtrix3

# 安装 dcm2niix
brew install dcm2niix

# 安装 FSL（可选）
# 请访问 https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation
```

#### Linux 安装

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install mrtrix3 dcm2niix

# 或从源码编译 MRtrix3
git clone https://github.com/MRtrix3/mrtrix3.git
cd mrtrix3
./configure
./build
./set_path
```

#### Windows (WSL2)

```bash
# 在 WSL2 中安装 Ubuntu，然后按照 Linux 安装步骤操作
wsl --install -d Ubuntu
```

### 3. 配置 MATLAB 路径

在 MATLAB 中运行：

```matlab
% 将工具包添加到 MATLAB 路径
addpath(genpath('/path/to/mrtrix-toolbox'));
savepath;
```

### 4. 配置环境变量（macOS）

如果使用 macOS，需要配置环境变量文件 `env.m`：

```matlab
% env.m 示例内容
setenv('PATH', ['/usr/local/bin:', getenv('PATH')]);
setenv('FSLDIR', '/usr/local/fsl');
```

## 🚀 使用指南

### 快速开始

1. **启动主界面**

```matlab
mrtrix
```

## 📁 数据格式

### 输入数据结构

```
project_folder/
├── rawdata/
│   ├── Sub001/
│   │   ├── T1/           # T1 结构像
│   │   └── DWI/          # 弥散加权像
│   ├── Sub002/
│   └── ...
```

### 输出数据结构

```
output_folder/
├── Sub001/
│   ├── dwi.mif           # 预处理后的 DWI
│   ├── T1.nii.gz         # T1 结构像
│   ├── mask.mif          # 脑掩膜
│   ├── dti/
│   │   ├── fa.mif
│   │   ├── md.mif
│   │   └── ...
│   ├── fod/
│   │   └── wmfod_norm.mif
│   ├── tractography/
│   │   └── tracks_10M.tck
│   └── connectome/
│       └── connectome.csv
```


## 🙏 致谢

- [MRtrix3](https://www.mrtrix.org/) 团队
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/) 开发团队
- 所有贡献者和用户

**⭐ 如果这个项目对您有帮助，请给我们一个 Star！**
