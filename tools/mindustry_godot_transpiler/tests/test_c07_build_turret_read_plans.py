import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_READ_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretReadPlansProof.gd'


class C07BuildTurretReadPlansTests(unittest.TestCase):
    def test_c07_build_turret_read_plans_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2429']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_read_plans_state')
        # BuildTurretBuild.read() (BuildTurret.java:266-278,
        # `public void read(Reads read, byte revision){`)
        # restores the builder unit's plans after
        # `TypeIO.readPlans(read)` (:272, owned at N2184):
        # the null-guard + restore loop (:273-275) is this
        # slice -- ONLY these 3 exprs:
        # `if(reqs != null){` (:273)
        # `for(var req : reqs){` (:274)
        # `unit.plans().add(req);` (:275)
        # NOT this slice: `super.read(read, revision);`
        # (:268, generic, owned in many slices),
        # `rotation = read.f();` (:269, N2184),
        # `unit.rotation(rotation);` (:270, N2184),
        # `unit.plans().clear();` (:271, N2184 -- do not
        # confuse with `:275` `unit.plans().add(req);`),
        # `var reqs = TypeIO.readPlans(read);` (:272,
        # N2184). The 3 exprs were 0-hit in both ledgers
        # at RED (exact + strip + normalize), and
        # `java_method` BuildTurretBuild.read(Reads, byte)
        # is 0-hit in both. One pure function on
        # SourceBuildTurretBuildState.gd (the BuildTurret
        # file, static func -- the N2184/N2201/N2423/N2426
        # convention for this file, NOT PortGame.*).
        # `reqs` is the caller-side Array (TypeIO.readPlans
        # already ran at N2184); `reqs_null` is the
        # explicit bool for `reqs != null`.
        self.assertEqual(
            ledger['N2429']['java_method'],
            'BuildTurretBuild.read(Reads, byte)',
        )
        self.assertEqual(
            ledger['N2429']['source_symbols'],
            [
                'source_build_turret_read_plans_state_result.plans_to_add',
            ],
        )
        for name in ledger['N2429']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2429']['runtime_proof'], '/root/C07BuildTurretReadPlansProof')
        self.assertEqual(
            ledger['N2429']['tests'],
            [
                'test_c07_build_turret_read_plans_registration',
                'test_all_c07_build_turret_read_plans_input_evidence_is_exact',
                'test_build_turret_read_plans_state',
                'test_reference_graph_and_actual_c07_build_turret_read_plans',
            ],
        )
        self.assertTrue(ledger['N2429']['deferred_exprs'])

    def test_all_c07_build_turret_read_plans_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2429']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2429']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_read_plans_state(self):
        state = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # BuildTurretBuild.read() plans restore
        # (BuildTurret.java:266-278): one pure function
        # over the caller-side reqs Array + reqs_null
        # bool -- null adds nothing, otherwise every req
        # is appended in order (duplicates kept, like
        # Java's `unit.plans().add(req);` in the loop).
        # No engine calls; read() runs once per load, not
        # per-tick.
        self.assertIn('static func source_build_turret_read_plans_state(reqs_null: bool, reqs: Array) -> Dictionary:', state)
        for expr in [
            'if(reqs != null){',
            'for(var req : reqs){',
            'unit.plans().add(req);',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # fixtures (no live tick).
        proof = BUILD_TURRET_READ_PROOF.read_text(encoding='utf-8')
        for key in [
            'null_reqs_adds_nothing',
            'null_reqs_ignores_reqs',
            'empty_reqs_adds_nothing',
            'single_req_restored',
            'multiple_reqs_restored_in_order',
            'duplicate_reqs_kept',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_read_plans(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretReadPlansProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_READ_PLANS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'null_reqs_adds_nothing',
            'null_reqs_ignores_reqs',
            'empty_reqs_adds_nothing',
            'single_req_restored',
            'multiple_reqs_restored_in_order',
            'duplicate_reqs_kept',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
