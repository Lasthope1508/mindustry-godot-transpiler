import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_ICONS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillIconsProof.gd'


class C07BurstDrillIconsTests(unittest.TestCase):
    def test_c07_burst_drill_icons_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2312']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_icons_state')
        # BurstDrill.icons() (BurstDrill.java:48-50,
        # `@Override public TextureRegion[] icons(){`)
        # returns the two loaded regions in order
        # (`return new TextureRegion[]{region, topRegion};`
        # -- BurstDrill.java:50). region is the inherited
        # block region (`public TextureRegion region;` --
        # Block.java:427) and topRegion is the Drill base
        # field (`public @Load("@-top") TextureRegion
        # topRegion;` -- Drill.java:73, loaded as name +
        # "-top"). The Block.icons() base (`protected
        # TextureRegion[] icons(){` -- Block.java:976-980,
        # the variants/teamRegion fold) is NOT this slice:
        # BurstDrill overrides it, so only the override's
        # return array is pinned; the getGeneratedIcons
        # cache (`public TextureRegion[]
        # getGeneratedIcons(){` -- Block.java:986-988,
        # `return generatedIcons == null ? (generatedIcons
        # = icons()) : generatedIcons;`) is likewise
        # deferred -- this slice pins only the override's
        # two-element array, region first (the N2250
        # Radar.icons() precedent, itself following the
        # N2227 RepairTurret.icons() precedent: "TextureRegion
        # internals and inherited region loading remain
        # deferred; explicit inputs carry region and
        # topRegion field values", pinned as the identity
        # pure function
        # source_tractor_beam_turret_icons_state).
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on
        # the same family file N2149 built:
        # source_burst_drill_icons_state(region,
        # top_region) returning icons ([region,
        # top_region]). Both params are explicit Variants
        # (the N2250 precedent: TextureRegion values ride
        # as Variants; the proof passes string region ids,
        # as the N2250 proof did with ["radar-base",
        # "radar"]). (2) There is NO driver tick line:
        # icons() is a load-time region accessor, not a
        # per-tick write (the N2217 read/write + N2224
        # setStats lifecycle precedent). One new result
        # symbol: icons. Two defs share the function
        # (impact-drill, Blocks.java:3070; eruption-drill,
        # Blocks.java:3093); they differ only in the
        # region name the caller passes.
        self.assertEqual(
            ledger['N2312']['source_symbols'],
            [
                'source_burst_drill_icons_state_result.icons',
            ],
        )
        for name in ledger['N2312']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2312']['runtime_proof'], '/root/C07BurstDrillIconsProof')
        self.assertEqual(
            ledger['N2312']['tests'],
            [
                'test_c07_burst_drill_icons_registration',
                'test_all_c07_burst_drill_icons_input_evidence_is_exact',
                'test_burst_drill_icons_state',
                'test_reference_graph_and_actual_c07_burst_drill_icons',
            ],
        )
        self.assertTrue(ledger['N2312']['deferred_exprs'])

    def test_all_c07_burst_drill_icons_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2312']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2312']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_icons_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # BurstDrill.icons() (BurstDrill.java:48-50,
        # `@Override public TextureRegion[] icons(){`):
        # `return new TextureRegion[]{region, topRegion};`
        # (:50) pins the two-element array, region first.
        # region is the inherited block region (`public
        # TextureRegion region;`, Block.java:427); topRegion
        # is the Drill base field (`public @Load("@-top")
        # TextureRegion topRegion;`, Drill.java:73, loaded
        # as name + "-top"). The Block.icons() base
        # (`protected TextureRegion[] icons(){`,
        # Block.java:976-980) and the getGeneratedIcons
        # cache (Block.java:986-988) are deferred -- only
        # the override's return array is pinned (the N2250
        # precedent). There is NO driver tick line: icons()
        # is a load-time region accessor, not a per-tick
        # write (the N2217 / N2224 lifecycle precedent).
        self.assertIn('static func source_burst_drill_icons_state(region: Variant, top_region: Variant) -> Dictionary:', burst_drill)
        self.assertIn('return {"icons": icons}', burst_drill)
        for expr in [
            '@Override',
            'public TextureRegion[] icons(){',
            'return new TextureRegion[]{region, topRegion};',
            'public @Load("@-top") TextureRegion topRegion;',
            'public TextureRegion region;',
            'protected TextureRegion[] icons(){',
            'public TextureRegion[] getGeneratedIcons(){',
            'return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;',
            'public class BurstDrill extends Drill{',
            'public class Drill extends Block{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with the per-def region ids: impact-drill
        # ("impact-drill", "impact-drill-top") and
        # eruption-drill ("eruption-drill",
        # "eruption-drill-top") -- topRegion loads "@-top"
        # (name + "-top"), region is the block's own region
        # (the block name); Blocks.java:3070/3093.
        proof = BURST_DRILL_ICONS_PROOF.read_text(encoding='utf-8')
        for key in [
            'icons_impact_drill',
            'icons_eruption_drill',
            'icons_length_two',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_icons(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillIconsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_ICONS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'icons_impact_drill',
            'icons_eruption_drill',
            'icons_length_two',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
