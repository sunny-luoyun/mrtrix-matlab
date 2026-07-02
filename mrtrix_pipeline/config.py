"""环境配置

服务器上 MRtrix3/FSL/ANTs 等工具已配好 PATH，只需检查命令是否可用。
"""

import os
import shutil


def check_commands():
    """检查关键命令是否可用，返回 (ok, missing)"""
    required = ['mrconvert', 'dwi2response', 'dwi2fod', 'tckgen']
    missing = [cmd for cmd in required if not shutil.which(cmd)]
    ok = len(missing) == 0
    if not ok:
        print("[WARN] 以下命令未找到，请确认环境已正确配置 PATH:")
        for cmd in missing:
            print(f"       {cmd}")
    return ok, missing
