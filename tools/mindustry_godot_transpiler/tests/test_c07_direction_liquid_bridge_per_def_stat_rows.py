import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DIRECTION_LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceDirectionLiquidBridgeBuildState.gd'
DIRECTION_LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DirectionLiquidBridgePerDefStatRowsProof.gd'
DIRECTION_LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DirectionLiquidBridgePerDefStatRowsProof.tscn'


class C07DirectionLiquidBridgePerDefStatRowsTests(unittest.TestCase):
    def test_c07_direction_liquid_bridge_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2502']['godot_owner'], 'SourceDirectionLiquidBridgeBuildState.source_direction_liquid_bridge_per_def_stats_state')
        # The port has NO SourceDirectionLiquidBridge*
        # files at all yet: NOTHING modeled the
        # reinforced-bridge-conduit def
        # (Blocks.java:2432-2443) -- range 4,
        # liquidCapacity 120f, health 250,
        # requirements graphite 8 / beryllium 20
        # (size 1 is the inherited Block default --
        # the def sets NO size line; speed 5f is
        # the class field -- the def sets NO speed
        # line). N2502 CREATES the family's driver
        # and ports the rows as ONE pure-only stats
        # pure (the N2304 / N2442 / N2489 / N2490
        # verification-slice precedent): the def's
        # rows for reinforced-bridge-conduit, with
        # the CLASS defaults (size 1, range 4,
        # liquidCapacity 20f, health 40 post-init,
        # speed 5f, no requirements) for an unknown
        # def id (the N2304 fallback precedent).
        # Six new result symbols: the size + range
        # + liquid capacity + health + speed +
        # requirements.
        self.assertEqual(
            ledger['N2502']['source_symbols'],
            [
                'source_direction_liquid_bridge_per_def_stats_state_result.size',
                'source_direction_liquid_bridge_per_def_stats_state_result.range_value',
                'source_direction_liquid_bridge_per_def_stats_state_result.liquid_capacity',
                'source_direction_liquid_bridge_per_def_stats_state_result.health',
                'source_direction_liquid_bridge_per_def_stats_state_result.speed',
                'source_direction_liquid_bridge_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_direction_liquid_bridge_per_def_stats_state_result.size': 'core/src/mindustry/world/Block.java',
            'source_direction_liquid_bridge_per_def_stats_state_result.range_value': 'core/src/mindustry/content/Blocks.java',
            'source_direction_liquid_bridge_per_def_stats_state_result.liquid_capacity': 'core/src/mindustry/content/Blocks.java',
            'source_direction_liquid_bridge_per_def_stats_state_result.health': 'core/src/mindustry/content/Blocks.java',
            'source_direction_liquid_bridge_per_def_stats_state_result.speed': 'core/src/mindustry/world/blocks/distribution/DirectionLiquidBridge.java',
            'source_direction_liquid_bridge_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2502']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceDirectionLiquidBridgeBuildState.source_direction_liquid_bridge_'))
        self.assertEqual(ledger['N2502']['runtime_proof'], '/root/C07DirectionLiquidBridgePerDefStatRowsProof')
        self.assertEqual(
            ledger['N2502']['tests'],
            [
                'test_c07_direction_liquid_bridge_per_def_stat_rows_registration',
                'test_all_c07_direction_liquid_bridge_per_def_stat_rows_input_evidence_is_exact',
                'test_direction_liquid_bridge_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_direction_liquid_bridge_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2502']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #39 (1-based in
        # the merged advances-35 DEFERRED base, 218
        # entries -- #41 in the 225-base, shifted by
        # the wave-35 removals): the
        # reinforced-bridge-conduit rows entry is
        # REMOVED -- size / range / liquidCapacity /
        # health / speed / requirements are live now
        # as a source-backed pure. Net 218 - 1 = 217.
        # The bridge-conduit rows entry STAYS:
        # bridge-conduit still falls back to the
        # LiquidBridge class defaults until its own
        # verification slice.
        self.assertFalse(any(entry.startswith('reinforced-bridge-conduit rows (') for entry in ledger['N2502']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('bridge-conduit rows (') for entry in ledger['N2502']['deferred_exprs']))
        self.assertEqual(len(ledger['N2502']['deferred_exprs']), 217)

    def test_all_c07_direction_liquid_bridge_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2502']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceDirectionLiquidBridgeBuildState.source_direction_liquid_bridge_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/DirectionLiquidBridge.java',
            'core/src/mindustry/world/blocks/distribution/DirectionBridge.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2502']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_direction_liquid_bridge_per_def_stat_rows_state(self):
        direction_liquid_bridge = DIRECTION_LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 / N2489 / N2490
        # precedent): the reinforced-bridge-conduit def
        # (Blocks.java:2432-2443) sets range 4,
        # liquidCapacity 120f, health 250 and
        # requirements graphite 8 / beryllium 20;
        # size 1 is the inherited Block default (the
        # def sets NO size line) and speed 5f is the
        # class field (the def sets NO speed line).
        # An unknown def id falls back to the CLASS
        # defaults (the N2304 fallback precedent):
        # size 1 (Block.java:215), range 4
        # (DirectionBridge.java:31 -- the def
        # restates the class value), liquidCapacity
        # 20f (the CONSTRUCTOR value,
        # DirectionLiquidBridge.java:26, which
        # survives Block.init() because the replace
        # only runs under `if(liquidCapacity < 0){`,
        # Block.java:1407), health 40 post-init (the
        # -1 sentinel, Block.java:190, resolved by
        # init() with scaledHealth 40,
        # Block.java:1378-1395 -- the N2495 / N2496
        # / N2497 coordinator decision), speed 5f
        # (DirectionLiquidBridge.java:15) and NO
        # requirements (the Block default is the
        # empty array, Block.java:356). The
        # requirements dict is the {item: amount}
        # dict from the def (the N2490 precedent);
        # the catalog carries the same rows as an
        # Array of {item, amount} dicts
        # (content_registry.json,
        # reinforced-bridge-conduit) plus health 250
        # / range 4, but NO size / liquidCapacity /
        # speed keys. liquidPadding is NOT a row --
        # draw-only (DirectionLiquidBridge.java:46),
        # the def does not override it. Pure-only:
        # the caller reads it; the tick / advance /
        # shouldConsume pures do not exist yet for
        # this family. Keep each Java expr on ONE
        # comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_direction_liquid_bridge_per_def_stats_state', direction_liquid_bridge)
        self.assertIn('reinforcedBridgeConduit = new DirectionLiquidBridge("reinforced-bridge-conduit"){{', direction_liquid_bridge)
        self.assertIn('requirements(Category.liquid, with(Items.graphite, 8, Items.beryllium, 20));', direction_liquid_bridge)
        self.assertIn('range = 4;', direction_liquid_bridge)
        self.assertIn('liquidCapacity = 120f;', direction_liquid_bridge)
        self.assertIn('health = 250;', direction_liquid_bridge)
        self.assertIn('public class DirectionLiquidBridge extends DirectionBridge{', direction_liquid_bridge)
        self.assertIn('public class DirectionBridge extends Block{', direction_liquid_bridge)
        self.assertIn('public int range = 4;', direction_liquid_bridge)
        self.assertIn('public float speed = 5f;', direction_liquid_bridge)
        self.assertIn('liquidCapacity = 20f;', direction_liquid_bridge)
        self.assertIn('if(liquidCapacity < 0){', direction_liquid_bridge)
        self.assertIn('public int size = 1;', direction_liquid_bridge)
        self.assertIn('public int health = -1;', direction_liquid_bridge)
        self.assertIn('public float scaledHealth = -1;', direction_liquid_bridge)
        self.assertIn('scaledHealth = 40;', direction_liquid_bridge)
        self.assertIn('if(health == -1){', direction_liquid_bridge)
        self.assertIn('Mathf.round(size * size * scaledHealth, 5)', direction_liquid_bridge)
        self.assertIn('public ItemStack[] requirements = {};', direction_liquid_bridge)
        self.assertIn('public float liquidPadding = 1f;', direction_liquid_bridge)
        # The driver header records the per-def stat
        # rows as live.
        self.assertIn('Per-def stat rows live (N2502)', direction_liquid_bridge)
        # The proof's keys drive the per-def stats pure
        # (the reinforced-bridge-conduit def row, the
        # range + capacity def-vs-class split, the
        # health + speed def-vs-class split, the
        # requirements dict, the class fallback for
        # an unknown def id, and the def rows feeding
        # the N2275 transport pure as live inputs).
        proof = DIRECTION_LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_bridge',
            'stats_range_capacity',
            'stats_health_speed',
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
        self.assertIn('preload("res://src/game/SourceDirectionLiquidBridgeBuildState.gd")', proof)
        self.assertTrue(DIRECTION_LIQUID_BRIDGE_STATE.exists())
        self.assertTrue(DIRECTION_LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07DirectionLiquidBridgePerDefStatRowsProof.gd', DIRECTION_LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_direction_liquid_bridge_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DirectionLiquidBridgePerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DIRECTION_LIQUID_BRIDGE_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_bridge',
            'stats_range_capacity',
            'stats_health_speed',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
