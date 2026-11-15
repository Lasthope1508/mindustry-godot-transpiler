import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
PAYLOAD_UNLOADER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderUpdateTileProof.gd'
PAYLOAD_UNLOADER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderUpdateTileProof.tscn'


class C07PayloadUnloaderUpdateTileTests(unittest.TestCase):
    def test_c07_payload_unloader_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2232']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_update_tile_advance_state')
        # N2163 proved the PayloadUnloader family's live power read
        # and N2209 the shouldConsume gate (return payload !=
        # null, inherited verbatim from PayloadLoaderBuild, no
        # enabled term) -- but the port tracked no payVector /
        # payRotation / items / liquids / lastOutputPower at
        # all, so a payload-unloader never moved its payload in
        # or out, never unloaded items, liquids, or battery
        # charge, and never produced power. N2232 is the
        # updateTile advance (PayloadUnloaderBuild.updateTile(),
        # PayloadUnloader.java:50-110): lastOutputPower reset,
        # the shouldExport branch (instant-deconstruct clear or
        # moveOutPayload), the moveInPayload gate, the item
        # unload loop (8 per timer tick, content-id order),
        # the liquid unload fold (min of liquidsLoaded *
        # edelta, remaining capacity, and the payload amount),
        # the battery unload into lastOutputPower (which IS the
        # power production, getPowerProduction returns it,
        # PayloadUnloader.java:44-47). The timer cadence, the
        # dump, the power-graph wiring, the movePayload /
        # dumpPayload application, and the live front query
        # defer; the live payload fill entry stays verbatim.
        # Thirteen new result symbols.
        self.assertEqual(
            ledger['N2232']['source_symbols'],
            [
                'source_payload_unloader_update_tile_advance_state_result.payload',
                'source_payload_unloader_update_tile_advance_state_result.pay_vector',
                'source_payload_unloader_update_tile_advance_state_result.pay_rotation',
                'source_payload_unloader_update_tile_advance_state_result.items',
                'source_payload_unloader_update_tile_advance_state_result.liquids',
                'source_payload_unloader_update_tile_advance_state_result.last_output_power',
                'source_payload_unloader_update_tile_advance_state_result.should_export',
                'source_payload_unloader_update_tile_advance_state_result.moved_in',
                'source_payload_unloader_update_tile_advance_state_result.payload_moved',
                'source_payload_unloader_update_tile_advance_state_result.payload_dumped',
                'source_payload_unloader_update_tile_advance_state_result.deconstructed',
                'source_payload_unloader_update_tile_advance_state_result.items_unloaded',
                'source_payload_unloader_update_tile_advance_state_result.liquids_unloaded',
            ],
        )
        for name in ledger['N2232']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], (
                    'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                    'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                ))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_update_tile_advance_state')
        self.assertEqual(ledger['N2232']['runtime_proof'], '/root/C07PayloadUnloaderUpdateTileProof')
        self.assertEqual(
            ledger['N2232']['tests'],
            [
                'test_c07_payload_unloader_update_tile_registration',
                'test_all_c07_payload_unloader_update_tile_input_evidence_is_exact',
                'test_payload_unloader_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_payload_unloader_update_tile',
            ],
        )
        self.assertTrue(ledger['N2232']['deferred_exprs'])
        # This slice resolves the updateTile advance, the load
        # params, the battery-unload rows, the shouldExport gate,
        # and the power-production rows deferrals -- so those
        # five entries are gone from DEFERRED, replaced by six
        # narrower entries (timer cadence, dump rows, the
        # power-production graph wiring, movePayload /
        # dumpPayload application, the payload entity update +
        # breakEffect presentation, the live front query). The
        # live payload fill entry stays verbatim (no live fill
        # sets the frame payload yet), as do the dynamic power
        # consumer row and the accept/handle payload rows.
        # maxBlockSize stays covered by the accept/handle entry:
        # it belongs to acceptPayload, not to this advance.
        for prefix in [
            'PayloadUnloader updateTile advance (',
            'PayloadUnloader load params (',
            'PayloadUnloader battery-unload rows (',
            'PayloadUnloader shouldExport gate (',
            'PayloadUnloader power-production rows (',
        ]:
            with self.subTest(prefix=prefix):
                self.assertFalse(any(entry.startswith(prefix) for entry in ledger['N2232']['deferred_exprs']))
        for prefix in [
            'PayloadUnloader updateTile timer cadence (',
            'PayloadUnloader dump rows (',
            'PayloadUnloader power-production graph wiring (',
            'PayloadUnloader movePayload/dumpPayload application (',
            'PayloadUnloader payload entity update + breakEffect presentation (',
            'PayloadUnloader live front query (',
            'PayloadUnloader live payload fill (',
            'PayloadUnloader dynamic power consumer row (',
            'PayloadUnloader accept/handle payload rows (',
        ]:
            with self.subTest(prefix=prefix):
                self.assertTrue(any(entry.startswith(prefix) for entry in ledger['N2232']['deferred_exprs']))

    def test_all_c07_payload_unloader_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2232']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        arc_sources = {
            'arc-core/src/arc/math/geom/Vec2.java',
        }
        upstream.update({source: (ROOT / 'arc-upstream' / source).read_text(encoding='utf-8') for source in arc_sources})
        for expr in ledger['N2232']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_update_tile_advance_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the payload-unloader build
        # state: the lastOutputPower reset
        # (PayloadUnloader.java:54), the shouldExport branch
        # (PayloadUnloader.java:56-64), the moveInPayload gate
        # (PayloadUnloader.java:65), the item unload loop
        # (PayloadUnloader.java:68-80), the liquid unload fold
        # (PayloadUnloader.java:82-92), the battery unload
        # (PayloadUnloader.java:94-102), and the dump
        # (PayloadUnloader.java:104-110, deferred). Keep each
        # Java expr on ONE comment line (the N2148 shootWarmup
        # lesson: a split line fails this test). The moveIn
        # port follows PayloadBlock.java:186-197 in order
        # (updatePayload is a no-op without a live payload
        # entity; block.rotate is true for PayloadLoader,
        # PayloadLoader.java:45, so the rotation target is
        # rotdeg(), BuildingComp.java:582-584 `return rotation
        # * 90;`); the moveOut reuses the ported helper
        # SourceBlockProducerMoveOutPayloadState
        # .move_out_payload_state through a preload (the N2224
        # precedent -- the helper's signature already covers
        # the whole PayloadBlock.java:199-226 body, including
        # the front flags and the movePayload result).
        # hasArrived is the Arc quirk `return
        # payVector.isZero(0.01f);` (PayloadBlock.java:243)
        # with isZero(margin) = len2() < margin (Vec2.java:
        # 679-681) -- NOT margin squared. delta() is `return
        # Time.delta * timeScale;` (BuildingComp.java:1922-1924)
        # and edelta() is `return efficiency * delta();`
        # (BuildingComp.java:1927-1929); moveIn/moveOut use
        # delta(), the liquid flow and the battery unload use
        # edelta(). source_delta is Time.delta in ticks
        # (seconds * 60 through game_source_delta, arc
        # Time.java:26), never raw seconds (the
        # N2186/N2187/N2191 lesson: raw seconds run 60x slow).
        self.assertIn('static func source_payload_unloader_update_tile_advance_state', payload_unloader)
        self.assertIn('lastOutputPower = 0f;', payload_unloader)
        self.assertIn('if(shouldExport()){', payload_unloader)
        self.assertIn('payload.block().breakEffect.at(this, payload.block().size);', payload_unloader)
        self.assertIn('payload = null;', payload_unloader)
        self.assertIn('moveOutPayload();', payload_unloader)
        self.assertIn('}else if(moveInPayload()){', payload_unloader)
        self.assertIn('if(payload.block().hasItems && !full()){', payload_unloader)
        self.assertIn('if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){', payload_unloader)
        self.assertIn('for(int j = 0; j < itemsLoaded && !full(); j++){', payload_unloader)
        self.assertIn('for(int i = 0; i < items.length(); i++){', payload_unloader)
        self.assertIn('if(payload.build.items.get(i) > 0){', payload_unloader)
        self.assertIn('Item item = content.item(i);', payload_unloader)
        self.assertIn('payload.build.items.remove(item, 1);', payload_unloader)
        self.assertIn('items.add(item, 1);', payload_unloader)
        self.assertIn('if(payload.block().hasLiquids && payload.build.liquids.currentAmount() >= 0.01f &&', payload_unloader)
        self.assertIn('(liquids.current() == payload.build.liquids.current() || liquids.currentAmount() <= 0.2f)){', payload_unloader)
        self.assertIn('var liq = payload.build.liquids.current();', payload_unloader)
        self.assertIn('float remaining = liquidCapacity - liquids.currentAmount();', payload_unloader)
        self.assertIn('float flow = Math.min(Math.min(liquidsLoaded * edelta(), remaining), payload.build.liquids.currentAmount());', payload_unloader)
        self.assertIn('liquids.add(liq, flow);', payload_unloader)
        self.assertIn('payload.build.liquids.remove(liq, flow);', payload_unloader)
        self.assertIn('if(hasBattery()){', payload_unloader)
        self.assertIn('float cap = payload.block().consPower.capacity;', payload_unloader)
        self.assertIn('float total = payload.build.power.status * cap;', payload_unloader)
        self.assertIn('float unloaded = Math.min(maxPowerUnload * edelta(), total);', payload_unloader)
        self.assertIn('lastOutputPower = unloaded;', payload_unloader)
        self.assertIn('payload.build.power.status -= unloaded / cap;', payload_unloader)
        self.assertIn('dumpLiquid(liquids.current());', payload_unloader)
        self.assertIn('for(int i = 0; i < offloadSpeed; i++){', payload_unloader)
        self.assertIn('dumpAccumulate();', payload_unloader)
        self.assertIn('return items.total() >= itemCapacity;', payload_unloader)
        self.assertIn('return payload != null && (', payload_unloader)
        self.assertIn('(!payload.block().hasItems || payload.build.items.empty()) &&', payload_unloader)
        self.assertIn('(!payload.block().hasLiquids || payload.build.liquids.currentAmount() <= 0.011f) &&', payload_unloader)
        self.assertIn('(!hasBattery() || payload.build.power.status <= 0.0000001f)', payload_unloader)
        self.assertIn('public float lastOutputPower = 0f;', payload_unloader)
        self.assertIn('public float getPowerProduction(){', payload_unloader)
        self.assertIn('return lastOutputPower;', payload_unloader)
        self.assertIn('public int offloadSpeed = 4;', payload_unloader)
        self.assertIn('public float maxPowerUnload = 80f;', payload_unloader)
        self.assertIn('public class PayloadUnloader extends PayloadLoader{', payload_unloader)
        self.assertIn('public class PayloadUnloaderBuild extends PayloadLoaderBuild{', payload_unloader)
        self.assertIn('payload.update(null, this);', payload_unloader)
        self.assertIn('public final int timerLoad = timers++;', payload_unloader)
        self.assertIn('public float loadTime = 2f;', payload_unloader)
        self.assertIn('public int itemsLoaded = 8;', payload_unloader)
        self.assertIn('public float liquidsLoaded = 40f;', payload_unloader)
        self.assertIn('public boolean hasBattery(){', payload_unloader)
        self.assertIn('return payload != null && payload.block().consPower != null && payload.block().consPower.buffered;', payload_unloader)
        self.assertIn('itemCapacity = 100;', payload_unloader)
        self.assertIn('liquidCapacity = 100f;', payload_unloader)
        self.assertIn('public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', payload_unloader)
        self.assertIn('public @Nullable T payload;', payload_unloader)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_unloader)
        self.assertIn('public float payRotation;', payload_unloader)
        self.assertIn('if(payload == null) return false;', payload_unloader)
        self.assertIn('payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());', payload_unloader)
        self.assertIn('payVector.approach(Vec2.ZERO, payloadSpeed * delta());', payload_unloader)
        self.assertIn('return hasArrived();', payload_unloader)
        self.assertIn('return payVector.isZero(0.01f);', payload_unloader)
        self.assertIn('Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);', payload_unloader)
        self.assertIn('payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());', payload_unloader)
        self.assertIn('payVector.approach(dest, payloadSpeed * delta());', payload_unloader)
        self.assertIn('boolean canDump = front == null || !front.tile.solid();', payload_unloader)
        self.assertIn('boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);', payload_unloader)
        self.assertIn('if(payVector.within(dest, 0.001f)){', payload_unloader)
        self.assertIn('if(movePayload(payload)){', payload_unloader)
        self.assertIn('dumpPayload();', payload_unloader)
        self.assertIn('return Time.delta * timeScale;', payload_unloader)
        self.assertIn('return efficiency * delta();', payload_unloader)
        self.assertIn('return rotation * 90;', payload_unloader)
        self.assertIn('updateConsumption();', payload_unloader)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', payload_unloader)
        self.assertIn('consumePower(2f);', payload_unloader)
        self.assertIn('public Liquid current(){', payload_unloader)
        self.assertIn('public float currentAmount(){', payload_unloader)
        self.assertIn('return liquids[current.id];', payload_unloader)
        self.assertIn('liquids[liquid.id] += amount;', payload_unloader)
        self.assertIn('current = liquid;', payload_unloader)
        self.assertIn('public boolean empty(){', payload_unloader)
        self.assertIn('return total == 0;', payload_unloader)
        self.assertIn('public static final int tilesize = 8;', payload_unloader)
        self.assertIn('return len2() < margin;', payload_unloader)
        # The def values are driver constants (single def --
        # payload-unloader; the catalog carries no load
        # params): loadTime 2f / itemsLoaded 8 / liquidsLoaded
        # 40f (PayloadLoader.java:22-24, inherited), offloadSpeed
        # 4 / maxPowerUnload 80f (PayloadUnloader.java:9-11),
        # itemCapacity 100 / liquidCapacity 100f
        # (PayloadLoader.java:40-41, inherited), size 3
        # (Blocks.java:6696), payloadSpeed 0.7f /
        # payloadRotateSpeed 5f (PayloadBlock.java:18).
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_LOAD_TIME := 2.0', payload_unloader)
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_ITEMS_LOADED := 8', payload_unloader)
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_LIQUIDS_LOADED := 40.0', payload_unloader)
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_MAX_POWER_UNLOAD := 80.0', payload_unloader)
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_ITEM_CAPACITY := 100', payload_unloader)
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_LIQUID_CAPACITY := 100.0', payload_unloader)
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_PAYLOAD_SPEED := 0.7', payload_unloader)
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_PAYLOAD_ROTATE_SPEED := 5.0', payload_unloader)
        self.assertIn('SOURCE_PAYLOAD_UNLOADER_SIZE := 3', payload_unloader)
        # The moveOut reuses the ported helper through a
        # preload (the N2224 precedent); the moveIn rotation
        # uses the shared angles helper and the approach uses
        # the helper's Vec2 approach.
        self.assertIn('preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")', payload_unloader)
        self.assertIn('source_move_out_payload_state.move_out_payload_state(', payload_unloader)
        self.assertIn('source_move_out_payload_state.source_vec2_approach(', payload_unloader)
        self.assertIn('source_math_state.source_angles_move_toward(', payload_unloader)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption, like Java's Building.update()
        # (BuildingComp.java:2274 updateConsumption(), then the
        # updateTile gate `if(enabled || !block.noUpdateDisabled){`
        # at BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170, so Java runs updateTile
        # even when disabled -- the port keeps the enabled gate
        # as a pragmatic choice, the N2195 coordinator-fix
        # precedent, because the driver skips the consumption
        # fold when disabled and the frame efficiency goes stale).
        # The timer cadence is live (N2320): the driver computes
        # load_tick from the frame-local load timer and passes it;
        # the item
        # order is the catalog item_names_by_id (the N2225
        # content-id order); the front flags arrive as explicit
        # params (no live neighbor query), so the driver passes
        # front-absent. Rotation reads live from the sprite
        # meta (the factory precedent) and the liquids store
        # syncs from the sprite meta each tick (the N2224
        # Fracker precedent) with the advanced store written
        # back to the meta.
        self.assertIn('game_source_delta(game, seconds)', payload_unloader)
        self.assertIn('time_scale(sprite', payload_unloader)
        self.assertIn('source_payload_unloader_update_tile_advance_state(frame, source_delta, time_scale, load_tick, item_order, front)', payload_unloader)
        self.assertIn('item_names_by_id', payload_unloader)
        self.assertIn('SOURCE_BUILD_ROTATION_META_KEY', payload_unloader)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', payload_unloader)
        self.assertIn('frame["payload"]', payload_unloader)
        self.assertIn('frame["pay_vector"]', payload_unloader)
        self.assertIn('frame["pay_rotation"]', payload_unloader)
        self.assertIn('frame["items"]', payload_unloader)
        self.assertIn('frame["liquids"]', payload_unloader)
        self.assertIn('frame["last_output_power"]', payload_unloader)
        self.assertIn('frame["should_export"]', payload_unloader)
        self.assertIn('frame["moved_in"]', payload_unloader)
        self.assertIn('frame["payload_moved"]', payload_unloader)
        self.assertIn('frame["payload_dumped"]', payload_unloader)
        self.assertIn('frame["deconstructed"]', payload_unloader)
        self.assertIn('frame["items_unloaded"]', payload_unloader)
        self.assertIn('frame["liquids_unloaded"]', payload_unloader)
        # The fresh frame binds the new state keys with the Java
        # field defaults (payload null, payVector (0, 0),
        # payRotation 0f, rotation 0, items {}, lastOutputPower
        # 0f); liquids syncs from the sprite meta each tick
        # (the Fracker precedent), not from _initial_frame.
        self.assertIn('"pay_vector": {"x": 0.0, "y": 0.0}', payload_unloader)
        self.assertIn('"pay_rotation": 0.0', payload_unloader)
        self.assertIn('"rotation": 0', payload_unloader)
        self.assertIn('"items": {}', payload_unloader)
        self.assertIn('"last_output_power": 0.0', payload_unloader)
        # The documented limits now record the advance as done
        # (with the battery unload into last_output_power) and
        # the remaining deferrals (timer cadence, dump, the
        # power-production graph wiring, movePayload /
        # dumpPayload application, the live front query); the
        # shouldConsume gate stays live (N2209) and the N2163
        # power row is preserved.
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertNotIn('No updateTile advance', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertIn('static func source_payload_unloader_power_status_row_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        # The proof's keys drive the pure advance (the moveIn
        # arrival, the item unload on a timer tick, the liquid
        # unload folding edelta, the battery unload into
        # last_output_power, the instant-deconstruct clear,
        # the moveOut push) plus the live tick (fresh-frame
        # defaults + a seeded payload advancing pay_vector /
        # liquids / last_output_power on a placed
        # payload-unloader, efficiency still folding
        # power.status).
        proof = PAYLOAD_UNLOADER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'move_in_arrives_at_center',
            'unload_items_on_timer_tick',
            'unload_liquids_folds_edelta',
            'battery_unloads_to_last_output_power',
            'instant_deconstruct_clears_payload',
            'move_out_pushes_payload',
            'live_tick_advances_unloader_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_UNLOADER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderUpdateTileProof.gd', scene)
        self.assertIn('C07PayloadUnloaderUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_payload_unloader_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'move_in_arrives_at_center',
            'unload_items_on_timer_tick',
            'unload_liquids_folds_edelta',
            'battery_unloads_to_last_output_power',
            'instant_deconstruct_clears_payload',
            'move_out_pushes_payload',
            'live_tick_advances_unloader_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
