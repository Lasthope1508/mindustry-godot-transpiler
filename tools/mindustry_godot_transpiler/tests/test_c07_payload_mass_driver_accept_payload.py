import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_MASS_DRIVER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadMassDriverBuildState.gd'
PAYLOAD_MASS_DRIVER_ACCEPT_PAYLOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverAcceptPayloadProof.gd'
PAYLOAD_MASS_DRIVER_ACCEPT_PAYLOAD_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverAcceptPayloadProof.tscn'


class C07PayloadMassDriverAcceptPayloadTests(unittest.TestCase):
    def test_c07_payload_mass_driver_accept_payload_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2298']['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_accept_payload_state')
        # N2164 proved the PayloadMassDriver live power read,
        # N2245 the updateTile frame/state advance and N2246 the
        # accepting / shooting branches -- but the port tracked
        # no acceptPayload gate at all, so nothing ever answered
        # whether a payload-mass-driver would take an offered
        # payload: the accepting branch aligned to a shooter
        # whose payload might not even fit. N2298 is the gate
        # (PayloadDriverBuild.acceptPayload(),
        # PayloadMassDriver.java:462-463): the base gate
        # `return this.payload == null;`
        # (PayloadBlock.java:116-118) AND the size gate
        # `payload.size() <= maxPayloadSize * tilesize` with the
        # class maxPayloadSize 3 (PayloadMassDriver.java:30) and
        # tilesize 8 (Vars.java:135) -- threshold 24. The
        # DEFERRED entry that scoped this slice cited
        # PayloadMassDriver.java:317-319 -- that range is the
        # transfer reset (other.state = idle), NOT acceptPayload;
        # the correct cite is :462-463. Three new result
        # symbols: the verdict, the size comparison, and the
        # threshold.
        self.assertEqual(
            ledger['N2298']['source_symbols'],
            [
                'source_payload_mass_driver_accept_payload_state_result.accepts',
                'source_payload_mass_driver_accept_payload_state_result.size_fits',
                'source_payload_mass_driver_accept_payload_state_result.threshold',
            ],
        )
        for name in ledger['N2298']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_accept_payload_state')
        self.assertEqual(ledger['N2298']['runtime_proof'], '/root/C07PayloadMassDriverAcceptPayloadProof')
        self.assertEqual(
            ledger['N2298']['tests'],
            [
                'test_c07_payload_mass_driver_accept_payload_registration',
                'test_all_c07_payload_mass_driver_accept_payload_input_evidence_is_exact',
                'test_payload_mass_driver_accept_payload_state',
                'test_reference_graph_and_actual_c07_payload_mass_driver_accept_payload',
            ],
        )
        self.assertTrue(ledger['N2298']['deferred_exprs'])
        # This slice resolves the acceptPayload entry (whose
        # :317-319 cite was wrong -- the real gate is :462-463).
        # One new deferral records what this slice leaves behind:
        # the per-def maxPayloadSize overrides (2.5f / 4f,
        # Blocks.java:6624/6636) beat the class default in Java,
        # so the class-default threshold 24 is exact only for a
        # class-default driver -- the per-def thresholds (20 / 32)
        # wait for their own slice.
        self.assertFalse(any(entry.startswith('PayloadMassDriver acceptPayload rows (') for entry in ledger['N2298']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadMassDriver acceptPayload per-def maxPayloadSize override (') for entry in ledger['N2298']['deferred_exprs']))

    def test_all_c07_payload_mass_driver_accept_payload_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2298']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_accept_payload_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2298']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_mass_driver_accept_payload_state(self):
        payload_mass_driver = PAYLOAD_MASS_DRIVER_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the payload-mass-driver build
        # state: PayloadDriverBuild.acceptPayload
        # (PayloadMassDriver.java:462-463),
        # `return super.acceptPayload(source, payload) &&
        # payload.size() <= maxPayloadSize * tilesize;`, where
        # super.acceptPayload is `return this.payload == null;`
        # (PayloadBlock.java:116-118) and maxPayloadSize is
        # `public float maxPayloadSize = 3;`
        # (PayloadMassDriver.java:30) times tilesize 8
        # (`public static final int tilesize = 8;`,
        # Vars.java:135) -- threshold 24. A BuildPayload size is
        # `return build.block.size * tilesize;`
        # (BuildPayload.java:86-88), so a size-3 block payload
        # measures 24 and sits exactly on the boundary (the
        # comparison is <=, so the boundary accepts). Keep each
        # Java expr on ONE comment line (the N2148 shootWarmup
        # lesson: a split line fails this test). The DEFERRED
        # entry's :317-319 cite was wrong -- that range is the
        # transfer reset (other.state = idle, :316-319), NOT
        # acceptPayload; the correct cite is :462-463. The
        # per-def overrides (`maxPayloadSize = 2.5f;` /
        # `maxPayloadSize = 4f;`, Blocks.java:6624/6636) beat the
        # class default in Java; this pure uses the class
        # default and the per-def thresholds live since N2304
        # in the for_def pure (which the tick calls with the
        # helper-resolved value). Unlike the Loader/Deconstructor block-size fits
        # checks, the PMD gate is size-based in world units.
        self.assertIn('static func source_payload_mass_driver_accept_payload_state', payload_mass_driver)
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
        # The class-default maxPayloadSize 3 and the shared
        # tilesize 8 (SourceWorldDefaults.TILESIZE, the
        # Loader/Unloader/Deconstructor precedent) give the
        # threshold 24; the pure returns the verdict, the size
        # comparison, and the threshold.
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE := 3.0', payload_mass_driver)
        self.assertIn('preload("res://src/game/SourceWorldDefaults.gd")', payload_mass_driver)
        self.assertIn('SOURCE_PAYLOAD_MASS_DRIVER_MAX_PAYLOAD_SIZE * source_world_defaults.TILESIZE', payload_mass_driver)
        self.assertIn('payload_size <= threshold', payload_mass_driver)
        self.assertIn('(not has_payload) and size_fits', payload_mass_driver)
        self.assertIn('return {"accepts": accepts, "size_fits": size_fits, "threshold": threshold}', payload_mass_driver)
        # The driver wires the gate into the live tick AFTER the
        # branches, so the verdict reads the post-tick payload (a
        # payload that just transferred out frees the gate in the
        # same tick). The offered size is a frame input
        # (frame["offered_payload_size"], world units -- there
        # are no live Payload objects in the port); no payload
        # offered means nothing to accept, so the verdict
        # defaults false. Since N2304 the tick calls the per-def
        # for_def pure (with the helper-resolved maxPayloadSize)
        # instead of this class-default pure; this pure stays as
        # the class-default gate.
        self.assertIn('frame.get("offered_payload_size", null)', payload_mass_driver)
        self.assertIn('source_payload_mass_driver_accept_payload_state_for_def(float(offered_payload_size), frame.get("payload", null) != null, max_payload_size)', payload_mass_driver)
        self.assertIn('frame["accepts_payload"] = false', payload_mass_driver)
        self.assertIn('frame["accepts_payload"] = bool(accept_verdict.get("accepts", false))', payload_mass_driver)
        # The documented limits now record the gate as live with
        # the corrected :462-463 cite; the old "No acceptPayload
        # rows" text is gone. The N2245 advance and the N2246
        # branches are preserved.
        self.assertIn('acceptPayload gate live (N2298)', payload_mass_driver)
        self.assertNotIn('No acceptPayload rows', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_power_status_row_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_update_tile_advance_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_state_branches_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_tick_buildings_state', payload_mass_driver)
        self.assertIn('static func source_payload_mass_driver_bind_frame_state', payload_mass_driver)
        # The proof's keys drive the pure gate (accepts when
        # empty and the size fits, rejects when a payload is
        # held, rejects oversize, the boundary size 24 accepts)
        # plus the live tick (a placed driver exposes the
        # verdict on the frame, and no payload offered means
        # false). Static checks: the proof preloads the family
        # state file that exists, and the scene file references
        # the proof script that exists.
        proof = PAYLOAD_MASS_DRIVER_ACCEPT_PAYLOAD_PROOF.read_text(encoding='utf-8')
        for key in [
            'accepts_when_empty_and_size_fits',
            'rejects_when_payload_present',
            'rejects_oversize',
            'boundary_size_24_accepted',
            'live_tick_exposes_verdict',
            'no_payload_offered_false',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadMassDriverBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_MASS_DRIVER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_MASS_DRIVER_ACCEPT_PAYLOAD_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadMassDriverAcceptPayloadProof.gd', scene)
        self.assertIn('C07PayloadMassDriverAcceptPayloadProof', scene)

    def test_reference_graph_and_actual_c07_payload_mass_driver_accept_payload(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadMassDriverAcceptPayloadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_MASS_DRIVER_ACCEPT_PAYLOAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accepts_when_empty_and_size_fits',
            'rejects_when_payload_present',
            'rejects_oversize',
            'boundary_size_24_accepted',
            'live_tick_exposes_verdict',
            'no_payload_offered_false',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
