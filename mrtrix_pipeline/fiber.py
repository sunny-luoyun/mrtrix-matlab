"""纤维追踪与后处理（与 MATLAB 完全一致）

追踪:
  fiber_{startname}/<sub>/tracks.tck

后处理（在当前纤维目录）:
  tcksift2 → sift_weight.txt
  tcksift  → tracks_sift.tck
  tckmap + mrtransform + mrconvert → Results/tracksMap/<sub>_<method>Map.nii
"""

import os
from .utils import run_cmd, find_subjects, mkdir_p, _find_project_root

ALGO_MAP = {
    'ifod2': 'iFOD2',
    'sd_stream': 'SD_Stream',
    'tensor_det': 'Tensor_Det',
    'tensor_prob': 'Tensor_Prob',
    'fact': 'FACT',
}


def _pick_fod(current_path):
    """自动选择 FOD 文件（MATLAB weightc.m 的 pickFODfile）"""
    for f in ['wmfod_norm.mif', 'fod_norm.mif', 'wmfod.mif', 'fod.mif']:
        fp = os.path.join(current_path, f)
        if os.path.isfile(fp):
            return fp
    return None


def fiberbuild_step(sub_dir, sub_name, work_dir, startname,
                    algo, mode, step_size, angle, min_len, max_len,
                    fod_cutoff, max_tries, fiber_num, seeds,
                    roi, mask_path):
    """纤维追踪: tckgen（MATLAB 完全一致）"""
    fiber_dir = mkdir_p(os.path.join(work_dir, f'fiber_{startname}', sub_name))
    fod = _pick_fod(sub_dir)
    if not fod:
        print(f"  [WARN] 无 FOD 文件: {sub_dir}")
        return None, []

    out_tck = os.path.join(fiber_dir, 'tracks.tck')
    algo_name = ALGO_MAP.get(algo, algo)

    cmd = f'tckgen -algorithm {algo_name} {fod} {out_tck}'
    cmd += f' -step {step_size} -angle {angle} -minlength {min_len} -maxlength {max_len}'
    cmd += f' -cutoff {fod_cutoff} -trials {max_tries} -seeds {seeds} -select {fiber_num}'

    act = os.path.join(work_dir, 'T1_corg', sub_name, '5tt_in_dwi.mif')
    gmwm = os.path.join(work_dir, 'T1_corg', sub_name, 'gmwmSeed_in_dwi.mif')
    if os.path.isfile(act) and os.path.isfile(gmwm):
        cmd += f' -act {act} -backtrack -seed_gmwmi {gmwm}'

    if mode == 'whole_brain':
        if not os.path.isfile(gmwm):
            cmd += f' -seed_dynamic {fod}'
    elif mode == 'seed':
        cmd += f' -seed_sphere {roi}'
    elif mode == 'mask':
        if mask_path:
            cmd += f' -seed_image {mask_path} -include {mask_path}'
    elif mode == 'roi':
        cmd += f' -seed_image {roi} -include {roi}'

    cmd += ' -force'
    return fiber_dir, [cmd]


def sift2_step(current_path, sub_dir):
    """tcksift2 → sift_weight.txt"""
    tck = os.path.join(current_path, 'tracks.tck')
    fod = _pick_fod(sub_dir)
    if not os.path.isfile(tck) or not fod:
        return []
    out = os.path.join(current_path, 'sift_weight.txt')
    return [f'tcksift2 {tck} {fod} {out} -force']


def sift_step(current_path, sub_dir, dec_num='1m'):
    """tcksift → tracks_sift.tck"""
    tck = os.path.join(current_path, 'tracks.tck')
    fod = _pick_fod(sub_dir)
    if not os.path.isfile(tck) or not fod:
        return []
    out = os.path.join(current_path, 'tracks_sift.tck')
    act = os.path.join(os.path.dirname(os.path.dirname(current_path)),
                       'T1_corg', os.path.basename(current_path), '5tt_in_dwi.mif')
    cmd = f'tcksift {tck} {fod} {out} -term_number {dec_num}'
    if os.path.isfile(act):
        cmd += f' -act {act}'
    cmd += ' -force'
    return [cmd]


def tck2nii_step(current_path, sub_name, work_dir, startname,
                 method='tdi', smooth=0, use_weight=False, gaussian_smooth=False):
    """tck → nii 映射（MATLAB 完全一致: tckmap → mrtransform → mrconvert）"""
    cmds = []
    tck = os.path.join(current_path, 'tracks.tck')
    tck_sift = os.path.join(current_path, 'tracks_sift.tck')

    root = _find_project_root()
    template_path = os.path.join(root, 'Templates', 'MNI152.nii.gz') if root else ''
    dwi_txt = os.path.join(work_dir, 'dwi_coreg', sub_name, 'dwi_to_MNI_mrtrix.txt')

    def _process_one(tck_file, prefix, method, smooth, use_weight, gaussian_smooth):
        nonlocal cmds
        if not os.path.isfile(tck_file):
            return
        name_tag = {'tdi': 'tdi'}.get(method, method)
        # tckmap → .mif（个体空间）
        mif_file = os.path.join(current_path, f'{prefix}_Map.mif')
        tck_cmd = f'tckmap {tck_file} {mif_file}'
        tck_cmd += f' -vox 1.0'
        if gaussian_smooth and smooth > 0:
            tck_cmd += f' -fwhm_tck {smooth}'
        else:
            tck_cmd += f' -contrast {method}'
        if use_weight:
            w = os.path.join(current_path, 'sift_weight.txt')
            if os.path.isfile(w):
                tck_cmd += f' -tck_weights_in {w}'
        tck_cmd += ' -force'
        cmds.append(tck_cmd)

        # mrtransform → MNI 空间 .mif
        mif_mni = os.path.join(current_path, f'{prefix}_Map_MNI.mif')
        if os.path.isfile(dwi_txt) and os.path.isfile(template_path):
            cmds.append(
                f'mrtransform {mif_file} -linear {dwi_txt} '
                f'-template {template_path} {mif_mni} -force'
            )
            # mrconvert → .nii
            suffix = f'_S{smooth}' if gaussian_smooth and smooth > 0 else ''
            result_dir = mkdir_p(os.path.join(work_dir, 'Results', f'{prefix}Map'))
            nii_out = os.path.join(
                result_dir, f'{sub_name}_{prefix}_{name_tag}Map{suffix}.nii'
            )
            cmds.append(f'mrconvert {mif_mni} {nii_out} -force')

    # 处理 tracks.tck
    _process_one(tck, 'tracks', method, smooth, use_weight, gaussian_smooth)
    # 处理 tracks_sift.tck
    _process_one(tck_sift, 'tracks_sift', method, smooth, use_weight, gaussian_smooth)

    return cmds


# ── 管线编排 ──────────────────────────────────────────────────


def run(work_dir, folder, sub_list, dry=False,
        algo='ifod2', mode='whole_brain',
        step_size=0.5, angle=45, min_length=2, max_length=100,
        fod_cutoff=0.1, max_tries=1000, fiber_num='10m', seeds='10m',
        sift2=False, sift=False, sift_num='1m',
        tck2nii=False, tck2nii_method='tdi',
        **kwargs):
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
    print(f"[INFO] 算法: {algo}, 模式: {mode}")

    for sub in sub_list:
        print(f"\n{'='*50}")
        print(f"[INFO] 处理被试: {sub}")
        sub_dir = os.path.join(full_path, sub)
        startname = folder

        fiber_dir, cmds = fiberbuild_step(
            sub_dir, sub, work_dir, startname,
            algo, mode, step_size, angle, min_length, max_length,
            fod_cutoff, max_tries, fiber_num, seeds,
            roi=kwargs.get('roi', ''), mask_path=kwargs.get('mask_path', ''),
        )
        for c in cmds:
            run_cmd(c, dry)

        current_path = fiber_dir or sub_dir

        if sift2:
            cmds = sift2_step(current_path, sub_dir)
            for c in cmds:
                run_cmd(c, dry)

        if sift:
            cmds = sift_step(current_path, sub_dir, dec_num=sift_num)
            for c in cmds:
                run_cmd(c, dry)

        if tck2nii:
            cmds = tck2nii_step(current_path, sub, work_dir, startname,
                                method=tck2nii_method)
            for c in cmds:
                run_cmd(c, dry)

    print(f"[INFO] 纤维追踪完成")
