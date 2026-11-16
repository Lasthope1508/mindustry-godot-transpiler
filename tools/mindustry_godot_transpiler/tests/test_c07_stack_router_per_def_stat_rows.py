import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
STACK_ROUTER_STATE = ROOT / 'godot-mindustry/src/game/SourceStackRouterBuildState.gd'
STACK_ROUTER_PER_DEF_STAT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterPerDefStatRowsProof.gd'
STACK_ROUTER_PER_DEF_STAT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07StackRouterPerDefStatRowsProof.tscn'


class C07StackRouterPerDefStatRowsTests(unittest.TestCase):
    def test_c07_stack_router_per_def_stat_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2496']['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_per_def_stats_state')
        # The StackRouter tick is live (N2240 advance +
        # N2324 target list + N2472 live proximity +
        # N2332 acceptItem gate) and the draw / stats /
        # plan / config rows are live (N2433 / N2442 /
        # N2449) but NOTHING modeled the per-def stat
        # rows as a source-backed pure: the
        # surge-router def (Blocks.java:2255-2268) sets
        # speed 6f, health 130 and requirements
        # surge-alloy 5 / tungsten 1, while size 1 /
        # itemCapacity 10 / glowAlpha 1f / glowColor
        # Pal.redLight come from the class (the def
        # sets NONE of them). N2496 ports them as ONE
        # pure-only stats pure (the N2304 / N2442 /
        # N2489 / N2490 verification-slice precedent):
        # the def's rows for surge-router, with the
        # CLASS defaults (size 1, speed 5f,
        # itemCapacity 10, health 40 init-resolved,
        # glowAlpha 1f / glowColor Pal.redLight, no
        # requirements) for an unknown def id (the
        # N2304 fallback precedent). Seven new result
        # symbols: size + speed + item_capacity +
        # health + glow_alpha + glow_color +
        # requirements.
        self.assertEqual(
            ledger['N2496']['source_symbols'],
            [
                'source_stack_router_per_def_stats_state_result.size',
                'source_stack_router_per_def_stats_state_result.speed',
                'source_stack_router_per_def_stats_state_result.item_capacity',
                'source_stack_router_per_def_stats_state_result.health',
                'source_stack_router_per_def_stats_state_result.glow_alpha',
                'source_stack_router_per_def_stats_state_result.glow_color',
                'source_stack_router_per_def_stats_state_result.requirements',
            ],
        )
        expected_sources = {
            'source_stack_router_per_def_stats_state_result.size': 'core/src/mindustry/world/Block.java',
            'source_stack_router_per_def_stats_state_result.speed': 'core/src/mindustry/content/Blocks.java',
            'source_stack_router_per_def_stats_state_result.item_capacity': 'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'source_stack_router_per_def_stats_state_result.health': 'core/src/mindustry/content/Blocks.java',
            'source_stack_router_per_def_stats_state_result.glow_alpha': 'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'source_stack_router_per_def_stats_state_result.glow_color': 'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'source_stack_router_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
        }
        for name in ledger['N2496']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_per_def_stats_state')
        self.assertEqual(ledger['N2496']['runtime_proof'], '/root/C07StackRouterPerDefStatRowsProof')
        self.assertEqual(
            ledger['N2496']['tests'],
            [
                'test_c07_stack_router_per_def_stat_rows_registration',
                'test_all_c07_stack_router_per_def_stat_rows_input_evidence_is_exact',
                'test_stack_router_per_def_stat_rows_state',
                'test_reference_graph_and_actual_c07_stack_router_per_def_stat_rows',
            ],
        )
        self.assertTrue(ledger['N2496']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #55 (1-based
        # in DEFERRED-after-advances-34.py, the
        # merged 225 file): "StackRouter per-def
        # stat rows (size 1, speed 6f, itemCapacity
        # 10, health 130, surge-alloy 5 / tungsten
        # 1, Blocks.java:2255-2268; glowAlpha 1f /
        # glowColor Pal.redLight, StackRouter.java:
        # 15-16)". Net 225 - 1 = 224. No new entry:
        # the pure is complete as a pure -- the
        # advance / draw call sites that would read
        # it are renderer / tick work that waits for
        # their own slices (the N2421 draw
        # precedent: no entry added for call sites).
        # The other StackRouter entries STAY.
        self.assertFalse(any(entry.startswith('StackRouter per-def stat rows (') for entry in ledger['N2496']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter read/write rows (') for entry in ledger['N2496']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter parent updateTile rows (') for entry in ledger['N2496']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter shouldConsume gate') for entry in ledger['N2496']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter live proximity query + handleItem application (') for entry in ledger['N2496']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('StackRouter acceptItem live fill (') for entry in ledger['N2496']['deferred_exprs']))
        self.assertEqual(len(ledger['N2496']['deferred_exprs']), 224)

    def test_all_c07_stack_router_per_def_stat_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2496']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceStackRouterBuildState.source_stack_router_per_def_stats_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/StackRouter.java',
            'core/src/mindustry/world/blocks/distribution/DuctRouter.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2496']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stack_router_per_def_stat_rows_state(self):
        stack_router = STACK_ROUTER_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION
        # slice: the speed / itemCapacity / glow
        # values are already constants in the
        # driver header -- the N2304 / N2442 /
        # N2489 / N2490 precedent): the single
        # StackRouter def surge-router
        # (Blocks.java:2255-2268) sets `speed =
        # 6f;` (:2259) / `health = 130;` (:2257) /
        # `requirements(Category.distribution,
        # with(Items.surgeAlloy, 5, Items.tungsten,
        # 1));` (:2256) and NO size / itemCapacity
        # / glow lines, so those take the class
        # values: size 1 (`public int size = 1;`,
        # Block.java:215), itemCapacity 10
        # (`itemCapacity = 10;`,
        # StackRouter.java:20, also the Block
        # default `public int itemCapacity = 10;`,
        # Block.java:75 -- the StackRouter ctor
        # re-sets the DuctRouter 1), glowAlpha 1f /
        # glowColor Pal.redLight
        # (StackRouter.java:15-16). The class
        # speed is 5f (`public float speed = 5f;`,
        # DuctRouter.java:19 -- DuctRouter
        # overrides Router.java:13's 8f). The
        # class health is the -1 sentinel
        # (`public int health = -1;`,
        # Block.java:190, "building health; -1 to
        # use scaledHealth"), resolved by init()
        # (Block.java:1378-1394) to 40 for size 1
        # with no requirements (`scaledHealth =
        # 40;`, scaling 1f, `Mathf.round(size *
        # size * scaledHealth, 5)`) -- the
        # fallback reports the RESOLVED 40, not
        # the sentinel. The stat anchor is
        # setStats() (DuctRouter.java:48-52,
        # inherited: `stats.add(Stat.itemsMoved,
        # 60f / speed * itemCapacity,
        # StatUnit.itemsSecond);`). An unknown def
        # id falls back to the CLASS defaults (the
        # N2304 fallback precedent). Pure-only:
        # the tick never calls it -- the advance /
        # draw / stats pures take these values as
        # caller-supplied inputs and are unchanged.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_stack_router_per_def_stats_state', stack_router)
        self.assertIn('surgeRouter = new StackRouter("surge-router"){{', stack_router)
        self.assertIn('requirements(Category.distribution, with(Items.surgeAlloy, 5, Items.tungsten, 1));', stack_router)
        self.assertIn('health = 130;', stack_router)
        self.assertIn('speed = 6f;', stack_router)
        self.assertIn('public float speed = 5f;', stack_router)
        self.assertIn('itemCapacity = 10;', stack_router)
        self.assertIn('public int itemCapacity = 10;', stack_router)
        self.assertIn('public int size = 1;', stack_router)
        self.assertIn('public int health = -1;', stack_router)
        self.assertIn('public float scaledHealth = -1;', stack_router)
        self.assertIn('if(health == -1){', stack_router)
        self.assertIn('scaledHealth = 40;', stack_router)
        self.assertIn('Mathf.round(size * size * scaledHealth, 5)', stack_router)
        self.assertIn('public float glowAlpha = 1f;', stack_router)
        self.assertIn('public Color glowColor = Pal.redLight;', stack_router)
        self.assertIn('public ItemStack[] requirements = {};', stack_router)
        self.assertIn('public class StackRouter extends DuctRouter{', stack_router)
        self.assertIn('stats.add(Stat.itemsMoved, 60f / speed * itemCapacity, StatUnit.itemsSecond);', stack_router)
        # The def constants carry the surge-router
        # rows (speed / itemCapacity / glow
        # already exist since N2240 / N2433) and
        # the class constants carry the fallback
        # speed + the init-resolved fallback health.
        self.assertIn('SOURCE_STACK_ROUTER_SIZE := 1', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_SPEED := 6.0', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_ITEM_CAPACITY := 10', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_HEALTH := 130', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_GLOW_ALPHA := 1.0', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_GLOW_COLOR := "Pal.redLight"', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_CLASS_SPEED := 5.0', stack_router)
        self.assertIn('SOURCE_STACK_ROUTER_CLASS_HEALTH := 40', stack_router)
        # The documented limits record the per-def
        # stat rows as live, and the advance / draw
        # / stats pures are untouched (this slice
        # amends neither -- they keep taking the
        # values as caller-supplied inputs).
        self.assertIn('Per-def stat rows live (N2496)', stack_router)
        self.assertIn('static func source_stack_router_update_tile_advance_state', stack_router)
        self.assertIn('static func source_stack_router_draw_state', stack_router)
        self.assertIn('static func source_stack_router_stats_state', stack_router)
        # Pure-only: the driver NEVER calls the new
        # pure from the tick -- the only call-shaped
        # occurrence is its definition itself
        # (docstring mentions carry no parens).
        self.assertEqual(stack_router.count('source_stack_router_per_def_stats_state('), 1)
        # The proof's keys drive the pure (the
        # surge-router def row, the setStats
        # itemsMoved rate at the def vs the class
        # speed/capacity, the health + glow rows
        # feeding the N2433 draw pure, the
        # requirements dict, the class-default
        # fallback, and the def rows feeding the
        # N2240 advance as live inputs).
        proof = STACK_ROUTER_PER_DEF_STAT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_router',
            'stats_speed_capacity',
            'stats_health_glow',
            'stats_requirements',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist). Pure-only: the proof
        # never touches the live tick; the live-input keys
        # compose the N2442 stats + N2433 draw + N2240 advance
        # pures (their caller-supplied inputs come from this
        # pure's rows).
        self.assertIn('preload("res://src/game/SourceStackRouterBuildState.gd")', proof)
        self.assertIn('stack_router_build_state.source_stack_router_per_def_stats_state(', proof)
        self.assertIn('stack_router_build_state.source_stack_router_stats_state(', proof)
        self.assertIn('stack_router_build_state.source_stack_router_draw_state(', proof)
        self.assertIn('stack_router_build_state.source_stack_router_update_tile_advance_state(', proof)
        self.assertNotIn('source_stack_router_tick_buildings_state', proof)
        self.assertTrue(STACK_ROUTER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = STACK_ROUTER_PER_DEF_STAT_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07StackRouterPerDefStatRowsProof.gd', scene)
        self.assertIn('C07StackRouterPerDefStatRowsProof', scene)

    def test_reference_graph_and_actual_c07_stack_router_per_def_stat_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07StackRouterPerDefStatRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_STACK_ROUTER_PER_DEF_STAT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_router',
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
