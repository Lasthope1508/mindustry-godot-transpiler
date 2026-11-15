import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd'
PAYLOAD_LOADER_ACCEPT_PAYLOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderAcceptPayloadProof.gd'
PAYLOAD_LOADER_ACCEPT_PAYLOAD_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderAcceptPayloadProof.tscn'


class C07PayloadLoaderAcceptPayloadTests(unittest.TestCase):
    def test_c07_payload_loader_accept_payload_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2295']['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_accept_payload_state')
        # The payload-loader gate (N2208) reads payload != null,
        # the updateTile advance (N2231) moves the payload in
        # and out and loads it, the dynamic power value (N2270)
        # prices the battery charge, and the live fill (N2278)
        # sets the payload on intake -- but nothing ever
        # ANSWERED whether a payload may be offered at all:
        # acceptPayload (PayloadLoader.java:90-101) is the
        # consult gate the source calls before pushing
        # (movePayload, BuildingComp.java:819-829), and it
        # waited for its own slice. N2295 is the gate: the
        # base gate (super.acceptPayload returns
        # this.payload == null, PayloadBlock.java:116-118)
        # AND payload.fits(maxBlockSize) AND the BuildPayload
        # instanceof AND one of the three branches -- the
        # item container (hasItems && unloadable &&
        # itemCapacity >= 10 && size <= maxBlockSize), the
        # liquid container (hasLiquids && liquidCapacity >=
        # 10f), the battery (consPower != null && buffered).
        # Five new result symbols: the verdict, the fits
        # check, and the three branch verdicts.
        self.assertEqual(
            ledger['N2295']['source_symbols'],
            [
                'source_payload_loader_accept_payload_state_result.accepts',
                'source_payload_loader_accept_payload_state_result.fits',
                'source_payload_loader_accept_payload_state_result.is_item_container',
                'source_payload_loader_accept_payload_state_result.is_liquid_container',
                'source_payload_loader_accept_payload_state_result.is_battery',
            ],
        )
        for name in ledger['N2295']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadLoader.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_accept_payload_state')
        self.assertEqual(ledger['N2295']['runtime_proof'], '/root/C07PayloadLoaderAcceptPayloadProof')
        self.assertEqual(
            ledger['N2295']['tests'],
            [
                'test_c07_payload_loader_accept_payload_registration',
                'test_all_c07_payload_loader_accept_payload_input_evidence_is_exact',
                'test_payload_loader_accept_payload_state',
                'test_reference_graph_and_actual_c07_payload_loader_accept_payload',
            ],
        )
        self.assertTrue(ledger['N2295']['deferred_exprs'])

    def test_all_c07_payload_loader_accept_payload_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2295']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_accept_payload_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2295']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_loader_accept_payload_state(self):
        payload_loader = PAYLOAD_LOADER_STATE.read_text(encoding='utf-8')
        # The pure accept function ports acceptPayload
        # (PayloadLoader.java:90-101): `return
        # super.acceptPayload(source, payload) &&` (:91),
        # `payload.fits(maxBlockSize) &&` (:92), `payload
        # instanceof BuildPayload build && (` (:93), then
        # the three branches -- the item container (:95),
        # the liquid container (:97), the battery (:99).
        # super.acceptPayload is `return this.payload ==
        # null;` (PayloadBlock.java:116-118), so the base
        # gate is the has_payload param. fits is
        # `return size() / tilesize <= s;`
        # (Payload.java:50-52) with `return build.block.size
        # * tilesize;` (BuildPayload.java:86-88), so for a
        # BuildPayload fits is block.size <= maxBlockSize
        # (maxBlockSize 3, PayloadLoader.java:25). The
        # descriptor carries the block flags Java reads
        # live: unloadable (Block.java:106, default true),
        # itemCapacity (Block.java:75, default 10),
        # liquidCapacity (Block.java:77, default -1f),
        # consPower (Block.java:414) with buffered
        # (ConsumePower.java:14). Missing keys default to
        # the rejecting value (false / 0) -- a partial
        # fixture must NOT accept.
        self.assertIn('static func source_payload_loader_accept_payload_state', payload_loader)
        self.assertIn('public boolean acceptPayload(Building source, Payload payload){', payload_loader)
        self.assertIn('return super.acceptPayload(source, payload) &&', payload_loader)
        self.assertIn('payload.fits(maxBlockSize) &&', payload_loader)
        self.assertIn('payload instanceof BuildPayload build && (', payload_loader)
        self.assertIn('(build.build.block.hasItems && build.block().unloadable && build.block().itemCapacity >= 10 && build.block().size <= maxBlockSize) ||', payload_loader)
        self.assertIn('(build.build.block.hasLiquids && build.block().liquidCapacity >= 10f) ||', payload_loader)
        self.assertIn('(build.build.block.consPower != null && build.build.block.consPower.buffered)', payload_loader)
        self.assertIn('return this.payload == null;', payload_loader)
        self.assertIn('public int maxBlockSize = 3;', payload_loader)
        self.assertIn('default boolean fits(float s){', payload_loader)
        self.assertIn('return size() / tilesize <= s;', payload_loader)
        self.assertIn('return build.block.size * tilesize;', payload_loader)
        self.assertIn('public boolean unloadable = true;', payload_loader)
        self.assertIn('public int itemCapacity = 10;', payload_loader)
        self.assertIn('public float liquidCapacity = -1f;', payload_loader)
        self.assertIn('public @Nullable ConsumePower consPower;', payload_loader)
        self.assertIn('public boolean buffered;', payload_loader)
        self.assertIn('public class PayloadLoader extends PayloadBlock{', payload_loader)
        self.assertIn('public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{', payload_loader)
        self.assertIn('public class PayloadBlockBuild<T extends Payload> extends Building{', payload_loader)
        self.assertIn('public @Nullable T payload;', payload_loader)
        # The driver stamps the verdict on the frame every
        # tick: frame["accepts_payload"], computed from the
        # frame-supplied offered-payload descriptor when
        # present (frame["offered_payload"]) and the frame
        # payload null-ness -- acceptPayload is consulted
        # BEFORE handlePayload, so the stamp sits before the
        # N2278 intake. No payload offered means no verdict
        # to give: accepts false. A fresh frame starts with
        # accepts_payload false (no offer at placement).
        # The N2278 intake keeps its own payload-null guard
        # untouched.
        self.assertIn('static func source_payload_loader_tick_buildings_state', payload_loader)
        self.assertIn('frame["offered_payload"]', payload_loader)
        self.assertIn('frame["accepts_payload"]', payload_loader)
        self.assertIn('"accepts_payload": false', payload_loader)
        self.assertIn('source_payload_loader_accept_payload_state(', payload_loader)
        self.assertIn('frame["incoming_payload"]', payload_loader)
        # The documented limits now record the acceptPayload
        # rows as live; the N2231 advance, N2208 gate and
        # N2278 fill text stays.
        self.assertIn('acceptPayload rows live (N2295)', payload_loader)
        self.assertIn('live payload fill live (N2278)', payload_loader)
        self.assertIn('updateTile advance live (N2231)', payload_loader)
        self.assertIn('shouldConsume gate live (N2208)', payload_loader)
        # The proof's keys drive the pure gate (the base
        # gate rejecting when a payload is held, the
        # non-build payload, the three accepted branches,
        # the oversize / under-capacity rejections) and the
        # live tick stamping frame accepts_payload from an
        # offered descriptor. Static checks: the proof
        # preloads the family state file that exists, and
        # the scene file references the proof script that
        # exists.
        proof = PAYLOAD_LOADER_ACCEPT_PAYLOAD_PROOF.read_text(encoding='utf-8')
        for key in [
            'base_gate_rejects_when_payload_present',
            'non_build_payload_rejected',
            'item_container_accepted',
            'liquid_container_accepted',
            'battery_accepted',
            'oversize_or_under_capacity_rejected',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadLoaderBuildState.gd")', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_accept_payload_state(', proof)
        self.assertTrue(PAYLOAD_LOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = PAYLOAD_LOADER_ACCEPT_PAYLOAD_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadLoaderAcceptPayloadProof.gd', scene)
        self.assertIn('C07PayloadLoaderAcceptPayloadProof', scene)

    def test_reference_graph_and_actual_c07_payload_loader_accept_payload(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadLoaderAcceptPayloadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_LOADER_ACCEPT_PAYLOAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'base_gate_rejects_when_payload_present',
            'non_build_payload_rejected',
            'item_container_accepted',
            'liquid_container_accepted',
            'battery_accepted',
            'oversize_or_under_capacity_rejected',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
