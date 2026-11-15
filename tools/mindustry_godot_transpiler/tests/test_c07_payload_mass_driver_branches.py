import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadMassDriverBuildState.gd'
PAYLOAD_MASS_DRIVER_BRANCHES_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverBranchesProof.gd'
PAYLOAD_MASS_DRIVER_BRANCHES_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverBranchesProof.tscn'


class C07PayloadMassDriverBranchesTests(unittest.TestCase):
    def test_c07_payload_mass_driver_branches_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2246']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_state_branches_state')
        # N2164 proved the PayloadMassDriver live power read and
        # N2245 the updateTile frame/state advance (link refresh,
        # charge discharge, curSize lerp, effectDelayTimer,
        # reload decay, shooter cleanup, the idle -> accepting /
        # shooting switch, the idle/accepting dump, the no-power
        # return) -- but the port tracked no accepting / shooting
        # branch behavior at all, so a payload-mass-driver never
        # aligned to a shooter, never loaded a payload toward
        # the muzzle, never charged, and never transferred a
        # payload to its link: the state machine switched states
        # and then did nothing with them. N2246 is the state
        # branches (PayloadDriverBuild.updateTile(),
        # PayloadMassDriver.java:232-342): the no-power return
        # (:232-234), the accepting bail + targetSize + align
        # (:236-248), the shooting bail + payRotation +
        # loadLength advance + moveInPayload intake (:249-270),
        # the fire gate -- enqueue, reload, first-in-queue,
        # partner accepting, both angles within 1f (:272-294) --
        # and the charge + transfer (:295-342, the payload
        # leaves the self frame the moment it fires, the
        # partner takes payVector / payRotation / payLength /
        # loaded / effectDelayTimer / lastOther and goes idle).
        # The partner driver state is an explicit dict input
        # (the N2237 MassDriver precedent); Angles.within is
        # <= (Arc Angles.java:19-21), NOT the strict < of
        # Angles.near -- the port has source_angles_within, so
        # no local helper is needed. Twenty-one new result
        # symbols: the advanced self values, the partner
        # write-back, and the fired flag.
        self.assertEqual(
            ledger['N2246']['source_symbols'],
            [
                'source_payload_mass_driver_state_branches_state_result.state',
                'source_payload_mass_driver_state_branches_state_result.target_size',
                'source_payload_mass_driver_state_branches_state_result.turret_rotation',
                'source_payload_mass_driver_state_branches_state_result.pay_rotation',
                'source_payload_mass_driver_state_branches_state_result.pay_length',
                'source_payload_mass_driver_state_branches_state_result.loaded',
                'source_payload_mass_driver_state_branches_state_result.pay_vector',
                'source_payload_mass_driver_state_branches_state_result.payload',
                'source_payload_mass_driver_state_branches_state_result.charge',
                'source_payload_mass_driver_state_branches_state_result.charging',
                'source_payload_mass_driver_state_branches_state_result.reload_counter',
                'source_payload_mass_driver_state_branches_state_result.partner_waiting_shooters',
                'source_payload_mass_driver_state_branches_state_result.partner_state',
                'source_payload_mass_driver_state_branches_state_result.partner_effect_delay_timer',
                'source_payload_mass_driver_state_branches_state_result.partner_pay_vector',
                'source_payload_mass_driver_state_branches_state_result.partner_pay_rotation',
                'source_payload_mass_driver_state_branches_state_result.partner_pay_length',
                'source_payload_mass_driver_state_branches_state_result.partner_loaded',
                'source_payload_mass_driver_state_branches_state_result.partner_payload',
                'source_payload_mass_driver_state_branches_state_result.partner_last_other',
                'source_payload_mass_driver_state_branches_state_result.fired',
            ],
        )
        for name in ledger['N2246']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], {
                    'source_payload_mass_driver_state_branches_state_result.pay_vector': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'source_payload_mass_driver_state_branches_state_result.partner_payload': 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                }.get(name, 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_state_branches_state')
        self.assertEqual(ledger['N2246']['runtime_proof'], '/root/C07PayloadMassDriverBranchesProof')
        self.assertEqual(
            ledger['N2246']['tests'],
            [
                'test_c07_payload_mass_driver_branches_registration',
                'test_all_c07_payload_mass_driver_branches_input_evidence_is_exact',
                'test_payload_mass_driver_state_branches_state',
                'test_reference_graph_and_actual_c07_payload_mass_driver_branches',
            ],
        )
        self.assertTrue(ledger['N2246']['deferred_exprs'])
        # This slice resolves the updateTile advance entry: N2245
        # did the frame/state half and N2246 the branches, so the
        # advance as a whole is done. Two new deferrals record
        # what this slice leaves behind (the transfer effects /
        # sound / shake, and the live updatePayload positioning
        # -- the port payload dict carries no position).
        self.assertFalse(any(entry.startswith('PayloadMassDriver updateTile advance (') for entry in ledger['N2246']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver transfer effects / sound / shake rows (') for entry in ledger['N2246']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver updatePayload live positioning rows (') for entry in ledger['N2246']['deferred_exprs']))

    def test_all_c07_payload_mass_driver_branches_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2246']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_state_branches_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2246']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_mass_driver_state_branches_state(self):
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The pure branches live on the payload-mass-driver build
        # state: the no-power return (PayloadMassDriver.java:
        # 232-234), the accepting branch (:236-248), the shooting
        # branch (:249-270), the fire gate (:272-294), and the
        # charge + transfer (:295-342). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). delta() is `return Time.delta
        # * timeScale;` (BuildingComp.java:1922-1924) and
        # edelta() is `return efficiency * delta();`
        # (BuildingComp.java:1927-1929); source_delta is
        # Time.delta in ticks (seconds * 60 through
        # game_source_delta, arc Time.java:26), never raw
        # seconds. rotdeg() is `return rotation * 90;`
        # (BuildingComp.java:582-584). Angles.within is <=
        # (Arc Angles.java:19-21, `return angleDist(a, b) <=
        # margin;`), unlike Angles.near (STRICT <, Arc
        # Angles.java:29-31, `return angleDist(a, b) < range;`).
        # hasArrived is `return payVector.isZero(0.01f);`
        # (PayloadBlock.java:242-244) and isZero(margin) is
        # `return len2() < margin;` (Arc Vec2.java:679-681) --
        # the SQUARED length against the bare margin, not the
        # margin squared (the N2233 deconstructor precedent).
        self.assertIn('static func source_payload_mass_driver_state_branches_state', payload_mass_driver)
        self.assertIn('public class PayloadMassDriver extends PayloadBlock{', payload_mass_driver)
        self.assertIn('public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{', payload_mass_driver)
        self.assertIn('public float range = 100f;', payload_mass_driver)
        self.assertIn('public float rotateSpeed = 5f;', payload_mass_driver)
        self.assertIn('public float length = 89 / 8f;', payload_mass_driver)
        self.assertIn('public float knockback = 5f;', payload_mass_driver)
        self.assertIn('public float reload = 30f;', payload_mass_driver)
        self.assertIn('public float chargeTime = 100f;', payload_mass_driver)
        self.assertIn('public float maxPayloadSize = 3;', payload_mass_driver)
        self.assertIn('public float grabWidth = 8f, grabHeight = 11/4f;', payload_mass_driver)
        self.assertIn('public Effect transferEffect = new Effect(11f, 600f, e -> {', payload_mass_driver)
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
        self.assertIn('public Payload recPayload;', payload_mass_driver)
        self.assertIn('return waitingShooters.isEmpty() ? null : waitingShooters.first();', payload_mass_driver)
        self.assertIn('idle, accepting, shooting;', payload_mass_driver)
        self.assertIn('public void updateTile(){', payload_mass_driver)
        self.assertIn('if(efficiency <= 0f){', payload_mass_driver)
        self.assertIn('if(state == accepting){', payload_mass_driver)
        self.assertIn('if(currentShooter() == null || payload != null){', payload_mass_driver)
        self.assertIn('state = idle;', payload_mass_driver)
        self.assertIn('if(currentShooter().getPayload() != null){', payload_mass_driver)
        self.assertIn('targetSize = recPayload == null ? currentShooter().getPayload().size() : recPayload.size();', payload_mass_driver)
        self.assertIn('turretRotation = Angles.moveToward(turretRotation, angleTo(currentShooter()), rotateSpeed * efficiency);', payload_mass_driver)
        self.assertIn('}else if(state == shooting){', payload_mass_driver)
        self.assertIn('if(!hasLink || (!waitingShooters.isEmpty() && payload == null)){', payload_mass_driver)
        self.assertIn('float targetRotation = angleTo(link);', payload_mass_driver)
        self.assertIn('payRotation = Angles.moveToward(payRotation, turretRotation, payloadRotateSpeed * delta());', payload_mass_driver)
        self.assertIn('float loadLength = length - reloadCounter *knockback;', payload_mass_driver)
        self.assertIn('payLength += payloadSpeed * delta();', payload_mass_driver)
        self.assertIn('if(payLength >= loadLength){', payload_mass_driver)
        self.assertIn('payLength = loadLength;', payload_mass_driver)
        self.assertIn('}else if(moveInPayload()){', payload_mass_driver)
        self.assertIn('payLength = 0f;', payload_mass_driver)
        self.assertIn('loaded = true;', payload_mass_driver)
        self.assertIn('if(movedOut && payload != null && link.getPayload() == null){', payload_mass_driver)
        self.assertIn('var other = (PayloadDriverBuild)link;', payload_mass_driver)
        self.assertIn('if(!other.waitingShooters.contains(this)){', payload_mass_driver)
        self.assertIn('other.waitingShooters.addLast(this);', payload_mass_driver)
        self.assertIn('if(reloadCounter <= 0){', payload_mass_driver)
        self.assertIn('turretRotation = Angles.moveToward(turretRotation, targetRotation, rotateSpeed * efficiency);', payload_mass_driver)
        self.assertIn('if(other.currentShooter() == this &&', payload_mass_driver)
        self.assertIn('other.state == accepting &&', payload_mass_driver)
        self.assertIn('other.reloadCounter <= 0f &&', payload_mass_driver)
        self.assertIn('Angles.within(turretRotation, targetRotation, 1f) && Angles.within(other.turretRotation, targetRotation + 180f, 1f)){', payload_mass_driver)
        self.assertIn('charge += edelta();', payload_mass_driver)
        self.assertIn('charging = true;', payload_mass_driver)
        self.assertIn('if(charge >= chargeTime){', payload_mass_driver)
        self.assertIn('float cx = Angles.trnsx(turretRotation, length), cy = Angles.trnsy(turretRotation, length);', payload_mass_driver)
        self.assertIn('other.recPayload = payload;', payload_mass_driver)
        self.assertIn('other.effectDelayTimer = transferEffect.lifetime;', payload_mass_driver)
        self.assertIn('other.handlePayload(this, pay);', payload_mass_driver)
        self.assertIn('other.lastOther = this;', payload_mass_driver)
        self.assertIn('other.payVector.set(-cx, -cy);', payload_mass_driver)
        self.assertIn('other.payRotation = turretRotation;', payload_mass_driver)
        self.assertIn('other.payLength = length;', payload_mass_driver)
        self.assertIn('other.loaded = true;', payload_mass_driver)
        self.assertIn('other.updatePayload();', payload_mass_driver)
        self.assertIn('other.recPayload = null;', payload_mass_driver)
        self.assertIn('if(other.waitingShooters.size != 0 && other.waitingShooters.first() == this){', payload_mass_driver)
        self.assertIn('other.waitingShooters.removeFirst();', payload_mass_driver)
        self.assertIn('other.state = idle;', payload_mass_driver)
        self.assertIn('payload = null;', payload_mass_driver)
        self.assertIn('loaded = false;', payload_mass_driver)
        self.assertIn('reloadCounter = 1f;', payload_mass_driver)
        self.assertIn('protected boolean linkValid(){', payload_mass_driver)
        self.assertIn('return link != -1 && world.build(this.link) instanceof PayloadDriverBuild other && other.block == block && other.team == team && within(other, range);', payload_mass_driver)
        self.assertIn('public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', payload_mass_driver)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_mass_driver)
        self.assertIn('public float payRotation;', payload_mass_driver)
        self.assertIn('public @Nullable T payload;', payload_mass_driver)
        self.assertIn('public boolean moveInPayload(){', payload_mass_driver)
        self.assertIn('public boolean moveInPayload(boolean rotate){', payload_mass_driver)
        self.assertIn('if(payload == null) return false;', payload_mass_driver)
        self.assertIn('payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());', payload_mass_driver)
        self.assertIn('payVector.approach(Vec2.ZERO, payloadSpeed * delta());', payload_mass_driver)
        self.assertIn('return hasArrived();', payload_mass_driver)
        self.assertIn('return payVector.isZero(0.01f);', payload_mass_driver)
        self.assertIn('this.payload = (T)payload;', payload_mass_driver)
        self.assertIn('this.payRotation = payload.rotation();', payload_mass_driver)
        self.assertIn('return build.block.size * tilesize;', payload_mass_driver)
        self.assertIn('return Time.delta * timeScale;', payload_mass_driver)
        self.assertIn('return efficiency * delta();', payload_mass_driver)
        self.assertIn('return rotation * 90;', payload_mass_driver)
        self.assertIn('updateConsumption();', payload_mass_driver)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', payload_mass_driver)
        self.assertIn('transient float efficiency;', payload_mass_driver)
        self.assertIn('public boolean noUpdateDisabled = false;', payload_mass_driver)
        self.assertIn('return angleDist(a, b) <= margin;', payload_mass_driver)
        self.assertIn('return angleDist(a, b) < range;', payload_mass_driver)
        self.assertIn('return len2() < margin;', payload_mass_driver)
        self.assertIn('payloadMassDriver = new PayloadMassDriver("payload-mass-driver"){{', payload_mass_driver)
        self.assertIn('largePayloadMassDriver = new PayloadMassDriver("large-payload-mass-driver"){{', payload_mass_driver)
        self.assertIn('reload = 130f;', payload_mass_driver)
        self.assertIn('chargeTime = 90f;', payload_mass_driver)
        self.assertIn('chargeTime = 100f;', payload_mass_driver)
        self.assertIn('range = 700f;', payload_mass_driver)
        self.assertIn('range = 2100f;', payload_mass_driver)
        self.assertIn('maxPayloadSize = 2.5f;', payload_mass_driver)
        self.assertIn('maxPayloadSize = 4f;', payload_mass_driver)
        self.assertIn('consumePower(0.5f);', payload_mass_driver)
        self.assertIn('consumePower(3f);', payload_mass_driver)
        # The def/class constants: rotateSpeed 5f, length 89/8f
        # (11.125), knockback 5f, payloadSpeed 0.7f,
        # payloadRotateSpeed 5f, transferEffect lifetime 11f,
        # chargeTime 90f / 100f (large), range 700f / 2100f
        # (large). The initial frame carries the Java build-field
        # defaults the branches read (link -1, turretRotation 90,
        # reloadCounter 0, charge 0, targetSize grabWidth*2f =
        # 16, payLength 0, loaded / charging false, state idle,
        # empty waitingShooters, recPayload / payload null,
        # payVector ZERO, payRotation 0). N2245 owns cur_size /
        # effect_delay_timer / last_other; the coordinator unions
        # the two _initial_frame dicts at integration.
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_ROTATE_SPEED := 5.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_LENGTH := 11.125', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_KNOCKBACK := 5.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED := 0.7', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED := 5.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_TRANSFER_EFFECT_LIFETIME := 11.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME := 90.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_CHARGE_TIME_LARGE := 100.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_RANGE := 700.0', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_RANGE_LARGE := 2100.0', payload_mass_driver)
        self.assertIn('"link": -1', payload_mass_driver)
        self.assertIn('"turret_rotation": 90.0', payload_mass_driver)
        self.assertIn('"reload_counter": 0.0', payload_mass_driver)
        self.assertIn('"charge": 0.0', payload_mass_driver)
        self.assertIn('"target_size": 16.0', payload_mass_driver)
        self.assertIn('"pay_length": 0.0', payload_mass_driver)
        self.assertIn('"loaded": false', payload_mass_driver)
        self.assertIn('"charging": false', payload_mass_driver)
        self.assertIn('"state": "idle"', payload_mass_driver)
        self.assertIn('"waiting_shooters": []', payload_mass_driver)
        self.assertIn('"rec_payload": null', payload_mass_driver)
        self.assertIn('"payload": null', payload_mass_driver)
        self.assertIn('"pay_vector": Vector2.ZERO', payload_mass_driver)
        self.assertIn('"pay_rotation": 0.0', payload_mass_driver)
        # The driver wires the branches into the live tick after
        # the consumption fold (the Java order:
        # updateConsumption before updateTile, BuildingComp.java:2274-2277),
        # AFTER the N2245 frame/state wiring position (the
        # coordinator places N2245 between the fold and the
        # branches at integration) and WITHOUT an enabled guard
        # (PayloadMassDriver has noUpdateDisabled = false, the
        # Block default, Block.java:170 -- the N2231 precedent:
        # Java runs updateTile() even when disabled). The source
        # delta is game_source_delta(game, seconds) and timeScale
        # reads live from the sprite meta. The rotation reuses
        # the shared angle helpers (source_angles_move_toward /
        # source_angles_angle / source_angles_within /
        # source_angles_trns_vec), the moveInPayload approach
        # reuses the N2233 Vec2.approach port, and the driver
        # writes back BOTH frames (the N2237 precedent): the self
        # branch keys and the partner transfer keys.
        self.assertIn('game_source_delta(game, seconds)', payload_mass_driver)
        self.assertIn('time_scale(sprite', payload_mass_driver)
        self.assertIn('source_payload_mass_driver_state_branches_state(frame, source_delta, time_scale, charge_time, SOURCE_PAYLOAD_MASS_DRIVER_LENGTH, SOURCE_PAYLOAD_MASS_DRIVER_KNOCKBACK, SOURCE_PAYLOAD_MASS_DRIVER_ROTATE_SPEED, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_SPEED, SOURCE_PAYLOAD_MASS_DRIVER_PAYLOAD_ROTATE_SPEED, rot_deg, this_pos, self_x, self_y, linked, shooters)', payload_mass_driver)
        self.assertIn('source_angles_move_toward(', payload_mass_driver)
        self.assertIn('source_angles_angle(', payload_mass_driver)
        self.assertIn('source_angles_within(', payload_mass_driver)
        self.assertIn('source_angles_trns_vec(', payload_mass_driver)
        self.assertIn('frame["state"]', payload_mass_driver)
        self.assertIn('frame["target_size"]', payload_mass_driver)
        self.assertIn('frame["turret_rotation"]', payload_mass_driver)
        self.assertIn('frame["pay_rotation"]', payload_mass_driver)
        self.assertIn('frame["pay_length"]', payload_mass_driver)
        self.assertIn('frame["loaded"]', payload_mass_driver)
        self.assertIn('frame["pay_vector"]', payload_mass_driver)
        self.assertIn('frame["payload"]', payload_mass_driver)
        self.assertIn('frame["charge"]', payload_mass_driver)
        self.assertIn('frame["charging"]', payload_mass_driver)
        self.assertIn('frame["reload_counter"]', payload_mass_driver)
        self.assertIn('partner_frame["waiting_shooters"]', payload_mass_driver)
        self.assertIn('partner_frame["state"]', payload_mass_driver)
        self.assertIn('partner_frame["effect_delay_timer"]', payload_mass_driver)
        self.assertIn('partner_frame["pay_vector"]', payload_mass_driver)
        self.assertIn('partner_frame["pay_rotation"]', payload_mass_driver)
        self.assertIn('partner_frame["pay_length"]', payload_mass_driver)
        self.assertIn('partner_frame["loaded"]', payload_mass_driver)
        self.assertIn('partner_frame["payload"]', payload_mass_driver)
        self.assertIn('partner_frame["last_other"]', payload_mass_driver)
        # The documented limits now record the branches as live
        # and the N2245 frame/state half as the integration
        # neighbour; the old N2164 "No updateTile advance" text
        # is gone. The N2164 power row is preserved.
        self.assertIn('State branches live (N2246)', payload_mass_driver)
        self.assertNotIn('No updateTile advance', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_power_status_row_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_tick_buildings_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_bind_frame_state', payload_mass_driver)
        # The proof's keys drive the pure branches (accepting
        # bails without a shooter, accepting aligns to the
        # shooter, shooting bails without a link, the load
        # advances to loadLength, the fire gate needs the queue
        # and both angles, the transfer resets both sides) plus
        # the live tick (a placed shooting driver with no link
        # bails to idle, folded into the shooting-bails key).
        # Static checks: the proof preloads the family state file
        # that exists, and the scene file references the proof
        # script that exists.
        proof = PAYLOAD_MASS_DRIVER_BRANCHES_PROOF.read_text(encoding='utf-8')
        for key in [
            'accepting_bails_without_shooter',
            'accepting_aligns_to_shooter',
            'shooting_bails_without_link',
            'load_advances_to_length',
            'fire_gate_requires_queue_and_angles',
            'transfer_resets_both_sides',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadMassDriverBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_MASS_DRIVER_BRANCHES_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadMassDriverBranchesProof.gd', scene)
        self.assertIn('C07PayloadMassDriverBranchesProof', scene)

    def test_reference_graph_and_actual_c07_payload_mass_driver_branches(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadMassDriverBranchesProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_MASS_DRIVER_BRANCHES_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accepting_bails_without_shooter',
            'accepting_aligns_to_shooter',
            'shooting_bails_without_link',
            'load_advances_to_length',
            'fire_gate_requires_queue_and_angles',
            'transfer_resets_both_sides',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
