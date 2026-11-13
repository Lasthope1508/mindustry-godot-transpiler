"""Validate generated JSON and static tests neighboring the five proof fixtures."""
import io
import json
from pathlib import Path
import sys
import unittest

root = Path(sys.argv[1]).resolve()
out = Path(__file__).resolve().parent
sys.path.insert(0, str(root / 'tools/mindustry_godot_transpiler'))
modules = [
    'test_c07_factory_power_status', 'test_factory_consumer_binding',
    'test_factory_craft', 'test_factory_dump_outputs',
    'test_factory_liquid_output', 'test_factory_should_consume',
    'test_unit_factory_consumer_binding', 'test_unit_factory_should_consume',
]
runtime_ids = {row['test'] for row in json.loads((out / 'manifest.json').read_text())}

def flatten(suite):
    for test in suite:
        if isinstance(test, unittest.TestSuite):
            yield from flatten(test)
        else:
            yield test

suite = unittest.TestSuite()
for module in modules:
    suite.addTests(test for test in flatten(unittest.defaultTestLoader.loadTestsFromName('tests.' + module)) if test.id() not in runtime_ids)
stream = io.StringIO()
result = unittest.TextTestRunner(stream=stream, verbosity=2).run(suite)
(out / 'static-tests.log').write_text(stream.getvalue(), encoding='utf-8')
paths = sorted((root / 'godot-mindustry/src/generated').rglob('*.json'))
for path in paths:
    json.loads(path.read_text(encoding='utf-8'))
summary = dict(tests=result.testsRun, failures=len(result.failures), errors=len(result.errors), skipped=len(result.skipped), generated_json_parsed=len(paths), passed=result.wasSuccessful())
(out / 'static-results.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
print(json.dumps(summary))
sys.exit(0 if result.wasSuccessful() else 1)
