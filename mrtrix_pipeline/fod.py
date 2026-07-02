"""反卷积响应函数 + FOD 计算（与 MATLAB 完全一致）

算法目录:
  dhollander → fod_d/<sub>/
  tournier   → fod_to/<sub>/
  fa         → fod_fa/<sub>/
  msmt_5tt   → msmt_5tt/<sub>/
  tax        → fod_tax/<sub>/

每个算法目录先 copy dwi.mif 再输出响应函数文件。

FOD 计算（在同目录）:
  csd       → fod.mif      (单组织)
  msmt_csd  → wmfod/gmfod/csffod.mif  (多组织)

标准化:
  多组织 → wmfod_norm.mif + csffod_norm.mif
  单组织 → fod_norm.mif
"""

import os
import shutil
from .utils import run_cmd, find_subjects, mkdir_p, find_dwi_files, find_mask_file


def _copy_dwi(src_dir, dst_dir, sub_name):
    """复制 dwi.mif 到输出目录（MATLAB 行为）"""
    src = os.path.join(src_dir, 'dwi.mif')
    dst = os.path.join(dst_dir, 'dwi.mif')
    if os.path.isfile(src) and not os.path.isfile(dst):
        shutil.copy2(src, dst)
    return dst


def dhollander_step(src_dir, sub_name, work_dir, params):
    """dwi2response dhollander → fod_d/<sub>/wm.txt gm.txt csf.txt"""
    out_dir = mkdir_p(os.path.join(work_dir, 'fod_d', sub_name))
    _copy_dwi(src_dir, out_dir, sub_name)
    cmd = (
        f'dwi2response dhollander {os.path.join(out_dir, "dwi.mif")} '
        f'{os.path.join(out_dir, "wm.txt")} '
        f'{os.path.join(out_dir, "gm.txt")} '
        f'{os.path.join(out_dir, "csf.txt")} '
        f'-erode {params.get("erode", 2)} '
        f'-fa {params.get("fa", 0.2)} '
        f'-sfwm {params.get("sfwm", 0.5)} '
        f'-gm {params.get("gm", 2)} '
        f'-csf {params.get("csf", 10)} -force'
    )
    return out_dir, [cmd]


def fa_response_step(src_dir, sub_name, work_dir, params):
    """dwi2response fa → fod_fa/<sub>/wm.txt"""
    out_dir = mkdir_p(os.path.join(work_dir, 'fod_fa', sub_name))
    _copy_dwi(src_dir, out_dir, sub_name)
    cmd = (
        f'dwi2response fa {os.path.join(out_dir, "dwi.mif")} '
        f'{os.path.join(out_dir, "wm.txt")} '
        f'-fa {params.get("fa", 0.2)} '
        f'-sfwm {params.get("sfwm", 1000)} -force'
    )
    return out_dir, [cmd]


def tournier_step(src_dir, sub_name, work_dir, params):
    """dwi2response tournier → fod_to/<sub>/resp.txt"""
    out_dir = mkdir_p(os.path.join(work_dir, 'fod_to', sub_name))
    _copy_dwi(src_dir, out_dir, sub_name)
    cmd = (
        f'dwi2response tournier {os.path.join(out_dir, "dwi.mif")} '
        f'{os.path.join(out_dir, "resp.txt")} '
        f'-number {params.get("number", 1000)} '
        f'-iter_voxels {params.get("next_fiber", 10000)} '
        f'-max_iters {params.get("max_iters", 100)} -force'
    )
    return out_dir, [cmd]


def csd_step(current_path):
    """dwi2fod csd → fod.mif（使用当前目录的 resp.txt）"""
    dwi = os.path.join(current_path, 'dwi.mif')
    resp = os.path.join(current_path, 'resp.txt')
    if not os.path.isfile(resp):
        resp = os.path.join(current_path, 'wm.txt')
    out = os.path.join(current_path, 'fod.mif')
    cmd = f'dwi2fod csd {dwi} {resp} {out} -force'
    return current_path, [cmd]


def msmt_step(current_path):
    """dwi2fod msmt_csd → wmfod.mif + gmfod.mif + csffod.mif"""
    dwi = os.path.join(current_path, 'dwi.mif')
    wm = os.path.join(current_path, 'wm.txt')
    gm = os.path.join(current_path, 'gm.txt')
    csf = os.path.join(current_path, 'csf.txt')
    cmd = (
        f'dwi2fod msmt_csd {dwi} '
        f'{wm} {os.path.join(current_path, "wmfod.mif")} '
        f'{gm} {os.path.join(current_path, "gmfod.mif")} '
        f'{csf} {os.path.join(current_path, "csffod.mif")} -force'
    )
    return current_path, [cmd]


def normalise_step(current_path, sub_name, work_dir, is_multi):
    """mtnormalise"""
    mask = os.path.join(work_dir, 'mask', sub_name, 'mask.mif')
    if not os.path.isfile(mask):
        print(f"  [WARN] mask 不存在: {mask}")
        return []
    if is_multi:
        wmfod = os.path.join(current_path, 'wmfod.mif')
        csffod = os.path.join(current_path, 'csffod.mif')
        if not os.path.isfile(wmfod) or not os.path.isfile(csffod):
            return []
        wm_norm = os.path.join(current_path, 'wmfod_norm.mif')
        csf_norm = os.path.join(current_path, 'csffod_norm.mif')
        cmd = f'mtnormalise {wmfod} {wm_norm} {csffod} {csf_norm} -mask {mask} -force'
    else:
        fod = os.path.join(current_path, 'fod.mif')
        if not os.path.isfile(fod):
            return []
        fod_norm = os.path.join(current_path, 'fod_norm.mif')
        cmd = f'mtnormalise {fod} {fod_norm} -mask {mask} -force'
    return [cmd]


def run(work_dir, folder, sub_list, dry=False,
        resp=True, resp_algo='dhollander',
        fod=True, fod_algo='msmt_csd',
        norm=True):
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
                print(f"[ERROR] 未找到被试: {full_path}")
                return

    is_multi = (fod_algo == 'msmt_csd')
    print(f"[INFO] 工作路径: {work_dir}")
    print(f"[INFO] 响应函数: {resp_algo}, FOD: {fod_algo}")

    for sub in sub_list:
        print(f"\n{'='*50}")
        print(f"[INFO] 处理被试: {sub}")
        src_dir = os.path.join(full_path, sub)
        current_path = src_dir

        if resp:
            params = {'erode': 2, 'fa': 0.2, 'sfwm': 0.5, 'gm': 2, 'csf': 10,
                      'max_iters': 100, 'number': 1000, 'next_fiber': 10000, 'change': 1.0}
            step_map = {
                'dhollander': dhollander_step,
                'fa': fa_response_step,
                'tournier': tournier_step,
            }
            step_func = step_map.get(resp_algo)
            if step_func:
                current_path, cmds = step_func(src_dir, sub, work_dir, params)
                for c in cmds:
                    run_cmd(c, dry)

        if fod:
            if fod_algo == 'msmt_csd':
                current_path, cmds = msmt_step(current_path)
            else:
                current_path, cmds = csd_step(current_path)
            for c in cmds:
                run_cmd(c, dry)

        if norm:
            cmds = normalise_step(current_path, sub, work_dir, is_multi)
            for c in cmds:
                run_cmd(c, dry)

    print(f"[INFO] FOD 计算完成")
