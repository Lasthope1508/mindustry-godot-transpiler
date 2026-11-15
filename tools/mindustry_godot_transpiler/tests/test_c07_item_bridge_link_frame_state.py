import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_LINK_FRAME_STATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeLinkFrameStateProof.gd'
ITEM_BRIDGE_LINK_FRAME_STATE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeLinkFrameStateProof.tscn'


class C07ItemBridgeLinkFrameStateTests(unittest.TestCase):
    def test_c07_item_bridge_link_frame_state_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2197']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_link_valid_state')
        # N2178 gave the item bridge its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but the port tracked NO live link
        # on any placed-building frame, so the shouldConsume gate
        # (`return hadValidLink && enabled;`,
        # ItemBridge.java:495-496) waited, and N2188 stopped at
        # scoping for exactly that reason. N2197 is the link frame
        # state that unblocks it: frame keys `link` (default -1,
        # `public int link = -1;`, ItemBridge.java:198) and
        # `had_valid_link` (default false, `public boolean
        # wasMoved, moved, hadValidLink;`, ItemBridge.java:202), a
        # pure configure mirroring the two constructor handlers
        # (ItemBridge.java:64, Point2 relative; :66, Integer
        # absolute), a pure linkValid mirroring linkValid +
        # positionsValid (ItemBridge.java:149-166), and a driver
        # recompute every tick (ItemBridge.java:332-333, `Tile
        # other = world.tile(link);` / `hadValidLink =
        # linkValid(tile, other);`), AFTER the consumption fold --
        # updateConsumption runs before updateTile
        # (BuildingComp.java:2274-2277) -- and only when enabled
        # (ItemBridge `noUpdateDisabled = true;`,
        # ItemBridge.java:54, so a disabled bridge freezes its
        # had_valid_link instead of clearing it). The gate itself
        # does NOT change here: the driver still folds with
        # should_consume=true when enabled, and N2188 wires
        # `should_consume = had_valid_link && enabled`. Two new
        # result symbols, grouped under one link result schema:
        # the link the configure function sets, and the
        # had_valid_link the linkValid function evaluates. The
        # slice owner is the linkValid pure function -- the live
        # tick function the driver calls every tick; the
        # configure function's `link` output is grouped here
        # because both keys are the one link frame state.
        self.assertEqual(
            ledger['N2197']['source_symbols'],
            [
                'source_item_bridge_link_result.link',
                'source_item_bridge_link_result.had_valid_link',
            ],
        )
        for name in ledger['N2197']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_link_result.link': 'SourceItemBridgeBuildState.source_item_bridge_link_valid_state',
                    'source_item_bridge_link_result.had_valid_link': 'SourceItemBridgeBuildState.source_item_bridge_link_valid_state',
                }[name])
        self.assertEqual(ledger['N2197']['runtime_proof'], '/root/C07ItemBridgeLinkFrameStateProof')
        self.assertEqual(
            ledger['N2197']['tests'],
            [
                'test_c07_item_bridge_link_frame_state_registration',
                'test_all_c07_item_bridge_link_frame_state_input_evidence_is_exact',
                'test_item_bridge_link_frame_state',
                'test_reference_graph_and_actual_c07_item_bridge_link_frame_state',
            ],
        )
        self.assertTrue(ledger['N2197']['deferred_exprs'])

    def test_all_c07_item_bridge_link_frame_state_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2197']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_link_result.link': 'SourceItemBridgeBuildState.source_item_bridge_link_valid_state',
                    'source_item_bridge_link_result.had_valid_link': 'SourceItemBridgeBuildState.source_item_bridge_link_valid_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'arc-core/src/arc/math/geom/Point2.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2197']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_link_frame_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The link frame state lives on the item-bridge build
        # state: a new ItemBridgeBuild starts unlinked (`public
        # int link = -1;`, ItemBridge.java:198 -- the old family
        # comment cited :202, fixed by this slice) with
        # hadValidLink false (`public boolean wasMoved, moved,
        # hadValidLink;`, ItemBridge.java:202 -- the old comment
        # cited :206, fixed by this slice). The pure configure
        # mirrors the two constructor handlers (ItemBridge.java:64,
        # `config(Point2.class, (ItemBridgeBuild tile, Point2 i)
        # -> tile.link = Point2.pack(i.x + tile.tileX(), i.y +
        # tile.tileY()));` -- Point2 is RELATIVE, keep on ONE
        # comment line, the N2148 shootWarmup lesson: a split
        # line fails this test -- and :66, `config(Integer.class,
        # (ItemBridgeBuild tile, Integer i) -> tile.link = i);`
        # -- Integer is the packed absolute position). The pack
        # is arc Point2.pack (arc Point2.java:40-42, `return
        # (((short)x) << 16) | (((short)y) & 0xFFFF);`), the
        # unpack arc Point2.unpack (arc Point2.java:35-37,
        # `return new Point2((short)(pos >>> 16), (short)(pos &
        # 0xFFFF));`); both are private helpers in the family
        # file (the N2191 slerpDelta local precedent -- no
        # separate symbol), with GDScript's 64-bit ints masked
        # and sign-extended back to short. The pure linkValid
        # mirrors linkValid (ItemBridge.java:145-156, `public
        # boolean linkValid(Tile tile, Tile other){` with
        # `return linkValid(tile, other, true);`, and `public
        # boolean linkValid(Tile tile, Tile other, boolean
        # checkDouble){`): `if(other == null || tile == null ||
        # !positionsValid(tile.x, tile.y, other.x, other.y))
        # return false;`, then `return ((other.block() ==
        # tile.block() && tile.block() == this) ||
        # (!(tile.block() instanceof ItemBridge) &&
        # other.block() == this))` and `&& (other.team() ==
        # tile.team() || tile.block() != this)` and `&&
        # (!checkDouble || ((ItemBridgeBuild)other.build).link
        # != tile.pos());`. The driver ticks ItemBridge builds
        # only, so tile.block() is always this: the block clause
        # reduces to the other block being an ItemBridge
        # (blocks_match, gathered by the driver) and the team
        # clause to the teams matching (teams_match).
        # positionsValid (ItemBridge.java:157-166, `public
        # boolean positionsValid(int x1, int y1, int x2, int
        # y2){`): same column `return Math.abs(y1 - y2) <=
        # range;`, same row `return Math.abs(x1 - x2) <= range;`,
        # else false. The driver recomputes had_valid_link every
        # tick (ItemBridge.java:332-333, `Tile other =
        # world.tile(link);` / `hadValidLink = linkValid(tile,
        # other);`), AFTER the consumption fold -- updateConsumption
        # runs before updateTile (BuildingComp.java:2274-2277,
        # `updateConsumption();` then `if(enabled ||
        # !block.noUpdateDisabled){` / `updateTile();`) -- and
        # only when enabled (ItemBridge `noUpdateDisabled =
        # true;`, ItemBridge.java:54). The partner sprite is
        # looked up through placed_blocks by the unpacked link
        # cell; the range comes from the catalog
        # (block.properties["range"], 12 for phase-conveyor,
        # `range = 12;`, Blocks.java:2118; the Java field
        # default is 0 when the def does not set it, `public int
        # range;`, ItemBridge.java:27). The gate does NOT change
        # here: the driver still folds with should_consume=true
        # when enabled -- N2188 wires `should_consume =
        # had_valid_link && enabled` (`return hadValidLink &&
        # enabled;`, ItemBridge.java:495-496). The config()
        # getter (`return Point2.unpack(link).sub(tile.x,
        # tile.y);`, ItemBridge.java:500-502) and write/read
        # (`write.i(link);`, ItemBridge.java:512) wait for their
        # own rebuild slice; placement auto-link (playerPlaced /
        # findLink / lastBuild) waits for N2199.
        self.assertIn('static func source_item_bridge_configure_state', item_bridge)
        self.assertIn('static func source_item_bridge_link_valid_state', item_bridge)
        self.assertIn('static func _point2_pack', item_bridge)
        self.assertIn('static func _point2_unpack', item_bridge)
        self.assertIn('config(Point2.class, (ItemBridgeBuild tile, Point2 i) -> tile.link = Point2.pack(i.x + tile.tileX(), i.y + tile.tileY()));', item_bridge)
        self.assertIn('config(Integer.class, (ItemBridgeBuild tile, Integer i) -> tile.link = i);', item_bridge)
        self.assertIn('public int link = -1;', item_bridge)
        self.assertIn('public boolean wasMoved, moved, hadValidLink;', item_bridge)
        self.assertIn('`public int link = -1;` (ItemBridge.java:198)', item_bridge)
        self.assertIn('`public boolean wasMoved, moved, hadValidLink;` (ItemBridge.java:202)', item_bridge)
        self.assertIn('public boolean linkValid(Tile tile, Tile other, boolean checkDouble){', item_bridge)
        self.assertIn('if(other == null || tile == null || !positionsValid(tile.x, tile.y, other.x, other.y)) return false;', item_bridge)
        self.assertIn('return ((other.block() == tile.block() && tile.block() == this) || (!(tile.block() instanceof ItemBridge) && other.block() == this))', item_bridge)
        self.assertIn('&& (other.team() == tile.team() || tile.block() != this)', item_bridge)
        self.assertIn('&& (!checkDouble || ((ItemBridgeBuild)other.build).link != tile.pos());', item_bridge)
        self.assertIn('public boolean positionsValid(int x1, int y1, int x2, int y2){', item_bridge)
        self.assertIn('return Math.abs(y1 - y2) <= range;', item_bridge)
        self.assertIn('return Math.abs(x1 - x2) <= range;', item_bridge)
        self.assertIn('Tile other = world.tile(link);', item_bridge)
        self.assertIn('hadValidLink = linkValid(tile, other);', item_bridge)
        self.assertIn('return linkValid(tile, other, true);', item_bridge)
        self.assertIn('noUpdateDisabled = true;', item_bridge)
        self.assertIn('return hadValidLink && enabled;', item_bridge)
        self.assertIn('return Point2.unpack(link).sub(tile.x, tile.y);', item_bridge)
        self.assertIn('return new Point2((short)(pos >>> 16), (short)(pos & 0xFFFF));', item_bridge)
        self.assertIn('return (((short)x) << 16) | (((short)y) & 0xFFFF);', item_bridge)
        self.assertIn('updateConsumption();', item_bridge)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', item_bridge)
        self.assertIn('range = 12;', item_bridge)
        self.assertIn('write.i(link);', item_bridge)
        self.assertIn('"link": -1', item_bridge)
        self.assertIn('"had_valid_link": false', item_bridge)
        self.assertIn('frame["link"]', item_bridge)
        self.assertIn('frame["had_valid_link"]', item_bridge)
        self.assertIn('static func source_item_bridge_tick_buildings_state', item_bridge)
        self.assertIn('source_item_bridge_link_valid_state(', item_bridge)
        self.assertIn('game.get("placed_blocks")', item_bridge)
        self.assertIn('block.properties.get("range", 0)', item_bridge)
        # The gate is LIVE since N2188: the driver reads
        # should_consume through the pure gate function
        # (`should_consume = had_valid_link && enabled`,
        # ItemBridge.java:495-496). The N2178 power row is
        # preserved.
        self.assertIn('var gate: Dictionary = source_item_bridge_should_consume_state(frame)', item_bridge)
        self.assertIn('var should_consume: bool = bool(gate.get("should_consume", false))', item_bridge)
        self.assertIn('static func source_item_bridge_power_status_row_state', item_bridge)
        # The proof's keys drive the frame defaults + the pure
        # configure (Point2 relative / Integer absolute) + the
        # pure linkValid (same row within range / double or out
        # of range) + the live tick (recompute both ways). There
        # is no gate key: the shouldConsume gate waits for
        # N2188. Static checks: the proof preloads the family
        # state file that exists, and the scene file references
        # the proof script that exists.
        proof = ITEM_BRIDGE_LINK_FRAME_STATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'link_defaults_to_minus_one',
            'configure_point2_sets_relative_link',
            'configure_integer_sets_absolute_link',
            'link_valid_same_row_within_range',
            'link_invalid_when_double_or_out_of_range',
            'live_tick_recomputes_had_valid_link',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        scene = ITEM_BRIDGE_LINK_FRAME_STATE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ItemBridgeLinkFrameStateProof.gd', scene)
        self.assertTrue(ITEM_BRIDGE_LINK_FRAME_STATE_PROOF.is_file())

    def test_reference_graph_and_actual_c07_item_bridge_link_frame_state(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeLinkFrameStateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_LINK_FRAME_STATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'link_defaults_to_minus_one',
            'configure_point2_sets_relative_link',
            'configure_integer_sets_absolute_link',
            'link_valid_same_row_within_range',
            'link_invalid_when_double_or_out_of_range',
            'live_tick_recomputes_had_valid_link',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
