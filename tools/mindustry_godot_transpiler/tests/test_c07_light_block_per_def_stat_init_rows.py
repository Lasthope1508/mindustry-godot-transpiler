import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIGHT_BLOCK_STATE = ROOT / 'godot-mindustry/src/game/SourceLightBlockBuildState.gd'
LIGHT_BLOCK_PER_DEF_STAT_INIT_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockPerDefStatInitRowsProof.gd'
LIGHT_BLOCK_PER_DEF_STAT_INIT_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockPerDefStatInitRowsProof.tscn'


class C07LightBlockPerDefStatInitRowsTests(unittest.TestCase):
    def test_c07_light_block_per_def_stat_init_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2500']['godot_owner'], 'SourceLightBlockBuildState.source_light_block_per_def_stats_state')
        # The LightBlock tick is live (N2185 power +
        # N2189/N2241 smoothTime + N2374 draw +
        # N2439 drawPlace + N2443 config/color) but
        # NOTHING modeled the per-def stat rows or
        # the init rows as source-backed pures: the
        # illuminator def (Blocks.java:6763-6767)
        # sets brightness 0.75f, radius 140f and
        # requirements graphite 12 / silicon 8 /
        # lead 8, while the values only existed as
        # constants in the driver header comment,
        # and LightBlock.init() (LightBlock.java:39-43)
        # derives lightRadius = radius*2.5f,
        # lightClipSize = max(lightClipSize,
        # lightRadius * 3f) and emitLight = true,
        # which only existed as a comment in the
        # draw-light pure. N2500 ports them as TWO
        # pure-only pures (the N2304 / N2442 /
        # N2489 / N2490 verification-slice precedent
        # PLUS the init derivation, the N2427
        # multi-entry precedent): the def's rows for
        # illuminator, with the CLASS defaults (size
        # 1, brightness 0.9f, radius 200f, no
        # requirements) for an unknown def id (the
        # N2304 fallback precedent), and the init
        # derivation over a caller-supplied radius +
        # incoming lightClipSize. Seven new result
        # symbols: the stats size + brightness +
        # radius + requirements, the init light
        # radius + light clip size + emit light.
        self.assertEqual(
            ledger['N2500']['source_symbols'],
            [
                'source_light_block_per_def_stats_state_result.size',
                'source_light_block_per_def_stats_state_result.brightness',
                'source_light_block_per_def_stats_state_result.radius',
                'source_light_block_per_def_stats_state_result.requirements',
                'source_light_block_init_rows_state_result.light_radius',
                'source_light_block_init_rows_state_result.light_clip_size',
                'source_light_block_init_rows_state_result.emit_light',
            ],
        )
        expected_sources = {
            'source_light_block_per_def_stats_state_result.size': 'core/src/mindustry/world/Block.java',
            'source_light_block_per_def_stats_state_result.brightness': 'core/src/mindustry/content/Blocks.java',
            'source_light_block_per_def_stats_state_result.radius': 'core/src/mindustry/content/Blocks.java',
            'source_light_block_per_def_stats_state_result.requirements': 'core/src/mindustry/content/Blocks.java',
            'source_light_block_init_rows_state_result.light_radius': 'core/src/mindustry/world/blocks/power/LightBlock.java',
            'source_light_block_init_rows_state_result.light_clip_size': 'core/src/mindustry/world/blocks/power/LightBlock.java',
            'source_light_block_init_rows_state_result.emit_light': 'core/src/mindustry/world/blocks/power/LightBlock.java',
        }
        expected_owners = {
            'source_light_block_per_def_stats_state_result.size': 'SourceLightBlockBuildState.source_light_block_per_def_stats_state',
            'source_light_block_per_def_stats_state_result.brightness': 'SourceLightBlockBuildState.source_light_block_per_def_stats_state',
            'source_light_block_per_def_stats_state_result.radius': 'SourceLightBlockBuildState.source_light_block_per_def_stats_state',
            'source_light_block_per_def_stats_state_result.requirements': 'SourceLightBlockBuildState.source_light_block_per_def_stats_state',
            'source_light_block_init_rows_state_result.light_radius': 'SourceLightBlockBuildState.source_light_block_init_rows_state',
            'source_light_block_init_rows_state_result.light_clip_size': 'SourceLightBlockBuildState.source_light_block_init_rows_state',
            'source_light_block_init_rows_state_result.emit_light': 'SourceLightBlockBuildState.source_light_block_init_rows_state',
        }
        for name in ledger['N2500']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        self.assertEqual(ledger['N2500']['runtime_proof'], '/root/C07LightBlockPerDefStatInitRowsProof')
        self.assertEqual(
            ledger['N2500']['tests'],
            [
                'test_c07_light_block_per_def_stat_init_rows_registration',
                'test_all_c07_light_block_per_def_stat_init_rows_input_evidence_is_exact',
                'test_light_block_per_def_stat_init_rows_state',
                'test_reference_graph_and_actual_c07_light_block_per_def_stat_init_rows',
            ],
        )
        self.assertTrue(ledger['N2500']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #66 AND #63
        # (1-based in the merged advances-35 DEFERRED
        # base, 218 entries): the LightBlock per-def
        # stat rows entry AND the LightBlock init
        # rows entry are REMOVED -- size /
        # brightness / radius / requirements and
        # lightRadius / lightClipSize / emitLight
        # are live now as source-backed pures. Net
        # 218 - 2 = 216. The shouldConsume gate and
        # the read/write rows STAY.
        self.assertFalse(any(entry.startswith('LightBlock per-def stat rows (') for entry in ledger['N2500']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('LightBlock init rows (') for entry in ledger['N2500']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock shouldConsume gate ') for entry in ledger['N2500']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock read/write rows (') for entry in ledger['N2500']['deferred_exprs']))
        self.assertEqual(len(ledger['N2500']['deferred_exprs']), 216)

    def test_all_c07_light_block_per_def_stat_init_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2500']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceLightBlockBuildState.source_light_block_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/power/LightBlock.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2500']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_light_block_per_def_stat_init_rows_state(self):
        light_block = LIGHT_BLOCK_STATE.read_text(encoding='utf-8')
        # The per-def stat rows (the VERIFICATION slice:
        # the values are already constants in the driver
        # header -- the N2304 / N2442 / N2489 / N2490
        # precedent): the single LightBlock def
        # illuminator (Blocks.java:6763-6767) sets
        # brightness 0.75f, radius 140f and
        # requirements graphite 12 / silicon 8 /
        # lead 8. The def sets NO size line, so size
        # 1 is the inherited Block class default
        # (`public int size = 1;`, Block.java:215 --
        # the N2494 precedent: the size symbol cites
        # Block.java, not the def block). An unknown
        # def id falls back to the CLASS defaults
        # (the N2304 fallback precedent): size 1
        # (Block.java:215), brightness 0.9f
        # (LightBlock.java:22), radius 200f
        # (LightBlock.java:23) and NO requirements
        # (the Block default is the empty array,
        # Block.java:356). The requirements dict is
        # the {item: amount} dict from the def (the
        # N2490 precedent); the catalog carries the
        # same rows as an Array of {item, amount}
        # dicts (content_registry.json, illuminator)
        # but NO size / brightness / radius keys --
        # those values come from Java only. The
        # requirements call carries
        # BuildVisibility.lightingOnly -- recorded,
        # NOT modeled (visibility is not modeled).
        # The init rows (LightBlock.init(),
        # LightBlock.java:39-43): lightRadius =
        # radius*2.5f (:40), lightClipSize =
        # Math.max(lightClipSize, lightRadius * 3f)
        # (:41), emitLight = true (:42). The pure
        # takes the incoming lightClipSize as a
        # caller-supplied input (a fresh block reads
        # 0f -- the field is uninitialized,
        # Block.java:223). Pure-only: the caller
        # reads them; the existing pures are
        # unchanged.
        # Keep each Java expr on ONE comment line (the
        # N2148 lesson: a split line fails this test).
        self.assertIn('static func source_light_block_per_def_stats_state', light_block)
        self.assertIn('static func source_light_block_init_rows_state', light_block)
        self.assertIn('illuminator = new LightBlock("illuminator"){{', light_block)
        self.assertIn('requirements(Category.effect, BuildVisibility.lightingOnly, with(Items.graphite, 12, Items.silicon, 8, Items.lead, 8));', light_block)
        self.assertIn('brightness = 0.75f;', light_block)
        self.assertIn('radius = 140f;', light_block)
        self.assertIn('public float brightness = 0.9f;', light_block)
        self.assertIn('public float radius = 200f;', light_block)
        self.assertIn('public int size = 1;', light_block)
        self.assertIn('public ItemStack[] requirements = {};', light_block)
        self.assertIn('public class LightBlock extends Block{', light_block)
        self.assertIn('lightRadius = radius*2.5f;', light_block)
        self.assertIn('lightClipSize = Math.max(lightClipSize, lightRadius * 3f);', light_block)
        self.assertIn('emitLight = true;', light_block)
        self.assertIn('public float lightClipSize;', light_block)
        # The documented limits record the per-def stat
        # rows and the init rows as live.
        self.assertIn('Per-def stat rows live (N2500)', light_block)
        self.assertIn('Init rows live (N2500)', light_block)
        # The proof's keys drive both pures (the
        # illuminator def row, the brightness +
        # radius at the def vs the class, the
        # requirements dict, the init derivation at
        # the def + class radii, the class fallback
        # for an unknown def id, and the def rows
        # feeding the init pure as live inputs).
        proof = LIGHT_BLOCK_PER_DEF_STAT_INIT_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'stats_block',
            'stats_brightness_radius',
            'stats_requirements',
            'stats_init_derived',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceLightBlockBuildState.gd")', proof)
        self.assertTrue(LIGHT_BLOCK_STATE.exists())
        self.assertTrue(LIGHT_BLOCK_PER_DEF_STAT_INIT_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07LightBlockPerDefStatInitRowsProof.gd', LIGHT_BLOCK_PER_DEF_STAT_INIT_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_light_block_per_def_stat_init_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LightBlockPerDefStatInitRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIGHT_BLOCK_PER_DEF_STAT_INIT_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stats_block',
            'stats_brightness_radius',
            'stats_requirements',
            'stats_init_derived',
            'stats_class_fallback',
            'stats_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
