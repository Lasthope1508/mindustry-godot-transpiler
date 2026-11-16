import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretPerDefStatRowsProof.gd'
REPAIR_TURRET_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretPerDefStatRowsProof.tscn'


class C07RepairTurretPerDefStatRowsTests(unittest.TestCase):
    def test_c07_repair_turret_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2489']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_per_def_stats_state')
        # The per-def stat rows (RepairTurret.java:32-37
        # class defaults + Blocks.java:6386-6406 def
        # overrides): repair-point repairSpeed 0.45f /
        # repairRadius 60f / beamWidth 0.73f /
        # pulseRadius 5f, and NO length override so it
        # keeps the class 5f; repair-turret length 6f /
        # repairSpeed 3f / repairRadius 145f /
        # beamWidth 1.1f / pulseRadius 6.1f. The class
        # defaults are repairSpeed 0.3f / repairRadius
        # 50f / length 5f / beamWidth 1f / pulseRadius
        # 6f. N2489 is the VERIFICATION slice (the
        # N2304 / N2442 precedent): the values were
        # already driver-header constants, and this
        # slice ports them as ONE pure-only pure,
        # source_repair_turret_per_def_stats_state
        # (def_id) -> {repair_speed, repair_radius,
        # length, beam_width, pulse_radius}; an unknown
        # def id falls back to the CLASS defaults (the
        # N2304 fallback precedent -- NOT the
        # repair-point fallback of the N2226 advance
        # helpers, which stay untouched). The advance
        # and draw pures take these values as caller-
        # supplied inputs and are unchanged. Five new
        # result symbols, one per returned row.
        self.assertEqual(
            ledger['N2489']['source_symbols'],
            [
                'source_repair_turret_per_def_stats_state_result.repair_speed',
                'source_repair_turret_per_def_stats_state_result.repair_radius',
                'source_repair_turret_per_def_stats_state_result.length',
                'source_repair_turret_per_def_stats_state_result.beam_width',
                'source_repair_turret_per_def_stats_state_result.pulse_radius',
            ],
        )
        for name in ledger['N2489']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/RepairTurret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_per_def_stats_state')
        self.assertEqual(ledger['N2489']['runtime_proof'], '/root/C07RepairTurretPerDefStatRowsProof')
        self.assertEqual(
            ledger['N2489']['tests'],
            [
                'test_c07_repair_turret_per_def_stat_rows_registration',
                'test_all_c07_repair_turret_per_def_stat_rows_input_evidence_is_exact',
                'test_repair_turret_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_repair_turret_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2489']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #34 (1-based
        # in DEFERRED-after-advances-33.py, the
        # merged 231 file): "RepairTurret per-def
        # stat rows (repairSpeed 0.45f/3f,
        # repairRadius 60f/145f, length 5f/6f,
        # beamWidth 0.73f/1.1f, pulseRadius 5f/6.1f,
        # Blocks.java:6386-6406)". Net 231 - 1 =
        # 230. No new entry: the pure is complete as
        # a pure -- the advance / draw call sites
        # that would read it are renderer / tick
        # work that waits for their own slices (the
        # N2421 draw precedent: no entry added for
        # call sites).
        self.assertFalse(any(entry.startswith('RepairTurret per-def stat rows (') for entry in ledger['N2489']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret read/write rows (') for entry in ledger['N2489']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret live target acquire (') for entry in ledger['N2489']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret updateTile live fill (') for entry in ledger['N2489']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTurret coolant stat/effect rows (') for entry in ledger['N2489']['deferred_exprs']))
        self.assertEqual(len(ledger['N2489']['deferred_exprs']), 230)

    def test_all_c07_repair_turret_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2489']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_per_def_stats_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2489']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_per_def_stat_rows_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (RepairTurret.java:32-
        # 37 class defaults + Blocks.java:6386-6406
        # def overrides). The class fields are
        # `public float repairRadius = 50f;` /
        # `public float repairSpeed = 0.3f;` /
        # `public float length = 5f;` / `public
        # float beamWidth = 1f;` / `public float
        # pulseRadius = 6f;`. The defs are
        # `repairPoint = new RepairTurret(
        # "repair-point"){{` with `repairSpeed =
        # 0.45f;` / `repairRadius = 60f;` /
        # `beamWidth = 0.73f;` / `pulseRadius =
        # 5f;` (NO length line -- the point keeps
        # the class 5f) and `repairTurret = new
        # RepairTurret("repair-turret"){{` with
        # `length = 6f;` / `repairSpeed = 3f;` /
        # `repairRadius = 145f;` / `beamWidth =
        # 1.1f;` / `pulseRadius = 6.1f;`. The stat
        # anchor is setStats() (RepairTurret.java:
        # 71-74): `stats.add(Stat.range,
        # repairRadius / tilesize, StatUnit.blocks);`
        # + `stats.add(Stat.repairSpeed,
        # repairSpeed * 60f, StatUnit.perSecond);`.
        # The pure returns the def's five rows; an
        # unknown def id falls back to the CLASS
        # defaults (the N2304 fallback precedent) --
        # NOT the repair-point fallback of the N2226
        # advance helpers, which stay untouched.
        # Pure-only: the tick never calls it -- the
        # advance / draw pures take these values as
        # caller-supplied inputs and are unchanged.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_repair_turret_per_def_stats_state', repair_turret)
        self.assertIn('public float repairRadius = 50f;', repair_turret)
        self.assertIn('public float repairSpeed = 0.3f;', repair_turret)
        self.assertIn('public float length = 5f;', repair_turret)
        self.assertIn('public float beamWidth = 1f;', repair_turret)
        self.assertIn('public float pulseRadius = 6f;', repair_turret)
        self.assertIn('repairPoint = new RepairTurret("repair-point"){{', repair_turret)
        self.assertIn('repairSpeed = 0.45f;', repair_turret)
        self.assertIn('repairRadius = 60f;', repair_turret)
        self.assertIn('beamWidth = 0.73f;', repair_turret)
        self.assertIn('pulseRadius = 5f;', repair_turret)
        self.assertIn('repairTurret = new RepairTurret("repair-turret"){{', repair_turret)
        self.assertIn('length = 6f;', repair_turret)
        self.assertIn('repairSpeed = 3f;', repair_turret)
        self.assertIn('repairRadius = 145f;', repair_turret)
        self.assertIn('beamWidth = 1.1f;', repair_turret)
        self.assertIn('pulseRadius = 6.1f;', repair_turret)
        self.assertIn('public class RepairTurret extends Block{', repair_turret)
        self.assertIn('stats.add(Stat.range, repairRadius / tilesize, StatUnit.blocks);', repair_turret)
        self.assertIn('stats.add(Stat.repairSpeed, repairSpeed * 60f, StatUnit.perSecond);', repair_turret)
        # The new constants carry the class defaults
        # + the per-def length / beamWidth /
        # pulseRadius rows (the speed / radius
        # constants already exist since N2226).
        self.assertIn('SOURCE_REPAIR_TURRET_CLASS_REPAIR_SPEED := 0.3', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_CLASS_REPAIR_RADIUS := 50.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_CLASS_LENGTH := 5.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_CLASS_BEAM_WIDTH := 1.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_CLASS_PULSE_RADIUS := 6.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_POINT_BEAM_WIDTH := 0.73', repair_turret)
        self.assertIn('SOURCE_REPAIR_POINT_PULSE_RADIUS := 5.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_LENGTH := 6.0', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_BEAM_WIDTH := 1.1', repair_turret)
        self.assertIn('SOURCE_REPAIR_TURRET_PULSE_RADIUS := 6.1', repair_turret)
        # The documented limits record the per-def
        # stat rows as live, and the advance / draw
        # pures are untouched (this slice amends
        # neither -- they keep taking the values as
        # caller-supplied inputs).
        self.assertIn('Per-def stat rows live (N2489)', repair_turret)
        self.assertIn('static func source_repair_turret_update_tile_advance_state', repair_turret)
        self.assertIn('static func source_repair_turret_draw_state', repair_turret)
        # Pure-only: the driver NEVER calls the new
        # pure from the tick -- the only call-shaped
        # occurrence is its definition itself
        # (docstring mentions carry no parens).
        self.assertEqual(repair_turret.count('source_repair_turret_per_def_stats_state('), 1)
        # The proof's keys drive the pure (the two
        # def rows, the class-default fallback, the
        # setStats speed/radius rows, the draw
        # beam/pulse rows, and the live advance
        # input composition).
        proof = REPAIR_TURRET_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_point',
            'stats_turret',
            'stats_class_fallback',
            'stats_speed_radius',
            'stats_beam_pulse',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist). Pure-only: the proof
        # never touches the live tick; the live-input keys
        # compose the N2226 advance + N2421 draw pures (their
        # caller-supplied inputs come from this pure's rows).
        self.assertIn('preload("res://src/game/SourceRepairTurretBuildState.gd")', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_per_def_stats_state(', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_update_tile_advance_state(', proof)
        self.assertIn('repair_turret_build_state.source_repair_turret_draw_state(', proof)
        self.assertNotIn('source_repair_turret_tick_buildings_state', proof)
        self.assertTrue(REPAIR_TURRET_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = REPAIR_TURRET_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RepairTurretPerDefStatRowsProof.gd', scene)
        self.assertIn('C07RepairTurretPerDefStatRowsProof', scene)

    def test_reference_graph_and_actual_c07_repair_turret_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretPerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_point',
            'stats_turret',
            'stats_class_fallback',
            'stats_speed_radius',
            'stats_beam_pulse',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
