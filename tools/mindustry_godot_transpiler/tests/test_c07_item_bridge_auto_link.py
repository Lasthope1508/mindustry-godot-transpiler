import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
PORT_GAME = ROOT / 'godot-mindustry/src/game/PortGame.gd'
SELECTED_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceSelectedBuildState.gd'
BLOCK_PLACEMENT = ROOT / 'godot-mindustry/src/game/SourceBlockPlacement.gd'
GAME_STATE = ROOT / 'godot-mindustry/src/game/SourcePortGameBuildProjectorStatePortBridge.gd'
ITEM_BRIDGE_AUTO_LINK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeAutoLinkProof.gd'
ITEM_BRIDGE_AUTO_LINK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeAutoLinkProof.tscn'


class C07ItemBridgeAutoLinkTests(unittest.TestCase):
    def test_c07_item_bridge_auto_link_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2199']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state')
        # N2197 gave the item bridge its link frame state (frame
        # keys link/had_valid_link + pure configure + pure
        # linkValid + the driver recompute every tick) and N2188
        # wired the shouldConsume gate over it -- but a bridge
        # placed by the player still started unlinked: the Java
        # auto-link (playerPlaced / findLink / lastBuild,
        # ItemBridge.java:41, 167-173, 211-220) was missing, so
        # two bridges placed in a row never linked each other.
        # N2199 is the placement auto-link: a pure findLink
        # mirroring findLink (ItemBridge.java:167-173, `Tile
        # tile = world.tile(x, y);` / `if(tile != null &&
        # lastBuild != null && linkValid(tile, lastBuild.tile)
        # && lastBuild.tile != tile && lastBuild.link == -1){
        # return lastBuild.tile; }`), a pure playerPlaced
        # mirroring playerPlaced (ItemBridge.java:210-219, `Tile
        # link = findLink(tile.x, tile.y);` / `if(linkValid(tile,
        # link) && this.link != link.pos() &&
        # !proximity.contains(link.build)){
        # link.build.configure(tile.pos()); }` / `lastBuild =
        # this;`), a game-level lastBuild store (one entry per
        # block def -- `lastBuild` is a field on the Block,
        # ItemBridge.java:41-42, `//for autolink` / `public
        # @Nullable ItemBridgeBuild lastBuild;`), and a driver
        # that runs it at placement on the player path only --
        # Java calls playerPlaced only when the builder is the
        # local player unit (ConstructBlock.java:106-109,
        # `if(!headless && builder == player.unit()){
        # tile.build.playerPlaced(config); }`), so scenario /
        # schematic placement (add_source_block /
        # source_place_schematic_state) does not auto-link.
        # proximity is the 4 orthogonal same-team neighbours
        # for a size-1 block (updateProximity,
        # BuildingComp.java:1879-1896, over
        # Edges.getEdges(block.size); Edges.java:20-37 gives
        # (0,-1),(0,1),(-1,0),(1,0) for size 1), so the
        # proximity check reduces to a Manhattan-distance-1
        # test once linkValid has already required a team
        # match. LiquidBridge inherits the whole behaviour
        # (LiquidBridgeBuild extends ItemBridgeBuild,
        # LiquidBridge.java:19, no playerPlaced override), so
        # the liquid driver reuses the item-bridge pures through
        # the N2198 preload (no new liquid symbols -- the
        # liquid driver is wiring, like the tick drivers).
        # 10 symbols: findLink (2) + playerPlaced (4) + the PortGame dispatch (4). The
        # dispatch entry is required because the PortGame dispatch is a non-static `func
        # source_*` method, so the audit discovers it and it needs its own registry owner
        # coverage (otherwise port_game.source_item_bridge_player_placed_dispatch_state stays
        # legacy-unregistered).
        self.assertEqual(
            ledger['N2199']['source_symbols'],
            [
                'source_item_bridge_find_link_result.found',
                'source_item_bridge_find_link_result.link_cell',
                'source_item_bridge_auto_link_result.configure_other',
                'source_item_bridge_auto_link_result.other_cell',
                'source_item_bridge_auto_link_result.config_value',
                'source_item_bridge_auto_link_result.new_last_build_cell',
                'source_item_bridge_player_placed_dispatch_result.applied',
                'source_item_bridge_player_placed_dispatch_result.configure_other',
                'source_item_bridge_player_placed_dispatch_result.other_cell',
                'source_item_bridge_player_placed_dispatch_result.new_last_build_cell',
            ],
        )
        for name in ledger['N2199']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_find_link_result.found': 'SourceItemBridgeBuildState.source_item_bridge_find_link_state',
                    'source_item_bridge_find_link_result.link_cell': 'SourceItemBridgeBuildState.source_item_bridge_find_link_state',
                    'source_item_bridge_auto_link_result.configure_other': 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state',
                    'source_item_bridge_auto_link_result.other_cell': 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state',
                    'source_item_bridge_auto_link_result.config_value': 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state',
                    'source_item_bridge_auto_link_result.new_last_build_cell': 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state',
                    'source_item_bridge_player_placed_dispatch_result.applied': 'PortGame.source_item_bridge_player_placed_dispatch_state',
                    'source_item_bridge_player_placed_dispatch_result.configure_other': 'PortGame.source_item_bridge_player_placed_dispatch_state',
                    'source_item_bridge_player_placed_dispatch_result.other_cell': 'PortGame.source_item_bridge_player_placed_dispatch_state',
                    'source_item_bridge_player_placed_dispatch_result.new_last_build_cell': 'PortGame.source_item_bridge_player_placed_dispatch_state',
                }[name])
        self.assertEqual(ledger['N2199']['runtime_proof'], '/root/C07ItemBridgeAutoLinkProof')
        self.assertEqual(
            ledger['N2199']['tests'],
            [
                'test_c07_item_bridge_auto_link_registration',
                'test_all_c07_item_bridge_auto_link_input_evidence_is_exact',
                'test_item_bridge_auto_link',
                'test_reference_graph_and_actual_c07_item_bridge_auto_link',
            ],
        )
        self.assertTrue(ledger['N2199']['deferred_exprs'])

    def test_all_c07_item_bridge_auto_link_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2199']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_find_link_result.found': 'SourceItemBridgeBuildState.source_item_bridge_find_link_state',
                    'source_item_bridge_find_link_result.link_cell': 'SourceItemBridgeBuildState.source_item_bridge_find_link_state',
                    'source_item_bridge_auto_link_result.configure_other': 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state',
                    'source_item_bridge_auto_link_result.other_cell': 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state',
                    'source_item_bridge_auto_link_result.config_value': 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state',
                    'source_item_bridge_auto_link_result.new_last_build_cell': 'SourceItemBridgeBuildState.source_item_bridge_player_placed_state',
                    'source_item_bridge_player_placed_dispatch_result.applied': 'PortGame.source_item_bridge_player_placed_dispatch_state',
                    'source_item_bridge_player_placed_dispatch_result.configure_other': 'PortGame.source_item_bridge_player_placed_dispatch_state',
                    'source_item_bridge_player_placed_dispatch_result.other_cell': 'PortGame.source_item_bridge_player_placed_dispatch_state',
                    'source_item_bridge_player_placed_dispatch_result.new_last_build_cell': 'PortGame.source_item_bridge_player_placed_dispatch_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
            'core/src/mindustry/world/blocks/ConstructBlock.java',
            'core/src/mindustry/world/Edges.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'arc-core/src/arc/math/geom/Point2.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2199']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_auto_link(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        port_game = PORT_GAME.read_text(encoding='utf-8')
        block_placement = BLOCK_PLACEMENT.read_text(encoding='utf-8')
        game_state = GAME_STATE.read_text(encoding='utf-8')
        # The auto-link pures live on the item-bridge build
        # state: findLink (ItemBridge.java:167-173, `public Tile
        # findLink(int x, int y){` with `Tile tile =
        # world.tile(x, y);` and `if(tile != null && lastBuild
        # != null && linkValid(tile, lastBuild.tile) &&
        # lastBuild.tile != tile && lastBuild.link == -1){
        # return lastBuild.tile; }` -- keep each Java line on
        # ONE comment line, the N2148 shootWarmup lesson: a
        # split line fails this test) and playerPlaced
        # (ItemBridge.java:210-219, `public void
        # playerPlaced(Object config){` with
        # `super.playerPlaced(config);` -- the super is a no-op,
        # BuildingComp.java:1350-1352 -- `Tile link =
        # findLink(tile.x, tile.y);`, `if(linkValid(tile, link)
        # && this.link != link.pos() &&
        # !proximity.contains(link.build)){`,
        # `link.build.configure(tile.pos());`, and `lastBuild =
        # this;`). lastBuild is a field on the Block
        # (ItemBridge.java:41-42, `//for autolink` / `public
        # @Nullable ItemBridgeBuild lastBuild;`) -- one per
        # block def, never cleared on removal, overwritten by
        # the next placement of the same def. The findLink
        # check order is Java's (tile, lastBuild, linkValid,
        # tile inequality, link == -1); the linkValid inside
        # findLink uses checkDouble=true (`return
        # linkValid(tile, other, true);`, ItemBridge.java:147),
        # and playerPlaced re-checks linkValid on the found
        # link exactly as Java does. The block clause
        # (`return ((other.block() == tile.block() &&
        # tile.block() == this) || (!(tile.block() instanceof
        # ItemBridge) && other.block() == this))`,
        # ItemBridge.java:152) requires the SAME block def, so
        # the N2199 driver gathers a strict def match (other
        # block id == this block id) -- unlike the N2198 tick
        # driver, which accepts any LiquidBridge implementation
        # and therefore validates a cross-def phase-conduit /
        # bridge-conduit pair; that tick deviation waits for its
        # own fix slice (DEFERRED). The proximity check is the
        # 4 orthogonal same-team neighbours for a size-1 block
        # (updateProximity, BuildingComp.java:1879-1896,
        # `Point2[] nearby = Edges.getEdges(block.size);` with
        # `if(other == null || other.team != team) continue;`;
        # Edges.java:25, `edges[i] = new Point2[(i + 1) * 4];`,
        # gives (0,-1),(0,1),(-1,0),(1,0) for size 1), reduced
        # to a Manhattan-distance-1 test once linkValid has
        # required the team match. The hook runs on the player
        # path only (ConstructBlock.java:106-109, `if(!headless
        # && builder == player.unit()){` / `tile.build
        # .playerPlaced(config);` -- the plan config is applied
        # first, ConstructBlock.java:93, `tile.build
        # .configured(builder, config);`), guarded by
        # has_method so test games without the PortGame method
        # (BlockPlacementModuleProof's FakePlacementGame) skip
        # it. handlePlacementLine (`public void
        # handlePlacementLine(Seq<BuildPlan> plans){`,
        # ItemBridge.java:185, with `cur.config = new Point2
        # (next.x - cur.x, next.y - cur.y);`, :190) and
        # pickedUp (`public void pickedUp(){`,
        # ItemBridge.java:206, `link = -1;`) wait for their own
        # slices -- the port has no placement lines, and the
        # bridge-specific pickup link reset is not wired yet.
        # LiquidBridge inherits the behaviour (`public class
        # LiquidBridge extends ItemBridge{`,
        # LiquidBridge.java:7; `public class LiquidBridgeBuild
        # extends ItemBridgeBuild{`, :19; no playerPlaced
        # override), so the liquid driver reuses the
        # item-bridge pures through the N2198 preload.
        self.assertIn('static func source_item_bridge_find_link_state', item_bridge)
        self.assertIn('static func source_item_bridge_player_placed_state', item_bridge)
        self.assertIn('static func source_item_bridge_auto_link_placement_state', item_bridge)
        self.assertIn('//for autolink', item_bridge)
        self.assertIn('public @Nullable ItemBridgeBuild lastBuild;', item_bridge)
        self.assertIn('public Tile findLink(int x, int y){', item_bridge)
        self.assertIn('Tile tile = world.tile(x, y);', item_bridge)
        self.assertIn('if(tile != null && lastBuild != null && linkValid(tile, lastBuild.tile) && lastBuild.tile != tile && lastBuild.link == -1){', item_bridge)
        self.assertIn('return lastBuild.tile;', item_bridge)
        self.assertIn('public void playerPlaced(Object config){', item_bridge)
        self.assertIn('super.playerPlaced(config);', item_bridge)
        self.assertIn('Tile link = findLink(tile.x, tile.y);', item_bridge)
        self.assertIn('if(linkValid(tile, link) && this.link != link.pos() && !proximity.contains(link.build)){', item_bridge)
        self.assertIn('link.build.configure(tile.pos());', item_bridge)
        self.assertIn('lastBuild = this;', item_bridge)
        self.assertIn('return ((other.block() == tile.block() && tile.block() == this) || (!(tile.block() instanceof ItemBridge) && other.block() == this))', item_bridge)
        self.assertIn('return linkValid(tile, other, true);', item_bridge)
        self.assertIn('Point2[] nearby = Edges.getEdges(block.size);', item_bridge)
        self.assertIn('if(other == null || other.team != team) continue;', item_bridge)
        self.assertIn('public void handlePlacementLine(Seq<BuildPlan> plans){', item_bridge)
        self.assertIn('cur.config = new Point2(next.x - cur.x, next.y - cur.y);', item_bridge)
        self.assertIn('public void pickedUp(){', item_bridge)
        self.assertIn('source_item_bridge_link_valid_state(', item_bridge)
        self.assertIn('source_item_bridge_find_link_state(', item_bridge)
        self.assertIn('source_item_bridge_configure_state(', item_bridge)
        self.assertIn('game.get("source_item_bridge_last_build_by_block")', item_bridge)
        self.assertIn('game.set("source_item_bridge_last_build_by_block"', item_bridge)
        self.assertIn('static func source_liquid_bridge_auto_link_placement_state', liquid_bridge)
        self.assertIn('source_item_bridge_player_placed_state(', liquid_bridge)
        self.assertIn('public class LiquidBridge extends ItemBridge{', liquid_bridge)
        self.assertIn('public class LiquidBridgeBuild extends ItemBridgeBuild{', liquid_bridge)
        self.assertIn('func source_item_bridge_player_placed_dispatch_state', port_game)
        # The PortGame dispatch routes through the SourceSelectedBuildState predicates
        # (the PortGame convention -- PortGame.gd never reads block.implementation
        # directly, test_port_game_uses_selected_build_implementation_predicates).
        self.assertIn('SourceSelectedBuildState.is_item_bridge(block)', port_game)
        self.assertIn('SourceSelectedBuildState.is_liquid_bridge(block)', port_game)
        self.assertNotIn('block.implementation', port_game)
        selected_build = SELECTED_BUILD_STATE.read_text(encoding='utf-8')
        self.assertIn('static func is_item_bridge(block) -> bool:', selected_build)
        self.assertIn('static func is_liquid_bridge(block) -> bool:', selected_build)
        self.assertIn('return implementation_name(block) == "ItemBridge" or implementation_name(block) == "BufferedItemBridge"', selected_build)
        self.assertIn('return implementation_name(block) == "LiquidBridge"', selected_build)
        self.assertIn('game.has_method("source_item_bridge_player_placed_dispatch_state")', block_placement)
        self.assertIn('game.call("source_item_bridge_player_placed_dispatch_state", sprite, block, cell)', block_placement)
        self.assertIn('if(!headless && builder == player.unit()){', block_placement)
        self.assertIn('tile.build.playerPlaced(config);', block_placement)
        self.assertIn('var source_item_bridge_last_build_by_block: Dictionary = {}', game_state)
        # The proof's keys drive the pure findLink (finds an
        # unlinked lastBuild / rejects a linked, same-tile, or
        # out-of-range one) + the pure playerPlaced (configures
        # the partner / skips an adjacent partner / skips when
        # already linked / still updates lastBuild with no
        # partner) + the live placement (two bridges placed in a
        # row auto-link and the game lastBuild dict updates;
        # same for liquid bridges). Static checks: the proof
        # preloads the family state file that exists, and the
        # scene file references the proof script that exists.
        proof = ITEM_BRIDGE_AUTO_LINK_PROOF.read_text(encoding='utf-8')
        for key in [
            'find_link_finds_unlinked_last_build',
            'find_link_rejects_linked_or_same_tile',
            'player_placed_configures_partner',
            'player_placed_skips_adjacent_partner',
            'player_placed_skips_when_already_linked',
            'player_placed_updates_last_build_without_partner',
            'live_placement_auto_links_and_updates_last_build',
            'live_liquid_placement_auto_links',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.is_file())
        scene = ITEM_BRIDGE_AUTO_LINK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07ItemBridgeAutoLinkProof.gd', scene)
        self.assertTrue(ITEM_BRIDGE_AUTO_LINK_PROOF.is_file())

    def test_reference_graph_and_actual_c07_item_bridge_auto_link(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeAutoLinkProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_AUTO_LINK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'find_link_finds_unlinked_last_build',
            'find_link_rejects_linked_or_same_tile',
            'player_placed_configures_partner',
            'player_placed_skips_adjacent_partner',
            'player_placed_skips_when_already_linked',
            'player_placed_updates_last_build_without_partner',
            'live_placement_auto_links_and_updates_last_build',
            'live_liquid_placement_auto_links',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
