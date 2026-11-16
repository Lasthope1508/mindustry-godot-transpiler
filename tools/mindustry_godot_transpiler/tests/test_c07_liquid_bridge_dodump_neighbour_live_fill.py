import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
LIQUID_BRIDGE_DODUMP_NEIGHBOUR_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeDodumpNeighbourLiveFillProof.gd'
LIQUID_BRIDGE_DODUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeDodumpNeighbourLiveFillProof.tscn'
LIQUID_BRIDGE_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/liquid/LiquidBridge.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'
BLOCKS_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java'


class C07LiquidBridgeDodumpNeighbourLiveFillTests(unittest.TestCase):
    def test_c07_liquid_bridge_dodump_neighbour_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2412']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_dodump_neighbour_live_fill_state')
        # N2287 ported the doDump rows (dumpLiquid(
        # liquids.current(), 1f) in the unlinked branch only,
        # LiquidBridge.java:29-31) -- but the eight neighbour
        # arrays stayed frame inputs (default []), so a live
        # bridge with no fill read an empty proximity and
        # never dumped. N2379 wired the neighbour write-back
        # (the shared source_neighbour_liquid_write_back_state
        # helper lands the routed liquid in the handled
        # neighbour's store) -- but with no fill the routing
        # never ran. N2412 is the live fill: the tick scans
        # the live proximity (the
        # source_block_proximity_cells_state ring, index i is
        # ring cell i, the N2353 convention) BEFORE the dump
        # reads at :540 and fills the eight neighbour arrays
        # from the live neighbour frames -- liquid amount /
        # capacity from the neighbour liquids modules,
        # accepts/canDump from the DEFAULT BuildingComp gates
        # (acceptLiquid is hasLiquids && consumesLiquid,
        # :868-870; canDumpLiquid defaults to true, :910-912).
        # The dumped liquid is liquids.current() (the N2394
        # unloader case, NOT the N2408 fixed def result), so
        # the fill reads the current id from the advanced
        # store and resolves its name through the tick's
        # liquid_names_by_id. Per-block overrides are OUT of
        # scope (a neighbour with a modeled override is
        # evaluated with the DEFAULT gate here -- the
        # override dispatch is a follow-through note, not a
        # new DEFERRED entry). Eight new result symbols: one
        # per filled neighbour array.
        self.assertEqual(
            ledger['N2412']['source_symbols'],
            [
                'source_liquid_bridge_dodump_neighbour_live_fill_state_result.dump_neighbour_amounts',
                'source_liquid_bridge_dodump_neighbour_live_fill_state_result.dump_neighbour_capacities',
                'source_liquid_bridge_dodump_neighbour_live_fill_state_result.dump_neighbour_accepts',
                'source_liquid_bridge_dodump_neighbour_live_fill_state_result.dump_neighbour_has_liquids',
                'source_liquid_bridge_dodump_neighbour_live_fill_state_result.dump_neighbour_can_dump',
                'source_liquid_bridge_dodump_neighbour_live_fill_state_result.dump_neighbour_liquids_present',
                'source_liquid_bridge_dodump_neighbour_live_fill_state_result.dump_neighbour_destination_present',
                'source_liquid_bridge_dodump_neighbour_live_fill_state_result.dump_neighbour_relative_to',
            ],
        )
        for name in ledger['N2412']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_dodump_neighbour_live_fill_state')
        self.assertEqual(ledger['N2412']['runtime_proof'], '/root/C07LiquidBridgeDodumpNeighbourLiveFillProof')
        self.assertEqual(
            ledger['N2412']['tests'],
            [
                'test_c07_liquid_bridge_dodump_neighbour_live_fill_registration',
                'test_all_c07_liquid_bridge_dodump_neighbour_live_fill_input_evidence_is_exact',
                'test_liquid_bridge_dodump_neighbour_live_fill_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_dodump_neighbour_live_fill',
            ],
        )
        self.assertTrue(ledger['N2412']['deferred_exprs'])
        # This slice RESOLVES the LiquidBridge doDump live
        # neighbour fill entry (DEFERRED #232 in the
        # coordinator's merged numbering, base
        # DEFERRED-after-advances-23, 291 entries): the fill
        # is live now, so the entry is REMOVED and the list
        # drops to 290. No new entry: the override-dispatch
        # follow-through is a note, not a deferral. The
        # campaign unlock, the moveLiquid reaction branch,
        # and the Pump / SolidPump dump neighbour live fill
        # entries stay verbatim.
        self.assertEqual(len(ledger['N2412']['deferred_exprs']), 290)
        self.assertFalse(any(entry.startswith('LiquidBridge doDump live neighbour fill (') for entry in ledger['N2412']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge doDump campaign unlock (') for entry in ledger['N2412']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge moveLiquid reaction branch (') for entry in ledger['N2412']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dump neighbour live fill (') for entry in ledger['N2412']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump dump neighbour live fill (') for entry in ledger['N2412']['deferred_exprs']))

    def test_all_c07_liquid_bridge_dodump_neighbour_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2412']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_dodump_neighbour_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2412']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_dodump_neighbour_live_fill_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The live fill (N2412, DEFERRED #232): the tick fills
        # the eight neighbour arrays from the live proximity
        # BEFORE the doDump reads them at :540. Index i is
        # ring cell i (the N2353 convention -- the ring comes
        # from source_block_proximity_cells_state, the sprite
        # from block_sprite_at_cell, the frame from the first
        # SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
        # the N2353/N2371 resolution path). The dumped liquid
        # is liquids.current() (LiquidBridge.java:30, the
        # N2394 unloader case -- NOT the N2408 fixed def
        # result), so the fill reads the current id from the
        # advanced store and resolves its name through the
        # tick's liquid_names_by_id. Per-neighbour amount /
        # capacity come from the neighbour liquids module +
        # the neighbour def's liquidCapacity (the ofract
        # denominator); accepts / canDump come from the
        # DEFAULT gates (acceptLiquid is hasLiquids &&
        # consumesLiquid, BuildingComp.java:868-870;
        # canDumpLiquid defaults to true, :910-912).
        # consumesLiquid reads the liquidFilter
        # (Block.java:778-779), which the port represents as
        # the catalog consumeLiquid rows. Per-block overrides
        # are OUT of scope: a neighbour with a modeled
        # override is evaluated with the DEFAULT gate here.
        # A neighbour with no frame (no sprite / unknown def
        # / conduit / no meta-key frame) reports the no-frame
        # outcome -- 0.0 / 0.0 / false / false / false /
        # false / false / 0 -- the N2353/N2371 no-frame
        # precedent (a routed liquid to a frameless neighbour
        # drops, so the fill closes the gates and nothing
        # routes there). Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_liquid_bridge_dodump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, liquids: Dictionary, liquid_names_by_id: Array) -> Dictionary:', liquid_bridge)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', liquid_bridge)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', liquid_bridge)
        self.assertIn('return block.hasLiquids && block.consumesLiquid(liquid);', liquid_bridge)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', liquid_bridge)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', liquid_bridge)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', liquid_bridge)
        self.assertIn('public boolean consumesLiquid(Liquid liq){', liquid_bridge)
        self.assertIn('return liquidFilter[liq.id];', liquid_bridge)
        self.assertIn('public Building getLiquidDestination(Building from, Liquid liquid){', liquid_bridge)
        self.assertIn('liquidCapacity = Mathf.round(10f * consumeAmount);', liquid_bridge)
        self.assertIn('dumpLiquid(liquids.current(), 1f);', liquid_bridge)
        self.assertIn('public void doDump(){', liquid_bridge)
        # The fill reuses the shared resolution path -- the
        # ring, the cell lookup, the frame-key list, the
        # liquid-module read -- never a hand-rolled scan. The
        # frame-key list comes from a runtime load (the
        # N2371/BeamDrill precedent), NOT a preload: the
        # power-graph state's 104-file transitive preload
        # tree is cycle-risky, and a preload line above the
        # tick would shift the :540 dump-read site. The
        # liquid-module read goes through the shared
        # source_get_state helper (the N2394/N2408 precedent)
        # resolved the same way.
        self.assertIn('load("res://src/game/SourcePlacedPowerGraphState.gd")', liquid_bridge)
        self.assertIn('load("res://src/game/SourceLiquidModuleState.gd")', liquid_bridge)
        self.assertIn('source_block_proximity_cells_state(size, cell.x, cell.y)', liquid_bridge)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', liquid_bridge)
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', liquid_bridge)
        self.assertIn('liquid_module_state.source_get_state(neighbour_liquids, current_liquid_id)', liquid_bridge)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY', liquid_bridge)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS', liquid_bridge)
        self.assertIn('properties.get("consumeLiquid", [])', liquid_bridge)
        self.assertIn('properties.get("liquidCapacity", 10.0)', liquid_bridge)
        self.assertIn('properties.get("hasLiquids", false)', liquid_bridge)
        self.assertIn('str(row.get("liquid", "")) == current_liquid_name', liquid_bridge)
        # The dumped liquid is liquids.current(): the fill
        # reads the current id from the advanced store (the
        # same read the N2287 doDump pure makes) and resolves
        # its name through liquid_names_by_id (catalog order,
        # index = liquid id, the PayloadLoader precedent).
        self.assertIn('var current_liquid_id: int = int(liquids.get("current", -1))', liquid_bridge)
        self.assertIn('str(liquid_names_by_id[current_liquid_id])', liquid_bridge)
        # The fill returns EIGHT parallel arrays, one per
        # frame neighbour input (the N2394 parallel-array
        # shape + the N2408 Fracker 8-field shape -- NOT the
        # N2408 dict array: the N2287 doDump pure reads
        # eight frame arrays at :540).
        self.assertIn('return {"dump_neighbour_amounts": dump_neighbour_amounts, "dump_neighbour_capacities": dump_neighbour_capacities, "dump_neighbour_accepts": dump_neighbour_accepts, "dump_neighbour_has_liquids": dump_neighbour_has_liquids, "dump_neighbour_can_dump": dump_neighbour_can_dump, "dump_neighbour_liquids_present": dump_neighbour_liquids_present, "dump_neighbour_destination_present": dump_neighbour_destination_present, "dump_neighbour_relative_to": dump_neighbour_relative_to}', liquid_bridge)
        # The fill is called exactly once (its definition plus
        # the one tick call site), in the unlinked branch,
        # with the origin cell inline (the N2363 note), the
        # catalog size, the advanced store, and the tick's
        # liquid_names_by_id.
        self.assertEqual(liquid_bridge.count('source_liquid_bridge_dodump_neighbour_live_fill_state('), 2)
        self.assertIn('source_liquid_bridge_dodump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), advanced["liquids_after"], liquid_names_by_id)', liquid_bridge)
        # The tick wires the fill BEFORE the dump reads the
        # frame arrays at :540: a supplied array WINS (the
        # N2381 / N2394 precedent -- the N2287/N2379 proofs
        # seed the arrays by hand, so a fill there would
        # overwrite the seed), and a previously live-filled
        # frame (dump_neighbour_live -- port bookkeeping, not
        # Java state) refreshes every tick.
        self.assertIn('has_supplied_dump_neighbour_arrays', liquid_bridge)
        self.assertIn('frame.has("dump_neighbour_amounts")', liquid_bridge)
        self.assertIn('frame.has("dump_neighbour_capacities")', liquid_bridge)
        self.assertIn('frame.has("dump_neighbour_accepts")', liquid_bridge)
        self.assertIn('frame.has("dump_neighbour_has_liquids")', liquid_bridge)
        self.assertIn('frame.has("dump_neighbour_can_dump")', liquid_bridge)
        self.assertIn('frame.has("dump_neighbour_liquids_present")', liquid_bridge)
        self.assertIn('frame.has("dump_neighbour_destination_present")', liquid_bridge)
        self.assertIn('frame.has("dump_neighbour_relative_to")', liquid_bridge)
        self.assertIn('frame["dump_neighbour_live"] = true', liquid_bridge)
        self.assertIn('bool(frame.get("dump_neighbour_live", false))', liquid_bridge)
        self.assertLess(
            liquid_bridge.index('source_liquid_bridge_dodump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), advanced["liquids_after"], liquid_names_by_id)'),
            liquid_bridge.index('var dump_neighbours: Dictionary = {"amounts": frame.get("dump_neighbour_amounts", [])'),
        )
        self.assertLess(
            liquid_bridge.index('frame["dump_neighbour_amounts"] = filled.get("dump_neighbour_amounts", [])'),
            liquid_bridge.index('var dump_neighbours: Dictionary = {"amounts": frame.get("dump_neighbour_amounts", [])'),
        )
        self.assertLess(
            liquid_bridge.index('frame["dump_neighbour_relative_to"] = filled.get("dump_neighbour_relative_to", [])'),
            liquid_bridge.index('var dump_neighbours: Dictionary = {"amounts": frame.get("dump_neighbour_amounts", [])'),
        )
        # The N2287 dump pins still hold: the dump call, the
        # frame-input read, the cursor write-back, and the
        # dump doc strings. The N2379 write-back pins still
        # hold: the handled index, the dumped liquid id, the
        # liquid_names_by_id build, and the helper call.
        self.assertIn('source_liquid_bridge_do_dump_state(frame, bool(frame.get("had_valid_link", false)), advanced["liquids_after"], SOURCE_LIQUID_BRIDGE_LIQUID_CAPACITY, dump_neighbours)', liquid_bridge)
        self.assertIn('frame["cdump"] = dumped["cursor_after"]', liquid_bridge)
        self.assertIn('dumped["liquids_after"]', liquid_bridge)
        self.assertIn('dump_neighbour_index = int(dump.get("handled_index", -1))', liquid_bridge)
        self.assertIn('"dump_neighbour_index": dump_neighbour_index, "dumped_liquid_id": liquid_id', liquid_bridge)
        self.assertIn('liquid_names_by_id.append(liquid.id)', liquid_bridge)
        self.assertIn('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, dumped_liquid_name, float(dumped.get("dumped_amount", 0.0)))', liquid_bridge)
        self.assertIn('doDump live (N2287)', liquid_bridge)
        self.assertIn('Dump neighbour write-back live since N2379', liquid_bridge)
        self.assertIn('updateTransport advance live (N2275)', liquid_bridge)
        self.assertIn('shouldConsume gate live (N2198)', liquid_bridge)
        # The documented limits now record the doDump
        # neighbour live fill as live (N2412), and the old
        # "no live proximity fill yet" text is gone.
        self.assertIn('live-filled since N2412', liquid_bridge)
        self.assertNotIn('no live proximity fill yet', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_do_dump_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_update_transport_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_should_consume_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_tick_buildings_state', liquid_bridge)
        # The shared helpers exist with their N2353/N2371
        # contracts (index i is ring cell i; no sprite / no
        # frame / no store reports written false).
        liquid_state = BUILDING_LIQUID_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_neighbour_liquid_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, liquid: String, amount: float) -> Dictionary:', liquid_state)
        self.assertIn('"no_frame"', liquid_state)
        geometry = BLOCK_GEOMETRY.read_text(encoding='utf-8')
        self.assertIn('static func source_block_proximity_cells_state(block_size: int, tile_x: int, tile_y: int) -> Dictionary:', geometry)
        # Scope pins, by Java line number: the default gates
        # (BuildingComp.java:868-870, :896, :901-905, :910-912,
        # :980-982), the filter read (Block.java:778-779), the
        # doDump override (LiquidBridge.java:29-31), and the
        # def constants (Blocks.java:2385, :2395).
        building_comp_lines = BUILDING_COMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(building_comp_lines[867].strip(), 'public boolean acceptLiquid(Building source, Liquid liquid){')
        self.assertEqual(building_comp_lines[868].strip(), 'return block.hasLiquids && block.consumesLiquid(liquid);')
        self.assertEqual(building_comp_lines[895].strip(), 'Building other = proximity.get((i + dump) % proximity.size);')
        self.assertEqual(building_comp_lines[900].strip(), 'if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){')
        self.assertEqual(building_comp_lines[901].strip(), 'float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;')
        self.assertEqual(building_comp_lines[904].strip(), 'if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);')
        self.assertEqual(building_comp_lines[909].strip(), 'public boolean canDumpLiquid(Building to, Liquid liquid){')
        self.assertEqual(building_comp_lines[910].strip(), 'return true;')
        self.assertEqual(building_comp_lines[979].strip(), 'public Building getLiquidDestination(Building from, Liquid liquid){')
        self.assertEqual(building_comp_lines[980].strip(), 'return self();')
        block_lines = BLOCK_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(block_lines[777].strip(), 'public boolean consumesLiquid(Liquid liq){')
        self.assertEqual(block_lines[778].strip(), 'return liquidFilter[liq.id];')
        liquid_bridge_lines = LIQUID_BRIDGE_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(liquid_bridge_lines[28].strip(), 'public void doDump(){')
        self.assertEqual(liquid_bridge_lines[29].strip(), 'dumpLiquid(liquids.current(), 1f);')
        blocks_lines = BLOCKS_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(blocks_lines[2384].strip(), 'phaseConduit = new LiquidBridge("phase-conduit"){{')
        self.assertEqual(blocks_lines[2394].strip(), 'liquidCapacity = 100f;')
        # The proof's keys drive the fill (the liquid arrays
        # from live neighbours, the accepts gates, the
        # capacity fill, the no-frame outcome) plus the live
        # tick (a live bridge with NO seeded arrays dumps
        # through the live fill).
        proof = LIQUID_BRIDGE_DODUMP_NEIGHBOUR_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'fill_liquid_arrays_from_live_neighbours',
            'fill_accepts_gate_requires_has_liquids',
            'fill_accepts_gate_requires_consumes_liquid',
            'fill_capacity_from_live_neighbour',
            'fill_no_frame_neighbour_reports_empty',
            'live_tick_dumps_with_live_fill',
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
        self.assertIn('preload("res://src/game/SourceLiquidBridgeBuildState.gd")', proof)
        self.assertTrue(LIQUID_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('liquid_bridge_build_state.source_liquid_bridge_dodump_neighbour_live_fill_state(', proof)
        self.assertIn('liquid_bridge_build_state.source_liquid_bridge_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = LIQUID_BRIDGE_DODUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LiquidBridgeDodumpNeighbourLiveFillProof.gd', scene)
        self.assertIn('C07LiquidBridgeDodumpNeighbourLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_liquid_bridge_dodump_neighbour_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgeDodumpNeighbourLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_DODUMP_NEIGHBOUR_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fill_liquid_arrays_from_live_neighbours',
            'fill_accepts_gate_requires_has_liquids',
            'fill_accepts_gate_requires_consumes_liquid',
            'fill_capacity_from_live_neighbour',
            'fill_no_frame_neighbour_reports_empty',
            'live_tick_dumps_with_live_fill',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
