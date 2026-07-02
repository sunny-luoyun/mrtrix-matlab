"""FBA 步骤0: 数据整理

将多条件/多时间点的 dwi.mif 汇总到 fba/subjects/ 目录下。
与 MATLAB fba_organize.m 一致。
"""

import os
import shutil
from .utils import run_cmd, mkdir_p, find_subjects


def run(work_dir, sources, sep='_', use_copy=True, dry=False):
    """执行数据整理

    Args:
        work_dir: 工作路径
        sources: [(condition, timepoint, src_path), ...] 列表
        sep: 分隔符（默认 _）
        use_copy: True=复制, False=软链接
        dry: 仅打印
    """
    if not work_dir or not os.path.isdir(work_dir):
        print(f"[ERROR] 工作路径不存在: {work_dir}")
        return

    subjects_dir = mkdir_p(os.path.join(work_dir, 'fba', 'subjects'))

    rows = []
    for cond, tp, src_path in sources:
        cond = cond.strip()
        tp = tp.strip()
        src_path = src_path.strip()
        if not cond or not tp or not src_path:
            continue
        if not os.path.isdir(src_path):
            print(f"[WARN] 源路径不存在: {src_path}")
            continue
        subs = find_subjects(src_path)
        for sub in subs:
            rows.append((cond, tp, src_path, sub))

    if not rows:
        print("[ERROR] 未找到任何有效源数据")
        return

    total = len(rows)
    print(f"[INFO] 共发现 {total} 个扫描")

    done = 0
    for cond, tp, src_path, sub in rows:
        target_name = f'Sub{sub}{sep}{cond}{sep}{tp}'
        target_dir = mkdir_p(os.path.join(subjects_dir, target_name))
        src_file = os.path.join(src_path, sub, 'dwi.mif')
        dst_file = os.path.join(target_dir, 'dwi.mif')

        if not os.path.isfile(src_file):
            print(f"  [SKIP] {target_name}: dwi.mif 不存在")
            continue

        if os.path.isfile(dst_file):
            print(f"  [SKIP] {target_name}: 已存在")
            done += 1
            continue

        if use_copy:
            shutil.copy2(src_file, dst_file)
            print(f"  [COPY] {target_name}")
        else:
            os.symlink(src_file, dst_file)
            print(f"  [LINK] {target_name}")

        done += 1

    print(f"\n[INFO] 数据整理完成！共处理 {done}/{total} 个扫描")
    print(f"[INFO] 保存至: {subjects_dir}")
