import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd'
MASS_DRIVER_DUMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverDumpProof.gd'
MASS_DRIVER_DUMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MassDriverDumpProof.tscn'


class C07MassDriverDumpTests(unittest.TestCase):
    def test_c07_mass_driver_dump_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2294']['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_dump_state')
        # N2237 gave the mass driver its updateTile advance
        # (link refresh / reloadCounter decay / waitingShooters
        # cleanup / the idle-accepting-shooting switch /
        # rotation align / register + fire, MassDriver.java:
        # 133-221 + fire() :290-317) -- but the dumpAccumulate
        # dump between the state switch and the no-power skip
        # (`//dump when idle or accepting` /
        # `if(state == DriverState.idle || state ==
        # DriverState.accepting){ dumpAccumulate(); }`,
        # MassDriver.java:163-166) was RED-deferred all along:
        # dumpAccumulate() delegates to dumpAccumulate(null)
        # (BuildingComp.java:1048-1050), which accumulates
        # `dumpAccum += delta();` and dumps while
        # `dumpAccum >= 1f` (BuildingComp.java:1053-1061) --
        # possibly MULTIPLE times per tick -- through dump()
        # = dump(null) (BuildingComp.java:1064-1066), the
        # neighbour-outer / item-inner scan (BuildingComp.
        # java:1072-1114) that hands the first held item an
        # accepting neighbour takes (acceptItem && canDump),
        # removing 1 from the store and advancing the cdump
        # cursor once per neighbour checked. The dump sits
        # BEFORE the efficiency check (`if(efficiency <= 0f){`,
        # MassDriver.java:169), so it runs even with no power;
        # and dumpAccumulate() is only CALLED while idle or
        # accepting, so the accumulator does NOT grow while
        # shooting. N2294 is the dump: the pure dump function
        # gates on the post-switch state (state_after_switch,
        # returned by the N2237 advance -- NOT the final
        # state, which the accepting/shooting branches may
        # flip back to idle) and routes each attempt through
        # the shared dumpAccumulate + dump_item_state helpers.
        # Four new result symbols: the accumulator after the
        # tick, the dumped flag, the items, and the cursor
        # after the tick.
        self.assertEqual(
            ledger['N2294']['source_symbols'],
            [
                'source_mass_driver_dump_state_result.dump_accum_after',
                'source_mass_driver_dump_state_result.dumped',
                'source_mass_driver_dump_state_result.items_after',
                'source_mass_driver_dump_state_result.cursor_after',
            ],
        )
        for name in ledger['N2294']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/distribution/MassDriver.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_dump_state')
        self.assertEqual(ledger['N2294']['runtime_proof'], '/root/C07MassDriverDumpProof')
        self.assertEqual(
            ledger['N2294']['tests'],
            [
                'test_c07_mass_driver_dump_registration',
                'test_all_c07_mass_driver_dump_input_evidence_is_exact',
                'test_mass_driver_dump_state',
                'test_reference_graph_and_actual_c07_mass_driver_dump',
            ],
        )
        self.assertTrue(ledger['N2294']['deferred_exprs'])
        # This slice resolves the MassDriver dumpAccumulate
        # deferral and adds two new ones: the dump neighbour
        # live fill (the accept/canDump arrays are frame
        # inputs, default []) and the dump neighbour
        # write-back (the dumped item leaves the mass driver
        # without landing in any neighbour store). The Time.run
        # arrival cleanup and the bullet entity entries stay:
        # the arrival cleanup and the bullet still defer.
        self.assertFalse(any(entry.startswith('MassDriver dumpAccumulate / dump rows (') for entry in ledger['N2294']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver dump neighbour live fill (') for entry in ledger['N2294']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver dump neighbour write-back (') for entry in ledger['N2294']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver fire arrival / Time.run cleanup (') for entry in ledger['N2294']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MassDriver bullet entity / DriverBulletData rows (') for entry in ledger['N2294']['deferred_exprs']))

    def test_all_c07_mass_driver_dump_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2294']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceMassDriverBuildState.source_mass_driver_dump_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/distribution/MassDriver.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2294']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mass_driver_dump_state(self):
        mass_driver = MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The dump (MassDriver.java:163-166, `//dump when idle
        # or accepting` / `if(state == DriverState.idle ||
        # state == DriverState.accepting){ dumpAccumulate();
        # }`) sits between the state switch (:154-161) and the
        # no-power skip (`if(efficiency <= 0f){`, :169-171),
        # so it runs even with no power -- and dumpAccumulate()
        # is only CALLED while idle or accepting, so the
        # accumulator does NOT grow while shooting. dumpAccumulate()
        # delegates to dumpAccumulate(null) (BuildingComp.java:
        # 1048-1050), which accumulates `dumpAccum += delta();`
        # and dumps while `dumpAccum >= 1f` (BuildingComp.java:
        # 1053-1061) -- possibly MULTIPLE times per tick --
        # through dump() = dump(null) (BuildingComp.java:
        # 1064-1066): neighbours outer, content items inner --
        # for each neighbour from the cdump cursor, the first
        # held item in content order an accepting neighbour
        # takes is handed over, 1 leaves the store, and the
        # cursor advances once per neighbour checked
        # (incrementDump, BuildingComp.java:1116-1120, guarded
        # on prox != 0). Keep each Java expr on ONE comment
        # line (the N2148 shootWarmup lesson: a split line
        # fails this test). The mass driver has items
        # (`hasItems = true;`, MassDriver.java:51), so the
        # hasItems guard always passes. delta() is `Time.delta
        # * timeScale` (BuildingComp.java:1922-1924), so the
        # accumulator grows by source_delta * time_scale.
        self.assertIn('static func source_mass_driver_dump_state', mass_driver)
        self.assertIn('//dump when idle or accepting', mass_driver)
        self.assertIn('if(state == DriverState.idle || state == DriverState.accepting){', mass_driver)
        self.assertIn('dumpAccumulate();', mass_driver)
        self.assertIn('if(efficiency <= 0f){', mass_driver)
        self.assertIn('hasItems = true;', mass_driver)
        self.assertIn('private transient float dumpAccum;', mass_driver)
        self.assertIn('public boolean dumpAccumulate(){', mass_driver)
        self.assertIn('return dumpAccumulate(null);', mass_driver)
        self.assertIn('public boolean dumpAccumulate(Item item){', mass_driver)
        self.assertIn('boolean res = false;', mass_driver)
        self.assertIn('dumpAccum += delta();', mass_driver)
        self.assertIn('while(dumpAccum >= 1f){', mass_driver)
        self.assertIn('res |= dump(item);', mass_driver)
        self.assertIn('dumpAccum -=1f;', mass_driver)
        self.assertIn('public boolean dump(){', mass_driver)
        self.assertIn('return dump(null);', mass_driver)
        self.assertIn('public boolean dump(Item todump){', mass_driver)
        self.assertIn('if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;', mass_driver)
        self.assertIn('int dump = this.cdump;', mass_driver)
        self.assertIn('var allItems = content.items();', mass_driver)
        self.assertIn('int itemSize = allItems.size;', mass_driver)
        self.assertIn('if(todump == null){', mass_driver)
        self.assertIn('Building other = proximity.get((i + dump) % proximity.size);', mass_driver)
        self.assertIn('if(!items.has(ii)) continue;', mass_driver)
        self.assertIn('Item item = (Item)itemArray[ii];', mass_driver)
        self.assertIn('if(other.acceptItem(self(), item) && canDump(other, item)){', mass_driver)
        self.assertIn('other.handleItem(self(), item);', mass_driver)
        self.assertIn('items.remove(item, 1);', mass_driver)
        self.assertIn('incrementDump(proximity.size);', mass_driver)
        self.assertIn('public void incrementDump(int prox){', mass_driver)
        self.assertIn('if(prox != 0){', mass_driver)
        self.assertIn('cdump = ((cdump + 1) % prox);', mass_driver)
        self.assertIn('transient int cdump;', mass_driver)
        self.assertIn('public boolean canDump(Building to, Item item){', mass_driver)
        self.assertIn('public float delta(){', mass_driver)
        self.assertIn('return Time.delta * timeScale;', mass_driver)
        # The dump reuses the shared helpers -- the
        # dumpAccumulate attempt count (SourceBuildingItemDump
        # State.dump_accumulate_state, which the bridge
        # source_dump_accumulate_attempt_state delegates to;
        # the bridge method is an instance method, so the
        # static pure calls the underlying static directly)
        # and the dump(null) port dump_item_state (the putItem
        # gate game_put_item_state is the WRONG shape here: it
        # dumps one SPECIFIC item and needs a game object for
        # its increment callbacks, while dumpAccumulate calls
        # dump()) -- and the drill inventory totals helper,
        # never a hand-rolled total. The advance returns the
        # post-switch state so the tick can gate the dump on
        # it: a shooting driver that fires ends the tick idle
        # but must NOT dump, and the accepting branch may flip
        # accepting back to idle while the dump still fires.
        self.assertIn('source_building_item_dump_state.dump_accumulate_state(', mass_driver)
        self.assertIn('source_building_item_dump_state.dump_item_state(', mass_driver)
        self.assertIn('inventory.items_total(items)', mass_driver)
        self.assertIn('const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")', mass_driver)
        self.assertIn('var state_after_switch: String = state', mass_driver)
        self.assertIn('"state_after_switch": state_after_switch', mass_driver)
        # The frame carries the dump accumulator at the Java
        # field default (dump_accum 0.0, `private transient
        # float dumpAccum;`, BuildingComp.java:99) and the
        # shared cdump cursor (0, BuildingComp.java:68); the
        # neighbour acceptItem / canDump arrays are frame
        # inputs (default [] -- no neighbours, the Java
        # proximity.size == 0 outcome) until a live proximity
        # fill lands. The tick wires the dump into the live
        # loop AFTER the advance in the same tick (the dump
        # gate reads advanced["state_after_switch"], and the
        # only advance branch that mutates items is fire(),
        # which runs only while shooting -- so the post-advance
        # store is the store Java dumps from in every
        # dump-eligible state), with the content item ids in
        # catalog order (the item_order the advance already
        # reads) and the source delta / timeScale the advance
        # already reads. The dump runs even when efficiency
        # is 0 -- the gate sits before the no-power skip
        # (MassDriver.java:168-171).
        self.assertIn('frame.get("dump_accum", 0.0)', mass_driver)
        self.assertIn('frame.get("dump_neighbour_accepts", [])', mass_driver)
        self.assertIn('frame.get("dump_neighbour_can_dump", [])', mass_driver)
        self.assertIn('source_mass_driver_dump_state(frame, post_switch_state, source_delta, time_scale, item_order, dump_neighbour_accepts, dump_neighbour_can_dump)', mass_driver)
        self.assertIn('frame["dump_accum"]', mass_driver)
        self.assertIn('frame["cdump"]', mass_driver)
        self.assertLess(
            mass_driver.index('source_mass_driver_update_tile_advance_state(frame, source_delta, time_scale, SOURCE_MASS_DRIVER_ITEM_CAPACITY, SOURCE_MASS_DRIVER_RELOAD, SOURCE_MASS_DRIVER_ROTATE_SPEED, SOURCE_MASS_DRIVER_MIN_DISTRIBUTE, SOURCE_MASS_DRIVER_BULLET_SPEED, SOURCE_MASS_DRIVER_BULLET_LIFETIME, this_pos, self_x, self_y, linked, shooters, item_order)'),
            mass_driver.index('source_mass_driver_dump_state(frame, post_switch_state, source_delta, time_scale, item_order, dump_neighbour_accepts, dump_neighbour_can_dump)'),
        )
        # The documented limits now record the dump as live
        # (dumpAccumulate idle/accepting + the dumpAccum while
        # loop, running even without power) and the remaining
        # deferrals (the Time.run arrival cleanup, the bullet
        # entity, handlePayload); the N2237 advance and the
        # N2171 power row are preserved.
        self.assertIn('dumpAccumulate (:164-166) is live since N2294', mass_driver)
        self.assertIn('updateTile advance live (N2237)', mass_driver)
        self.assertIn('static func source_mass_driver_power_status_row_state', mass_driver)
        self.assertIn('static func source_mass_driver_update_tile_advance_state', mass_driver)
        self.assertIn('static func source_mass_driver_tick_buildings_state', mass_driver)
        self.assertIn('static func source_mass_driver_bind_frame_state', mass_driver)
        # The proof's keys drive the pure dump (the dump fires
        # when idle and when accepting, is blocked when
        # shooting with the accumulator NOT growing, runs
        # without power, and removes the first held item in
        # content order) plus the live tick (a placed mass
        # driver with no power still dumps 1 item in one tick
        # at a full accumulator).
        proof = MASS_DRIVER_DUMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'dump_fires_when_idle',
            'dump_fires_when_accepting',
            'dump_blocked_when_shooting',
            'dump_runs_without_power',
            'dump_removes_item_from_store',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceMassDriverBuildState.gd")', proof)
        self.assertTrue(MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('mass_driver_build_state.source_mass_driver_dump_state(', proof)
        self.assertIn('mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = MASS_DRIVER_DUMP_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07MassDriverDumpProof.gd', scene)
        self.assertIn('C07MassDriverDumpProof', scene)

    def test_reference_graph_and_actual_c07_mass_driver_dump(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MassDriverDumpProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MASS_DRIVER_DUMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dump_fires_when_idle',
            'dump_fires_when_accepting',
            'dump_blocked_when_shooting',
            'dump_runs_without_power',
            'dump_removes_item_from_store',
            'live_tick_dumps_item',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
