"""CLI 主入口 —— Click 命令树"""
import click
from .config import check_commands
from . import pre, dti, fod, fiber
from . import fba_organize, fba_subject, fba_template, fba_fixel, fba_stats
from . import map as map_module
from . import stats as stats_module
from . import update as update_module


# ── 全局上下文 ──────────────────────────────────────────────────

@click.group(invoke_without_command=False)
@click.option('--dry-run', is_flag=True, help='仅打印命令不执行，用于调试参数')
@click.pass_context
def cli(ctx, dry_run):
    """MRtrix3 弥散 MRI 处理管线终端工具 —— 完整替代 MATLAB GUI

    通过 subprocess 调用 MRtrix3/FSL/ANTs 命令（dwi2fod、fixelcfestats 等），
    与原始 MATLAB GUI 共享完全相同的目录结构和输出规范。

    可用命令:
      \b
      pre     预处理（格式转换→降噪→Gibbs→头动→Bias→T1分割→Mask）
      dti     弥散指标计算（FA/AD/RD/ADC/MK 等）
      fod     响应函数 + FOD 计算
      fiber   纤维追踪 + SIFT/SIFT2 + tck2nii
      fba     FBA 完整管线（6 个子命令）
      map     纤维网络矩阵构建 (tck2connectome)
      stats   统计分析工具集（4 个子命令）
      update  检查项目更新 / 拉取最新代码

    全局选项:
      \b
      --dry-run  仅打印要执行的命令，不实际运行（调试参数时推荐）
      --help     显示帮助信息

    快速上手:
      \b
      mrtrix-cli pre --work-dir /data --folder raw --subjects Sub01
      mrtrix-cli fba subject --work-dir /data --csd msmt
      mrtrix-cli update --check
    """
    ctx.ensure_object(dict)
    ctx.obj['dry_run'] = dry_run

    ok, missing = check_commands()
    if not ok and not dry_run:
        click.echo(f"警告: 以下命令未找到: {', '.join(missing)}", err=True)
        click.echo("请确认 PATH 中已包含 MRtrix3/FSL 等工具的 bin 目录", err=True)


# ── 辅助工具 ──────────────────────────────────────────────────

def DRY(ctx):
    return ctx.obj.get('dry_run', False)


def COMMON_OPTIONS(f):
    f = click.option('--subjects', '-s', default='',
                     help='逗号分隔的被试列表（如 Sub01,Sub02）。不传则自动扫描 Sub* 目录')(f)
    f = click.option('--folder', '-f', default='',
                     help='存放 Sub* 目录的起始文件夹名（如 raw、dwimif），相对 --work-dir')(f)
    return f


def workdir_option(f):
    return click.option('--work-dir', '-w', required=True,
                        help='工作路径 (workPath)，所有输出均在此路径下生成')(f)


# ═══════════════════════════════════════════════════════════════
# pre: 预处理
# ═══════════════════════════════════════════════════════════════

@cli.command('pre')
@workdir_option
@COMMON_OPTIONS
@click.option('--format/--no-format', 'do_format', default=True,
              help='[默认开启] nii.gz → mif 格式转换 (mrconvert)，同时转换 T1。输出到 dwimif/<sub>/')
@click.option('--denoise/--no-denoise', default=True,
              help='[默认开启] dwidenoise 降噪。输出到 denoise/<sub>/')
@click.option('--gibbs/--no-gibbs', default=True,
              help='[默认开启] mrdegibbs 消除 Gibbs Ring 伪影。输出到 gibbs/<sub>/')
@click.option('--headmove/--no-headmove', default=True,
              help='[默认开启] dwifslpreproc 头动矫正 + 涡流变形矫正（含 eddy）。输出到 headmove/<sub>/')
@click.option('--bias/--no-bias', default=True,
              help='[默认开启] dwibiascorrect ants B1 场不均匀性校正。输出到 bias/<sub>/')
@click.option('--t1corg/--no-t1corg', default=True,
              help='[默认开启] 5ttgen fsl T1 结构像五组织分割。输出到 T1seg/<sub>/')
@click.option('--t1-to-mni/--no-t1-to-mni', default=True,
              help='[默认开启] 将 T1 配准到 MNI 标准空间 (mrregister)')
@click.option('--dwi-to-mni/--no-dwi-to-mni', default=True,
              help='[默认开启] 将 DWI 配准到 MNI 标准空间 (mrregister)。输出到 dwiMNI/<sub>/')
@click.option('--mask/--no-mask', default=True,
              help='[默认开启] dwi2mask 提取脑 mask，在当前步骤目录下生成 dwi_mask.mif')
@click.pass_context
def cmd_pre(ctx, work_dir, subjects, folder, **kwargs):
    """预处理管线: 格式转换→降噪→Gibbs→头动→Bias→T1分割→MNI配准→Mask

    按顺序执行以下步骤，每个步骤的输出目录依次递进：

    1. --format:    nii.gz → mif 格式转换 (mrconvert)
    2. --denoise:   降噪 (dwidenoise)
    3. --gibbs:     Gibbs Ring 消除 (mrdegibbs)
    4. --headmove:  头动 + 涡流变形矫正 (dwifslpreproc)
    5. --bias:      B1 场不均匀性校正 (dwibiascorrect)
    6. --t1corg:    T1 结构像分割 (5ttgen fsl)
    7. --t1-to-mni: T1 → MNI 空间 (mrregister)
    8. --dwi-to-mni: DWI → MNI 空间 (mrregister)
    9. --mask:      脑 mask 提取 (dwi2mask)

    使用示例:

      mrtrix-cli pre -w /data -f raw -s Sub01,Sub02

      mrtrix-cli pre -w /data -f raw -s Sub01 --no-gibbs --no-denoise

      mrtrix-cli pre -w /data -f raw -s Sub01 --t1-to-mni --dwi-to-mni

    注意: 不传 --subjects 时自动扫描 --folder 下的所有 Sub* 目录。
    """
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    pre.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# dti: 弥散指标
# ═══════════════════════════════════════════════════════════════

@cli.command('dti')
@workdir_option
@COMMON_OPTIONS
@click.option('--dt/--no-dt', default=True,
              help='[默认开启] dwi2tensor 弥散张量拟合，生成 dt.mif')
@click.option('--dkt/--no-dkt', default=False,
              help='[默认关闭] dwi2fod 弥散峰度张量拟合，生成 dki.mif')
@click.option('--fa/--no-fa', default=True,
              help='[默认开启] tensor2metric 计算分数各向异性 (FA)')
@click.option('--ad/--no-ad', default=False,
              help='[默认关闭] tensor2metric 计算轴向扩散率 (AD)')
@click.option('--rd/--no-rd', default=False,
              help='[默认关闭] tensor2metric 计算径向扩散率 (RD)')
@click.option('--adc/--no-adc', default=False,
              help='[默认关闭] tensor2metric 计算平均表观扩散系数 (ADC)')
@click.option('--cl/--no-cl', default=False,
              help='[默认关闭] tensor2metric 计算线性度量 (CL)')
@click.option('--cp/--no-cp', default=False,
              help='[默认关闭] tensor2metric 计算平面度量 (CP)')
@click.option('--cs/--no-cs', default=False,
              help='[默认关闭] tensor2metric 计算球形度量 (CS)')
@click.option('--mk/--no-mk', default=False,
              help='[默认关闭] tensor2metric 计算平均峰度 (MK)')
@click.option('--ak/--no-ak', default=False,
              help='[默认关闭] tensor2metric 计算轴向峰度 (AK)')
@click.option('--rk/--no-rk', default=False,
              help='[默认关闭] tensor2metric 计算径向峰度 (RK)')
@click.pass_context
def cmd_dti(ctx, work_dir, subjects, folder, **kwargs):
    """弥散指标计算: 张量拟合 + 多种 DTI/DKI 指标

    先对 DWI 数据进行张量/峰度张量拟合，再计算选中的各项指标。

    DTI 指标（基于弥散张量，需 --dt）:
      \b
      --fa   分数各向异性          --ad  轴向扩散率
      --rd   径向扩散率            --adc 平均表观扩散系数
      --cl   线性度量              --cp  平面度量
      --cs   球形度量

    DKI 指标（基于弥散峰度张量，需 --dkt）:
      \b
      --mk   平均峰度              --ak  轴向峰度
      --rk   径向峰度

    使用示例:

      mrtrix-cli dti -w /data -f dwimif -s Sub01 --fa --ad --rd

      mrtrix-cli dti -w /data -f dwimif -s Sub01 --dt --dkt --mk --ak
    """
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    dti.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# fod: 响应函数 + FOD
# ═══════════════════════════════════════════════════════════════

@cli.command('fod')
@workdir_option
@COMMON_OPTIONS
@click.option('--resp/--no-resp', default=True,
              help='[默认开启] dwi2response 估计响应函数')
@click.option('--resp-algo',
              type=click.Choice(['dhollander', 'fa', 'msmt_5tt', 'tax', 'tournier']),
              default='dhollander',
              help='响应函数算法 [默认: dhollander]。'
                   'dhollander=多组织(WF/GM/CSF)，fa=基于FA阈值，'
                   'msmt_5tt=基于5tt分割，tax=Tax方法，tournier=Tournier方法')
@click.option('--fod/--no-fod', default=True,
              help='[默认开启] dwi2fod 纤维方向分布 (FOD) 计算')
@click.option('--fod-algo',
              type=click.Choice(['csd', 'msmt_csd']), default='msmt_csd',
              help='FOD 算法 [默认: msmt_csd]。'
                   'csd=单组织CSD（仅WM），msmt_csd=多组织CSD（WM+GM+CSF，推荐）')
@click.option('--norm/--no-norm', default=True,
              help='[默认开启] mtnormalise 多组织强度标准化，生成 wmfod_norm.mif')
@click.pass_context
def cmd_fod(ctx, work_dir, subjects, folder, **kwargs):
    """FOD 响应函数 + 纤维方向分布计算

    三步管线:
      1. --resp:     dwi2response 估计响应函数
      2. --fod:      dwi2fod 计算纤维方向分布 (FOD)
      3. --norm:     mtnormalise 强度标准化

    响应函数算法 (--resp-algo) 说明:
      \b
      dhollander  多组织响应函数（WM/GM/CSF 三种），适合多组织 CSD（推荐）
      fa          基于 FA 阈值的单组织 WM 响应函数
      msmt_5tt    基于 5tt 分割的多组织响应函数
      tax         Tax 算法
      tournier    Tournier 算法

    FOD 算法 (--fod-algo) 说明:
      \b
      csd         单组织 CSD，仅使用 WM 响应函数
      msmt_csd    多组织 CSD，使用 WM/GM/CSF 三种响应函数（推荐）

    使用示例:

      mrtrix-cli fod -w /data -f dwimif -s Sub01 --resp-algo dhollander --fod-algo msmt_csd

      mrtrix-cli fod -w /data -f dwimif -s Sub01 --no-resp --fod-algo csd --norm

    注意: 各步骤可通过 --no-* 独立跳过。fba 流程中响应函数是分步做的，
          这里主要用于独立使用 fod 模块。
    """
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    fod.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# fiber: 纤维追踪
# ═══════════════════════════════════════════════════════════════

@cli.command('fiber')
@workdir_option
@COMMON_OPTIONS
@click.option('--algo',
              type=click.Choice(['ifod2', 'sd_stream', 'tensor_det', 'tensor_prob', 'fact']),
              default='ifod2',
              help='纤维追踪算法 [默认: ifod2]。'
                   'ifod2=iFOD2（第二代，推荐），sd_stream=SD_Stream，'
                   'tensor_det=Tensor_Det，tensor_prob=Tensor_Prob，fact=FACT')
@click.option('--mode',
              type=click.Choice(['whole_brain', 'seed', 'roi', 'mask']),
              default='whole_brain',
              help='追踪模式 [默认: whole_brain]。'
                   'whole_brain=全脑追踪，seed=基于单种子点，'
                   'roi=基于ROI区域，mask=基于mask')
@click.option('--step-size', default=0.5,
              help='追踪步进长度，单位 mm [默认: 0.5]')
@click.option('--angle', default=45,
              help='最大转角阈值，单位 度 [默认: 45]')
@click.option('--min-length', default=2,
              help='纤维最小长度，单位 mm [默认: 2]')
@click.option('--max-length', default=100,
              help='纤维最大长度，单位 mm [默认: 100]')
@click.option('--fod-cutoff', default=0.1,
              help='追踪终止的 FOD 振幅阈值 [默认: 0.1]')
@click.option('--max-tries', default=1000,
              help='每个种子点的最大尝试次数 [默认: 1000]')
@click.option('--fiber-num', default='10m',
              help='需要生成的纤维条数。支持 k/m 后缀，如 10m=1千万, 100k=10万 [默认: 10m]')
@click.option('--seeds', default='10m',
              help='种子点数上限。支持 k/m 后缀 [默认: 10m]')
@click.option('--sift2/--no-sift2', default=False,
              help='[默认关闭] tcksift2 生成纤维权重文件（tracks_weights.csv），用于后续的 SIFT2 分析')
@click.option('--sift/--no-sift', default=False,
              help='[默认关闭] tcksift 缩减纤维数量')
@click.option('--sift-num', default='1m',
              help='SIFT 缩减后的目标纤维条数 [默认: 1m]')
@click.option('--tck2nii/--no-tck2nii', default=False,
              help='[默认关闭] tckmap 将 .tck 转为 .nii 密度映射图')
@click.option('--tck2nii-method',
              type=click.Choice(['tdi', 'length', 'invlength', 'fod_amp', 'curvature']),
              default='tdi',
              help='tck→nii 映射方法 [默认: tdi]。'
                   'tdi=纤维密度，length=纤维长度，'
                   'invlength=长度倒数，fod_amp=FOD幅值，curvature=曲率')
@click.pass_context
def cmd_fiber(ctx, work_dir, subjects, folder, **kwargs):
    """纤维追踪 + SIFT/SIFT2 + tck2nii

    追踪算法 (--algo):
      \b
      ifod2        iFOD2 算法（默认，推荐用于 FOD 数据）
      sd_stream    SD_Stream 确定性追踪
      tensor_det   Tensor_Det 张量确定性追踪
      tensor_prob  Tensor_Prob 张量概率追踪
      fact         FACT 确定性追踪

    追踪模式 (--mode):
      \b
      whole_brain  全脑追踪（默认，使用 DWI mask 约束）
      seed         基于单种子点坐标/区域
      roi          基于 ROI 区域追踪
      mask         基于 mask 的纤维追踪

    后处理:
      \b
      --sift2    SIFT2 纤维权重（产物: tracks_weights.csv）
      --sift     SIFT 纤维缩减（产物: tracks_sift.tck）
      --tck2nii  将 .tck 转为 .nii 密度图

    使用示例:

      # 全脑追踪 1000 万条纤维
      mrtrix-cli fiber -w /data -f dwimif -s Sub01 --algo ifod2 --fiber-num 10m

      # 追踪 + SIFT 缩减到 100 万 + 转 nii
      mrtrix-cli fiber -w /data -f dwimif -s Sub01 --sift --sift-num 1m --tck2nii

      # 追踪 + SIFT2 权重
      mrtrix-cli fiber -w /data -f dwimif -s Sub01 --sift2 --tck2nii --tck2nii-method length
    """
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    fiber.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# fba: FBA 纤维分析（子命令组）
# ═══════════════════════════════════════════════════════════════

@cli.group()
def fba():
    """FBA 完整管线: 数据整理→个体→模板→配准→Fixel→统计

    6 个子命令:
      \b
      organize  FBA 步骤0: 数据整理
      subject   FBA 步骤1: 个体水平处理 (step1-6)
      template  FBA 步骤2: 构建群体模板
      register  FBA 步骤2b: 配准到模板 + mask 交集
      fixel     FBA 步骤3: Fixel 指标计算 + 追踪 + 平滑 (step10-19)
      stats     FBA 步骤4: CFE 统计分析 (step20)

    推荐执行顺序:
      organize → subject → template → register → fixel → stats

    使用示例:
      mrtrix-cli fba subject --work-dir /data --csd msmt
      mrtrix-cli fba stats -w /data -d design.txt -c contrast.txt
    """


@fba.command('organize')
@click.option('--work-dir', '-w', required=True,
              help='工作路径，fba/subjects/ 将在此路径下创建')
@click.option('--source', '-S', type=(str, str, str), multiple=True,
              help='源数据。格式: "-S 条件 时间点 源路径"，可重复多次指定不同条件/时间点。'
                   '源路径应指向包含 Sub* 目录的预处理输出文件夹。'
                   '例如: -S healthy baseline /data/preproc')
@click.option('--sep', default='_',
              help='目标目录名中条件与时间点之间的分隔符 [默认: _]。'
                   '例如: Sub01_healthy_baseline')
@click.option('--copy/--link', default=True,
              help='[默认: --copy] --copy=复制 dwi.mif 到目标目录，'
                   '--link=创建软链接。软链接更省空间但源文件不能删除')
@click.pass_context
def cmd_fba_organize(ctx, work_dir, source, sep, copy):
    """FBA 步骤0: 数据整理 —— 将多条件/多时间点的 dwi.mif 汇总到 fba/subjects/

    将来自不同条件（如 control/disease）和不同时间点（如 baseline/followup）
    的预处理后 dwi.mif 文件，按规则命名后统一复制到 fba/subjects/ 目录下。

    目标目录命名规则:
      Sub<原被试名><分隔符><条件><分隔符><时间点>
      例如: Sub01_control_baseline, Sub02_disease_followup

    使用示例:

      # 单条件单时间点
      mrtrix-cli fba organize -w /data -S control baseline /data/preproc

      # 多条件多时间点
      mrtrix-cli fba organize -w /data \\
        -S control baseline  /data/control/baseline \\
        -S control followup  /data/control/followup \\
        -S disease baseline  /data/patient/baseline \\
        -S disease followup  /data/patient/followup

      # 使用软链接
      mrtrix-cli fba organize -w /data --link -S control baseline /data/preproc

    注意: 源路径下的子目录必须以 Sub 或 sub 开头。
    """
    fba_organize.run(work_dir, list(source), sep, copy, dry=DRY(ctx))


@fba.command('subject')
@click.option('--work-dir', '-w', required=True,
              help='工作路径，需要已运行 fba organize')
@click.option('--csd', type=click.Choice(['msmt', 'st']), default='msmt',
              help='CSD 算法 [默认: msmt]。msmt=多组织(dhollander)，st=单组织(tournier)')
@click.option('--voxel', default=1.25,
              help='DWI 上采样目标体素大小（各向同性），单位 mm [默认: 1.25]')
@click.option('--subjects', '-s', default='',
              help='逗号分隔的被试列表（如 Sub01,Sub02）。不传则自动检索 fba/subjects/ 下所有 Sub* 目录')
@click.option('--no-resp', is_flag=True,
              help='跳过步骤1: dwi2response 响应函数计算')
@click.option('--no-respmean', is_flag=True,
              help='跳过群体平均响应函数 (responsemean)')
@click.option('--no-upsample', is_flag=True,
              help='跳过步骤2: mrgrid regrid 上采样 + dwi2mask')
@click.option('--no-csd', is_flag=True,
              help='跳过步骤3: dwi2fod FOD 计算')
@click.option('--no-norm', is_flag=True,
              help='跳过步骤4: mtnormalise 归一化')
@click.pass_context
def cmd_fba_subject(ctx, work_dir, csd, voxel, subjects, **kwargs):
    """FBA 步骤1: 个体水平处理 (step1-6)

    按顺序执行 6 个子步骤:
      1. dwi2response        计算个体响应函数
      2. responsemean        群体平均响应函数
      3. mrgrid regrid       DWI 上采样到各向同性体素（默认 1.25mm）
      4. dwi2mask            计算上采样后的脑 mask
      5. dwi2fod             FOD 计算（CSD 或 MSMT-CSD）
      6. mtnormalise         多组织强度归一化

    CSD 算法说明:
      \b
      msmt  多组织 CSD（dhollander）— 推荐，使用 WM/GM/CSF 三种响应函数
      st    单组织 CSD（tournier）— 仅使用 WM 响应函数，速度更快

    使用示例:

      # 完整运行（自动检索全部被试）
      mrtrix-cli fba subject -w /data --csd msmt

      # 指定被试 + 自定义体素大小
      mrtrix-cli fba subject -w /data --csd msmt --voxel 1.5 -s Sub01,Sub02

      # 只跑 CSD 和归一化（跳过响应函数和上采样）
      mrtrix-cli fba subject -w /data --csd msmt --no-resp --no-upsample

    注意: 必须先运行 fba organize 准备好数据。
    """
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    fba_subject.run(work_dir, csd, voxel, sub_list, dry=DRY(ctx), **kwargs)


@fba.command('template')
@click.option('--work-dir', '-w', required=True,
              help='工作路径（需要已运行 fba subject）')
@click.option('--voxel', default=1.25,
              help='模板体素大小，单位 mm（各向同性）[默认: 1.25]')
@click.option('--subjects', '-s', default='',
              help='用于构建模板的被试列表（逗号分隔）。不传则使用所有完成个体处理的被试')
@click.option('--no-subset', is_flag=True,
              help='强制使用全部被试构建模板，忽略 --subjects 指定的子集')
@click.pass_context
def cmd_fba_template(ctx, work_dir, voxel, subjects, no_subset):
    """FBA 步骤2: 构建群体模板

    通过 population_template 命令，对所有被试已归一化的 wmfod_norm.mif
    进行迭代配准，生成群体平均模板，保存为 fba/template/wmfod_template.mif。

    使用示例:

      # 使用全部被试（默认）
      mrtrix-cli fba template -w /data

      # 指定体素大小
      mrtrix-cli fba template -w /data --voxel 1.25

      # 使用部分被试
      mrtrix-cli fba template -w /data -s Sub01,Sub02,Sub03

    注意: 所有被试必须已完成 fba subject 的归一化步骤（有 wmfod_norm.mif）。
    """
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects and not no_subset else []
    fba_template.build_template(work_dir, voxel, sub_list, dry=DRY(ctx))


@fba.command('register')
@click.option('--work-dir', '-w', required=True,
              help='工作路径（需要已运行 fba template）')
@click.option('--scale', default='0.5,0.75,1.0',
              help='多级配准尺度，逗号分隔（从粗到细）。数值代表体素大小的倍数。'
                   '例如 "0.5,0.75,1.0" 表示先在 0.5 倍体素尺度配准，逐步到原始尺度 [默认: 0.5,0.75,1.0]')
@click.option('--niter', default='5,5,15',
              help='每级配准的迭代次数，逗号分隔（与 --scale 一一对应）[默认: 5,5,15]')
@click.option('--subjects', '-s', default='',
              help='逗号分隔的被试列表。不传则配准所有完成个体处理的被试')
@click.pass_context
def cmd_fba_register(ctx, work_dir, scale, niter, subjects):
    """FBA 步骤2b: 配准到模板 + mask 交集

    1. mrregister 将每个被试的 wmfod_norm.mif 非线性配准到群体模板
    2. 生成 subject2template_warp.mif 和 template2subject_warp.mif 变形场
    3. mrmath 计算所有被试 mask 的共有区域（mask_inter.mif）

    使用示例:

      # 默认参数
      mrtrix-cli fba register -w /data

      # 自定义配准参数（更精细的 4 级配准）
      mrtrix-cli fba register -w /data --scale "0.3,0.5,0.8,1.0" --niter "3,5,8,10"

    注意: 必须先运行 fba template 构建模板。
    """
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    fba_template.register(work_dir, scale, niter, sub_list, dry=DRY(ctx))


@fba.command('fixel')
@click.option('--work-dir', '-w', required=True,
              help='工作路径（需要已运行 fba register）')
@click.option('--skip-track', is_flag=True,
              help='跳过模板全脑追踪 (step17-18)。如果已有 tracks.tck 可跳过以节省时间')
@click.option('--skip-smooth', is_flag=True,
              help='跳过指标平滑 (step19)。如果已有平滑结果可跳过')
@click.pass_context
def cmd_fba_fixel(ctx, work_dir, skip_track, skip_smooth):
    """FBA 步骤3: Fixel 指标计算 + 模板追踪 + 连接矩阵 + 指标平滑

    按顺序执行 step10-19:
      \b
      step10  fod2fixel              模板 fixel mask
      step11  mrtransform            将 FOD 变形到模板空间
      step12  fod2fixel -afd         计算纤维密度 (FD)
      step13  fixelreorient          Fixel 重定向
      step14  fixelcorrespondence    Fixel 跨被试对应
      step15  warp2metric -fc        纤维截面变化 (FC)
      step16  mrcalc                 计算 log(FC) 和 FDC
      step17  tckgen + tcksift       模板全脑追踪（可跳过）
      step18  fixelconnectivity      fixel-fixel 连接矩阵
      step19  fixelfilter smooth     FD/FC/FDC 指标平滑（可跳过）

    使用示例:

      # 完整运行
      mrtrix-cli fba fixel -w /data

      # 跳过追踪（已有结果时）
      mrtrix-cli fba fixel -w /data --skip-track

      # 跳过追踪和平滑
      mrtrix-cli fba fixel -w /data --skip-track --skip-smooth

    注意: 必须先运行 fba template 和 fba register。
    """
    fba_fixel.run(work_dir, dry=DRY(ctx), skip_track=skip_track, skip_smooth=skip_smooth)


@fba.command('stats')
@click.option('--work-dir', '-w', required=True,
              help='工作路径（需要已运行 fba fixel）')
@click.option('--design', '-d', required=True,
              help='设计矩阵文件路径。文本格式：每行一个被试，'
                   '每列一个解释变量（组别、协变量等），空格或制表符分隔。'
                   '第一行可为列名（会被忽略）')
@click.option('--contrast', '-c', required=True,
              help='对比矩阵文件路径。文本格式：每行一个对比，每列对应设计矩阵的一列。'
                   '例如: "1 -1 0" 表示两组比较')
@click.option('--metrics', default='fd,log_fc,fdc',
              help='待分析的 fixel 指标，逗号分隔。'
                   '可选: fd（纤维密度）, log_fc（纤维截面对数）, fdc（FD×FC）'
                   '[默认: fd,log_fc,fdc]')
@click.option('--nshuffles', default=5000,
              help='基于排列检验的置换次数。'
                   '值越大结果越稳定，推荐至少 5000 [默认: 5000]')
@click.option('--cfe-h', default=3.0,
              help='CFE 高度参数 (h)。控制增强的敏感度，通常 2.0-3.0 [默认: 3.0]')
@click.option('--cfe-e', default=0.5,
              help='CFE 延伸参数 (e)。控制空间平滑延伸程度，通常 0.5-1.0 [默认: 0.5]')
@click.option('--cfe-c', default=0.5,
              help='CFE 连接参数 (c)。控制连接权重的影响 [默认: 0.5]')
@click.option('--exchange', default='',
              help='exchangeability 块文件路径。用于配对设计/重复测量/区组设计的'
                   '置换块定义。不传则默认逐行独立置换')
@click.option('--suffix', default='',
              help='输出目录名后缀。例如 --suffix _robust 会输出到 '
                   'stats_fd_robust、stats_log_fc_robust 等')
@click.pass_context
def cmd_fba_stats(ctx, work_dir, design, contrast, metrics, **kwargs):
    """FBA 步骤4: CFE 统计分析 (fixelcfestats)

    对 FD / log(FC) / FDC 三个 fixel 指标进行基于排列检验的
    CFE（Connectivity-based Fixel Enhancement）统计分析。

    需要准备:
      \b
      --design    设计矩阵，描述被试所属组别/协变量
      --contrast  对比矩阵，定义要检验的假设

    设计矩阵示例 (design_matrix.txt):
      \b
      1 0   （第1组）
      1 0
      0 1   （第2组）
      0 1

    对比矩阵示例 (contrast_matrix.txt):
      \b
      1 -1  （第1组 > 第2组）

    使用示例:

      # 两组比较
      mrtrix-cli fba stats -w /data \\
        --design design.txt --contrast contrast.txt \\
        --metrics fd,log_fc,fdc --nshuffles 5000

      # 只分析 FD，自定义 CFE 参数
      mrtrix-cli fba stats -w /data \\
        -d design.txt -c contrast.txt \\
        --metrics fd --nshuffles 10000 \\
        --cfe-h 3.0 --cfe-e 0.5 --cfe-c 0.5

      # 配对设计（需要 exchangeability 块文件）
      mrtrix-cli fba stats -w /data \\
        -d design.txt -c contrast.txt \\
        --exchange exchange.txt

    注意: 必须先运行 fba fixel 完成所有指标计算和平滑。
    """
    metric_list = [m.strip() for m in metrics.split(',')]
    fba_stats.run(work_dir, design, contrast, metric_list, dry=DRY(ctx), **kwargs)


# ═══════════════════════════════════════════════════════════════
# map: 纤维网络矩阵
# ═══════════════════════════════════════════════════════════════

@cli.command('map')
@workdir_option
@COMMON_OPTIONS
@click.option('--mask', '-m', default='',
              help='mask 文件路径（NIfTI）。用于约束纤维到节点的分配范围')
@click.option('--assign',
              type=click.Choice(['voxels', 'radial', 'reverse', 'forward']),
              default='voxels',
              help='纤维到节点的分配标准 [默认: voxels]。'
                   'voxels=基于体素交集，radial=径向搜索分配，'
                   'reverse=反向搜索分配，forward=前向搜索分配')
@click.option('--metric',
              type=click.Choice(['length', 'invlength', 'invnodevol']),
              default='length',
              help='矩阵边权重指标 [默认: length]。'
                   'length=连接长度（mm），invlength=长度倒数（1/mm），'
                   'invnodevol=节点体积倒数')
@click.option('--symmetric/--no-symmetric', default=True,
              help='[默认开启] 矩阵对称化: M = (M + M^T) / 2')
@click.option('--zero-diagonal/--no-zero-diagonal', default=True,
              help='[默认开启] 将对角线元素置零（去除自连接）')
@click.option('--search-length', default=0,
              help='纤维分配搜索长度（mm）。当 --assign 为 radial/reverse/forward 时使用 [默认: 4]')
@click.option('--tck-weight/--no-tck-weight', default=False,
              help='[默认关闭] 使用 SIFT2 纤维权重文件 (tracks_weights.csv) 加权矩阵')
@click.option('--output-txt/--no-output-txt', default=False,
              help='[默认关闭] 额外输出制表符分隔的 .txt 文件（CSV 外的另一种格式）')
@click.option('--extract-regions', default='',
              help='提取指定脑区的子矩阵。逗号分隔脑区编号（如 "1,2,3,4"），'
                   '基于脑图谱的索引')
@click.pass_context
def cmd_map(ctx, work_dir, subjects, folder, **kwargs):
    """纤维网络矩阵构建 (tck2connectome)

    使用纤维追踪结果和脑图谱模板，将纤维分配到脑区节点，构建连接矩阵。

    脑图谱: 自动从项目 Templates/ 目录加载。支持 Brainnetome 246、AAL3、DISTAL 等。

    纤维分配标准 (--assign):
      \b
      voxels   基于体素交集分配（最快，默认）
      radial   基于径向搜索分配，需要 --search-length
      reverse  反向搜索分配，需要 --search-length
      forward  前向搜索分配，需要 --search-length

    矩阵指标 (--metric):
      \b
      length       边权重=纤维长度（mm，默认）
      invlength    边权重=纤维长度的倒数
      invnodevol   边权重=节点体积的倒数

    后处理:
      \b
      --symmetric      对称化: M = (M + M^T) / 2
      --zero-diagonal  对角线归零
      --output-txt     同时输出 .txt 格式
      --extract-regions 提取子矩阵

    使用示例:

      mrtrix-cli map -w /data -f fiber -s Sub01 --assign voxels --metric length

      mrtrix-cli map -w /data -f fiber -s Sub01 --symmetric --zero-diagonal

      mrtrix-cli map -w /data -f fiber -s Sub01 --extract-regions 1,2,3,4 --output-txt
    """
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    map_module.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# stats: 统计分析
# ═══════════════════════════════════════════════════════════════

@cli.group()
def stats():
    """统计分析工具集 —— 4 个子命令

    \b
    mrstats          弥散指标数值提取
    mrclusterstats   弥散指标统计分析
    connectomestats  连接网络统计分析
    tckstats         纤维指标数值提取

    使用示例:
      mrtrix-cli stats mrstats -i fa.mif -o fa_stats.csv
      mrtrix-cli stats mrclusterstats -i input.mif -d design.txt -c contrast.txt
    """


@stats.command('mrstats')
@click.option('--input', '-i', required=True,
              help='输入图像路径，支持 .mif 或 .nii.gz 格式')
@click.option('--mask', '-m', default='',
              help='mask 文件路径，只统计 mask 内的体素。不传则统计全脑')
@click.option('--output', '-o', default='',
              help='输出 CSV 文件路径。不传则直接打印到终端')
@click.pass_context
def cmd_mrstats(ctx, input, mask, output):
    """弥散指标数值提取 (mrstats)

    从 .mif / .nii 图像中提取弥散指标的数值统计（均值、标准差等）。

    使用示例:
      mrtrix-cli stats mrstats -i dti/fa.mif -o fa_stats.csv
      mrtrix-cli stats mrstats -i wmfod.mif -m mask.mif
    """
    stats_module.run_mrstats(input, mask, output, dry=DRY(ctx))


@stats.command('mrclusterstats')
@click.option('--input', '-i', required=True,
              help='输入图像路径（.mif/.nii）')
@click.option('--design', '-d', required=True,
              help='设计矩阵文件路径')
@click.option('--contrast', '-c', required=True,
              help='对比矩阵文件路径')
@click.option('--nshuffles', default=5000,
              help='基于排列检验的置换次数 [默认: 5000]')
@click.option('--output', '-o', default='',
              help='输出文件前缀，结果保存为 <前缀>_<指标>.mif')
@click.pass_context
def cmd_mrclusterstats(ctx, input, design, contrast, nshuffles, output):
    """弥散指标体素统计分析 (mrclusterstats)

    对体素或 fixel 指标进行基于排列的聚类统计分析。

    使用示例:
      mrtrix-cli stats mrclusterstats -i fd.mif -d design.txt -c contrast.txt --nshuffles 5000
    """
    stats_module.run_mrclusterstats(input, design, contrast, nshuffles, output, dry=DRY(ctx))


@stats.command('connectomestats')
@click.option('--input', '-i', required=True,
              help='连接矩阵列表文件（包含所有被试的连接矩阵路径列表）')
@click.option('--design', '-d', required=True,
              help='设计矩阵文件路径')
@click.option('--contrast', '-c', required=True,
              help='对比矩阵文件路径')
@click.option('--nshuffles', default=5000,
              help='基于排列检验的置换次数 [默认: 5000]')
@click.pass_context
def cmd_connectomestats(ctx, input, design, contrast, nshuffles):
    """连接网络统计分析 (connectomestats)

    对连接矩阵进行基于排列的统计分析（网络级统计推断）。

    使用示例:
      mrtrix-cli stats connectomestats -i connectome_list.txt -d design.txt -c contrast.txt
    """
    stats_module.run_connectomestats(input, design, contrast, nshuffles, dry=DRY(ctx))


@stats.command('tckstats')
@click.option('--input', '-i', required=True,
              help='纤维文件路径，.tck 格式')
@click.option('--output', '-o', default='',
              help='输出 CSV 文件路径。不传则打印到终端')
@click.option('--dump', default='',
              help='输出逐条纤维的详细值到文件（可选），CSV 格式')
@click.pass_context
def cmd_tckstats(ctx, input, output, dump):
    """纤维指标数值提取 (tckstats)

    从 .tck 纤维文件中提取纤维的各项统计指标。

    使用示例:
      mrtrix-cli stats tckstats -i tracks.tck -o tck_stats.csv
      mrtrix-cli stats tckstats -i tracks.tck --dump per_fiber.csv
    """
    stats_module.run_tckstats(input, output, dump, dry=DRY(ctx))


# ═══════════════════════════════════════════════════════════════
# update: 检查更新 / 拉取最新代码
# ═══════════════════════════════════════════════════════════════

@cli.command('update')
@click.option('--check', is_flag=True,
              help='仅检查版本更新，不拉取代码')
@click.option('--pull', is_flag=True,
              help='检查更新并执行 git pull 拉取最新代码')
def cmd_update(check, pull):
    """检查项目更新或拉取最新代码

    对比本地 git commit SHA 与 Gitee/GitHub 远程最新 commit,
    发现有新版本后可选择直接 git fetch + git reset 更新。

    使用示例:
      mrtrix-cli update --check
      mrtrix-cli update --pull
    """
    if not check and not pull:
        check = True

    local, remote, source, has_update = update_module.check_update()

    if local:
        click.echo(f"本地版本:  {local[:7]}")
    else:
        click.echo("本地版本:  未知（非 git 仓库）")

    if remote:
        src_name = {'gitee': 'Gitee', 'github': 'GitHub'}.get(source, source)
        click.echo(f"远程版本:  {remote[:7]} ({src_name})")
    else:
        click.echo("远程版本:  获取失败（检查网络）")

    if has_update:
        click.echo("\n→ 发现新版本！")
    else:
        click.echo("\n→ 已是最新版本")

    if pull and has_update:
        click.echo("\n正在拉取更新...")
        ok, result = update_module.do_pull()
        if ok:
            click.echo("✓ 更新成功")
            click.echo(f"  请重新安装: pip install -e {result}")
            click.echo("  然后重启 mrtrix-cli")
        else:
            click.echo(f"✗ 更新失败: {result}")


# ═══════════════════════════════════════════════════════════════
# 入口
# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    cli()
