import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadLoaderBuildState.gd'
PAYLOAD_LOADER_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderShouldConsumeProof.gd'
PAYLOAD_LOADER_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadLoaderShouldConsumeProof.tscn'


class C07PayloadLoaderShouldConsumeTests(unittest.TestCase):
    def test_c07_payload_loader_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2208']['godot_owner'], 'SourcePayloadLoaderBuildState.source_payload_loader_should_consume_state')
        # N2162 gave the payload loader its live power.status read --
        # a pure power row over the stamped frame value, folded by
        # the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO payload state on any
        # placed-building frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- a payload loader holding
        # nothing kept consuming power while Java efficiency is
        # 0. PayloadLoaderBuild overrides shouldConsume
        # (PayloadLoader.java:240-242, `return payload != null;`),
        # so the default (BuildingComp.java:755, `return
        # enabled;`) does NOT apply here -- and unlike the
        # Separator/Drill gates this one has NO `&& enabled`:
        # the pure gate must mirror Java exactly and NOT add an
        # enabled term (the driver already runs the machinery
        # only when enabled, so the live path still respects
        # disabled). The payload is the PayloadBlock field
        # (`public @Nullable T payload;`, PayloadBlock.java:92),
        # set by handlePayload (`this.payload = (T)payload;`,
        # PayloadBlock.java:122) and cleared by takePayload
        # (`payload = null;`, PayloadBlock.java:147). N2208
        # wires the gate into the payload loader's OWN driver
        # (SourcePayloadLoaderBuildState.gd, frame key
        # "source_payload_loader_building"): the frame gets a
        # `payload` key (default null, the Java field default),
        # the pure gate reads only its null-ness, and the driver
        # feeds `should_consume` to the machinery, so an empty
        # payload-loader folds efficiency 0 like Java. No live
        # fill sets frame["payload"] yet -- moveInPayload /
        # handlePayload fill waits for its own slice (new
        # deferral); the gate reads the frame as-is. The def is
        # the only payload-loader (consumePower 2f, size 3,
        # Blocks.java:6682-6689); there is no
        # large-payload-loader. Two new result symbols: the gate
        # and the payload presence it reads.
        self.assertEqual(
            ledger['N2208']['source_symbols'],
            [
                'source_payload_loader_should_consume_state_result.should_consume',
                'source_payload_loader_should_consume_state_result.has_payload',
            ],
        )
        for name in ledger['N2208']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_loader_should_consume_state_result.should_consume': 'SourcePayloadLoaderBuildState.source_payload_loader_should_consume_state',
                    'source_payload_loader_should_consume_state_result.has_payload': 'SourcePayloadLoaderBuildState.source_payload_loader_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2208']['runtime_proof'], '/root/C07PayloadLoaderShouldConsumeProof')
        self.assertEqual(
            ledger['N2208']['tests'],
            [
                'test_c07_payload_loader_should_consume_registration',
                'test_all_c07_payload_loader_should_consume_input_evidence_is_exact',
                'test_payload_loader_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_payload_loader_should_consume',
            ],
        )
        self.assertTrue(ledger['N2208']['deferred_exprs'])
        # This slice resolves the N2162 PayloadLoader gate
        # deferral, so the gate entry is gone from DEFERRED --
        # while the updateTile advance, dynamic power consumer,
        # battery-charge, load params, and accept/handle payload
        # rows stay deferred, and the live payload fill is a new
        # deferral.
        self.assertFalse(any(entry.startswith('PayloadLoader shouldConsume gate (') for entry in ledger['N2208']['deferred_exprs']))

    def test_all_c07_payload_loader_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2208']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_payload_loader_should_consume_state_result.should_consume': 'SourcePayloadLoaderBuildState.source_payload_loader_should_consume_state',
                    'source_payload_loader_should_consume_state_result.has_payload': 'SourcePayloadLoaderBuildState.source_payload_loader_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadLoader.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2208']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_loader_should_consume_gate_state(self):
        payload_loader = PAYLOAD_LOADER_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the payload-loader build state:
        # PayloadLoaderBuild overrides shouldConsume
        # (PayloadLoader.java:240, `public boolean shouldConsume(){`
        # with `return payload != null;`, PayloadLoader.java:241)
        # -- PayloadLoader extends PayloadBlock
        # (PayloadLoader.java:19, `public class PayloadLoader
        # extends PayloadBlock{`) and PayloadLoaderBuild extends
        # PayloadBlockBuild (PayloadLoader.java:86, `public class
        # PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{`;
        # PayloadBlock.java:91, `public class PayloadBlockBuild<T
        # extends Payload> extends Building{`), so the default
        # (BuildingComp.java:755, `public boolean shouldConsume(){`
        # with `return enabled;`) does NOT apply here. The gate
        # has NO `&& enabled` -- unlike the Separator/Drill
        # gates, Java returns the bare null check, so the pure
        # gate must NOT read frame["enabled"] at all. The payload
        # is the PayloadBlock field (`public @Nullable T payload;`,
        # PayloadBlock.java:92), set by handlePayload
        # (`this.payload = (T)payload;`, PayloadBlock.java:122)
        # and cleared by takePayload (`payload = null;`,
        # PayloadBlock.java:147). When the gate is false
        # updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries a `payload` key
        # (default null, the Java field default); the gate reads
        # only its null-ness. No live fill sets frame["payload"]
        # yet -- moveInPayload / handlePayload fill waits for its
        # own slice; the gate reads the frame as-is. The def is
        # the only payload-loader (`consumePower(2f);`, `size =
        # 3;`, Blocks.java:6682-6689); there is no
        # large-payload-loader. The load gate follows the folded
        # efficiency (PayloadLoader.java:157, `if(efficiency >
        # 0.01f && timer(timerLoad, loadTime / efficiency)){`).
        self.assertIn('static func source_payload_loader_should_consume_state', payload_loader)
        self.assertIn('public boolean shouldConsume(){', payload_loader)
        self.assertIn('return payload != null;', payload_loader)
        self.assertIn('public @Nullable T payload;', payload_loader)
        self.assertIn('this.payload = (T)payload;', payload_loader)
        self.assertIn('payload = null;', payload_loader)
        self.assertIn('public class PayloadLoader extends PayloadBlock{', payload_loader)
        self.assertIn('public class PayloadLoaderBuild extends PayloadBlockBuild<BuildPayload>{', payload_loader)
        self.assertIn('public class PayloadBlockBuild<T extends Payload> extends Building{', payload_loader)
        self.assertIn('boolean update = shouldConsume() && productionValid();', payload_loader)
        self.assertIn('if(!update){', payload_loader)
        self.assertIn('return enabled;', payload_loader)
        self.assertIn('consumePower(2f);', payload_loader)
        self.assertIn('size = 3;', payload_loader)
        self.assertIn('if(efficiency > 0.01f && timer(timerLoad, loadTime / efficiency)){', payload_loader)
        self.assertIn('"payload": null', payload_loader)
        self.assertIn('frame.get("payload", null)', payload_loader)
        self.assertIn('frame["payload"]', payload_loader)
        # The driver feeds the live gate to the machinery: the
        # gate call takes only the frame -- it does NOT take
        # enabled, and the driver does not AND enabled into the
        # gate result (the outer tick guard already runs the
        # machinery only when enabled).
        self.assertIn('static func source_payload_loader_tick_buildings_state', payload_loader)
        self.assertIn('source_payload_loader_should_consume_state(frame)', payload_loader)
        self.assertIn('bool(gate.get("should_consume", true))', payload_loader)
        # The documented limits record the gate as live; the old
        # N2162 deferral text is gone. The N2162 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2208)', payload_loader)
        self.assertNotIn('runs with should_consume=true when enabled', payload_loader)
        self.assertNotIn('payload state is not tracked yet', payload_loader)
        self.assertIn('static func source_payload_loader_power_status_row_state', payload_loader)
        # The proof's keys drive the pure gate (true with a
        # payload, false without one, INDEPENDENT of enabled --
        # the no-enabled point) plus the live tick (efficiency 0
        # when the gate is false, the N2162 power fold preserved
        # when the gate is true) and the def (payload-loader
        # consumePower 2f / size 3). There are no load / export /
        # battery keys: the updateTile advance
        # (PayloadLoader.java:143-220) waits for its own slice,
        # so the load gate (PayloadLoader.java:157) is what the
        # efficiency keys prove. Static checks: the proof
        # preloads the payload-loader state file that exists,
        # and the scene file references the proof script that
        # exists.
        proof = PAYLOAD_LOADER_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_with_payload',
            'gate_false_without_payload',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'def_payload_loader_consume_power_two_size_three',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourcePayloadLoaderBuildState.gd")', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_should_consume_state(', proof)
        self.assertIn('payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(PAYLOAD_LOADER_STATE.is_file())
        scene = PAYLOAD_LOADER_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PayloadLoaderShouldConsumeProof.gd', scene)
        self.assertTrue(PAYLOAD_LOADER_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_payload_loader_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadLoaderShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_LOADER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_with_payload',
            'gate_false_without_payload',
            'gate_ignores_enabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'def_payload_loader_consume_power_two_size_three',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
