import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MECHANICAL_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceMechanicalPumpBuildState.gd'
PUMP_LIQUID_NEIGHBOUR_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PumpLiquidNeighbourWriteBackProof.gd'
PUMP_LIQUID_NEIGHBOUR_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PumpLiquidNeighbourWriteBackProof.tscn'


class C07PumpLiquidNeighbourWriteBackTests(unittest.TestCase):
    def test_c07_pump_liquid_neighbour_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2378']['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_liquid_state')
        # N2285 routed the placed pump's dumped liquid through
        # the shared dump_liquid_state routing -- but the
        # shared port reported only the amounts after, so the
        # dumped liquid left the pump without landing in any
        # neighbour store. Java hands the liquid over for
        # real: `next.handleLiquid(self(), liquid, flow);`
        # (BuildingComp.java:918), and handleLiquid is
        # `liquids.add(liquid, amount);`
        # (BuildingComp.java:872-874). N2378 is the Pump
        # wiring slice (the N2371 Fracker precedent): the
        # advance exposes the handled neighbour index
        # (dump_neighbour_index, from the shared routing's
        # handled_index -- the FIRST eligible neighbour whose
        # transfer actually moved liquid, -1 when nothing
        # moved) + the dumped liquid name (dumped_liquid),
        # and the tick wires the shared
        # source_neighbour_liquid_write_back_state helper
        # after the dump write-back when dumped_amount > 0.
        # Unlike the Fracker (def constant "oil"), the pumped
        # liquid VARIES BY TILE: liquidDrop is the floor
        # drop's name (water / oil / cryofluid / slag /
        # arkycite, source_floor_liquid_drop_state), so
        # dumped_liquid is str(liquid_drop) -- the same
        # resolution the pure already uses for
        # liquid_id_by_name -- and "" on the null-drop path
        # (the tick never calls the helper when nothing
        # dumped). dumped_amount already existed -- no
        # duplicate key. Two new result symbols; the three
        # N2285 symbols are re-listed (the N2369 / N2321
        # shared-ownership precedent). The schema/contract
        # fold waits for a schema-sync slice (the N2367
        # precedent) -- this slice does NOT touch
        # register_c07_pump_dump_liquid.py.
        self.assertEqual(
            ledger['N2378']['source_symbols'],
            [
                'source_mechanical_pump_dump_liquid_state_result.liquids_after',
                'source_mechanical_pump_dump_liquid_state_result.dumped_amount',
                'source_mechanical_pump_dump_liquid_state_result.cursor_after',
                'source_mechanical_pump_dump_liquid_state_result.dump_neighbour_index',
                'source_mechanical_pump_dump_liquid_state_result.dumped_liquid',
            ],
        )
        for name in ledger['N2378']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Pump.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_liquid_state')
        self.assertEqual(ledger['N2378']['runtime_proof'], '/root/C07PumpLiquidNeighbourWriteBackProof')
        self.assertEqual(
            ledger['N2378']['tests'],
            [
                'test_c07_pump_liquid_neighbour_write_back_registration',
                'test_all_c07_pump_liquid_neighbour_write_back_input_evidence_is_exact',
                'test_pump_liquid_neighbour_write_back_state',
                'test_reference_graph_and_actual_c07_pump_liquid_neighbour_write_back',
            ],
        )
        # Base: the coordinator's merged DEFERRED after
        # advances-19 (311) - 1 resolved (Pump dump neighbour
        # write-back, #241) + 0 new = 310. The
        # multi-recipient split is already covered by the
        # N2371 follow-ups entry, which stays for the
        # coordinator to rewrite (the N2363 precedent); the
        # Pump live fill + campaign unlock entries stay too.
        self.assertEqual(len(ledger['N2378']['deferred_exprs']), 310)
        self.assertFalse(any(entry.startswith('Pump dump neighbour write-back (') for entry in ledger['N2378']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour liquid write-back follow-ups (') for entry in ledger['N2378']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump dump neighbour live fill (') for entry in ledger['N2378']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Pump dumpLiquid campaign unlock application (') for entry in ledger['N2378']['deferred_exprs']))

    def test_all_c07_pump_liquid_neighbour_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2378']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMechanicalPumpBuildState.source_mechanical_pump_dump_liquid_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Pump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2378']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_pump_liquid_neighbour_write_back_state(self):
        pump = MECHANICAL_PUMP_STATE.read_text(encoding='utf-8')
        # The Pump dump exposes the handled neighbour index +
        # the dumped liquid name on BOTH return paths
        # (dumped_amount already existed -- no duplicate
        # key). dump_neighbour_index is the shared routing's
        # handled_index (the FIRST eligible neighbour whose
        # transfer actually moved liquid, -1 when nothing
        # moved); dumped_liquid is str(liquid_drop) -- the
        # floor drop's name, which VARIES BY TILE (unlike
        # the Fracker's def constant "oil") -- and "" on the
        # null-drop path. The tick wires the shared helper
        # after the dump write-back when something dumped
        # (Java order: the dump at Pump.java:178-180 runs
        # after the advance, and the write-back lands what
        # the dump routed). This driver already binds `cell`
        # (the origin_cell meta) BEFORE the enabled block,
        # so the wiring needs no N2363-style dump_cell
        # workaround; the catalog size comes from the block
        # properties (the Fracker pattern).
        self.assertIn('return {"liquids_after": liquids_after, "dumped_amount": 0.0, "cursor_after": cdump, "dump_neighbour_index": -1, "dumped_liquid": ""}', pump)
        self.assertIn('return {"liquids_after": liquids_after, "dumped_amount": current - amount_after, "cursor_after": int(dump.get("final_cdump", cdump)), "dump_neighbour_index": int(dump.get("handled_index", -1)), "dumped_liquid": str(liquid_drop)}', pump)
        self.assertIn('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", "")), float(dumped.get("dumped_amount", 0.0)))', pump)
        self.assertIn('if float(dumped.get("dumped_amount", 0.0)) > 0.0:', pump)
        self.assertIn('var dump_index: int = int(dumped.get("dump_neighbour_index", -1))', pump)
        self.assertLess(
            pump.index('frame["cdump"] = dumped["cursor_after"]'),
            pump.index('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", "")), float(dumped.get("dumped_amount", 0.0)))'),
        )
        self.assertLess(
            pump.index('source_mechanical_pump_dump_liquid_state(frame, proximity.get("liquid_drop", null), liquids, _liquid_capacity_for_block_id(block_id), liquid_id_by_name, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)'),
            pump.index('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", "")), float(dumped.get("dumped_amount", 0.0)))'),
        )
        # The documented limits now record the neighbour
        # write-back as live (N2378) with the multi-recipient
        # split + live fill + campaign unlock still deferred;
        # the N2285 dump, the N2221 advance, the N2205 gate,
        # and the N2154 power row are preserved.
        self.assertIn('neighbour write-back live since N2378', pump)
        self.assertIn('Dump rows live (N2285)', pump)
        self.assertIn('updateTile advance (N2221)', pump)
        self.assertIn('shouldConsume gate live (N2205)', pump)
        self.assertIn('static func source_mechanical_pump_power_status_row_state', pump)
        self.assertIn('static func source_mechanical_pump_should_consume_state', pump)
        self.assertIn('static func source_mechanical_pump_update_tile_advance_state', pump)
        self.assertIn('static func source_mechanical_pump_dump_liquid_state', pump)
        # The proof's keys drive the advance's exposed
        # handled index (first transfer / fuller / refusing
        # pair / multi-recipient first / null drop) and the
        # live tick (a dumped pump lands its water in the
        # neighbour frame; a dumped pump next to a wall
        # still loses its water).
        proof = PUMP_LIQUID_NEIGHBOUR_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dump_neighbour_index',
            'live_tick_writes_dumped_water_to_neighbour_frame',
            'live_tick_dumped_water_leaves_pump_without_frame',
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
        self.assertTrue(MECHANICAL_PUMP_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', proof)
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state(', proof)
        self.assertIn('mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertIn('write_proof("C07PumpLiquidNeighbourWriteBackProof"', proof)
        scene = PUMP_LIQUID_NEIGHBOUR_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PumpLiquidNeighbourWriteBackProof.gd', scene)
        self.assertIn('[node name="C07PumpLiquidNeighbourWriteBackProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_pump_liquid_neighbour_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PumpLiquidNeighbourWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PUMP_LIQUID_NEIGHBOUR_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dump_neighbour_index',
            'live_tick_writes_dumped_water_to_neighbour_frame',
            'live_tick_dumped_water_leaves_pump_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
