"""Run unchanged slice tests and graphical proofs, sequentially on Windows."""
import argparse
import datetime
import io
import json
from pathlib import Path
import os
import shutil
import socket
import subprocess
import sys
import time
import unittest

parser = argparse.ArgumentParser()
parser.add_argument('--root', required=True)
parser.add_argument('--phase', choices=['tests', 'visible'], required=True)
args = parser.parse_args()
root = Path(args.root).resolve()
out = Path(__file__).resolve().parent
engine = shutil.which('Godot_v4.6.2-stable_win64_console.exe')
assert engine
original_run = subprocess.run
mapping = [
    (2146, 'adjacent_factory', 'C07AdjacentFactoryPowerStatusProof'),
    (2147, 'drill', 'C07DrillPowerStatusProof'),
    (2148, 'turret', 'C07TurretPowerStatusProof'),
    (2149, 'burst_drill', 'C07BurstDrillPowerStatusProof'),
    (2150, 'solid_pump', 'C07SolidPumpPowerStatusProof'),
    (2151, 'point_defense_turret', 'C07PointDefenseTurretPowerStatusProof'),
    (2152, 'tractor_beam_turret', 'C07TractorBeamTurretPowerStatusProof'),
    (2153, 'fracker', 'C07FrackerPowerStatusProof'),
    (2154, 'mechanical_pump', 'C07MechanicalPumpPowerStatusProof'),
    (2155, 'beam_drill', 'C07BeamDrillPowerStatusProof'),
]

def save(name, value):
    (out / name).write_text(json.dumps(value, indent=2), encoding='utf-8')

def free_port():
    with socket.socket() as connection:
        connection.settimeout(1)
        assert connection.connect_ex(('127.0.0.1', 7777)) != 0, 'Port 7777 occupied; no competing proof will be started'

environment = dict(commit=original_run(['git','rev-parse','HEAD'], cwd=root, capture_output=True, text=True, check=True).stdout.strip(), engine=engine, version=original_run([engine,'--version'], capture_output=True,text=True,check=True).stdout.strip(), python=sys.version, started=datetime.datetime.now().astimezone().isoformat(), phase=args.phase)
save(args.phase + '-environment.json', environment)
results = []
current = None

def record_run(*positional, **kwargs):
    command = positional[0] if positional else kwargs['args']
    if not isinstance(command, (list, tuple)) or 'godot' not in str(command[0]).lower():
        return original_run(*positional, **kwargs)
    free_port()
    started = time.time()
    result = original_run(*positional, **kwargs)
    output = (result.stdout or '') + '\n' + (result.stderr or '')
    stem = args.phase + '-' + current['label']
    (out / (stem + '.log')).write_text(output.rstrip('\r\n') + '\n', encoding='utf-8')
    proofs = []
    for line in output.splitlines():
        if '_PROOF ' in line:
            prefix, data = line.split(' ', 1)
            try:
                proof = json.loads(data)
            except ValueError:
                continue
            proofs.append(dict(prefix=prefix, data=proof))
    current['engine_runs'].append(dict(command=[str(x) for x in command], exit_code=result.returncode, seconds=round(time.time()-started,3), log=stem+'.log', errors=[line for line in output.splitlines() if 'ERROR:' in line or 'SCRIPT ERROR' in line], proofs=proofs))
    save(stem + '-proofs.json', proofs)
    return result

subprocess.run = record_run
if args.phase == 'tests':
    os.chdir(root / 'tools/mindustry_godot_transpiler')
    sys.path.insert(0, str(Path.cwd()))
    modules = [(str(n), 'tests.test_c07_' + name + '_power_status') for n,name,_ in mapping]
    modules += [('adjacent-consumer-neighbor', 'tests.test_adjacent_factory_consumer_binding'), ('adjacent-loop-neighbor','tests.test_adjacent_factory_live_loop')]
    for label,module in modules:
        current = dict(label=label, module=module, engine_runs=[])
        print('START ' + label + ' ' + module, flush=True)
        started = time.time()
        stream = io.StringIO()
        result = unittest.TextTestRunner(stream=stream, verbosity=2).run(unittest.defaultTestLoader.loadTestsFromName(module))
        (out / ('tests-' + label + '-unittest.log')).write_text(stream.getvalue().rstrip()+'\n', encoding='utf-8')
        current.update(tests=result.testsRun, failures=len(result.failures), errors=len(result.errors), skips=len(result.skipped), passed=result.wasSuccessful() and not result.skipped, seconds=round(time.time()-started,3))
        results.append(current)
        save('tests-results.json', results)
        print('RESULT ' + label + ' ' + json.dumps({key:current[key] for key in ['tests','passed','failures','errors','skips','seconds']}), flush=True)
else:
    for number,_,scene in mapping:
        current = dict(label=str(number), scene=scene, engine_runs=[])
        print('START VISIBLE N' + str(number) + ' ' + scene, flush=True)
        run = record_run([engine,'--path',str(root/'godot-mindustry'),'--scene','res://tools/runtime_proofs/'+scene+'.tscn','--quit-after','300'], capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180)
        recorded = current['engine_runs'][0]
        current['passed'] = recorded['exit_code']==0 and not recorded['errors'] and len(recorded['proofs'])==1 and recorded['proofs'][0]['data'].get('matches') is True
        results.append(current)
        save('visible-results.json', results)
        print('RESULT VISIBLE N' + str(number) + ' ' + str(current['passed']), flush=True)
free_port()
print('FINAL ' + args.phase + ' ' + json.dumps(dict(groups=len(results), passed=sum(row['passed'] for row in results))), flush=True)
sys.exit(0 if all(row['passed'] for row in results) else 1)
