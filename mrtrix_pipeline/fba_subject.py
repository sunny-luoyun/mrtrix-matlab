"""FBA 步骤1: 个体水平处理

与 MATLAB fba_subject.m 的 start_ButtonPushed 一致:
    step1_resp → step2_respmean → step3_upsample → step4_mask → step5_csd → step6_normalise
"""

import os
from .utils import run_cmd, find_subjects, find_dwi_files, mkdir_p


def step1_resp(work_path, sub_list, algorithm, params):
    """dwi2response"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        dwi = find_dwi_files(sub_dir)
        if not dwi:
            continue

        if algorithm == 'dhollander':
            cmd = (
                f'dwi2response dhollander {dwi} '
                f'{os.path.join(sub_dir, "response_wm.txt")} '
                f'{os.path.join(sub_dir, "response_gm.txt")} '
                f'{os.path.join(sub_dir, "response_csf.txt")} '
                f'-erode {params.get("erode", 2)} '
                f'-fa {params.get("fa", 0.2)} '
                f'-sfwm {params.get("sfwm", 0.5)} '
                f'-gm {params.get("gm", 2)} '
                f'-csf {params.get("csf", 10)} -force'
            )
        else:
            cmd = (
                f'dwi2response tournier {dwi} '
                f'{os.path.join(sub_dir, "response_wm.txt")} '
                f'-max_iters {params.get("max_iters", 100)} '
                f'-sfwm {params.get("sfwm", 1000)} '
                f'-next_fiber {params.get("next_fiber", 10000)} '
                f'-change {params.get("change", 1.0)} -force'
            )
        run_cmd(cmd)


def step2_respmean(work_path, algorithm):
    """responsemean 群体平均"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    fba_dir = os.path.join(work_path, 'fba')
    subs = find_subjects(fba_sub_dir)
    if not subs:
        return

    wm_files = [os.path.join(fba_sub_dir, s, 'response_wm.txt') for s in subs
                if os.path.isfile(os.path.join(fba_sub_dir, s, 'response_wm.txt'))]
    if wm_files:
        out = os.path.join(fba_dir, 'group_average_response_wm.txt')
        run_cmd(f'responsemean {" ".join(wm_files)} {out} -force')

    if algorithm == 'dhollander':
        gm_files = [os.path.join(fba_sub_dir, s, 'response_gm.txt') for s in subs
                    if os.path.isfile(os.path.join(fba_sub_dir, s, 'response_gm.txt'))]
        csf_files = [os.path.join(fba_sub_dir, s, 'response_csf.txt') for s in subs
                     if os.path.isfile(os.path.join(fba_sub_dir, s, 'response_csf.txt'))]
        if gm_files:
            run_cmd(f'responsemean {" ".join(gm_files)} {os.path.join(fba_dir, "group_average_response_gm.txt")} -force')
        if csf_files:
            run_cmd(f'responsemean {" ".join(csf_files)} {os.path.join(fba_dir, "group_average_response_csf.txt")} -force')


def step3_upsample(work_path, sub_list, voxel_size):
    """mrgrid regrid 上采样"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        dwi = find_dwi_files(sub_dir)
        if not dwi:
            continue
        out = os.path.join(sub_dir, 'dwi_upsampled.mif')
        cmd = f'mrgrid {dwi} regrid -voxel {voxel_size} {out} -force'
        run_cmd(cmd)


def step4_mask(work_path, sub_list):
    """dwi2mask"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        up = os.path.join(sub_dir, 'dwi_upsampled.mif')
        dwi = up if os.path.isfile(up) else find_dwi_files(sub_dir)
        if not dwi:
            continue
        out = os.path.join(sub_dir, 'dwi_mask_upsampled.mif')
        run_cmd(f'dwi2mask {dwi} {out} -force')


def step5_csd(work_path, sub_list, csd_algo):
    """dwi2fod"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    fba_dir = os.path.join(work_path, 'fba')
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        up = os.path.join(sub_dir, 'dwi_upsampled.mif')
        dwi = up if os.path.isfile(up) else find_dwi_files(sub_dir)
        if not dwi:
            continue
        mask = os.path.join(sub_dir, 'dwi_mask_upsampled.mif')
        if not os.path.isfile(mask):
            mask = os.path.join(sub_dir, 'dwi_mask.mif')
        if not os.path.isfile(mask):
            run_cmd(f'dwi2mask {dwi} {mask} -force')

        if csd_algo == 'msmt_csd':
            cmd = (
                f'dwi2fod msmt_csd {dwi} '
                f'{os.path.join(fba_dir, "group_average_response_wm.txt")} '
                f'{os.path.join(sub_dir, "wmfod.mif")} '
                f'{os.path.join(fba_dir, "group_average_response_gm.txt")} '
                f'{os.path.join(sub_dir, "gm.mif")} '
                f'{os.path.join(fba_dir, "group_average_response_csf.txt")} '
                f'{os.path.join(sub_dir, "csf.mif")} '
                f'-mask {mask} -force'
            )
        else:
            cmd = (
                f'dwi2fod csd {dwi} '
                f'{os.path.join(fba_dir, "group_average_response_wm.txt")} '
                f'{os.path.join(sub_dir, "wmfod.mif")} '
                f'-mask {mask} -force'
            )
        run_cmd(cmd)


def step6_normalise(work_path, sub_list, csd_algo):
    """mtnormalise"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        wmfod = os.path.join(sub_dir, 'wmfod.mif')
        if not os.path.isfile(wmfod):
            continue

        wmfod_norm = os.path.join(sub_dir, 'wmfod_norm.mif')
        mask = os.path.join(sub_dir, 'dwi_mask_upsampled.mif')
        if not os.path.isfile(mask):
            mask = os.path.join(sub_dir, 'dwi_mask.mif')

        if csd_algo == 'msmt_csd':
            cmd = (
                f'mtnormalise {wmfod} {wmfod_norm} '
                f'{os.path.join(sub_dir, "gm.mif")} {os.path.join(sub_dir, "gm_norm.mif")} '
                f'{os.path.join(sub_dir, "csf.mif")} {os.path.join(sub_dir, "csf_norm.mif")} '
                f'-mask {mask} -force'
            )
        else:
            cmd = f'mtnormalise {wmfod} {wmfod_norm} -mask {mask} -force'
        run_cmd(cmd)


# ── 管线编排 ──────────────────────────────────────────────────


def run(work_path, csd='msmt', voxel=1.25, sub_list=None,
        dry=False, no_resp=False, no_respmean=False,
        no_upsample=False, no_csd=False, no_norm=False):
    """执行 FBA 个体水平处理"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    if not os.path.isdir(fba_sub_dir):
        print(f"[ERROR] 无 fba/subjects 目录: {fba_sub_dir}")
        print("[HINT]  请先运行 'fba organize'")
        return

    if not sub_list:
        sub_list = find_subjects(fba_sub_dir)
        if not sub_list:
            print("[ERROR] fba/subjects 下无被试")
            return

    is_mt = (csd == 'msmt')
    algorithm = 'dhollander' if is_mt else 'tournier'
    voxel_size = f'{voxel},{voxel},{voxel}'

    print(f"[INFO] FBA 个体水平处理")
    print(f"[INFO] 工作路径: {work_path}")
    print(f"[INFO] 被试: {', '.join(sub_list)}")
    print(f"[INFO] CSD: {csd}, 体素: {voxel}mm")

    from .utils import Timer
    with Timer('个体水平处理'):
        if not no_resp:
            print("\n[INFO] 步骤1/4: 计算响应函数...")
            params = {'erode': 2, 'fa': 0.2, 'sfwm': 0.5, 'gm': 2, 'csf': 10,
                      'max_iters': 100, 'sfwm': 1000, 'next_fiber': 10000, 'change': 1.0}
            step1_resp(work_path, sub_list, algorithm, params)

        if not no_respmean:
            print("\n[INFO] 计算群体平均响应函数...")
            step2_respmean(work_path, algorithm)

        if not no_upsample:
            print("\n[INFO] 步骤2/4: 上采样 DWI...")
            step3_upsample(work_path, sub_list, voxel_size)
            print("[INFO] 计算上采样后 mask...")
            step4_mask(work_path, sub_list)

        if not no_csd:
            print(f"\n[INFO] 步骤3/4: CSD 计算 ({csd})...")
            step5_csd(work_path, sub_list, f'msmt_csd' if is_mt else 'csd')

        if not no_norm:
            print("\n[INFO] 步骤4/4: 归一化...")
            step6_normalise(work_path, sub_list, f'msmt_csd' if is_mt else 'csd')

    print("\n[INFO] 个体水平处理完成！")
    print(f"[INFO] 结果保存在: {fba_sub_dir}")
