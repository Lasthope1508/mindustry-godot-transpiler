import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_SET_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerSetStatsProof.gd'


class C07RepairTowerSetStatsTests(unittest.TestCase):
    def test_c07_repair_tower_set_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2230']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_set_stats_state')
        # RepairTower.setStats() (RepairTower.java:35-41,
        # `public void setStats(){`) adds two stat rows
        # unconditionally (`stats.add(Stat.range, range /
        # tilesize, StatUnit.blocks);` -- RepairTower.java:38
        # -- and `stats.add(Stat.repairSpeed, healAmount *
        # 60f, StatUnit.perSecond);` -- RepairTower.java:39).
        # `super.setStats();` (:37) is Block-level stat work
        # (N1696), NOT this slice: the base stats come from
        # Block.setStats and are not re-emitted here. RED
        # decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on the
        # same family file N2190 / N2191 / N2211 / N2228 /
        # N2229 built:
        # source_repair_tower_set_stats_state(range,
        # heal_amount, tilesize) returning a single `stats`
        # list with the two rows in Java order (the
        # scope-pinned shape, mirroring the stats.add
        # order). All three params are explicit floats (the
        # N2212 acquire / N2220 draw-place / N2224 setStats
        # per-def-param precedent -- range and healAmount are
        # per-def static state, not live frame keys: class
        # defaults range 80f / healAmount 1f,
        # RepairTower.java:21, :24; unit-repair-tower 100f /
        # 1.5f, Blocks.java:6579-6580); tilesize is 8
        # (Vars.java:135, `public static final int tilesize =
        # 8;`). (2) There is NO driver tick line: setStats is
        # a stat-display read, not a tick write (the N2224
        # RepairTurret setStats / N2220 draw-select/draw-place
        # precedent); the proof calls the pure function
        # directly with per-def params. (3) One new result
        # symbol, `stats` (the two-row list): the scope's +5
        # estimate was copied from N2224's flat 5-key return
        # and is corrected at RED -- this slice returns a
        # single list, so symbols +1, Done +1, contracts +1,
        # schema +2, SSOT 11497/1679/1606/3003 ->
        # 11498/1680/1607/3005.
        self.assertEqual(
            ledger['N2230']['source_symbols'],
            [
                'source_repair_tower_set_stats_state_result.stats',
            ],
        )
        for name in ledger['N2230']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTower.java',
                    'core/src/mindustry/Vars.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2230']['runtime_proof'], '/root/C07RepairTowerSetStatsProof')
        self.assertEqual(
            ledger['N2230']['tests'],
            [
                'test_c07_repair_tower_set_stats_registration',
                'test_all_c07_repair_tower_set_stats_input_evidence_is_exact',
                'test_repair_tower_set_stats_state',
                'test_reference_graph_and_actual_c07_repair_tower_set_stats',
            ],
        )
        self.assertTrue(ledger['N2230']['deferred_exprs'])

    def test_all_c07_repair_tower_set_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2230']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2230']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_set_stats_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # RepairTower.setStats() (RepairTower.java:35-41,
        # `public void setStats(){`): `super.setStats();`
        # (:37) is Block-level stat work (N1696), NOT this
        # slice; this slice owns the two unconditional rows
        # (`stats.add(Stat.range, range / tilesize,
        # StatUnit.blocks);` -- :38 -- and
        # `stats.add(Stat.repairSpeed, healAmount * 60f,
        # StatUnit.perSecond);` -- :39). All three params are
        # explicit per-def floats (the N2212 / N2220 / N2224
        # precedent): class defaults range 80f / healAmount
        # 1f (RepairTower.java:21, :24); unit-repair-tower
        # 100f / 1.5f (Blocks.java:6579-6580); tilesize is 8
        # (Vars.java:135, `public static final int tilesize =
        # 8;`). There is no driver tick line: setStats is a
        # stat-display read, not a tick write (the N2224 /
        # N2220 precedent) -- the driver function body below
        # must not call the new function.
        self.assertIn('static func source_repair_tower_set_stats_state(range: float, heal_amount: float, tilesize: float) -> Dictionary:', repair_tower)
        self.assertIn('var range_blocks: float = range / tilesize', repair_tower)
        self.assertIn('var repair_speed_per_second: float = heal_amount * 60.0', repair_tower)
        self.assertIn('return {"stats": [{"stat": "range", "value": range_blocks, "unit": "blocks"}, {"stat": "repairSpeed", "value": repair_speed_per_second, "unit": "perSecond"}]}', repair_tower)
        for expr in [
            'public void setStats(){',
            'super.setStats();',
            'stats.add(Stat.range, range / tilesize, StatUnit.blocks);',
            'stats.add(Stat.repairSpeed, healAmount * 60f, StatUnit.perSecond);',
            'public float range = 80f;',
            'public float healAmount = 1f;',
            'range = 100f;',
            'healAmount = 1.5f;',
            'public static final int tilesize = 8;',
            'public class RepairTower extends Block{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_tower)
        driver_start = repair_tower.index('static func source_repair_tower_tick_buildings_state')
        driver_end = repair_tower.find('\nstatic func ', driver_start + 1)
        driver_body = repair_tower[driver_start:driver_end if driver_end != -1 else len(repair_tower)]
        self.assertNotIn('source_repair_tower_set_stats_state', driver_body)
        # The proof's keys drive the pure function directly
        # with per-def params (no live tick: setStats is a
        # stat-display read): range + repair speed at the
        # catalog def (100f / 1.5f -> 12.5 blocks / 90 per
        # second), the same rows at the class defaults via
        # params (80f / 1f -> 10 blocks / 60 per second,
        # proving the function does not hardcode the
        # catalog), and the no-driver-tick-line key (the
        # proof reads the state script source and greps the
        # driver body -- a runtime check, not a hardcoded
        # true).
        proof = REPAIR_TOWER_SET_STATS_PROOF.read_text(encoding='utf-8')
        for key in [
            'range_in_blocks',
            'repair_speed_per_second',
            'class_defaults_via_params',
            'no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_set_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerSetStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_SET_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'range_in_blocks',
            'repair_speed_per_second',
            'class_defaults_via_params',
            'no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
