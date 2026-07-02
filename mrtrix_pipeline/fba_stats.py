"""FBA 步骤4: CFE 统计分析

与 MATLAB step20_stats.m 一致:
    fixelcfestats
"""

import os
from .utils import run_cmd, find_subjects, mkdir_p
from .models import write_files_txt


def run(work_path, design_txt, contrast_txt, metrics,
        dry=False, nshuffles=5000, cfe_h=3.0, cfe_e=0.5, cfe_c=0.5,
        exchange='', suffix=''):
    """执行 CFE 统计分析

    Args:
        work_path: 工作路径
        design_txt: 设计矩阵文件路径或文本内容
        contrast_txt: 对比矩阵文件路径或文本内容
        metrics: 指标列表 ['fd', 'log_fc', 'fdc']
        dry: 仅打印
        nshuffles: 排列次数
        cfe_h/cfe_e/cfe_c: CFE 参数
        exchange: exchangeability 块文件
        suffix: 输出后缀
    """
    template_dir = os.path.join(work_path, 'fba', 'template')

    if not os.path.isdir(template_dir):
        print(f"[ERROR] 模板目录不存在: {template_dir}")
        print("[HINT] 先完成 FBA 步骤0-3")
        return

    # 获取被试列表
    sub_list = find_subjects(os.path.join(work_path, 'fba', 'subjects'))
    if not sub_list:
        print("[ERROR] fba/subjects 下无被试")
        return

    # 生成 files.txt（CFE 所需）
    files_txt = os.path.join(template_dir, 'files.txt')
    write_files_txt(files_txt, [f'{s}.mif' for s in sub_list])

    # 读写设计/对比矩阵
    def _read_or_write(filepath, content):
        if os.path.isfile(content):
            with open(content) as f:
                data = f.read()
            with open(filepath, 'w') as f:
                f.write(data)
        else:
            with open(filepath, 'w') as f:
                f.write(content)

    design_file = os.path.join(template_dir, 'design_matrix.txt')
    contrast_file = os.path.join(template_dir, 'contrast_matrix.txt')
    _read_or_write(design_file, design_txt)
    _read_or_write(contrast_file, contrast_txt)

    # exchangeability 选项
    exc_opt = ''
    if exchange and os.path.isfile(exchange):
        exc_opt = f' -exchangeability {exchange}'

    # 对各指标分别运行 fixelcfestats
    out_names = {
        'fd': f'stats_fd{suffix}',
        'log_fc': f'stats_log_fc{suffix}',
        'fdc': f'stats_fdc{suffix}',
    }

    print(f"[INFO] CFE 统计分析")
    print(f"[INFO] 被试: {len(sub_list)}, nshuffles: {nshuffles}")
    print(f"[INFO] 指标: {', '.join(metrics)}")

    for metric in metrics:
        if metric not in out_names:
            print(f"  [WARN] 未知指标: {metric}")
            continue

        smooth_dir = os.path.join(template_dir, f'{metric}_smooth')
        if not os.path.isdir(smooth_dir):
            print(f"  [SKIP] {metric}: {smooth_dir} 不存在")
            print(f"  [HINT] 先运行 'fba fixel'（含平滑）")
            continue

        cmd = (
            f'fixelcfestats {smooth_dir} '
            f'{files_txt} {design_file} {contrast_file} '
            f'{os.path.join(template_dir, "matrix")} '
            f'{os.path.join(template_dir, out_names[metric])} '
            f'-nshuffles {nshuffles} '
            f'-cfe_h {cfe_h} -cfe_e {cfe_e} -cfe_c {cfe_c}'
            f'{exc_opt} -force'
        )
        run_cmd(cmd, dry)

    print(f"\n[INFO] 统计分析完成！")
    print(f"[INFO] 结果保存在: {template_dir}")
