import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
REGISTRY_JSON = ROOT / 'godot-mindustry/src/generated/content_registry.json'
TURRET_CAN_CONSUME_HEAT_GATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretCanConsumeHeatGateProof.gd'


class C07TurretCanConsumeHeatGateTests(unittest.TestCase):
    def test_c07_turret_can_consume_heat_gate_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2272']['godot_owner'], 'SourceTurretBuildState.source_turret_can_consume_heat_gate_state')
        # N2270 pinned only the heat fold: when a turret needs
        # heat, updateEfficiencyMultiplier() scales efficiency
        # by heatReq / heatRequirement -- but the fold never
        # gates consumption: an unheated afflict / malign folds
        # efficiency to 0 and still consumes. The gate itself is
        # TurretBuild.canConsume() (Turret.java:623-629):
        # `public boolean canConsume(){`
        # `if(heatRequirement > 0 && heatReq <= 0f){`
        # `return false;`
        # `}`
        # `return super.canConsume();`
        # `}`
        # `heatRequirement` defaults to -1 (Turret.java:52-53,
        # `/** Minimum input heat required to fire. */ public
        # float heatRequirement = -1f;`) and `heatReq` is the
        # live per-build field (Turret.java:295, `public float
        # heatReq;`), recomputed by calculateHeat -- which stays
        # BLOCKED (live proximity scan, BuildingComp.java:
        # 410-461), so this slice models the gate purely and
        # takes heat_req as a live input parameter. Only
        # afflict (`heatRequirement = 20f;`, Blocks.java:5122)
        # and malign (`heatRequirement = 144f;`,
        # Blocks.java:6240) set a positive requirement among
        # turrets -- the other Blocks.java setters (surge
        # crucible, cyanogen / phase synthesizer) are
        # HeatCrafter blocks, not turrets. Every other turret
        # reads the -1 default, so the gate passes through
        # super.canConsume() unchanged. One new result symbol:
        # can_consume.
        self.assertEqual(
            ledger['N2272']['source_symbols'],
            [
                'source_turret_can_consume_heat_gate_state_result.can_consume',
            ],
        )
        for name in ledger['N2272']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_can_consume_heat_gate_state_result.can_consume': 'SourceTurretBuildState.source_turret_can_consume_heat_gate_state',
                }[name])
        self.assertEqual(ledger['N2272']['runtime_proof'], '/root/C07TurretCanConsumeHeatGateProof')
        self.assertEqual(
            ledger['N2272']['tests'],
            [
                'test_c07_turret_can_consume_heat_gate_registration',
                'test_all_c07_turret_can_consume_heat_gate_input_evidence_is_exact',
                'test_turret_can_consume_heat_gate',
                'test_reference_graph_and_actual_c07_turret_can_consume_heat_gate',
            ],
        )
        self.assertTrue(ledger['N2272']['deferred_exprs'])

    def test_all_c07_turret_can_consume_heat_gate_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2272']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_can_consume_heat_gate_state_result.can_consume': 'SourceTurretBuildState.source_turret_can_consume_heat_gate_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2272']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_can_consume_heat_gate(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the shared TurretBuild driver
        # file (SourceTurretBuildState.gd), after
        # source_turret_charge_sound_state and before the tick
        # driver, following the N2268/N2269/N2271 event-driven
        # pattern (no driver tick: canConsume() is evaluated
        # per consumption check, not per tick, and the driver
        # has no shouldConsume gate yet -- the N2270 handoff
        # records exactly that). The function takes the catalog
        # heat requirement (the N2270 read, -1 when the turret
        # does not use heat), the live heat_req input (the
        # calculateHeat field, Turret.java:295) and the
        # super.canConsume() result passed in, and returns the
        # 1-key dict `{"can_consume": ..}`: false exactly when
        # heat_requirement > 0 and heat_req <= 0 (the :625
        # guard), super_can_consume otherwise (the :628
        # pass-through).
        self.assertIn('static func source_turret_can_consume_heat_gate_state(heat_requirement: float, heat_req: float, super_can_consume: bool) -> Dictionary:', turret)
        self.assertIn('return {"can_consume": can_consume}', turret)
        self.assertIn('public float heatRequirement = -1f;', turret)
        self.assertIn('public float heatReq;', turret)
        self.assertIn('if(heatRequirement > 0 && heatReq <= 0f){', turret)
        self.assertIn('return super.canConsume();', turret)
        # The catalog already carries the real values from
        # N2270 -- no extractor change in this slice: afflict
        # 20.0, malign 144.0, duo carries no key (the -1
        # default).
        registry = json.loads(REGISTRY_JSON.read_text(encoding='utf-8'))
        by_id = {block['id']: block for block in registry['blocks']}
        self.assertEqual(by_id['afflict']['properties'].get('heatRequirement'), 20.0)
        self.assertEqual(by_id['malign']['properties'].get('heatRequirement'), 144.0)
        self.assertIsNone(by_id['duo']['properties'].get('heatRequirement'))
        # The proof's keys drive the catalog values (afflict /
        # malign / duo default), the gate closed / open for
        # afflict and malign, the duo pass-through for both
        # super values, the super-false block even when heated,
        # and the negative-heat_req boundary.
        proof = TURRET_CAN_CONSUME_HEAT_GATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'catalog_afflict_20',
            'catalog_malign_144',
            'catalog_duo_default_neg1',
            'gate_closed_afflict_no_heat',
            'gate_open_afflict_heated',
            'gate_closed_malign_no_heat',
            'gate_open_malign_heated',
            'gate_passthrough_duo_super_true',
            'gate_passthrough_duo_super_false',
            'gate_super_false_blocks_heated',
            'gate_negative_heat_req_closed',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_can_consume_heat_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretCanConsumeHeatGateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CAN_CONSUME_HEAT_GATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'catalog_afflict_20',
            'catalog_malign_144',
            'catalog_duo_default_neg1',
            'gate_closed_afflict_no_heat',
            'gate_open_afflict_heated',
            'gate_closed_malign_no_heat',
            'gate_open_malign_heated',
            'gate_passthrough_duo_super_true',
            'gate_passthrough_duo_super_false',
            'gate_super_false_blocks_heated',
            'gate_negative_heat_req_closed',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
