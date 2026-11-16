import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_CONVEYOR_STATE = ROOT / 'godot-mindustry/src/game/SourceStackConveyorBuildState.gd'
STACK_CONVEYOR_SET_STATS_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorSetStatsRowsProof.gd'
STACK_CONVEYOR_SET_STATS_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorSetStatsRowsProof.tscn'


class C07StackConveyorSetStatsRowsTests(unittest.TestCase):
    def test_c07_stack_conveyor_set_stats_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2457']['godot_owner'], 'SourceStackConveyorBuildState.source_stack_conveyor_stats_state')
        # The StackConveyor tick is live (N2239
        # updateTile advance), the draw rows are
        # live (N2434 draw / drawCached / glow),
        # and the blends / plan / rotatedOutput
        # rows are live (N2448) but NOTHING
        # modeled the stats rows: setStats() adds
        # the itemsMoved stat (StackConveyor.
        # java:64-68). N2457 ports it as ONE
        # pure-only pure (the N2442 StackRouter
        # stats precedent): the stats pure takes
        # itemCapacity / speed and returns the
        # items-moved rate + the Stat / StatUnit
        # tokens. Three new result symbols: the
        # rate + key + unit.
        self.assertEqual(
            ledger['N2457']['source_symbols'],
            [
                'source_stack_conveyor_stats_state_result.items_moved_per_second',
                'source_stack_conveyor_stats_state_result.stat_key',
                'source_stack_conveyor_stats_state_result.stat_unit',
            ],
        )
        expected_sources = {
            'source_stack_conveyor_stats_state_result.items_moved_per_second': 'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'source_stack_conveyor_stats_state_result.stat_key': 'core/src/mindustry/world/meta/Stat.java',
            'source_stack_conveyor_stats_state_result.stat_unit': 'core/src/mindustry/world/meta/StatUnit.java',
        }
        for name in ledger['N2457']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackConveyorBuildState.source_stack_conveyor_stats_state'))
        self.assertEqual(ledger['N2457']['runtime_proof'], '/root/C07StackConveyorSetStatsRowsProof')
        self.assertEqual(
            ledger['N2457']['tests'],
            [
                'test_c07_stack_conveyor_set_stats_rows_registration',
                'test_all_c07_stack_conveyor_set_stats_rows_input_evidence_is_exact',
                'test_stack_conveyor_set_stats_rows_state',
                'test_reference_graph_and_actual_c07_stack_conveyor_set_stats_rows',
            ],
        )
        self.assertTrue(ledger['N2457']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #252
        # (1-based in the merged advances-29
        # DEFERRED base): the StackConveyor
        # setStats rows entry is REMOVED --
        # setStats itemsMoved is live now. Net
        # 253 - 1 = 252. The acceptStack /
        # handleStack and read/write entries
        # STAY.
        self.assertFalse(any(entry.startswith('StackConveyor setStats rows (') for entry in ledger['N2457']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor acceptStack / handleStack / removeStack / itemTaken / acceptItem rows (') for entry in ledger['N2457']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor read/write rows (') for entry in ledger['N2457']['deferred_exprs']))
        self.assertEqual(len(ledger['N2457']['deferred_exprs']), 252)

    def test_all_c07_stack_conveyor_set_stats_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2457']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackConveyorBuildState.source_stack_conveyor_stats_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/meta/Stat.java',
            'core/src/mindustry/world/meta/StatUnit.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The round() semantics live in arc, not
        # mindustry (the N2191 precedent):
        # Mathf.round(float) adds BIG_ENOUGH_ROUND
        # and truncates (Mathf.java:500-502).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2457']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_conveyor_set_stats_rows_state(self):
        stack_conveyor = STACK_CONVEYOR_STATE.read_text(encoding='utf-8')
        # The stats rows (StackConveyor.setStats(),
        # StackConveyor.java:64-68): super.setStats()
        # then stats.add(Stat.itemsMoved, Mathf.round(
        # itemCapacity * speed * 60), StatUnit.
        # itemsSecond) -- the float math is Java-exact:
        # itemCapacity * speed FIRST, then times 60
        # (left-assoc), then Mathf.round. The class
        # defaults are speed 0f (StackConveyor.
        # java:38) and itemCapacity 10 (StackConveyor.
        # java:52), so the class-default rate is
        # round(10 * 0 * 60) = 0 items per second.
        # The plastanium-conveyor def sets speed 4f/60f
        # (Blocks.java:2087) with itemCapacity 10
        # (Blocks.java:2088), so its rate is round(10
        # * 4/60 * 60) = 40; the surge-conveyor def
        # sets speed 5f/60f (Blocks.java:2241) with
        # itemCapacity 10 (Blocks.java:2242), so its
        # rate is round(10 * 5/60 * 60) = 50. There is
        # NO "stack-conveyor" or "large-stack-conveyor"
        # def in Blocks.java -- plastanium-conveyor
        # and surge-conveyor are the only two
        # StackConveyor defs. The tokens are exact:
        # itemsMoved (Stat.java:52) and itemsSecond
        # (StatUnit.java:20). Mathf.round(float)
        # (arc Mathf.java:500-502) adds
        # BIG_ENOUGH_ROUND (16384.5f) and truncates,
        # which is floor(v + 0.5) for the non-negative
        # values here -- the port uses int(floor(v +
        # 0.5)) explicitly (the
        # SourceBlockRequirementsState precedent)
        # instead of GDScript round(), so the .5 edge
        # rounds UP exactly like Java.
        # Pure-only: the tick never calls setStats.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_stack_conveyor_stats_state', stack_conveyor)
        self.assertIn('public void setStats(){', stack_conveyor)
        self.assertIn('super.setStats();', stack_conveyor)
        self.assertIn('stats.add(Stat.itemsMoved, Mathf.round(itemCapacity * speed * 60), StatUnit.itemsSecond);', stack_conveyor)
        self.assertIn('public float speed = 0f;', stack_conveyor)
        self.assertIn('itemCapacity = 10;', stack_conveyor)
        self.assertIn('public class StackConveyor extends Block implements Autotiler{', stack_conveyor)
        self.assertIn('itemsMoved = new Stat("itemsMoved", StatCat.items),', stack_conveyor)
        self.assertIn('itemsSecond = new StatUnit("itemsSecond"),', stack_conveyor)
        self.assertIn('plastaniumConveyor = new StackConveyor("plastanium-conveyor"){{', stack_conveyor)
        self.assertIn('speed = 4f / 60f;', stack_conveyor)
        self.assertIn('surgeConveyor = new StackConveyor("surge-conveyor"){{', stack_conveyor)
        self.assertIn('speed = 5f / 60f;', stack_conveyor)
        self.assertIn('public static int round(float value){', stack_conveyor)
        self.assertIn('return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;', stack_conveyor)
        # The documented limits record the setStats
        # rows as live.
        self.assertIn('SetStats rows live (N2457)', stack_conveyor)
        # The proof's keys drive the pure (the
        # stats math at the class defaults
        # round(10*0*60) = 0 plus the
        # plastanium-conveyor round(10*4/60*60) =
        # 40 and surge-conveyor round(10*5/60*60)
        # = 50 def rates, the exact Stat /
        # StatUnit tokens, and the rounding edge:
        # 4.5 -> 5 and 2.5 -> 3 round UP like
        # Java, 4.2 -> 4 rounds down).
        proof = STACK_CONVEYOR_SET_STATS_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_class_default',
            'stats_plastanium_def',
            'stats_surge_def',
            'stats_key',
            'stats_unit',
            'stats_rounding',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceStackConveyorBuildState.gd")', proof)
        self.assertTrue(STACK_CONVEYOR_STATE.exists())
        self.assertTrue(STACK_CONVEYOR_SET_STATS_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07StackConveyorSetStatsRowsProof.gd', STACK_CONVEYOR_SET_STATS_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_stack_conveyor_set_stats_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackConveyorSetStatsRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_CONVEYOR_SET_STATS_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_class_default',
            'stats_plastanium_def',
            'stats_surge_def',
            'stats_key',
            'stats_unit',
            'stats_rounding',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
