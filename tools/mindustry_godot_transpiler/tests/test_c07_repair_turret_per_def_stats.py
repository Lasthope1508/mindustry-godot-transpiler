import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_PER_DEF_STATS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretPerDefStatsProof.gd'


class C07RepairTurretPerDefStatsTests(unittest.TestCase):
    def test_c07_repair_turret_per_def_stats_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2237']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_per_def_stats_state')
        # The per-def values were already resolved by driver
        # helpers (_repair_radius_for_block_id,
        # _repair_speed_for_block_id, _beam_length_for_block_id,
        # _beam_width_for_block_id) but never registered as a
        # pure function: the deferred pool entry "RepairTurret
        # per-def stat rows (repairSpeed 0.45f/3f, repairRadius
        # 60f/145f, length 5f/6f, beamWidth 0.73f/1.1f,
        # pulseRadius 5f/6.1f, Blocks.java:6386-6406) -- static
        # defs, wait for their own verification slice" is the
        # last open RepairTurret stat item (range() is N2233,
        # ambientSoundVolume N2235, coolantUse/coolantMultiplier
        # the N2209 coolant fold; powerUse lives in the catalog
        # consumePower/consumePowerCond). RED decisions
        # (resolved at RED, recorded in the register
        # docstring): (1) One pure function on the same family
        # file, taking the block id explicitly (per-def static
        # state, not a live frame key -- the N2212 / N2220 /
        # N2235 precedent) and returning all five rows, reusing
        # the four existing helpers plus a new
        # `_pulse_radius_for_block_id` helper -- no duplicated
        # constants. (2) There is NO driver tick line: a static
        # read (the N2233 range / N2235 ambient volume
        # precedent). (3) The deferred pool entry "RepairTurret
        # per-def stat rows" is dropped here and replaced by
        # the N2237 Windows-proof debt entry; the RepairTower
        # per-def stat rows entry survives (different family).
        # Five new result symbols: repair_speed,
        # repair_radius, length, beam_width, pulse_radius.
        self.assertEqual(
            ledger['N2237']['source_symbols'],
            [
                'source_repair_turret_per_def_stats_state_result.repair_speed',
                'source_repair_turret_per_def_stats_state_result.repair_radius',
                'source_repair_turret_per_def_stats_state_result.length',
                'source_repair_turret_per_def_stats_state_result.beam_width',
                'source_repair_turret_per_def_stats_state_result.pulse_radius',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2237']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2237']['runtime_proof'], '/root/C07RepairTurretPerDefStatsProof')
        self.assertEqual(
            ledger['N2237']['tests'],
            [
                'test_c07_repair_turret_per_def_stats_registration',
                'test_all_c07_repair_turret_per_def_stats_input_evidence_is_exact',
                'test_repair_turret_per_def_stats_state',
                'test_reference_graph_and_actual_c07_repair_turret_per_def_stats',
            ],
        )
        self.assertTrue(ledger['N2237']['deferred_exprs'])

    def test_all_c07_repair_turret_per_def_stats_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2237']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2237']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_per_def_stats_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairTurret per-def stat rows (Blocks.java:6386-6406
        # + class defaults RepairTurret.java:32-37): repair-point
        # repairSpeed 0.45f / repairRadius 60f / beamWidth 0.73f /
        # pulseRadius 5f, length the 5f class default (no override);
        # repair-turret length 6f / repairSpeed 3f / repairRadius
        # 145f / beamWidth 1.1f / pulseRadius 6.1f; class defaults
        # repairSpeed 0.3f / repairRadius 50f / length 5f /
        # beamWidth 1f / pulseRadius 6f. The pure function takes
        # the block id explicitly (per-def static state, not a
        # live frame key) and reuses the four existing per-def
        # helpers plus the new `_pulse_radius_for_block_id`.
        # No driver tick line: a static read (the N2233 /
        # N2235 precedent).
        self.assertIn('static func source_repair_turret_per_def_stats_state(block_id: String) -> Dictionary:', repair_turret)
        self.assertIn('return {"repair_speed": _repair_speed_for_block_id(block_id), "repair_radius": _repair_radius_for_block_id(block_id), "length": _beam_length_for_block_id(block_id), "beam_width": _beam_width_for_block_id(block_id), "pulse_radius": _pulse_radius_for_block_id(block_id)}', repair_turret)
        self.assertIn('static func _pulse_radius_for_block_id(block_id: String) -> float:', repair_turret)
        for expr in [
            'public float repairRadius = 50f;',
            'public float repairSpeed = 0.3f;',
            'public float length = 5f;',
            'public float beamWidth = 1f;',
            'public float pulseRadius = 6f;',
            'repairSpeed = 0.45f;',
            'repairRadius = 60f;',
            'beamWidth = 0.73f;',
            'pulseRadius = 5f;',
            'length = 6f;',
            'repairSpeed = 3f;',
            'repairRadius = 145f;',
            'beamWidth = 1.1f;',
            'pulseRadius = 6.1f;',
            'public class RepairTurret extends Block{',
            'repairPoint = new RepairTurret("repair-point"){{',
            'repairTurret = new RepairTurret("repair-turret"){{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        driver_start = repair_turret.index('static func source_repair_turret_tick_buildings_state')
        driver_end = repair_turret.find('\nstatic func ', driver_start + 1)
        driver_body = repair_turret[driver_start:driver_end if driver_end != -1 else len(repair_turret)]
        self.assertNotIn('source_repair_turret_per_def_stats_state', driver_body)
        # The proof's keys drive the pure function with the two
        # catalog defs, an unknown def and the empty id / has no
        # driver tick line (the proof reads the state script
        # source and greps the driver body -- a runtime check,
        # not a hardcoded true).
        proof = REPAIR_TURRET_PER_DEF_STATS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_repair_point',
            'stats_repair_turret',
            'stats_class_default',
            'stats_empty_defaults',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_per_def_stats(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretPerDefStatsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_PER_DEF_STATS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_repair_point',
            'stats_repair_turret',
            'stats_class_default',
            'stats_empty_defaults',
            'has_no_driver_tick_line',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
