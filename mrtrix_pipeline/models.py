"""数据模型

定义设计矩阵、对比矩阵等结构化数据，方便从文件读写。
"""

import os


def write_design_matrix(filepath, matrix_text):
    """将设计矩阵文本写入文件"""
    with open(filepath, 'w') as f:
        f.write(matrix_text)
    print(f"[INFO] 设计矩阵已写入: {filepath}")


def write_contrast_matrix(filepath, matrix_text):
    with open(filepath, 'w') as f:
        f.write(matrix_text)
    print(f"[INFO] 对比矩阵已写入: {filepath}")


def write_files_txt(filepath, file_list):
    """写入 files.txt（CFE 统计所需）"""
    with open(filepath, 'w') as f:
        for fn in file_list:
            f.write(f'{fn}\n')
    print(f"[INFO] 文件列表已写入: {filepath} ({len(file_list)} 个)")
