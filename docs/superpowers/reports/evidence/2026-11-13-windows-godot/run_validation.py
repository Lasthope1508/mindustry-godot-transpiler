"""Run the recorded Godot-dependent unittest methods unchanged, sequentially.

Usage: python run_validation.py --root ABSOLUTE_REPOSITORY_ROOT
The subprocess wrapper records calls/results; it does not change arguments,
timeouts, environment, stdout, stderr, or assertions in the repository tests.
"""
import argparse
import datetime
import io
import json
import os
from pathlib import Path
import shutil
import socket
import subprocess
import sys
import time
import unittest

parser = argparse.ArgumentParser()
parser.add_argument('--root', required=True)
parser.add_argument('--only', nargs='*', help='Optional exact test IDs to rerun')
args = parser.parse_args()
root = Path(args.root).resolve()
out = Path(__file__).resolve().parent
manifest = json.loads((out / 'manifest.json').read_text(encoding='utf-8'))
if args.only:
    manifest = [row for row in manifest if row['test'] in args.only]
    out = out / ('rerun-' + datetime.datetime.now().strftime('%H%M%S'))
    out.mkdir()
os.chdir(root / 'tools/mindustry_godot_transpiler')
sys.path.insert(0, str(Path.cwd()))
engine = shutil.which('Godot_v4.6.2-stable_win64_console.exe')
if not engine:
    raise RuntimeError('Godot 4.6.2 Windows console executable is missing')
original_run = subprocess.run
meta = dict(
    commit=original_run(['git', 'rev-parse', 'HEAD'], cwd=root, capture_output=True, text=True, check=True).stdout.strip(),
    engine=engine,
    version=original_run([engine, '--version'], capture_output=True, text=True, check=True).stdout.strip(),
    python=sys.version,
    started=datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=7))).isoformat(),
    count=len(manifest),
)
(out / 'environment.json').write_text(json.dumps(meta, indent=2), encoding='utf-8')
results = []
current = None

def record_run(*positional, **kwargs):
    command = positional[0] if positional else kwargs['args']
    tracked = isinstance(command, (list, tuple)) and ('godot' in str(command[0]).lower())
    if not tracked:
        return original_run(*positional, **kwargs)
    number = len(current['engine_runs']) + 1
    stem = f"engine-{current['number']:03d}-{number:02d}"
    record = dict(command=[str(part) for part in command], timeout=kwargs.get('timeout'))
    started = time.time()
    try:
        completed = original_run(*positional, **kwargs)
        stdout = completed.stdout or ''
        stderr = completed.stderr or ''
        if isinstance(stdout, bytes):
            stdout = stdout.decode('utf-8', 'replace')
        if isinstance(stderr, bytes):
            stderr = stderr.decode('utf-8', 'replace')
        (out / (stem + '.log')).write_text((stdout + '\n' + stderr).rstrip('\r\n') + '\n', encoding='utf-8')
        record.update(exit_code=completed.returncode, log=stem + '.log', error_lines=[line for line in (stdout + '\n' + stderr).splitlines() if 'ERROR:' in line or 'SCRIPT ERROR' in line])
        for path in sorted((root / 'godot-mindustry/tools/runtime_proofs').glob('*.json')):
            if path.stat().st_mtime >= started - 0.01:
                target = stem + '-proof.json'
                # A scene normally writes one JSON. Preserve every JSON if it writes more.
                if 'proofs' in record:
                    target = stem + f"-proof-{len(record['proofs']) + 1}.json"
                shutil.copy2(path, out / target)
                record.setdefault('proofs', []).append(dict(source=path.name, file=target, data=json.loads(path.read_text(encoding='utf-8'))))
        return completed
    except subprocess.TimeoutExpired as error:
        record['timed_out'] = True
        (out / (stem + '.log')).write_text(str(error) + '\n' + str(error.stdout or '') + '\n' + str(error.stderr or ''), encoding='utf-8')
        record['log'] = stem + '.log'
        raise
    finally:
        record['seconds'] = round(time.time() - started, 3)
        current['engine_runs'].append(record)

subprocess.run = record_run
for index, row in enumerate(manifest, 1):
    with socket.socket() as connection:
        connection.settimeout(1)
        if connection.connect_ex(('127.0.0.1', 7777)) == 0:
            raise RuntimeError('Port 7777 occupied before ' + row['test'])
    current = dict(number=index, test=row['test'], category='optional-without-godot' if row['optional_skip'] else 'required', engine_runs=[])
    started = time.time()
    print(f"START {index}/{len(manifest)} {row['test']}", flush=True)
    suite = unittest.defaultTestLoader.loadTestsFromName(row['test'])
    stream = io.StringIO()
    result = unittest.TextTestRunner(stream=stream, verbosity=2).run(suite)
    log = f'test-{index:03d}.log'
    (out / log).write_text(stream.getvalue(), encoding='utf-8')
    current.update(tests_run=result.testsRun, passed=result.wasSuccessful() and not result.skipped, failures=len(result.failures), errors=len(result.errors), skipped=len(result.skipped), log=log, seconds=round(time.time() - started, 3))
    results.append(current)
    (out / 'results.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
    print(f"RESULT {index}/{len(manifest)} {'PASS' if current['passed'] else 'FAIL'} {current['seconds']}s {row['test']}", flush=True)
summary = dict(tests=len(results), passed=sum(r['passed'] for r in results), failures=sum(r['failures'] for r in results), errors=sum(r['errors'] for r in results), skipped=sum(r['skipped'] for r in results), engine_runs=sum(len(r['engine_runs']) for r in results))
(out / 'summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
print('FINAL ' + json.dumps(summary), flush=True)
sys.exit(0 if all(r['passed'] for r in results) else 1)
