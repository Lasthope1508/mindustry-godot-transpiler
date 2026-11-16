import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
MASS_DRIVER_LINK_CONFIG_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverLinkConfigRowsProof.gd'
MASS_DRIVER_LINK_CONFIG_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverLinkConfigRowsProof.tscn'


class C07MassDriverLinkConfigRowsTests(unittest.TestCase):
    def test_c07_mass_driver_link_config_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2461']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_link_valid_state')
        # The MassDriver tick is live (N2237 updateTile
        # advance + N2294 dumpAccumulate + N2336
        # acceptItem gate + N2392 sense + N2396 draw
        # rows + N2406 dump neighbour live fill) but
        # NOTHING modeled the link/config rows:
        # linkValid() (MassDriver.java:346-349),
        # config(Point2) (:58, the RELATIVE point2
        # packed against the tile) / config(Integer)
        # (:59, the absolute packed int), config()
        # (:352-355, the relative Point2, null when
        # tile == null) and onConfigureBuildTapped
        # (:266-282, self / unlink / link / reject).
        # N2461 ports them as THREE pure-only pures
        # (the N2460 mirror): link_valid (1 key),
        # config (2 keys) and configure_tapped (3
        # keys). Six new result symbols.
        self.assertEqual(
            ledger['N2461']['source_symbols'],
            [
                'source_mass_driver_link_valid_state_result.link_valid',
                'source_mass_driver_config_state_result.link',
                'source_mass_driver_config_state_result.config_value',
                'source_mass_driver_configure_tapped_state_result.link_after',
                'source_mass_driver_configure_tapped_state_result.deselect_called',
                'source_mass_driver_configure_tapped_state_result.handled',
            ],
        )
        expected_sources = {
            'source_mass_driver_link_valid_state_result.link_valid': 'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'source_mass_driver_config_state_result.link': 'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'source_mass_driver_config_state_result.config_value': 'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'source_mass_driver_configure_tapped_state_result.link_after': 'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'source_mass_driver_configure_tapped_state_result.deselect_called': 'core/src/mindustry/world/blocks/distribution/MassDriver.java',
            'source_mass_driver_configure_tapped_state_result.handled': 'core/src/mindustry/world/blocks/distribution/MassDriver.java',
        }
        for name in ledger['N2461']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceMassDriverBuildState.source_mass_driver_'))
        self.assertEqual(ledger['N2461']['runtime_proof'], '/root/C07MassDriverLinkConfigRowsProof')
        self.assertEqual(
            ledger['N2461']['tests'],
            [
                'test_c07_mass_driver_link_config_rows_registration',
                'test_all_c07_mass_driver_link_config_rows_input_evidence_is_exact',
                'test_mass_driver_link_config_rows_state',
                'test_reference_graph_and_actual_c07_mass_driver_link_config_rows',
            ],
        )
        self.assertTrue(ledger['N2461']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #34 (1-based in
        # the merged advances-29 DEFERRED base): the
        # MassDriver link/config rows entry is
        # REMOVED -- linkValid, config(Point2) /
        # config(Integer), config() and
        # onConfigureBuildTapped are all live now.
        # Net 253 - 1 = 252. The handlePayload entry
        # STAYS. shooterValid needs NO new entry: it
        # is already ported as the private
        # _mass_driver_shooter_valid helper, live in
        # the N2237 tick since N2237.
        self.assertFalse(any(entry.startswith('MassDriver link/config rows (') for entry in ledger['N2461']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver handlePayload / receive rows (') for entry in ledger['N2461']['deferred_exprs']))
        self.assertEqual(len(ledger['N2461']['deferred_exprs']), 252)

    def test_all_c07_mass_driver_link_config_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2461']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceMassDriverBuildState.source_mass_driver_'))
        slice_sources = [
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/distribution/MassDriver.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Tile.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Point2.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Position.java'),
        ]
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2461']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_link_config_rows_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The link/config rows (MassDriver linkValid,
        # MassDriver.java:346-349; config(Point2),
        # :58; config(Integer), :59; config(),
        # :352-355; onConfigureBuildTapped, :266-282).
        # The link is a PACKED INT (not a Vector2i):
        # config(Point2) packs the RELATIVE point
        # against the tile (point.x + tile.tileX(),
        # point.y + tile.tileY()), config(Integer)
        # takes the absolute packed int, config()
        # returns unpack(link) - tile (null when
        # tile == null). linkValid is link != -1 AND
        # the linked build is a MassDriverBuild of
        # the same block + team + within(range) --
        # within is STRICT dst2 < range*range
        # (Position.java:44-46, pixels, range 440f).
        # onConfigureBuildTapped: self -> deselect
        # iff link == -1 + configure(-1) + return
        # false; link == other.pos() -> configure(-1)
        # + return false; block + other.dst(tile) <=
        # range + team -> configure(other.pos()) +
        # return false; else return true. NOTE the
        # tap range check is dst <= range INCLUSIVE,
        # NOT within's strict < (the (c)
        # verification: other.dst(tile) vs within
        # are DIFFERENT metrics). The pure names the
        # key `handled` = NOT the Java return (Java
        # returns false = handled, don't propagate).
        # unpack(-1) is Point2(-1, -1) (the (short)
        # casts, Point2.java:35-37), so a cleared
        # link reads config_value (-1 - tx, -1 - ty).
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_mass_driver_link_valid_state', mass_driver)
        self.assertIn('static func source_mass_driver_config_state', mass_driver)
        self.assertIn('static func source_mass_driver_configure_tapped_state', mass_driver)
        self.assertIn('config(Point2.class, (MassDriverBuild tile, Point2 point) -> tile.link = Point2.pack(point.x + tile.tileX(), point.y + tile.tileY()));', mass_driver)
        self.assertIn('config(Integer.class, (MassDriverBuild tile, Integer point) -> tile.link = point);', mass_driver)
        self.assertIn('public boolean onConfigureBuildTapped(Building other){', mass_driver)
        self.assertIn('if(this == other){', mass_driver)
        self.assertIn('if(link == -1) deselect();', mass_driver)
        self.assertIn('configure(-1);', mass_driver)
        self.assertIn('if(link == other.pos()){', mass_driver)
        self.assertIn('}else if(other.block == block && other.dst(tile) <= range && other.team == team){', mass_driver)
        self.assertIn('configure(other.pos());', mass_driver)
        self.assertIn('return true;', mass_driver)
        self.assertIn('return false;', mass_driver)
        self.assertIn('protected boolean linkValid(){', mass_driver)
        self.assertIn('if(link == -1) return false;', mass_driver)
        self.assertIn('return world.build(this.link) instanceof MassDriverBuild other && other.block == block && other.team == team && within(other, range);', mass_driver)
        self.assertIn('public Point2 config(){', mass_driver)
        self.assertIn('if(tile == null) return null;', mass_driver)
        self.assertIn('return Point2.unpack(link).sub(tile.x, tile.y);', mass_driver)
        self.assertIn('public int link = -1;', mass_driver)
        self.assertIn('public class MassDriverBuild extends Building implements RotBlock{', mass_driver)
        self.assertIn('public float range;', mass_driver)
        self.assertIn('return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));', mass_driver)
        self.assertIn('return (((short)x) << 16) | (((short)y) & 0xFFFF);', mass_driver)
        self.assertIn('default boolean within(Position other, float dst){', mass_driver)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', mass_driver)
        self.assertIn('return Point2.pack(x, y);', mass_driver)
        self.assertIn('public void deselect(){', mass_driver)
        self.assertIn('public int pos(){', mass_driver)
        self.assertIn('range = 440f;', mass_driver)
        # The documented limits record the link/config
        # rows as live.
        self.assertIn('Link/config rows live (N2461)', mass_driver)
        # The proof's keys drive the pures (link_valid
        # true / -1 / range, config point2-relative /
        # integer + clear + none, the tapped branches
        # incl. the inclusive dst <= range boundary).
        proof = MASS_DRIVER_LINK_CONFIG_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'link_valid_true',
            'link_valid_minus_one',
            'link_valid_range',
            'config_point2_relative',
            'config_integer',
            'tapped_link',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceMassDriverBuildState.gd")', proof)
        self.assertTrue(MASS_DRIVER_STATE.exists())
        self.assertTrue(MASS_DRIVER_LINK_CONFIG_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07MassDriverLinkConfigRowsProof.gd', MASS_DRIVER_LINK_CONFIG_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_mass_driver_link_config_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverLinkConfigRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_LINK_CONFIG_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'link_valid_true',
            'link_valid_minus_one',
            'link_valid_range',
            'config_point2_relative',
            'config_integer',
            'tapped_link',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
