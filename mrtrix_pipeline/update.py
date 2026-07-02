"""检查更新与自动拉取

与 MATLAB mrtrix.m 中的 checkForUpdate / doUpdate 逻辑一致。
"""

import os
import subprocess
import json
import time
from urllib.request import urlopen, Request
from urllib.error import URLError


def _find_project_root():
    """从当前文件位置向上搜索，找到包含 setup.py 的目录"""
    path = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.isfile(os.path.join(path, 'setup.py')):
            return path
        parent = os.path.dirname(path)
        if parent == path:
            break
        path = parent
    return None


def _git_cmd(args):
    """执行 git 命令，返回 (ok, output)"""
    root = _find_project_root()
    if not root:
        return False, "未找到项目根目录（setup.py）"
    try:
        r = subprocess.run(
            ['git', '-C', root] + args,
            capture_output=True, text=True, timeout=30,
        )
        if r.returncode == 0:
            return True, r.stdout.strip()
        return False, r.stderr.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        return False, str(e)


def get_local_version():
    """获取本地 commit SHA"""
    ok, out = _git_cmd(['rev-parse', 'HEAD'])
    if ok:
        return out
    ok2, out2 = _git_cmd(['rev-parse', '--short', 'HEAD'])
    if ok2:
        return out2
    ver_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'version.txt')
    if os.path.isfile(ver_file):
        with open(ver_file) as f:
            return f.read().strip()
    return None


def get_remote_version(timeout=5):
    """从 Gitee API 获取远程最新 commit SHA，失败时尝试 GitHub"""
    gitee_url = 'https://gitee.com/api/v5/repos/luoyun-weixi/mrtrix-matlab/commits/main'
    github_url = 'https://api.github.com/repos/sunny-luoyun/mrtrix-matlab/commits/main'

    for url in [gitee_url, github_url]:
        try:
            req = Request(url, headers={'User-Agent': 'mrtrix-cli'})
            with urlopen(req, timeout=timeout) as resp:
                data = json.loads(resp.read().decode())
                sha = data.get('sha', '')
                if sha:
                    return sha, 'gitee' if 'gitee' in url else 'github'
        except (URLError, json.JSONDecodeError, OSError):
            continue
    return None, None


def check_update():
    """检查更新，返回 (local_sha, remote_sha, source, has_update)"""
    local = get_local_version()
    remote, source = get_remote_version()
    if not local or not remote:
        return local, remote, source, False
    return local, remote, source, local[:7] != remote[:7]


def do_pull():
    """执行 git fetch + git reset --hard FETCH_HEAD"""
    root = _find_project_root()
    if not root:
        return False, "未找到项目根目录"

    update_url = 'https://gitee.com/luoyun-weixi/mrtrix-matlab.git'

    ok1, out1 = _git_cmd(['fetch', '--depth', '1', update_url, 'main'])
    if not ok1:
        ok1_gh, out1_gh = _git_cmd(['fetch', '--depth', '1', 'origin', 'main'])
        if not ok1_gh:
            return False, f"git fetch 失败: {out1}"

    ok2, out2 = _git_cmd(['reset', '--hard', 'FETCH_HEAD'])
    if not ok2:
        return False, f"git reset 失败: {out2}"

    return True, root
