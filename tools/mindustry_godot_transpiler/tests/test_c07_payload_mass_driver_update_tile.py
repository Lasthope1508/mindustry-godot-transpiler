import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadMassDriverBuildState.gd'
PAYLOAD_MASS_DRIVER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverUpdateTileProof.gd'
PAYLOAD_MASS_DRIVER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverUpdateTileProof.tscn'
PAYLOAD_MASS_DRIVER_LARGE_VARIANT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverLargeVariantProof.gd'


class C07PayloadMassDriverUpdateTileTests(unittest.TestCase):
    def test_c07_payload_mass_driver_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2245']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_update_tile_advance_state')
        # N2164 proved the PayloadMassDriver live power read --
        # but the port tracked no link / charge / curSize /
        # effectDelayTimer / reload / waiting / state / payload
        # -carry state at all, so a payload-mass-driver never
        # left idle: the no-power skip gated on an efficiency
        # no advance ever followed. N2245 is the updateTile
        # advance PART 1, frame + state switch
        # (PayloadDriverBuild.updateTile(), PayloadMassDriver.
        # java:155-234): super.updateTile() (:156, noted --
        # the payload.update call defers, no live payload
        # entity), the link lookup + linkValid (:157-158, :466
        # -468), the charge discharge when not charging
        # (:161-164), the curSize lerp + targetSize (:166-171,
        # grabWidth 8f, payload.size() when a payload is held),
        # the effectDelayTimer countdown + reloadCounter = 1f
        # reset (:173-183, STATE only -- receiveEffect /
        # receiveSound / shake defer), the charging reset
        # (:184), the link pos refresh (:186-188), the
        # reloadCounter decay regardless of state (:191-192),
        # the currentShooter cleanup (:194-205, the inline
        # validity -- no shooterValid helper here, unlike
        # MassDriver), the idle -> accepting / shooting switch
        # (:208-215), the dump when idle or accepting
        # (:218-229, loaded unload + the PURE moveOutPayload
        # vector/rotation part -- pushOutput / dumpPayload /
        # movePayload defer), and the no-power return (:232
        # -234) that gates the N2246 branches. The accepting /
        # shooting branches (:236-332) belong to N2246, NOT
        # this slice. Thirteen new result symbols: the
        # advanced frame values. turret_rotation / last_other
        # / payload are frame keys this slice introduces but
        # part 1 only READS (turretRotation is written by the
        # N2246 branches, lastOther by the N2246 transfer,
        # payload by handlePayload/takePayload), so they are
        # not result symbols here.
        self.assertEqual(
            ledger['N2245']['source_symbols'],
            [
                'source_payload_mass_driver_update_tile_advance_state_result.link',
                'source_payload_mass_driver_update_tile_advance_state_result.charge',
                'source_payload_mass_driver_update_tile_advance_state_result.cur_size',
                'source_payload_mass_driver_update_tile_advance_state_result.target_size',
                'source_payload_mass_driver_update_tile_advance_state_result.effect_delay_timer',
                'source_payload_mass_driver_update_tile_advance_state_result.charging',
                'source_payload_mass_driver_update_tile_advance_state_result.reload_counter',
                'source_payload_mass_driver_update_tile_advance_state_result.waiting_shooters',
                'source_payload_mass_driver_update_tile_advance_state_result.state',
                'source_payload_mass_driver_update_tile_advance_state_result.pay_length',
                'source_payload_mass_driver_update_tile_advance_state_result.pay_rotation',
                'source_payload_mass_driver_update_tile_advance_state_result.pay_vector',
                'source_payload_mass_driver_update_tile_advance_state_result.loaded',
            ],
        )
        for name in ledger['N2245']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_payload_mass_driver_update_tile_advance_state_result.pay_vector': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                }.get(name, 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_update_tile_advance_state')
        self.assertEqual(ledger['N2245']['runtime_proof'], '/root/C07PayloadMassDriverUpdateTileProof')
        self.assertEqual(
            ledger['N2245']['tests'],
            [
                'test_c07_payload_mass_driver_update_tile_registration',
                'test_all_c07_payload_mass_driver_update_tile_input_evidence_is_exact',
                'test_payload_mass_driver_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_payload_mass_driver_update_tile',
            ],
        )
        self.assertTrue(ledger['N2245']['deferred_exprs'])
        # The updateTile advance entry is REWORDED, not
        # removed: N2245 ports the frame/state part
        # (:155-234) and the accepting/shooting branches
        # (:236-332) wait for N2246, which removes the entry.
        # Three new deferrals record what this slice leaves
        # behind (receive effects/sound/shake, the
        # moveOutPayload world interaction, the super.
        # updateTile payload update). DEFERRED base after
        # unification is 283 entries; reword keeps the count,
        # +3 new = 286.
        self.assertEqual(len(ledger['N2245']['deferred_exprs']), 286)
        self.assertFalse(any(entry.startswith('PayloadMassDriver updateTile advance (link/state-machine') for entry in ledger['N2245']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver updateTile advance (state branches accepting/shooting') for entry in ledger['N2245']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver updateTile effects / sound / shake rows (') for entry in ledger['N2245']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver moveOutPayload world interaction (') for entry in ledger['N2245']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadBlock super.updateTile payload update (') for entry in ledger['N2245']['deferred_exprs']))

    def test_all_c07_payload_mass_driver_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2245']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2245']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_mass_driver_update_tile_advance_state(self):
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the payload-mass-driver
        # build state: super.updateTile() (PayloadMassDriver.
        # java:156), the link lookup + linkValid (:157-158,
        # :466-468), the charge discharge (:161-164), the
        # curSize lerp + targetSize (:166-171), the
        # effectDelayTimer countdown + reloadCounter reset
        # (:173-183), the charging reset (:184), the link pos
        # refresh (:186-188), the reloadCounter decay
        # (:191-192), the currentShooter cleanup (:194-205),
        # the state switch (:208-215), the dump (:218-229),
        # the no-power return (:232-234), linkValid (:466-468)
        # and moveOutPayload (PayloadBlock.java:199-228, the
        # pure vector/rotation part). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). delta() is `return
        # Time.delta * timeScale;` (BuildingComp.java:1922
        # -1924) and edelta() is `return efficiency *
        # delta();` (BuildingComp.java:1927-1929); source_
        # delta is Time.delta in ticks (seconds * 60 through
        # game_source_delta, arc Time.java:26), never raw
        # seconds. The charge discharge and the effect timer
        # use RAW Time.delta, not edelta -- they run even at
        # efficiency 0. The reload decay uses edelta, so it
        # stalls at no power. The dump payLength is NOT
        # clamped at 0 (Java :220-222 only flips loaded).
        self.assertIn('static func source_payload_mass_driver_update_tile_advance_state', payload_mass_driver)
        self.assertIn('public class PayloadMassDriver extends PayloadBlock{', payload_mass_driver)
        self.assertIn('public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{', payload_mass_driver)
        self.assertIn('public float range = 100f;', payload_mass_driver)
        self.assertIn('public float reload = 30f;', payload_mass_driver)
        self.assertIn('public float grabWidth = 8f, grabHeight = 11/4f;', payload_mass_driver)
        self.assertIn('public int link = -1;', payload_mass_driver)
        self.assertIn('public float turretRotation = 90;', payload_mass_driver)
        self.assertIn('public float reloadCounter = 0f, charge = 0f;', payload_mass_driver)
        self.assertIn('public float targetSize = grabWidth*2f, curSize = targetSize;', payload_mass_driver)
        self.assertIn('public float payLength = 0f, effectDelayTimer = -1f;', payload_mass_driver)
        self.assertIn('public PayloadDriverBuild lastOther;', payload_mass_driver)
        self.assertIn('public boolean loaded;', payload_mass_driver)
        self.assertIn('public boolean charging;', payload_mass_driver)
        self.assertIn('public PayloadDriverState state = idle;', payload_mass_driver)
        self.assertIn('public Queue<Building> waitingShooters = new Queue<>();', payload_mass_driver)
        self.assertIn('idle, accepting, shooting;', payload_mass_driver)
        self.assertIn('public void updateTile(){', payload_mass_driver)
        self.assertIn('super.updateTile();', payload_mass_driver)
        self.assertIn('Building link = world.build(this.link);', payload_mass_driver)
        self.assertIn('boolean hasLink = linkValid();', payload_mass_driver)
        self.assertIn('charge -= Time.delta * 10f;', payload_mass_driver)
        self.assertIn('if(charge < 0) charge = 0f;', payload_mass_driver)
        self.assertIn('curSize = Mathf.lerpDelta(curSize, targetSize, 0.05f);', payload_mass_driver)
        self.assertIn('targetSize = grabWidth*2f;', payload_mass_driver)
        self.assertIn('targetSize = payload.size();', payload_mass_driver)
        self.assertIn('boolean pos = effectDelayTimer > 0;', payload_mass_driver)
        self.assertIn('effectDelayTimer -= Time.delta;', payload_mass_driver)
        self.assertIn('if(effectDelayTimer <= 0 && pos && lastOther != null){', payload_mass_driver)
        self.assertIn('reloadCounter = 1f;', payload_mass_driver)
        self.assertIn('receiveEffect.at(x - cx/2f, y - cy/2f, turretRotation);', payload_mass_driver)
        self.assertIn('Effect.shake(shake, shake, this);', payload_mass_driver)
        self.assertIn('charging = false;', payload_mass_driver)
        self.assertIn('this.link = link.pos();', payload_mass_driver)
        self.assertIn('reloadCounter -= edelta() / reload;', payload_mass_driver)
        self.assertIn('if(reloadCounter < 0) reloadCounter = 0f;', payload_mass_driver)
        self.assertIn('var current = currentShooter();', payload_mass_driver)
        self.assertIn('return waitingShooters.isEmpty() ? null : waitingShooters.first();', payload_mass_driver)
        self.assertIn('current instanceof PayloadDriverBuild entity &&', payload_mass_driver)
        self.assertIn('entity.efficiency > 0 && entity.block == block &&', payload_mass_driver)
        self.assertIn('entity.link == pos() && within(current, range)', payload_mass_driver)
        self.assertIn('waitingShooters.removeFirst();', payload_mass_driver)
        self.assertIn('if(state == idle){', payload_mass_driver)
        self.assertIn('if(!waitingShooters.isEmpty() && payload == null){', payload_mass_driver)
        self.assertIn('state = accepting;', payload_mass_driver)
        self.assertIn('state = shooting;', payload_mass_driver)
        self.assertIn('if((state == idle || state == accepting) && payload != null){', payload_mass_driver)
        self.assertIn('payLength -= payloadSpeed * delta();', payload_mass_driver)
        self.assertIn('if(payLength <= 0f){', payload_mass_driver)
        self.assertIn('loaded = false;', payload_mass_driver)
        self.assertIn('payVector.setZero();', payload_mass_driver)
        self.assertIn('payRotation = Angles.moveToward(payRotation, turretRotation + 180f, payloadRotateSpeed * delta());', payload_mass_driver)
        self.assertIn('moveOutPayload();', payload_mass_driver)
        self.assertIn('if(efficiency <= 0f){', payload_mass_driver)
        self.assertIn('protected boolean linkValid(){', payload_mass_driver)
        self.assertIn('return link != -1 && world.build(this.link) instanceof PayloadDriverBuild other && other.block == block && other.team == team && within(other, range);', payload_mass_driver)
        self.assertIn('public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', payload_mass_driver)
        self.assertIn('public @Nullable T payload;', payload_mass_driver)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_mass_driver)
        self.assertIn('public float payRotation;', payload_mass_driver)
        self.assertIn('public void moveOutPayload(){', payload_mass_driver)
        self.assertIn('Vec2 dest = Tmp.v1.trns(rotdeg(), size * tilesize/2f);', payload_mass_driver)
        self.assertIn('payRotation = Angles.moveToward(payRotation, rotdeg(), payloadRotateSpeed * delta());', payload_mass_driver)
        self.assertIn('payVector.approach(dest, payloadSpeed * delta());', payload_mass_driver)
        self.assertIn('payload.update(null, this);', payload_mass_driver)
        self.assertIn('return build.block.size * tilesize;', payload_mass_driver)
        self.assertIn('config(Point2.class, (PayloadDriverBuild tile, Point2 point) -> tile.link = Point2.pack(point.x + tile.tileX(), point.y + tile.tileY()));', payload_mass_driver)
        self.assertIn('config(Integer.class, (PayloadDriverBuild tile, Integer point) -> tile.link = point);', payload_mass_driver)
        self.assertIn('return Time.delta * timeScale;', payload_mass_driver)
        self.assertIn('return efficiency * delta();', payload_mass_driver)
        self.assertIn('updateConsumption();', payload_mass_driver)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', payload_mass_driver)
        self.assertIn('public boolean noUpdateDisabled = false;', payload_mass_driver)
        self.assertIn('public float rotdeg(){', payload_mass_driver)
        self.assertIn('return rotation * 90;', payload_mass_driver)
        self.assertIn('payloadMassDriver = new PayloadMassDriver("payload-mass-driver"){{', payload_mass_driver)
        self.assertIn('largePayloadMassDriver = new PayloadMassDriver("large-payload-mass-driver"){{', payload_mass_driver)
        self.assertIn('reload = 130f;', payload_mass_driver)
        self.assertIn('chargeTime = 90f;', payload_mass_driver)
        self.assertIn('range = 700f;', payload_mass_driver)
        self.assertIn('maxPayloadSize = 2.5f;', payload_mass_driver)
        self.assertIn('consumePower(0.5f);', payload_mass_driver)
        self.assertIn('range = 2100f;', payload_mass_driver)
        self.assertIn('maxPayloadSize = 4f;', payload_mass_driver)
        self.assertIn('consumePower(3f);', payload_mass_driver)
        # The def/class constants: reload 130f on BOTH defs
        # (Blocks.java:6621/6633, beating the class `public
        # float reload = 30f;`), range 700f / 2100f per def
        # (the driver reads the catalog range with the small
        # -def 700f default), grabWidth 8f class, payloadSpeed
        # 0.7f / payloadRotateSpeed 5f (PayloadBlock.java:18).
        # The initial frame carries the Java build-field
        # defaults (link -1, charge 0, curSize/targetSize 16
        # = grabWidth*2f, effectDelayTimer -1, charging
        # false, reloadCounter 0, empty waitingShooters,
        # state idle, payLength 0, payRotation 0, payVector
        # (0, 0), loaded false, lastOther -1 (null), turret
        # Rotation 90, payload null).
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_GRAB_WIDTH := 8.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED := 0.7', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED := 5.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_RELOAD := 130.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_RANGE := 700.0', payload_mass_driver)
        self.assertIn('"link": -1', payload_mass_driver)
        self.assertIn('"charge": 0.0', payload_mass_driver)
        self.assertIn('"cur_size": 16.0', payload_mass_driver)
        self.assertIn('"target_size": 16.0', payload_mass_driver)
        self.assertIn('"effect_delay_timer": -1.0', payload_mass_driver)
        self.assertIn('"charging": false', payload_mass_driver)
        self.assertIn('"reload_counter": 0.0', payload_mass_driver)
        self.assertIn('"waiting_shooters": []', payload_mass_driver)
        self.assertIn('"state": "idle"', payload_mass_driver)
        self.assertIn('"pay_length": 0.0', payload_mass_driver)
        self.assertIn('"pay_rotation": 0.0', payload_mass_driver)
        self.assertIn('"pay_vector": {"x": 0.0, "y": 0.0}', payload_mass_driver)
        self.assertIn('"loaded": false', payload_mass_driver)
        self.assertIn('"last_other": -1', payload_mass_driver)
        self.assertIn('"turret_rotation": 90.0', payload_mass_driver)
        self.assertIn('"payload": null', payload_mass_driver)
        # The driver wires the advance into the live tick after
        # the consumption fold (the Java order:
        # updateConsumption before updateTile, BuildingComp.java:2274-2277),
        # WITHOUT an enabled guard (PayloadMassDriver has
        # noUpdateDisabled = false, the Block default,
        # Block.java:170 -- the N2231 precedent: Java runs
        # updateTile() even when disabled). The source delta is
        # game_source_delta(game, seconds) and timeScale reads
        # live from the sprite meta. The driver gathers the
        # linked building snapshot (the partner sprite through
        # placed_blocks by the unpacked link cell; same_block
        # is the BLOCK-id match -- the two defs are different
        # blocks, so a payload-mass-driver never links a
        # large-payload-mass-driver) and the per-shooter
        # records for every waiting entry (the inline
        # validity, PayloadMassDriver.java:199-202). The
        # rotdeg comes from the rotation meta (BuildingComp.
        # java:582-584); range / reload / size read the
        # catalog properties with the small-def defaults.
        self.assertIn('game_source_delta(game, seconds)', payload_mass_driver)
        self.assertIn('time_scale(sprite', payload_mass_driver)
        self.assertIn('source_payload_mass_driver_update_tile_advance_state(frame, source_delta, time_scale, reload_value, SOURCE_PAYLOAD_MASS_DRIVER_GRAB_WIDTH, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED, size_value, tile_size, rotdeg_value, this_pos, linked, shooters)', payload_mass_driver)
        self.assertIn('source_angles_move_toward(', payload_mass_driver)
        self.assertIn('source_lerp_delta(', payload_mass_driver)
        self.assertIn('source_vec2_approach(', payload_mass_driver)
        self.assertIn('source_payload_move_out_dest(', payload_mass_driver)
        self.assertIn('frame["link"]', payload_mass_driver)
        self.assertIn('frame["charge"]', payload_mass_driver)
        self.assertIn('frame["cur_size"]', payload_mass_driver)
        self.assertIn('frame["target_size"]', payload_mass_driver)
        self.assertIn('frame["effect_delay_timer"]', payload_mass_driver)
        self.assertIn('frame["charging"]', payload_mass_driver)
        self.assertIn('frame["reload_counter"]', payload_mass_driver)
        self.assertIn('frame["waiting_shooters"]', payload_mass_driver)
        self.assertIn('frame["state"]', payload_mass_driver)
        self.assertIn('frame["pay_length"]', payload_mass_driver)
        self.assertIn('frame["pay_rotation"]', payload_mass_driver)
        self.assertIn('frame["pay_vector"]', payload_mass_driver)
        self.assertIn('frame["loaded"]', payload_mass_driver)
        # The documented limits now record the frame/state
        # advance as live (N2245) and the branches as N2246;
        # the old N2164 "No updateTile advance" text is gone.
        # The N2164 power row is preserved.
        self.assertIn('updateTile advance live (N2245)', payload_mass_driver)
        self.assertNotIn('No updateTile advance', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_power_status_row_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_tick_buildings_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_bind_frame_state', payload_mass_driver)
        # The proof's keys drive the pure advance (the charge
        # discharges 10/tick when idle and clamps at 0, the
        # reload counter decays by edelta / reload regardless
        # of state, idle accepts a waiting shooter, idle
        # shoots with a valid link, the dump unloads a held
        # payload when idle, and at no power the frame/state
        # part still runs while the branches below the
        # :232 return never run) plus the live tick (the
        # driver writes the advance keys onto the frame).
        # Static checks: the proof preloads the family state
        # file that exists, and the scene file references the
        # proof script that exists.
        proof = PAYLOAD_MASS_DRIVER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'charge_discharges_when_idle',
            'reload_counter_decays',
            'state_switches_to_accepting',
            'state_switches_to_shooting',
            'dump_unloads_when_idle',
            'no_power_skips_branches',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadMassDriverBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_MASS_DRIVER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadMassDriverUpdateTileProof.gd', scene)
        self.assertIn('C07PayloadMassDriverUpdateTileProof', scene)

    def test_payload_mass_driver_live_link_uses_java_tilesize_8(self):
        # N2364: the live link world-coord math uses the JAVA
        # tilesize constant 8.0 -- NEVER the game tile_size
        # 32. Java ground truth (read verbatim below):
        # `public static final int tilesize = 8;`
        # (Vars.java:135); `selected.within(x * tilesize, y *
        # tilesize, range)` (PayloadMassDriver.java:111);
        # within is STRICT dst < range
        # (Position.java:44-46, arc). Range is 700f / 2100f
        # large in Java world units (Blocks.java:6623/6635).
        # The game tile_size is 32 (rendering px per tile --
        # it feeds viewport/input, and the N2357 proof asserts
        # game.get("tile_size") == 32.0), so the old driver
        # line `tile_size = game.get("tile_size")` (default
        # 8.0 if unset) made live link distances 4x Java's
        # while the range stayed in Java units: the live link
        # range in tiles was 4x SHORTER than Java's.
        # Boundary numbers (the deviation, verified FIRST):
        # 30 cells apart: Java 30*8 = 240 < 700 in range, old
        # port 30*32 = 960 > 700 out of range. 40 cells: Java
        # 320 < 700 in, old port 1280 > 700 out -- this was
        # the N2357 small pair's separation, which LINKED
        # under Java math after this fix, so N2365 re-seeded
        # the pair to 100 cells: Java 100*8 = 800 > 700 out,
        # old port 100*32 = 3200 > 700 out (the small pair
        # stays idle at the new separation, the large pair
        # stays 40 cells apart: 320 < 2100, still links).
        # 87 cells is the last in-range separation
        # for the small def under Java math (696 < 700); 88
        # cells (704 > 700) stays out of range after the fix.
        # Large def: 262 cells in (2096 < 2100), 263 out
        # (2104 > 2100).
        java_tilesize = 8.0
        game_tile_size = 32.0
        small_range = 700.0
        large_range = 2100.0
        self.assertLess(30 * java_tilesize, small_range)
        self.assertGreater(30 * game_tile_size, small_range)
        self.assertLess(40 * java_tilesize, small_range)
        self.assertGreater(40 * game_tile_size, small_range)
        self.assertGreater(100 * java_tilesize, small_range)
        self.assertGreater(100 * game_tile_size, small_range)
        self.assertLess(87 * java_tilesize, small_range)
        self.assertGreater(88 * java_tilesize, small_range)
        self.assertLess(262 * java_tilesize, large_range)
        self.assertGreater(263 * java_tilesize, large_range)
        vars_lines = (ROOT / 'mindustry-upstream/core/src/mindustry/Vars.java').read_text(encoding='utf-8').splitlines()
        self.assertEqual(vars_lines[134].strip(), 'public static final int tilesize = 8;')
        payload_mass_driver_lines = (ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java').read_text(encoding='utf-8').splitlines()
        self.assertIn('selected.within(x * tilesize, y * tilesize, range)', payload_mass_driver_lines[110])
        position_lines = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Position.java').read_text(encoding='utf-8').splitlines()
        self.assertEqual(position_lines[44].strip(), 'return Mathf.dst2(getX(), getY(), x, y) < dst*dst;')
        # The fix: the driver hard-codes the Java constant
        # and NEVER reads game tile_size for world-coord
        # math. Every consumer of the local was audited: the
        # self / other / shooter coords (the within_range
        # checks + the linked x/y) and the tilesize param
        # passed to the advance pure, whose only use is the
        # move-out dest `size * tilesize / 2f`
        # (PayloadBlock.java:204-207) -- ALL Java world units;
        # none needs the game value. The old "the game
        # tile_size when set" comment is gone.
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        self.assertIn('\t\tvar tile_size: float = 8.0\n', payload_mass_driver)
        self.assertNotIn('game.get("tile_size")', payload_mass_driver)
        self.assertNotIn('tile_size_value', payload_mass_driver)
        self.assertNotIn('the game tile_size when set', payload_mass_driver)
        self.assertIn('the game tile_size 32 is rendering px per tile', payload_mass_driver)
        self.assertIn('float(cell.x) * tile_size', payload_mass_driver)
        self.assertIn('float(other_cell.x) * tile_size', payload_mass_driver)
        self.assertIn('float(shooter_cell.x) * tile_size', payload_mass_driver)
        self.assertIn('size_value * tilesize / 2.0', payload_mass_driver)
        # MassDriver HAD the IDENTICAL pattern
        # (SourceMassDriverBuildState.gd:504-505) -- fixed by
        # N2375 (same fix, separate slice, range 440f): the
        # MassDriver driver now hard-codes 8.0 too, and no
        # MassDriver proof needed a re-seed (the AcceptItem
        # pair is 2 cells apart -- in range under both
        # maths -- and every other live-tick proof ticks
        # unlinked).
        mass_driver = (ROOT / 'godot-mindustry/src/game/SourceMassDriverBuildState.gd').read_text(encoding='utf-8')
        self.assertNotIn('game.get("tile_size")', mass_driver)
        self.assertIn('\t\tvar tile_size: float = 8.0\n', mass_driver)
        # N2357 RE-RUN NOTE (N2365 did the re-seed): the
        # N2357 proof fixture used to encode the pre-fix 32x
        # assumption -- the small pair sat 40 cells apart
        # (1280 world units at game tile_size 32, past the
        # small range 700) and the
        # large_def_range_2100_live_link key asserts both
        # stay idle. After N2364 the same pair was 320 world
        # units apart under Java math -- inside 700 -- so
        # both would switch idle -> shooting and that key
        # would FAIL in Godot. N2365 re-seeded the small
        # pair to 100 cells (800 units: past 700, still
        # inside the large 2100) and the key holds again.
        # The other N2357 keys are unaffected (catalog rows,
        # the pure chargeTime / move-out fixtures already
        # pass 8.0, the accept gate reads offered size, not
        # link state). The N2357 proof still needs a RE-RUN
        # on the Godot side after the re-seed. This pin
        # documents the fixture as-is.
        large_proof = PAYLOAD_MASS_DRIVER_LARGE_VARIANT_PROOF.read_text(encoding='utf-8')
        self.assertIn('100 * 8 = 800 world units', large_proof)
        self.assertIn('Vector2i(28, 26)', large_proof)
        self.assertIn('Vector2i(128, 26)', large_proof)
        self.assertNotIn('Vector2i(68, 26)', large_proof)
        self.assertIn('large_def_range_2100_live_link', large_proof)

    def test_reference_graph_and_actual_c07_payload_mass_driver_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadMassDriverUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_MASS_DRIVER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'charge_discharges_when_idle',
            'reload_counter_decays',
            'state_switches_to_accepting',
            'state_switches_to_shooting',
            'dump_unloads_when_idle',
            'no_power_skips_branches',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
