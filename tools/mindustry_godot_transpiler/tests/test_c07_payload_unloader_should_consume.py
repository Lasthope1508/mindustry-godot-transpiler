import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_UNLOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadUnloaderBuildState.gd'
PAYLOAD_UNLOADER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderShouldConsumeProof.gd'
PAYLOAD_UNLOADER_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderShouldConsumeProof.tscn'


class C07PayloadUnloaderShouldConsumeTests(unittest.TestCase):
    def test_c07_payload_unloader_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2209']['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_should_consume_state')
        # N2163 gave the payload-unloader its live power.status
        # read -- a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency
        # is build.power.status) -- but RED-deferred the
        # shouldConsume gate: the port tracked NO payload state
        # on any placed-building frame, so the machinery ran
        # with should_consume=true when enabled (the
        # MendProjector suppression precedent) -- a
        # payload-unloader holding nothing kept consuming power
        # while Java efficiency is 0. PayloadUnloaderBuild does
        # NOT override shouldConsume (PayloadUnloader.java has
        # no shouldConsume at all; PayloadUnloader extends
        # PayloadLoader, PayloadUnloader.java:8, and
        # PayloadUnloaderBuild extends PayloadLoaderBuild,
        # PayloadUnloader.java:32), so it inherits
        # PayloadLoaderBuild.shouldConsume verbatim
        # (PayloadLoader.java:240-242, `return payload != null;`)
        # -- and unlike the Separator/Drill gates this one has
        # NO `&& enabled`: the pure gate mirrors Java exactly
        # and does NOT add an enabled term (the driver already
        # runs the machinery only when enabled, so the live
        # path still respects disabled). N2209 wires the gate
        # into the payload-unloader's OWN driver
        # (SourcePayloadUnloaderBuildState.gd, frame key
        # "source_payload_unloader_building", the N2198
        # inherited-gate precedent): the frame gets a `payload`
        # key (the PayloadBlockBuild.payload field,
        # PayloadBlock.java:92, default null), the pure gate
        # reads only its null-ness, and the driver feeds
        # `should_consume` to the machinery, so an empty
        # payload-unloader folds efficiency 0 like Java. The
        # def is payload-unloader (consumePower 2f, size 3,
        # Blocks.java:6691-6698); there is no
        # large-payload-unloader. No live fill sets the frame
        # payload yet -- moveInPayload / handlePayload /
        # takePayload is the updateTile advance
        # (PayloadUnloader.java:50-110), which waits for its
        # own slice; the gate reads the frame as-is. Two new
        # result symbols: the gate and the payload presence
        # it reads.
        self.assertEqual(
            ledger['N2209']['source_symbols'],
            [
                'source_payload_unloader_should_consume_state_result.should_consume',
                'source_payload_unloader_should_consume_state_result.has_payload',
            ],
        )
        for name in ledger['N2209']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadLoader.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_should_consume_state')
        self.assertEqual(ledger['N2209']['runtime_proof'], '/root/C07PayloadUnloaderShouldConsumeProof')
        self.assertEqual(
            ledger['N2209']['tests'],
            [
                'test_c07_payload_unloader_should_consume_registration',
                'test_all_c07_payload_unloader_should_consume_input_evidence_is_exact',
                'test_payload_unloader_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_payload_unloader_should_consume',
            ],
        )
        self.assertTrue(ledger['N2209']['deferred_exprs'])
        # This slice resolves the N2163 PayloadUnloader gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, the dynamic power
        # consumer, the battery-unload rows, the shouldExport
        # gate, the power-production rows, the load params,
        # and the accept/handle payload rows stay deferred.
        self.assertFalse(any(entry.startswith('PayloadUnloader shouldConsume gate (') for entry in ledger['N2209']['deferred_exprs']))

    def test_all_c07_payload_unloader_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2209']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePayloadUnloaderBuildState.source_payload_unloader_should_consume_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadUnloader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2209']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_unloader_should_consume_gate_state(self):
        payload_unloader = PAYLOAD_UNLOADER_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the payload-unloader build
        # state: PayloadUnloaderBuild does NOT override
        # shouldConsume (PayloadUnloader.java has no
        # shouldConsume at all; PayloadUnloader extends
        # PayloadLoader, PayloadUnloader.java:8, `public class
        # PayloadUnloader extends PayloadLoader{`, and
        # PayloadUnloaderBuild extends PayloadLoaderBuild,
        # PayloadUnloader.java:32, `public class
        # PayloadUnloaderBuild extends PayloadLoaderBuild{`),
        # so it inherits PayloadLoaderBuild.shouldConsume
        # verbatim (PayloadLoader.java:240, `public boolean
        # shouldConsume(){` with `return payload != null;`,
        # PayloadLoader.java:241) -- and the default
        # (BuildingComp.java:755, `public boolean
        # shouldConsume(){` with `return enabled;`) does NOT
        # apply either. The gate has NO `&& enabled` -- unlike
        # the Separator/Drill gates, Java returns the bare
        # payload null check, so the pure gate must NOT read
        # frame["enabled"] at all. The payload field is the
        # PayloadBlockBuild field (`public @Nullable T
        # payload;`, PayloadBlock.java:92), default null, set
        # by handlePayload and cleared by takePayload. When
        # the gate is false updateConsumption forces
        # efficiency to zero (BuildingComp.java:1960, `boolean
        # update = shouldConsume() && productionValid();` +
        # 1992, `if(!update){`). The frame carries a `payload`
        # key (default null, bound by _initial_frame); the
        # gate reads only its null-ness. No live fill sets the
        # frame payload yet -- the moveInPayload /
        # handlePayload / takePayload advance is the updateTile
        # advance (PayloadUnloader.java:50-110), which waits
        # for its own slice; the gate reads the frame as-is.
        # The def is payload-unloader (consumePower 2f, size
        # 3, Blocks.java:6691-6698).
        self.assertIn('static func source_payload_unloader_should_consume_state', payload_unloader)
        self.assertIn('public boolean shouldConsume(){', payload_unloader)
        self.assertIn('return payload != null;', payload_unloader)
        self.assertIn('public class PayloadUnloader extends PayloadLoader{', payload_unloader)
        self.assertIn('public class PayloadUnloaderBuild extends PayloadLoaderBuild{', payload_unloader)
        self.assertIn('public @Nullable T payload;', payload_unloader)
        self.assertIn('boolean update = shouldConsume() && productionValid();', payload_unloader)
        self.assertIn('if(!update){', payload_unloader)
        self.assertIn('consumePower(2f);', payload_unloader)
        self.assertIn('"payload": null', payload_unloader)
        # The driver feeds the live gate to the machinery: the
        # gate call on the frame, and the gate result folded
        # into should_consume. The pure gate takes only the
        # frame -- it does NOT take enabled, and the driver
        # does not AND enabled into the gate result (the outer
        # tick guard already runs the machinery only when
        # enabled).
        self.assertIn('static func source_payload_unloader_tick_buildings_state', payload_unloader)
        self.assertIn('source_payload_unloader_should_consume_state(frame)', payload_unloader)
        self.assertIn('bool(gate.get("should_consume", true))', payload_unloader)
        # The documented limits record the gate as live; the
        # old N2163 deferral text is gone. The N2163 power row
        # is preserved.
        self.assertIn('shouldConsume gate live (N2209)', payload_unloader)
        self.assertNotIn('runs with should_consume=true when enabled', payload_unloader)
        self.assertNotIn('payload state is not tracked yet', payload_unloader)
        self.assertIn('static func source_payload_unloader_power_status_row_state', payload_unloader)
        # The proof's keys drive the pure gate (true with a
        # payload, false without one, INDEPENDENT of enabled --
        # the no-enabled point) plus the live tick (efficiency
        # 0 when the gate is false, the N2163 power fold
        # preserved when the gate is true, and the def:
        # payload-unloader consumePower 2f, size 3). There are
        # no load / export / battery keys: the updateTile
        # advance (PayloadUnloader.java:50-110) waits for its
        # own slice, so the load gate (PayloadUnloader.java:69)
        # is what the efficiency keys prove. Static checks:
        # the proof preloads the family state file that
        # exists, and the scene file references the proof
        # script that exists.
        proof = PAYLOAD_UNLOADER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_with_payload',
            'gate_false_without_payload',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'def_payload_unloader_consume_power_two_size_three',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadUnloaderBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_UNLOADER_STATE.is_file())
        scene = PAYLOAD_UNLOADER_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadUnloaderShouldConsumeProof.gd', scene)
        self.assertTrue(PAYLOAD_UNLOADER_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_payload_unloader_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadUnloaderShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_UNLOADER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_with_payload',
            'gate_false_without_payload',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'def_payload_unloader_consume_power_two_size_three',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
