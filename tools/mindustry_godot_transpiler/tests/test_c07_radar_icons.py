import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_ICONS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarIconsProof.gd'


class C07RadarIconsTests(unittest.TestCase):
    def test_c07_radar_icons_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2288']['godot_owner'], 'SourceRadarBuildState.source_radar_icons_state')
        # Radar.icons() (Radar.java:36-39,
        # `@Override public TextureRegion[] icons(){`)
        # returns the two loaded regions in order
        # (`return new TextureRegion[]{baseRegion, region};`
        # -- Radar.java:38). baseRegion is the
        # block's own base field (`public @Load("@-base")
        # TextureRegion baseRegion;` -- Radar.java:21) and
        # region is the inherited block region (`public
        # TextureRegion region;` -- Block.java:427). The
        # Block.icons() base (`protected TextureRegion[]
        # icons(){` -- Block.java:976-980, the
        # variants/teamRegion fold) is NOT this slice:
        # Radar overrides it, so only the override's
        # return array is pinned; the getGeneratedIcons
        # cache (`public TextureRegion[]
        # getGeneratedIcons(){` -- Block.java:986-988,
        # `return generatedIcons == null ? (generatedIcons
        # = icons()) : generatedIcons;`) is likewise
        # deferred -- this slice pins only the override's
        # two-element array, base first (the N2227
        # RepairTurret.icons() precedent, itself following
        # the N1232 TractorBeamTurret.icons() precedent:
        # "TextureRegion internals and inherited region
        # loading remain deferred; explicit inputs carry
        # baseRegion and region field values", pinned as
        # the identity pure function
        # source_tractor_beam_turret_icons_state).
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on
        # the same family file N2173 built:
        # source_radar_icons_state(base_region, region)
        # returning icons ([base_region, region]).
        # Both params are explicit Variants (the N2227
        # precedent: TextureRegion values ride as Variants;
        # the proof passes string region ids, as the N2227
        # proof did with ["repair-point-base",
        # "repair-point"]). (2) There is NO driver tick
        # line: icons() is a load-time region accessor,
        # not a per-tick write (the N2217 read/write +
        # N2224 setStats lifecycle precedent). One new
        # result symbol: icons.
        self.assertEqual(
            ledger['N2288']['source_symbols'],
            [
                'source_radar_icons_state_result.icons',
            ],
        )
        for name in ledger['N2288']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2288']['runtime_proof'], '/root/C07RadarIconsProof')
        self.assertEqual(
            ledger['N2288']['tests'],
            [
                'test_c07_radar_icons_registration',
                'test_all_c07_radar_icons_input_evidence_is_exact',
                'test_radar_icons_state',
                'test_reference_graph_and_actual_c07_radar_icons',
            ],
        )
        self.assertTrue(ledger['N2288']['deferred_exprs'])

    def test_all_c07_radar_icons_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2288']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2288']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_icons_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # Radar.icons() (Radar.java:36-39,
        # `@Override public TextureRegion[] icons(){`):
        # `return new TextureRegion[]{baseRegion, region};`
        # (:38) pins the two-element array, base first.
        # baseRegion is the block's own base field
        # (`public @Load("@-base") TextureRegion
        # baseRegion;`, Radar.java:21); region is the
        # inherited block region (`public TextureRegion
        # region;`, Block.java:427). The Block.icons() base
        # (`protected TextureRegion[] icons(){`,
        # Block.java:976-980) and the getGeneratedIcons
        # cache (Block.java:986-988) are deferred -- only
        # the override's return array is pinned (the N2227
        # precedent). There is NO driver tick line: icons()
        # is a load-time region accessor, not a per-tick
        # write (the N2217 / N2224 lifecycle precedent).
        self.assertIn('static func source_radar_icons_state(base_region: Variant, region: Variant) -> Dictionary:', radar)
        self.assertIn('return {"icons": icons}', radar)
        for expr in [
            '@Override',
            'public TextureRegion[] icons(){',
            'return new TextureRegion[]{baseRegion, region};',
            'public @Load("@-base") TextureRegion baseRegion;',
            'public TextureRegion region;',
            'protected TextureRegion[] icons(){',
            'public TextureRegion[] getGeneratedIcons(){',
            'return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;',
            'public class Radar extends Block{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive the pure function directly
        # with the per-def region ids: radar ("radar-base",
        # "radar") -- baseRegion loads "@-base" (name +
        # "-base"), region is the block's own region (the
        # block name); Blocks.java:1988.
        proof = RADAR_ICONS_PROOF.read_text(encoding='utf-8')
        for key in [
            'icons_radar',
            'icons_length_two',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_icons(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarIconsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_ICONS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'icons_radar',
            'icons_length_two',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
