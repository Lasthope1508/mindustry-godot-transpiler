import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceBuildTurretBuildState.gd'
BUILD_TURRET_INIT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BuildTurretInitUnitTypeProof.gd'


class C07BuildTurretInitUnitTypeTests(unittest.TestCase):
    def test_c07_build_turret_init_unit_type_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2426']['godot_owner'], 'SourceBuildTurretBuildState.source_build_turret_init_unit_type_state')
        # BuildTurret.init() (BuildTurret.java:50-69,
        # `public void init(){`) -- the anonymous UnitType
        # `unitType = new UnitType("turret-unit-" + name){{`
        # (:56) -- this slice is ONLY the 6 UnitType field
        # lines (:57-61, :63):
        # `hidden = true;` (:57)
        # `internal = true;` (:58)
        # `speed = 0f;` (:59)
        # `hitSize = 0f;` (:60)
        # `health = 1;` (:61)
        # `rotateSpeed = BuildTurret.this.rotateSpeed;` (:63)
        # NOT this slice: `if(elevation < 0) elevation =
        # size / 2f;` (:53, already owned), `itemCapacity
        # = 0;` (:62, already owned), `buildBeamOffset =
        # BuildTurret.this.buildBeamOffset;` /
        # `buildRange = BuildTurret.this.range;` /
        # `buildSpeed = BuildTurret.this.buildSpeed;` /
        # `constructor = BlockUnitUnit::create;` (:64-67,
        # already owned at N2184), the opener :56 and the
        # `}};` closer :68 (generic). The 6 exprs were
        # 0-hit in both ledgers at RED (exact + strip +
        # normalize), and `java_method` BuildTurret.init()
        # is 0-hit in both. One pure function on
        # SourceBuildTurretBuildState.gd (the BuildTurret
        # file, static func -- the N2184/N2201/N2423
        # convention for this file, NOT PortGame.*). The
        # block's rotateSpeed is a param: the constructor
        # default is `rotateSpeed = 10f;`
        # (BuildTurret.java:45), but the init line reads
        # the live block field, so the caller passes it.
        self.assertEqual(
            ledger['N2426']['java_method'],
            'BuildTurret.init()',
        )
        self.assertEqual(
            ledger['N2426']['source_symbols'],
            [
                'source_build_turret_init_unit_type_state_result.hidden',
                'source_build_turret_init_unit_type_state_result.internal',
                'source_build_turret_init_unit_type_state_result.speed',
                'source_build_turret_init_unit_type_state_result.hit_size',
                'source_build_turret_init_unit_type_state_result.health',
                'source_build_turret_init_unit_type_state_result.rotate_speed',
            ],
        )
        for name in ledger['N2426']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2426']['runtime_proof'], '/root/C07BuildTurretInitUnitTypeProof')
        self.assertEqual(
            ledger['N2426']['tests'],
            [
                'test_c07_build_turret_init_unit_type_registration',
                'test_all_c07_build_turret_init_unit_type_input_evidence_is_exact',
                'test_build_turret_init_unit_type_state',
                'test_reference_graph_and_actual_c07_build_turret_init_unit_type',
            ],
        )
        self.assertTrue(ledger['N2426']['deferred_exprs'])

    def test_all_c07_build_turret_init_unit_type_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2426']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBuildTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BuildTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2426']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_build_turret_init_unit_type_state(self):
        state = BUILD_TURRET_STATE.read_text(encoding='utf-8')
        # BuildTurret.init() UnitType fields
        # (BuildTurret.java:50-69): one pure function over
        # the block's rotateSpeed -- the 5 other fields are
        # constants taken from the Java lines. No engine
        # calls; init() runs once at block init, not
        # per-tick.
        self.assertIn('static func source_build_turret_init_unit_type_state(rotate_speed: float) -> Dictionary:', state)
        for expr in [
            'hidden = true;',
            'internal = true;',
            'speed = 0f;',
            'hitSize = 0f;',
            'health = 1;',
            'rotateSpeed = BuildTurret.this.rotateSpeed;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive the pure function with
        # fixtures (no live tick).
        proof = BUILD_TURRET_INIT_PROOF.read_text(encoding='utf-8')
        for key in [
            'hidden_true',
            'internal_true',
            'speed_zero',
            'hit_size_zero',
            'health_one',
            'rotate_speed_passthrough',
            'rotate_speed_other_value',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_build_turret_init_unit_type(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BuildTurretInitUnitTypeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BUILD_TURRET_INIT_UNIT_TYPE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'hidden_true',
            'internal_true',
            'speed_zero',
            'hit_size_zero',
            'health_one',
            'rotate_speed_passthrough',
            'rotate_speed_other_value',
            'returns_only_expected_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
