"""Assemble the validation report without hiding the initial failures."""
import json
from pathlib import Path
import sys

root = Path(sys.argv[1]).resolve()
out = Path(__file__).resolve().parent
read = lambda path: json.loads(path.read_text(encoding='utf-8'))
baseline = read(out / 'results.json')
final_dir = out / 'rerun-080853'
final = read(final_dir / 'results.json')
assert len(baseline) == 101 and len(final) == 8 and all(row['passed'] for row in final)
latest = {row['test']: row for row in baseline}
latest.update({row['test']: row for row in final})
assert all(row['passed'] for row in latest.values())
defense_dirs = []
for directory in sorted(out.glob('rerun-*')):
    if not (directory / 'results.json').exists():
        continue
    rows = read(directory / 'results.json')
    if len(rows) == 1 and 'test_c06_defense_leg' in rows[0]['test']:
        assert rows[0]['passed']
        defense_dirs.append(directory.name)
assert len(defense_dirs) == 2
for name in ['factory', 'unit']:
    data = read(out / ('native-' + name + '.json'))
    status = json.loads(data['status']['content'][0]['text'])
    debug = json.loads(data['debug']['content'][0]['text'])
    assert status['connected'] and not any('ERROR:' in line or 'SCRIPT ERROR' in line for line in debug['errors'])
    assert any('"matches":true' in line for line in debug['output'])
visible = (out / 'visible-factory.log').read_text(encoding='utf-8')
assert 'NVIDIA' in visible and '"matches":true' in visible and 'ERROR:' not in visible
summary = dict(baseline=read(out / 'summary.json'), final_targeted=read(final_dir / 'summary.json'), cumulative_distinct_passed=len(latest), static=read(out / 'static-results.json'), defense_passes_including_baseline=3, final_directory=final_dir.name, defense_directories=defense_dirs, mcp_proofs=2, visible_proofs=1, full_suite_rerun=False)
(out / 'final-summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
link = 'evidence/2026-11-13-windows-godot/'
lines = [
    '# Windows Godot validation and proof fixture repair — 2026-11-13', '',
    '**Result: the selected Godot-dependent coverage is GREEN after five proof fixture repairs. The immutable baseline was NOT GREEN (96 passed, 5 failed).**', '',
    '## Revision, environment and scope', '',
    '- Base: `Lasthope1508/mindustry-godot-transpiler` main `b969e046d0d56c22da4f7e59e8736f621a7e522e` (N2145). Remote main was checked again before publication.',
    '- Windows, Godot `4.6.2.stable.official.71f334935`, Python 3.13.3, `javalang==0.13.0`.',
    '- Upstream dependencies use README pins: Mindustry `2bdedfed25932ebf11330d3584092c50e2e26d96`, Arc `f30acd23ece4b626b755660d56c1b0d4aaf46aed`.',
    '- Prior Linux gate: 5,677 tests, 96 failures attributed to unavailable Godot, 5 skips, 0 errors. This validation selected all 101 Godot-dependent methods, including helper-mediated WorldTileLifecycle calls. See the exact manifest.',
    '- The initial 101 tests ran sequentially against unchanged base source. TCP 7777 was checked before each run; no competing game instances were used.', '',
    '## Results', '',
    '| Check | Result |', '|---|---|',
    '| Immutable baseline, 101 existing methods | 96 PASS, 5 FAIL, 0 errors, 0 skips |',
    '| Final targeted proof run, including all five failures and three neighbors | 8/8 PASS |',
    '| Distinct methods with passing evidence across baseline and final rerun | 101/101; cumulative coverage, not a new complete 101-test run |',
    '| Static tests from the eight relevant modules | 24/24 PASS |',
    '| Generated JSON syntax parsing | 113/113 files valid; not a schema/full gate claim |',
    '| Godot MCP debug sessions | FactoryConsumerBinding and UnitFactoryConsumerBinding: matches=true, ping connected, no ERROR/SCRIPT ERROR |',
    '| Graphical Godot, no --headless | FactoryConsumerBinding: exit 0, NVIDIA OpenGL renderer, matches=true, no ERROR |',
    '| Defense stability, seeded upstream proof | 3/3 PASS: baseline plus two repeats |', '',
    'The MCP launcher uses `--headless -d` on this host. The separate graphical launch is recorded in visible-factory.log. MCP debug logs include 99 existing GDScript warnings per session (shadowing, ternary types, unused parameters, integer division); these are retained, not described as an empty warning stream. Both MCP projects were stopped after checking output. The graphical process exited normally.', '',
    '## Initial failures and minimal repairs', '',
    '| Proof | Failure on base | Fixture repair |', '|---|---|---|',
    '| FactoryConsumerBinding | Powered efficiency/water consumption assertions fail; no producer | Add a thorium reactor and start the background battery full |',
    '| C06FactoryCraft | Live silicon input/output counts fail | Add a thorium reactor |',
    '| C06FactoryDumpOutputs | Live mixer water/progress/efficiency fail | Add a thorium reactor |',
    '| C06FactoryLiquidOutput | Live mixer/electrolyzer output/consumption fail | Add a thorium reactor |',
    '| UnitFactoryConsumerBinding | Assembler cyanogen consumption/efficiency fail | Supply tier-zero payloads (stell 4, tungsten-wall-large 10) and unitCap 10 |', '',
    '- N2145 correctly folds live power.status into crafter efficiency (`ConsumePower.java:39`). The four older scenes assumed a powered graph. This follows the producer setup already used by upstream FactoryShouldConsumeProof; the current producer model supplies catalog powerProduction and does not simulate reactor fuel/coolant.',
    '- A producer alone fixes most assertions, but FactoryConsumerBinding restoration still reads efficiency 0.9454545: the bootstrap battery absorbs surplus before PowerGraph estimates power for an idle consumer (`PowerGraph.java:205-206`). A second producer alone did not fix it. Starting the fixture battery full isolates the existing full-efficiency restoration assertion without bypassing the graph.',
    '- Assembler shouldConsume requires payload stacks (`UnitAssembler.java:389-391`, plan `Blocks.java:6526`) and Units.canCreate (`Units.java:115-117`). Payloads alone remain blocked by the bootstrap zero unitCap default. Both are now explicit fixture inputs.',
    '- No gameplay implementation, SSOT, assertion, timeout, skip condition or RNG seed was changed. These are proof setup repairs, not new migration slices. Temporary diagnostics were removed before the final run. Intermediate diagnostic runs remain local; committed RED evidence is the unchanged baseline, and committed GREEN evidence is the final eight-proof run.', '',
    '## Earlier C06 queue', '',
    '- C06DefenseProof: PASS, including two extra repeats; the upstream seed(12345) fix was already in the tested base.',
    '- DrillProximityLifecycleProof and FactoryDumpSwapProof: PASS in the baseline, without ERROR lines.',
    '- Other Godot-dependent methods in the manifest were exercised; this does not declare unfinished C07-C12 gameplay complete.', '',
    '## Evidence and reproduction', '',
    f'- [Final summary]({link}final-summary.json), [baseline]({link}results.json), [manifest]({link}manifest.json), [environment]({link}environment.json), [final 8-proof results]({link}{final_dir.name}/results.json).',
    f'- [Static tests]({link}static-tests.log), [static/JSON summary]({link}static-results.json), [MCP factory]({link}native-factory.json), [MCP assembler]({link}native-unit.json), [graphical run]({link}visible-factory.log).',
    f'- Defense repeats: ' + ', '.join(f'[{name}]({link}{name}/results.json)' for name in defense_dirs) + '.',
    '- Run `python run_validation.py --root ABSOLUTE_REPO_ROOT` with its manifest alongside it. Optional `--only EXACT_TEST_ID ...` creates a separate evidence directory. The recorder forwards existing subprocess arguments/results unchanged and saves logs and fresh proof JSON.',
    '- Run `python run_static_checks.py ABSOLUTE_REPO_ROOT` for the 24 neighboring static tests and generated JSON syntax parsing.',
    '- Evidence logs normalize terminal empty lines for git diff --check; diagnostic messages and test results are retained.',
    '- Baseline environment.json records the base SHA. Final rerun environment.json also records that HEAD because the five fixture edits were still uncommitted; the final fixture content is the content in this validation commit.',
    '- Source-adjacent ignored proof JSON, Godot import/UID churn, project.godot and dependency junctions are excluded from the commit. Only copied evidence snapshots under this report are versioned.', '',
    '## Baseline method results', '',
    '| # | Existing unittest method | Baseline | Final targeted |', '|---:|---|---|---|',
]
final_ids = {r['test'] for r in final}
for row in baseline:
    lines.append(f"| {row['number']} | `{row['test']}` | [{'PASS' if row['passed'] else 'FAIL'}]({link}{row['log']}) | {'PASS' if row['test'] in final_ids else 'Not rerun'} |")
lines += ['', '## Limits', '',
    '- The complete 5,677-test Python gate was not rerun. The unchanged baseline passes plus affected/neighbor reruns provide cumulative coverage; do not advertise this as a full-suite green result.',
    '- No production code changed, so SSOT/checklist slice totals are unchanged. Passing proofs validate their assertions, not full gameplay or release readiness.',
    '- Publication is a branch/PR for review; main is not merged by this task.', '']
(root / 'docs/superpowers/reports/2026-11-13-windows-godot-validation.md').write_text('\n'.join(lines), encoding='utf-8')
print(json.dumps(summary))
