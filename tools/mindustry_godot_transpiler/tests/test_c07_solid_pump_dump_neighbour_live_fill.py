import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
SOLID_PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpDumpNeighbourLiveFillProof.gd'
SOLID_PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpDumpNeighbourLiveFillProof.tscn'
SOLID_PUMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/SolidPump.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'
BLOCKS_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java'


class C07SolidPumpDumpNeighbourLiveFillTests(unittest.TestCase):
    def test_c07_solid_pump_dump_neighbour_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2411']['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_neighbour_live_fill_state')
        # N2286 ported the dumpLiquid rows (dumpLiquid(result)
        # 2f after the advance, SolidPump.java:140) -- but the
        # neighbour arrays stayed frame inputs (default []),
        # so a live solid pump with no fill read an empty
        # proximity and never dumped. N2377 wired the
        # neighbour write-back (the shared
        # source_neighbour_liquid_write_back_state helper
        # lands the routed water in the handled neighbour's
        # store) -- but with no fill the routing never ran.
        # N2411 is the live fill: the tick scans the live
        # proximity (the source_block_proximity_cells_state
        # ring, index i is ring cell i, the N2353 convention)
        # BEFORE the dump pure and fills the four neighbour
        # arrays from the live neighbour frames -- liquid
        # amount / capacity from the neighbour liquids
        # modules, accepts/canDump from the DEFAULT
        # BuildingComp gates (acceptLiquid is hasLiquids &&
        # consumesLiquid, :868-870; canDumpLiquid defaults to
        # true, :910-912). Per-block overrides are OUT of
        # scope (a neighbour with a modeled override is
        # evaluated with the DEFAULT gate here -- the
        # override dispatch is a follow-through note, not a
        # new DEFERRED entry). Four new symbols: the four
        # filled neighbour arrays.
        self.assertEqual(
            ledger['N2411']['source_symbols'],
            [
                'source_solid_pump_dump_neighbour_live_fill_state_result.dump_neighbour_liquid_amounts',
                'source_solid_pump_dump_neighbour_live_fill_state_result.dump_neighbour_liquid_capacities',
                'source_solid_pump_dump_neighbour_live_fill_state_result.dump_neighbour_accepts_liquid',
                'source_solid_pump_dump_neighbour_live_fill_state_result.dump_neighbour_can_dump_liquid',
            ],
        )
        for name in ledger['N2411']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/SolidPump.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_neighbour_live_fill_state')
        self.assertEqual(ledger['N2411']['runtime_proof'], '/root/C07SolidPumpDumpNeighbourLiveFillProof')
        self.assertEqual(
            ledger['N2411']['tests'],
            [
                'test_c07_solid_pump_dump_neighbour_live_fill_registration',
                'test_all_c07_solid_pump_dump_neighbour_live_fill_input_evidence_is_exact',
                'test_solid_pump_dump_neighbour_live_fill_state',
                'test_reference_graph_and_actual_c07_solid_pump_dump_neighbour_live_fill',
            ],
        )
        self.assertTrue(ledger['N2411']['deferred_exprs'])
        # This slice RESOLVES the SolidPump dump neighbour
        # live fill entry (DEFERRED #230 in the coordinator's
        # merged numbering, base DEFERRED-after-advances-23,
        # 291 entries): the fill is live now, so the entry is
        # REMOVED and the list drops to 290. No new entry:
        # the override-dispatch follow-through is a note, not
        # a deferral. The campaign unlock, the item intake,
        # and the fraction linked-tiles entries stay verbatim.
        self.assertEqual(len(ledger['N2411']['deferred_exprs']), 290)
        self.assertFalse(any(entry.startswith('SolidPump dump neighbour live fill (') for entry in ledger['N2411']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dumpLiquid campaign unlock surfacing (') for entry in ledger['N2411']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2411']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump fraction linked-tiles live fill (') for entry in ledger['N2411']['deferred_exprs']))

    def test_all_c07_solid_pump_dump_neighbour_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2411']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_neighbour_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2411']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_solid_pump_dump_neighbour_live_fill_state(self):
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        # The live fill (N2411, DEFERRED #230): the tick fills
        # the four neighbour arrays from the live proximity
        # BEFORE the dump pure reads them. Index i is ring
        # cell i (the N2353 convention -- the ring comes from
        # source_block_proximity_cells_state, the sprite from
        # block_sprite_at_cell, the frame from the first
        # SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
        # the N2353/N2371 resolution path). The dumped liquid
        # is the fixed def result water (not liquids.current(),
        # the N2394 unloader case) -- the fill takes the
        # result liquid id as a param, like the N2286 dump
        # pure. Per-neighbour amount / capacity come from the
        # neighbour liquids module + the neighbour def's
        # liquidCapacity (the ofract denominator); accepts /
        # canDump come from the DEFAULT gates (acceptLiquid
        # is hasLiquids && consumesLiquid, BuildingComp.java:
        # 868-870; canDumpLiquid defaults to true, :910-912).
        # consumesLiquid reads the liquidFilter
        # (Block.java:778-779), which the port represents as
        # the catalog consumeLiquid rows. Per-block overrides
        # are OUT of scope: a neighbour with a modeled
        # override is evaluated with the DEFAULT gate here.
        # A neighbour with no frame (no sprite / unknown def
        # / conduit / no meta-key frame) reports the no-frame
        # outcome -- 0.0 / 0.0 / false / false -- the
        # N2353/N2371 no-frame precedent (a routed liquid to
        # a frameless neighbour drops, so the fill closes the
        # gates and nothing routes there). Keep each Java expr
        # on ONE comment line (the N2148 lesson: a split line
        # fails this test).
        self.assertIn('static func source_solid_pump_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, result_liquid_id: int) -> Dictionary:', solid_pump)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', solid_pump)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', solid_pump)
        self.assertIn('return block.hasLiquids && block.consumesLiquid(liquid);', solid_pump)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', solid_pump)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', solid_pump)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', solid_pump)
        self.assertIn('public boolean consumesLiquid(Liquid liq){', solid_pump)
        self.assertIn('return liquidFilter[liq.id];', solid_pump)
        self.assertIn('liquidCapacity = Mathf.round(10f * consumeAmount);', solid_pump)
        # The fill reuses the shared resolution path -- the
        # ring, the cell lookup, the frame-key list, the
        # liquid-module read -- never a hand-rolled scan. The
        # frame-key list comes from a runtime load (the
        # N2371/BeamDrill precedent), NOT a preload, and the
        # fill pure lives AFTER the tick function (the N2408
        # precedent).
        self.assertIn('load("res://src/game/SourcePlacedPowerGraphState.gd")', solid_pump)
        self.assertIn('source_block_proximity_cells_state(size, cell.x, cell.y)', solid_pump)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', solid_pump)
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', solid_pump)
        self.assertIn('source_get_state(neighbour_liquids, result_liquid_id)', solid_pump)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY', solid_pump)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS', solid_pump)
        self.assertIn('properties.get("consumeLiquid", [])', solid_pump)
        self.assertIn('properties.get("liquidCapacity", 10.0)', solid_pump)
        self.assertIn('properties.get("hasLiquids", false)', solid_pump)
        self.assertIn('str(row.get("liquid", "")) == SOURCE_SOLID_PUMP_RESULT_LIQUID', solid_pump)
        self.assertIn('"dump_neighbour_liquid_amounts": neighbour_liquid_amounts', solid_pump)
        self.assertIn('"dump_neighbour_liquid_capacities": neighbour_liquid_capacities', solid_pump)
        self.assertIn('"dump_neighbour_accepts_liquid": neighbour_accepts_liquid', solid_pump)
        self.assertIn('"dump_neighbour_can_dump_liquid": neighbour_can_dump_liquid', solid_pump)
        # The fill is called exactly once (its definition plus
        # the one tick call site), with the origin cell inline
        # (cell is bound after the enabled block, the N2363
        # note), the catalog size, and the resolved result id.
        self.assertEqual(solid_pump.count('source_solid_pump_dump_neighbour_live_fill_state('), 2)
        self.assertIn('source_solid_pump_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), advance_result_id)', solid_pump)
        # The tick wires the fill BEFORE the dump reads the
        # frame arrays: a supplied array WINS (the N2381
        # precedent -- the N2286/N2377 proofs seed the arrays
        # by hand, so a fill there would overwrite the seed),
        # and a previously live-filled frame
        # (dump_neighbour_live -- port bookkeeping, not Java
        # state) refreshes every tick.
        self.assertIn('has_supplied_dump_neighbour_arrays', solid_pump)
        self.assertIn('frame["dump_neighbour_live"] = true', solid_pump)
        self.assertIn('bool(frame.get("dump_neighbour_live", false))', solid_pump)
        self.assertLess(
            solid_pump.index('source_solid_pump_dump_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), advance_result_id)'),
            solid_pump.index('frame.get("dump_neighbour_liquid_amounts", [])'),
        )
        self.assertLess(
            solid_pump.index('frame["dump_neighbour_liquid_amounts"] = dump_filled.get("dump_neighbour_liquid_amounts", [])'),
            solid_pump.index('frame.get("dump_neighbour_liquid_amounts", [])'),
        )
        # The N2286 dump pins still hold: the dump call, the
        # frame-input reads, the 2-call count, and the dump
        # doc strings.
        self.assertIn('source_solid_pump_dump_liquid_state(frame, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)', solid_pump)
        self.assertEqual(solid_pump.count('source_solid_pump_dump_liquid_state('), 2)
        self.assertIn('Dump rows live (N2286)', solid_pump)
        self.assertIn('neighbour write-back live since N2377', solid_pump)
        self.assertIn('shouldConsume gate live (N2206)', solid_pump)
        self.assertIn('updateTile advance live (N2220)', solid_pump)
        self.assertIn('Fraction fill live (N2292)', solid_pump)
        # The documented limits now record the dump neighbour
        # live fill as live (N2411).
        self.assertIn('live-filled since N2411', solid_pump)
        self.assertIn('static func source_solid_pump_dump_liquid_state', solid_pump)
        self.assertIn('static func source_solid_pump_update_tile_advance_state', solid_pump)
        self.assertIn('static func source_solid_pump_should_consume_state', solid_pump)
        self.assertIn('static func source_solid_pump_tick_buildings_state', solid_pump)
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
        # dump call (SolidPump.java:140), and the def
        # constants (Blocks.java:2922, :2925).
        building_comp_lines = BUILDING_COMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(building_comp_lines[867].strip(), 'public boolean acceptLiquid(Building source, Liquid liquid){')
        self.assertEqual(building_comp_lines[868].strip(), 'return block.hasLiquids && block.consumesLiquid(liquid);')
        self.assertEqual(building_comp_lines[895].strip(), 'Building other = proximity.get((i + dump) % proximity.size);')
        self.assertEqual(building_comp_lines[900].strip(), 'if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){')
        self.assertEqual(building_comp_lines[901].strip(), 'float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;')
        self.assertEqual(building_comp_lines[904].strip(), 'if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);')
        self.assertEqual(building_comp_lines[909].strip(), 'public boolean canDumpLiquid(Building to, Liquid liquid){')
        self.assertEqual(building_comp_lines[910].strip(), 'return true;')
        block_lines = BLOCK_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(block_lines[777].strip(), 'public boolean consumesLiquid(Liquid liq){')
        self.assertEqual(block_lines[778].strip(), 'return liquidFilter[liq.id];')
        solid_pump_lines = SOLID_PUMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(solid_pump_lines[139].strip(), 'dumpLiquid(result);')
        blocks_lines = BLOCKS_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(blocks_lines[2921].strip(), 'result = Liquids.water;')
        self.assertEqual(blocks_lines[2924].strip(), 'liquidCapacity = 40f;')
        # The proof's keys drive the fill (the liquid arrays
        # from live neighbours, the accepts gates, the
        # capacity fill, the no-frame outcome) plus the live
        # tick (a live solid pump with NO seeded arrays dumps
        # through the live fill).
        proof = SOLID_PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF.read_text(encoding='utf-8')
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
        self.assertIn('preload("res://src/game/SourceSolidPumpBuildState.gd")', proof)
        self.assertTrue(SOLID_PUMP_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('solid_pump_build_state.source_solid_pump_dump_neighbour_live_fill_state(', proof)
        self.assertIn('solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = SOLID_PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SolidPumpDumpNeighbourLiveFillProof.gd', scene)
        self.assertIn('C07SolidPumpDumpNeighbourLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_solid_pump_dump_neighbour_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SolidPumpDumpNeighbourLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOLID_PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF ')]
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
