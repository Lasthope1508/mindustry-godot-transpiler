import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_ICONS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretIconsProof.gd'


class C07RepairTurretIconsTests(unittest.TestCase):
    def test_c07_repair_turret_icons_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2227']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_icons_state')
        # RepairTurret.icons() (RepairTurret.java:101-104,
        # `@Override public TextureRegion[] icons(){`)
        # returns the two loaded regions in order
        # (`return new TextureRegion[]{baseRegion, region};`
        # -- RepairTurret.java:103). baseRegion is the
        # block's own base field (`public @Load(value =
        # "@-base", fallback = "block-@size") TextureRegion
        # baseRegion;` -- RepairTurret.java:47) and region
        # is the inherited block region (`public
        # TextureRegion region;` -- Block.java:427). The
        # Block.icons() base (`protected TextureRegion[]
        # icons(){` -- Block.java:976-980, the
        # variants/teamRegion fold) is NOT this slice:
        # RepairTurret overrides it, so only the override's
        # return array is pinned; the getGeneratedIcons
        # cache (`public TextureRegion[]
        # getGeneratedIcons(){` -- Block.java:986-988,
        # `return generatedIcons == null ? (generatedIcons
        # = icons()) : generatedIcons;`) is likewise
        # deferred -- this slice pins only the override's
        # two-element array, base first (the N1232
        # TractorBeamTurret.icons() precedent: "TextureRegion
        # internals and inherited region loading remain
        # deferred; explicit inputs carry baseRegion and
        # region field values", pinned as the identity pure
        # function source_tractor_beam_turret_icons_state).
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on
        # the same family file N2174 / N2188 / N2209 /
        # N2212-N2215 / N2217 / N2219-N2226 built:
        # source_repair_turret_icons_state(base_region,
        # region) returning icons ([base_region, region]).
        # Both params are explicit Variants (the N1232
        # precedent: TextureRegion values ride as Variants;
        # the proof passes string region ids, as the N1232
        # proof did with ["tractor-base", "tractor-top"]).
        # (2) There is NO driver tick line: icons() is a
        # load-time region accessor, not a per-tick write
        # (the N2217 read/write + N2224 setStats lifecycle
        # precedent). One new result symbol: icons.
        self.assertEqual(
            ledger['N2227']['source_symbols'],
            [
                'source_repair_turret_icons_state_result.icons',
            ],
        )
        for name in ledger['N2227']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2227']['runtime_proof'], '/root/C07RepairTurretIconsProof')
        self.assertEqual(
            ledger['N2227']['tests'],
            [
                'test_c07_repair_turret_icons_registration',
                'test_all_c07_repair_turret_icons_input_evidence_is_exact',
                'test_repair_turret_icons_state',
                'test_reference_graph_and_actual_c07_repair_turret_icons',
            ],
        )
        self.assertTrue(ledger['N2227']['deferred_exprs'])

    def test_all_c07_repair_turret_icons_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2227']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2227']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_icons_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairTurret.icons() (RepairTurret.java:101-104,
        # `@Override public TextureRegion[] icons(){`):
        # `return new TextureRegion[]{baseRegion, region};`
        # (:103) pins the two-element array, base first.
        # baseRegion is the block's own base field
        # (`public @Load(value = "@-base", fallback =
        # "block-@size") TextureRegion baseRegion;`,
        # RepairTurret.java:47); region is the inherited
        # block region (`public TextureRegion region;`,
        # Block.java:427). The Block.icons() base
        # (`protected TextureRegion[] icons(){`,
        # Block.java:976-980) and the getGeneratedIcons
        # cache (Block.java:986-988) are deferred -- only
        # the override's return array is pinned (the N1232
        # precedent). There is NO driver tick line: icons()
        # is a load-time region accessor, not a per-tick
        # write (the N2217 / N2224 lifecycle precedent).
        self.assertIn('static func source_repair_turret_icons_state(base_region: Variant, region: Variant) -> Dictionary:', repair_turret)
        self.assertIn('return {"icons": icons}', repair_turret)
        for expr in [
            '@Override',
            'public TextureRegion[] icons(){',
            'return new TextureRegion[]{baseRegion, region};',
            'public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;',
            'public TextureRegion region;',
            'protected TextureRegion[] icons(){',
            'public TextureRegion[] getGeneratedIcons(){',
            'return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;',
            'public class RepairTurret extends Block{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function directly
        # with the per-def region ids: repair-point
        # ("repair-point-base", "repair-point") and
        # repair-turret ("repair-turret-base",
        # "repair-turret") -- baseRegion loads "@-base"
        # (name + "-base"), region is the block's own
        # region (the block name); Blocks.java:6386, :6396.
        proof = REPAIR_TURRET_ICONS_PROOF.read_text(encoding='utf-8')
        for key in [
            'icons_repair_point',
            'icons_repair_turret',
            'icons_length_two',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_icons(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretIconsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_ICONS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'icons_repair_point',
            'icons_repair_turret',
            'icons_length_two',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
