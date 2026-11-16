import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceMechanicalPumpBuildState.gd'
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PumpDumpNeighbourLiveFillProof.gd'
PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PumpDumpNeighbourLiveFillProof.tscn'
PUMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/Pump.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'
BLOCKS_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java'
CONDUIT_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/liquid/Conduit.java'


class C07PumpDumpNeighbourLiveFillTests(unittest.TestCase):
    def test_c07_pump_dump_neighbour_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2410']['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_neighbour_live_fill_state')
        # N2285 ported the dumpLiquid rows (if(liquidDrop !=
        # null) dumpLiquid(liquidDrop), Pump.java:178-180,
        # after the advance) -- but the neighbour arrays
        # stayed frame inputs (default []), so a live pump
        # with no fill read an empty proximity and never
        # dumped. N2378 wired the neighbour write-back (the
        # shared source_neighbour_liquid_write_back_state
        # helper lands the routed water in the handled
        # neighbour's store) -- but with no fill the routing
        # never ran. N2410 is the live fill: the tick scans
        # the live proximity (the
        # source_block_proximity_cells_state ring, index i is
        # ring cell i, the N2353 convention) BEFORE the dump
        # pure and fills the four neighbour arrays from the
        # live neighbour frames -- liquid amount / capacity
        # from the neighbour liquids modules, accepts/canDump
        # from the DEFAULT BuildingComp gates (acceptLiquid
        # is hasLiquids && consumesLiquid, :868-870;
        # canDumpLiquid defaults to true, :910-912).
        # Per-block overrides are OUT of scope (a neighbour
        # with a modeled override is evaluated with the
        # DEFAULT gate here -- the override dispatch is a
        # follow-through note, not a new DEFERRED entry).
        # Unlike the Fracker's def constant "oil", the pumped
        # liquid VARIES BY TILE: liquid_drop is a String NAME
        # (the N2378 precedent), so the fill takes the NAME
        # + the liquid_id_by_name map, like the N2285 dump
        # pure. Four new symbols: the four filled arrays.
        self.assertEqual(
            ledger['N2410']['source_symbols'],
            [
                'source_mechanical_pump_dump_neighbour_live_fill_state_result.dump_neighbour_amounts',
                'source_mechanical_pump_dump_neighbour_live_fill_state_result.dump_neighbour_capacities',
                'source_mechanical_pump_dump_neighbour_live_fill_state_result.dump_neighbour_accepts',
                'source_mechanical_pump_dump_neighbour_live_fill_state_result.dump_neighbour_can_dump',
            ],
        )
        for name in ledger['N2410']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Pump.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_neighbour_live_fill_state')
        self.assertEqual(ledger['N2410']['runtime_proof'], '/root/C07PumpDumpNeighbourLiveFillProof')
        self.assertEqual(
            ledger['N2410']['tests'],
            [
                'test_c07_pump_dump_neighbour_live_fill_registration',
                'test_all_c07_pump_dump_neighbour_live_fill_input_evidence_is_exact',
                'test_pump_dump_neighbour_live_fill_state',
                'test_reference_graph_and_actual_c07_pump_dump_neighbour_live_fill',
            ],
        )
        self.assertTrue(ledger['N2410']['deferred_exprs'])
        # This slice RESOLVES the Pump dump neighbour live
        # fill entry (DEFERRED #228 in the coordinator's
        # merged numbering, base DEFERRED-after-advances-23,
        # 291 entries): the fill is live now, so the entry
        # is REMOVED and the list drops to 290. No new entry:
        # the override-dispatch follow-through is a note, not
        # a deferral. The Fracker campaign unlock, the
        # SolidPump dump neighbour live fill, the Pump
        # tick-scan proximity, and the scenario-pump gate
        # entries stay verbatim.
        self.assertEqual(len(ledger['N2410']['deferred_exprs']), 290)
        self.assertFalse(any(entry.startswith('Pump dump neighbour live fill (') for entry in ledger['N2410']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid campaign unlock (') for entry in ledger['N2410']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dump neighbour live fill (') for entry in ledger['N2410']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump tick-scan proximity for the shouldConsume gate (') for entry in ledger['N2410']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump shouldConsume gate on the scenario pump path (') for entry in ledger['N2410']['deferred_exprs']))

    def test_all_c07_pump_dump_neighbour_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2410']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_neighbour_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2410']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_pump_dump_neighbour_live_fill_state(self):
        pump = PUMP_STATE.read_text(encoding='utf-8')
        # The live fill (N2410, DEFERRED #228): the tick fills
        # the four neighbour arrays from the live proximity
        # BEFORE the dump pure reads them. Index i is ring
        # cell i (the N2353 convention -- the ring comes from
        # source_block_proximity_cells_state, the sprite from
        # block_sprite_at_cell, the frame from the first
        # SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
        # the N2353/N2371 resolution path). The dumped liquid
        # VARIES BY TILE: liquid_drop is a String NAME (the
        # N2378 precedent -- "liquid_drop is a String NAME
        # varying by tile"), NOT a constant id (unlike
        # SolidPump's water or Fracker's oil) -- so the fill
        # takes the NAME + the liquid_id_by_name map, like
        # the N2285 dump pure: the consumeLiquid rows match
        # on the NAME, and the amount read resolves the id
        # through the same map the dump pure uses.
        # Per-neighbour amount / capacity come from the
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
        # gates and nothing routes there). Keep each Java
        # expr on ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_mechanical_pump_dump_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, liquid_drop: Variant, liquid_id_by_name: Dictionary) -> Dictionary:', pump)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', pump)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', pump)
        self.assertIn('return block.hasLiquids && block.consumesLiquid(liquid);', pump)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', pump)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', pump)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', pump)
        self.assertIn('public boolean consumesLiquid(Liquid liq){', pump)
        self.assertIn('return liquidFilter[liq.id];', pump)
        self.assertIn('public Building getLiquidDestination(Building from, Liquid liquid){', pump)
        self.assertIn('liquidCapacity = Mathf.round(10f * consumeAmount);', pump)
        self.assertIn('public @Nullable Liquid liquidDrop = null;', pump)
        self.assertIn('dumpLiquid(liquidDrop);', pump)
        # The fill reuses the shared resolution path -- the
        # ring, the cell lookup, the frame-key list, the
        # liquid-module read -- never a hand-rolled scan. The
        # frame-key list comes from a runtime load (the
        # N2371/BeamDrill/N2408 precedent), NOT a preload.
        self.assertIn('load("res://src/game/SourcePlacedPowerGraphState.gd")', pump)
        self.assertIn('source_block_proximity_cells_state(size, cell.x, cell.y)', pump)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', pump)
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', pump)
        self.assertIn('source_get_state(neighbour_liquids, liquid_id)', pump)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY', pump)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS', pump)
        self.assertIn('properties.get("consumeLiquid", [])', pump)
        self.assertIn('properties.get("liquidCapacity", 10.0)', pump)
        self.assertIn('properties.get("hasLiquids", false)', pump)
        self.assertIn('str(row.get("liquid", "")) == liquid_name', pump)
        self.assertIn('"dump_neighbour_amounts": neighbour_amounts, "dump_neighbour_capacities": neighbour_capacities, "dump_neighbour_accepts": neighbour_accepts, "dump_neighbour_can_dump": neighbour_can_dump', pump)
        # The fill is called exactly once (its definition plus
        # the one tick call site), with the bound cell (cell
        # is bound before the enabled block, so no N2363-style
        # workaround is needed), the catalog size, the
        # proximity liquid_drop NAME, and the id map.
        self.assertEqual(pump.count('source_mechanical_pump_dump_neighbour_live_fill_state('), 2)
        self.assertIn('source_mechanical_pump_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), proximity.get("liquid_drop", null), liquid_id_by_name)', pump)
        # The tick wires the fill BEFORE the dump reads the
        # frame arrays: a supplied array WINS (the N2381
        # precedent -- the N2285/N2378 proofs seed the four
        # arrays by hand, so a fill there would overwrite the
        # seed), and a previously live-filled frame
        # (dump_neighbour_live -- port bookkeeping, not Java
        # state) refreshes every tick.
        self.assertIn('has_supplied_dump_neighbour_arrays', pump)
        self.assertIn('frame["dump_neighbour_live"] = true', pump)
        self.assertIn('bool(frame.get("dump_neighbour_live", false))', pump)
        self.assertLess(
            pump.index('source_mechanical_pump_dump_neighbour_live_fill_state(game, cell, int(block.properties.get("size", 1)), proximity.get("liquid_drop", null), liquid_id_by_name)'),
            pump.index('frame.get("dump_neighbour_amounts", [])'),
        )
        self.assertLess(
            pump.index('frame["dump_neighbour_amounts"] = filled.get("dump_neighbour_amounts", [])'),
            pump.index('frame.get("dump_neighbour_amounts", [])'),
        )
        # The N2285 dump pins still hold: the dump call, the
        # frame-input reads, the 2-call count, and the dump
        # doc strings.
        self.assertIn('source_mechanical_pump_dump_liquid_state(frame, proximity.get("liquid_drop", null), liquids, _liquid_capacity_for_block_id(block_id), liquid_id_by_name, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)', pump)
        self.assertEqual(pump.count('source_mechanical_pump_dump_liquid_state('), 2)
        self.assertIn('Dump rows live (N2285)', pump)
        self.assertIn('neighbour write-back live since N2378', pump)
        self.assertIn('shouldConsume gate live (N2205)', pump)
        self.assertIn('updateTile advance (N2221)', pump)
        # The documented limits now record the dump neighbour
        # live fill as live (N2410).
        self.assertIn('live-filled since N2410', pump)
        self.assertIn('static func source_mechanical_pump_dump_liquid_state', pump)
        self.assertIn('static func source_mechanical_pump_update_tile_advance_state', pump)
        self.assertIn('static func source_mechanical_pump_should_consume_state', pump)
        self.assertIn('static func source_mechanical_pump_tick_buildings_state', pump)
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
        # conduit override (Conduit.java:242-244), the pump
        # drop field + dump call (Pump.java:114, :140, :160,
        # :178-179), and the rotary-pump def
        # (Blocks.java:2308, :2310).
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
        conduit_lines = CONDUIT_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(conduit_lines[241].strip(), 'public boolean acceptLiquid(Building source, Liquid liquid){')
        self.assertEqual(conduit_lines[242].strip(), 'noSleep();')
        pump_lines = PUMP_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(pump_lines[113].strip(), 'public @Nullable Liquid liquidDrop = null;')
        self.assertEqual(pump_lines[139].strip(), 'public void onProximityUpdate(){')
        self.assertEqual(pump_lines[159].strip(), 'public void updateTile(){')
        self.assertEqual(pump_lines[177].strip(), 'if(liquidDrop != null){')
        self.assertEqual(pump_lines[178].strip(), 'dumpLiquid(liquidDrop);')
        blocks_lines = BLOCKS_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(blocks_lines[2307].strip(), 'liquidCapacity = 80f;')
        self.assertEqual(blocks_lines[2309].strip(), 'size = 2;')
        # The proof's keys drive the fill (the liquid arrays
        # from live neighbours, the accepts gates, the
        # capacity fill, the no-frame outcome) plus the live
        # tick (a live pump with NO seeded neighbours dumps
        # through the live fill).
        proof = PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF.read_text(encoding='utf-8')
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
        self.assertIn('preload("res://src/game/SourceMechanicalPumpBuildState.gd")', proof)
        self.assertTrue(PUMP_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceFactoryBuildState.gd")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd').is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('mechanical_pump_build_state.source_mechanical_pump_dump_neighbour_live_fill_state(', proof)
        self.assertIn('mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertIn('write_proof("C07PumpDumpNeighbourLiveFillProof"', proof)
        scene = PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PumpDumpNeighbourLiveFillProof.gd', scene)
        self.assertIn('[node name="C07PumpDumpNeighbourLiveFillProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_pump_dump_neighbour_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PumpDumpNeighbourLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PUMP_DUMP_NEIGHBOUR_LIVE_FILL_PROOF ')]
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
