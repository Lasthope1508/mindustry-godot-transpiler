import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
PAYLOAD_UNLOADER_DUMP_LIQUID_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderDumpLiquidWriteBackProof.gd'
PAYLOAD_UNLOADER_DUMP_LIQUID_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderDumpLiquidWriteBackProof.tscn'


class C07PayloadUnloaderDumpLiquidWriteBackTests(unittest.TestCase):
    def test_c07_payload_unloader_dump_liquid_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2380']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        # N2293 ported the dump rows (dumpLiquid(current) 2f +
        # offloadSpeed x dumpAccumulate() at the end of
        # updateTile, PayloadUnloader.java:105-108) -- but the
        # dumped liquid/item left the store without landing
        # in any neighbour store: Java hands the liquid over
        # for real (`next.handleLiquid(self(), liquid, flow);`,
        # BuildingComp.java:918), and handleLiquid is
        # `liquids.add(liquid, amount);` (BuildingComp.java:
        # 872-874). N2380 is the LIQUID half of that
        # write-back only (the N2371 Fracker precedent): the
        # dump advance exposes dump_neighbour_index (the
        # shared routing's handled_index, the FIRST eligible
        # neighbour whose transfer actually moved liquid, -1
        # when nothing moved) + dumped_liquid_name (the dumped
        # liquid's catalog name), and the tick lands the dumped
        # liquid in the handled neighbour's store through the
        # shared source_neighbour_liquid_write_back_state
        # helper (N2371). KEY COLLISION: the advance ALREADY
        # returns `dumped_liquid` -- but as the FLOAT amount
        # dumped (BuildingComp.java:905), NOT a name -- so this
        # slice exposes the separate dumped_liquid_name String
        # key and does NOT change the old key's meaning. Two
        # new symbols; the six N2293 dump result symbols are
        # re-listed (the N2321 shared-ownership precedent).
        # The schema + contract fold lives in a later
        # schema-sync slice (the N2367 precedent), NOT here.
        self.assertEqual(
            ledger['N2380']['source_symbols'],
            [
                'source_payload_unloader_dump_state_result.liquids_after',
                'source_payload_unloader_dump_state_result.dumped_liquid',
                'source_payload_unloader_dump_state_result.items_after',
                'source_payload_unloader_dump_state_result.dumped_items',
                'source_payload_unloader_dump_state_result.cursor_after',
                'source_payload_unloader_dump_state_result.dump_accum_after',
                'source_payload_unloader_dump_state_result.dump_neighbour_index',
                'source_payload_unloader_dump_state_result.dumped_liquid_name',
            ],
        )
        for name in ledger['N2380']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        self.assertEqual(ledger['N2380']['runtime_proof'], '/root/C07PayloadUnloaderDumpLiquidWriteBackProof')
        self.assertEqual(
            ledger['N2380']['tests'],
            [
                'test_c07_payload_unloader_dump_liquid_write_back_registration',
                'test_all_c07_payload_unloader_dump_liquid_write_back_input_evidence_is_exact',
                'test_payload_unloader_dump_liquid_write_back_state',
                'test_reference_graph_and_actual_c07_payload_unloader_dump_liquid_write_back',
            ],
        )
        self.assertTrue(ledger['N2380']['deferred_exprs'])
        # This slice rewrites the dump neighbour write-back
        # entry IN PLACE (DEFERRED #258 in the coordinator's
        # merged numbering): the liquid half is live since
        # N2380, the item half still waits for its own
        # follow-through slice -- the entry is NOT removed,
        # so the list keeps its 311 entries. The dump
        # neighbour live fill (the neighbour arrays are still
        # frame inputs, default []) stays deferred, and no new
        # deferral is added (the per-neighbour split is already
        # covered by the liquid follow-ups entry).
        self.assertEqual(len(ledger['N2380']['deferred_exprs']), 311)
        rewritten = [entry for entry in ledger['N2380']['deferred_exprs'] if entry.startswith('PayloadUnloader dump neighbour write-back (')]
        self.assertEqual(len(rewritten), 1)
        self.assertIn('LIQUID half is live since N2380', rewritten[0])
        self.assertIn('ITEM half still waits', rewritten[0])
        self.assertTrue(any(entry.startswith('PayloadUnloader dump neighbour live fill (') for entry in ledger['N2380']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour liquid write-back follow-ups (') for entry in ledger['N2380']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadUnloader live front query (') for entry in ledger['N2380']['deferred_exprs']))

    def test_all_c07_payload_unloader_dump_liquid_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2380']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_dump_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2380']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_dump_liquid_write_back_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The dump advance (N2293) now exposes the liquid
        # write-back keys: dump_neighbour_index is the shared
        # routing's handled_index (the FIRST eligible neighbour
        # whose transfer actually moved liquid -- handle_liquid
        # called AND flow > 0, the N2371 rule -- -1 when nothing
        # moved; a dump that reaches several neighbours reports
        # only the first, so the per-neighbour split waits for
        # its own slice) and dumped_liquid_name is the dumped
        # liquid's catalog name. The name resolves the current
        # liquid id through the liquid_names_by_id frame input
        # (the PayloadLoader precedent: the tick builds the
        # names-by-id array from catalog.get_many("liquid"),
        # index == id, and stamps it on the frame; a fixture
        # without it reads ""). The name is set whenever a
        # current liquid resolves, even when nothing moved (the
        # Fracker dumped_liquid precedent). KEY COLLISION: the
        # old `dumped_liquid` key is the FLOAT amount dumped
        # (BuildingComp.java:905) -- its meaning does NOT
        # change, and the return keeps it alongside the new
        # String key. The tick call string is UNCHANGED (the
        # N2293 test pins it): the names ride the frame, not a
        # new parameter.
        self.assertIn('dump_neighbour_index = int(dumped.get("handled_index", -1))', payload_unloader)
        self.assertIn('var liquid_names_by_id: Array = frame.get("liquid_names_by_id", [])', payload_unloader)
        self.assertIn('dumped_liquid_name = str(liquid_names_by_id[int(current)])', payload_unloader)
        self.assertIn('"dump_neighbour_index": dump_neighbour_index, "dumped_liquid_name": dumped_liquid_name', payload_unloader)
        self.assertIn('"dumped_liquid": dumped_liquid', payload_unloader)
        self.assertIn('source_payload_unloader_dump_state(frame, source_delta, time_scale, item_order, dump_neighbour_liquid_amounts, dump_neighbour_liquid_capacities, dump_neighbour_accepts_liquid, dump_neighbour_can_dump_liquid, dump_neighbour_accepts_item, dump_neighbour_can_dump_item)', payload_unloader)
        self.assertEqual(payload_unloader.count('source_payload_unloader_dump_state('), 2)
        # The tick builds the names-by-id array from the
        # catalog (the Loader precedent) and stamps it on the
        # frame before the dump call, then wires the shared
        # N2371 helper after the dump write-back (when the
        # dumped amount is > 0 and the handled index is >= 0),
        # with the origin_cell meta read inline as dump_cell
        # (cell is bound after the enabled block, the N2363
        # note) and the catalog size. The dumped amount reads
        # from the dumped_liquid FLOAT key; the name rides the
        # new dumped_liquid_name key. A failed write-back (no
        # sprite / no frame / no liquids store) drops the
        # liquid -- the routing already decided, so there is no
        # fallback to the unloader's own store (the N2353
        # precedent). The ITEM half is NOT wired here -- it
        # waits for its own follow-through slice (N2353 helper).
        self.assertIn('for liquid in catalog.get_many("liquid"):', payload_unloader)
        self.assertIn('liquid_names_by_id.append(liquid.id)', payload_unloader)
        self.assertIn('frame["liquid_names_by_id"] = liquid_names_by_id', payload_unloader)
        self.assertLess(
            payload_unloader.index('frame["liquid_names_by_id"] = liquid_names_by_id'),
            payload_unloader.index('source_payload_unloader_dump_state(frame, source_delta, time_scale, item_order, dump_neighbour_liquid_amounts, dump_neighbour_liquid_capacities, dump_neighbour_accepts_liquid, dump_neighbour_can_dump_liquid, dump_neighbour_accepts_item, dump_neighbour_can_dump_item)'),
        )
        self.assertIn('if float(dumped.get("dumped_liquid", 0.0)) > 0.0:', payload_unloader)
        self.assertIn('var dump_index: int = int(dumped.get("dump_neighbour_index", -1))', payload_unloader)
        self.assertIn('var dump_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)', payload_unloader)
        self.assertIn('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid_name", "")), float(dumped.get("dumped_liquid", 0.0)))', payload_unloader)
        self.assertLess(
            payload_unloader.index('frame["dumped_items"] = dumped["dumped_items"]'),
            payload_unloader.index('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(dumped.get("dumped_liquid_name", "")), float(dumped.get("dumped_liquid", 0.0)))'),
        )
        # The documented limits now record the liquid half of
        # the dump neighbour write-back as live (N2380) and
        # the old "dumped liquid leaves this store without
        # landing in any neighbour store yet" text is gone;
        # the item half still waits (the handleItem comment
        # keeps its deferral). The N2293 dump, the N2232
        # advance, the N2209 gate and the N2279 live fill are
        # preserved.
        self.assertIn('dump neighbour write-back (liquid half) is live since N2380', payload_unloader)
        self.assertNotIn('the dumped liquid leaves this store without landing in any neighbour store yet', payload_unloader)
        self.assertIn('the neighbour write-back waits for its own slice, as with the liquid', payload_unloader)
        self.assertIn('dump rows live (N2293)', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertIn('live payload fill live (N2279)', payload_unloader)
        self.assertIn('static func source_payload_unloader_dump_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_update_tile_advance_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_tick_buildings_state', payload_unloader)
        # The shared helper exists with its N2371 contract (the
        # liquid arrives by name, resolves to its catalog id;
        # no sprite / no frame / no store / unknown liquid
        # reports written false with a reason).
        liquid_state = BUILDING_LIQUID_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_neighbour_liquid_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, liquid: String, amount: float) -> Dictionary:', liquid_state)
        self.assertIn('liquid_id_by_name', liquid_state)
        self.assertIn('"no_frame"', liquid_state)
        # The proof's keys drive the advance's exposed keys
        # (transfer / second-neighbour / multi-neighbour /
        # no-move / no-names / no-current) and the live tick (a
        # dumped liquid lands in the neighbour frame liquids;
        # a dumped liquid to a storeless neighbour still leaves
        # the unloader).
        proof = PAYLOAD_UNLOADER_DUMP_LIQUID_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dump_neighbour_index_and_liquid_name',
            'live_tick_writes_dumped_liquid_to_neighbour_frame',
            'live_tick_dumped_liquid_leaves_unloader_without_frame',
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
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', proof)
        self.assertTrue(BUILDING_LIQUID_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('payload_unloader_build_state.source_payload_unloader_dump_state(', proof)
        self.assertIn('payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = PAYLOAD_UNLOADER_DUMP_LIQUID_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderDumpLiquidWriteBackProof.gd', scene)
        self.assertIn('C07PayloadUnloaderDumpLiquidWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_payload_unloader_dump_liquid_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderDumpLiquidWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_DUMP_LIQUID_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dump_neighbour_index_and_liquid_name',
            'live_tick_writes_dumped_liquid_to_neighbour_frame',
            'live_tick_dumped_liquid_leaves_unloader_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
