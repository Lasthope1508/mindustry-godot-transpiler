import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
LIQUID_BRIDGE_LINK_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeLinkRowsProof.gd'
LIQUID_BRIDGE_LINK_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeLinkRowsProof.tscn'


class C07LiquidBridgeLinkRowsTests(unittest.TestCase):
    def test_c07_liquid_bridge_link_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2463']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_link_valid_state')
        # The LiquidBridge tick is live (N2198 shouldConsume
        # gate + N2275 updateTransport advance + N2287
        # doDump + N2379 dump neighbour write-back +
        # N2412 dodump neighbour live fill) but NOTHING
        # modeled the link/findLink/linkValid rows as
        # LiquidBridge-driver pures: linkValid()
        # (ItemBridge.java:145-155, inherited --
        # LiquidBridge overrides NOTHING here,
        # LiquidBridge.java is 33 lines and overrides
        # only updateTransport / doDump), findLink()
        # (:167-173, the lastBuild autolink), config
        # (Point2) (:64, the RELATIVE point2 packed
        # against the tile) / config(Integer) (:66,
        # the absolute packed int) and config()
        # (:500-501, the relative Point2). N2463 ports
        # them as THREE pure-only pures (the N2460 /
        # N2461 mirror): link_valid (1 key), find_link
        # (1 key) and config (2 keys). Four new
        # result symbols.
        self.assertEqual(
            ledger['N2463']['source_symbols'],
            [
                'source_liquid_bridge_link_valid_state_result.link_valid',
                'source_liquid_bridge_find_link_state_result.found_tile',
                'source_liquid_bridge_config_state_result.link',
                'source_liquid_bridge_config_state_result.config_value',
            ],
        )
        expected_sources = {
            'source_liquid_bridge_link_valid_state_result.link_valid': 'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'source_liquid_bridge_find_link_state_result.found_tile': 'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'source_liquid_bridge_config_state_result.link': 'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'source_liquid_bridge_config_state_result.config_value': 'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
        }
        for name in ledger['N2463']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], expected_sources[name])
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidBridgeBuildState.source_liquid_bridge_'))
        self.assertEqual(ledger['N2463']['runtime_proof'], '/root/C07LiquidBridgeLinkRowsProof')
        self.assertEqual(
            ledger['N2463']['tests'],
            [
                'test_c07_liquid_bridge_link_rows_registration',
                'test_all_c07_liquid_bridge_link_rows_input_evidence_is_exact',
                'test_liquid_bridge_link_rows_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_link_rows',
            ],
        )
        self.assertTrue(ledger['N2463']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #48 (1-based in
        # the merged advances-30 DEFERRED base): the
        # LiquidBridge link / findLink / linkValid
        # rows entry is REMOVED -- linkValid,
        # findLink, config(Point2) / config(Integer)
        # and config() are all live now as
        # LiquidBridge-driver pures. Net 246 - 1 =
        # 245. The per-def stat entry STAYS. No new
        # DEFERRED entry: the tick keeps its N2197
        # linkValid (the implementation-loose
        # blocks_match deviation already has its own
        # entry), and the placement-time auto-link
        # driver (N2199) is untouched.
        self.assertFalse(any(entry.startswith('LiquidBridge link / findLink / linkValid rows (') for entry in ledger['N2463']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge per-def stat rows (') for entry in ledger['N2463']['deferred_exprs']))
        self.assertEqual(len(ledger['N2463']['deferred_exprs']), 245)

    def test_all_c07_liquid_bridge_link_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2463']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceLiquidBridgeBuildState.source_liquid_bridge_'))
        slice_sources = [
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/distribution/ItemBridge.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/liquid/LiquidBridge.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Point2.java'),
        ]
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2463']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_link_rows_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The link/findLink/linkValid rows (ItemBridge
        # linkValid, ItemBridge.java:145-155;
        # positionsValid, :157-165; findLink, :167-173;
        # config(Point2), :64; config(Integer), :66;
        # config(), :500-501; link -1, :198 --
        # inherited by LiquidBridge, which overrides
        # NOTHING here: LiquidBridge.java:7 `public
        # class LiquidBridge extends ItemBridge{` and
        # :19 `public class LiquidBridgeBuild extends
        # ItemBridgeBuild{`, overriding only
        # updateTransport / doDump). linkValid is the
        # 3-arg Java exactly: null/positions guard
        # first, then the block clause ((other.block
        # == tile.block && tile.block == this) ||
        # (!(tile.block instanceof ItemBridge) &&
        # other.block == this)), the team clause
        # (other.team == tile.team || tile.block !=
        # this) and the checkDouble gate (!checkDouble
        # || other.link != tile.pos()). The block
        # clause has FOUR distinct predicates -- the
        # brief's 9 params cover three, so the pure
        # takes a 10th, tile_is_item_bridge (the
        # instanceof term): a phase-conveyor tile
        # (an ItemBridge, not this def) against a
        # bridge-conduit other is INVALID in Java
        # (linked(), ItemBridge.java:465, calls
        # linkValid(source.tile, tile) across defs)
        # and the pure must say so too. positionsValid
        # is caller-supplied (same x -> |dy| <= range;
        # same y -> |dx| <= range; else false) because
        # range varies per def (bridge-conduit 4,
        # phase-conduit 12, Blocks.java:2379/2388).
        # findLink returns lastBuild.tile iff the tile
        # exists, a lastBuild exists, linkValid holds,
        # lastBuild.tile != tile and lastBuild.link ==
        # -1. config(Point2) packs the RELATIVE point
        # against the tile, config(Integer) takes the
        # absolute packed int, config() returns
        # unpack(link) - tile. unpack(-1) is Point2
        # (-1, -1) (the (short) casts,
        # Point2.java:35-37), so a cleared link reads
        # config_value (-1 - tx, -1 - ty). ItemBridge
        # .config() has NO null check (unlike
        # MassDriver.config(), MassDriver.java:353) --
        # a null tile would NPE in Java, so the pure
        # returns config_value null as a documented
        # fallback (the N2461 precedent) and leaves
        # the link untouched for a "point2" action
        # with a null tile. Keep each Java expr on
        # ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_liquid_bridge_link_valid_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_find_link_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_config_state', liquid_bridge)
        self.assertIn('public boolean linkValid(Tile tile, Tile other){', liquid_bridge)
        self.assertIn('return linkValid(tile, other, true);', liquid_bridge)
        self.assertIn('public boolean linkValid(Tile tile, Tile other, boolean checkDouble){', liquid_bridge)
        self.assertIn('if(other == null || tile == null || !positionsValid(tile.x, tile.y, other.x, other.y)) return false;', liquid_bridge)
        self.assertIn('return ((other.block() == tile.block() && tile.block() == this) || (!(tile.block() instanceof ItemBridge) && other.block() == this))', liquid_bridge)
        self.assertIn('&& (other.team() == tile.team() || tile.block() != this)', liquid_bridge)
        self.assertIn('&& (!checkDouble || ((ItemBridgeBuild)other.build).link != tile.pos());', liquid_bridge)
        self.assertIn('public boolean positionsValid(int x1, int y1, int x2, int y2){', liquid_bridge)
        self.assertIn('return Math.abs(y1 - y2) <= range;', liquid_bridge)
        self.assertIn('return Math.abs(x1 - x2) <= range;', liquid_bridge)
        self.assertIn('public Tile findLink(int x, int y){', liquid_bridge)
        self.assertIn('Tile tile = world.tile(x, y);', liquid_bridge)
        self.assertIn('if(tile != null && lastBuild != null && linkValid(tile, lastBuild.tile) && lastBuild.tile != tile && lastBuild.link == -1){', liquid_bridge)
        self.assertIn('return lastBuild.tile;', liquid_bridge)
        self.assertIn('public int link = -1;', liquid_bridge)
        self.assertIn('config(Point2.class, (ItemBridgeBuild tile, Point2 i) -> tile.link = Point2.pack(i.x + tile.tileX(), i.y + tile.tileY()));', liquid_bridge)
        self.assertIn('config(Integer.class, (ItemBridgeBuild tile, Integer i) -> tile.link = i);', liquid_bridge)
        self.assertIn('public Point2 config(){', liquid_bridge)
        self.assertIn('return Point2.unpack(link).sub(tile.x, tile.y);', liquid_bridge)
        self.assertIn('public @Nullable ItemBridgeBuild lastBuild;', liquid_bridge)
        self.assertIn('public class ItemBridgeBuild extends Building{', liquid_bridge)
        self.assertIn('return source instanceof ItemBridgeBuild && linkValid(source.tile, tile) && ((ItemBridgeBuild)source).link == pos();', liquid_bridge)
        self.assertIn('public class LiquidBridge extends ItemBridge{', liquid_bridge)
        self.assertIn('public class LiquidBridgeBuild extends ItemBridgeBuild{', liquid_bridge)
        self.assertIn('return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));', liquid_bridge)
        self.assertIn('return (((short)x) << 16) | (((short)y) & 0xFFFF);', liquid_bridge)
        self.assertIn('range = 4;', liquid_bridge)
        self.assertIn('range = 12;', liquid_bridge)
        # The documented limits record the link /
        # findLink / linkValid rows as live.
        self.assertIn('Link/findLink/linkValid rows live (N2463)', liquid_bridge)
        # The proof's keys drive the pures (link_valid
        # true / positions / double, find_link found /
        # last-build guards, config point2-relative +
        # integer + clear + none + null tile).
        proof = LIQUID_BRIDGE_LINK_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'link_valid_true',
            'link_valid_positions',
            'link_valid_double',
            'find_link_found',
            'find_link_last_build',
            'config_point2_relative',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceLiquidBridgeBuildState.gd")', proof)
        self.assertTrue(LIQUID_BRIDGE_STATE.exists())
        self.assertTrue(LIQUID_BRIDGE_LINK_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07LiquidBridgeLinkRowsProof.gd', LIQUID_BRIDGE_LINK_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_liquid_bridge_link_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgeLinkRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_LINK_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'link_valid_true',
            'link_valid_positions',
            'link_valid_double',
            'find_link_found',
            'find_link_last_build',
            'config_point2_relative',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
