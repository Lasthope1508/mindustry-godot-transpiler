import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_WARMUP_STATS_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretWarmupStatsRowsProof.gd'
BUILD_TURRET_WARMUP_STATS_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretWarmupStatsRowsProof.tscn'


class C07BuildTurretWarmupStatsRowsTests(unittest.TestCase):
    def test_c07_build_turret_warmup_stats_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2451']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_warmup_state')
        # The build tower's warmup is a live frame key
        # (N2243 ticks the lerp -- `warmup =
        # Mathf.lerpDelta(warmup,
        # unit.activelyBuilding() ? efficiency :
        # 0f, 0.1f);`, BuildTurret.java:139) but
        # NOTHING modeled the warmup() accessor
        # (`public float warmup(){` / `return
        # warmup;`, BuildTurret.java:254-255, the
        # override of the BuildingComp default
        # `return 0f;`, BuildingComp.java:608-610)
        # or the setStats row (`stats.addPercent(
        # Stat.buildSpeed, buildSpeed);`,
        # BuildTurret.java:84). N2451 ports them
        # as TWO pure-only pures (the N2442
        # precedent): the warmup accessor takes
        # the caller-supplied warmup and returns
        # it verbatim, and the stats pure takes
        # the caller-supplied buildSpeed and
        # returns the exact Stat token + the RAW
        # buildSpeed -- percent formatting is a
        # UI concern (the N2422 precedent):
        # addPercent multiplies by 100 only at
        # display time (`add(stat, StatValues.
        # number((int)(value * 100),
        # StatUnit.percent));`, Stats.java:38).
        # Three new result symbols: the warmup
        # value + the stat key + the stat value.
        self.assertEqual(
            ledger['N2451']['source_symbols'],
            [
                'source_build_turret_warmup_state_result.warmup_value',
                'source_build_turret_stats_state_result.stat_key',
                'source_build_turret_stats_state_result.stat_value',
            ],
        )
        expected_sources = {
            'source_build_turret_warmup_state_result.warmup_value': 'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'source_build_turret_stats_state_result.stat_key': 'core/src/mindustry/world/meta/Stat.java',
            'source_build_turret_stats_state_result.stat_value': 'core/src/mindustry/world/blocks/defense/BuildTurret.java',
        }
        for name in ledger['N2451']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_'))
        self.assertEqual(ledger['N2451']['runtime_proof'], '/root/C07BuildTurretWarmupStatsRowsProof')
        self.assertEqual(
            ledger['N2451']['tests'],
            [
                'test_c07_build_turret_warmup_stats_rows_registration',
                'test_all_c07_build_turret_warmup_stats_rows_input_evidence_is_exact',
                'test_build_turret_warmup_stats_rows_state',
                'test_reference_graph_and_actual_c07_build_turret_warmup_stats_rows',
            ],
        )
        self.assertTrue(ledger['N2451']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #85 (1-based in
        # the merged advances-28 DEFERRED base): the
        # BuildTurret warmup / setStats rows entry is
        # REMOVED -- warmup() and the setStats
        # buildSpeed row are both live now. Net 258 -
        # 1 = 257. The read/write and per-def stat
        # entries STAY.
        self.assertFalse(any(entry.startswith('BuildTurret warmup / setStats rows (') for entry in ledger['N2451']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret read/write rows (') for entry in ledger['N2451']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BuildTurret per-def stat rows (') for entry in ledger['N2451']['deferred_exprs']))
        self.assertEqual(len(ledger['N2451']['deferred_exprs']), 257)

    def test_all_c07_build_turret_warmup_stats_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2451']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceBuildTurretBuildState.source_build_turret_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/meta/Stat.java',
            'core/src/mindustry/world/meta/Stats.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2451']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_warmup_stats_rows_state(self):
        build_turret = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # The warmup accessor (BuildTurretBuild.
        # warmup(), BuildTurret.java:254-255):
        # `public float warmup(){` / `return
        # warmup;` -- the override of the
        # BuildingComp default (`return 0f;`,
        # BuildingComp.java:608-610). The field
        # is `public float warmup;`
        # (BuildTurret.java:96), ticked live
        # since N2243 (`warmup = Mathf.
        # lerpDelta(warmup, unit.
        # activelyBuilding() ? efficiency : 0f,
        # 0.1f);`, BuildTurret.java:139) -- the
        # pure takes it caller-supplied and
        # returns it verbatim.
        # The stats row (BuildTurret.setStats(),
        # BuildTurret.java:81-84): `super.
        # setStats();` then `stats.addPercent(
        # Stat.buildSpeed, buildSpeed);` -- the
        # token is exact (`buildSpeed = new
        # Stat("buildSpeed"),`, Stat.java:30)
        # and the value is the RAW buildSpeed:
        # addPercent formats at display time
        # only (`add(stat, StatValues.number(
        # (int)(value * 100), StatUnit.percent));
        # `, Stats.java:38), so the def 1.5f
        # displays as 150% and the class
        # default 1f (`public float buildSpeed
        # = 1f;`, BuildTurret.java:33) as 100%.
        # The single def is build-tower
        # (`buildTower = new BuildTurret(
        # "build-tower"){{`, Blocks.java:1997)
        # with `buildSpeed = 1.5f;`
        # (Blocks.java:2003). Pure-only: the
        # tick never calls warmup() / setStats
        # -- warmup() is read by the status UI
        # and setStats() by the stats UI, and
        # both call sites wait for their own
        # slices. Keep each Java expr on ONE
        # comment line (the N2148 lesson: a
        # split line fails this test).
        self.assertIn('static func source_build_turret_warmup_state', build_turret)
        self.assertIn('static func source_build_turret_stats_state', build_turret)
        self.assertIn('public float warmup(){', build_turret)
        self.assertIn('return warmup;', build_turret)
        self.assertIn('public float warmup;', build_turret)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, unit.activelyBuilding() ? efficiency : 0f, 0.1f);', build_turret)
        self.assertIn('public void setStats(){', build_turret)
        self.assertIn('super.setStats();', build_turret)
        self.assertIn('stats.addPercent(Stat.buildSpeed, buildSpeed);', build_turret)
        self.assertIn('buildSpeed = new Stat("buildSpeed"),', build_turret)
        self.assertIn('public void addPercent(Stat stat, float value){', build_turret)
        self.assertIn('add(stat, StatValues.number((int)(value * 100), StatUnit.percent));', build_turret)
        self.assertIn('public float buildSpeed = 1f;', build_turret)
        self.assertIn('buildSpeed = 1.5f;', build_turret)
        self.assertIn('public class BuildTurret extends BaseTurret{', build_turret)
        # The documented limits record the
        # warmup / stats rows as live.
        self.assertIn('Warmup / stats rows live (N2451)', build_turret)
        # The proof's keys drive the two pures
        # (the warmup accessor at 0 / 0.5 / 1,
        # the exact "buildSpeed" token, the def
        # 1.5f raw value displaying as 150%
        # and the class-default 1f raw value
        # displaying as 100%).
        proof = BUILD_TURRET_WARMUP_STATS_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_zero',
            'warmup_value',
            'warmup_one',
            'stats_key',
            'stats_value_def',
            'stats_value_class',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceBuildTurretBuildState.gd")', proof)
        self.assertTrue(BUILD_TURRET_STATE.exists())
        self.assertTrue(BUILD_TURRET_WARMUP_STATS_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07BuildTurretWarmupStatsRowsProof.gd', BUILD_TURRET_WARMUP_STATS_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_build_turret_warmup_stats_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretWarmupStatsRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_WARMUP_STATS_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_zero',
            'warmup_value',
            'warmup_one',
            'stats_key',
            'stats_value_def',
            'stats_value_class',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
