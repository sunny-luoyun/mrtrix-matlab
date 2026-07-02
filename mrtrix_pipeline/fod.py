"""反卷积响应函数 + FOD 计算

与 MATLAB fod.m 一致:
    响应函数: dhollander / fa / msmt_5tt / tax / tournier
    FOD:      csd / msmt_csd
    标准化:   mtnormalise
"""

import os
from .utils import run_cmd, find_subjects, find_dwi_files, find_mask_file, mkdir_p


def dhollander_step(sub_dir, params):
    """dwi2response dhollander 多组织响应函数"""
    dwi = find_dwi_files(sub_dir)
    if not dwi:
        return []
    out_wm = os.path.join(sub_dir, 'response_wm.txt')
    out_gm = os.path.join(sub_dir, 'response_gm.txt')
    out_csf = os.path.join(sub_dir, 'response_csf.txt')
    cmd = (
        f'dwi2response dhollander {dwi} {out_wm} {out_gm} {out_csf} '
        f'-erode {params.get("erode", 2)} '
        f'-fa {params.get("fa", 0.2)} '
        f'-sfwm {params.get("sfwm", 0.5)} '
        f'-gm {params.get("gm", 2)} '
        f'-csf {params.get("csf", 10)} -force'
    )
    return [cmd]


def fa_response_step(sub_dir, params):
    """基于 FA 的响应函数"""
    dwi = find_dwi_files(sub_dir)
    if not dwi:
        return []
    mask = find_mask_file(sub_dir)
    out_resp = os.path.join(sub_dir, 'response_wm.txt')
    cmd = f'dwi2response fa {dwi} {out_resp}'
    if mask:
        cmd += f' -mask {mask}'
    cmd += f' -fa {params.get("fa", 0.2)} -sfwm {params.get("sfwm", 1000)} -force'
    return [cmd]


def tournier_step(sub_dir, params):
    """dwi2response tournier"""
    dwi = find_dwi_files(sub_dir)
    if not dwi:
        return []
    out_resp = os.path.join(sub_dir, 'response_wm.txt')
    cmd = (
        f'dwi2response tournier {dwi} {out_resp} '
        f'-max_iters {params.get("max_iters", 100)} '
        f'-sfwm {params.get("sfwm", 1000)} '
        f'-next_fiber {params.get("next_fiber", 10000)} '
        f'-change {params.get("change", 1.0)} -force'
    )
    return [cmd]


def respmean_step(work_dir, algorithm):
    """群体平均响应函数: responsemean"""
    fba_dir = os.path.join(work_dir, 'fba')
    subjects_dir = os.path.join(fba_dir, 'subjects')
    subs = find_subjects(subjects_dir)
    if not subs:
        print("[WARN] fba/subjects 下无被试，跳过群体平均")
        return []

    resp_files = []
    for s in subs:
        f = os.path.join(subjects_dir, s, 'response_wm.txt')
        if os.path.isfile(f):
            resp_files.append(f)

    if not resp_files:
        print("[WARN] 无 response_wm.txt 文件，跳过群体平均")
        return []

    ext = '_wm' if algorithm in ('msmt_csd', 'msmt') else ''
    out = os.path.join(fba_dir, f'group_average_response{ext}.txt')
    cmd = f'responsemean {" ".join(resp_files)} {out} -force'

    # 多组织另外处理 gm 和 csf
    cmds = [cmd]
    if algorithm in ('msmt_csd', 'msmt'):
        gm_files = []
        csf_files = []
        for s in subs:
            gf = os.path.join(subjects_dir, s, 'response_gm.txt')
            cf = os.path.join(subjects_dir, s, 'response_csf.txt')
            if os.path.isfile(gf):
                gm_files.append(gf)
            if os.path.isfile(cf):
                csf_files.append(cf)
        if gm_files:
            cmds.append(f'responsemean {" ".join(gm_files)} {os.path.join(fba_dir, "group_average_response_gm.txt")} -force')
        if csf_files:
            cmds.append(f'responsemean {" ".join(csf_files)} {os.path.join(fba_dir, "group_average_response_csf.txt")} -force')

    return cmds


def csd_step(sub_dir, work_dir, algo):
    """FOD 计算: dwi2fod csd / msmt_csd"""
    dwi = find_dwi_files(sub_dir)
    if not dwi:
        return []
    mask = find_mask_file(sub_dir)
    if not mask:
        mask = os.path.join(sub_dir, 'dwi_mask_upsampled.mif')
        if not os.path.isfile(mask):
            print(f"[WARN] 无 mask 文件，由 dwi2mask 生成: {mask}")
            run_cmd(f'dwi2mask {dwi} {mask} -force')

    fba_dir = os.path.join(work_dir, 'fba')
    wmfod = os.path.join(sub_dir, 'wmfod.mif')

    if algo == 'msmt_csd':
        cmd = (
            f'dwi2fod msmt_csd {dwi} '
            f'{os.path.join(fba_dir, "group_average_response_wm.txt")} {wmfod} '
            f'{os.path.join(fba_dir, "group_average_response_gm.txt")} {os.path.join(sub_dir, "gm.mif")} '
            f'{os.path.join(fba_dir, "group_average_response_csf.txt")} {os.path.join(sub_dir, "csf.mif")} '
            f'-mask {mask} -force'
        )
    else:
        cmd = (
            f'dwi2fod csd {dwi} '
            f'{os.path.join(fba_dir, "group_average_response_wm.txt")} {wmfod} '
            f'-mask {mask} -force'
        )
    return [cmd]


def normalise_step(sub_dir, work_dir, is_multi):
    """强度标准化: mtnormalise"""
    wmfod = os.path.join(sub_dir, 'wmfod.mif')
    if not os.path.isfile(wmfod):
        return []
    wmfod_norm = os.path.join(sub_dir, 'wmfod_norm.mif')

    if is_multi:
        cmd = (
            f'mtnormalise {wmfod} {wmfod_norm} '
            f'{os.path.join(sub_dir, "gm.mif")} {os.path.join(sub_dir, "gm_norm.mif")} '
            f'{os.path.join(sub_dir, "csf.mif")} {os.path.join(sub_dir, "csf_norm.mif")} '
            f'-mask {find_mask_file(sub_dir) or ""} -force'
        )
    else:
        cmd = f'mtnormalise {wmfod} {wmfod_norm} -mask {find_mask_file(sub_dir) or ""} -force'
    return [cmd]


# ── 管线编排 ──────────────────────────────────────────────────


def run(work_dir, folder, sub_list, dry=False,
        resp=True, resp_algo='dhollander',
        fod=True, fod_algo='msmt_csd',
        norm=True):
    """执行 FOD 管线"""
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
    print(f"[INFO] 被试: {', '.join(sub_list)}")
    print(f"[INFO] 响应函数: {resp_algo}, FOD: {fod_algo}")

    for sub in sub_list:
        print(f"\n{'='*50}")
        print(f"[INFO] 处理被试: {sub}")
        sub_dir = os.path.join(full_path, sub)

        if resp:
            params = {'erode': 2, 'fa': 0.2, 'sfwm': 0.5, 'gm': 2, 'csf': 10,
                      'max_iters': 100, 'next_fiber': 10000, 'change': 1.0}
            step_map = {
                'dhollander': dhollander_step,
                'fa': fa_response_step,
                'tournier': tournier_step,
            }
            step_func = step_map.get(resp_algo)
            if step_func:
                cmds = step_func(sub_dir, params)
                for c in cmds:
                    run_cmd(c, dry)

        if fod:
            cmds = csd_step(sub_dir, work_dir, fod_algo)
            for c in cmds:
                run_cmd(c, dry)

        if norm:
            cmds = normalise_step(sub_dir, work_dir, is_multi)
            for c in cmds:
                run_cmd(c, dry)

    print(f"[INFO] FOD 计算完成")
