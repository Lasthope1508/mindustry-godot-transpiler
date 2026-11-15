import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_ASSEMBLER_MODULE_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitAssemblerModuleBuildState.gd'
UNIT_ASSEMBLER_MODULE_ACCEPT_PAYLOAD_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleAcceptPayloadProof.gd'
UNIT_ASSEMBLER_MODULE_ACCEPT_PAYLOAD_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleAcceptPayloadProof.tscn'
UNIT_ASSEMBLER_MODULE_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'
UNIT_ASSEMBLER_JAVA = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
MODULE_OWNER = 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_module_accept_payload_state'
ASSEMBLER_OWNER = 'SourceUnitAssemblerModuleBuildState.source_unit_assembler_accept_payload_state'


class C07UnitAssemblerModuleAcceptPayloadTests(unittest.TestCase):
    def test_c07_unit_assembler_module_accept_payload_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2299']['godot_owner'], MODULE_OWNER)
        # N2248 proved the updateTile advance (lastChange refresh
        # + findLink re-discovery + moveInPayload + the handoff
        # gate) -- but the handoff gate's acceptPayload term
        # (UnitAssemblerModule.java:138) was an explicit frame
        # predicate, never evaluated: no slice had ported the
        # module's acceptPayload gate (UnitAssemblerModule.java:
        # 110-111, `return link != null && this.payload == null
        # && link.acceptPayload(this, payload);`) or the link
        # assembler's gate it delegates to (UnitAssembler.java:
        # 722-727). N2299 ports both as two pures. The module
        # gate: link present && own payload empty && link
        # accepts. The assembler gate: (assembler payload empty
        # OR source is a module) AND the plan has a requirement
        # for the payload's content item AND the assembler's
        # stored count of that item is below round(amount *
        # unitCost) minus 1 when the source is a module AND the
        # assembler already holds an equal payload (the -1
        # accounts for the in-flight payload). Nine new result
        # symbols: four for the module gate (the verdict plus
        # its three terms) and five for the assembler gate (the
        # verdict, requirement found, quota, stored count, and
        # the module-source adjustment).
        self.assertEqual(
            ledger['N2299']['source_symbols'],
            [
                'source_unit_assembler_module_accept_payload_state_result.accepts',
                'source_unit_assembler_module_accept_payload_state_result.has_link',
                'source_unit_assembler_module_accept_payload_state_result.has_payload',
                'source_unit_assembler_module_accept_payload_state_result.link_accepts',
                'source_unit_assembler_accept_payload_state_result.accepts',
                'source_unit_assembler_accept_payload_state_result.requirement_found',
                'source_unit_assembler_accept_payload_state_result.quota',
                'source_unit_assembler_accept_payload_state_result.stored_count',
                'source_unit_assembler_accept_payload_state_result.module_adjustment',
            ],
        )
        for name in ledger['N2299']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                if name.startswith('source_unit_assembler_module_accept_payload_state_result.'):
                    self.assertEqual(symbol['java_source'], UNIT_ASSEMBLER_MODULE_JAVA)
                    self.assertEqual(symbol['godot_owner'], MODULE_OWNER)
                else:
                    self.assertEqual(symbol['java_source'], UNIT_ASSEMBLER_JAVA)
                    self.assertEqual(symbol['godot_owner'], ASSEMBLER_OWNER)
        self.assertEqual(ledger['N2299']['runtime_proof'], '/root/C07UnitAssemblerModuleAcceptPayloadProof')
        self.assertEqual(
            ledger['N2299']['tests'],
            [
                'test_c07_unit_assembler_module_accept_payload_registration',
                'test_all_c07_unit_assembler_module_accept_payload_input_evidence_is_exact',
                'test_unit_assembler_module_accept_payload_state',
                'test_reference_graph_and_actual_c07_unit_assembler_module_accept_payload',
            ],
        )
        self.assertTrue(ledger['N2299']['deferred_exprs'])
        # This slice resolves DEFERRED entry 51 (the
        # UnitAssemblerModule acceptPayload rows -- the entry
        # cited :125-127, inside onRemoved, and a payloads/
        # path; the real gate is UnitAssemblerModule.java:
        # 110-111 in world/blocks/units/). It adds the
        # acceptPayload live fill and the handoff-gate wiring
        # deferrals, and rewords the N2248 updateTile live-fill
        # entry (acceptPayload evaluation is live since N2299;
        # moduleFits / wasOccupied still wait). DEFERRED goes
        # 321 - 1 removed + 2 added = 322 entries.
        self.assertEqual(len(ledger['N2299']['deferred_exprs']), 322)
        self.assertFalse(any(entry.startswith('UnitAssemblerModule acceptPayload rows (') for entry in ledger['N2299']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule acceptPayload live fill (') for entry in ledger['N2299']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule handoff-gate acceptPayload wiring (') for entry in ledger['N2299']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitAssemblerModule updateTile live fill (') and 'acceptPayload evaluation is live since N2299' in entry for entry in ledger['N2299']['deferred_exprs']))

    def test_all_c07_unit_assembler_module_accept_payload_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2299']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                if name.startswith('source_unit_assembler_module_accept_payload_state_result.'):
                    self.assertEqual(symbol['godot_owner'], MODULE_OWNER)
                else:
                    self.assertEqual(symbol['godot_owner'], ASSEMBLER_OWNER)
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssemblerModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/units/UnitAssembler.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/Payload.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/payloads/BuildPayload.java'),
            ('mindustry-upstream', 'core/src/mindustry/type/PayloadSeq.java'),
            ('mindustry-upstream', 'core/src/mindustry/type/PayloadStack.java'),
            ('mindustry-upstream', 'core/src/mindustry/game/Rules.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Mathf.java'),
            ('arc-upstream', 'arc-core/src/arc/struct/ObjectIntMap.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2299']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_assembler_module_accept_payload_state(self):
        unit_assembler_module = UNIT_ASSEMBLER_MODULE_STATE.read_text(encoding='utf-8')
        # The module gate (UnitAssemblerModuleBuild.
        # acceptPayload(), UnitAssemblerModule.java:110-111):
        # `return link != null && this.payload == null &&
        # link.acceptPayload(this, payload);` -- the file is in
        # world/blocks/units/, NOT payloads/, and :110-111 is
        # the gate (the DEFERRED entry's :125-127 cite is
        # inside onRemoved). The link gate (UnitAssemblerBuild.
        # acceptPayload(), UnitAssembler.java:722-727): `var
        # plan = plan();` (plan() is :383-386, `return plans.
        # get(Math.min(currentTier, plans.size - 1));`, the
        # current unit plan with its requirements Seq<
        # PayloadStack>, :278) then the two-term return: the
        # payload-empty-or-module-source term plus the plan
        # requirement + stored-count term with the module-source
        # -1 adjustment. plan.requirements.contains takes the
        # FIRST matching requirement's quota for the reported
        # quota key, but the verdict is Java-exact any-match:
        # the pure accepts when ANY matching requirement's
        # count check passes (plans carry one stack per content
        # in every def, so the two agree in practice).
        # PayloadStack.amount is an int (PayloadStack.java:9,
        # `public int amount = 1;`), so the quota is
        # round(amount * unitCost) with unitCost the rules
        # multiplier (Rules.java:275-277, `return
        # unitCostMultiplier * teams.get(team).
        # unitCostMultiplier;`, both factors default 1f, so the
        # frame input defaults 1.0). Mathf.round is arc's
        # BIG_ENOUGH trick (Mathf.java:500-501, `return (int)(
        # value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;` with
        # BIG_ENOUGH_ROUND = 16*1024 + 0.5f, i.e. floor(x +
        # 0.5) -- NOT Java Math.round, though the two agree on
        # non-negative values); the port uses roundi, which
        # matches on this non-negative domain (amount >= 0,
        # unit_cost >= 0): roundi(2.5) == 3. The stored count
        # is blocks.get(content) (PayloadSeq.java:66-68,
        # delegating to ObjectIntMap.get, which returns 0 for a
        # missing key, ObjectIntMap.java:285-286) -- an unknown
        # count is 0, which ACCEPTS when a requirement exists
        # (an empty blocks map means nothing stored yet, so the
        # count check passes). contentEquals is the Payload
        # interface method (Payload.java:39) with the build
        # comparison for BuildPayload (BuildPayload.java:43).
        # Keep each Java expr on ONE comment line (the N2148
        # shootWarmup lesson: a split line fails this test).
        self.assertIn('static func source_unit_assembler_module_accept_payload_state(has_link: bool, has_payload: bool, link_accepts: bool) -> Dictionary', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_accept_payload_state(payload: Dictionary, assembler: Dictionary, plan_requirements: Array, unit_cost: float, source_is_module: bool) -> Dictionary', unit_assembler_module)
        self.assertIn('public boolean acceptPayload(Building source, Payload payload){', unit_assembler_module)
        self.assertIn('return link != null && this.payload == null && link.acceptPayload(this, payload);', unit_assembler_module)
        self.assertIn('var plan = plan();', unit_assembler_module)
        self.assertIn('return (this.payload == null || (source instanceof UnitAssemblerModuleBuild)) &&', unit_assembler_module)
        self.assertIn('plan.requirements.contains(b -> b.item == payload.content() &&', unit_assembler_module)
        self.assertIn('blocks.get(payload.content()) < Mathf.round(b.amount * state.rules.unitCost(team)) -', unit_assembler_module)
        self.assertIn('(source instanceof UnitAssemblerModuleBuild && (this.payload != null && this.payload.contentEquals(payload)) ? 1 : 0));', unit_assembler_module)
        self.assertIn('return plans.get(Math.min(currentTier, plans.size - 1));', unit_assembler_module)
        self.assertIn('public PayloadSeq blocks = new PayloadSeq();', unit_assembler_module)
        self.assertIn('public int get(UnlockableContent block){', unit_assembler_module)
        self.assertIn('return get(key, 0);', unit_assembler_module)
        self.assertIn('return unitCostMultiplier * teams.get(team).unitCostMultiplier;', unit_assembler_module)
        self.assertIn('return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;', unit_assembler_module)
        self.assertIn('public int amount = 1;', unit_assembler_module)
        self.assertIn('boolean contentEquals(Payload other);', unit_assembler_module)
        self.assertIn('return other instanceof BuildPayload bp && bp.block() == build.block;', unit_assembler_module)
        self.assertIn('public @Nullable T payload;', unit_assembler_module)
        self.assertIn('public UnitAssemblerBuild link;', unit_assembler_module)
        self.assertIn('roundi(2.5) == 3', unit_assembler_module)
        self.assertIn('roundi(', unit_assembler_module)
        # The driver wires both verdicts into the live tick
        # from frame-supplied plan/blocks/payload inputs: the
        # offered payload descriptor (default {} -- no payload
        # offered, so the link verdict is false), the assembler
        # dict (default {} -- no link assembler state), the
        # plan requirements (default [] -- no plan), and the
        # unit-cost multiplier (default 1.0). The source IS the
        # module itself (the module gate calls link.
        # acceptPayload(this, payload)), so source_is_module is
        # true. No link means the module verdict is false. The
        # verdicts are EXPOSED on the frame only -- the N2248
        # handoff gate still reads the frame-input
        # accept_payload predicate (wiring the live verdict
        # into the gate waits for its own slice).
        self.assertIn('frame.get("offered_payload", {})', unit_assembler_module)
        self.assertIn('frame.get("assembler", {})', unit_assembler_module)
        self.assertIn('frame.get("plan_requirements", [])', unit_assembler_module)
        self.assertIn('frame.get("unit_cost", 1.0)', unit_assembler_module)
        self.assertIn('source_unit_assembler_accept_payload_state(offered_payload, assembler_state, plan_requirements, unit_cost, true)', unit_assembler_module)
        self.assertIn('frame["accepts_payload"]', unit_assembler_module)
        self.assertIn('frame["link_accepts_payload"]', unit_assembler_module)
        # The N2248 link/handoff wiring is untouched: the
        # advance, the power row, and the frame-input
        # accept_payload predicate all stay as they were.
        self.assertIn('static func source_unit_assembler_module_update_tile_advance_state', unit_assembler_module)
        self.assertIn('static func source_unit_assembler_module_power_status_row_state', unit_assembler_module)
        self.assertIn('frame.get("accept_payload", false)', unit_assembler_module)
        self.assertIn('updateTile advance live (N2248)', unit_assembler_module)
        # The documented limits now record acceptPayload as
        # live (N2299) instead of listing it among the missing
        # rows.
        self.assertIn('acceptPayload rows live (N2299)', unit_assembler_module)
        self.assertNotIn('No link/tier/canPlaceOn/draw/acceptPayload/onRemoved rows', unit_assembler_module)
        # The proof's keys drive both pures (the module
        # accepts when linked, empty, and the link accepts;
        # the module rejects when unlinked; the assembler
        # accepts below quota; the assembler rejects at quota;
        # the module-source -1 adjustment) plus the live tick
        # (a placed basic-assembler-module with a seeded
        # offered payload + link assembler + plan exposes both
        # verdicts on the frame).
        proof = UNIT_ASSEMBLER_MODULE_ACCEPT_PAYLOAD_PROOF.read_text(encoding='utf-8')
        for key in [
            'module_accepts_when_linked_empty_link_accepts',
            'module_rejects_when_unlinked',
            'assembler_accepts_below_quota',
            'assembler_rejects_at_quota',
            'module_source_minus_one_adjustment',
            'live_tick_exposes_both_verdicts',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")', proof)
        self.assertTrue(UNIT_ASSEMBLER_MODULE_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = UNIT_ASSEMBLER_MODULE_ACCEPT_PAYLOAD_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07UnitAssemblerModuleAcceptPayloadProof.gd', scene)
        self.assertIn('C07UnitAssemblerModuleAcceptPayloadProof', scene)

    def test_reference_graph_and_actual_c07_unit_assembler_module_accept_payload(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitAssemblerModuleAcceptPayloadProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_ASSEMBLER_MODULE_ACCEPT_PAYLOAD_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'module_accepts_when_linked_empty_link_accepts',
            'module_rejects_when_unlinked',
            'assembler_accepts_below_quota',
            'assembler_rejects_at_quota',
            'module_source_minus_one_adjustment',
            'live_tick_exposes_both_verdicts',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
