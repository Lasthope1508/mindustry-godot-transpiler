import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_AMMO_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourcePayloadAmmoTurretBuildPortBridge.gd'
PAYLOAD_AMMO_TURRET_PAYLOAD_INTAKE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadTurretPayloadIntakeProof.gd'


class C07PayloadTurretPayloadIntakeTests(unittest.TestCase):
    def test_c07_payload_turret_payload_intake_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2387']['godot_owner'], 'PortGame.source_payload_ammo_turret_build_has_ammo_state')
        # PayloadTurretBuild.hasAmmo()+acceptPayload()+handlePayload()
        # (PayloadAmmoTurret.java:107-110/:112-115/:117-120):
        # `@Override`
        # `public boolean acceptPayload(Building source, Payload payload){`
        # `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`
        # `}`
        # `@Override`
        # `public void handlePayload(Building source, Payload payload){`
        # `payloads.add(payload.content());`
        # `}`
        # `@Override`
        # `public boolean hasAmmo(){`
        # `return payloads.total() > 0;`
        # `}`
        # on `public class PayloadTurretBuild extends TurretBuild{`
        # (PayloadAmmoTurret.java:94) inside
        # `public class PayloadAmmoTurret extends Turret{`
        # (PayloadAmmoTurret.java:21). These are three one-line
        # Build methods on the same payload-ammo intake
        # concern: hasAmmo reports whether any payload unit is
        # held; acceptPayload gates intake on capacity
        # (payloads.total() < maxAmmo) and ammo membership
        # (ammoTypes.containsKey(payload.content())); handlePayload
        # adds the payload's content to the seq. The method
        # headers are shared text (acceptPayload hits N1415/N2131,
        # handlePayload hits N586, hasAmmo hits N1171/N1203/N1228/
        # N2285/N2301/N2311/N2313/N2316 in the local ledger) --
        # the N632-N639 vs N1078-N1085 precedent allows the same
        # text under its own java_method. The distinguishing
        # lines are the three bodies
        # `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`,
        # `payloads.add(payload.content());` and
        # `return payloads.total() > 0;`
        # (all 0-hit in both ledgers at HEAD 1047fc24).
        # `payloads` is `public PayloadSeq payloads = new PayloadSeq();`
        # (PayloadAmmoTurret.java:95) and arrives as the explicit
        # payload_contents param -- one entry per payload unit,
        # so total() is exactly payload_contents.size() (the
        # N2381 updateTile precedent). `maxAmmo` is the
        # constructor field (`maxAmmo = 3;`,
        # PayloadAmmoTurret.java:28) and arrives as an explicit
        # int param. `ammoTypes` (ObjectMap<UnlockableContent,
        # BulletType>, PayloadAmmoTurret.java:22) arrives as the
        # explicit ammo_types Dictionary param (content name ->
        # bullet type name); ObjectMap is NOT ported.
        # `payload.content()` is a field on the given Payload --
        # it arrives as the explicit payload_content param
        # (content name or null); `Payload`/`PayloadSeq` are
        # NOT ported. The `source` (Building) param of
        # acceptPayload/handlePayload is unused in the bodies
        # and is NOT a param. Three new result symbols:
        # has_ammo, accepts_payload, payload_contents.
        self.assertEqual(
            ledger['N2387']['source_symbols'],
            [
                'source_payload_ammo_turret_build_has_ammo_state_result.has_ammo',
                'source_payload_ammo_turret_build_accept_payload_state_result.accepts_payload',
                'source_payload_ammo_turret_build_handle_payload_state_result.payload_contents',
            ],
        )
        for name in ledger['N2387']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2387']['runtime_proof'], '/root/C07PayloadTurretPayloadIntakeProof')
        self.assertEqual(
            ledger['N2387']['tests'],
            [
                'test_c07_payload_turret_payload_intake_registration',
                'test_all_c07_payload_turret_payload_intake_input_evidence_is_exact',
                'test_payload_turret_payload_intake_state',
                'test_reference_graph_and_actual_c07_payload_turret_payload_intake',
            ],
        )
        self.assertTrue(ledger['N2387']['deferred_exprs'])

    def test_all_c07_payload_turret_payload_intake_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2387']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2387']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_turret_payload_intake_state(self):
        bridge = PAYLOAD_AMMO_TURRET_BRIDGE.read_text(encoding='utf-8')
        # PayloadTurretBuild.hasAmmo()+acceptPayload()+handlePayload()
        # (PayloadAmmoTurret.java:107-110/:112-115/:117-120)
        # groups three one-line Build methods: hasAmmo is
        # `payloads.total() > 0`; acceptPayload is
        # `payloads.total() < maxAmmo` AND the payload content
        # is an ammo type; handlePayload adds the payload
        # content to the seq (`payloads.add(payload.content());`).
        # The handlePayload mutation is modeled as param in/out
        # (the N2313 param precedent): the payload contents
        # arrive as the explicit payload_contents param, the
        # function duplicates it, appends the content, and
        # returns the updated list -- the input array is never
        # mutated. A null content is a no-op
        # (`PayloadSeq.add` returns early on null,
        # PayloadSeq.java:35-37). NO driver tick line: pure
        # intake predicates / seq update, not a per-tick write
        # -- the caller wiring waits for its own slice.
        self.assertIn('static func source_payload_ammo_turret_build_has_ammo_state(payload_contents: Array) -> Dictionary:', bridge)
        self.assertIn('static func source_payload_ammo_turret_build_accept_payload_state(payload_contents: Array, max_ammo: int, ammo_types: Dictionary, payload_content: Variant) -> Dictionary:', bridge)
        self.assertIn('static func source_payload_ammo_turret_build_handle_payload_state(payload_contents: Array, payload_content: Variant) -> Dictionary:', bridge)
        self.assertIn('return {"has_ammo": has_ammo}', bridge)
        self.assertIn('return {"accepts_payload": accepts_payload}', bridge)
        self.assertIn('return {"payload_contents": updated_contents}', bridge)
        for expr in [
            'public class PayloadAmmoTurret extends Turret{',
            'public class PayloadTurretBuild extends TurretBuild{',
            '@Override',
            'public boolean acceptPayload(Building source, Payload payload){',
            'return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());',
            'public void handlePayload(Building source, Payload payload){',
            'payloads.add(payload.content());',
            'public boolean hasAmmo(){',
            'return payloads.total() > 0;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the three pure functions
        # with synthetic inputs (no live tick): hasAmmo true
        # iff the seq is non-empty / acceptPayload gates on
        # capacity and ammo membership / handlePayload appends
        # the content (null is a no-op) / inputs unmutated /
        # exactly one result key each.
        proof = PAYLOAD_AMMO_TURRET_PAYLOAD_INTAKE_PROOF.read_text(encoding='utf-8')
        for key in [
            'has_ammo_true_when_nonempty',
            'has_ammo_false_when_empty',
            'accept_payload_accepts_known_below_max',
            'accept_payload_rejects_at_max',
            'accept_payload_rejects_unknown_content',
            'handle_payload_adds_content',
            'handle_payload_null_content_noop',
            'handle_payload_inputs_unmutated',
            'has_ammo_returns_only_one_key',
            'accept_payload_returns_only_one_key',
            'handle_payload_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_payload_turret_payload_intake(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadTurretPayloadIntakeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_TURRET_PAYLOAD_INTAKE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'has_ammo_true_when_nonempty',
            'has_ammo_false_when_empty',
            'accept_payload_accepts_known_below_max',
            'accept_payload_rejects_at_max',
            'accept_payload_rejects_unknown_content',
            'handle_payload_adds_content',
            'handle_payload_null_content_noop',
            'handle_payload_inputs_unmutated',
            'has_ammo_returns_only_one_key',
            'accept_payload_returns_only_one_key',
            'handle_payload_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
