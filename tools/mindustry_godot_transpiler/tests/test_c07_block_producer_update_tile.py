import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceConstructorBuildState.gd'
BLOCK_PRODUCER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BlockProducerUpdateTileProof.gd'
BLOCK_PRODUCER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BlockProducerUpdateTileProof.tscn'


class C07BlockProducerUpdateTileTests(unittest.TestCase):
    def test_c07_block_producer_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2274']['godot_owner'], 'SourceConstructorBuildState.source_constructor_update_tile_advance_state')
        # N2161 proved the constructor's live power read, N2216
        # its shouldConsume gate (enabled && recipe != null),
        # and N2265 its dynamic item row (ConsumeItemDynamic
        # over the recipe requirements, folded BINARY into the
        # first pass, plus the pure trigger -- tested pure, NOT
        # wired live). What was still missing was the whole
        # updateTile advance (BlockProducer.java:107-128):
        # the produce gate (BlockProducer.java:110, `boolean
        # produce = recipe != null && efficiency > 0 &&
        # payload == null;`) with the progress advance
        # (BlockProducer.java:113, `progress += buildSpeed *
        # edelta();`), the completion branch
        # (BlockProducer.java:115-120, `if(progress >=
        # recipe.buildTime){` / `consume();` / `payload = new
        # BuildPayload(recipe, team);` / placeEffect /
        # `payVector.setZero();` / `progress %= 1f;`), the
        # heat lerp (BlockProducer.java:124, `heat =
        # Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);`),
        # the time advance (BlockProducer.java:125, `time +=
        # heat * delta();`), and moveOutPayload
        # (BlockProducer.java:127, through the reused
        # SourceBlockProducerMoveOutPayloadState helper,
        # PayloadBlock.java:199-228). N2274 is that advance:
        # one pure function returning the advanced frame
        # values (progress / heat / time / payload /
        # pay_vector / pay_rotation / items / consumed),
        # wired into the tick after the consumption fold.
        # Eight new result symbols, not the six the scope
        # expected: items must come back (consume() removes
        # the recipe stacks through the N2265 trigger, and
        # the removal has to persist in the frame or the
        # trigger wiring is fake) and pay_rotation must come
        # back (moveOutPayload rotates it toward rotdeg every
        # tick, and the rotation only progresses if the
        # driver persists it -- the N2231 precedent).
        self.assertEqual(
            ledger['N2274']['source_symbols'],
            [
                'source_constructor_update_tile_advance_state_result.progress',
                'source_constructor_update_tile_advance_state_result.heat',
                'source_constructor_update_tile_advance_state_result.time',
                'source_constructor_update_tile_advance_state_result.payload',
                'source_constructor_update_tile_advance_state_result.pay_vector',
                'source_constructor_update_tile_advance_state_result.pay_rotation',
                'source_constructor_update_tile_advance_state_result.items',
                'source_constructor_update_tile_advance_state_result.consumed',
            ],
        )
        for name in ledger['N2274']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_constructor_update_tile_advance_state_result.progress': 'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
                    'source_constructor_update_tile_advance_state_result.heat': 'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
                    'source_constructor_update_tile_advance_state_result.time': 'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
                    'source_constructor_update_tile_advance_state_result.payload': 'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
                    'source_constructor_update_tile_advance_state_result.pay_vector': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_constructor_update_tile_advance_state_result.pay_rotation': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_constructor_update_tile_advance_state_result.items': 'core/src/mindustry/world/consumers/ConsumeItemDynamic.java',
                    'source_constructor_update_tile_advance_state_result.consumed': 'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
                }[name])
                self.assertEqual(symbol['godot_owner'], 'SourceConstructorBuildState.source_constructor_update_tile_advance_state')
        self.assertEqual(ledger['N2274']['runtime_proof'], '/root/C07BlockProducerUpdateTileProof')
        self.assertEqual(
            ledger['N2274']['tests'],
            [
                'test_c07_block_producer_update_tile_registration',
                'test_all_c07_block_producer_update_tile_input_evidence_is_exact',
                'test_block_producer_update_tile_state',
                'test_reference_graph_and_actual_c07_block_producer_update_tile',
            ],
        )
        self.assertTrue(ledger['N2274']['deferred_exprs'])
        # This slice resolves THREE deferrals: the updateTile
        # advance entry, the dynamic item trigger live wiring
        # (the N2265 trigger now fires through consume() when
        # progress completes), and the buildSpeed rows (the
        # per-def buildSpeed is now a driver const). Three new
        # deferrals record what this slice leaves behind (the
        # explicit-def recipe buildTime the catalog cannot see,
        # the spawned-payload block flags, the live front
        # gather for moveOutPayload). DEFERRED goes 290 - 3 +
        # 3 = 290 entries.
        self.assertEqual(len(ledger['N2274']['deferred_exprs']), 290)
        self.assertFalse(any(entry.startswith('Constructor / BlockProducer updateTile advance (') for entry in ledger['N2274']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('BlockProducer dynamic item trigger live wiring (') for entry in ledger['N2274']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('Constructor buildSpeed rows (') for entry in ledger['N2274']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor explicit-def recipe buildTime (') for entry in ledger['N2274']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor spawned-payload block flags (') for entry in ledger['N2274']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor moveOutPayload live front gather (') for entry in ledger['N2274']['deferred_exprs']))
        # The payload / draw rows stay deferred (placeEffect
        # is presentation, BlockProducer.java:118), the config
        # path stays deferred (no live fill sets frame
        # ["recipe"] yet), and the frame items intake stays
        # deferred (no live intake fills frame["items"] yet).
        self.assertTrue(any(entry.startswith('Constructor payload / draw rows (') for entry in ledger['N2274']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor live recipe config fill (') for entry in ledger['N2274']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor frame items intake (') for entry in ledger['N2274']['deferred_exprs']))

    def test_all_c07_block_producer_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2274']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceConstructorBuildState.source_constructor_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
            'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/consumers/ConsumeItemDynamic.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/type/Item.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2274']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_block_producer_update_tile_state(self):
        constructor = CONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure advance mirrors BlockProducerBuild.
        # updateTile() (BlockProducer.java:107-128): the
        # produce gate (BlockProducer.java:110, `boolean
        # produce = recipe != null && efficiency > 0 &&
        # payload == null;`), the progress advance
        # (BlockProducer.java:113, `progress += buildSpeed *
        # edelta();`), the completion branch
        # (BlockProducer.java:115-120, `if(progress >=
        # recipe.buildTime){` / `consume();` / `payload = new
        # BuildPayload(recipe, team);` / `payVector.setZero();`
        # / `progress %= 1f;` -- the remainder is KEPT, not
        # reset to 0), the heat lerp
        # (BlockProducer.java:124, `heat =
        # Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);`),
        # the time advance (BlockProducer.java:125, `time +=
        # heat * delta();`), and moveOutPayload
        # (BlockProducer.java:127). delta() is `return
        # Time.delta * timeScale;` (BuildingComp.java:1922-1924)
        # and edelta() is `return efficiency * delta();`
        # (BuildingComp.java:1927-1929); the heat lerp takes
        # the RAW Time.delta (arc Mathf.lerpDelta is `return
        # lerp(fromValue, toValue, clamp(progress *
        # Time.delta));`, Mathf.java:430-432 -- the N2193
        # precedent), while progress / time use the scaled
        # delta / edelta.
        self.assertIn('static func source_constructor_update_tile_advance_state', constructor)
        self.assertIn('boolean produce = recipe != null && efficiency > 0 && payload == null;', constructor)
        self.assertIn('progress += buildSpeed * edelta();', constructor)
        self.assertIn('if(progress >= recipe.buildTime){', constructor)
        self.assertIn('consume();', constructor)
        self.assertIn('payload = new BuildPayload(recipe, team);', constructor)
        self.assertIn('payVector.setZero();', constructor)
        self.assertIn('progress %= 1f;', constructor)
        self.assertIn('fmod(progress, 1.0)', constructor)
        self.assertIn('heat = Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);', constructor)
        self.assertIn('time += heat * delta();', constructor)
        self.assertIn('moveOutPayload();', constructor)
        self.assertIn('return Time.delta * timeScale;', constructor)
        self.assertIn('return efficiency * delta();', constructor)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', constructor)
        self.assertIn('source_lerp_delta(', constructor)
        # Completion consumes through the N2265 trigger
        # (ConsumeItemDynamic.trigger,
        # ConsumeItemDynamic.java:53-57, `build.items.remove(
        # stack.item, Math.round(stack.amount *
        # multiplier.get(build)));`) -- the trigger is wired
        # LIVE now, not just tested pure: consume() fires
        # when progress completes (BlockProducer.java:115-116).
        # The spawned payload is the BuildPayload dict
        # (BuildPayload.java:18-21, `public BuildPayload(Block
        # block, Team team){` with `this.build =
        # block.newBuilding().create(block, team);`); the
        # placeEffect (BlockProducer.java:118,
        # `payload.block().placeEffect.at(x, y, payload.size()
        # / tilesize);`) is presentation and defers.
        self.assertIn('source_constructor_dynamic_item_trigger_state(', constructor)
        self.assertIn('build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', constructor)
        self.assertIn('public BuildPayload(Block block, Team team){', constructor)
        self.assertIn('this.build = block.newBuilding().create(block, team);', constructor)
        self.assertIn('payload.block().placeEffect.at(x, y, payload.size() / tilesize);', constructor)
        # moveOutPayload reuses the ported helper (the N2231 /
        # N2224 cross-driver precedent): dest / rotation /
        # approach / canDump / canMove / push fraction /
        # arrival / clamp / movePayload / dumpPayload
        # (PayloadBlock.java:199-228) already live in
        # SourceBlockProducerMoveOutPayloadState.
        # moveOutPayload runs UNCONDITIONALLY every tick
        # (BlockProducer.java:127, after the heat/time lines),
        # including the tick a payload spawns.
        self.assertIn('preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")', constructor)
        self.assertIn('move_out_payload_state(', constructor)
        self.assertIn('public void moveOutPayload(){', constructor)
        self.assertIn('Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);', constructor)
        self.assertIn('payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());', constructor)
        self.assertIn('payVector.approach(dest, payloadSpeed * delta());', constructor)
        self.assertIn('public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', constructor)
        self.assertIn('public static final int tilesize = 8;', constructor)
        # buildSpeed resolves per def (constructor 0.6f /
        # large-constructor 0.75f, Blocks.java:6662/6674) with
        # the class default 0.4f (BlockProducer.java:22,
        # `public float buildSpeed = 0.4f;`) as fallback --
        # the catalog carries no buildSpeed key.
        self.assertIn('SOURCE_CONSTRUCTOR_BUILD_SPEED', constructor)
        self.assertIn('buildSpeed = 0.6f;', constructor)
        self.assertIn('buildSpeed = 0.75f;', constructor)
        self.assertIn('public float buildSpeed = 0.4f;', constructor)
        # The recipe buildTime follows the Block.init formula
        # (Block.java:1432-1443): requirements present ->
        # sum(amount * item.cost); no requirements -> 20f;
        # then *= buildCostMultiplier. The catalog carries no
        # buildTime key, but it carries requirements and item
        # costs (`public float cost = 1f;`, Item.java:35, the
        # default for an item the catalog does not know).
        self.assertIn('if(requirements.length > 0 && buildTime < 0){', constructor)
        self.assertIn('buildTime += stack.amount * stack.item.cost;', constructor)
        self.assertIn('buildTime = 20f;', constructor)
        self.assertIn('buildTime *= buildCostMultiplier;', constructor)
        self.assertIn('public float cost = 1f;', constructor)
        # The tick wires the advance after the consumption
        # fold -- the Java order, `updateConsumption();` then
        # `if(enabled || !block.noUpdateDisabled){` /
        # `updateTile();` (BuildingComp.java:2274-2277) -- and
        # WITHOUT an enabled guard: BlockProducer has `public
        # boolean noUpdateDisabled = false;` (Block.java:170,
        # the default), so Java runs updateTile() even when
        # disabled (the N2231 precedent). The driver passes
        # no-front defaults (no live front query yet) and
        # move_payload_result false, and writes the advanced
        # frame keys back.
        self.assertIn('static func source_constructor_tick_buildings_state', constructor)
        self.assertIn('source_constructor_update_tile_advance_state(', constructor)
        self.assertIn('updateConsumption();', constructor)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', constructor)
        self.assertIn('public boolean noUpdateDisabled = false;', constructor)
        self.assertIn('game_source_delta(', constructor)
        self.assertIn('frame["progress"]', constructor)
        self.assertIn('frame["heat"]', constructor)
        self.assertIn('frame["time"]', constructor)
        self.assertIn('frame["payload"]', constructor)
        self.assertIn('frame["pay_vector"]', constructor)
        self.assertIn('frame["pay_rotation"]', constructor)
        # The frame carries the new keys now (progress / heat
        # / time / payload / pay_vector / pay_rotation, the
        # Java field defaults: `public float progress, time,
        # heat;` BlockProducer.java:78, `public @Nullable T
        # payload;` / `public Vec2 payVector = new Vec2();` /
        # `public float payRotation;` PayloadBlock.java:92-95).
        self.assertIn('"progress": 0.0', constructor)
        self.assertIn('"heat": 0.0', constructor)
        self.assertIn('"time": 0.0', constructor)
        self.assertIn('"payload": null', constructor)
        self.assertIn('"pay_vector": {"x": 0.0, "y": 0.0}', constructor)
        self.assertIn('"pay_rotation": 0.0', constructor)
        self.assertIn('public float progress, time, heat;', constructor)
        # The documented limits record the advance live, the
        # trigger wired live, and the placeEffect deferral.
        self.assertIn('updateTile advance live (N2274)', constructor)
        self.assertIn('trigger is wired live since N2274', constructor)
        # The proof's keys drive the pure advance (accumulate
        # / complete + spawn / remainder / heat lerp / time /
        # no-produce gates / move-out approach) plus the live
        # tick (a placed constructor advances progress and
        # spawns the payload).
        proof = BLOCK_PRODUCER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'progress_accumulates_when_producing',
            'progress_completes_spawns_payload',
            'progress_keeps_remainder_mod_one',
            'heat_lerps_toward_produce',
            'time_accumulates_with_heat',
            'no_progress_without_recipe',
            'move_out_payload_approaches_dest',
            'live_tick_advances_progress',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceConstructorBuildState.gd")', proof)
        self.assertIn('constructor_build_state.source_constructor_update_tile_advance_state(', proof)
        scene = BLOCK_PRODUCER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BlockProducerUpdateTileProof.gd', scene)
        self.assertIn('C07BlockProducerUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_block_producer_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BlockProducerUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BLOCK_PRODUCER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'progress_accumulates_when_producing',
            'progress_completes_spawns_payload',
            'progress_keeps_remainder_mod_one',
            'heat_lerps_toward_produce',
            'time_accumulates_with_heat',
            'no_progress_without_recipe',
            'move_out_payload_approaches_dest',
            'live_tick_advances_progress',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
