"""纤维网络矩阵构建（与 MATLAB 完全一致）

输出:
  brainnet/<sub>/BN.csv
  Results/brainnet_Map/GlobalMap/<sub>_BN.mat + <sub>_BN.csv
  Results/brainnet_Map/ROIMAP/<sub>_ROIBN.mat + <sub>_ROIBN.csv（脑区提取时）

流程:
  1. mrtransform 将图谱 mask warp 到个体 DWI 空间
  2. tck2connectome 建连
  3. MATLAB 原生: readmatrix + save .mat + copyfile + writematrix
"""

import os
import shutil
from .utils import run_cmd, find_subjects, mkdir_p


def run(work_dir, folder, sub_list, dry=False,
        mask='', assign='voxels', metric='length',
        symmetric=True, zero_diagonal=True,
        search_length=0, tck_weight=False,
        output_txt=False, extract_regions=''):
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

    print(f"[INFO] 纤维网络矩阵构建（MATLAB 兼容模式）")

    # 确定图谱路径
    atlas = mask
    if not atlas:
        candidates = [
            os.path.join(work_dir, '..', 'Templates', 'Brainnetome_246_MNI152_1mm.nii.gz'),
            os.path.join(work_dir, '..', 'Templates', 'AAl3.nii'),
        ]
        for af in candidates:
            if os.path.isfile(af):
                atlas = af
                break
    if not atlas:
        templates_dir = os.path.join(work_dir, 'Templates')
        if os.path.isdir(templates_dir):
            for fname in sorted(os.listdir(templates_dir)):
                if fname.endswith('.nii') or fname.endswith('.nii.gz'):
                    atlas = os.path.join(templates_dir, fname)
                    break
    if not atlas:
        print("[ERROR] 未找到图谱模板文件")
        return

    for sub in sub_list:
        print(f"\n{'='*50}")
        print(f"[INFO] 处理被试: {sub}")
        sub_input = os.path.join(full_path, sub)

        # 找 tck 文件
        tck_file = None
        for cand in ['tracks_sift.tck', 'tracks.tck']:
            fp = os.path.join(sub_input, cand)
            if os.path.isfile(fp):
                tck_file = fp
                break
        if not tck_file:
            startname = os.path.basename(folder) if folder else ''
            for cand in [f'tracks_sift.tck', f'tracks.tck']:
                fp = os.path.join(work_dir, f'fiber_{startname}', sub, cand)
                if os.path.isfile(fp):
                    tck_file = fp
                    break
        if not tck_file:
            print(f"  [SKIP] {sub}: 无 .tck 文件")
            continue

        # 1. mrtransform: 将图谱 warp 到个体 DWI 空间
        brainnet_dir = mkdir_p(os.path.join(work_dir, 'brainnet', sub))
        dwi_txt = os.path.join(work_dir, 'dwi_coreg', sub, 'dwi_to_MNI_mrtrix.txt')
        mean_b0 = os.path.join(work_dir, 'pred_b0', sub, 'mean_b0.nii.gz')
        mask_in_dwi = os.path.join(brainnet_dir, 'mask.nii.gz')

        if os.path.isfile(dwi_txt) and os.path.isfile(mean_b0) and os.path.isfile(atlas):
            run_cmd(
                f'mrtransform {atlas} -linear {dwi_txt} -inverse '
                f'-template {mean_b0} {mask_in_dwi} '
                f'-interp nearest -datatype int32 -force', dry
            )

        # 2. tck2connectome
        bn_csv = os.path.join(brainnet_dir, 'BN.csv')
        assign_csv = os.path.join(brainnet_dir, 'assign.csv') if output_txt else ''
        cmd = f'tck2connectome {tck_file} {mask_in_dwi} {bn_csv}'

        if symmetric:
            cmd += ' -symmetric'
        if zero_diagonal:
            cmd += ' -zero_diagonal'

        if metric == 'length':
            cmd += ' -scale_length'
        elif metric == 'invlength':
            cmd += ' -scale_invlength'
        elif metric == 'invnodevol':
            cmd += ' -scale_invnodevol'

        if assign == 'radial':
            cmd += f' -assignment_radial_search {search_length or 4}'
        elif assign == 'reverse':
            cmd += f' -assignment_reverse_search {search_length or 4}'
        elif assign == 'forward':
            cmd += f' -assignment_forward_search {search_length or 4}'

        if tck_weight:
            w = os.path.join(sub_input, 'sift_weight.txt')
            if os.path.isfile(w):
                cmd += f' -tck_weights_in {w}'
        if output_txt:
            cmd += f' -out_assignment {assign_csv}'
        cmd += ' -force'
        run_cmd(cmd, dry)

        # 3. MATLAB 原生: 读 CSV → 存 .mat → 复制到 GlobalMap
        if os.path.isfile(bn_csv):
            global_dir = mkdir_p(os.path.join(work_dir, 'Results', 'brainnet_Map', 'GlobalMap'))
            try:
                import numpy as np
                mat_data = np.loadtxt(bn_csv, delimiter=',')
                mat_file = os.path.join(global_dir, f'{sub}_BN.mat')
                csv_file = os.path.join(global_dir, f'{sub}_BN.csv')
                if not dry:
                    import scipy.io as sio
                    sio.savemat(mat_file, {'BN': mat_data})
                    shutil.copy2(bn_csv, csv_file)
                else:
                    print(f"[DRY-RUN] save {mat_file}")
                    print(f"[DRY-RUN] copy {bn_csv} → {csv_file}")
            except Exception as e:
                print(f"  [WARN] 后处理失败: {e}")

        # 4. 脑区提取 → ROIMAP
        if extract_regions:
            region_list = [int(r.strip()) for r in extract_regions.split(',') if r.strip()]
            if region_list and os.path.isfile(bn_csv):
                roi_dir = mkdir_p(os.path.join(work_dir, 'Results', 'brainnet_Map', 'ROIMAP'))
                try:
                    import numpy as np
                    mat = np.loadtxt(bn_csv, delimiter=',')
                    sub_mat = mat[np.ix_(region_list, region_list)]
                    roi_mat = os.path.join(roi_dir, f'{sub}_ROIBN.mat')
                    roi_csv = os.path.join(brainnet_dir, f'{sub}_ROIBN.csv')
                    if not dry:
                        import scipy.io as sio
                        sio.savemat(roi_mat, {'ROIBN': sub_mat})
                        np.savetxt(roi_csv, sub_mat, delimiter=',', fmt='%f')
                    else:
                        print(f"[DRY-RUN] save {roi_mat}")
                        print(f"[DRY-RUN] save {roi_csv}")
                except Exception as e:
                    print(f"  [WARN] 脑区提取失败: {e}")

    print("\n[INFO] 矩阵构建完成")
