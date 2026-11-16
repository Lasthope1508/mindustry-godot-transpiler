import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_SHOULD_AMBIENT_SOUND_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretShouldAmbientSoundStatusProof.gd'


class C07RepairTurretShouldAmbientSoundStatusTests(unittest.TestCase):
    def test_c07_repair_turret_should_ambient_sound_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2221']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_should_ambient_sound_state')
        # N2212-N2215 made the repair turret live (target acquire,
        # heal advance, rotation slerp, strength lerp), N2217
        # persisted its rotation, N2219 captured the beam state and
        # N2220 the dash-circle state -- but nothing in the port
        # captured when the turret plays its ambient sound or what
        # status it reports: RepairPointBuild.shouldAmbientSound()
        # returns `target != null && efficiency > 0f`
        # (RepairTurret.java:182, inside `public boolean
        # shouldAmbientSound(){`, RepairTurret.java:181) and
        # RepairPointBuild.status() returns `Mathf.equal
        # (potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput
        # : super.status()` (RepairTurret.java:226, inside
        # `public BlockStatus status(){`,
        # RepairTurret.java:225). RED decisions (resolved at RED,
        # recorded in the register docstring): (1) Two pure
        # functions on the same family file N2174 / N2188 / N2209 /
        # N2212-N2215 / N2217 / N2219 / N2220 built, returning the
        # ambient gate (bool) and the status (String). (2) The
        # ambient gate reads the live target observation as
        # `has_target` (stamped every tick by the N2212 acquire)
        # and the folded `efficiency` (stamped every tick by the
        # driver via apply_update_consumption_state); absent
        # has_target means "no observation yet", so it reads
        # false, and absent efficiency folds to 1.0 (the N2174
        # missing-stamp precedent). (3) The status gate reads
        # `potential_efficiency` (stamped every tick by the
        # driver via apply_update_consumption_state);
        # Mathf.equal(potentialEfficiency, 0f, 0.01f) is
        # `Math.abs(a - b) <= tolerance`
        # (Mathf.java:554-556), so the gate is
        # `absf(potential_efficiency) <= 0.01`; absent
        # potential_efficiency reads 0.0 -- the Java transient
        # field default (BuildingComp.java:89, `transient float
        # potentialEfficiency;`) -- so an unticked frame reports
        # noInput, exactly like Java before the first
        # updateConsumption. (4) super.status() is
        # BuildingComp.status() (BuildingComp.java:632-646):
        # disabled -> logicDisable, shouldConsume false ->
        # noOutput, efficiency <= 0 or productionValid false ->
        # noInput, else the tick flicker `((state.tick / 30f) %
        # 1f) < efficiency ? active : noInput`; the shouldConsume
        # leg reuses source_repair_turret_should_consume_state
        # (N2188) and productionValid is the canonical true
        # default (SourceBuildingAccessState
        # .production_valid_state()); the tick arrives as an
        # explicit float param, not from the frame (the driver
        # stamps no tick key). Status strings are the
        # SourceBuildingAccessState constants ("logicDisable" /
        # "noOutput" / "noInput" / "active"). (5) There is NO
        # driver tick line: status() / shouldAmbientSound() are
        # read functions (UI + the ambient-sound gate
        # BuildingComp.update() calls), not per-tick -- the
        # live-loop ambient-sound gate call waits for its own
        # slice. Two new result symbols: ambient should_ambient
        # _sound, status status.
        self.assertEqual(
            ledger['N2221']['source_symbols'],
            [
                'source_repair_turret_should_ambient_sound_state_result.should_ambient_sound',
                'source_repair_turret_status_state_result.status',
            ],
        )
        for name in ledger['N2221']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2221']['runtime_proof'], '/root/C07RepairTurretShouldAmbientSoundStatusProof')
        self.assertEqual(
            ledger['N2221']['tests'],
            [
                'test_c07_repair_turret_should_ambient_sound_status_registration',
                'test_all_c07_repair_turret_should_ambient_sound_status_input_evidence_is_exact',
                'test_repair_turret_should_ambient_sound_status_state',
                'test_reference_graph_and_actual_c07_repair_turret_should_ambient_sound_status',
            ],
        )
        self.assertTrue(ledger['N2221']['deferred_exprs'])

    def test_all_c07_repair_turret_should_ambient_sound_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2221']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2221']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_should_ambient_sound_status_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairPointBuild.shouldAmbientSound() returns `target !=
        # null && efficiency > 0f` (RepairTurret.java:182, inside
        # `public boolean shouldAmbientSound(){`,
        # RepairTurret.java:181) and RepairPointBuild.status()
        # returns `Mathf.equal(potentialEfficiency, 0f, 0.01f) ?
        # BlockStatus.noInput : super.status()`
        # (RepairTurret.java:226, inside `public BlockStatus
        # status(){`, RepairTurret.java:225). super.status() is
        # BuildingComp.status() (BuildingComp.java:632-646):
        # disabled -> logicDisable, shouldConsume false ->
        # noOutput, efficiency <= 0 or productionValid false ->
        # noInput, else the tick flicker `((state.tick / 30f) %
        # 1f) < efficiency ? active : noInput`. The status gate
        # reads potential_efficiency (absent 0.0, the Java
        # transient field default); the ambient gate reads
        # has_target (absent false) and efficiency (absent 1.0).
        # There is no driver tick line: status() /
        # shouldAmbientSound() are read functions, not per-tick.
        self.assertIn('static func source_repair_turret_should_ambient_sound_state(frame: Dictionary) -> Dictionary:', repair_turret)
        self.assertIn('return {"should_ambient_sound": has_target and efficiency > 0.0}', repair_turret)
        self.assertIn('static func source_repair_turret_status_state(frame: Dictionary, tick: float) -> Dictionary:', repair_turret)
        self.assertIn('if absf(potential_efficiency) <= 0.01:', repair_turret)
        self.assertIn('return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_INPUT}', repair_turret)
        self.assertIn('return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_LOGIC_DISABLE}', repair_turret)
        self.assertIn('return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_OUTPUT}', repair_turret)
        self.assertIn('return {"status": source_building_access_state.SOURCE_BUILDING_STATUS_ACTIVE}', repair_turret)
        self.assertIn('if fmod(tick / 30.0, 1.0) < efficiency:', repair_turret)
        for expr in [
            'public boolean shouldAmbientSound(){',
            'return target != null && efficiency > 0f;',
            'public BlockStatus status(){',
            'return Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();',
            'if(!enabled){',
            'return BlockStatus.logicDisable;',
            'if(!shouldConsume()){',
            'return BlockStatus.noOutput;',
            'if(efficiency <= 0 || !productionValid()){',
            'return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;',
            'transient float potentialEfficiency;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure functions with
        # synthetic frames (no live tick: status() /
        # shouldAmbientSound() are read functions, not per-tick;
        # the tick arrives as an explicit param): ambient true
        # with target + efficiency / ambient false with no target
        # / ambient false with zero efficiency / status noInput
        # with zero potential / status noInput with near-zero
        # potential (within the 0.01 tolerance) / status
        # logicDisable when disabled / status noOutput when
        # shouldConsume is false / status active with full
        # potential, a target and tick 0.
        proof = REPAIR_TURRET_SHOULD_AMBIENT_SOUND_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'ambient_true_target_and_efficiency',
            'ambient_false_no_target',
            'ambient_false_zero_efficiency',
            'status_no_input_zero_potential',
            'status_no_input_near_zero_potential',
            'status_logic_disable',
            'status_no_output_no_consume',
            'status_active',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_should_ambient_sound_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretShouldAmbientSoundStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_SHOULD_AMBIENT_SOUND_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ambient_true_target_and_efficiency',
            'ambient_false_no_target',
            'ambient_false_zero_efficiency',
            'status_no_input_zero_potential',
            'status_no_input_near_zero_potential',
            'status_logic_disable',
            'status_no_output_no_consume',
            'status_active',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
