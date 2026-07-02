"""FBA 步骤3: Fixel 指标与追踪（与 MATLAB 完全一致）

step10: fod2fixel → template/fixel_mask
step11: mrtransform → subjects/Sub01/fod_in_template_space_NOT_REORIENTED.mif
step12: fod2fixel -afd → subjects/Sub01/fixel_in_template_space_NOT_REORIENTED/fd.mif
step13: fixelreorient → fixel_in_template_space_NOT_REORIENTED → fixel_in_template_space
step14: fixelcorrespondence → template/fd/Sub01.mif
step15: warp2metric -fc → template/fc/Sub01.mif
step16: mrcalc → log_fc, fdc
step17: tckgen + tcksift → tracks_{select}.tck
step18: fixelconnectivity → template/matrix
step19: fixelfilter smooth → fd_smooth/ 等
"""

import os
from .utils import run_cmd, find_subjects, mkdir_p


def run(work_path, dry=False, skip_track=False, skip_smooth=False,
        fmls_peak=0.5, tck_algorithm='iFOD2', tck_angle=45,
        tck_maxlen=250, tck_minlen=10, tck_power=1.0, tck_select=10000000,
        tck_sift_num=1000000, tck_cutoff=0.05):
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    template_dir = os.path.join(work_path, 'fba', 'template')
    template_fod = os.path.join(template_dir, 'wmfod_template.mif')
    template_mask = os.path.join(template_dir, 'template_mask.mif')

    if not os.path.isfile(template_fod):
        print(f"[ERROR] 模板文件不存在: {template_fod}")
        print("[HINT] 先运行 fba template")
        return

    sub_list = find_subjects(fba_sub_dir)
    if not sub_list:
        print("[ERROR] 无被试数据")
        return

    print(f"[INFO] FBA Fixel 处理（MATLAB 兼容模式）")

    # ── step10: 模板 fixel mask ────────────────────────────
    print("\n[INFO] step10: 模板 fixel mask...")
    fixel_mask = os.path.join(template_dir, 'fixel_mask')
    cmd = (
        f'fod2fixel -mask {template_mask} '
        f'-fmls_peak_value {fmls_peak} '
        f'{template_fod} {fixel_mask} -force'
    )
    run_cmd(cmd, dry)

    # ── step11: warp FOD 到模板空间（不重定向）────────────
    print("\n[INFO] step11: Warp FOD 到模板空间...")
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        fod_norm = os.path.join(sub_dir, 'wmfod_norm.mif')
        warp = os.path.join(sub_dir, 'subject2template_warp.mif')
        if not os.path.isfile(fod_norm) or not os.path.isfile(warp):
            continue
        out_fod = os.path.join(sub_dir, 'fod_in_template_space_NOT_REORIENTED.mif')
        run_cmd(
            f'mrtransform {fod_norm} -warp {warp} '
            f'-reorient_fod no {out_fod} -force', dry
        )

    # ── step12: FD ─────────────────────────────────────────
    print("\n[INFO] step12: 纤维密度 (FD)...")
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        fod_warped = os.path.join(sub_dir, 'fod_in_template_space_NOT_REORIENTED.mif')
        if not os.path.isfile(fod_warped):
            continue
        fixel_out = os.path.join(sub_dir, 'fixel_in_template_space_NOT_REORIENTED')
        run_cmd(
            f'fod2fixel -mask {template_mask} '
            f'{fod_warped} {fixel_out} '
            f'-afd fd.mif -fmls_peak_value {fmls_peak} -force', dry
        )

    # ── step13: Reorient ───────────────────────────────────
    print("\n[INFO] step13: Fixel 重定向...")
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        warp = os.path.join(sub_dir, 'subject2template_warp.mif')
        nreor = os.path.join(sub_dir, 'fixel_in_template_space_NOT_REORIENTED')
        if not os.path.isdir(nreor):
            continue
        reor = os.path.join(sub_dir, 'fixel_in_template_space')
        run_cmd(f'fixelreorient {nreor} {warp} {reor} -force', dry)

    # ── step14: Correspondence → template/fd/ ──────────────
    print("\n[INFO] step14: Fixel 对应关系 → FD...")
    fd_dir = mkdir_p(os.path.join(template_dir, 'fd'))
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        fd_file = os.path.join(sub_dir, 'fixel_in_template_space', 'fd.mif')
        if not os.path.isfile(fd_file):
            continue
        run_cmd(
            f'fixelcorrespondence {fd_file} {fixel_mask} '
            f'{os.path.join(fd_dir, f"{sub}.mif")} -force', dry
        )

    # ── step15: FC ─────────────────────────────────────────
    print("\n[INFO] step15: 纤维截面 (FC)...")
    fc_dir = mkdir_p(os.path.join(template_dir, 'fc'))
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        warp = os.path.join(sub_dir, 'subject2template_warp.mif')
        if not os.path.isfile(warp):
            continue
        run_cmd(
            f'warp2metric {warp} -fc {fixel_mask} '
            f'{os.path.join(fc_dir, f"{sub}.mif")} -force', dry
        )

    # ── step16: log(FC) + FDC ──────────────────────────────
    print("\n[INFO] step16: log(FC) 和 FDC...")
    logfc_dir = mkdir_p(os.path.join(template_dir, 'log_fc'))
    fdc_dir = mkdir_p(os.path.join(template_dir, 'fdc'))
    for sub in sub_list:
        sub_fc = os.path.join(fc_dir, f'{sub}.mif')
        sub_fd = os.path.join(fd_dir, f'{sub}.mif')
        if os.path.isfile(sub_fc):
            run_cmd(f'mrcalc {sub_fc} -log {os.path.join(logfc_dir, f"{sub}.mif")} -force', dry)
        if os.path.isfile(sub_fc) and os.path.isfile(sub_fd):
            run_cmd(
                f'mrcalc {sub_fd} {sub_fc} -multiply '
                f'{os.path.join(fdc_dir, f"{sub}.mif")} -force', dry
            )

    # ── step17: 模板全脑追踪 ──────────────────────────────
    if not skip_track:
        print(f"\n[INFO] step17: 模板全脑追踪 ({tck_select} 条)...")
        tck_file = os.path.join(template_dir, f'tracks_{tck_select}.tck')
        run_cmd(
            f'tckgen -algorithm {tck_algorithm} '
            f'-angle {tck_angle} -maxlen {tck_maxlen} -minlen {tck_minlen} '
            f'-power {tck_power} '
            f'{template_fod} '
            f'-seed_image {template_mask} '
            f'-mask {template_mask} '
            f'-select {tck_select} -cutoff {tck_cutoff} '
            f'{tck_file} -force', dry
        )
        tck_sift = os.path.join(template_dir, f'tracks_{tck_select}_sift.tck')
        print("[INFO] SIFT 缩减...")
        run_cmd(
            f'tcksift {tck_file} {template_fod} {tck_sift} '
            f'-term_number {tck_sift_num} -force', dry
        )

    # ── step18: Fixel 连接矩阵 ────────────────────────────
    if not skip_track:
        print("\n[INFO] step18: Fixel 连接矩阵...")
        matrix_dir = os.path.join(template_dir, 'matrix')
        tck_file = os.path.join(template_dir, f'tracks_{tck_select}_sift.tck')
        if os.path.isfile(tck_file):
            run_cmd(f'fixelconnectivity {fixel_mask} {tck_file} {matrix_dir} -force', dry)

    # ── step19: 指标平滑 ──────────────────────────────────
    if not skip_smooth:
        print("\n[INFO] step19: Fixel 指标平滑...")
        matrix_dir = os.path.join(template_dir, 'matrix')
        for metric in ['fd', 'log_fc', 'fdc']:
            metric_dir = os.path.join(template_dir, metric)
            smooth_dir = os.path.join(template_dir, f'{metric}_smooth')
            if os.path.isdir(metric_dir) and os.path.isdir(matrix_dir):
                run_cmd(
                    f'fixelfilter {metric_dir} smooth {smooth_dir} '
                    f'-matrix {matrix_dir} -force', dry
                )

    print("\n[INFO] Fixel 处理完成!")
