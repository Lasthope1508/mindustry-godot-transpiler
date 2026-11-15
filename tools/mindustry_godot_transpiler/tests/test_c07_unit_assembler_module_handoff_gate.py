import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
UNIT_ASSEMBLER_MODULE_HANDOFF_GATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleHandoffGateProof.gd'
UNIT_ASSEMBLER_MODULE_HANDOFF_GATE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleHandoffGateProof.tscn'
UNIT_ASSEMBLER_MODULE_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'
UNIT_ASSEMBLER_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
LINK_OWNER = 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_accept_payload_state'


class C07UnitAssemblerModuleHandoffGateTests(unittest.TestCase):
    def test_c07_unit_assembler_module_handoff_gate_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2314']['godot_owner'], LINK_OWNER)
        # The N2248 handoff gate (UnitAssemblerModule.java:138)
        # read frame["accept_payload"] as an explicit predicate
        # input, while the N2299 tick exposed both acceptPayload
        # verdicts (frame["accepts_payload"] module gate,
        # frame["link_accepts_payload"] link gate) without
        # feeding either into the gate. N2314 is wiring only
        # (the N2308 precedent): no new pure, no new symbols --
        # the tick evaluates the LINK verdict before the
        # advance and stamps frame["accept_payload"] from it,
        # so the advance (signature and call unchanged) reads
        # the live verdict. The LINK verdict is the right one:
        # Java is `link.acceptPayload(this, payload)` (the
        # assembler's gate, UnitAssembler.java:722-727, ported
        # as source_unit_assembler_accept_payload_state), NOT
        # the module's own gate (UnitAssemblerModule.java:
        # 110-111). The ledger entry references the reused
        # link pure's five result symbols (shared ownership is
        # allowed -- the registry already carries symbols
        # claimed by more than one slice).
        self.assertEqual(
            ledger['N2314']['source_symbols'],
            [
                'source_unit_assembler_accept_payload_state_result.accepts',
                'source_unit_assembler_accept_payload_state_result.requirement_found',
                'source_unit_assembler_accept_payload_state_result.quota',
                'source_unit_assembler_accept_payload_state_result.stored_count',
                'source_unit_assembler_accept_payload_state_result.module_adjustment',
            ],
        )
        for name in ledger['N2314']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], UNIT_ASSEMBLER_JAVA)
                self.assertEqual(symbol['godot_owner'], LINK_OWNER)
        self.assertEqual(ledger['N2314']['runtime_proof'], '/root/C07UnitAssemblerModuleHandoffGateProof')
        self.assertEqual(
            ledger['N2314']['tests'],
            [
                'test_c07_unit_assembler_module_handoff_gate_registration',
                'test_all_c07_unit_assembler_module_handoff_gate_input_evidence_is_exact',
                'test_unit_assembler_module_handoff_gate_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_handoff_gate',
            ],
        )
        self.assertTrue(ledger['N2314']['deferred_exprs'])
        # This slice resolves DEFERRED entry #318 (the
        # UnitAssemblerModule handoff-gate acceptPayload
        # wiring) and adds no new deferral: the offered /
        # assembler / plan inputs are still frame inputs
        # (the N2299 live-fill entry stays), module_fits /
        # was_occupied stay frame inputs (separate entries),
        # and the handoff-to-intake wiring (#236) is a
        # different slice. DEFERRED goes 325 - 1 = 324.
        self.assertEqual(len(ledger['N2314']['deferred_exprs']), 324)
        self.assertFalse(any(entry.startswith('UnitAssemblerModule handoff-gate acceptPayload wiring (') for entry in ledger['N2314']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule acceptPayload live fill (') for entry in ledger['N2314']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule handoff-to-intake wiring (') for entry in ledger['N2314']['deferred_exprs']))

    def test_all_c07_unit_assembler_module_handoff_gate_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2314']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], LINK_OWNER)
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssembler.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2314']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_handoff_gate_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The handoff gate (UnitAssemblerModuleBuild.
        # updateTile(), UnitAssemblerModule.java:137-139):
        # `if(moveInPayload() && link != null &&
        # link.moduleFits(block, x, y, rotation) &&
        # !link.wasOccupied && link.acceptPayload(this,
        # payload) && efficiency > 0){` -- the acceptPayload
        # term is the LINK assembler's gate
        # (UnitAssemblerBuild.acceptPayload(),
        # UnitAssembler.java:722-727, `var plan = plan();`
        # then the payload-empty-or-module-source term plus
        # the plan requirement + stored-count term with the
        # module-source -1 adjustment), NOT the module's own
        # gate (UnitAssemblerModule.java:110-111, `return
        # link != null && this.payload == null &&
        # link.acceptPayload(this, payload);`). Keep each
        # Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        self.assertIn('if(moveInPayload() && link != null && link.moduleFits(block, x, y, rotation) && !link.wasOccupied && link.acceptPayload(this, payload) && efficiency > 0){', unit_assembler_module)
        self.assertIn('return link != null && this.payload == null && link.acceptPayload(this, payload);', unit_assembler_module)
        self.assertIn('var plan = plan();', unit_assembler_module)
        self.assertIn('return (this.payload == null || (source instanceof UnitAssemblerModuleBuild)) &&', unit_assembler_module)
        self.assertIn('plan.requirements.contains(b -> b.item == payload.content() &&', unit_assembler_module)
        self.assertIn('blocks.get(payload.content()) < Mathf.round(b.amount * state.rules.unitCost(team)) -', unit_assembler_module)
        self.assertIn('(source instanceof UnitAssemblerModuleBuild && (this.payload != null && this.payload.contentEquals(payload)) ? 1 : 0));', unit_assembler_module)
        self.assertIn('link.yeetPayload(payload);', unit_assembler_module)
        # The wiring (N2314): the tick evaluates the LINK
        # verdict BEFORE the advance and stamps
        # frame["accept_payload"] from it (the frame-stamp +
        # frame-fallback pattern, the N2235 precedent) -- the
        # advance keeps reading frame["accept_payload"], its
        # signature and call site unchanged. The N2299
        # tick-call string is preserved verbatim (the N2304
        # lesson: the N2299 test pins it), and the module
        # verdict still evaluates AFTER the advance, from the
        # post-advance link / payload. The stamp OVERWRITES
        # any seeded frame input: a stale accept_payload
        # seed no longer drives the gate (the N2248 proof
        # fixture seeds the offer + assembler + plan
        # instead). module_fits / was_occupied stay frame
        # inputs (separate DEFERRED entries).
        self.assertIn('source_unit_assembler_accept_payload_state(offered_payload, assembler_state, plan_requirements, unit_cost, true)', unit_assembler_module)
        self.assertIn('frame.get("offered_payload", {})', unit_assembler_module)
        self.assertIn('frame.get("assembler", {})', unit_assembler_module)
        self.assertIn('frame.get("plan_requirements", [])', unit_assembler_module)
        self.assertIn('frame.get("unit_cost", 1.0)', unit_assembler_module)
        self.assertIn('frame["link_accepts_payload"] = link_verdict["accepts"]', unit_assembler_module)
        self.assertIn('frame["accept_payload"] = link_verdict["accepts"]', unit_assembler_module)
        link_call = unit_assembler_module.index('source_unit_assembler_accept_payload_state(offered_payload, assembler_state, plan_requirements, unit_cost, true)')
        advance_call = unit_assembler_module.index('source_unit_assembler_module_update_tile_advance_state(frame, source_delta, time_scale)')
        module_call = unit_assembler_module.index('source_unit_assembler_module_accept_payload_state(frame.get("link", null) != null, frame.get("payload", null) != null, bool(link_verdict.get("accepts", false)))')
        self.assertLess(link_call, advance_call)
        self.assertLess(advance_call, module_call)
        self.assertIn('frame["accepts_payload"] = module_verdict["accepts"]', unit_assembler_module)
        # The advance is untouched: it still reads the
        # accept_payload predicate (now live-stamped) plus
        # the module_fits / was_occupied frame inputs.
        self.assertIn('static func source_unit_assembler_module_update_tile_advance_state(frame: Dictionary, source_delta: float, time_scale: float) -> Dictionary', unit_assembler_module)
        self.assertIn('frame.get("accept_payload", false)', unit_assembler_module)
        self.assertIn('frame.get("module_fits", false)', unit_assembler_module)
        self.assertIn('frame.get("was_occupied", false)', unit_assembler_module)
        # The documented limits now record the handoff gate
        # as wired (N2314); the N2299 acceptPayload rows,
        # the N2248 advance and the N2168 power row stay.
        self.assertIn('Handoff-gate wiring live (N2314)', unit_assembler_module)
        self.assertIn('acceptPayload rows live (N2299)', unit_assembler_module)
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_power_status_row_state', unit_assembler_module)
        # The proof's keys drive the live tick through the
        # gate: fires when the link accepts, blocked when
        # the link rejects (at quota), blocked without a
        # link (verdict true but no link), the live tick
        # wires the gate (a stale accept_payload=false seed
        # is overwritten by the true verdict and the
        # handoff fires), the module verdict does NOT drive
        # the gate (the module gate on the pre-tick state
        # is false -- the module holds a payload -- yet the
        # handoff fires on the link verdict), and blocked
        # when efficiency is zero (verdict true, power 0).
        proof = UNIT_ASSEMBLER_MODULE_HANDOFF_GATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'handoff_fires_when_link_accepts',
            'handoff_blocked_when_link_rejects',
            'handoff_blocked_without_link',
            'live_tick_wires_the_gate',
            'module_verdict_does_not_drive_gate',
            'handoff_blocked_when_efficiency_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertIn('unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = UNIT_ASSEMBLER_MODULE_HANDOFF_GATE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerModuleHandoffGateProof.gd', scene)
        self.assertIn('C07UnitAssemblerModuleHandoffGateProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_module_handoff_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleHandoffGateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_HANDOFF_GATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'handoff_fires_when_link_accepts',
            'handoff_blocked_when_link_rejects',
            'handoff_blocked_without_link',
            'live_tick_wires_the_gate',
            'module_verdict_does_not_drive_gate',
            'handoff_blocked_when_efficiency_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
