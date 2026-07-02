"""FBA 步骤3: Fixel 指标与追踪

与 MATLAB fba_fixel.m 一致:
    step10: fixel mask
    step11: warp FOD
    step12: FD (fod2fixel -afd)
    step13: reorient
    step14: correspondence
    step15: FC
    step16: log(FC) 和 FDC
    step17: 模板全脑追踪（tckgen + tcksift）
    step18: fixel 连接矩阵
    step19: fixel 指标平滑
"""

import os
from .utils import run_cmd, find_subjects, mkdir_p


def run(work_path, dry=False, skip_track=False, skip_smooth=False):
    """执行 FBA fixel 处理"""
    fba_sub_dir = os.path.join(work_path, 'fba', 'subjects')
    template_dir = os.path.join(work_path, 'fba', 'template')
    fixel_dir = os.path.join(template_dir, 'fixel')
    template_fod = os.path.join(template_dir, 'wmfod_template.mif')

    if not os.path.isfile(template_fod):
        print(f"[ERROR] 模板文件不存在: {template_fod}")
        print("[HINT] 先运行 'fba template'")
        return

    sub_list = find_subjects(fba_sub_dir)
    if not sub_list:
        print("[ERROR] 无被试数据")
        return

    print(f"[INFO] FBA Fixel 指标处理")
    print(f"[INFO] 被试: {', '.join(sub_list)}")

    # ── step10: 模板 fixel mask ────────────────────────────
    print("\n[INFO] step10: Fixel mask...")
    fod2fixel_out = os.path.join(template_dir, 'fod2fixel_out')
    cmd = f'fod2fixel -mask {os.path.join(template_dir, "mask_inter.mif")} {template_fod} {fod2fixel_out} -force'
    run_cmd(cmd, dry)

    # fixel 目录的实际位置
    fixel_mask_dir = fod2fixel_out
    if os.path.isdir(fod2fixel_out):
        dirs = [d for d in os.listdir(fod2fixel_out) if os.path.isdir(os.path.join(fod2fixel_out, d))]
        if dirs:
            fixel_mask_dir = os.path.join(fod2fixel_out, dirs[0])

    # ── step11: warp FOD ───────────────────────────────────
    print("\n[INFO] step11: Warp FOD 到模板空间...")
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        fod_norm = os.path.join(sub_dir, 'wmfod_norm.mif')
        warp = os.path.join(sub_dir, 'subject2template_warp.mif')
        if not os.path.isfile(fod_norm) or not os.path.isfile(warp):
            continue
        out_fod = os.path.join(sub_dir, 'fod_in_template_space.mif')
        cmd = f'mrtransform {fod_norm} -warp {warp} -reorient_fod no {out_fod} -force'
        run_cmd(cmd, dry)

    # ── step12: FD ─────────────────────────────────────────
    print("\n[INFO] step12: 纤维密度 (FD)...")
    fd_dir = mkdir_p(os.path.join(template_dir, 'fd'))
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        fod_warped = os.path.join(sub_dir, 'fod_in_template_space.mif')
        if not os.path.isfile(fod_warped):
            continue
        out_fd = os.path.join(fd_dir, f'{sub}.mif')
        cmd = f'fod2fixel -afd {out_fd} -mask {os.path.join(template_dir, "mask_inter.mif")} {fod_warped} {fd_dir} -force'
        run_cmd(cmd, dry)

    # ── step13: Reorient ───────────────────────────────────
    print("\n[INFO] step13: Fixel 重定向...")
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        warp = os.path.join(sub_dir, 'subject2template_warp.mif')
        if not os.path.isfile(warp):
            continue
        cmd = f'fixelreorient {fd_dir} {warp} {fd_dir} -force'
        run_cmd(cmd, dry)

    # ── step14: Correspondence ─────────────────────────────
    print("\n[INFO] step14: Fixel 对应关系...")
    fc_dir = mkdir_p(os.path.join(template_dir, 'fc'))
    for sub in sub_list:
        sub_fd = os.path.join(fd_dir, f'{sub}.mif')
        if not os.path.isfile(sub_fd):
            continue
        out_fc = os.path.join(fc_dir, f'{sub}.mif')
        cmd = f'fixelcorrespondence {sub_fd} {fixel_mask_dir} {out_fc} -force'
        run_cmd(cmd, dry)

    # ── step15: FC ─────────────────────────────────────────
    print("\n[INFO] step15: 纤维截面 (FC)...")
    for sub in sub_list:
        sub_dir = os.path.join(fba_sub_dir, sub)
        warp = os.path.join(sub_dir, 'subject2template_warp.mif')
        fod_norm = os.path.join(sub_dir, 'wmfod_norm.mif')
        if not os.path.isfile(warp) or not os.path.isfile(fod_norm):
            continue
        out_fc = os.path.join(fc_dir, f'{sub}.mif')
        cmd = f'warp2metric {fod_norm} {warp} -fc {out_fc} -force'
        run_cmd(cmd, dry)

    # ── step16: log(FC) + FDC ──────────────────────────────
    print("\n[INFO] step16: log(FC) 和 FDC...")
    logfc_dir = mkdir_p(os.path.join(template_dir, 'log_fc'))
    fdc_dir = mkdir_p(os.path.join(template_dir, 'fdc'))
    for sub in sub_list:
        sub_fc = os.path.join(fc_dir, f'{sub}.mif')
        sub_fd = os.path.join(fd_dir, f'{sub}.mif')
        if os.path.isfile(sub_fc):
            out_logfc = os.path.join(logfc_dir, f'{sub}.mif')
            run_cmd(f'mrcalc {sub_fc} -log {out_logfc} -force', dry)
        if os.path.isfile(sub_fc) and os.path.isfile(sub_fd):
            out_fdc = os.path.join(fdc_dir, f'{sub}.mif')
            run_cmd(f'mrcalc {sub_fd} {sub_fc} -multiply {out_fdc} -force', dry)

    # ── step17: 模板全脑追踪 ──────────────────────────────
    if not skip_track:
        print("\n[INFO] step17: 模板全脑追踪...")
        tck_file = os.path.join(template_dir, 'tracks.tck')
        cmd = (
            f'tckgen -algorithm iFOD2 {template_fod} {tck_file} '
            f'-select 10m -seed_dynamic {template_fod} '
            f'-mask {os.path.join(template_dir, "mask_inter.mif")} -force'
        )
        run_cmd(cmd, dry)

        print("[INFO] SIFT 缩减...")
        tck_sift = os.path.join(template_dir, 'tracks_sift.tck')
        run_cmd(f'tcksift {tck_file} {template_fod} {tck_sift} -mask {os.path.join(template_dir, "mask_inter.mif")} -force', dry)

    # ── step18: Fixel 连接矩阵 ────────────────────────────
    if not skip_track:
        print("\n[INFO] step18: Fixel 连接矩阵...")
        matrix_dir = os.path.join(template_dir, 'matrix')
        tck_file = os.path.join(template_dir, 'tracks_sift.tck')
        if os.path.isfile(tck_file):
            cmd = f'fixelconnectivity {fixel_mask_dir} {tck_file} {matrix_dir} -force'
            run_cmd(cmd, dry)

    # ── step19: 指标平滑 ──────────────────────────────────
    if not skip_smooth:
        print("\n[INFO] step19: Fixel 指标平滑...")
        for metric in ['fd', 'log_fc', 'fdc']:
            metric_dir = os.path.join(template_dir, metric)
            smooth_dir = os.path.join(template_dir, f'{metric}_smooth')
            if os.path.isdir(metric_dir):
                cmd = f'fixelfilter {metric_dir} smooth {smooth_dir} -matrix {os.path.join(template_dir, "matrix")} -force'
                run_cmd(cmd, dry)

    print("\n[INFO] Fixel 处理完成!")
