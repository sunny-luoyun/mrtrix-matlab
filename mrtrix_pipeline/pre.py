"""预处理管线 (Preprocessing)

完整步骤与 MATLAB 的 prepro.m 一致:
    change_format → denoise → gibbs → headmove → bias
    → T1corg → T1toMNI → dwitoMNI → mask

每个步骤是独立的函数，可从 run() 逐一调用。
"""

import os
from .utils import run_cmd, find_subjects, mkdir_p


def change_format_step(subject_dir, sub_name, work_dir, dry=False):
    """格式转换: mrconvert nii.gz → mif"""
    dwimif_dir = mkdir_p(os.path.join(work_dir, 'dwimif', sub_name), dry)
    t1mif_dir = mkdir_p(os.path.join(work_dir, 'T1mif', sub_name), dry)

    cmds = []

    bvec = os.path.join(subject_dir, f'{sub_name}dwi.bvec')
    bval = os.path.join(subject_dir, f'{sub_name}dwi.bval')
    dwi_nii = os.path.join(subject_dir, f'{sub_name}dwi.nii.gz')
    dwi_mif = os.path.join(dwimif_dir, 'dwi.mif')
    if os.path.isfile(dwi_nii):
        cmds.append(
            f'mrconvert -fslgrad {bvec} {bval} {dwi_nii} {dwi_mif} -force'
        )

    t1_nii = os.path.join(subject_dir, f'{sub_name}T1.nii.gz')
    t1_mif = os.path.join(t1mif_dir, 'T1.mif')
    if os.path.isfile(t1_nii):
        cmds.append(f'mrconvert {t1_nii} {t1_mif} -force')

    return dwimif_dir, cmds


def denoise_step(current_path, sub_name, work_dir, startname, dry=False):
    """降噪: dwidenoise"""
    out_dir = mkdir_p(os.path.join(work_dir, 'denoise', sub_name), dry)
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    noise = os.path.join(out_dir, 'noise.mif')
    cmd = f'dwidenoise {in_file} {out_file} -noise {noise} -force'
    return out_dir, [cmd]


def gibbs_step(current_path, sub_name, work_dir, startname, dry=False):
    """Gibbs Ring 消除: mrdegibbs"""
    out_dir = mkdir_p(os.path.join(work_dir, 'gibbs', sub_name), dry)
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    cmd = f'mrdegibbs {in_file} {out_file} -force'
    return out_dir, [cmd]


def headmove_step(current_path, sub_name, work_dir, startname, dry=False):
    """头动矫正 + 变形矫正: dwifslpreproc"""
    out_dir = mkdir_p(os.path.join(work_dir, 'headmove', sub_name), dry)
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    rpe_cmd = '-rpe_none'  # 可根据需要改为其他选项
    cmd = f'dwifslpreproc {in_file} {out_file} {rpe_cmd} -eddy_options " --slm=linear" -force'
    return out_dir, [cmd]


def bias_step(current_path, sub_name, work_dir, startname, dry=False):
    """B1 场不均匀性校正: dwibiascorrect"""
    out_dir = mkdir_p(os.path.join(work_dir, 'bias', sub_name), dry)
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    cmd = f'dwibiascorrect ants {in_file} {out_file} -force'
    return out_dir, [cmd]


def t1corg_step(current_path, sub_name, work_dir, startname, dry=False):
    """T1 结构像分割: 5ttgen fsl"""
    out_dir = mkdir_p(os.path.join(work_dir, 'T1seg', sub_name), dry)
    t1_dir = os.path.join(work_dir, 'T1mif', sub_name)
    t1_file = os.path.join(t1_dir, 'T1.mif')
    if not os.path.isfile(t1_file):
        t1_file = os.path.join(current_path, '..', '..', 'T1mif', sub_name, 'T1.mif')
    out_file = os.path.join(out_dir, '5tt.mif')
    cmd = f'5ttgen fsl {t1_file} {out_file} -force'
    return out_dir, [cmd]


def t1_to_mni_step(sub_name, work_dir):
    """T1 配准到 MNI"""
    t1_dir = os.path.join(work_dir, 'T1mif', sub_name)
    t1_file = os.path.join(t1_dir, 'T1.mif')
    out_file = os.path.join(t1_dir, 'T1_MNI.mif')
    cmd = f'mrregister {t1_file} -type rigid {out_file} -force'
    return [cmd]


def dwi_to_mni_step(current_path, sub_name, work_dir, startname, dry=False):
    """DWI 配准到 MNI"""
    out_dir = mkdir_p(os.path.join(work_dir, 'dwiMNI', sub_name), dry)
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(out_dir, 'dwi.mif')
    cmd = f'mrregister {in_file} -type rigid {out_file} -force'
    return out_dir, [cmd]


def mask_step(current_path, sub_name, work_dir, startname):
    """提取脑 mask: dwi2mask"""
    in_file = os.path.join(current_path, 'dwi.mif')
    out_file = os.path.join(current_path, 'dwi_mask.mif')
    cmd = f'dwi2mask {in_file} {out_file} -force'
    return current_path, [cmd]


# ── 管线编排 ──────────────────────────────────────────────────


def run(work_dir, folder, sub_list, dry=False,
        do_format=True, denoise=True, gibbs=True, headmove=True,
        bias=True, t1corg=True, t1_to_mni=False, dwi_to_mni=False,
        mask=True):
    """执行预处理管线

    Args:
        work_dir: 工作路径
        folder: 起始文件夹名（含 Sub* 目录）
        sub_list: 被试名列表（空则自动查找）
        dry: 仅打印不执行
    """
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
                print(f"[ERROR] 未找到以 Sub 开头的被试文件夹: {full_path}")
                return

    print(f"[INFO] 工作路径: {work_dir}")
    print(f"[INFO] 被试: {', '.join(sub_list)}")

    from .utils import Timer
    with Timer('预处理'):
        for sub in sub_list:
            print(f"\n{'='*60}")
            print(f"[INFO] 处理被试: {sub}")
            print(f"{'='*60}")

            current_path = os.path.join(full_path, sub)
            startname = folder

            if do_format:
                current_path, cmds = change_format_step(current_path, sub, work_dir, dry)
                for c in cmds:
                    run_cmd(c, dry)
                startname = 'dwimif'

            if denoise:
                current_path, cmds = denoise_step(current_path, sub, work_dir, startname, dry)
                for c in cmds:
                    run_cmd(c, dry)
                startname = 'denoise'

            if gibbs:
                current_path, cmds = gibbs_step(current_path, sub, work_dir, startname, dry)
                for c in cmds:
                    run_cmd(c, dry)
                startname = 'gibbs'

            if headmove:
                current_path, cmds = headmove_step(current_path, sub, work_dir, startname, dry)
                for c in cmds:
                    run_cmd(c, dry)
                startname = 'headmove'

            if bias:
                current_path, cmds = bias_step(current_path, sub, work_dir, startname, dry)
                for c in cmds:
                    run_cmd(c, dry)
                startname = 'bias'

            if t1corg:
                _, cmds = t1corg_step(current_path, sub, work_dir, startname, dry)
                for c in cmds:
                    run_cmd(c, dry)

            if t1_to_mni:
                cmds = t1_to_mni_step(sub, work_dir)
                for c in cmds:
                    run_cmd(c, dry)

            if dwi_to_mni:
                current_path, cmds = dwi_to_mni_step(current_path, sub, work_dir, startname, dry)
                for c in cmds:
                    run_cmd(c, dry)
                startname = 'dwiMNI'

            if mask:
                current_path, cmds = mask_step(current_path, sub, work_dir, startname)
                for c in cmds:
                    run_cmd(c, dry)

    print(f"[INFO] 预处理完成")
