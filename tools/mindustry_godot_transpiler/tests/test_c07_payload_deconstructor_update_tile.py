import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorUpdateTileProof.gd'
PAYLOAD_DECONSTRUCTOR_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorUpdateTileProof.tscn'


class C07PayloadDeconstructorUpdateTileTests(unittest.TestCase):
    def test_c07_payload_deconstructor_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2233']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_update_tile_advance_state')
        # N2166 gave the deconstructor its live power.status row
        # and N2210 its live shouldConsume gate (deconstructing
        # != null && enabled) -- but RED-deferred the updateTile
        # advance itself: the port tracked no progress / time /
        # speedScl / accum at all, so a deconstructor never
        # deconstructed anything even at full power. N2233 is
        # the updateTile advance (PayloadDeconstructorBuild.
        # updateTile(), PayloadDeconstructor.java:109-204):
        # progress resets to 0f with no deconstructing payload
        # (:117-119); payRotation moves toward 90f at
        # payloadRotateSpeed * edelta() (:121, NOTE edelta(),
        # not delta() as in moveInPayload); the deconstruct
        # branch (:123-196) resizes accum (:126-128), gates on
        # canProgress (items.total() <= itemCapacity && every
        # accum < 1f, :132-140), advances shift = edelta() *
        # deconstructSpeed / buildTime() (:142) with progress
        # += shift -- NOT realShift, so progress can pass 1f
        # (:159) -- folds the requirements into accum with the
        # build / unit cost multiplier (:163-165), lerps
        # speedScl toward 1f / 0f at 0.1f (:167), transfers
        # whole items into the inventory (:170-176), and at
        # progress >= 1f (:179) runs the rounding check
        # (equal(accum[i], 1f, 0.0001f), :182) before clearing
        # deconstructing / accum (:191-194); the intake branch
        # (:197-201) moves the payload in with rotate = FALSE
        # and starts deconstructing it. Ten new result symbols:
        # the advanced frame values plus the finish flag.
        self.assertEqual(
            ledger['N2233']['source_symbols'],
            [
                'source_payload_deconstructor_update_tile_advance_state_result.progress',
                'source_payload_deconstructor_update_tile_advance_state_result.time',
                'source_payload_deconstructor_update_tile_advance_state_result.speed_scl',
                'source_payload_deconstructor_update_tile_advance_state_result.accum',
                'source_payload_deconstructor_update_tile_advance_state_result.items',
                'source_payload_deconstructor_update_tile_advance_state_result.deconstructing',
                'source_payload_deconstructor_update_tile_advance_state_result.payload',
                'source_payload_deconstructor_update_tile_advance_state_result.pay_vector',
                'source_payload_deconstructor_update_tile_advance_state_result.pay_rotation',
                'source_payload_deconstructor_update_tile_advance_state_result.finished',
            ],
        )
        for name in ledger['N2233']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
                    'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_update_tile_advance_state')
        self.assertEqual(ledger['N2233']['runtime_proof'], '/root/C07PayloadDeconstructorUpdateTileProof')
        self.assertEqual(
            ledger['N2233']['tests'],
            [
                'test_c07_payload_deconstructor_update_tile_registration',
                'test_all_c07_payload_deconstructor_update_tile_input_evidence_is_exact',
                'test_payload_deconstructor_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_update_tile',
            ],
        )
        self.assertTrue(ledger['N2233']['deferred_exprs'])
        # This slice resolves the N2166 PayloadDeconstructor
        # updateTile advance deferral and adds the puddles
        # liquid dump + moveInPayload live payload positioning
        # + Fx.breakBlock finish effect deferrals. The live
        # deconstructing fill entry stays: the advance moves a
        # frame payload into deconstructing, but no live
        # handlePayload fill sets frame["payload"] yet.
        self.assertFalse(any(entry.startswith('PayloadDeconstructor updateTile advance (') for entry in ledger['N2233']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor puddles liquid dump (') for entry in ledger['N2233']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor moveInPayload live payload positioning (') for entry in ledger['N2233']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor Fx.breakBlock finish effect (') for entry in ledger['N2233']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor live deconstructing fill (') for entry in ledger['N2233']['deferred_exprs']))

    def test_all_c07_payload_deconstructor_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2233']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_update_tile_advance_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/BuildPayload.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/UnitPayload.java'),
            ('mindustry-upstream', 'core/src/mindustry/game/Rules.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Mathf.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Angles.java'),
            ('arc-upstream', 'arc-core/src/arc/math/geom/Vec2.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2233']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_update_tile_advance_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the payload-deconstructor
        # build state: the progress reset
        # (PayloadDeconstructor.java:117-119), the payRotation
        # moveToward at payloadRotateSpeed * edelta()
        # (PayloadDeconstructor.java:121 -- edelta(), NOT
        # delta() as in moveInPayload), the deconstruct branch
        # (PayloadDeconstructor.java:123-196) with the accum
        # resize, the canProgress gate, shift / realShift,
        # progress += shift (NOT realShift), the accum fold
        # with the build / unit cost multipliers, the speedScl
        # lerpDelta, the whole-item transfer, and the finish
        # branch with its rounding check, plus the intake
        # branch (PayloadDeconstructor.java:197-201) with
        # moveInPayload(FALSE). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). delta() = Time.delta *
        # timeScale (BuildingComp.java:1922-1924), edelta() =
        # efficiency * delta() (BuildingComp.java:1927-1929);
        # Time.delta in the port is seconds * 60 through
        # game_source_delta (arc Time.java:26), never raw
        # seconds (the N2186/N2187/N2191 lesson: raw seconds
        # run 60x slow). lerpDelta scales by Time.delta, not
        # delta() (Mathf.java:430-432), so the speedScl lerp
        # uses the unscaled source delta.
        self.assertIn('static func source_payload_deconstructor_update_tile_advance_state', payload_deconstructor)
        self.assertIn('if(deconstructing == null){', payload_deconstructor)
        self.assertIn('progress = 0f;', payload_deconstructor)
        self.assertIn('payRotation = Angles.moveToward(payRotation, 90f, payloadRotateSpeed * edelta());', payload_deconstructor)
        self.assertIn('var reqs = deconstructing.requirements();', payload_deconstructor)
        self.assertIn('if(accum == null || reqs.length != accum.length){', payload_deconstructor)
        self.assertIn('accum = new float[reqs.length];', payload_deconstructor)
        self.assertIn('boolean canProgress = items.total() <= itemCapacity;', payload_deconstructor)
        self.assertIn('if(ac >= 1f){', payload_deconstructor)
        self.assertIn('float shift = edelta() * deconstructSpeed / deconstructing.buildTime();', payload_deconstructor)
        self.assertIn('float realShift = Math.min(shift, 1f - progress);', payload_deconstructor)
        self.assertIn('progress += shift;', payload_deconstructor)
        self.assertIn('time += edelta();', payload_deconstructor)
        self.assertIn('accum[i] += reqs[i].amount * (deconstructing instanceof BuildPayload ? state.rules.buildCostMultiplier : state.rules.unitCost(team)) * realShift;', payload_deconstructor)
        self.assertIn('speedScl = Mathf.lerpDelta(speedScl, canProgress ? 1f : 0f, 0.1f);', payload_deconstructor)
        self.assertIn('int taken = Math.min((int)accum[i], itemCapacity - items.total());', payload_deconstructor)
        self.assertIn('items.add(reqs[i].item, taken);', payload_deconstructor)
        self.assertIn('accum[i] -= taken;', payload_deconstructor)
        self.assertIn('if(progress >= 1f){', payload_deconstructor)
        self.assertIn('if(Mathf.equal(accum[i], 1f, 0.0001f)){', payload_deconstructor)
        self.assertIn('if(items.total() < itemCapacity){', payload_deconstructor)
        self.assertIn('items.add(reqs[i].item, 1);', payload_deconstructor)
        self.assertIn('accum[i] = 0f;', payload_deconstructor)
        self.assertIn('deconstructing = null;', payload_deconstructor)
        self.assertIn('accum = null;', payload_deconstructor)
        self.assertIn('}else if(moveInPayload(false) && payload != null){', payload_deconstructor)
        self.assertIn('accum = new float[payload.requirements().length];', payload_deconstructor)
        self.assertIn('deconstructing = payload;', payload_deconstructor)
        self.assertIn('payload = null;', payload_deconstructor)
        self.assertIn('return Time.delta * timeScale;', payload_deconstructor)
        self.assertIn('return efficiency * delta();', payload_deconstructor)
        self.assertIn('public @Nullable Payload deconstructing;', payload_deconstructor)
        self.assertIn('public @Nullable float[] accum;', payload_deconstructor)
        self.assertIn('public float progress;', payload_deconstructor)
        self.assertIn('public float time, speedScl;', payload_deconstructor)
        # The payload dict contract (decision 8): kind
        # ("build" / "unit"), requirements (ItemStack list),
        # build_time. BuildPayload requirements are the block
        # requirements (BuildPayload.java:66-68) and its
        # buildTime is the block buildTime (BuildPayload
        # .java:71-73); UnitPayload requirements are the unit
        # type total requirements (UnitPayload.java:61-63) and
        # its buildTime is the unit type buildTime
        # (UnitPayload.java:66-68). The multipliers are Rules
        # params at their Java defaults (Rules.java:115
        # buildCostMultiplier 1f; Rules.java:275-276 unitCost
        # = unitCostMultiplier * team unitCostMultiplier, both
        # 1f, Rules.java:83/361) -- the unit cost reads live
        # through the existing SourceRulesRuntimeState helper,
        # the build cost reads the rules dict with the Java
        # default when the port's rules shape does not carry
        # it yet.
        self.assertIn('return build.block.requirements;', payload_deconstructor)
        self.assertIn('return build.block.buildTime;', payload_deconstructor)
        self.assertIn('return unit.type.getTotalRequirements();', payload_deconstructor)
        self.assertIn('return unit.type.getBuildTime();', payload_deconstructor)
        self.assertIn('public float buildCostMultiplier = 1f;', payload_deconstructor)
        self.assertIn('return unitCostMultiplier * teams.get(team).unitCostMultiplier;', payload_deconstructor)
        self.assertIn('source_rules_state.source_unit_cost_state(', payload_deconstructor)
        # moveInPayload is ported in the driver (decision 7):
        # updatePayload positions the live payload
        # (PayloadBlock.java:174-177, deferred -- the port's
        # payload dict carries no position); rotate is FALSE
        # so the rotation branch never runs; payVector
        # approaches zero at payloadSpeed * delta()
        # (PayloadBlock.java:194, delta() NOT edelta()); the
        # arrival check is hasArrived()
        # (PayloadBlock.java:242-244, Vec2.isZero(0.01f) =
        # len2() < margin, Vec2.java:679-681 -- the SQUARED
        # length, not the length). The deconstructor overrides
        # payloadSpeed to 1f (PayloadDeconstructor.java:31);
        # payloadRotateSpeed stays the PayloadBlock class
        # default 5f (PayloadBlock.java:18).
        self.assertIn('static func _deconstructor_move_in_payload', payload_deconstructor)
        self.assertIn('static func _deconstructor_vec2_approach', payload_deconstructor)
        self.assertIn('public boolean moveInPayload(boolean rotate){', payload_deconstructor)
        self.assertIn('if(payload == null) return false;', payload_deconstructor)
        self.assertIn('payVector.approach(Vec2.ZERO, payloadSpeed * delta());', payload_deconstructor)
        self.assertIn('return hasArrived();', payload_deconstructor)
        self.assertIn('return payVector.isZero(0.01f);', payload_deconstructor)
        self.assertIn('payload.set(x + payVector.x, y + payVector.y, payRotation);', payload_deconstructor)
        self.assertIn('float dx = x - target.x, dy = y - target.y;', payload_deconstructor)
        self.assertIn('return len2() < margin;', payload_deconstructor)
        self.assertIn('payloadSpeed = 1f;', payload_deconstructor)
        self.assertIn('public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', payload_deconstructor)
        self.assertIn('public @Nullable T payload;', payload_deconstructor)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_deconstructor)
        self.assertIn('public float payRotation;', payload_deconstructor)
        # The math helpers are reused through the
        # SourceMathState preload (the N2224 reuse precedent),
        # not re-implemented: moveToward
        # (Angles.java:38-41) and lerpDelta (Mathf.java:430-432,
        # `return lerp(fromValue, toValue, clamp(progress *
        # Time.delta));`); the rounding check is
        # Mathf.equal (Mathf.java:554-556, `return Math.abs(a -
        # b) <= tolerance;`). Item adds go through the drill
        # inventory helper (add_item_state), totals through
        # items_total -- never recomputed by hand.
        self.assertIn('source_math_state.source_angles_move_toward(', payload_deconstructor)
        self.assertIn('source_math_state.source_lerp_delta(', payload_deconstructor)
        self.assertIn('if(Math.abs(angleDist(angle, to)) < speed) return to;', payload_deconstructor)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', payload_deconstructor)
        self.assertIn('return Math.abs(a - b) <= tolerance;', payload_deconstructor)
        self.assertIn('inventory.add_item_state(items', payload_deconstructor)
        self.assertIn('inventory.items_total(items)', payload_deconstructor)
        # deconstructSpeed is per-def (the catalog parses no
        # deconstructSpeed property, so the driver reads
        # constants): deconstructor 6f (Blocks.java:6655),
        # small-deconstructor 3f (Blocks.java:6646), class
        # default 2.5f (PayloadDeconstructor.java:19); the
        # itemCapacity comes from the catalog (250 deconstructor
        # / 100 small, Blocks.java:6652/6643) with the ctor
        # default 100 (PayloadDeconstructor.java:37).
        self.assertIn('SOURCE_DECONSTRUCTOR_DECONSTRUCT_SPEED := 6.0', payload_deconstructor)
        self.assertIn('SOURCE_SMALL_DECONSTRUCTOR_DECONSTRUCT_SPEED := 3.0', payload_deconstructor)
        self.assertIn('SOURCE_PAYLOAD_DECONSTRUCTOR_CLASS_DECONSTRUCT_SPEED := 2.5', payload_deconstructor)
        self.assertIn('deconstructSpeed = 6f;', payload_deconstructor)
        self.assertIn('deconstructSpeed = 3f;', payload_deconstructor)
        self.assertIn('public float deconstructSpeed = 2.5f;', payload_deconstructor)
        self.assertIn('itemCapacity = 250;', payload_deconstructor)
        self.assertIn('itemCapacity = 100;', payload_deconstructor)
        self.assertIn('public float maxPayloadSize = 4;', payload_deconstructor)
        self.assertIn('public int dumpRate = 4;', payload_deconstructor)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption and only when enabled
        # (BuildingComp.java:2274 updateConsumption(), then the
        # updateTile gate `if(enabled || !block.noUpdateDisabled){`
        # at BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170).
        self.assertIn('game_source_delta(game, seconds)', payload_deconstructor)
        self.assertIn('time_scale(sprite', payload_deconstructor)
        self.assertIn('source_payload_deconstructor_update_tile_advance_state(frame, source_delta, time_scale, deconstruct_speed, item_capacity, build_cost_multiplier, unit_cost_multiplier)', payload_deconstructor)
        self.assertIn('frame["progress"]', payload_deconstructor)
        self.assertIn('frame["time"]', payload_deconstructor)
        self.assertIn('frame["speed_scl"]', payload_deconstructor)
        self.assertIn('frame["accum"]', payload_deconstructor)
        self.assertIn('frame["items"]', payload_deconstructor)
        self.assertIn('frame["deconstructing"]', payload_deconstructor)
        self.assertIn('frame["payload"]', payload_deconstructor)
        self.assertIn('frame["pay_vector"]', payload_deconstructor)
        self.assertIn('frame["pay_rotation"]', payload_deconstructor)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', payload_deconstructor)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', payload_deconstructor)
        self.assertIn('public boolean noUpdateDisabled = false;', payload_deconstructor)
        self.assertIn('block.properties.get("itemCapacity", 100)', payload_deconstructor)
        # The documented limits now record the advance as done
        # (progress / time / speedScl / accum / transfer /
        # finish / intake) and the remaining deferrals (the
        # dump, the puddles liquid dump, the Fx.breakBlock
        # effect, the live payload fill); the N2210 gate and
        # the N2166 power row are preserved.
        self.assertIn('Partial updateTile advance (N2233)', payload_deconstructor)
        self.assertIn('shouldConsume gate live (N2210)', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_power_status_row_state', payload_deconstructor)
        self.assertIn('static func source_payload_deconstructor_should_consume_state', payload_deconstructor)
        # The proof's keys drive the pure advance (intake,
        # progress with edelta, the accum fold, the whole-item
        # transfer, the finish clear with its rounding check,
        # the progress reset without a deconstructing payload)
        # plus the live tick (a placed deconstructor advances
        # progress / time / accum / speedScl / payRotation at
        # half power).
        proof = PAYLOAD_DECONSTRUCTOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'intake_moves_payload_to_deconstructing',
            'progress_advances_with_edelta',
            'accum_folds_requirements',
            'transfer_moves_whole_items',
            'finish_clears_deconstructing',
            'progress_zero_without_deconstructing',
            'live_tick_advances_progress',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(', proof)
        self.assertIn('payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)', proof)
        scene = PAYLOAD_DECONSTRUCTOR_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadDeconstructorUpdateTileProof.gd', scene)
        self.assertIn('C07PayloadDeconstructorUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_payload_deconstructor_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'intake_moves_payload_to_deconstructing',
            'progress_advances_with_edelta',
            'accum_folds_requirements',
            'transfer_moves_whole_items',
            'finish_clears_deconstructing',
            'progress_zero_without_deconstructing',
            'live_tick_advances_progress',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
