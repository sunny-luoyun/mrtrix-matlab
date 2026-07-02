"""弥散指标计算 (DTI/DKI)

与 MATLAB dti.m 一致:
    dt → dkt → fa → ad → rd → adc → cl → cp → cs → mk → ak → rk
"""

import os
from .utils import run_cmd, find_subjects


def dt_step(sub_name, work_dir, startname):
    """弥散张量拟合: dwi2tensor"""
    sub_dir = os.path.join(work_dir, startname, sub_name)
    dt_dir = os.path.join(work_dir, 'dt', sub_name)
    os.makedirs(dt_dir, exist_ok=True)
    in_file = os.path.join(sub_dir, 'dwi.mif')
    out_file = os.path.join(dt_dir, 'dt.mif')
    cmd = f'dwi2tensor {in_file} {out_file} -force'
    return dt_dir, [cmd]


def dkt_step(sub_name, work_dir, startname):
    """弥散峰度张量拟合: dwi2fod → tensor2metric"""
    sub_dir = os.path.join(work_dir, startname, sub_name)
    dkt_dir = os.path.join(work_dir, 'dkt', sub_name)
    os.makedirs(dkt_dir, exist_ok=True)
    in_file = os.path.join(sub_dir, 'dwi.mif')
    out_file = os.path.join(dkt_dir, 'dki.mif')
    cmd = f'dwi2fod csd {in_file} -dkt {out_file} -force'
    return dkt_dir, [cmd]


def metric_step(sub_name, work_dir, metric_func):
    """通用指标计算: tensor2metric"""
    sub_dir = os.path.join(work_dir, 'dt', sub_name)
    dt_file = os.path.join(sub_dir, 'dt.mif')
    if not os.path.isfile(dt_file):
        return None, []
    out_dir = os.path.join(work_dir, 'dti', sub_name)
    os.makedirs(out_dir, exist_ok=True)

    metric_map = {
        'fa': '-fa',
        'ad': '-ad',
        'rd': '-rd',
        'adc': '-adc',
        'cl': '-cl',
        'cp': '-cp',
        'cs': '-cs',
    }
    flag = metric_map.get(metric_func)
    if flag is None:
        return None, []
    out_file = os.path.join(out_dir, f'{metric_func}.mif')
    cmd = f'tensor2metric {dt_file} {flag} {out_file} -force'
    return out_dir, [cmd]


def kurtosis_step(sub_name, work_dir, kt_func):
    """峰度指标计算"""
    sub_dir = os.path.join(work_dir, 'dkt', sub_name)
    dkt_file = os.path.join(sub_dir, 'dki.mif')
    if not os.path.isfile(dkt_file):
        return None, []
    out_dir = os.path.join(work_dir, 'dti', sub_name)
    os.makedirs(out_dir, exist_ok=True)

    metric_map = {
        'mk': '-mk',
        'ak': '-ak',
        'rk': '-rk',
    }
    flag = metric_map.get(kt_func)
    if flag is None:
        return None, []
    out_file = os.path.join(out_dir, f'{kt_func}.mif')
    cmd = f'tensor2metric {dkt_file} {flag} {out_file} -force'
    return out_dir, [cmd]


# ── 管线编排 ──────────────────────────────────────────────────


def run(work_dir, folder, sub_list, dry=False,
        dt=True, fa=True, ad=False, rd=False, adc=False,
        cl=False, cp=False, cs=False,
        dkt=False, mk=False, ak=False, rk=False):
    """执行弥散指标计算"""

    full_path = os.path.join(work_dir, folder) if folder else work_dir
    if not dry and not os.path.isdir(full_path):
        print(f"[ERROR] 路径不存在: {full_path}")
        return

    if not sub_list:
        if not dry:
            sub_list = find_subjects(full_path)
        if not sub_list:
            sub_list = ['Sub01', 'Sub02'] if dry else sub_list
            if not sub_list:
                print(f"[ERROR] 未找到被试文件夹: {full_path}")
                return

    print(f"[INFO] 工作路径: {work_dir}")
    print(f"[INFO] 被试: {', '.join(sub_list)}")

    for sub in sub_list:
        print(f"\n{'='*50}")
        print(f"[INFO] 处理: {sub}")

        startname = folder

        # 张量拟合
        if dt:
            _, cmds = dt_step(sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)
            startname = 'dt'

        # 弥散张量指标
        for met, enabled in [('fa', fa), ('ad', ad), ('rd', rd),
                              ('adc', adc), ('cl', cl), ('cp', cp), ('cs', cs)]:
            if enabled:
                _, cmds = metric_step(sub, work_dir, met)
                for c in cmds:
                    run_cmd(c, dry)

        # 峰度张量拟合
        if dkt:
            _, cmds = dkt_step(sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

        # 峰度指标
        for kt, enabled in [('mk', mk), ('ak', ak), ('rk', rk)]:
            if enabled:
                _, cmds = kurtosis_step(sub, work_dir, kt)
                for c in cmds:
                    run_cmd(c, dry)

    print(f"[INFO] DTI 计算完成")
