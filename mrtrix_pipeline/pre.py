"""预处理管线（与 MATLAB 完全一致）

目录链（全部勾选时）:
  dwimif → +N(denoise) → +G(gibbs) → +H(headmove) → +B(bias)
  
独立于目录链的目录:
  T1mif/         ← change_format
  raw_b0/        ← headmove (从 dwimif/ 提取 b0)
  pred_b0/       ← dwitoMNI (从当前链目录提取 b0 均值)
  dwi_coreg/     ← dwitoMNI (DWI → MNI 配准)
  T1_corg/       ← T1corg (5tt 分割 + 配准到 DWI 空间)
  T1_coreg/      ← T1toMNI (T1 → MNI 配准)
  mask/          ← mask (dwi2mask + dilate)
"""

import os
import shutil
from .utils import run_cmd, find_subjects, mkdir_p, _find_project_root


def change_format_step(subject_dir, sub_name, work_dir, dry=False):
    """nii.gz → mif 格式转换，输出到 dwimif/<sub>/ 和 T1mif/<sub>/"""
    dwimif_dir = mkdir_p(os.path.join(work_dir, 'dwimif', sub_name), dry)
    t1mif_dir = mkdir_p(os.path.join(work_dir, 'T1mif', sub_name), dry)
    cmds = []
    bvec = os.path.join(subject_dir, f'{sub_name}dwi.bvec')
    bval = os.path.join(subject_dir, f'{sub_name}dwi.bval')
    dwi_nii = os.path.join(subject_dir, f'{sub_name}dwi.nii.gz')
    dwi_mif = os.path.join(dwimif_dir, 'dwi.mif')
    if dry or (os.path.isfile(dwi_nii) and os.path.isfile(bvec) and os.path.isfile(bval)):
        cmds.append(
            f'mrconvert -fslgrad {bvec} {bval} {dwi_nii} {dwi_mif} -force'
        )
    t1_nii = os.path.join(subject_dir, f'{sub_name}T1.nii.gz')
    t1_mif = os.path.join(t1mif_dir, 'T1.mif')
    if dry or os.path.isfile(t1_nii):
        cmds.append(f'mrconvert {t1_nii} {t1_mif} -force')
    return dwimif_dir, 'dwimif', cmds


def denoise_step(current_path, sub_name, work_dir, startname):
    """dwidenoise，输出到 {startname}N/<sub>/"""
    newstart = startname + 'N'
    out_dir = mkdir_p(os.path.join(work_dir, newstart, sub_name))
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    cmd = f'dwidenoise {in_file} {out_file} -force'
    return out_dir, newstart, [cmd]


def gibbs_step(current_path, sub_name, work_dir, startname):
    """mrdegibbs，输出到 {startname}G/<sub>/"""
    newstart = startname + 'G'
    out_dir = mkdir_p(os.path.join(work_dir, newstart, sub_name))
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    cmd = f'mrdegibbs {in_file} {out_file} -force'
    return out_dir, newstart, [cmd]


def headmove_step(current_path, sub_name, work_dir, startname):
    """头动矫正（MATLAB 完全一致: 从 dwimif/ 提取 b0，输出到 {startname}H/<sub>/）"""
    cmds = []
    raw_b0 = mkdir_p(os.path.join(work_dir, 'raw_b0', sub_name))
    dwimif_file = os.path.join(work_dir, 'dwimif', sub_name, 'dwi.mif')
    if os.path.isfile(dwimif_file):
        cmds.append(
            f'dwiextract {dwimif_file} - -bzero | '
            f'mrconvert - -coord 3 0 {os.path.join(raw_b0, "b0_PA.mif")} -force'
        )
        cmds.append(
            f'dwiextract {dwimif_file} - -bzero | '
            f'mrconvert - -coord 3 0 {os.path.join(raw_b0, "b0_AP.mif")} -force'
        )
        cmds.append(
            f'mrcat {os.path.join(raw_b0, "b0_PA.mif")} '
            f'{os.path.join(raw_b0, "b0_AP.mif")} '
            f'{os.path.join(raw_b0, "b0_pair.mif")} -force'
        )
    newstart = startname + 'H'
    out_dir = mkdir_p(os.path.join(work_dir, newstart, sub_name))
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    b0_pair = os.path.join(raw_b0, 'b0_pair.mif')
    cmds.append(
        f'dwifslpreproc {in_file} {out_file} '
        f'-pe_dir AP -rpe_pair -se_epi {b0_pair} '
        f'-eddy_options " --data_is_shelled --slm=linear --niter=5 " -force'
    )
    return out_dir, newstart, cmds


def bias_step(current_path, sub_name, work_dir, startname):
    """dwibiascorrect ants，输出到 {startname}B/<sub>/"""
    newstart = startname + 'B'
    out_dir = mkdir_p(os.path.join(work_dir, newstart, sub_name))
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    cmd = f'dwibiascorrect ants {in_file} {out_file} -force'
    return out_dir, newstart, [cmd]


def t1corg_step(current_path, sub_name, work_dir, startname):
    """T1 结构像分割 + 配准到 DWI 空间（MATLAB 完全一致）"""
    cmds = []
    out_dir = mkdir_p(os.path.join(work_dir, 'T1_corg', sub_name))
    t1_dir = os.path.join(work_dir, 'T1mif', sub_name)
    t1_mif = os.path.join(t1_dir, 'T1.mif')
    b0_path = os.path.join(work_dir, 'pred_b0', sub_name)
    mean_b0_nii = os.path.join(b0_path, 'mean_b0.nii.gz')
    t1_nii_path = os.path.join(t1_dir, 'T1.nii.gz')
    if not os.path.isfile(t1_nii_path) and os.path.isfile(t1_mif):
        cmds.append(f'mrconvert {t1_mif} {t1_nii_path} -force')
    cmds.append(f'5ttgen fsl {t1_nii_path} {os.path.join(out_dir, "5tt.mif")} -force')
    five_tt = os.path.join(out_dir, '5tt.mif')
    cmds.append(f'5tt2gmwmi {five_tt} {os.path.join(out_dir, "gmwmSeed.mif")} -force')
    cmds.append(
        f'flirt -in {t1_nii_path} -ref {mean_b0_nii} -dof 12 '
        f'-out {os.path.join(out_dir, "T1_in_DWI.nii.gz")} '
        f'-omat {os.path.join(out_dir, "T1_to_DWI_fsl.mat")}'
    )
    t1_fsl_mat = os.path.join(out_dir, 'T1_to_DWI_fsl.mat')
    t1_txt = os.path.join(out_dir, 'T1_to_DWI_mrtrix.txt')
    cmds.append(
        f'transformconvert {t1_fsl_mat} {t1_nii_path} {mean_b0_nii} '
        f'flirt_import {t1_txt} -force'
    )
    five_tt_in_dwi = os.path.join(out_dir, '5tt_in_dwi.mif')
    cmds.append(
        f'mrtransform {five_tt} -linear {t1_txt} '
        f'-template {mean_b0_nii} {five_tt_in_dwi} '
        f'-interp nearest -force'
    )
    gmwm = os.path.join(out_dir, 'gmwmSeed.mif')
    gmwm_in_dwi = os.path.join(out_dir, 'gmwmSeed_in_dwi.mif')
    cmds.append(
        f'mrtransform {gmwm} -linear {t1_txt} '
        f'-template {mean_b0_nii} {gmwm_in_dwi} '
        f'-interp nearest -force'
    )
    return out_dir, cmds


def t1_to_mni_step(sub_name, work_dir):
    """T1 → MNI 配准（MATLAB 完全一致）"""
    cmds = []
    out_dir = mkdir_p(os.path.join(work_dir, 'T1_coreg', sub_name))
    t1_dir = os.path.join(work_dir, 'T1mif', sub_name)
    t1_mif = os.path.join(t1_dir, 'T1.mif')
    t1_nii = os.path.join(t1_dir, 'T1.nii.gz')
    if os.path.isfile(t1_mif) and not os.path.isfile(t1_nii):
        cmds.append(f'mrconvert {t1_mif} {t1_nii} -force')
    root = _find_project_root()
    template_path = os.path.join(root, 'Templates', 'MNI152.nii.gz') if root else ''
    if not os.path.isfile(template_path):
        print(f"[WARN] MNI 模板不存在: {template_path}")
        return cmds
    if os.path.isfile(t1_nii):
        cmds.append(
            f'flirt -in {t1_nii} -ref {template_path} -dof 12 '
            f'-out {os.path.join(out_dir, "T1_coreg.nii.gz")} '
            f'-omat {os.path.join(out_dir, "T1_to_MNI_fsl.mat")}'
        )
    fsl_mat = os.path.join(out_dir, 'T1_to_MNI_fsl.mat')
    if os.path.isfile(fsl_mat) and os.path.isfile(t1_nii):
        cmds.append(
            f'transformconvert {fsl_mat} {t1_nii} {template_path} '
            f'flirt_import {os.path.join(out_dir, "T1_to_MNI_mrtrix.txt")} -force'
        )
    return cmds


def dwi_to_mni_step(current_path, sub_name, work_dir, startname):
    """DWI → MNI 配准（MATLAB 完全一致）"""
    cmds = []
    out_dir = mkdir_p(os.path.join(work_dir, 'dwi_coreg', sub_name))
    b0_dir = mkdir_p(os.path.join(work_dir, 'pred_b0', sub_name))
    dwi_file = os.path.join(current_path, 'dwi.mif')
    mean_b0_mif = os.path.join(b0_dir, 'mean_b0.mif')
    mean_b0_nii = os.path.join(b0_dir, 'mean_b0.nii.gz')
    root = _find_project_root()
    template_path = os.path.join(root, 'Templates', 'MNI152.nii.gz') if root else ''
    if not os.path.isfile(template_path):
        print(f"[WARN] MNI 模板不存在: {template_path}")
        return cmds
    cmds.append(
        f'dwiextract {dwi_file} - -bzero | '
        f'mrmath - mean {mean_b0_mif} -axis 3 -force'
    )
    cmds.append(f'mrconvert {mean_b0_mif} {mean_b0_nii} -force')
    cmds.append(
        f'flirt -in {mean_b0_nii} -ref {template_path} -dof 6 '
        f'-out {os.path.join(out_dir, "dwi_coreg.nii.gz")} '
        f'-omat {os.path.join(out_dir, "dwi_to_MNI_fsl.mat")}'
    )
    fsl_mat = os.path.join(out_dir, 'dwi_to_MNI_fsl.mat')
    cmds.append(
        f'transformconvert {fsl_mat} {mean_b0_nii} {template_path} '
        f'flirt_import {os.path.join(out_dir, "dwi_to_MNI_mrtrix.txt")} -force'
    )
    return cmds


def mask_step(current_path, sub_name, work_dir, startname):
    """dwi2mask + dilate，输出到 mask/<sub>/"""
    out_dir = mkdir_p(os.path.join(work_dir, 'mask', sub_name))
    dwi_file = os.path.join(current_path, 'dwi.mif')
    raw_mask = os.path.join(out_dir, 'raw_mask.mif')
    mask = os.path.join(out_dir, 'mask.mif')
    cmds = [
        f'dwi2mask {dwi_file} {raw_mask} -force',
        f'maskfilter {raw_mask} dilate {mask} -npass 6 -force',
    ]
    return out_dir, cmds


# ── 管线编排 ──────────────────────────────────────────────────


def run(work_dir, folder, sub_list, dry=False,
        do_format=True, denoise=True, gibbs=True, headmove=True,
        bias=True, t1corg=True, t1_to_mni=True, dwi_to_mni=True, mask=True):
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
        print(f"\n{'='*60}")
        print(f"[INFO] 处理被试: {sub}")
        current_path = os.path.join(full_path, sub)
        startname = folder

        if do_format:
            current_path, startname, cmds = change_format_step(current_path, sub, work_dir, dry)
            for c in cmds:
                run_cmd(c, dry)

        if denoise:
            current_path, startname, cmds = denoise_step(current_path, sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

        if gibbs:
            current_path, startname, cmds = gibbs_step(current_path, sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

        if headmove:
            current_path, startname, cmds = headmove_step(current_path, sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

        if bias:
            current_path, startname, cmds = bias_step(current_path, sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

        if t1_to_mni:
            cmds = t1_to_mni_step(sub, work_dir)
            for c in cmds:
                run_cmd(c, dry)

        if dwi_to_mni:
            cmds = dwi_to_mni_step(current_path, sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

        if t1corg:
            _, cmds = t1corg_step(current_path, sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

        if mask:
            _, cmds = mask_step(current_path, sub, work_dir, startname)
            for c in cmds:
                run_cmd(c, dry)

    print(f"[INFO] 预处理完成")
