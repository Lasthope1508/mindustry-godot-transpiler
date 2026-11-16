import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
BUILDING_LIQUID_DUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidDumpState.gd'
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
LIQUID_NEIGHBOUR_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidNeighbourWriteBackProof.gd'
LIQUID_NEIGHBOUR_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidNeighbourWriteBackProof.tscn'


class C07LiquidNeighbourWriteBackTests(unittest.TestCase):
    def test_c07_liquid_neighbour_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        self.assertEqual(ledger['N2371']['godot_owner'], 'SourceBuildingLiquidState.source_neighbour_liquid_write_back_state')
        # N2284 routed the Fracker's dumped oil through the
        # shared dump_liquid_state routing -- but the shared
        # port reported only the amounts after, so the dumped
        # oil left the fracker without landing in any
        # neighbour store. Java hands the liquid over for
        # real: `next.handleLiquid(self(), liquid, flow);`
        # (BuildingComp.java:918), and handleLiquid is
        # `liquids.add(liquid, amount);`
        # (BuildingComp.java:872-874). N2371 is the shared
        # neighbour liquid write-back helper + the Fracker
        # dumpLiquid wiring: the helper maps the routed
        # neighbour index to a ring cell (the
        # source_block_proximity_cells_state ring, so index i
        # is ring cell i -- the N2353 convention), resolves
        # the sprite at that cell, and lands the liquid in
        # the neighbour's store -- a conduit neighbour's
        # sprite-meta LiquidModule (Conduit has no tick frame
        # and no queue: its liquids live on the
        # source_building_liquids meta, the N2090 precedent)
        # or a building neighbour's frame liquids (the first
        # SOURCE_CONSUMER_FRAME_META_KEYS frame present, the
        # N2142 set_meta write-back precedent, through the
        # shared liquid module add). No sprite, no frame, a
        # frame with no liquids store, or an unknown liquid
        # reports written false with a reason -- the liquid
        # is already routed away, so there is no fallback to
        # the fracker's own store. Six new result symbols:
        # the helper's written / reason / neighbour_cell,
        # the Fracker advance's dump_neighbour_index /
        # dumped_liquid, and the shared routing's
        # handled_index. The routing symbol lives on the
        # N1900 routing owner (PortGame), the Fracker symbols
        # on the Fracker dump owner -- the N2367 precedent.
        self.assertEqual(
            ledger['N2371']['source_symbols'],
            [
                'source_neighbour_liquid_write_back_state_result.written',
                'source_neighbour_liquid_write_back_state_result.reason',
                'source_neighbour_liquid_write_back_state_result.neighbour_cell',
                'source_fracker_dump_liquid_state_result.dump_neighbour_index',
                'source_fracker_dump_liquid_state_result.dumped_liquid',
                'building_dump_liquid.handled_index',
            ],
        )
        owners = {
            'source_neighbour_liquid_write_back_state_result.written': 'SourceBuildingLiquidState.source_neighbour_liquid_write_back_state',
            'source_neighbour_liquid_write_back_state_result.reason': 'SourceBuildingLiquidState.source_neighbour_liquid_write_back_state',
            'source_neighbour_liquid_write_back_state_result.neighbour_cell': 'SourceBuildingLiquidState.source_neighbour_liquid_write_back_state',
            'source_fracker_dump_liquid_state_result.dump_neighbour_index': 'SourceFrackerBuildState.source_fracker_dump_liquid_state',
            'source_fracker_dump_liquid_state_result.dumped_liquid': 'SourceFrackerBuildState.source_fracker_dump_liquid_state',
            'building_dump_liquid.handled_index': 'PortGame.source_building_dump_liquid_state',
        }
        for name in ledger['N2371']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/blocks/production/Fracker.java',
                })
                self.assertEqual(symbol['godot_owner'], owners[name])
        self.assertEqual(ledger['N2371']['runtime_proof'], '/root/C07LiquidNeighbourWriteBackProof')
        self.assertEqual(
            ledger['N2371']['tests'],
            [
                'test_c07_liquid_neighbour_write_back_registration',
                'test_all_c07_liquid_neighbour_write_back_input_evidence_is_exact',
                'test_liquid_neighbour_write_back_state',
                'test_reference_graph_and_actual_c07_liquid_neighbour_write_back',
            ],
        )
        # The shared routing contract + result schema carry
        # the new handled_index key (the N1900 register edit,
        # not a new contract/schema): the routing reports the
        # first neighbour its transfer actually reached, -1
        # when nothing moved.
        routing_owner = 'PortGame.source_building_dump_liquid_state'
        self.assertIn('handled_index', contracts[routing_owner]['return_keys'])
        self.assertIn('handled_index', schemas['source_building_dump_liquid_result']['keys'])
        self.assertEqual(schemas['source_building_dump_liquid_result']['keys']['handled_index']['type'], 'int')
        # The helper contract + input/result schemas are new.
        helper_owner = 'SourceBuildingLiquidState.source_neighbour_liquid_write_back_state'
        self.assertEqual(contracts[helper_owner]['source_slice'], 'N2371')
        self.assertEqual(
            contracts[helper_owner]['return_keys'],
            ['written', 'reason', 'neighbour_cell'],
        )
        self.assertIn('liquid', schemas['source_neighbour_liquid_write_back_state_input']['keys'])
        self.assertIn('amount', schemas['source_neighbour_liquid_write_back_state_input']['keys'])
        self.assertTrue(ledger['N2371']['deferred_exprs'])
        # This slice resolves the Fracker dumpLiquid neighbour
        # write-back deferral and adds one new entry: the
        # remaining liquid dump write-backs follow the helper
        # in their own wiring slices (Pump, SolidPump,
        # LiquidBridge, PayloadUnloader), and the
        # multi-recipient split waits (the advance reports
        # only the first handled index, so a dump that
        # reaches several neighbours lands the total in the
        # first). The item follow-ups entry stays untouched
        # for the coordinator to rewrite (the N2363
        # precedent); the Fracker live fill + campaign unlock
        # entries stay too.
        self.assertFalse(any(entry.startswith('Fracker dumpLiquid neighbour write-back (') for entry in ledger['N2371']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour liquid write-back follow-ups (') for entry in ledger['N2371']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour item write-back follow-ups (') for entry in ledger['N2371']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid neighbour live fill (') for entry in ledger['N2371']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid campaign unlock (') for entry in ledger['N2371']['deferred_exprs']))

    def test_all_c07_liquid_neighbour_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2371']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/Fracker.java',
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/world/blocks/liquid/Conduit.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2371']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_neighbour_write_back_state(self):
        building_liquid = BUILDING_LIQUID_STATE.read_text(encoding='utf-8')
        # The shared helper lives on the Building liquid state --
        # the handleLiquid / dumpLiquid home -- because the
        # write-back IS next.handleLiquid (BuildingComp.java:
        # 918): `public void handleLiquid(Building source,
        # Liquid liquid, float amount){` with
        # `liquids.add(liquid, amount);` (:872-874), no
        # capacity check (acceptLiquid already gated, :917).
        # dumpLiquid routes over proximity (:896) and
        # transfers (fract - ofract) * capacity / scaling to
        # each eligible neighbour (:905) through transferLiquid
        # (:914-921). Keep each Java expr on ONE comment line
        # (the N2148 shootWarmup lesson: a split line fails
        # this test).
        self.assertIn('static func source_neighbour_liquid_write_back_state', building_liquid)
        self.assertIn('public void dumpLiquid(Liquid liquid, float scaling, int outputDir){', building_liquid)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', building_liquid)
        self.assertIn('if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);', building_liquid)
        self.assertIn('public void transferLiquid(Building next, float amount, Liquid liquid){', building_liquid)
        self.assertIn('float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);', building_liquid)
        self.assertIn('if(next.acceptLiquid(self(), liquid)){', building_liquid)
        self.assertIn('next.handleLiquid(self(), liquid, flow);', building_liquid)
        self.assertIn('liquids.remove(liquid, flow);', building_liquid)
        self.assertIn('public void handleLiquid(Building source, Liquid liquid, float amount){', building_liquid)
        self.assertIn('liquids.add(liquid, amount);', building_liquid)
        # The conduit path is NOT a queue (the brief's belt
        # analogy does not hold -- scope correction, verified
        # in code): Conduit never overrides handleLiquid, so
        # the default liquids.add lands in its LiquidModule,
        # which the port keeps on the sprite
        # source_building_liquids meta (the N2090 pump-dump
        # precedent). ConduitBuild is a LiquidBuild
        # (Conduit.java:156) with its own acceptLiquid
        # (:242-244, current matches or under 0.2f); the
        # conduit defs are conduit / pulse-conduit /
        # plated-conduit / reinforced-conduit (Blocks.java:
        # 2322/2329/2337/2410, the last two ArmoredConduit,
        # which extends Conduit). A conduit neighbour is told
        # from a building neighbour by the conduit frame meta
        # key OR the Conduit-class block id, checked FIRST:
        # a conduit's handleLiquid goes to its meta store,
        # never to a frame liquids dict (it has no frame in
        # SOURCE_CONSUMER_FRAME_META_KEYS).
        self.assertIn('public class Conduit extends LiquidBlock implements Autotiler{', building_liquid)
        self.assertIn('public class ConduitBuild extends LiquidBuild implements ChainedBuilding{', building_liquid)
        self.assertIn('return (liquids.current() == liquid || liquids.currentAmount() < 0.2f)', building_liquid)
        self.assertIn('liquidCapacity = 20f;', building_liquid)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY := "source_conduit_building"', building_liquid)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS := ["conduit", "pulse-conduit", "plated-conduit", "reinforced-conduit"]', building_liquid)
        self.assertIn('sprite.has_meta(SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) or SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS.has(block_id)', building_liquid)
        # Preload-cycle pins (verified by transitive closure):
        # the geometry / liquid-module / placed-block /
        # content-registry preloads never reach
        # SourceBuildingLiquidState, but the power-graph state
        # does (via SourceFactoryBuildState) and the conduit
        # runtime does directly -- so the frame-key list comes
        # from a runtime load() (the BeamDrill precedent) and
        # the conduit frame key is a local const citing the
        # conduit runtime const.
        self.assertIn('const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")', building_liquid)
        self.assertIn('const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")', building_liquid)
        self.assertIn('const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")', building_liquid)
        self.assertIn('const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")', building_liquid)
        self.assertNotIn('preload("res://src/game/SourcePlacedPowerGraphState.gd")', building_liquid)
        self.assertNotIn('preload("res://src/game/SourceConduitRuntimeState.gd")', building_liquid)
        self.assertIn('load("res://src/game/SourcePlacedPowerGraphState.gd")', building_liquid)
        self.assertIn('power_graph_state.SOURCE_CONSUMER_FRAME_META_KEYS', building_liquid)
        # The frame path is the N2142 write-back precedent:
        # the neighbour frame is the first
        # SOURCE_CONSUMER_FRAME_META_KEYS key present on the
        # sprite, the liquid lands through the shared liquid
        # module add (source_add_state, which clamps like
        # Java's LiquidModule.add and flips "current"), and
        # the frame is written back with set_meta. The ring
        # cell comes from source_block_proximity_cells_state
        # (index i is ring cell i), the sprite from
        # block_sprite_at_cell, and the liquid id from the
        # catalog liquid_id_by_name (the module is id-indexed,
        # the helper takes a name).
        self.assertIn('source_block_geometry.source_block_proximity_cells_state(', building_liquid)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', building_liquid)
        self.assertIn('source_content_registry_runtime_state.source_liquid_catalog_state(catalog)', building_liquid)
        self.assertIn('source_liquid_module_state.source_add_state(', building_liquid)
        self.assertIn('sprite.set_meta(meta_key, frame)', building_liquid)
        self.assertIn('sprite.set_meta(source_placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY,', building_liquid)
        # The return shape is {written, reason,
        # neighbour_cell}; the reasons cover every exit: a
        # conduit write, a live-frame write, and the no-store
        # exits (no sprite, no frame, a frame/conduit with no
        # liquids store, an unknown liquid) plus the
        # invalid-input guards.
        self.assertIn('"written"', building_liquid)
        self.assertIn('"reason"', building_liquid)
        self.assertIn('"neighbour_cell"', building_liquid)
        self.assertIn('"conduit"', building_liquid)
        self.assertIn('"live_frame"', building_liquid)
        self.assertIn('"no_sprite"', building_liquid)
        self.assertIn('"no_frame"', building_liquid)
        self.assertIn('"no_liquids_store"', building_liquid)
        self.assertIn('"unknown_liquid"', building_liquid)
        self.assertIn('"invalid_index"', building_liquid)
        self.assertIn('"invalid_amount"', building_liquid)
        self.assertIn('"invalid_liquid"', building_liquid)
        # The shared routing reports the handled neighbour:
        # handled_index is the FIRST eligible index whose
        # transfer actually moved liquid -- handle_liquid_called
        # AND flow_value > 0 (flow alone is not enough: a
        # refusing neighbour still computes a flow, and a full
        # neighbour handles a zero flow) -- -1 when nothing
        # moved. A dump that reaches several neighbours reports
        # only the first (the multi-recipient split defers).
        dump_state = BUILDING_LIQUID_DUMP_STATE.read_text(encoding='utf-8')
        self.assertIn('var handled_index := -1', dump_state)
        self.assertIn('bool(check_state.get("handle_liquid_called", false)) and float(check_state.get("flow_value", 0.0)) > 0.0', dump_state)
        self.assertIn('"handled_index": handled_index', dump_state)
        # The Fracker dump exposes the handled neighbour index
        # + the dumped liquid name (dumped_amount already
        # existed -- no duplicate key) on BOTH return paths,
        # and the tick wires the helper after the dump
        # write-back when something dumped (Java order: the
        # dump at Fracker.java:42 / SolidPump.java:140 runs
        # after the advance, and the write-back lands what
        # the dump routed). The tick reads the origin_cell
        # meta inline as dump_cell (cell is bound after the
        # enabled block, the N2363 note) and the catalog size.
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        self.assertIn('return {"liquids_after": store, "dumped_amount": 0.0, "cursor_after": cursor, "dump_neighbour_index": -1, "dumped_liquid": SOURCE_FRACKER_RESULT_LIQUID}', fracker)
        self.assertIn('return {"liquids_after": store, "dumped_amount": dumped_amount, "cursor_after": int(dumped.get("final_cdump", cursor)), "dump_neighbour_index": int(dumped.get("handled_index", -1)), "dumped_liquid": SOURCE_FRACKER_RESULT_LIQUID}', fracker)
        self.assertIn('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", SOURCE_FRACKER_RESULT_LIQUID)), float(dumped.get("dumped_amount", 0.0)))', fracker)
        self.assertLess(
            fracker.index('frame["cdump"] = dumped["cursor_after"]'),
            fracker.index('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", SOURCE_FRACKER_RESULT_LIQUID)), float(dumped.get("dumped_amount", 0.0)))'),
        )
        self.assertLess(
            fracker.index('source_fracker_dump_liquid_state(frame, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, dump_neighbours)'),
            fracker.index('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", SOURCE_FRACKER_RESULT_LIQUID)), float(dumped.get("dumped_amount", 0.0)))'),
        )
        # The documented limits now record the neighbour
        # write-back as live (N2371) with the multi-recipient
        # split + live fill + campaign unlock still deferred;
        # the N2284 dump, the N2224 advance, the N2207 gate,
        # the N2255 liquid row and the N2268 item row are
        # preserved.
        self.assertIn('neighbour write-back live since N2371', fracker)
        self.assertIn('dumpLiquid live (N2284)', fracker)
        self.assertIn('updateTile advance live (N2224)', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('liquid row live (N2255)', fracker)
        self.assertIn('item row live (N2268)', fracker)
        self.assertIn('static func source_fracker_dump_liquid_state', fracker)
        self.assertIn('static func source_fracker_update_tile_advance_state', fracker)
        self.assertIn('static func source_fracker_tick_buildings_state', fracker)
        # The proof's keys drive the helper directly (a frame
        # neighbour lands the liquid, a conduit neighbour
        # lands it in its meta store, a storeless neighbour
        # reports no_frame, an empty cell reports no_sprite),
        # the advance's exposed handled index (first transfer
        # / fuller / refusing / no-neighbour / multi-recipient
        # first), and the live tick (a dumped fracker lands
        # its oil in the neighbour frame; a dumped fracker
        # next to a wall still loses its oil).
        proof = LIQUID_NEIGHBOUR_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'write_back_frame_neighbour_lands_liquid',
            'write_back_conduit_neighbour_lands_liquid',
            'write_back_no_frame_reports_no_frame',
            'write_back_no_sprite_reports_no_sprite',
            'advance_exposes_dump_neighbour_index',
            'live_tick_writes_dumped_liquid_to_neighbour_frame',
            'live_tick_dumped_liquid_leaves_fracker_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        for line in proof.splitlines():
            if 'preload("res://' in line:
                res_path = line.split('preload("res://', 1)[1].split('"', 1)[0]
                with self.subTest(preload=res_path):
                    self.assertTrue((ROOT / 'godot-mindustry' / res_path).is_file(), res_path)
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', proof)
        self.assertTrue(BUILDING_LIQUID_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('building_liquid_state.source_neighbour_liquid_write_back_state(', proof)
        self.assertIn('fracker_build_state.source_fracker_dump_liquid_state(', proof)
        self.assertIn('fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = LIQUID_NEIGHBOUR_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LiquidNeighbourWriteBackProof.gd', scene)
        self.assertIn('C07LiquidNeighbourWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_liquid_neighbour_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidNeighbourWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_NEIGHBOUR_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'write_back_frame_neighbour_lands_liquid',
            'write_back_conduit_neighbour_lands_liquid',
            'write_back_no_frame_reports_no_frame',
            'write_back_no_sprite_reports_no_sprite',
            'advance_exposes_dump_neighbour_index',
            'live_tick_writes_dumped_liquid_to_neighbour_frame',
            'live_tick_dumped_liquid_leaves_fracker_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
