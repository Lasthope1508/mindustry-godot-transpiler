import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadMassDriverBuildState.gd'
PAYLOAD_MASS_DRIVER_SUPER_UPDATE_TILE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverSuperUpdateTileRowsProof.gd'
PAYLOAD_MASS_DRIVER_SUPER_UPDATE_TILE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverSuperUpdateTileRowsProof.tscn'


class C07PayloadMassDriverSuperUpdateTileRowsTests(unittest.TestCase):
    def test_c07_payload_mass_driver_super_update_tile_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2488']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_payload_update_state')
        # PayloadDriverBuild.updateTile() calls
        # super.updateTile() (PayloadMassDriver.java:156),
        # which is PayloadBlockBuild.updateTile()
        # (PayloadBlock.java:158-162): if the payload
        # is non-null, payload.update(null, this).
        # Payload.update is a default no-op
        # (Payload.java:42) and both overrides are
        # ENTITY behaviour (a live inner building /
        # unit) the port cannot model -- there is no
        # live payload entity -- so the N2245 advance
        # notes the call and advances only the driver
        # frame. N2488 ports it as a pure-only CALL
        # record (the N2471 Loader precedent, the
        # N2396 record-the-call precedent): one pure,
        # one result symbol -- the call {method,
        # unit_holder null, building_holder self,
        # payload_kind} when the payload is non-null,
        # null otherwise. No tick wiring: the N2245
        # advance still skips the call.
        self.assertEqual(
            ledger['N2488']['source_symbols'],
            [
                'source_payload_mass_driver_payload_update_state_result.payload_update_call',
            ],
        )
        for name in ledger['N2488']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_payload_update_state')
        self.assertEqual(ledger['N2488']['runtime_proof'], '/root/C07PayloadMassDriverSuperUpdateTileRowsProof')
        self.assertEqual(
            ledger['N2488']['tests'],
            [
                'test_c07_payload_mass_driver_super_update_tile_rows_registration',
                'test_all_c07_payload_mass_driver_super_update_tile_rows_input_evidence_is_exact',
                'test_payload_mass_driver_super_update_tile_rows_state',
                'test_reference_graph_and_actual_c07_payload_mass_driver_super_update_tile_rows',
            ],
        )
        self.assertTrue(ledger['N2488']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #131 (1-based
        # in the merged advances-33 DEFERRED base):
        # the GENERIC PayloadBlock super.updateTile
        # payload update entry is REMOVED -- the call
        # is live now as a CALL record on the PMD
        # call site (PayloadMassDriver.java:156).
        # N2471 deliberately left this entry alone
        # (it resolved only the Loader entry #104);
        # N2488 resolves it. Net 231 - 1 = 230.
        # The neighbouring PMD entries stay: #130
        # (moveOutPayload world interaction) and
        # #132 (updatePayload live positioning).
        self.assertFalse(any(entry.startswith('PayloadBlock super.updateTile payload update (') for entry in ledger['N2488']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver moveOutPayload world interaction (') for entry in ledger['N2488']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver updatePayload live positioning rows (') for entry in ledger['N2488']['deferred_exprs']))
        self.assertEqual(len(ledger['N2488']['deferred_exprs']), 230)

    def test_all_c07_payload_mass_driver_super_update_tile_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2488']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_payload_update_state')
        slice_sources = [
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/blocks/payloads/UnitPayload.java',
        ]
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2488']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_mass_driver_super_update_tile_rows_state(self):
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The super.updateTile payload update
        # (PayloadBlockBuild.updateTile(),
        # PayloadBlock.java:158-162): `if(payload !=
        # null){` then `payload.update(null, this);`
        # -- called from PayloadDriverBuild.
        # updateTile() via `super.updateTile();`
        # (PayloadMassDriver.java:156). Payload is an
        # interface (`public interface Payload
        # extends Position{`, Payload.java:15) whose
        # update is a default no-op (`default void
        # update(@Nullable Unit unitHolder,
        # @Nullable Building buildingHolder){}`,
        # Payload.java:42); the only two
        # implementations are BuildPayload
        # (BuildPayload.java:16) and UnitPayload
        # (UnitPayload.java:22). BuildPayload.update
        # (:52-57) gates on unitHolder non-null
        # (`if(unitHolder != null && ...)`), so with
        # the PMD's null holder the gate
        # short-circuits and the call ALWAYS runs
        # for a non-null payload; UnitPayload.update
        # (:51-53) delegates to the unit type. Both
        # overrides are ENTITY behaviour the port
        # cannot model, so the slice is a CALL
        # record (the N2471 Loader precedent, the
        # N2396 record-the-call precedent): the pure
        # returns the call as data, never the
        # callee's behaviour. Verify-first: the PMD
        # generic is PayloadBlockBuild<Payload>
        # (PayloadMassDriver.java:132), NOT
        # BuildPayload -- BOTH kinds are genuinely
        # possible in Java (acceptPayload has no
        # instanceof check, only the size gate),
        # so the "BuildPayload" default for a
        # kind-less dict is the N2471 port
        # convention, not a Java-exact generic
        # default; the PMD payload contract carries
        # no kind key (it carries "size" in world
        # units, the N2245 advance). Pure-only: the
        # tick never calls this pure.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_payload_mass_driver_payload_update_state', payload_mass_driver)
        self.assertIn('public void updateTile(){', payload_mass_driver)
        self.assertIn('if(payload != null){', payload_mass_driver)
        self.assertIn('payload.update(null, this);', payload_mass_driver)
        self.assertIn('public class PayloadBlockBuild<T extends Payload> extends Building{', payload_mass_driver)
        self.assertIn('public @Nullable T payload;', payload_mass_driver)
        self.assertIn('public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{', payload_mass_driver)
        self.assertIn('super.updateTile();', payload_mass_driver)
        self.assertIn('public interface Payload extends Position{', payload_mass_driver)
        self.assertIn('int payloadUnit = 0, payloadBlock = 1;', payload_mass_driver)
        self.assertIn('default void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){}', payload_mass_driver)
        self.assertIn('if(type == payloadBlock){', payload_mass_driver)
        self.assertIn('}else if(type == payloadUnit){', payload_mass_driver)
        self.assertIn('public class BuildPayload implements Payload{', payload_mass_driver)
        self.assertIn('public void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){', payload_mass_driver)
        self.assertIn('if(unitHolder != null && (!build.block.updateInUnits || (!state.rules.unitPayloadUpdate && !build.block.alwaysUpdateInUnits))) return;', payload_mass_driver)
        self.assertIn('build.tile = emptyTile;', payload_mass_driver)
        self.assertIn('build.updatePayload(unitHolder, buildingHolder);', payload_mass_driver)
        self.assertIn('write.b(payloadBlock);', payload_mass_driver)
        self.assertIn('public class UnitPayload implements Payload{', payload_mass_driver)
        self.assertIn('unit.type.updatePayload(unit, unitHolder, buildingHolder);', payload_mass_driver)
        self.assertIn('write.b(payloadUnit);', payload_mass_driver)
        # The documented limits record the
        # super.updateTile payload update as live.
        self.assertIn('super.updateTile payload update live (N2488)', payload_mass_driver)
        # The proof's keys drive the pure (the
        # build call + the unit call, the null
        # payload, the kind default + explicit
        # kinds, the holders, and the live PMD
        # payload-contract input).
        proof = PAYLOAD_MASS_DRIVER_SUPER_UPDATE_TILE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'update_call_build',
            'update_call_unit',
            'update_null',
            'update_kind',
            'update_holders',
            'update_live_input',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file
        # (the N2185 lesson: check the preload
        # target exists, and the scene file exists
        # and points at the proof script).
        self.assertIn('preload("res://src/game/SourcePayloadMassDriverBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_MASS_DRIVER_STATE.exists())
        self.assertTrue(PAYLOAD_MASS_DRIVER_SUPER_UPDATE_TILE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07PayloadMassDriverSuperUpdateTileRowsProof.gd', PAYLOAD_MASS_DRIVER_SUPER_UPDATE_TILE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_payload_mass_driver_super_update_tile_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadMassDriverSuperUpdateTileRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_MASS_DRIVER_SUPER_UPDATE_TILE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'update_call_build',
            'update_call_unit',
            'update_null',
            'update_kind',
            'update_holders',
            'update_live_input',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
