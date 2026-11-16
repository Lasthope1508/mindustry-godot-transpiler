import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FRACKER_STATE = ROOT / 'godot-mindustry/src/game/SourceFrackerBuildState.gd'
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
FRACKER_DUMP_LIQUID_NEIGHBOUR_LIVE_FILL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerDumpLiquidNeighbourLiveFillProof.gd'
FRACKER_DUMP_LIQUID_NEIGHBOUR_LIVE_FILL_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07FrackerDumpLiquidNeighbourLiveFillProof.tscn'
FRACKER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/production/Fracker.java'
BUILDING_COMP_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'
BLOCKS_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/content/Blocks.java'


class C07FrackerDumpLiquidNeighbourLiveFillTests(unittest.TestCase):
    def test_c07_fracker_dump_liquid_neighbour_live_fill_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2408']['godot_owner'], 'SourceFrackerBuildState.source_fracker_dump_liquid_neighbour_live_fill_state')
        # N2284 ported the dumpLiquid rows (dumpLiquid(result)
        # 2f after the advance in BOTH updateTile branches,
        # Fracker.java:42 / SolidPump.java:140) -- but the
        # neighbour entries stayed frame inputs (default []),
        # so a live fracker with no fill read an empty
        # proximity and never dumped. N2371 wired the
        # neighbour write-back (the shared
        # source_neighbour_liquid_write_back_state helper
        # lands the routed oil in the handled neighbour's
        # store) -- but with no fill the routing never ran.
        # N2408 is the live fill: the tick scans the live
        # proximity (the source_block_proximity_cells_state
        # ring, index i is ring cell i, the N2353 convention)
        # BEFORE the dump pure and fills the neighbour dict
        # array from the live neighbour frames -- liquid
        # amount / capacity from the neighbour liquids
        # modules, accepts/canDump from the DEFAULT
        # BuildingComp gates (acceptLiquid is hasLiquids &&
        # consumesLiquid, :868-870; canDumpLiquid defaults to
        # true, :910-912). Per-block overrides are OUT of
        # scope (a neighbour with a modeled override is
        # evaluated with the DEFAULT gate here -- the
        # override dispatch is a follow-through note, not a
        # new DEFERRED entry). One new symbol: the filled
        # neighbour dict array.
        self.assertEqual(
            ledger['N2408']['source_symbols'],
            [
                'source_fracker_dump_liquid_neighbour_live_fill_state_result.dump_liquid_neighbours',
            ],
        )
        for name in ledger['N2408']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Fracker.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_dump_liquid_neighbour_live_fill_state')
        self.assertEqual(ledger['N2408']['runtime_proof'], '/root/C07FrackerDumpLiquidNeighbourLiveFillProof')
        self.assertEqual(
            ledger['N2408']['tests'],
            [
                'test_c07_fracker_dump_liquid_neighbour_live_fill_registration',
                'test_all_c07_fracker_dump_liquid_neighbour_live_fill_input_evidence_is_exact',
                'test_fracker_dump_liquid_neighbour_live_fill_state',
                'test_reference_graph_and_actual_c07_fracker_dump_liquid_neighbour_live_fill',
            ],
        )
        self.assertTrue(ledger['N2408']['deferred_exprs'])
        # This slice RESOLVES the Fracker dumpLiquid
        # neighbour live fill entry (DEFERRED #230 in the
        # coordinator's merged numbering, base
        # DEFERRED-after-advances-22, 298 entries): the fill
        # is live now, so the entry is REMOVED and the list
        # drops to 297. No new entry: the override-dispatch
        # follow-through is a note, not a deferral. The
        # campaign unlock, the item intake, and the SolidPump
        # dump neighbour live fill entries stay verbatim.
        self.assertEqual(len(ledger['N2408']['deferred_exprs']), 297)
        self.assertFalse(any(entry.startswith('Fracker dumpLiquid neighbour live fill (') for entry in ledger['N2408']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker dumpLiquid campaign unlock (') for entry in ledger['N2408']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Fracker item intake (') for entry in ledger['N2408']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dump neighbour live fill (') for entry in ledger['N2408']['deferred_exprs']))

    def test_all_c07_fracker_dump_liquid_neighbour_live_fill_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2408']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceFrackerBuildState.source_fracker_dump_liquid_neighbour_live_fill_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Fracker.java',
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2408']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_fracker_dump_liquid_neighbour_live_fill_state(self):
        fracker = FRACKER_STATE.read_text(encoding='utf-8')
        # The live fill (N2408, DEFERRED #230): the tick fills
        # the neighbour dict array from the live proximity
        # BEFORE the dump pure reads it. Index i is ring
        # cell i (the N2353 convention -- the ring comes from
        # source_block_proximity_cells_state, the sprite from
        # block_sprite_at_cell, the frame from the first
        # SOURCE_CONSUMER_FRAME_META_KEYS meta on the sprite,
        # the N2353/N2371 resolution path). The dumped liquid
        # is the fixed def result oil (not liquids.current(),
        # the N2394 unloader case) -- the fill takes the
        # result liquid id as a param, like the N2284 dump
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
        # outcome -- 0.0 / 0.0 / false / false / false /
        # false / false / 0 -- the N2353/N2371 no-frame
        # precedent (a routed liquid to a frameless neighbour
        # drops, so the fill closes the gates and nothing
        # routes there). Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line fails this
        # test).
        self.assertIn('static func source_fracker_dump_liquid_neighbour_live_fill_state(game: Object, cell: Vector2i, size: int, result_liquid_id: int) -> Dictionary:', fracker)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', fracker)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', fracker)
        self.assertIn('return block.hasLiquids && block.consumesLiquid(liquid);', fracker)
        self.assertIn('public boolean canDumpLiquid(Building to, Liquid liquid){', fracker)
        self.assertIn('if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){', fracker)
        self.assertIn('float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;', fracker)
        self.assertIn('public boolean consumesLiquid(Liquid liq){', fracker)
        self.assertIn('return liquidFilter[liq.id];', fracker)
        self.assertIn('public Building getLiquidDestination(Building from, Liquid liquid){', fracker)
        self.assertIn('liquidCapacity = Mathf.round(10f * consumeAmount);', fracker)
        # The fill reuses the shared resolution path -- the
        # ring, the cell lookup, the frame-key list, the
        # liquid-module read -- never a hand-rolled scan. The
        # frame-key list comes from a runtime load (the
        # N2371/BeamDrill precedent), NOT a preload: a
        # preload line above the tick would shift the :633
        # frame-sync pin (test_c07_fracker_cite_sweep).
        self.assertIn('load("res://src/game/SourcePlacedPowerGraphState.gd")', fracker)
        self.assertIn('source_block_proximity_cells_state(size, cell.x, cell.y)', fracker)
        self.assertIn('game.call("block_sprite_at_cell", neighbour_cell)', fracker)
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', fracker)
        self.assertIn('source_get_state(neighbour_liquids, result_liquid_id)', fracker)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY', fracker)
        self.assertIn('SOURCE_NEIGHBOUR_CONDUIT_BLOCK_IDS', fracker)
        self.assertIn('properties.get("consumeLiquid", [])', fracker)
        self.assertIn('properties.get("liquidCapacity", 10.0)', fracker)
        self.assertIn('properties.get("hasLiquids", false)', fracker)
        self.assertIn('str(row.get("liquid", "")) == SOURCE_FRACKER_RESULT_LIQUID', fracker)
        self.assertIn('"dump_liquid_neighbours": neighbours', fracker)
        # The fill builds ONE dict entry per ring cell with
        # the exact N2284 dict shape (amount / capacity /
        # accepts / has_liquids / can_dump / liquids_present
        # / destination_present / relative_to).
        self.assertIn('{"amount": amount, "capacity": capacity, "accepts": accepts, "has_liquids": has_liquids, "can_dump": can_dump, "liquids_present": liquids_present, "destination_present": destination_present, "relative_to": relative_to}', fracker)
        # The fill is called exactly once (its definition plus
        # the one tick call site), with the origin cell inline
        # (cell is bound after the enabled block, the N2363
        # note), the catalog size, and the resolved result id.
        self.assertEqual(fracker.count('source_fracker_dump_liquid_neighbour_live_fill_state('), 2)
        self.assertIn('source_fracker_dump_liquid_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), advance_result_id)', fracker)
        # The tick wires the fill BEFORE the dump reads the
        # frame array: a supplied array WINS (the N2381
        # precedent -- the N2284 proof seeds
        # dump_liquid_neighbours by hand, so a fill there
        # would overwrite the seed), and a previously
        # live-filled frame (dump_liquid_neighbours_live --
        # port bookkeeping, not Java state) refreshes every
        # tick.
        self.assertIn('has_supplied_dump_liquid_neighbours', fracker)
        self.assertIn('frame["dump_liquid_neighbours_live"] = true', fracker)
        self.assertIn('bool(frame.get("dump_liquid_neighbours_live", false))', fracker)
        self.assertLess(
            fracker.index('source_fracker_dump_liquid_neighbour_live_fill_state(game, fill_cell, int(block.properties.get("size", 1)), advance_result_id)'),
            fracker.index('frame.get("dump_liquid_neighbours", [])'),
        )
        self.assertLess(
            fracker.index('frame["dump_liquid_neighbours"] = dump_filled.get("dump_liquid_neighbours", [])'),
            fracker.index('frame.get("dump_liquid_neighbours", [])'),
        )
        # The N2284 dump pins still hold: the dump call, the
        # frame-input read, the 2-call count, and the dump
        # doc strings.
        self.assertIn('source_fracker_dump_liquid_state(frame, advance_result_id, SOURCE_FRACKER_LIQUID_CAPACITY, dump_neighbours)', fracker)
        self.assertEqual(fracker.count('source_fracker_dump_liquid_state('), 2)
        self.assertIn('dumpLiquid live (N2284)', fracker)
        self.assertIn('neighbour write-back live since N2371', fracker)
        self.assertIn('shouldConsume gate live (N2207)', fracker)
        self.assertIn('updateTile advance live (N2224)', fracker)
        self.assertIn('Fraction fill live (N2305)', fracker)
        # The documented limits now record the dump neighbour
        # live fill as live (N2408).
        self.assertIn('live-filled since N2408', fracker)
        self.assertIn('static func source_fracker_dump_liquid_state', fracker)
        self.assertIn('static func source_fracker_update_tile_advance_state', fracker)
        self.assertIn('static func source_fracker_should_consume_state', fracker)
        self.assertIn('static func source_fracker_tick_buildings_state', fracker)
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
        # else-branch dump (Fracker.java:42), and the def
        # constants (Blocks.java:2966, :2971).
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
        fracker_lines = FRACKER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(fracker_lines[41].strip(), 'dumpLiquid(result);')
        blocks_lines = BLOCKS_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(blocks_lines[2965].strip(), 'result = Liquids.oil;')
        self.assertEqual(blocks_lines[2970].strip(), 'liquidCapacity = 40f;')
        # The proof's keys drive the fill (the liquid entries
        # from live neighbours, the accepts gates, the
        # capacity fill, the no-frame outcome) plus the live
        # tick (a live fracker with NO seeded neighbours dumps
        # through the live fill).
        proof = FRACKER_DUMP_LIQUID_NEIGHBOUR_LIVE_FILL_PROOF.read_text(encoding='utf-8')
        for key in [
            'fill_liquid_entries_from_live_neighbours',
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
        self.assertIn('preload("res://src/game/SourceFrackerBuildState.gd")', proof)
        self.assertTrue(FRACKER_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('fracker_build_state.source_fracker_dump_liquid_neighbour_live_fill_state(', proof)
        self.assertIn('fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = FRACKER_DUMP_LIQUID_NEIGHBOUR_LIVE_FILL_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07FrackerDumpLiquidNeighbourLiveFillProof.gd', scene)
        self.assertIn('C07FrackerDumpLiquidNeighbourLiveFillProof', scene)

    def test_reference_graph_and_actual_c07_fracker_dump_liquid_neighbour_live_fill(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07FrackerDumpLiquidNeighbourLiveFillProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_FRACKER_DUMP_LIQUID_NEIGHBOUR_LIVE_FILL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fill_liquid_entries_from_live_neighbours',
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
