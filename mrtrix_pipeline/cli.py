"""CLI 主入口 —— Click 命令树

用法:
    mrtrix-cli [--dry-run] [--config PATH] COMMAND [ARGS]...
"""

import click

from .config import check_commands
from . import pre, dti, fod, fiber
from . import fba_organize, fba_subject, fba_template, fba_fixel, fba_stats
from . import map as map_module
from . import stats as stats_module
from . import update as update_module


# ── 全局上下文 ──────────────────────────────────────────────────

@click.group(invoke_without_command=False)
@click.option('--dry-run', is_flag=True, help='仅打印命令不执行')
@click.pass_context
def cli(ctx, dry_run):
    """MRtrix3 弥散 MRI 处理管线终端工具

    完整替代 MATLAB GUI，通过 subprocess 调用 MRtrix3/FSL/ANTs 命令。
    与原始 MATLAB GUI 共享完全相同的目录结构和输出规范。
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
    f = click.option('--subjects', '-s', help='被试列表，逗号分隔（如 Sub01,Sub02）', default='')(f)
    f = click.option('--folder', '-f', help='起始文件夹名（相对工作路径）', default='')(f)
    return f


def workdir_option(f):
    return click.option('--work-dir', '-w', required=True, help='工作路径 (workPath)')(f)


# ═══════════════════════════════════════════════════════════════
# pre: 预处理
# ═══════════════════════════════════════════════════════════════

@cli.command('pre')
@workdir_option
@COMMON_OPTIONS
@click.option('--format/--no-format', 'do_format', default=True, help='nii → mif 格式转换')
@click.option('--denoise/--no-denoise', default=True, help='降噪 (dwidenoise)')
@click.option('--gibbs/--no-gibbs', default=True, help='Gibbs Ring 消除')
@click.option('--headmove/--no-headmove', default=True, help='头动矫正 + 变形矫正')
@click.option('--bias/--no-bias', default=True, help='B1 场不均匀性校正')
@click.option('--t1corg/--no-t1corg', default=True, help='T1 结构像分割 (5ttgen)')
@click.option('--t1-to-mni/--no-t1-to-mni', default=False, help='T1 配准到 MNI')
@click.option('--dwi-to-mni/--no-dwi-to-mni', default=False, help='DWI 配准到 MNI')
@click.option('--mask/--no-mask', default=True, help='提取脑 mask')
@click.pass_context
def cmd_pre(ctx, work_dir, subjects, folder, **kwargs):
    """预处理管线: 格式转换→降噪→Gibbs→头动→Bias→T1分割→MNI配准→Mask"""
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    pre.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# dti: 弥散指标
# ═══════════════════════════════════════════════════════════════

@cli.command('dti')
@workdir_option
@COMMON_OPTIONS
@click.option('--dt/--no-dt', default=True, help='生成弥散张量图 (dwi2tensor)')
@click.option('--fa/--no-fa', default=True, help='FA 分数各向异性')
@click.option('--ad/--no-ad', default=False, help='AD 轴向扩散率')
@click.option('--rd/--no-rd', default=False, help='RD 径向扩散率')
@click.option('--adc/--no-adc', default=False, help='ADC 平均表观扩散系数')
@click.option('--cl/--no-cl', default=False, help='CL 线性度量')
@click.option('--cp/--no-cp', default=False, help='CP 平面度量')
@click.option('--cs/--no-cs', default=False, help='CS 球形度量')
@click.option('--dkt/--no-dkt', default=False, help='生成弥散峰度图')
@click.option('--mk/--no-mk', default=False, help='MK 平均峰度')
@click.option('--ak/--no-ak', default=False, help='AK 轴向峰度')
@click.option('--rk/--no-rk', default=False, help='RK 径向峰度')
@click.pass_context
def cmd_dti(ctx, work_dir, subjects, folder, **kwargs):
    """弥散指标计算: 张量拟合 + 多种指标"""
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    dti.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# fod: 响应函数 + FOD
# ═══════════════════════════════════════════════════════════════

@cli.command('fod')
@workdir_option
@COMMON_OPTIONS
@click.option('--resp/--no-resp', default=True, help='响应函数估计')
@click.option('--resp-algo', type=click.Choice(['dhollander', 'fa', 'msmt_5tt', 'tax', 'tournier']),
              default='dhollander', help='响应函数算法')
@click.option('--fod/--no-fod', default=True, help='FOD 计算')
@click.option('--fod-algo', type=click.Choice(['csd', 'msmt_csd']), default='msmt_csd', help='FOD 算法')
@click.option('--norm/--no-norm', default=True, help='强度标准化 (mtnormalise)')
@click.pass_context
def cmd_fod(ctx, work_dir, subjects, folder, **kwargs):
    """FOD 响应函数 + 纤维方向分布计算"""
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    fod.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# fiber: 纤维追踪
# ═══════════════════════════════════════════════════════════════

@cli.command('fiber')
@workdir_option
@COMMON_OPTIONS
@click.option('--algo', type=click.Choice(['ifod2', 'sd_stream', 'tensor_det', 'tensor_prob', 'fact']),
              default='ifod2', help='纤维追踪算法')
@click.option('--mode', type=click.Choice(['whole_brain', 'seed', 'roi', 'mask']),
              default='whole_brain', help='追踪模式')
@click.option('--step-size', default=0.5, help='步进长度 (mm)')
@click.option('--angle', default=45, help='最大转角 (度)')
@click.option('--min-length', default=2, help='最小纤维长度 (mm)')
@click.option('--max-length', default=100, help='最大纤维长度 (mm)')
@click.option('--fod-cutoff', default=0.1, help='终止 FOD 振幅')
@click.option('--max-tries', default=1000, help='每个种子点最大尝试次数')
@click.option('--fiber-num', default='10m', help='生成纤维数')
@click.option('--seeds', default='10m', help='种子数上限')
@click.option('--sift/--no-sift', default=False, help='SIFT 缩减纤维')
@click.option('--sift-num', default='1m', help='SIFT 后纤维数')
@click.option('--sift2/--no-sift2', default=False, help='SIFT2 纤维权重')
@click.option('--tck2nii/--no-tck2nii', default=False, help='tck → nii 映射')
@click.option('--tck2nii-method', type=click.Choice(['tdi', 'length', 'invlength', 'fod_amp', 'curvature']),
              default='tdi', help='映射方法')
@click.pass_context
def cmd_fiber(ctx, work_dir, subjects, folder, **kwargs):
    """纤维追踪 + SIFT/SIFT2 + tck2nii"""
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    fiber.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# fba: FBA 纤维分析（子命令组）
# ═══════════════════════════════════════════════════════════════

@cli.group()
def fba():
    """FBA 完整管线: 数据整理→个体→模板→配准→Fixel→统计"""


@fba.command('organize')
@click.option('--work-dir', '-w', required=True, help='工作路径')
@click.option('--source', '-S', type=(str, str, str), multiple=True,
              help='源数据: 条件 时间点 路径（可重复）')
@click.option('--sep', default='_', help='分隔符')
@click.option('--copy/--link', default=True, help='复制或软链接')
@click.pass_context
def cmd_fba_organize(ctx, work_dir, source, sep, copy):
    """FBA 步骤0: 数据整理，将多条件/多时间点 DWI 汇总到 fba/subjects/"""
    fba_organize.run(work_dir, list(source), sep, copy, dry=DRY(ctx))


@fba.command('subject')
@click.option('--work-dir', '-w', required=True, help='工作路径')
@click.option('--csd', type=click.Choice(['msmt', 'st']), default='msmt', help='CSD 算法')
@click.option('--voxel', default=1.25, help='上采样体素大小 (mm)')
@click.option('--subjects', '-s', default='', help='逗号分隔被试列表（默认全部）')
@click.option('--no-resp', is_flag=True, help='跳过响应函数')
@click.option('--no-respmean', is_flag=True, help='跳过群体平均')
@click.option('--no-upsample', is_flag=True, help='跳过上采样')
@click.option('--no-csd', is_flag=True, help='跳过 FOD 计算')
@click.option('--no-norm', is_flag=True, help='跳过归一化')
@click.pass_context
def cmd_fba_subject(ctx, work_dir, csd, voxel, subjects, **kwargs):
    """FBA 步骤1: 个体水平处理 (step1-6)"""
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    fba_subject.run(work_dir, csd, voxel, sub_list, dry=DRY(ctx), **kwargs)


@fba.command('template')
@click.option('--work-dir', '-w', required=True, help='工作路径')
@click.option('--voxel', default=1.25, help='模板体素大小 (mm)')
@click.option('--subjects', '-s', default='', help='逗号分隔被试列表（默认全部）')
@click.option('--no-subset', is_flag=True, help='忽略 --subjects，使用全部被试')
@click.pass_context
def cmd_fba_template(ctx, work_dir, voxel, subjects, no_subset):
    """FBA 步骤2: 构建群体模板"""
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects and not no_subset else []
    fba_template.build_template(work_dir, voxel, sub_list, dry=DRY(ctx))


@fba.command('register')
@click.option('--work-dir', '-w', required=True, help='工作路径')
@click.option('--scale', default='0.5,0.75,1.0', help='多级配准尺度')
@click.option('--niter', default='5,5,15', help='每级迭代次数')
@click.option('--subjects', '-s', default='', help='逗号分隔被试列表（默认全部）')
@click.pass_context
def cmd_fba_register(ctx, work_dir, scale, niter, subjects):
    """FBA 步骤2b: 配准到模板 + mask 交集"""
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    fba_template.register(work_dir, scale, niter, sub_list, dry=DRY(ctx))


@fba.command('fixel')
@click.option('--work-dir', '-w', required=True, help='工作路径')
@click.option('--skip-track', is_flag=True, help='跳过模板追踪')
@click.option('--skip-smooth', is_flag=True, help='跳过指标平滑')
@click.pass_context
def cmd_fba_fixel(ctx, work_dir, skip_track, skip_smooth):
    """FBA 步骤3: Fixel 指标计算 + 追踪 + 平滑"""
    fba_fixel.run(work_dir, dry=DRY(ctx), skip_track=skip_track, skip_smooth=skip_smooth)


@fba.command('stats')
@click.option('--work-dir', '-w', required=True, help='工作路径')
@click.option('--design', '-d', required=True, help='设计矩阵文件路径')
@click.option('--contrast', '-c', required=True, help='对比矩阵文件路径')
@click.option('--metrics', default='fd,log_fc,fdc', help='逗号分隔指标')
@click.option('--nshuffles', default=5000, help='排列次数')
@click.option('--cfe-h', default=3.0, help='CFE 高度参数')
@click.option('--cfe-e', default=0.5, help='CFE 延伸参数')
@click.option('--cfe-c', default=0.5, help='CFE 连接参数')
@click.option('--exchange', default='', help='exchangeability 块文件')
@click.option('--suffix', default='', help='输出后缀')
@click.pass_context
def cmd_fba_stats(ctx, work_dir, design, contrast, metrics, **kwargs):
    """FBA 步骤4: CFE 统计分析"""
    metric_list = [m.strip() for m in metrics.split(',')]
    fba_stats.run(work_dir, design, contrast, metric_list, dry=DRY(ctx), **kwargs)


# ═══════════════════════════════════════════════════════════════
# map: 纤维网络矩阵
# ═══════════════════════════════════════════════════════════════

@cli.command('map')
@workdir_option
@COMMON_OPTIONS
@click.option('--mask', '-m', default='', help='mask 文件路径')
@click.option('--assign', type=click.Choice(['voxels', 'radial', 'reverse', 'forward']),
              default='voxels', help='纤维分配标准')
@click.option('--metric', type=click.Choice(['length', 'invlength', 'invnodevol']),
              default='length', help='矩阵分配指标')
@click.option('--symmetric/--no-symmetric', default=True, help='矩阵对称化')
@click.option('--zero-diagonal/--no-zero-diagonal', default=True, help='对角线归零')
@click.option('--search-length', default=0, help='搜索长度')
@click.option('--tck-weight/--no-tck-weight', default=False, help='使用纤维权重文件')
@click.option('--output-txt/--no-output-txt', default=False, help='输出 txt')
@click.option('--extract-regions', default='', help='提取指定脑区编号')
@click.pass_context
def cmd_map(ctx, work_dir, subjects, folder, **kwargs):
    """纤维网络矩阵构建 (tck2connectome)"""
    dry = DRY(ctx)
    sub_list = [s.strip() for s in subjects.split(',') if s.strip()] if subjects else []
    map_module.run(work_dir, folder, sub_list, dry=dry, **kwargs)


# ═══════════════════════════════════════════════════════════════
# stats: 统计分析
# ═══════════════════════════════════════════════════════════════

@cli.group()
def stats():
    """统计分析工具集"""


@stats.command('mrstats')
@click.option('--input', '-i', required=True, help='输入图像（.mif/.nii）')
@click.option('--mask', '-m', default='', help='mask 文件')
@click.option('--output', '-o', default='', help='输出 CSV')
@click.pass_context
def cmd_mrstats(ctx, input, mask, output):
    """弥散指标数值提取"""
    stats_module.run_mrstats(input, mask, output, dry=DRY(ctx))


@stats.command('mrclusterstats')
@click.option('--input', '-i', required=True, help='输入图像')
@click.option('--design', '-d', required=True, help='设计矩阵')
@click.option('--contrast', '-c', required=True, help='对比矩阵')
@click.option('--nshuffles', default=5000, help='排列次数')
@click.option('--output', '-o', default='', help='输出前缀')
@click.pass_context
def cmd_mrclusterstats(ctx, input, design, contrast, nshuffles, output):
    """弥散指标统计分析"""
    stats_module.run_mrclusterstats(input, design, contrast, nshuffles, output, dry=DRY(ctx))


@stats.command('connectomestats')
@click.option('--input', '-i', required=True, help='连接矩阵列表')
@click.option('--design', '-d', required=True, help='设计矩阵')
@click.option('--contrast', '-c', required=True, help='对比矩阵')
@click.option('--nshuffles', default=5000, help='排列次数')
@click.pass_context
def cmd_connectomestats(ctx, input, design, contrast, nshuffles):
    """连接网络统计分析"""
    stats_module.run_connectomestats(input, design, contrast, nshuffles, dry=DRY(ctx))


@stats.command('tckstats')
@click.option('--input', '-i', required=True, help='纤维文件 (.tck)')
@click.option('--output', '-o', default='', help='输出 CSV')
@click.option('--dump', default='', help='输出逐条纤维值的文件')
@click.pass_context
def cmd_tckstats(ctx, input, output, dump):
    """纤维指标数值提取"""
    stats_module.run_tckstats(input, output, dump, dry=DRY(ctx))


# ═══════════════════════════════════════════════════════════════
# update: 检查更新 / 拉取最新代码
# ═══════════════════════════════════════════════════════════════

@cli.command('update')
@click.option('--check', is_flag=True, help='仅检查更新，不拉取')
@click.option('--pull', is_flag=True, help='检查并拉取最新代码')
def cmd_update(check, pull):
    """检查项目更新或拉取最新代码

    对比本地 commit 与 Gitee/GitHub 远程最新 commit，
    可选择直接 git pull 更新。
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
