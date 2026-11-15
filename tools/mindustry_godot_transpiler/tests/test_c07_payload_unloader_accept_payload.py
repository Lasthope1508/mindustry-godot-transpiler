import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
PAYLOAD_UNLOADER_ACCEPT_PAYLOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderAcceptPayloadProof.gd'
PAYLOAD_UNLOADER_ACCEPT_PAYLOAD_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderAcceptPayloadProof.tscn'
PAYLOAD_UNLOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadUnloader.java'
PAYLOAD_LOADER_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadLoader.java'
PAYLOAD_BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/PayloadBlock.java'
PAYLOAD_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/Payload.java'
BUILD_PAYLOAD_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/blocks/payloads/BuildPayload.java'
BLOCK_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/world/Block.java'
VARS_JAVA = ROOT / 'mindustry-upstream/core/src/mindustry/Vars.java'


class C07PayloadUnloaderAcceptPayloadTests(unittest.TestCase):
    def test_c07_payload_unloader_accept_payload_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2296']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_accept_payload_state')
        # N2163 proved the PayloadUnloader family's live power
        # read, N2209 the shouldConsume gate (return payload !=
        # null, inherited verbatim from PayloadLoaderBuild, no
        # enabled term), N2232 the updateTile advance
        # (moveInPayload / moveOutPayload + unload
        # items/liquids + battery unload into lastOutputPower),
        # N2279 the live payload fill and N2293 the dump rows --
        # but the intake itself never asked whether the offered
        # payload was acceptable: the N2279 handlePayload fill
        # applies incoming_payload on the frame-null check
        # alone. N2296 is the acceptPayload gate: ONE pure
        # (source_payload_unloader_accept_payload_state)
        # returning {accept_payload, accept_item,
        # accept_liquid}. SCOPE CORRECTION (grep-verified, the
        # brief had this backwards): PayloadUnloaderBuild
        # extends PayloadLoaderBuild (PayloadUnloader.java:32)
        # and does NOT override acceptPayload, so it inherits
        # the LOADER's override (PayloadLoader.java:90-101) --
        # the base null gate AND fits(maxBlockSize) AND
        # instanceof BuildPayload AND the item-container /
        # liquid-container / battery branches -- NOT the bare
        # PayloadBlock base gate (PayloadBlock.java:116-118).
        # DEFERRED entry 12's "PayloadLoader.java:90-101,
        # inherited" cite was CORRECT all along; the brief's
        # "misleading" label was the error. acceptItem /
        # acceptLiquid are hard-coded false
        # (PayloadUnloader.java:35-44), so the Unloader
        # accepts payloads but never loose items or liquids --
        # that is why its dump rows (N2293) move items/liquids
        # OUT only. Three new result symbols: the three
        # verdicts.
        self.assertEqual(
            ledger['N2296']['source_symbols'],
            [
                'source_payload_unloader_accept_payload_state_result.accept_payload',
                'source_payload_unloader_accept_payload_state_result.accept_item',
                'source_payload_unloader_accept_payload_state_result.accept_liquid',
            ],
        )
        for name in ledger['N2296']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
                    'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
                    'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
                    'core/src/mindustry/world/blocks/payloads/Payload.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_accept_payload_state')
        self.assertEqual(ledger['N2296']['runtime_proof'], '/root/C07PayloadUnloaderAcceptPayloadProof')
        self.assertEqual(
            ledger['N2296']['tests'],
            [
                'test_c07_payload_unloader_accept_payload_registration',
                'test_all_c07_payload_unloader_accept_payload_input_evidence_is_exact',
                'test_payload_unloader_accept_payload_state',
                'test_reference_graph_and_actual_c07_payload_unloader_accept_payload',
            ],
        )
        self.assertTrue(ledger['N2296']['deferred_exprs'])
        # This slice resolves the acceptPayload entry (entry
        # 12) and adds three narrower entries (the intake-guard
        # wiring, the live offered source, and the descriptor
        # unification). The Loader's own acceptPayload entry
        # stays verbatim -- N2295 owns it, and this slice
        # ports the same Java method for the Unloader driver,
        # not for the Loader.
        self.assertFalse(any(entry.startswith('PayloadUnloader acceptPayload rows (') for entry in ledger['N2296']['deferred_exprs']))
        for prefix in [
            'PayloadUnloader acceptPayload intake-guard wiring (',
            'PayloadUnloader acceptPayload live offered source (',
            'PayloadUnloader offered-payload descriptor unification (',
            'PayloadLoader acceptPayload rows (',
            'PayloadUnloader dump neighbour live fill (',
            'PayloadUnloader dump neighbour write-back (',
            'PayloadUnloader dumpLiquid campaign unlock surfacing (',
        ]:
            with self.subTest(prefix=prefix):
                self.assertTrue(any(entry.startswith(prefix) for entry in ledger['N2296']['deferred_exprs']))

    def test_all_c07_payload_unloader_accept_payload_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2296']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_accept_payload_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2296']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_accept_payload_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The acceptPayload gate (PayloadLoaderBuild.
        # acceptPayload(), PayloadLoader.java:90-101),
        # inherited verbatim by PayloadUnloaderBuild
        # (PayloadUnloader.java:32, `public class
        # PayloadUnloaderBuild extends PayloadLoaderBuild{`;
        # PayloadUnloader.java has NO acceptPayload at all):
        # `return super.acceptPayload(source, payload) &&` +
        # `payload.fits(maxBlockSize) &&` + `payload instanceof
        # BuildPayload build && (` + the three container
        # branches OR'd. super.acceptPayload is the base gate
        # (`return this.payload == null;`,
        # PayloadBlock.java:116-118). fits is `return size() /
        # tilesize <= s;` (Payload.java:50-52) with tilesize 8
        # (Vars.java:135) and maxBlockSize 3
        # (PayloadLoader.java:25); a BuildPayload's size() is
        # `return build.block.size * tilesize;`
        # (BuildPayload.java:86-88), so fits(3) is block.size
        # <= 3 for build payloads. The item branch needs
        # hasItems && unloadable (Block.java:106, default true)
        # && itemCapacity >= 10 && size <= maxBlockSize; the
        # liquid branch needs hasLiquids && liquidCapacity >=
        # 10f; the battery branch needs consPower != null &&
        # buffered. acceptItem / acceptLiquid are hard-coded
        # false (PayloadUnloader.java:35-44). Keep each Java
        # expr on ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_payload_unloader_accept_payload_state', payload_unloader)
        self.assertIn('public boolean acceptPayload(Building source, Payload payload){', payload_unloader)
        self.assertIn('return super.acceptPayload(source, payload) &&', payload_unloader)
        self.assertIn('payload.fits(maxBlockSize) &&', payload_unloader)
        self.assertIn('payload instanceof BuildPayload build && (', payload_unloader)
        self.assertIn('(build.build.block.hasItems && build.block().unloadable && build.block().itemCapacity >= 10 && build.block().size <= maxBlockSize) ||', payload_unloader)
        self.assertIn('(build.build.block.hasLiquids && build.block().liquidCapacity >= 10f) ||', payload_unloader)
        self.assertIn('(build.build.block.consPower != null && build.build.block.consPower.buffered)', payload_unloader)
        self.assertIn('public int maxBlockSize = 3;', payload_unloader)
        self.assertIn('return this.payload == null;', payload_unloader)
        self.assertIn('default boolean fits(float s){', payload_unloader)
        self.assertIn('return size() / tilesize <= s;', payload_unloader)
        self.assertIn('return build.block.size * tilesize;', payload_unloader)
        self.assertIn('public boolean acceptItem(Building source, Item item){', payload_unloader)
        self.assertIn('public boolean acceptLiquid(Building source, Liquid liquid){', payload_unloader)
        self.assertIn('return false;', payload_unloader)
        self.assertIn('public class PayloadUnloaderBuild extends PayloadLoaderBuild{', payload_unloader)
        self.assertIn('public class PayloadUnloader extends PayloadLoader{', payload_unloader)
        self.assertIn('public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{', payload_unloader)
        self.assertIn('public boolean unloadable = true;', payload_unloader)
        self.assertIn('public static final int tilesize = 8;', payload_unloader)
        self.assertIn('const SOURCE_PAYLOAD_UNLOADER_MAX_BLOCK_SIZE := 3', payload_unloader)
        # The scope correction is pinned in the driver: the
        # Unloader inherits the Loader's override, NOT the
        # bare base gate -- and the Unloader accepts payloads
        # but never loose items or liquids, which is why its
        # dump rows (N2293) move items/liquids OUT only.
        self.assertIn('inherits the Loader', payload_unloader)
        self.assertIn('NOT the bare PayloadBlock base gate', payload_unloader)
        self.assertIn('accepts payloads but never loose items or liquids', payload_unloader)
        # The driver wires the gate into the live tick: the
        # offered payload is a frame input (default null -- no
        # offer), evaluated against the filled frame payload
        # each tick, and the three verdicts land on the frame.
        # The pure is called exactly twice (its definition
        # plus the two tick call sites: the offer verdict
        # below, and the N2313 intake verdict computed from
        # the incoming dict itself). The N2279 intake is
        # wired to the gate since N2313.
        self.assertIn('source_payload_unloader_accept_payload_state(has_payload, offered_payload)', payload_unloader)
        self.assertEqual(payload_unloader.count('source_payload_unloader_accept_payload_state('), 3)
        self.assertIn('frame.get("offered_payload", null)', payload_unloader)
        self.assertIn('frame["accepts_payload"]', payload_unloader)
        self.assertIn('frame["accepts_item"]', payload_unloader)
        self.assertIn('frame["accepts_liquid"]', payload_unloader)
        # The fresh frame binds the offered key with the null
        # default, and the tick preserves it on a frame bound
        # before this slice.
        self.assertIn('"offered_payload": null', payload_unloader)
        self.assertIn('if not frame.has("offered_payload"):', payload_unloader)
        # Scope correction, pinned by line number: the brief
        # claimed the Unloader inherits PayloadBlock's base
        # gate and called entry 12's PayloadLoader.java:90-101
        # cite misleading -- but PayloadUnloaderBuild extends
        # PayloadLoaderBuild (:32) and PayloadUnloader.java
        # has no acceptPayload at all, so the Loader override
        # (:90-101) IS the Unloader's gate and entry 12's cite
        # was correct. acceptItem is :35-38 and acceptLiquid
        # :40-43 (:44 is blank, so the brief's :40-44 range
        # overruns by one line).
        unloader_lines = PAYLOAD_UNLOADER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(unloader_lines[31].strip(), 'public class PayloadUnloaderBuild extends PayloadLoaderBuild{')
        self.assertEqual(unloader_lines[35].strip(), 'public boolean acceptItem(Building source, Item item){')
        self.assertEqual(unloader_lines[36].strip(), 'return false;')
        self.assertEqual(unloader_lines[40].strip(), 'public boolean acceptLiquid(Building source, Liquid liquid){')
        self.assertEqual(unloader_lines[41].strip(), 'return false;')
        self.assertEqual(unloader_lines[43].strip(), '')
        self.assertNotIn('acceptPayload', PAYLOAD_UNLOADER_JAVA.read_text(encoding='utf-8'))
        loader_lines = PAYLOAD_LOADER_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(loader_lines[24].strip(), 'public int maxBlockSize = 3;')
        self.assertEqual(loader_lines[85].strip(), 'public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{')
        self.assertEqual(loader_lines[89].strip(), 'public boolean acceptPayload(Building source, Payload payload){')
        self.assertEqual(loader_lines[90].strip(), 'return super.acceptPayload(source, payload) &&')
        self.assertEqual(loader_lines[91].strip(), 'payload.fits(maxBlockSize) &&')
        self.assertEqual(loader_lines[92].strip(), 'payload instanceof BuildPayload build && (')
        self.assertEqual(loader_lines[94].strip(), '(build.build.block.hasItems && build.block().unloadable && build.block().itemCapacity >= 10 && build.block().size <= maxBlockSize) ||')
        self.assertEqual(loader_lines[96].strip(), '(build.build.block.hasLiquids && build.block().liquidCapacity >= 10f) ||')
        self.assertEqual(loader_lines[98].strip(), '(build.build.block.consPower != null && build.build.block.consPower.buffered)')
        block_lines = PAYLOAD_BLOCK_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(block_lines[115].strip(), 'public boolean acceptPayload(Building source, Payload payload){')
        self.assertEqual(block_lines[116].strip(), 'return this.payload == null;')
        payload_lines = PAYLOAD_JAVA.read_text(encoding='utf-8').splitlines()
        self.assertEqual(payload_lines[49].strip(), 'default boolean fits(float s){')
        self.assertEqual(payload_lines[50].strip(), 'return size() / tilesize <= s;')
        self.assertEqual(BUILD_PAYLOAD_JAVA.read_text(encoding='utf-8').splitlines()[86].strip(), 'return build.block.size * tilesize;')
        self.assertIn('public boolean unloadable = true;', BLOCK_JAVA.read_text(encoding='utf-8'))
        self.assertEqual(VARS_JAVA.read_text(encoding='utf-8').splitlines()[134].strip(), 'public static final int tilesize = 8;')
        # The documented limits now record the acceptPayload
        # rows as live (N2296); the shouldConsume gate stays
        # live (N2209), the advance stays live (N2232), the
        # live fill stays live (N2279) and the dump rows stay
        # live (N2293).
        self.assertIn('acceptPayload rows live (N2296)', payload_unloader)
        self.assertNotIn('No accept/handle payload rows', payload_unloader)
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertIn('updateTile advance live (N2232)', payload_unloader)
        self.assertIn('live payload fill live (N2279)', payload_unloader)
        self.assertIn('dump rows live (N2293)', payload_unloader)
        self.assertIn('static func source_payload_unloader_update_tile_advance_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_handle_payload_state', payload_unloader)
        self.assertIn('static func source_payload_unloader_dump_state', payload_unloader)
        # The proof's keys drive the pure gate (accepts a
        # fitting container when empty, rejects when a payload
        # is held, rejects non-container payloads, item/liquid
        # always false) plus the live tick (a placed
        # payload-unloader exposes all three verdicts on the
        # frame, and with no offer accepts nothing and moves
        # nothing).
        proof = PAYLOAD_UNLOADER_ACCEPT_PAYLOAD_PROOF.read_text(encoding='utf-8')
        for key in [
            'accepts_container_when_empty',
            'rejects_when_payload_present',
            'rejects_non_container_payload',
            'accept_item_always_false',
            'accept_liquid_always_false',
            'live_tick_exposes_all_three_verdicts',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        self.assertIn('preload("res://src/game/SourceSsotAccessorRuntimeState.gd")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/src/game/SourceSsotAccessorRuntimeState.gd').is_file())
        self.assertIn('preload("res://tools/runtime_proofs/RuntimeProofState.gd")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/tools/runtime_proofs/RuntimeProofState.gd').is_file())
        scene = PAYLOAD_UNLOADER_ACCEPT_PAYLOAD_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderAcceptPayloadProof.gd', scene)
        self.assertIn('C07PayloadUnloaderAcceptPayloadProof', scene)

    def test_reference_graph_and_actual_c07_payload_unloader_accept_payload(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderAcceptPayloadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_ACCEPT_PAYLOAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accepts_container_when_empty',
            'rejects_when_payload_present',
            'rejects_non_container_payload',
            'accept_item_always_false',
            'accept_liquid_always_false',
            'live_tick_exposes_all_three_verdicts',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
