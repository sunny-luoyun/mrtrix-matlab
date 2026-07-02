"""统计分析工具

与 MATLAB stats_fun.m 一致:
    mrstats / mrclusterstats / connectomestats / tckstats
"""

import os
from .utils import run_cmd


def run_mrstats(input_file, mask_file='', output_file='', dry=False):
    """弥散指标数值提取: mrstats"""
    if not dry and not os.path.isfile(input_file):
        print(f"[ERROR] 输入文件不存在: {input_file}")
        return
    cmd = f'mrstats {input_file}'
    if mask_file and (dry or os.path.isfile(mask_file)):
        cmd += f' -mask {mask_file}'
    if output_file:
        cmd += f' -output {output_file}'
    cmd += ' -force'
    run_cmd(cmd, dry)


def run_mrclusterstats(input_file, design_file, contrast_file,
                       nshuffles=5000, output_prefix='', dry=False):
    """弥散指标统计分析: mrclusterstats"""
    if not dry:
        for f in [input_file, design_file, contrast_file]:
            if not os.path.isfile(f):
                print(f"[ERROR] 文件不存在: {f}")
                return
    cmd = (
        f'mrclusterstats {input_file} {design_file} {contrast_file} '
        f'-nshuffles {nshuffles}'
    )
    if output_prefix:
        cmd += f' -output {output_prefix}'
    cmd += ' -force'
    run_cmd(cmd, dry)


def run_connectomestats(input_file, design_file, contrast_file,
                        nshuffles=5000, dry=False):
    """连接网络统计分析: connectomestats"""
    if not dry and not os.path.isfile(input_file):
        print(f"[ERROR] 输入文件不存在: {input_file}")
        return
    cmd = (
        f'connectomestats {input_file} {design_file} {contrast_file} '
        f'-nshuffles {nshuffles} -force'
    )
    run_cmd(cmd, dry)


def run_tckstats(input_file, output_file='', dump_file='', dry=False):
    """纤维指标数值提取: tckstats"""
    if not dry and not os.path.isfile(input_file):
        print(f"[ERROR] 输入文件不存在: {input_file}")
        return
    cmd = f'tckstats {input_file}'
    if output_file:
        cmd += f' -output {output_file}'
    if dump_file:
        cmd += f' -dump {dump_file}'
    cmd += ' -force'
    run_cmd(cmd, dry)
