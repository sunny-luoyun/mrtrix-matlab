"""纤维网络矩阵构建

与 MATLAB build_map.m / buildmap.m 一致:
    tck2connectome + 后处理（对称化、对角线归零、长度缩放、权重、脑区提取）
"""

import os
import numpy as np
from .utils import run_cmd, find_subjects, mkdir_p


def run(work_dir, folder, sub_list, dry=False,
        mask='', assign='voxels', metric='length',
        symmetric=True, zero_diagonal=True,
        search_length=0, tck_weight=False,
        output_txt=False, extract_regions=''):
    """执行矩阵构建

    Args:
        work_dir: 工作路径
        folder: 起始文件夹名
        sub_list: 被试列表
        mask: mask 文件路径
        assign: 纤维分配标准 (voxels/radial/reverse/forward)
        metric: 矩阵分配指标 (length/invlength/invnodevol)
        symmetric: 矩阵对称化
        zero_diagonal: 对角线归零
        search_length: 搜索长度
        tck_weight: 使用权重文件
        output_txt: 输出 txt
        extract_regions: 提取指定脑区编号
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
                print(f"[ERROR] 未找到被试: {full_path}")
                return

    print(f"[INFO] 纤维网络矩阵构建")
    print(f"[INFO] 分配: {assign}, 指标: {metric}, 对称: {symmetric}")

    for sub in sub_list:
        print(f"\n{'='*50}")
        print(f"[INFO] 处理被试: {sub}")
        sub_dir = os.path.join(full_path, sub)

        # 寻找 .tck 文件
        tck_file = None
        for cand in ['tracks_sift.tck', 'tracks.tck']:
            fp = os.path.join(sub_dir, cand)
            if os.path.isfile(fp):
                tck_file = fp
                break

        # 也查找 fiber 目录
        fiber_dir = os.path.join(work_dir, 'fiber', sub)
        if not tck_file and os.path.isdir(fiber_dir):
            for cand in ['tracks_sift.tck', 'tracks.tck']:
                fp = os.path.join(fiber_dir, cand)
                if os.path.isfile(fp):
                    tck_file = fp
                    break

        if not tck_file:
            print(f"  [SKIP] {sub}: 无 .tck 文件")
            continue

        # 寻找图谱
        atlas_files = [
            os.path.join(work_dir, '..', 'Templates', 'Brainnetome_246_MNI152_1mm.nii.gz'),
            os.path.join(work_dir, '..', 'Templates', 'AAl3.nii'),
        ]
        atlas = None
        for af in atlas_files:
            if os.path.isfile(af):
                atlas = af
                break
        if not atlas:
            # 尝试在模板目录查找
            template_dir = os.path.join(work_dir, 'Templates')
            if os.path.isdir(template_dir):
                for fname in sorted(os.listdir(template_dir)):
                    if fname.endswith('.nii') or fname.endswith('.nii.gz'):
                        atlas = os.path.join(template_dir, fname)
                        break

        if not atlas:
            print(f"  [SKIP] {sub}: 未找到图谱模板")
            continue

        # 构建输出目录
        out_dir = mkdir_p(os.path.join(work_dir, 'connectome', sub))
        out_csv = os.path.join(out_dir, 'connectome.csv')

        cmd = f'tck2connectome {tck_file} {atlas} {out_csv}'

        # 分配标准
        if assign == 'radial':
            cmd += f' -assignment_radial_search {search_length or 4}'
        elif assign == 'reverse':
            cmd += f' -assignment_reverse_search {search_length or 4}'
        elif assign == 'forward':
            cmd += f' -assignment_forward_search {search_length or 4}'

        # 矩阵指标
        if metric == 'invlength':
            cmd += ' -scale_invnodevol'
        elif metric == 'length':
            cmd += ' -scale_length'
        elif metric == 'invnodevol':
            cmd += ' -scale_invnodevol'

        if tck_weight:
            weight_csv = os.path.join(sub_dir, 'tracks_weights.csv')
            if os.path.isfile(weight_csv):
                cmd += f' -tck_weights {weight_csv}'

        if zero_diagonal:
            cmd += ' -zero_diagonal'
        cmd += ' -force'

        run_cmd(cmd, dry)

        # 后处理: 对称化
        if symmetric and os.path.isfile(out_csv):
            try:
                mat = np.loadtxt(out_csv, delimiter=',')
                mat = (mat + mat.T) / 2
                out_sym = out_csv.replace('.csv', '_sym.csv') if not output_txt else out_csv
                if not output_txt:
                    out_sym = out_csv
                np.savetxt(out_sym, mat, delimiter=',', fmt='%f')
                print(f"  [INFO] 矩阵已对称化")
            except Exception as e:
                print(f"  [WARN] 对称化失败: {e}")

        # 导出 txt
        if output_txt:
            try:
                mat = np.loadtxt(out_csv, delimiter=',')
                out_txt = os.path.join(out_dir, 'connectome.txt')
                np.savetxt(out_txt, mat, delimiter='\t', fmt='%f')
                print(f"  [INFO] 已输出 txt: {out_txt}")
            except Exception as e:
                print(f"  [WARN] txt 导出失败: {e}")

        # 提取指定脑区
        if extract_regions:
            region_list = [int(r.strip()) for r in extract_regions.split(',') if r.strip()]
            if region_list:
                try:
                    mat = np.loadtxt(out_csv, delimiter=',')
                    extracted = mat[np.ix_(region_list, region_list)]
                    out_ext = os.path.join(out_dir, 'connectome_extracted.csv')
                    np.savetxt(out_ext, extracted, delimiter=',', fmt='%f')
                    print(f"  [INFO] 已提取脑区 {region_list}: {out_ext}")
                except Exception as e:
                    print(f"  [WARN] 脑区提取失败: {e}")

    print("\n[INFO] 矩阵构建完成")
