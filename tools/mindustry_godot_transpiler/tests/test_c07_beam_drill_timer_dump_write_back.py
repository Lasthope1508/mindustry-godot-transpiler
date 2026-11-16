import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BUILDING_ITEM_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingItemState.gd'
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
BEAM_DRILL_TIMER_DUMP_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillTimerDumpWriteBackProof.gd'
BEAM_DRILL_TIMER_DUMP_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillTimerDumpWriteBackProof.tscn'


class C07BeamDrillTimerDumpWriteBackTests(unittest.TestCase):
    def test_c07_beam_drill_timer_dump_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2363']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_timer_dump_state')
        # N2289 gave the beam drill its timerDump dump (the
        # frame-local Interval-equivalent + dump(null) through
        # the shared dump_item_state routing) -- but the dumped
        # item left the drill without landing in any neighbour
        # store: the shared port reports the handled neighbour
        # index and item, and the advance swallowed both. Java
        # hands the item over for real: `other.handleItem(self(),
        # item);` (BuildingComp.java:1089). N2363 is the
        # wiring-only write-back (the N2353 precedent): the
        # timerDump advance exposes the routed neighbour index
        # + dumped item (dump_neighbour_index / dumped_item,
        # UNREGISTERED API shape -- the schema-sync slice
        # folds them into
        # source_beam_drill_timer_dump_state_result later),
        # and the tick wires the shared
        # source_neighbour_item_write_back_state helper after
        # the timerDump advance when dumped. No new symbols,
        # contracts, or schemas: the ledger entry re-lists the
        # five N2289 timerDump result symbols it extends (the
        # re-listing precedent: 781 symbols are listed by more
        # than one slice), so the SSOT delta is +0/+1/+0/+0.
        self.assertEqual(
            ledger['N2363']['source_symbols'],
            [
                'source_beam_drill_timer_dump_state_result.fired',
                'source_beam_drill_timer_dump_state_result.elapsed_after',
                'source_beam_drill_timer_dump_state_result.dumped',
                'source_beam_drill_timer_dump_state_result.items_after',
                'source_beam_drill_timer_dump_state_result.cursor_after',
            ],
        )
        for name in ledger['N2363']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/comp/TimerComp.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_timer_dump_state')
        self.assertEqual(ledger['N2363']['runtime_proof'], '/root/C07BeamDrillTimerDumpWriteBackProof')
        self.assertEqual(
            ledger['N2363']['tests'],
            [
                'test_c07_beam_drill_timer_dump_write_back_registration',
                'test_all_c07_beam_drill_timer_dump_write_back_input_evidence_is_exact',
                'test_beam_drill_timer_dump_write_back_state',
                'test_reference_graph_and_actual_c07_beam_drill_timer_dump_write_back',
            ],
        )
        self.assertTrue(ledger['N2363']['deferred_exprs'])
        # This slice resolves the BeamDrill timerDump dump
        # neighbour write-back deferral (#262) and adds no new
        # entry: the dump neighbour live fill (the accept /
        # canDump arrays stay frame inputs, default []), the
        # first-fire deviation, and the drop loop + time reset
        # entries stay, and the write-back follow-ups entry
        # (#319) stays for the coordinator to rewrite once the
        # wave's four write-backs land.
        self.assertFalse(any(entry.startswith('BeamDrill timerDump dump neighbour write-back (') for entry in ledger['N2363']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill timerDump dump neighbour live fill (') for entry in ledger['N2363']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill timerDump first-fire deviation (') for entry in ledger['N2363']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BeamDrill drop loop + time reset + lastDrillSpeed (') for entry in ledger['N2363']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour item write-back follow-ups (') for entry in ledger['N2363']['deferred_exprs']))

    def test_all_c07_beam_drill_timer_dump_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2363']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_timer_dump_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/BeamDrill.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/TimerComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Interval.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Time.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2363']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_timer_dump_write_back_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The timerDump advance (N2289) runs dump(null)
        # (BuildingComp.java:1072-1113): neighbours outer,
        # content items inner -- for each neighbour from the
        # cdump cursor, the first held item in content order
        # an accepting neighbour takes is handed over via
        # `other.handleItem(self(), item);` (:1089), 1 leaves
        # the store, and the cursor advances once per
        # neighbour checked (incrementDump, :1116-1120). The
        # shared dump_item_state port reports the handled
        # neighbour index + item (handled_index / handled_item,
        # -1 / null when nothing dumps); the advance now
        # exposes them as dump_neighbour_index / dumped_item
        # (-1 / "" when nothing dumps) so the tick can wire
        # the write-back. Keep each Java expr on ONE comment
        # line (the N2148 shootWarmup lesson: a split line
        # fails this test).
        self.assertIn('static func source_beam_drill_timer_dump_state', beam_drill)
        self.assertIn('other.handleItem(self(), item);', beam_drill)
        self.assertIn('dump_neighbour_index', beam_drill)
        self.assertIn('dumped_item', beam_drill)
        self.assertIn('int(result.get("handled_index", -1))', beam_drill)
        self.assertIn('str(result.get("handled_item", ""))', beam_drill)
        self.assertIn('"dump_neighbour_index": dump_neighbour_index', beam_drill)
        self.assertIn('"dumped_item": dumped_item', beam_drill)
        # The tick wires the shared neighbour write-back
        # helper (N2353) after the timerDump advance write-back
        # when dumped: the helper maps the routed neighbour
        # index to a ring cell (index i is ring cell i, the
        # source_block_proximity_cells_state ring) and lands
        # the dumped item in the neighbour store -- a belt
        # neighbour's conveyor queue or a building neighbour's
        # frame items -- with amount 1 (one handleItem per
        # dump, BuildingComp.java:1089). The cell is the
        # drill's origin_cell, the size the catalog size (2
        # plasma-bore / 3 large-plasma-bore). A failed
        # write-back (no sprite / no frame / no items store /
        # full belt) drops the item -- the routing already
        # decided, so there is no fallback to the drill's own
        # store (the N2353 precedent).
        self.assertIn('const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")', beam_drill)
        self.assertIn('source_building_item_state.source_neighbour_item_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(timer_dump.get("dumped_item", "")), 1)', beam_drill)
        self.assertIn('if bool(timer_dump.get("dumped", false)):', beam_drill)
        self.assertIn('if dump_index >= 0:', beam_drill)
        self.assertLess(
            beam_drill.index('frame["cdump"] = timer_dump.get("cursor_after", frame.get("cdump", 0))'),
            beam_drill.index('source_building_item_state.source_neighbour_item_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, str(timer_dump.get("dumped_item", "")), 1)'),
        )
        # The documented limits now record the dump neighbour
        # write-back as live (N2363) with the dump neighbour
        # live fill still deferred; the N2289 dump, the N2195
        # advance, the N2202 gate, the N2339 facing scan, and
        # the N2352 facing-tile fill are preserved -- the
        # facing-tiles stamp is a different path and this
        # slice does not touch it.
        self.assertIn('dump neighbour write-back live since N2363', beam_drill)
        self.assertIn('timerDump dump is live since N2289', beam_drill)
        self.assertIn('(3) Partial updateTile', beam_drill)
        self.assertIn('advance (N2195)', beam_drill)
        self.assertIn('shouldConsume gate live (N2202)', beam_drill)
        self.assertIn('facing scan live (N2339)', beam_drill)
        self.assertIn('facing-tile fill live since N2352', beam_drill)
        self.assertIn('if not world_tiles.is_empty():', beam_drill)
        self.assertIn('frame["facing_tiles"] = filled.get("facing_tiles", [])', beam_drill)
        self.assertIn('static func source_beam_drill_power_status_row_state', beam_drill)
        self.assertIn('static func source_beam_drill_should_consume_state', beam_drill)
        self.assertIn('static func source_beam_drill_update_tile_advance_state', beam_drill)
        # The proof's keys drive the advance's exposed routed
        # index + dumped item (routed / not-fired / no-accept /
        # empty-store) plus the live tick (a dumped copper
        # lands in the neighbour frame; a dumped copper to a
        # storeless neighbour still leaves the drill).
        proof = BEAM_DRILL_TIMER_DUMP_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_routed_neighbour_index',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_drill_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBeamDrillBuildState.gd")', proof)
        self.assertTrue(BEAM_DRILL_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd').is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('beam_drill_build_state.source_beam_drill_timer_dump_state(', proof)
        self.assertIn('beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = BEAM_DRILL_TIMER_DUMP_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillTimerDumpWriteBackProof.gd', scene)
        self.assertIn('C07BeamDrillTimerDumpWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_timer_dump_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillTimerDumpWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_TIMER_DUMP_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_routed_neighbour_index',
            'live_tick_writes_dumped_item_to_neighbour_frame',
            'live_tick_dumped_item_leaves_drill_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
