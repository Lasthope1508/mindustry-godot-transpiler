import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_LIQUID_ROW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadLiquidRowProof.gd'
LAUNCH_PAD_LIQUID_ROW_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadLiquidRowProof.tscn'


class C07LaunchPadLiquidRowTests(unittest.TestCase):
    def test_c07_launch_pad_liquid_row_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2253']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_liquid_consumer_row_state')
        # N2172 proved the launch pad's pure power row, N2186 its
        # shouldConsume gate and N2238 its updateTile advance --
        # but the folded efficiency was still the min over the
        # power row alone: the advanced-launch-pad also consumes
        # liquid oil (9f/60f, Blocks.java:6808), a required
        # ConsumeLiquid, so a starved advanced pad kept launching
        # as if its oil tank were full. N2253 is the liquid row:
        # a pure ConsumeLiquid.efficiency row (ConsumeLiquid.java:
        # 42-47) folded into the first pass beside the power row,
        # with the second-pass removal (ConsumeLiquid.java:37-39)
        # after the fold. ONLY the advanced def has the row -- the
        # plain launch-pad has no liquid consumer at all
        # (Blocks.java:6790-6797), so its row is absent (mirror
        # the has_power_row pattern). Two new result symbols: the
        # row and its presence flag.
        self.assertEqual(
            ledger['N2253']['source_symbols'],
            [
                'source_launch_pad_liquid_consumer_row_state_result.row',
                'source_launch_pad_liquid_consumer_row_state_result.has_liquid_row',
            ],
        )
        for name in ledger['N2253']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumeLiquid.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_liquid_consumer_row_state_result.row': 'SourceLaunchPadBuildState.source_launch_pad_liquid_consumer_row_state',
                    'source_launch_pad_liquid_consumer_row_state_result.has_liquid_row': 'SourceLaunchPadBuildState.source_launch_pad_liquid_consumer_row_state',
                }[name])
        self.assertEqual(ledger['N2253']['runtime_proof'], '/root/C07LaunchPadLiquidRowProof')
        self.assertEqual(
            ledger['N2253']['tests'],
            [
                'test_c07_launch_pad_liquid_row_registration',
                'test_all_c07_launch_pad_liquid_row_input_evidence_is_exact',
                'test_launch_pad_liquid_row_state',
                'test_reference_graph_and_actual_c07_launch_pad_liquid_row',
            ],
        )
        self.assertTrue(ledger['N2253']['deferred_exprs'])

    def test_all_c07_launch_pad_liquid_row_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2253']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_launch_pad_liquid_consumer_row_state_result.row': 'SourceLaunchPadBuildState.source_launch_pad_liquid_consumer_row_state',
                    'source_launch_pad_liquid_consumer_row_state_result.has_liquid_row': 'SourceLaunchPadBuildState.source_launch_pad_liquid_consumer_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2253']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_liquid_row_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The pure liquid row lives on the launch pad build state:
        # ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47) over
        # the frame liquids store, folded by the first pass
        # (BuildingComp.java:1969-1976) into the min efficiency
        # beside the power row; a starved row folds below one, a
        # full row caps at one, and ed <= 1e-8 zeroes it. The
        # liquid amount comes from the shared liquid module helper
        # (SourceLiquidModuleState.source_get_state) with the
        # Fracker guard (frame liquids dict + bounds check), so a
        # frame with no store reads 0.0 -- Java's liquids.get
        # returns 0.0 for a liquid never added
        # (LiquidModule.java:102-104). The multiplier defaults to
        # 1f (Consume.java:18); the advanced def sets none.
        self.assertIn('static func source_launch_pad_liquid_consumer_row_state', launch_pad)
        self.assertIn('float ed = build.edelta() * build.efficiencyScale();', launch_pad)
        self.assertIn('if(ed <= 0.00000001f) return 0f;', launch_pad)
        self.assertIn('return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);', launch_pad)
        self.assertIn('build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));', launch_pad)
        self.assertIn('consumeLiquid(Liquids.oil, 9f/60f);', launch_pad)
        self.assertIn('public Floatf<Building> multiplier = b -> 1f;', launch_pad)
        self.assertIn('public float get(Liquid liquid){', launch_pad)
        self.assertIn('public void remove(Liquid liquid, float amount){', launch_pad)
        # The liquid row is a non-power required row: is_power
        # false, so the fold sets shouldConsumePower=false when
        # the row is starved (BuildingComp.java:1972-1973,
        # `if(cons != block.consPower && result <= 0.0000001f){`).
        # The driver detects the consumer from the catalog
        # consumeLiquid row (advanced-launch-pad only: amount
        # 0.15 = 9f/60f, liquid oil) and resolves the oil id from
        # the liquid catalog; the plain launch-pad has no
        # consumeLiquid row, so its liquid row is absent.
        self.assertIn('"is_power": false', launch_pad)
        self.assertIn('block.properties.get("consumeLiquid", [])', launch_pad)
        self.assertIn('source_liquid_catalog_state', launch_pad)
        self.assertIn('liquid_id_by_name', launch_pad)
        # The tick syncs the live liquids store from the sprite
        # meta into the frame BEFORE the fold (the Fracker:327
        # precedent), the fresh frame carries an empty liquids
        # store, and the second-pass removal runs after the fold
        # through the shared liquid module helper (the
        # PayloadLoader cache_sums precedent) -- direct removal,
        # not the updates array: the machinery's second pass only
        # records update consumers, it never calls update on them.
        self.assertIn('frame["liquids"] = sprite.get_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})', launch_pad)
        self.assertIn('"liquids": {}', launch_pad)
        self.assertIn('source_get_state', launch_pad)
        self.assertIn('source_remove_state', launch_pad)
        self.assertIn('cache_sums', launch_pad)
        # The power row's documented limits now record the live
        # liquid row (def + amount + cite) instead of deferring it.
        self.assertIn('Liquid consumer row LIVE (N2253)', launch_pad)
        # The proof file exists, its scene points at it, and it
        # carries the pure-row keys (starved / full / edelta-zero /
        # no-liquid / absent-for-plain-def) plus the live-tick keys
        # (fold + removal) and the catalog key.
        self.assertTrue(LAUNCH_PAD_LIQUID_ROW_PROOF.is_file())
        self.assertTrue(LAUNCH_PAD_LIQUID_ROW_PROOF_SCENE.is_file())
        self.assertIn('C07LaunchPadLiquidRowProof.gd', LAUNCH_PAD_LIQUID_ROW_PROOF_SCENE.read_text(encoding='utf-8'))
        proof = LAUNCH_PAD_LIQUID_ROW_PROOF.read_text(encoding='utf-8')
        self.assertIn('SourceLaunchPadBuildState.gd', proof)
        for key in [
            'advanced_pad_has_oil_consumer',
            'row_folds_below_one_when_starved',
            'row_caps_at_one_when_full',
            'row_zeroes_when_edelta_zero',
            'row_zeroes_without_liquid',
            'row_absent_for_plain_launch_pad',
            'live_tick_folds_liquid_row',
            'live_tick_removes_liquid_when_running',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_launch_pad_liquid_row(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadLiquidRowProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_LIQUID_ROW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advanced_pad_has_oil_consumer',
            'row_folds_below_one_when_starved',
            'row_caps_at_one_when_full',
            'row_zeroes_when_edelta_zero',
            'row_zeroes_without_liquid',
            'row_absent_for_plain_launch_pad',
            'live_tick_folds_liquid_row',
            'live_tick_removes_liquid_when_running',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
