import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_CONVEYOR_STATE = ROOT / 'godot-mindustry/src/game/SourceStackConveyorBuildState.gd'
STACK_CONVEYOR_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorPerDefStatRowsProof.gd'
STACK_CONVEYOR_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackConveyorPerDefStatRowsProof.tscn'


class C07StackConveyorPerDefStatRowsTests(unittest.TestCase):
    def test_c07_stack_conveyor_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2495']['godot_owner'], 'SourceStackConveyorBuildState.source_stack_conveyor_per_def_stats_state')
        # The StackConveyor tick is live (N2239 advance +
        # N2457 setStats) and the draw / blends rows are
        # live (N2434 / N2448) but NOTHING modeled the
        # per-def stat rows as a source-backed pure:
        # the TWO StackConveyor defs set their rows in
        # Blocks.java -- plastanium-conveyor
        # (:2084-2089: health 90, speed 4f/60f,
        # itemCapacity 10, requirements plastanium 1 /
        # silicon 1 / graphite 1) and surge-conveyor
        # (:2237-2253: health 130, speed 5f/60f,
        # itemCapacity 10, requirements surge-alloy 1 /
        # tungsten 1) -- while the values only existed
        # as constants in the driver header comment.
        # N2495 ports them as ONE pure-only stats pure
        # (the N2304 / N2442 verification-slice
        # precedent): the def's rows for each def,
        # with the CLASS defaults (size 1, speed 0f,
        # itemCapacity 10, health 40 after the
        # Block.init() fill, glowAlpha 1f, glowColor
        # Pal.redLight, no requirements) for an
        # unknown def id (the N2304 fallback
        # precedent). Seven new result symbols: the
        # size + speed + item capacity + health +
        # glow alpha + glow color + requirements.
        self.assertEqual(
            ledger['N2495']['source_symbols'],
            [
                'source_stack_conveyor_per_def_stats_state_result.size',
                'source_stack_conveyor_per_def_stats_state_result.speed',
                'source_stack_conveyor_per_def_stats_state_result.item_capacity',
                'source_stack_conveyor_per_def_stats_state_result.health',
                'source_stack_conveyor_per_def_stats_state_result.glow_alpha',
                'source_stack_conveyor_per_def_stats_state_result.glow_color',
                'source_stack_conveyor_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_stack_conveyor_per_def_stats_state_result.size': 'core/src/mindustry/world/Block.java',
            'source_stack_conveyor_per_def_stats_state_result.speed': 'core/src/mindustry/content/Blocks.java',
            'source_stack_conveyor_per_def_stats_state_result.item_capacity': 'core/src/mindustry/content/Blocks.java',
            'source_stack_conveyor_per_def_stats_state_result.health': 'core/src/mindustry/content/Blocks.java',
            'source_stack_conveyor_per_def_stats_state_result.glow_alpha': 'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'source_stack_conveyor_per_def_stats_state_result.glow_color': 'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'source_stack_conveyor_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2495']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackConveyorBuildState.source_stack_conveyor_'))
        self.assertEqual(ledger['N2495']['runtime_proof'], '/root/C07StackConveyorPerDefStatRowsProof')
        self.assertEqual(
            ledger['N2495']['tests'],
            [
                'test_c07_stack_conveyor_per_def_stat_rows_registration',
                'test_all_c07_stack_conveyor_per_def_stat_rows_input_evidence_is_exact',
                'test_stack_conveyor_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_stack_conveyor_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2495']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #49 (1-based in
        # the merged advances-34 DEFERRED base, 225
        # entries): the StackConveyor per-def stat rows
        # entry is REMOVED -- size / speed /
        # itemCapacity / health / glowAlpha /
        # glowColor / requirements are live now as a
        # source-backed pure. Net 225 - 1 = 224. The
        # plastanium-conveyor power-scope entry (#48)
        # and the live items intake entry STAY -- they
        # are about power.scope / intake, not the stat
        # rows.
        self.assertFalse(any(entry.startswith('StackConveyor per-def stat rows (') for entry in ledger['N2495']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('plastanium-conveyor rows (') for entry in ledger['N2495']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackConveyor live items intake (') for entry in ledger['N2495']['deferred_exprs']))
        self.assertEqual(len(ledger['N2495']['deferred_exprs']), 224)

    def test_all_c07_stack_conveyor_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2495']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceStackConveyorBuildState.source_stack_conveyor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackConveyor.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2495']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_conveyor_per_def_stat_rows_state(self):
        stack_conveyor = STACK_CONVEYOR_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 precedent): the
        # TWO StackConveyor defs -- plastanium-conveyor
        # (Blocks.java:2084-2089: health 90, speed
        # 4f/60f, itemCapacity 10, requirements
        # plastanium 1 / silicon 1 / graphite 1) and
        # surge-conveyor (Blocks.java:2237-2253: health
        # 130, speed 5f/60f, itemCapacity 10,
        # requirements surge-alloy 1 / tungsten 1).
        # NEITHER def sets size (size 1 is the Block
        # class default, Block.java:215) or overrides
        # the glow (glowAlpha 1f / glowColor
        # Pal.redLight, StackConveyor.java:34-35). An
        # unknown def id falls back to the CLASS
        # defaults (the N2304 fallback precedent):
        # size 1 (Block.java:215), speed 0f
        # (StackConveyor.java:38), itemCapacity 10
        # (StackConveyor.java:52), glowAlpha 1f /
        # glowColor Pal.redLight
        # (StackConveyor.java:34-35), NO requirements
        # (the Block default is the empty array,
        # Block.java:356), and health 40 -- the class
        # field is the -1 sentinel (`public int health
        # = -1;`, Block.java:190, "-1 to use
        # scaledHealth"), which Block.init()
        # (Block.java:1378-1394) fills to
        # round(size * size * scaledHealth, 5) with
        # scaledHealth defaulting to 40 (:1381, no
        # requirements to scale it), so a no-override
        # def has health 40 after init. The glow
        # color carries the TOKEN "Pal.redLight"
        # (the N2469 token precedent), not a resolved
        # Color. The requirements dict is the {item:
        # amount} dict from the def (the N2490
        # precedent); the catalog carries the same
        # rows as an Array of {item, amount}
        # (content_registry.json, plastanium-conveyor
        # / surge-conveyor). Pure-only: the caller
        # reads it; the existing advance / draw /
        # stats pures are unchanged.
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_stack_conveyor_per_def_stats_state', stack_conveyor)
        self.assertIn('plastaniumConveyor = new StackConveyor("plastanium-conveyor"){{', stack_conveyor)
        self.assertIn('requirements(Category.distribution, with(Items.plastanium, 1, Items.silicon, 1, Items.graphite, 1));', stack_conveyor)
        self.assertIn('health = 90;', stack_conveyor)
        self.assertIn('speed = 4f / 60f;', stack_conveyor)
        self.assertIn('surgeConveyor = new StackConveyor("surge-conveyor"){{', stack_conveyor)
        self.assertIn('requirements(Category.distribution, with(Items.surgeAlloy, 1, Items.tungsten, 1));', stack_conveyor)
        self.assertIn('health = 130;', stack_conveyor)
        self.assertIn('speed = 5f / 60f;', stack_conveyor)
        self.assertIn('itemCapacity = 10;', stack_conveyor)
        self.assertIn('public float glowAlpha = 1f;', stack_conveyor)
        self.assertIn('public Color glowColor = Pal.redLight;', stack_conveyor)
        self.assertIn('public float speed = 0f;', stack_conveyor)
        self.assertIn('public int size = 1;', stack_conveyor)
        self.assertIn('public int health = -1;', stack_conveyor)
        self.assertIn('public ItemStack[] requirements = {};', stack_conveyor)
        self.assertIn('public class StackConveyor extends Block implements Autotiler{', stack_conveyor)
        # The documented limits record the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2495)', stack_conveyor)
        # The proof's keys drive the per-def stats pure
        # (the surge-conveyor def row, the per-def
        # speeds + shared itemCapacity, the per-def
        # health + shared glow, the requirements
        # dicts, the class fallback for an unknown def
        # id, and the def rows feeding the N2457 stats
        # pure as live inputs).
        proof = STACK_CONVEYOR_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_conveyor',
            'stats_speed_capacity',
            'stats_health_glow',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceStackConveyorBuildState.gd")', proof)
        self.assertTrue(STACK_CONVEYOR_STATE.exists())
        self.assertTrue(STACK_CONVEYOR_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07StackConveyorPerDefStatRowsProof.gd', STACK_CONVEYOR_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_stack_conveyor_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackConveyorPerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_CONVEYOR_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_conveyor',
            'stats_speed_capacity',
            'stats_health_glow',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
