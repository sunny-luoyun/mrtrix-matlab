"""通用工具函数

run_cmd:     执行系统命令并实时输出
find_subjects: 扫描被试目录
find_dwi_files: 探测 DWI 文件
Timer:       计时器上下文管理器
save_params / load_params: 参数读写（兼容 MATLAB .mat 格式）
"""

import os
import subprocess
import sys
import time
import json


def run_cmd(cmd, dry_run=False, log_file=None, cwd=None):
    """执行命令，实时输出 stdout/stderr

    Args:
        cmd: 命令字符串或列表
        dry_run: 如果为 True，仅打印不执行
        log_file: 可选日志文件路径
        cwd: 工作目录

    Returns:
        (returncode, stdout_text, stderr_text)
    """
    cmd_str = cmd if isinstance(cmd, str) else ' '.join(cmd)

    if dry_run:
        print(f"[DRY-RUN] {cmd_str}")
        return 0, '', ''

    print(f"[RUN] {cmd_str}")
    if cwd:
        print(f"  (in {cwd})")

    try:
        p = subprocess.Popen(
            cmd if isinstance(cmd, list) else cmd,
            shell=isinstance(cmd, str),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            bufsize=1,
            text=True,
            cwd=cwd,
        )
    except FileNotFoundError as e:
        print(f"[ERROR] 命令未找到: {e}")
        return -1, '', str(e)

    stdout_lines = []
    log_fp = None
    if log_file:
        log_fp = open(log_file, 'a')

    try:
        for line in p.stdout:
            print(line, end='', flush=True)
            stdout_lines.append(line)
            if log_fp:
                log_fp.write(line)
    except KeyboardInterrupt:
        p.terminate()
        print("\n[INFO] 用户中断")
    finally:
        if log_fp:
            log_fp.close()

    p.wait()
    stdout_text = ''.join(stdout_lines)
    return p.returncode, stdout_text, ''


def run_cmd_simple(cmd, dry_run=False):
    """执行命令并以字符串形式返回 stdout（无实时输出）"""
    cmd_str = cmd if isinstance(cmd, str) else ' '.join(cmd)
    if dry_run:
        print(f"[DRY-RUN] {cmd_str}")
        return 0, '', ''
    try:
        r = subprocess.run(
            cmd if isinstance(cmd, list) else cmd,
            shell=isinstance(cmd, str),
            capture_output=True, text=True, timeout=600,
        )
        return r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        return -1, '', 'Timeout'
    except FileNotFoundError as e:
        return -1, '', str(e)


def find_subjects(base_dir, prefix='Sub'):
    """扫描以 prefix 开头的被试目录，返回名称列表"""
    if not os.path.isdir(base_dir):
        return []
    names = []
    if os.path.isdir(base_dir):
        for entry in sorted(os.listdir(base_dir)):
            entry_path = os.path.join(base_dir, entry)
            if os.path.isdir(entry_path) and entry.startswith(prefix):
                names.append(entry)
    return names


def find_subject_dirs(work_dir, sub_path='fba/subjects', prefix='Sub'):
    """在 work_dir/fba/subjects 下查找被试目录"""
    subjects_dir = os.path.join(work_dir, sub_path)
    return find_subjects(subjects_dir, prefix)


def find_dwi_files(subject_dir):
    """查找 DWI 文件，优先级：dwi_upsampled.mif > dwi.mif"""
    candidates = [
        os.path.join(subject_dir, 'dwi_upsampled.mif'),
        os.path.join(subject_dir, 'dwi.mif'),
    ]
    for f in candidates:
        if os.path.isfile(f):
            return f
    return None


def find_mask_file(subject_dir):
    """查找 mask 文件"""
    candidates = [
        os.path.join(subject_dir, 'dwi_mask_upsampled.mif'),
        os.path.join(subject_dir, 'dwi_mask.mif'),
    ]
    for f in candidates:
        if os.path.isfile(f):
            return f
    return None


def require_file(path, description=''):
    """确保文件存在，否则报错退出"""
    if not path or not os.path.isfile(path):
        if description:
            print(f"[ERROR] 缺少文件: {description}")
        else:
            print(f"[ERROR] 文件不存在: {path}")
        sys.exit(1)
    return path


def require_dir(path, description=''):
    if not path or not os.path.isdir(path):
        if description:
            print(f"[ERROR] 目录不存在: {description}")
        else:
            print(f"[ERROR] 目录不存在: {path}")
        sys.exit(1)
    return path


def _find_project_root():
    """从当前文件位置向上搜索，找到包含 setup.py 的目录"""
    import inspect
    path = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
    for _ in range(10):
        if os.path.isfile(os.path.join(path, 'setup.py')):
            return path
        parent = os.path.dirname(path)
        if parent == path:
            break
        path = parent
    return None


def mkdir_p(path, dry=False):
    if dry:
        print(f"[DRY-RUN] mkdir -p {path}")
    else:
        os.makedirs(path, exist_ok=True)
    return path


def save_params_json(module, func, work_path, params):
    """保存参数为 JSON（兼容 MATLAB 不直接，但可读）"""
    out_dir = os.path.join(work_path, 'params')
    mkdir_p(out_dir)
    ts = time.strftime('%Y%m%d_%H%M%S')
    filename = f'{module}_{func}_{ts}.json'
    filepath = os.path.join(out_dir, filename)
    with open(filepath, 'w') as f:
        json.dump({'params': params, 'module': module, 'func': func}, f, indent=2)
    print(f"[INFO] 参数已保存: {filepath}")
    return filepath


def load_params_json(filepath):
    """读取 JSON 参数文件"""
    if not os.path.isfile(filepath):
        filepath = os.path.join('.', 'params', filepath)
    if not os.path.isfile(filepath):
        print(f"[ERROR] 参数文件不存在: {filepath}")
        return None
    with open(filepath) as f:
        return json.load(f)


class Timer:
    def __init__(self, label=''):
        self.label = label
        self.start = None

    def __enter__(self):
        self.start = time.time()
        return self

    def __exit__(self, *args):
        elapsed = time.time() - self.start
        hours = int(elapsed // 3600)
        minutes = int((elapsed % 3600) // 60)
        seconds = elapsed % 60
        tag = f' [{self.label}]' if self.label else ''
        print(f"\n[完成{tag}] 耗时: {hours}小时 {minutes}分钟 {seconds:.0f}秒")
