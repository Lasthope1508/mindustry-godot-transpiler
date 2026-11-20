import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_ICONS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillIconsProof.gd'


class C07DrillIconsTests(unittest.TestCase):
    def test_c07_drill_icons_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2335']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_icons_state')
        # Drill.icons() (Drill.java:194-196,
        # `public TextureRegion[] icons(){`)
        # returns the three loaded regions in order
        # (`return new TextureRegion[]{region,
        # rotatorRegion, topRegion};` -- Drill.java:195).
        # region is the inherited block region (`public
        # TextureRegion region;` -- Block.java:427),
        # rotatorRegion is the Drill field (`public
        # @Load("@-rotator") TextureRegion rotatorRegion;`
        # -- Drill.java:72, loaded as name + "-rotator")
        # and topRegion is the Drill field (`public
        # @Load("@-top") TextureRegion topRegion;` --
        # Drill.java:73, loaded as name + "-top"). The
        # Block.icons() base (`protected TextureRegion[]
        # icons(){` -- Block.java:976-980, the variants /
        # teamRegion fold) is NOT this slice: Drill
        # overrides it, so only the override's return
        # array is pinned; the getGeneratedIcons cache
        # (`public TextureRegion[] getGeneratedIcons(){`
        # -- Block.java:986-988, `return generatedIcons
        # == null ? (generatedIcons = icons()) :
        # generatedIcons;`) is likewise deferred -- this
        # slice pins only the override's three-element
        # array, region first (the N2312 BurstDrill.icons
        # precedent, itself following the N2250
        # Radar.icons() precedent: "TextureRegion
        # internals and inherited region loading remain
        # deferred; explicit inputs carry region and
        # topRegion field values", pinned as the identity
        # pure function
        # source_tractor_beam_turret_icons_state).
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on
        # the same family file N2149 built:
        # source_drill_icons_state(region, rotator_region,
        # top_region) returning icons ([region,
        # rotator_region, top_region]). All three params
        # are explicit Variants (the N2312 precedent:
        # TextureRegion values ride as Variants; the
        # proof passes string region ids, as the N2312
        # proof did with ["impact-drill",
        # "impact-drill-top"]). (2) There is NO driver
        # tick line: icons() is a load-time region
        # accessor, not a per-tick write (the N2217
        # read/write + N2224 setStats lifecycle
        # precedent). One new result symbol: icons. Two
        # defs share the function (impact-drill,
        # Blocks.java:3070; eruption-drill,
        # Blocks.java:3093); they differ only in the
        # region name the caller passes. (3) This slice
        # does NOT touch Turret.icons() (N1159),
        # Radar.icons() (N2288) or BurstDrill.icons()
        # (N2312) -- each class owns its own icons().
        self.assertEqual(
            ledger['N2335']['source_symbols'],
            [
                'source_drill_icons_state_result.icons',
            ],
        )
        for name in ledger['N2335']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2335']['runtime_proof'], '/root/C07DrillIconsProof')
        self.assertEqual(
            ledger['N2335']['tests'],
            [
                'test_c07_drill_icons_registration',
                'test_all_c07_drill_icons_input_evidence_is_exact',
                'test_drill_icons_state',
                'test_reference_graph_and_actual_c07_drill_icons',
            ],
        )
        self.assertTrue(ledger['N2335']['deferred_exprs'])

    def test_all_c07_drill_icons_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2335']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2335']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_icons_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # Drill.icons() (Drill.java:194-196,
        # `public TextureRegion[] icons(){`):
        # `return new TextureRegion[]{region,
        # rotatorRegion, topRegion};` (:195) pins the
        # three-element array, region first. region is
        # the inherited block region (`public
        # TextureRegion region;`, Block.java:427);
        # rotatorRegion is the Drill field (`public
        # @Load("@-rotator") TextureRegion rotatorRegion;`,
        # Drill.java:72, loaded as name + "-rotator");
        # topRegion is the Drill field (`public
        # @Load("@-top") TextureRegion topRegion;`,
        # Drill.java:73, loaded as name + "-top"). The
        # Block.icons() base (`protected TextureRegion[]
        # icons(){`, Block.java:976-980) and the
        # getGeneratedIcons cache (Block.java:986-988)
        # are deferred -- only the override's return
        # array is pinned (the N2312 precedent). There
        # is NO driver tick line: icons() is a
        # load-time region accessor, not a per-tick
        # write (the N2217 / N2224 lifecycle precedent).
        self.assertIn('static func source_drill_icons_state(region: Variant, rotator_region: Variant, top_region: Variant) -> Dictionary:', burst_drill)
        self.assertIn('return {"icons": icons}', burst_drill)
        for expr in [
            '@Override',
            'public TextureRegion[] icons(){',
            'return new TextureRegion[]{region, rotatorRegion, topRegion};',
            'public @Load("@-rotator") TextureRegion rotatorRegion;',
            'public @Load("@-top") TextureRegion topRegion;',
            'public TextureRegion region;',
            'protected TextureRegion[] icons(){',
            'public TextureRegion[] getGeneratedIcons(){',
            'return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;',
            'public class Drill extends Block{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with the per-def region ids: impact-drill
        # ("impact-drill", "impact-drill-rotator",
        # "impact-drill-top") and eruption-drill
        # ("eruption-drill", "eruption-drill-rotator",
        # "eruption-drill-top") -- rotatorRegion loads
        # "@-rotator" and topRegion loads "@-top" (name +
        # suffix), region is the block's own region (the
        # block name); Blocks.java:3070/3093.
        proof = DRILL_ICONS_PROOF.read_text(encoding='utf-8')
        for key in [
            'icons_impact_drill',
            'icons_eruption_drill',
            'icons_length_three',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_icons(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillIconsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_ICONS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'icons_impact_drill',
            'icons_eruption_drill',
            'icons_length_three',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
