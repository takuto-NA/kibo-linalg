"""Fetch only pinned, checksum-verified test/build dependencies."""
import argparse
import hashlib
import json
import shutil
import tarfile
import urllib.request
import zipfile
from pathlib import Path

root=Path(__file__).resolve().parent.parent
lock=json.loads((root/'tools/toolchains.lock.json').read_text(encoding='utf-8'))
parser=argparse.ArgumentParser()
parser.add_argument('--platform',choices=['linux','windows'],default='linux')
parser.add_argument('--llvm',action='store_true')
parser.add_argument('--eigen',action='store_true')
parser.add_argument('--msvc',action='store_true')
args=parser.parse_args()
cache=root/'.cache'
downloads=cache/'downloads'; downloads.mkdir(parents=True,exist_ok=True)

def sha256(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream,'sha256').hexdigest()

def fetch(name,url,checksum):
    path=downloads/name
    if not path.exists() or sha256(path)!=checksum:
        partial=path.with_suffix(path.suffix+'.partial')
        print('fetch',url,flush=True)
        with urllib.request.urlopen(url) as response,partial.open('wb') as output:
            shutil.copyfileobj(response,output)
        if sha256(partial)!=checksum:
            raise RuntimeError('checksum mismatch: '+name)
        partial.replace(path)
    print('verified',name,checksum,flush=True)
    return path

cmake=lock['cmake']
cmake_name='cmake-3.30.5-windows-x86_64.zip' if args.platform=='windows' else 'cmake-3.30.5-linux-x86_64.tar.gz'
archive=fetch(cmake_name,cmake[args.platform+'_url'],cmake[args.platform+'_sha256'])
if args.platform=='windows':
    destination=cache/'tools'; destination.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(archive) as contents:
        for entry in contents.infolist():
            if not (destination/entry.filename).resolve().is_relative_to(destination.resolve()):
                raise RuntimeError('unsafe archive member')
        contents.extractall(destination)
if args.llvm:
    fetch('LLVM-20.1.8-Linux-X64.tar.xz',lock['llvm']['url'],lock['llvm']['sha256'])
if args.eigen:
    archive=fetch('eigen-5.0.1.tar.gz',lock['eigen']['url'],lock['eigen']['sha256'])
    destination=cache/'eigen'; destination.mkdir(parents=True,exist_ok=True)
    with tarfile.open(archive) as contents:
        for entry in contents.getmembers():
            parts=Path(entry.name).parts[1:]
            if not parts: continue
            entry.name=str(Path(*parts))
            contents.extract(entry,destination,filter='data')
if args.msvc:
    fetch('vs_BuildTools-17.14.25.exe',lock['msvc']['url'],lock['msvc']['sha256'])
