"""纤维追踪与后处理

与 MATLAB fiber.m 一致:
    tckgen (多种算法+模式) → tcksift2 → tcksift → tckmap
"""

import os
from .utils import run_cmd, find_subjects, find_mask_file, mkdir_p

ALGO_MAP = {
    'ifod2': 'iFOD2',
    'sd_stream': 'SD_Stream',
    'tensor_det': 'Tensor_Det',
    'tensor_prob': 'Tensor_Prob',
    'fact': 'FACT',
}


def fiberbuild_step(sub_dir, sub_name, work_dir, startname,
                    algo, mode, step_size, angle, min_len, max_len,
                    fod_cutoff, max_tries, fiber_num, seeds,
                    roi, mask_path):
    """纤维追踪: tckgen"""
    fod_file = os.path.join(sub_dir, 'wmfod_norm.mif')
    if not os.path.isfile(fod_file):
        fod_file = os.path.join(sub_dir, 'wmfod.mif')
    if not os.path.isfile(fod_file):
        print(f"[WARN] 无 FOD 文件: {sub_dir}")
        return None, []

    fiber_dir = mkdir_p(os.path.join(work_dir, 'fiber', sub_name))
    out_tck = os.path.join(fiber_dir, 'tracks.tck')

    algo_name = ALGO_MAP.get(algo, algo)
    cmd = f'tckgen -algorithm {algo_name} {fod_file} {out_tck}'

    # 追踪参数
    cmd += f' -step {step_size} -angle {angle} -minlength {min_len} -maxlength {max_len}'
    cmd += f' -fod_cutoff {fod_cutoff} -trials {max_tries} -seeds {seeds}'
    cmd += f' -select {fiber_num} -force'

    # 追踪模式
    if mode == 'whole_brain':
        mask = find_mask_file(sub_dir)
        if mask:
            cmd += f' -mask {mask}'
    elif mode == 'seed':
        cmd += f' -seed_image {sub_dir}/{roi}' if not os.path.isabs(roi) else f' -seed_image {roi}'
    elif mode == 'roi':
        cmd += f' -roi {roi}'
    elif mode == 'mask':
        mask = mask_path or find_mask_file(sub_dir)
        if mask:
            cmd += f' -include {mask}'
        else:
            cmd += f' -mask {find_mask_file(sub_dir) or ""}'

    return fiber_dir, [cmd]


def sift2_step(sub_dir, work_dir, startname, fod_folder=None):
    """SIFT2 纤维权重: tcksift2"""
    tck_file = os.path.join(sub_dir, 'tracks.tck')
    fod_file = os.path.join(sub_dir, 'wmfod_norm.mif')
    if not os.path.isfile(fod_file):
        fod_file = os.path.join(sub_dir, 'wmfod.mif')
    if not os.path.isfile(tck_file) or not os.path.isfile(fod_file):
        return sub_dir, []
    out_csv = os.path.join(sub_dir, 'tracks_weights.csv')
    cmd = f'tcksift2 {tck_file} {fod_file} {out_csv} -force'
    return sub_dir, [cmd]


def sift_step(sub_dir, work_dir, startname, fod_folder=None, dec_num='1m'):
    """SIFT 缩减纤维: tcksift"""
    tck_file = os.path.join(sub_dir, 'tracks.tck')
    fod_file = os.path.join(sub_dir, 'wmfod_norm.mif')
    if not os.path.isfile(fod_file):
        fod_file = os.path.join(sub_dir, 'wmfod.mif')
    if not os.path.isfile(tck_file) or not os.path.isfile(fod_file):
        return sub_dir, []
    out_tck = os.path.join(sub_dir, 'tracks_sift.tck')
    cmd = f'tcksift {tck_file} {fod_file} {out_tck} -select {dec_num} -force'
    return sub_dir, [cmd]


def tck2nii_step(sub_dir, sub_name, work_dir, startname,
                 method='tdi', smooth=0, use_weight=False, gaussian_smooth=False):
    """tck → nii 映射: tckmap"""
    tck_file = os.path.join(sub_dir, 'tracks.tck')
    if not os.path.isfile(tck_file) and os.path.isfile(os.path.join(sub_dir, 'tracks_sift.tck')):
        tck_file = os.path.join(sub_dir, 'tracks_sift.tck')
    if not os.path.isfile(tck_file):
        return sub_dir, []

    map_dir = mkdir_p(os.path.join(work_dir, 'fiber_map', sub_name))
    out_nii = os.path.join(map_dir, 'tdi.nii.gz')

    cmd = f'tckmap {tck_file} {out_nii} -template {find_mask_file(sub_dir) or sub_dir}'

    if method == 'tdi':
        pass
    else:
        cmd += f' -{method}'

    if smooth > 0 and gaussian_smooth:
        cmd += f' -smooth {smooth}'
    if use_weight:
        csv = os.path.join(sub_dir, 'tracks_weights.csv')
        if os.path.isfile(csv):
            cmd += f' -tck_weights {csv}'

    cmd += ' -force'
    return map_dir, [cmd]


# ── 管线编排 ──────────────────────────────────────────────────


def run(work_dir, folder, sub_list, dry=False,
        algo='ifod2', mode='whole_brain',
        step_size=0.5, angle=45, min_length=2, max_length=100,
        fod_cutoff=0.1, max_tries=1000, fiber_num='10m', seeds='10m',
        sift=False, sift_num='1m', sift2=False,
        tck2nii=False, tck2nii_method='tdi',
        **kwargs):
    """执行纤维追踪管线"""
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

    print(f"[INFO] 工作路径: {work_dir}")
    print(f"[INFO] 被试: {', '.join(sub_list)}")
    print(f"[INFO] 算法: {algo}, 模式: {mode}")

    for sub in sub_list:
        print(f"\n{'='*50}")
        print(f"[INFO] 处理被试: {sub}")
        sub_dir = os.path.join(full_path, sub)

        # 1. 纤维追踪
        fiber_dir, cmds = fiberbuild_step(
            sub_dir, sub, work_dir, folder,
            algo, mode, step_size, angle, min_length, max_length,
            fod_cutoff, max_tries, fiber_num, seeds,
            roi=kwargs.get('roi', ''), mask_path=kwargs.get('mask_path', ''),
        )
        for c in cmds:
            run_cmd(c, dry)

        current_path = fiber_dir or sub_dir
        startname = 'fiber'

        # 2. SIFT2 权重
        if sift2:
            current_path, cmds = sift2_step(current_path, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

        # 3. SIFT 缩减
        if sift:
            current_path, cmds = sift_step(current_path, work_dir, startname, dec_num=sift_num)
            for c in cmds:
                run_cmd(c, dry)

        # 4. tck → nii
        if tck2nii:
            _, cmds = tck2nii_step(current_path, sub, work_dir, startname,
                                   method=tck2nii_method)
            for c in cmds:
                run_cmd(c, dry)

    print(f"[INFO] 纤维追踪完成")
