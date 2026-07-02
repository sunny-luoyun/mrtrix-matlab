"""弥散指标计算（与 MATLAB 完全一致）

DTI: dt → tensor/<sub>/dt.mif
      dkt → tensor/<sub>/dkt/dkt.mif + dt.mif
      指标 → tensor/<sub>/FA.mif → tensor/<sub>/FA_coreg.mif
              → Results/tensormetric/FA/<sub>_FAmap.nii

所有指标均经过 MNI 配准并转为 NIfTI。
"""

import os
from .utils import run_cmd, find_subjects, mkdir_p, _find_project_root


def _tensor2metric_and_coreg(work_dir, name, sub_dir, metric, suffix):
    """通用流程: tensor2metric → mrtransform 配准 → mrconvert 转 nii"""
    cmds = []
    in_file = os.path.join(sub_dir, f'dt.mif')
    out_mif = os.path.join(sub_dir, f'{suffix}.mif')
    cmds.append(f'tensor2metric {in_file} -{metric} {out_mif} -force')

    coreg_mif = os.path.join(sub_dir, f'{suffix}_coreg.mif')
    dwi_txt = os.path.join(work_dir, 'dwi_coreg', name, 'dwi_to_MNI_mrtrix.txt')
    root = _find_project_root()
    template_path = os.path.join(root, 'Templates', 'MNI152.nii.gz') if root else ''
    if os.path.isfile(dwi_txt) and os.path.isfile(template_path):
        cmds.append(
            f'mrtransform {out_mif} -linear {dwi_txt} '
            f'-template {template_path} {coreg_mif} -force'
        )
        result_dir = mkdir_p(os.path.join(work_dir, 'Results', 'tensormetric', suffix))
        nii_out = os.path.join(result_dir, f'{name}_{suffix}map.nii')
        cmds.append(f'mrconvert {coreg_mif} {nii_out} -force')
    return cmds


def _kurtosis2metric_and_coreg(work_dir, name, sub_dir, metric, suffix):
    """峰度指标: 从 dkt/ 子目录读取，然后配准 + 转 nii"""
    cmds = []
    dkt_dir = os.path.join(sub_dir, 'dkt')
    in_file = os.path.join(dkt_dir, 'dkt.mif')
    out_mif = os.path.join(dkt_dir, f'{suffix}.mif')
    cmds.append(f'tensor2metric {in_file} -{metric} {out_mif} -force')

    coreg_mif = os.path.join(dkt_dir, f'{suffix}_coreg.mif')
    dwi_txt = os.path.join(work_dir, 'dwi_coreg', name, 'dwi_to_MNI_mrtrix.txt')
    root = _find_project_root()
    template_path = os.path.join(root, 'Templates', 'MNI152.nii.gz') if root else ''
    if os.path.isfile(dwi_txt) and os.path.isfile(template_path):
        cmds.append(
            f'mrtransform {out_mif} -linear {dwi_txt} '
            f'-template {template_path} {coreg_mif} -force'
        )
        result_dir = mkdir_p(os.path.join(work_dir, 'Results', 'tensormetric', suffix))
        nii_out = os.path.join(result_dir, f'{name}_{suffix}map.nii')
        cmds.append(f'mrconvert {coreg_mif} {nii_out} -force')
    return cmds


def run(work_dir, folder, sub_list, dry=False,
        dt=True, fa=True, ad=False, rd=False, adc=False,
        cl=False, cp=False, cs=False,
        dkt=False, mk=False, ak=False, rk=False):
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
        sub_input = os.path.join(full_path if folder else work_dir, sub)
        mask_file = os.path.join(work_dir, 'mask', sub, 'mask.mif')

        tensor_dir = mkdir_p(os.path.join(work_dir, 'tensor', sub))
        dwi_file = os.path.join(sub_input, 'dwi.mif')

        if not os.path.isfile(dwi_file):
            print(f"  [SKIP] {sub}: dwi.mif 不存在")
            continue

        if dt:
            mask_opt = f'-mask {mask_file}' if os.path.isfile(mask_file) else ''
            run_cmd(f'dwi2tensor {mask_opt} {dwi_file} {os.path.join(tensor_dir, "dt.mif")} -force', dry)

        if dkt:
            dkt_dir = mkdir_p(os.path.join(tensor_dir, 'dkt'))
            mask_opt = f'-mask {mask_file}' if os.path.isfile(mask_file) else ''
            run_cmd(
                f'dwi2tensor {mask_opt} -dkt {os.path.join(dkt_dir, "dkt.mif")} '
                f'{dwi_file} {os.path.join(dkt_dir, "dt.mif")} -force', dry
            )

        # DTI 指标 (tensor2metric → coreg → nii)
        for met, suf in [('fa', 'FA'), ('ad', 'AD'), ('rd', 'RD'),
                         ('adc', 'ADC'), ('cl', 'CL'), ('cp', 'CP'), ('cs', 'CS')]:
            enabled = locals()[met]
            if enabled:
                for c in _tensor2metric_and_coreg(work_dir, sub, tensor_dir, met, suf):
                    run_cmd(c, dry)

        # DKI 指标
        for met, suf in [('mk', 'MK'), ('ak', 'AK'), ('rk', 'RK')]:
            enabled = locals()[met]
            if enabled:
                for c in _kurtosis2metric_and_coreg(work_dir, sub, tensor_dir, met, suf):
                    run_cmd(c, dry)

    print(f"[INFO] DTI 计算完成")
