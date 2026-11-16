import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOLID_PUMP_STATE = ROOT / 'godot-mindustry/src/game/SourceSolidPumpBuildState.gd'
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
BLOCK_GEOMETRY = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
SOLID_PUMP_DUMP_LIQUID_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpDumpLiquidWriteBackProof.gd'
SOLID_PUMP_DUMP_LIQUID_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SolidPumpDumpLiquidWriteBackProof.tscn'


class C07SolidPumpDumpLiquidWriteBackTests(unittest.TestCase):
    def test_c07_solid_pump_dump_liquid_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        self.assertEqual(ledger['N2377']['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_liquid_state')
        # N2286 routed the SolidPump dump through the shared
        # dump_liquid_state routing -- but the shared port
        # reported only the amounts after, so the dumped water
        # left the water-extractor without landing in any
        # neighbour store. Java hands the liquid over for
        # real: `next.handleLiquid(self(), liquid, flow);`
        # (BuildingComp.java:918), and handleLiquid is
        # `liquids.add(liquid, amount);`
        # (BuildingComp.java:872-874). N2377 is the SolidPump
        # wiring of the N2371 shared helper (the Fracker
        # precedent): the dump advance exposes the handled
        # neighbour index (dump_neighbour_index, from the
        # shared routing's handled_index -- the FIRST eligible
        # neighbour whose transfer actually moved liquid, -1
        # when nothing moved) + the dumped liquid name
        # (dumped_liquid, the def constant "water"), and the
        # tick wires the helper after the dump write-back when
        # dumped_amount > 0. dumped_amount already existed --
        # no duplicate key. Two new symbols; the three N2286
        # dump result symbols are re-listed (the N2321
        # shared-ownership precedent, the N2369 pattern). The
        # contract + result schema keep their three keys --
        # the fold waits for a schema-sync slice (the N2367
        # precedent).
        self.assertEqual(
            ledger['N2377']['source_symbols'],
            [
                'source_solid_pump_dump_liquid_state_result.liquids_after',
                'source_solid_pump_dump_liquid_state_result.dumped_amount',
                'source_solid_pump_dump_liquid_state_result.cursor_after',
                'source_solid_pump_dump_liquid_state_result.dump_neighbour_index',
                'source_solid_pump_dump_liquid_state_result.dumped_liquid',
            ],
        )
        for name in ledger['N2377']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/SolidPump.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_liquid_state')
        self.assertEqual(ledger['N2377']['runtime_proof'], '/root/C07SolidPumpDumpLiquidWriteBackProof')
        self.assertEqual(
            ledger['N2377']['tests'],
            [
                'test_c07_solid_pump_dump_liquid_write_back_registration',
                'test_all_c07_solid_pump_dump_liquid_write_back_input_evidence_is_exact',
                'test_solid_pump_dump_liquid_write_back_state',
                'test_reference_graph_and_actual_c07_solid_pump_dump_liquid_write_back',
            ],
        )
        # The schema/contract fold waits for a schema-sync
        # slice (the N2367 precedent): the new keys are
        # registered symbols but NOT contract return keys or
        # schema keys yet.
        self.assertEqual(
            contracts['SourceSolidPumpBuildState.source_solid_pump_dump_liquid_state']['return_keys'],
            ['liquids_after', 'dumped_amount', 'cursor_after'],
        )
        self.assertEqual(
            sorted(schemas['source_solid_pump_dump_liquid_state_result']['keys']),
            ['cursor_after', 'dumped_amount', 'liquids_after'],
        )
        self.assertTrue(ledger['N2377']['deferred_exprs'])
        # This slice resolves the SolidPump dump neighbour
        # write-back entry (#244 in the coordinator's merged
        # numbering after advances-19) and adds no new
        # deferral. The neighbour live fill (the neighbour
        # arrays are still frame inputs, default []), the
        # campaign-unlock surfacing, and the updateEffect
        # chance stay deferred, as does the liquid
        # write-back follow-ups entry (Pump, LiquidBridge,
        # PayloadUnloader still wait for their own wiring).
        self.assertFalse(any(entry.startswith('SolidPump dump neighbour write-back (') for entry in ledger['N2377']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dump neighbour live fill (') for entry in ledger['N2377']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump dumpLiquid campaign unlock surfacing (') for entry in ledger['N2377']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('SolidPump updateEffect chance rows (') for entry in ledger['N2377']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour liquid write-back follow-ups (') for entry in ledger['N2377']['deferred_exprs']))

    def test_all_c07_solid_pump_dump_liquid_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2377']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceSolidPumpBuildState.source_solid_pump_dump_liquid_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/SolidPump.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2377']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_solid_pump_dump_liquid_write_back_state(self):
        solid_pump = SOLID_PUMP_STATE.read_text(encoding='utf-8')
        # The dump advance (N2286) now exposes the handled
        # neighbour index + the dumped liquid name (the N2371
        # Fracker precedent): dump_neighbour_index is the
        # shared routing's handled_index -- the FIRST eligible
        # neighbour whose transfer actually moved liquid
        # (handle_liquid_called AND flow_value > 0), -1 when
        # nothing moved -- and dumped_liquid is the def
        # constant "water" (SOURCE_SOLID_PUMP_RESULT_LIQUID,
        # `result = Liquids.water;`, Blocks.java:2922).
        # dumped_amount already existed -- no duplicate key.
        # The SolidPump pure has a single return path (no
        # early return: the shared routing handles the empty
        # store), so one return dict carries both new keys.
        self.assertIn('return {"liquids_after": liquids, "dumped_amount": current - amount_after, "cursor_after": int(dump.get("final_cdump", cursor)), "dump_neighbour_index": int(dump.get("handled_index", -1)), "dumped_liquid": SOURCE_SOLID_PUMP_RESULT_LIQUID}', solid_pump)
        # The tick wires the shared helper after the dump
        # write-back when something dumped (Java order: the
        # dump at SolidPump.java:140 runs after the advance,
        # and the write-back lands what the dump routed).
        # The tick reads the origin_cell meta inline as
        # dump_cell (cell is bound after the enabled block,
        # the N2363 note) and the catalog size. A failed
        # write-back (no sprite / no frame / no liquids
        # store) drops the water -- the routing already
        # decided, so there is no fallback to the pump's own
        # store (the N2353 precedent). A dump that reaches
        # several neighbours lands the total in the first
        # handled one -- the per-neighbour split waits for
        # its own slice.
        self.assertIn('if float(dumped.get("dumped_amount", 0.0)) > 0.0:', solid_pump)
        self.assertIn('var dump_index: int = int(dumped.get("dump_neighbour_index", -1))', solid_pump)
        self.assertIn('if dump_index >= 0:', solid_pump)
        self.assertIn('var dump_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)', solid_pump)
        self.assertIn('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", SOURCE_SOLID_PUMP_RESULT_LIQUID)), float(dumped.get("dumped_amount", 0.0)))', solid_pump)
        self.assertLess(
            solid_pump.index('frame["cdump"] = dumped["cursor_after"]'),
            solid_pump.index('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", SOURCE_SOLID_PUMP_RESULT_LIQUID)), float(dumped.get("dumped_amount", 0.0)))'),
        )
        self.assertLess(
            solid_pump.index('source_solid_pump_dump_liquid_state(frame, advance_result_id, SOURCE_SOLID_PUMP_LIQUID_CAPACITY, neighbour_amounts, neighbour_capacities, neighbour_accepts, neighbour_can_dump)'),
            solid_pump.index('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid", SOURCE_SOLID_PUMP_RESULT_LIQUID)), float(dumped.get("dumped_amount", 0.0)))'),
        )
        # The documented limits now record the neighbour
        # write-back as live (N2377) and the old "not written
        # into the neighbour frame yet" / "no neighbour
        # write-back" text is gone; the N2286 dump, the N2220
        # advance, the N2206 gate, and the N2292 fraction fill
        # are preserved.
        self.assertIn('neighbour write-back live since N2377', solid_pump)
        self.assertNotIn('no neighbour write-back', solid_pump)
        self.assertNotIn('the dumped liquid is not written into the neighbour frame yet', solid_pump)
        self.assertNotIn('the neighbour write-back waits for its own slice', solid_pump)
        self.assertIn('Dump rows live (N2286)', solid_pump)
        self.assertIn('updateTile advance live (N2220)', solid_pump)
        self.assertIn('shouldConsume gate live (N2206)', solid_pump)
        self.assertIn('Fraction fill live (N2292)', solid_pump)
        self.assertIn('static func source_solid_pump_dump_liquid_state', solid_pump)
        self.assertIn('static func source_solid_pump_update_tile_advance_state', solid_pump)
        self.assertIn('static func source_solid_pump_tick_buildings_state', solid_pump)
        # The pure N2220 advance is untouched: its return dict
        # keeps exactly the five N2220 keys and the dump wires
        # AFTER its call, never inside it.
        self.assertIn('return {"warmup": next_warmup, "pump_time": next_pump_time, "last_pump": last_pump, "max_pump": max_pump, "fraction": fraction}', solid_pump)
        # The proof's keys drive the advance's exposed handled
        # index (first transfer / fuller / refusing /
        # refusing-first pair / multi-recipient first /
        # no-neighbour) and the live tick (a dumped pump lands
        # its water in the neighbour frame; a dumped pump next
        # to a wall still loses its water).
        proof = SOLID_PUMP_DUMP_LIQUID_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dump_neighbour_index',
            'live_tick_writes_dumped_liquid_to_neighbour_frame',
            'live_tick_dumped_liquid_leaves_pump_without_frame',
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
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', proof)
        self.assertTrue(BUILDING_LIQUID_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('solid_pump_build_state.source_solid_pump_dump_liquid_state(', proof)
        self.assertIn('solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = SOLID_PUMP_DUMP_LIQUID_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07SolidPumpDumpLiquidWriteBackProof.gd', scene)
        self.assertIn('C07SolidPumpDumpLiquidWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_solid_pump_dump_liquid_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SolidPumpDumpLiquidWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SOLID_PUMP_DUMP_LIQUID_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dump_neighbour_index',
            'live_tick_writes_dumped_liquid_to_neighbour_frame',
            'live_tick_dumped_liquid_leaves_pump_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
