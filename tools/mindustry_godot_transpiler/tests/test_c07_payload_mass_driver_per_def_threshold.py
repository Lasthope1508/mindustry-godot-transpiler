import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadMassDriverBuildState.gd'
PAYLOAD_MASS_DRIVER_PER_DEF_THRESHOLD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverPerDefThresholdProof.gd'
PAYLOAD_MASS_DRIVER_PER_DEF_THRESHOLD_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverPerDefThresholdProof.tscn'


class C07PayloadMassDriverPerDefThresholdTests(unittest.TestCase):
    def test_c07_payload_mass_driver_per_def_threshold_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2304']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_accept_payload_state_for_def')
        # N2298 ported the PayloadMassDriver acceptPayload gate
        # with the class-default maxPayloadSize 3 (threshold
        # 24), but BOTH real defs override it: 2.5f for
        # payload-mass-driver (threshold 20) and 4f for
        # large-payload-mass-driver (threshold 32),
        # Blocks.java:6624/6636. N2304 is the per-def gate: a
        # new pure taking max_payload_size as a param (the
        # N2298 pure stays as the class-default gate -- the
        # N2298 test pins its exact 2-arg tick call and its
        # class-default threshold line, so extending it would
        # break the N2298 test; the duplication rationale is
        # that the class-default pure remains the fallback the
        # helper returns for an unknown block id). The driver
        # resolves the per-def value by block id (the catalog
        # carries no maxPayloadSize property) and the tick
        # passes it to the new pure. Three new result symbols:
        # the verdict, the size comparison, and the threshold.
        self.assertEqual(
            ledger['N2304']['source_symbols'],
            [
                'source_payload_mass_driver_accept_payload_state_for_def_result.accepts',
                'source_payload_mass_driver_accept_payload_state_for_def_result.size_fits',
                'source_payload_mass_driver_accept_payload_state_for_def_result.threshold',
            ],
        )
        for name in ledger['N2304']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_accept_payload_state_for_def')
        self.assertEqual(ledger['N2304']['runtime_proof'], '/root/C07PayloadMassDriverPerDefThresholdProof')
        self.assertEqual(
            ledger['N2304']['tests'],
            [
                'test_c07_payload_mass_driver_per_def_threshold_registration',
                'test_all_c07_payload_mass_driver_per_def_threshold_input_evidence_is_exact',
                'test_payload_mass_driver_per_def_threshold_state',
                'test_reference_graph_and_actual_c07_payload_mass_driver_per_def_threshold',
            ],
        )
        self.assertTrue(ledger['N2304']['deferred_exprs'])
        # This slice resolves the per-def DEFERRED entry N2298
        # left behind; it adds no new deferral (the unknown
        # block-id fallback to the class default is defensive,
        # not a deviation -- every real PayloadMassDriver build
        # has one of the two defs).
        self.assertFalse(any(entry.startswith('PayloadMassDriver acceptPayload per-def maxPayloadSize override (') for entry in ledger['N2304']['deferred_exprs']))

    def test_all_c07_payload_mass_driver_per_def_threshold_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2304']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_accept_payload_state_for_def')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2304']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_mass_driver_per_def_threshold_state(self):
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The per-def gate lives on the payload-mass-driver
        # build state: PayloadDriverBuild.acceptPayload
        # (PayloadMassDriver.java:462-463),
        # `return super.acceptPayload(source, payload) &&
        # payload.size() <= maxPayloadSize * tilesize;`, where
        # super.acceptPayload is `return this.payload == null;`
        # (PayloadBlock.java:116-118) and maxPayloadSize is
        # per def: `maxPayloadSize = 2.5f;`
        # (Blocks.java:6624, payload-mass-driver, threshold 20)
        # and `maxPayloadSize = 4f;` (Blocks.java:6636,
        # large-payload-mass-driver, threshold 32), beating the
        # class `public float maxPayloadSize = 3;`
        # (PayloadMassDriver.java:30, threshold 24) times
        # tilesize 8 (`public static final int tilesize = 8;`,
        # Vars.java:135). A BuildPayload size is `return
        # build.block.size * tilesize;`
        # (BuildPayload.java:86-88). Keep each Java expr on ONE
        # comment line (the N2148 shootWarmup lesson: a split
        # line fails this test). The new pure takes
        # max_payload_size as a param; the N2298 class-default
        # pure stays intact (its test pins the exact 2-arg call
        # and the class-default threshold line).
        self.assertIn('static func source_payload_mass_driver_accept_payload_state_for_def(payload_size: float, has_payload: bool, max_payload_size: float) -> Dictionary:', payload_mass_driver)
        self.assertIn('public class PayloadMassDriver extends PayloadBlock{', payload_mass_driver)
        self.assertIn('public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{', payload_mass_driver)
        self.assertIn('public float maxPayloadSize = 3;', payload_mass_driver)
        self.assertIn('public boolean acceptPayload(Building source, Payload payload){', payload_mass_driver)
        self.assertIn('return super.acceptPayload(source, payload) && payload.size() <= maxPayloadSize * tilesize;', payload_mass_driver)
        self.assertIn('return this.payload == null;', payload_mass_driver)
        self.assertIn('public static final int tilesize = 8;', payload_mass_driver)
        self.assertIn('return build.block.size * tilesize;', payload_mass_driver)
        self.assertIn('public @Nullable T payload;', payload_mass_driver)
        self.assertIn('maxPayloadSize = 2.5f;', payload_mass_driver)
        self.assertIn('maxPayloadSize = 4f;', payload_mass_driver)
        self.assertIn('PayloadMassDriver.java:462-463', payload_mass_driver)
        # The per-def values resolve by block id (the N2273
        # boostItemUseTime precedent, and the in-family
        # charge-time / range helpers): the catalog carries no
        # maxPayloadSize property, so the driver resolves it
        # here; an unknown block id keeps the class default.
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE_SMALL := 2.5', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE_LARGE := 4.0', payload_mass_driver)
        self.assertIn('static func _payload_mass_driver_max_payload_size_for_block(block_id: String) -> float:', payload_mass_driver)
        self.assertIn('if block_id == "payload-mass-driver":', payload_mass_driver)
        self.assertIn('if block_id == "large-payload-mass-driver":', payload_mass_driver)
        self.assertIn('return SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE_SMALL', payload_mass_driver)
        self.assertIn('return SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE_LARGE', payload_mass_driver)
        self.assertIn('return SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE', payload_mass_driver)
        # The new pure multiplies the PARAM by the shared
        # tilesize (SourceWorldDefaults.TILESIZE, the
        # Loader/Unloader/Deconstructor precedent) and returns
        # the verdict, the size comparison, and the threshold.
        self.assertIn('max_payload_size * source_world_defaults.TILESIZE', payload_mass_driver)
        self.assertIn('payload_size <= threshold', payload_mass_driver)
        self.assertIn('(not has_payload) and size_fits', payload_mass_driver)
        self.assertIn('return {"accepts": accepts, "size_fits": size_fits, "threshold": threshold}', payload_mass_driver)
        # The driver wires the per-def gate into the live tick
        # AFTER the branches, so the verdict reads the
        # post-tick payload (a payload that just transferred
        # out frees the gate in the same tick). The offered
        # size is a frame input (frame["offered_payload_size"],
        # world units -- there are no live Payload objects in
        # the port); no payload offered means nothing to
        # accept, so the verdict defaults false. The tick
        # resolves the per-def value from the placed block id
        # and passes it to the new pure.
        self.assertIn('frame.get("offered_payload_size", null)', payload_mass_driver)
        self.assertIn('_payload_mass_driver_max_payload_size_for_block(block_id)', payload_mass_driver)
        self.assertIn('source_payload_mass_driver_accept_payload_state_for_def(float(offered_payload_size), frame.get("payload", null) != null, max_payload_size)', payload_mass_driver)
        self.assertIn('frame["accepts_payload"] = false', payload_mass_driver)
        self.assertIn('frame["accepts_payload"] = bool(accept_verdict.get("accepts", false))', payload_mass_driver)
        # The documented limits now record the per-def gate as
        # live (N2304) alongside the N2298 class-default gate;
        # the N2298 pure, the N2245 advance and the N2246
        # branches are preserved.
        self.assertIn('acceptPayload gate live (N2298)', payload_mass_driver)
        self.assertIn('per-def maxPayloadSize live (N2304)', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_accept_payload_state(payload_size: float, has_payload: bool) -> Dictionary:', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_power_status_row_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_update_tile_advance_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_state_branches_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_tick_buildings_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_bind_frame_state', payload_mass_driver)
        # The proof's keys drive the per-def gate (the small
        # def's boundary 20 accepts while size 24 -- which fits
        # the class default -- rejects; the large def's
        # boundary 32 accepts while 33 rejects; the class
        # default boundary 24 still accepts) plus the live tick
        # (a placed driver exposes the per-def verdict on the
        # frame). Static checks: the proof preloads the family
        # state file that exists, and the scene file references
        # the proof script that exists.
        proof = PAYLOAD_MASS_DRIVER_PER_DEF_THRESHOLD_PROOF.read_text(encoding='utf-8')
        for key in [
            'small_def_boundary_20_accepted',
            'small_def_size_24_rejected',
            'large_def_boundary_32_accepted',
            'large_def_size_33_rejected',
            'class_default_boundary_24_accepted',
            'live_tick_exposes_per_def_verdict',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadMassDriverBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_MASS_DRIVER_PER_DEF_THRESHOLD_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadMassDriverPerDefThresholdProof.gd', scene)
        self.assertIn('C07PayloadMassDriverPerDefThresholdProof', scene)

    def test_reference_graph_and_actual_c07_payload_mass_driver_per_def_threshold(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadMassDriverPerDefThresholdProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_MASS_DRIVER_PER_DEF_THRESHOLD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'small_def_boundary_20_accepted',
            'small_def_size_24_rejected',
            'large_def_boundary_32_accepted',
            'large_def_size_33_rejected',
            'class_default_boundary_24_accepted',
            'live_tick_exposes_per_def_verdict',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
