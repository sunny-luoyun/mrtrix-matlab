"""FBA 步骤2: 模板构建与配准

与 MATLAB fba_template.m 一致:
    step7: population_template
    step8: mrregister
    step9: 求 mask 交集
"""

import os
from .utils import run_cmd, find_subjects, mkdir_p


def build_template(work_path, voxel=1.25, sub_list=None, dry=False):
    """构建群体模板 (population_template)"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    template_dir = mkdir_p(os.path.join(work_path, 'fba', 'template'))
    fod_input = mkdir_p(os.path.join(template_dir, 'fod_input'))
    mask_input = mkdir_p(os.path.join(template_dir, 'mask_input'))

    if not sub_list:
        sub_list = find_subjects(fba_sub_dir)
        if not sub_list:
            print("[ERROR] 无被试数据")
            return

    print(f"[INFO] 构建群体模板")
    print(f"[INFO] 被试: {', '.join(sub_list)}")

    # 创建软链接
    for sub in sub_list:
        fod_src = os.path.join(fba_sub_dir, sub, 'wmfod_norm.mif')
        mask_src = os.path.join(fba_sub_dir, sub, 'dwi_mask_upsampled.mif')
        if os.path.isfile(fod_src):
            fod_link = os.path.join(fod_input, f'{sub}.mif')
            if not os.path.exists(fod_link):
                os.symlink(fod_src, fod_link)

        # 也用原始 mask 作为备选
        if not os.path.isfile(mask_src):
            mask_src = os.path.join(fba_sub_dir, sub, 'dwi_mask.mif')
        if os.path.isfile(mask_src):
            mask_link = os.path.join(mask_input, f'{sub}.mif')
            if not os.path.exists(mask_link):
                os.symlink(mask_src, mask_link)

    cmd = (
        f'population_template {fod_input} '
        f'-mask_dir {mask_input} '
        f'{os.path.join(template_dir, "wmfod_template.mif")} '
        f'-voxel_size {voxel}'
    )
    run_cmd(cmd, dry)
    print(f"[INFO] 模板构建完成: {os.path.join(template_dir, 'wmfod_template.mif')}")


def register(work_path, nl_scale='0.5,0.75,1.0', nl_niter='5,5,15',
             sub_list=None, dry=False):
    """配准到模板 (mrregister) + mask 交集"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    template_dir = os.path.join(work_path, 'fba', 'template')
    template_fod = os.path.join(template_dir, 'wmfod_template.mif')

    if not os.path.isfile(template_fod):
        print(f"[ERROR] 模板文件不存在: {template_fod}")
        print("[HINT] 先运行 'fba template'")
        return

    if not sub_list:
        sub_list = find_subjects(fba_sub_dir)
        if not sub_list:
            print("[ERROR] 无被试数据")
            return

    print(f"[INFO] 配准到模板")
    print(f"[INFO] 尺度: {nl_scale}, 迭代: {nl_niter}")

    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        fod_norm = os.path.join(sub_dir, 'wmfod_norm.mif')
        if not os.path.isfile(fod_norm):
            print(f"  [SKIP] {sub}: wmfod_norm.mif 不存在")
            continue

        mask = os.path.join(sub_dir, 'dwi_mask_upsampled.mif')
        if not os.path.isfile(mask):
            dwi_file = os.path.join(sub_dir, 'dwi_upsampled.mif')
            if not os.path.isfile(dwi_file):
                dwi_file = os.path.join(sub_dir, 'dwi.mif')
            if os.path.isfile(dwi_file):
                print(f"  [INFO] 生成 mask: {sub}")
                run_cmd(f'dwi2mask {dwi_file} {mask} -force', dry)

        warp_sub2tmp = os.path.join(sub_dir, 'subject2template_warp.mif')
        warp_tmp2sub = os.path.join(sub_dir, 'template2subject_warp.mif')

        cmd = (
            f'mrregister {fod_norm} '
            f'-mask1 {mask} '
            f'{template_fod} '
            f'-nl_warp {warp_sub2tmp} {warp_tmp2sub} '
            f'-nl_scale {nl_scale} '
            f'-nl_niter {nl_niter} -force'
        )
        run_cmd(cmd, dry)

    # mask 交集（MATLAB step9: 先 warp 到模板空间，再取 min）
    print("\n[INFO] 计算 mask 交集...")
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        warp_file = os.path.join(sub_dir, 'subject2template_warp.mif')
        mask_file = os.path.join(sub_dir, 'dwi_mask_upsampled.mif')
        if not os.path.isfile(mask_file):
            mask_file = os.path.join(sub_dir, 'dwi_mask.mif')
        if os.path.isfile(warp_file) and os.path.isfile(mask_file):
            warped_mask = os.path.join(sub_dir, 'dwi_mask_in_template_space.mif')
            run_cmd(
                f'mrtransform {mask_file} -warp {warp_file} '
                f'-interp nearest -datatype bit {warped_mask} -force', dry
            )

    template_mask = os.path.join(template_dir, 'template_mask.mif')
    mask_files = []
    for sub in sub_list:
        m = os.path.join(fba_sub_dir, sub, 'dwi_mask_in_template_space.mif')
        if os.path.isfile(m):
            mask_files.append(m)
    if mask_files:
        run_cmd(f'mrmath {" ".join(mask_files)} min {template_mask} -datatype bit -force', dry)

    print("[INFO] 配准与 mask 交集完成")
