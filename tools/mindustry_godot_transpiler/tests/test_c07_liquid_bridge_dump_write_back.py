import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIQUID_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidBridgeBuildState.gd'
BUILDING_LIQUID_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildingLiquidState.gd'
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
BLOCK_GEOMETRY_STATE = ROOT / 'godot-mindustry/src/game/SourceBlockGeometry.gd'
LIQUID_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceLiquidModuleState.gd'
PLACED_BLOCK_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedBlockState.gd'
LIQUID_BRIDGE_DUMP_WRITE_BACK_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeDumpWriteBackProof.gd'
LIQUID_BRIDGE_DUMP_WRITE_BACK_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LiquidBridgeDumpWriteBackProof.tscn'


class C07LiquidBridgeDumpWriteBackTests(unittest.TestCase):
    def test_c07_liquid_bridge_dump_write_back_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2379']['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_do_dump_state')
        # N2287 ported the LiquidBridge doDump override
        # (LiquidBridge.java:29-31, dumpLiquid(current, 1f)
        # at scaling 1f through the shared dump_liquid_state
        # routing) -- but the dumped liquid left the bridge
        # without landing in any neighbour store: Java hands
        # it over for real (`next.handleLiquid(self(),
        # liquid, flow);`, BuildingComp.java:918), and
        # handleLiquid is `liquids.add(liquid, amount);`
        # (BuildingComp.java:872-874). N2379 is the
        # write-back wiring (the N2371 Fracker precedent):
        # the doDump pure exposes the handled neighbour
        # index (dump_neighbour_index, from the shared
        # routing's handled_index -- the FIRST eligible
        # neighbour whose transfer actually moved liquid,
        # -1 when nothing moved) + the dumped liquid id
        # (dumped_liquid_id, the module current id -- the
        # pure has no catalog, so it exposes the id and the
        # tick resolves the name), and the tick lands the
        # dumped liquid in the neighbour store through the
        # shared source_neighbour_liquid_write_back_state
        # helper. The ledger entry re-lists the three N2287
        # dump result symbols (the N2321 shared-ownership
        # precedent) plus the two new symbols this slice
        # registers (the N2360 pattern -- the schema/
        # contract fold waits for a later schema-sync
        # slice, the N2367 precedent).
        self.assertEqual(
            ledger['N2379']['source_symbols'],
            [
                'source_liquid_bridge_do_dump_state_result.liquids_after',
                'source_liquid_bridge_do_dump_state_result.dumped_amount',
                'source_liquid_bridge_do_dump_state_result.cursor_after',
                'source_liquid_bridge_do_dump_state_result.dump_neighbour_index',
                'source_liquid_bridge_do_dump_state_result.dumped_liquid_id',
            ],
        )
        for name in ledger['N2379']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
                    'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_do_dump_state')
        self.assertEqual(ledger['N2379']['runtime_proof'], '/root/C07LiquidBridgeDumpWriteBackProof')
        self.assertEqual(
            ledger['N2379']['tests'],
            [
                'test_c07_liquid_bridge_dump_write_back_registration',
                'test_all_c07_liquid_bridge_dump_write_back_input_evidence_is_exact',
                'test_liquid_bridge_dump_write_back_state',
                'test_reference_graph_and_actual_c07_liquid_bridge_dump_write_back',
            ],
        )
        self.assertTrue(ledger['N2379']['deferred_exprs'])
        # This slice resolves the doDump neighbour
        # write-back entry (#247 in the merged
        # advances-19 list); the live neighbour fill (the
        # dump arrays are still frame inputs, default [])
        # and the campaign unlock stay deferred, and no new
        # deferral is added (the per-neighbour split + the
        # core-neighbour gap are already covered by the
        # N2371 follow-ups entry).
        self.assertFalse(any(entry.startswith('LiquidBridge doDump neighbour write-back (') for entry in ledger['N2379']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge doDump live neighbour fill (') for entry in ledger['N2379']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge doDump campaign unlock (') for entry in ledger['N2379']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LiquidBridge moveLiquid reaction branch (') for entry in ledger['N2379']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Neighbour liquid write-back follow-ups (') for entry in ledger['N2379']['deferred_exprs']))

    def test_all_c07_liquid_bridge_dump_write_back_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2379']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLiquidBridgeBuildState.source_liquid_bridge_do_dump_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/liquid/LiquidBridge.java',
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
        for expr in ledger['N2379']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_liquid_bridge_dump_write_back_state(self):
        liquid_bridge = LIQUID_BRIDGE_STATE.read_text(encoding='utf-8')
        # The doDump pure (N2287) now exposes the handled
        # neighbour + the dumped liquid: dump_neighbour_index
        # is the shared routing's handled_index (the FIRST
        # eligible neighbour whose transfer actually moved
        # liquid -- handle_liquid_called AND flow > 0 -- -1
        # when nothing moved, the N2371 routing note), and
        # dumped_liquid_id is the module current id (the
        # dumped liquid is liquids.current(),
        # LiquidBridge.java:30; `private Liquid current =
        # content.liquid(0);`, LiquidModule.java:24). The
        # pure has no catalog, so it exposes the id -- NOT
        # a name -- and the tick resolves the name through
        # liquid_names_by_id (the PayloadLoader precedent:
        # catalog order, index = liquid id). A dump that
        # reaches several neighbours reports only the first
        # handled index, so the write-back lands the total
        # there -- the per-neighbour split waits for its
        # own slice (the N2371 follow-ups entry).
        self.assertIn('dump_neighbour_index = int(dump.get("handled_index", -1))', liquid_bridge)
        self.assertIn('"dump_neighbour_index": dump_neighbour_index, "dumped_liquid_id": liquid_id', liquid_bridge)
        self.assertIn('for liquid in catalog.get_many("liquid"):', liquid_bridge)
        self.assertIn('liquid_names_by_id.append(liquid.id)', liquid_bridge)
        # The tick wires the shared helper after the doDump
        # write-back when dumped_amount > 0, with the
        # origin_cell read inline as dump_cell (the N2363
        # note), the catalog size (phase-conduit is size 1),
        # the handled index, and the resolved liquid name.
        # A failed write-back (no sprite / no frame / no
        # liquids store) drops the liquid -- the routing
        # already decided, so there is no fallback to the
        # bridge's own store (the N2353 precedent).
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', liquid_bridge)
        self.assertIn('if float(dumped.get("dumped_amount", 0.0)) > 0.0:', liquid_bridge)
        self.assertIn('var dump_index: int = int(dumped.get("dump_neighbour_index", -1))', liquid_bridge)
        self.assertIn('var dumped_liquid_id: int = int(dumped.get("dumped_liquid_id", -1))', liquid_bridge)
        self.assertIn('var dump_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)', liquid_bridge)
        self.assertIn('var dumped_liquid_name: String = str(liquid_names_by_id[dumped_liquid_id])', liquid_bridge)
        self.assertIn('source_building_liquid_state.source_neighbour_liquid_write_back_state(game, dump_cell, int(block.properties.get("size", 1)), dump_index, dumped_liquid_name, float(dumped.get("dumped_amount", 0.0)))', liquid_bridge)
        self.assertLess(
            liquid_bridge.index('frame["cdump"] = dumped["cursor_after"]'),
            liquid_bridge.index('source_building_liquid_state.source_neighbour_liquid_write_back_state('),
        )
        # The documented limits now record the dump
        # neighbour write-back as live (N2379) and the old
        # "not written into the neighbour frame yet" / "no
        # neighbour write-back yet" / "waits for its own
        # slice" texts are gone; the N2287 dump rows, the
        # N2275 transport advance, the N2198 gate, and the
        # N2197 link frame state are preserved.
        self.assertIn('Dump neighbour write-back live since N2379', liquid_bridge)
        self.assertNotIn('the dumped amount is not written into the neighbour frame yet', liquid_bridge)
        self.assertNotIn('no neighbour write-back yet', liquid_bridge)
        self.assertNotIn('the neighbour write-back waits for its own slice', liquid_bridge)
        self.assertIn('doDump live (N2287)', liquid_bridge)
        self.assertIn('updateTransport advance live (N2275)', liquid_bridge)
        self.assertIn('shouldConsume gate live (N2198)', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_do_dump_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_update_transport_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_should_consume_state', liquid_bridge)
        self.assertIn('static func source_liquid_bridge_tick_buildings_state', liquid_bridge)
        # The proof's keys drive the pure's exposed
        # handled neighbour + dumped liquid id (transfer /
        # fuller / refusing / pair / multi / alone / linked
        # / threshold / no-current) and the live tick
        # (dumped liquid lands in the neighbour frame
        # liquids; dumped liquid to a frameless neighbour
        # still leaves the bridge).
        proof = LIQUID_BRIDGE_DUMP_WRITE_BACK_PROOF.read_text(encoding='utf-8')
        for key in [
            'advance_exposes_dump_neighbour_index',
            'live_tick_writes_dumped_liquid_to_neighbour_frame',
            'live_tick_dumped_liquid_leaves_bridge_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceLiquidBridgeBuildState.gd")', proof)
        self.assertTrue(LIQUID_BRIDGE_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBuildingLiquidState.gd")', proof)
        self.assertTrue(BUILDING_LIQUID_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceBlockGeometry.gd")', proof)
        self.assertTrue(BLOCK_GEOMETRY_STATE.is_file())
        self.assertIn('preload("res://src/game/SourceLiquidModuleState.gd")', proof)
        self.assertTrue(LIQUID_MODULE_STATE.is_file())
        self.assertIn('preload("res://src/game/SourcePlacedBlockState.gd")', proof)
        self.assertTrue(PLACED_BLOCK_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('liquid_bridge_build_state.source_liquid_bridge_do_dump_state(', proof)
        self.assertIn('liquid_bridge_build_state.source_liquid_bridge_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = LIQUID_BRIDGE_DUMP_WRITE_BACK_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07LiquidBridgeDumpWriteBackProof.gd', scene)
        self.assertIn('C07LiquidBridgeDumpWriteBackProof', scene)

    def test_reference_graph_and_actual_c07_liquid_bridge_dump_write_back(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LiquidBridgeDumpWriteBackProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIQUID_BRIDGE_DUMP_WRITE_BACK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'advance_exposes_dump_neighbour_index',
            'live_tick_writes_dumped_liquid_to_neighbour_frame',
            'live_tick_dumped_liquid_leaves_bridge_without_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
