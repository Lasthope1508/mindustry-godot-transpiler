import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd'
PAYLOAD_LOADER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderUpdateTileProof.gd'
PAYLOAD_LOADER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderUpdateTileProof.tscn'


class C07PayloadLoaderUpdateTileTests(unittest.TestCase):
    def test_c07_payload_loader_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2231']['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_update_tile_advance_state')
        # N2162 gave the payload loader its live power.status read
        # and N2208 proved the shouldConsume gate (payload !=
        # null) -- but the port advanced NO payload-loader tick
        # state at all: a payload sitting in the loader never
        # moved in, never loaded items / liquids / power, never
        # exported. N2231 is the updateTile advance
        # (PayloadLoaderBuild.updateTile(),
        # PayloadLoader.java:148-220): shouldExport() (PayloadLoader.java:227-233)
        # -> moveOutPayload() through the REUSED
        # SourceBlockProducerMoveOutPayloadState helper (the
        # N2224 cross-driver preload precedent; the helper's
        # signature matches this call exactly -- same
        # PayloadBlock.moveOutPayload, PayloadBlock.java:199-226),
        # else moveInPayload() (PayloadBlock.java:186-197, ported
        # in the driver: moveToward rotation + approach Vec2.ZERO
        # + hasArrived isZero(0.01f), i.e. len2 < 0.01) -> the
        # load branches (items PayloadLoader.java:154-177 with
        # the load_tick bool in place of the deferred timer,
        # iterating items in content-id order like N2225;
        # liquids PayloadLoader.java:179-196 with flow folding
        # edelta(); power PayloadLoader.java:198-217 charging
        # the payload battery from power.status). PayloadLoader
        # DOES rotate (rotate = true, PayloadLoader.java:45),
        # so the moveIn rotation target is rotdeg(), not the
        # 90f fallback -- the scope's no-rotate claim was wrong
        # and the RED grep caught it. Fourteen new result
        # symbols: the export/arrival flags, the advanced frame
        # values, the payload handoff flags, and the pure
        # amounts (liquid flow / power charged / items loaded /
        # push fraction).
        self.assertEqual(
            ledger['N2231']['source_symbols'],
            [
                'source_payload_loader_update_tile_advance_state_result.should_export',
                'source_payload_loader_update_tile_advance_state_result.has_arrived',
                'source_payload_loader_update_tile_advance_state_result.exporting',
                'source_payload_loader_update_tile_advance_state_result.pay_vector',
                'source_payload_loader_update_tile_advance_state_result.pay_rotation',
                'source_payload_loader_update_tile_advance_state_result.items',
                'source_payload_loader_update_tile_advance_state_result.liquids',
                'source_payload_loader_update_tile_advance_state_result.payload',
                'source_payload_loader_update_tile_advance_state_result.payload_moved',
                'source_payload_loader_update_tile_advance_state_result.payload_dumped',
                'source_payload_loader_update_tile_advance_state_result.liquid_flow',
                'source_payload_loader_update_tile_advance_state_result.power_charged',
                'source_payload_loader_update_tile_advance_state_result.items_loaded',
                'source_payload_loader_update_tile_advance_state_result.pushed_output_fraction',
            ],
        )
        for name in ledger['N2231']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
                    'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_update_tile_advance_state')
        self.assertEqual(ledger['N2231']['runtime_proof'], '/root/C07PayloadLoaderUpdateTileProof')
        self.assertEqual(
            ledger['N2231']['tests'],
            [
                'test_c07_payload_loader_update_tile_registration',
                'test_all_c07_payload_loader_update_tile_input_evidence_is_exact',
                'test_payload_loader_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_payload_loader_update_tile',
            ],
        )
        self.assertTrue(ledger['N2231']['deferred_exprs'])
        # This slice resolves THREE deferrals: the updateTile
        # advance entry, the load params entry (loadTime /
        # itemsLoaded / liquidsLoaded / maxBlockSize are this
        # slice's consts), and the battery-charge rows entry
        # (the power branch, PayloadLoader.java:202-213, is this
        # slice -- the brief named the first two; the third is
        # the same lines, so leaving it would keep a false
        # "needs payload battery state the tick does not track
        # yet"). Six new deferrals record what this slice leaves
        # behind (timer cadence, movePayload/dumpPayload
        # application, live front gather, per-type accept rows,
        # super.updateTile payload.update, payload contract
        # unify). The live payload fill, the dynamic power
        # consumer row, and the accept/handle payload rows stay
        # deferred.
        self.assertFalse(any(entry.startswith('PayloadLoader updateTile advance (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('PayloadLoader load params (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('PayloadLoader battery-charge rows (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader load timer cadence (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader movePayload / dumpPayload application (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader live front gather (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader payload acceptItem / acceptLiquid per-type rows (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader super.updateTile payload update (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader payload dict contract unify (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader live payload fill (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader dynamic power consumer row (') for entry in ledger['N2231']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadLoader accept/handle payload rows (') for entry in ledger['N2231']['deferred_exprs']))

    def test_all_c07_payload_loader_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2231']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/world/blocks/storage/StorageBlock.java',
            'core/src/mindustry/world/blocks/liquid/LiquidRouter.java',
            'core/src/mindustry/world/blocks/sandbox/LiquidVoid.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2231']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_loader_update_tile_advance_state(self):
        payload_loader = PAYLOAD_LOADER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the payload-loader build
        # state: PayloadLoaderBuild.updateTile()
        # (PayloadLoader.java:148-220) on
        # `public class PayloadLoader extends PayloadBlock{`
        # (PayloadLoader.java:19) /
        # `public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{`
        # (PayloadLoader.java:86) /
        # `public class PayloadBlockBuild<T extends Payload> extends Building{`
        # (PayloadBlock.java:91). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). The scope's "PayloadLoader does
        # NOT rotate" claim was WRONG: the ctor sets
        # `rotate = true;` (PayloadLoader.java:45), so the
        # moveIn rotation target is rotdeg() and the pure
        # function takes block_rotate as an explicit param
        # (driver passes true). hasArrived is
        # `return payVector.isZero(0.01f);`
        # (PayloadBlock.java:243) and Vec2.isZero(margin) is
        # `return len2() < margin;` -- the margin compares
        # against the SQUARED length, so arrival is len2 <
        # 0.01, not len < 0.01. The moveOut arrival guard is
        # `if(payVector.within(dest, 0.001f)){` with
        # Position.within as `return Mathf.dst2(getX(), getY(),
        # x, y) < dst*dst;` -- dst2 < 0.001^2, which the reused
        # helper already implements. delta() is
        # `return Time.delta * timeScale;`
        # (BuildingComp.java:1922-1924) and edelta() is
        # `return efficiency * delta();`
        # (BuildingComp.java:1927-1929); source_delta is
        # Time.delta in ticks (seconds * 60 through
        # game_source_delta, arc Time.java:26), never raw
        # seconds. The default acceptItem is NOT the
        # items.total() gate the scope suggested: it is
        # `return block.consumesItem(item) && items.get(item) <
        # getMaximumAccepted(item);` (BuildingComp.java:865)
        # with `return block.itemCapacity;`
        # (BuildingComp.java:782); storage payloads use the
        # open rule instead
        # (StorageBlock.java:55), and liquid payloads the
        # LiquidRouter rule (LiquidRouter.java:42) -- the
        # payload contract carries explicit accept_item_open /
        # accept_liquid_open flags for those.
        self.assertIn('static func source_payload_loader_update_tile_advance_state', payload_loader)
        self.assertIn('public class PayloadLoader extends PayloadBlock{', payload_loader)
        self.assertIn('public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{', payload_loader)
        self.assertIn('public class PayloadBlockBuild<T extends Payload> extends Building{', payload_loader)
        self.assertIn('public float loadTime = 2f;', payload_loader)
        self.assertIn('public int itemsLoaded = 8;', payload_loader)
        self.assertIn('public float liquidsLoaded = 40f;', payload_loader)
        self.assertIn('public int maxBlockSize = 3;', payload_loader)
        self.assertIn('public float maxPowerConsumption = 40f;', payload_loader)
        self.assertIn('public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', payload_loader)
        self.assertIn('public boolean exporting = false;', payload_loader)
        self.assertIn('public @Nullable T payload;', payload_loader)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_loader)
        self.assertIn('public float payRotation;', payload_loader)
        self.assertIn('rotate = true;', payload_loader)
        self.assertIn('public void updateTile(){', payload_loader)
        self.assertIn('super.updateTile();', payload_loader)
        self.assertIn('if(shouldExport()){', payload_loader)
        self.assertIn('moveOutPayload();', payload_loader)
        self.assertIn('}else if(moveInPayload()){', payload_loader)
        self.assertIn('public boolean shouldExport(){', payload_loader)
        self.assertIn('return payload != null && (', payload_loader)
        self.assertIn('(payload.block().hasLiquids && liquids.currentAmount() >= 0.1f && payload.build.liquids.currentAmount() >= payload.block().liquidCapacity - 0.001f) ||', payload_loader)
        self.assertIn('(payload.block().hasItems && items.any() && payload.block().separateItemCapacity && content.items().contains(i -> (payload.build.items.get(i) >= payload.block().itemCapacity) && items.has(i))) ||', payload_loader)
        self.assertIn('(hasBattery() && payload.build.power.status >= 0.999999999f));', payload_loader)
        self.assertIn('public boolean hasBattery(){', payload_loader)
        self.assertIn('return payload != null && payload.block().consPower != null && payload.block().consPower.buffered;', payload_loader)
        self.assertIn('public boolean moveInPayload(){', payload_loader)
        self.assertIn('return moveInPayload(true);', payload_loader)
        self.assertIn('public boolean moveInPayload(boolean rotate){', payload_loader)
        self.assertIn('if(payload == null) return false;', payload_loader)
        self.assertIn('updatePayload();', payload_loader)
        self.assertIn('payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());', payload_loader)
        self.assertIn('payVector.approach(Vec2.ZERO, payloadSpeed * delta());', payload_loader)
        self.assertIn('return hasArrived();', payload_loader)
        self.assertIn('public boolean hasArrived(){', payload_loader)
        self.assertIn('return payVector.isZero(0.01f);', payload_loader)
        self.assertIn('return len2() < margin;', payload_loader)
        self.assertIn('public void moveOutPayload(){', payload_loader)
        self.assertIn('Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);', payload_loader)
        self.assertIn('payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());', payload_loader)
        self.assertIn('payVector.approach(dest, payloadSpeed * delta());', payload_loader)
        self.assertIn('Building front = front();', payload_loader)
        self.assertIn('boolean canDump = front == null || !front.tile.solid();', payload_loader)
        self.assertIn('boolean canMove = front != null && (front.block.outputsPayload || front.block.acceptsPayload);', payload_loader)
        self.assertIn('pushOutput(payload, 1f - (payVector.dst(dest) / (size * tilesize / 2f)));', payload_loader)
        self.assertIn('if(payVector.within(dest, 0.001f)){', payload_loader)
        self.assertIn('return Mathf.dst2(getX(), getY(), x, y) < dst*dst;', payload_loader)
        self.assertIn('payVector.clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);', payload_loader)
        self.assertIn('if(movePayload(payload)){', payload_loader)
        self.assertIn('payload = null;', payload_loader)
        self.assertIn('dumpPayload();', payload_loader)
        self.assertIn('if(payload.block().hasItems && items.any()){', payload_loader)
        self.assertIn('boolean acceptedAny = true;', payload_loader)
        self.assertIn('if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){', payload_loader)
        self.assertIn('acceptedAny = false;', payload_loader)
        self.assertIn('for(int j = 0; j < itemsLoaded && items.any(); j++){', payload_loader)
        self.assertIn('for(int i = 0; i < items.length(); i++){', payload_loader)
        self.assertIn('if(items.get(i) > 0){', payload_loader)
        self.assertIn('Item item = content.item(i);', payload_loader)
        self.assertIn('if(payload.build.acceptItem(payload.build, item)){', payload_loader)
        self.assertIn('payload.build.handleItem(payload.build, item);', payload_loader)
        self.assertIn('items.remove(item, 1);', payload_loader)
        self.assertIn('acceptedAny = true;', payload_loader)
        self.assertIn('}else if(payload.block().separateItemCapacity || payload.block().consumesItem(item)){', payload_loader)
        self.assertIn('exporting = true;', payload_loader)
        self.assertIn('if(!acceptedAny){', payload_loader)
        self.assertIn('if(payload.block().hasLiquids && liquids.currentAmount() >= 0.001f){', payload_loader)
        self.assertIn('Liquid liq = liquids.current();', payload_loader)
        self.assertIn('float total = liquids.currentAmount();', payload_loader)
        self.assertIn('float flow = Math.min(Math.min(liquidsLoaded * edelta(), payload.block().liquidCapacity - payload.build.liquids.get(liq)), total);', payload_loader)
        self.assertIn('if(payload.build.acceptLiquid(payload.build, liq)){', payload_loader)
        self.assertIn('if(!(payload.block() instanceof LiquidVoid)){', payload_loader)
        self.assertIn('payload.build.liquids.add(liq, flow);', payload_loader)
        self.assertIn('liquids.remove(liq, flow);', payload_loader)
        self.assertIn('float powerInput = power.status * (basePowerUse + maxPowerConsumption);', payload_loader)
        self.assertIn('float availableInput = Math.max(powerInput - basePowerUse, 0f);', payload_loader)
        self.assertIn('float cap = payload.block().consPower.capacity;', payload_loader)
        self.assertIn('payload.build.power.status += availableInput / cap * edelta();', payload_loader)
        self.assertIn('if(payload.build.power.status >= 1f){', payload_loader)
        self.assertIn('payload.build.power.status = Mathf.clamp(payload.build.power.status);', payload_loader)
        self.assertIn('basePowerUse = consPower != null ? consPower.usage : 0f;', payload_loader)
        self.assertIn('return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);', payload_loader)
        self.assertIn('return block.itemCapacity;', payload_loader)
        self.assertIn('return linkedCore != null ? linkedCore.acceptItem(source, item) : items.get(item) < getMaximumAccepted(item);', payload_loader)
        self.assertIn('return block.hasLiquids && block.consumesLiquid(liquid);', payload_loader)
        self.assertIn('return (liquids.current() == liquid || liquids.currentAmount() < 0.2f);', payload_loader)
        self.assertIn('public boolean separateItemCapacity = false;', payload_loader)
        self.assertIn('public boolean consumesItem(Item item){', payload_loader)
        self.assertIn('return itemFilter[item.id];', payload_loader)
        self.assertIn('public boolean any(){', payload_loader)
        self.assertIn('return total > 0;', payload_loader)
        self.assertIn('public float currentAmount(){', payload_loader)
        self.assertIn('return liquids[current.id];', payload_loader)
        self.assertIn('public void remove(Liquid liquid, float amount){', payload_loader)
        self.assertIn('add(liquid, Math.max(-amount, -liquids[liquid.id]));', payload_loader)
        self.assertIn('public void add(Liquid liquid, float amount){', payload_loader)
        self.assertIn('liquids[liquid.id] += amount;', payload_loader)
        self.assertIn('return Time.delta * timeScale;', payload_loader)
        self.assertIn('return efficiency * delta();', payload_loader)
        self.assertIn('public float rotdeg(){', payload_loader)
        self.assertIn('return rotation * 90;', payload_loader)
        self.assertIn('public static final int tilesize = 8;', payload_loader)
        self.assertIn('public @Nullable Building front(){', payload_loader)
        self.assertIn('int trns = block.size/2 + 1;', payload_loader)
        self.assertIn('return nearby(Geometry.d4(rotation).x * trns, Geometry.d4(rotation).y * trns);', payload_loader)
        self.assertIn('updateConsumption();', payload_loader)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', payload_loader)
        self.assertIn('public boolean noUpdateDisabled = false;', payload_loader)
        self.assertIn('boolean update = shouldConsume() && productionValid();', payload_loader)
        self.assertIn('if(!update){', payload_loader)
        self.assertIn('consumePower(2f);', payload_loader)
        self.assertIn('size = 3;', payload_loader)
        # The def consts arrive as driver consts (the N2220 /
        # N2224 precedent): loadTime 2f, itemsLoaded 8,
        # liquidsLoaded 40f, maxBlockSize 3, maxPowerConsumption
        # 40f, basePowerUse 2f (the def consumePower), size 3,
        # payloadSpeed 0.7f, payloadRotateSpeed 5f. The frame
        # carries the new keys with the Java field defaults
        # (exporting false, payVector (0, 0), payRotation 0f,
        # items / liquids empty).
        self.assertIn('SOURCE_PAYLOAD_LOADER_LOAD_TIME := 2.0', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_ITEMS_LOADED := 8', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_LIQUIDS_LOADED := 40.0', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_MAX_BLOCK_SIZE := 3', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_MAX_POWER_CONSUMPTION := 40.0', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_BASE_POWER_USE := 2.0', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_SIZE := 3', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_PAYLOAD_SPEED := 0.7', payload_loader)
        self.assertIn('SOURCE_PAYLOAD_LOADER_PAYLOAD_ROTATE_SPEED := 5.0', payload_loader)
        self.assertIn('"payload": null', payload_loader)
        self.assertIn('"exporting": false', payload_loader)
        self.assertIn('"pay_rotation": 0.0', payload_loader)
        # The moveOut branch REUSES the ported helper through a
        # preload (the N2224 cross-driver precedent) -- it is
        # NOT re-implemented -- and the moveIn approach reuses
        # the helper's Vec2.approach. The rotation step reuses
        # SourceMathState.source_angles_move_toward and the
        # liquid steps reuse SourceLiquidModuleState. The item
        # steps reuse the shared drill inventory helpers.
        self.assertIn('preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")', payload_loader)
        self.assertIn('move_out_payload_state(', payload_loader)
        self.assertIn('source_vec2_approach(', payload_loader)
        self.assertIn('source_angles_move_toward(', payload_loader)
        self.assertIn('source_liquid_module_state.source_current_amount_state(', payload_loader)
        self.assertIn('source_liquid_module_state.source_remove_state(', payload_loader)
        self.assertIn('inventory.items_total(', payload_loader)
        self.assertIn('inventory.add_item_state(', payload_loader)
        self.assertIn('inventory.remove_item_state(', payload_loader)
        # The driver wires the advance into the live tick after
        # the consumption fold (the Java order:
        # updateConsumption before updateTile,
        # BuildingComp.java:2274-2277) -- and WITHOUT an enabled
        # guard: PayloadLoader has noUpdateDisabled = false (the
        # Block default, Block.java:170), so Java runs
        # updateTile() even when disabled (efficiency folds to 0
        # through updateConsumption, so the edelta loads stall
        # while moveIn/moveOut still run on delta). The driver
        # passes the live load_tick (N2319 -- the load timer
        # cadence is live; the N2319 pin update, the N2290/N2304
        # precedent), the live rotdeg from the rotation meta,
        # block_rotate true (the ctor value), the catalog item
        # order, and no-front defaults (no live front query
        # yet). The liquids store syncs from the sprite meta
        # each tick (the Fracker pattern).
        self.assertIn('game_source_delta(game, seconds)', payload_loader)
        self.assertIn('time_scale(sprite', payload_loader)
        self.assertIn('source_payload_loader_update_tile_advance_state(frame, source_delta, time_scale, load_tick, rotdeg_value, true, item_order, liquid_names_by_id, front, false, SOURCE_PAYLOAD_LOADER_BASE_POWER_USE)', payload_loader)
        self.assertIn('SOURCE_BUILD_ROTATION_META_KEY', payload_loader)
        self.assertIn('item_names_by_id', payload_loader)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', payload_loader)
        self.assertIn('frame["exporting"]', payload_loader)
        self.assertIn('frame["pay_vector"]', payload_loader)
        self.assertIn('frame["pay_rotation"]', payload_loader)
        self.assertIn('frame["items"]', payload_loader)
        self.assertIn('frame["liquids"]', payload_loader)
        self.assertIn('frame["payload"]', payload_loader)
        # The documented limits now record the updateTile
        # advance as live and the remaining deferrals (timer
        # cadence, movePayload/dumpPayload application, live
        # front gather, live payload fill); the old N2162 "No
        # updateTile advance" text is gone. The N2162 power row
        # and the N2208 gate are preserved.
        self.assertIn('updateTile advance live (N2231)', payload_loader)
        self.assertNotIn('No updateTile advance', payload_loader)
        self.assertIn('shouldConsume gate live (N2208)', payload_loader)
        self.assertIn('static func source_payload_loader_should_consume_state', payload_loader)
        self.assertIn('static func source_payload_loader_power_status_row_state', payload_loader)
        # The proof's keys drive the pure advance (moveIn
        # arrival at the center with the len2 < 0.01 rule, item
        # loading on the timer tick in content-id order, liquid
        # flow folding edelta, the battery charging to full and
        # exporting, shouldExport folding all four flags, and
        # moveOut pushing the payload to the front and handing
        # it off). Static checks: the proof preloads the family
        # state file that exists, and the scene file references
        # the proof script that exists.
        proof = PAYLOAD_LOADER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'move_in_arrives_at_center',
            'load_items_on_timer_tick',
            'load_liquids_folds_edelta',
            'battery_charges_and_exports_when_full',
            'should_export_folds_flags',
            'move_out_pushes_payload',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadLoaderBuildState.gd")', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_update_tile_advance_state(', proof)
        self.assertTrue(PAYLOAD_LOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_LOADER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadLoaderUpdateTileProof.gd', scene)
        self.assertIn('C07PayloadLoaderUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_payload_loader_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadLoaderUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_LOADER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'move_in_arrives_at_center',
            'load_items_on_timer_tick',
            'load_liquids_folds_edelta',
            'battery_charges_and_exports_when_full',
            'should_export_folds_flags',
            'move_out_pushes_payload',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
