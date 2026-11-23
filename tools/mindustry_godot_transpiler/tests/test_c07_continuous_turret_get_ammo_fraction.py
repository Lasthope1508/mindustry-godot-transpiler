import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretBuildPortBridge.gd'
CONTINUOUS_TURRET_GET_AMMO_FRACTION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretGetAmmoFractionProof.gd'


class C07ContinuousTurretGetAmmoFractionTests(unittest.TestCase):
    def test_c07_continuous_turret_get_ammo_fraction_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2355']['godot_owner'], 'PortGame.source_continuous_turret_build_get_ammo_fraction_state')
        # ContinuousTurretBuild.getAmmoFraction() (ContinuousTurret.java:75-84):
        # `@Override`
        # `public float getAmmoFraction(){`
        # `//TODO unclean way of calculating ammo fraction to display`
        # `float ammoFract = efficiency;`
        # `if(findConsumer(f -> f instanceof ConsumeLiquidBase) instanceof ConsumeLiquid cons){`
        # `ammoFract = Math.min(ammoFract, liquids.get(cons.liquid) / liquidCapacity);`
        # `}`
        # `return ammoFract;`
        # on `public class ContinuousTurretBuild extends TurretBuild{`
        # (ContinuousTurret.java:38) inside
        # `public class ContinuousTurret extends Turret{`. This
        # is the ContinuousTurret override: it starts from the
        # block efficiency and caps it by the liquid fraction
        # when a ConsumeLiquid consumer exists. The other
        # getAmmoFraction overrides own their own bodies and
        # are NOT touched here -- TurretBuild base (N2348,
        # constant 1f), ItemTurretBuild (N1181),
        # LiquidTurretBuild (N1198), ContinuousLiquidTurretBuild
        # (N1221), PowerTurretBuild (N1168). NO driver line:
        # a pure accessor the HUD caller reads, not a per-tick
        # write. One new result symbol: ammo_fraction. The
        # findConsumer lookup is NOT ported: its result arrives
        # as the explicit has_liquid_consumer + liquid_amount
        # params (the N2330 param precedent).
        self.assertEqual(
            ledger['N2355']['source_symbols'],
            [
                'source_continuous_turret_build_get_ammo_fraction_state_result.ammo_fraction',
            ],
        )
        for name in ledger['N2355']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2355']['runtime_proof'], '/root/C07ContinuousTurretGetAmmoFractionProof')
        self.assertEqual(
            ledger['N2355']['tests'],
            [
                'test_c07_continuous_turret_get_ammo_fraction_registration',
                'test_all_c07_continuous_turret_get_ammo_fraction_input_evidence_is_exact',
                'test_continuous_turret_get_ammo_fraction_state',
                'test_reference_graph_and_actual_c07_continuous_turret_get_ammo_fraction',
            ],
        )
        self.assertTrue(ledger['N2355']['deferred_exprs'])

    def test_all_c07_continuous_turret_get_ammo_fraction_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2355']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2355']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_get_ammo_fraction_state(self):
        bridge = CONTINUOUS_TURRET_BRIDGE.read_text(encoding='utf-8')
        # ContinuousTurretBuild.getAmmoFraction()
        # (ContinuousTurret.java:75-84) starts from efficiency
        # and caps it by liquids.get(liquid) / liquidCapacity
        # when a ConsumeLiquid consumer exists. The consumer
        # lookup arrives as explicit params; there is no dict
        # frame input, so every input is a scalar and there is
        # no input-unmutated key for this slice (unlike the
        # frame-taking Turret accessors). NO driver line: a
        # pure accessor, not a per-tick write.
        self.assertIn('static func source_continuous_turret_build_get_ammo_fraction_state(efficiency: float, has_liquid_consumer: bool, liquid_amount: float, liquid_capacity: float) -> Dictionary:', bridge)
        self.assertIn('return {"ammo_fraction": ammo_fraction}', bridge)
        for expr in [
            'public class ContinuousTurret extends Turret{',
            'public class ContinuousTurretBuild extends TurretBuild{',
            '@Override',
            'public float getAmmoFraction(){',
            '//TODO unclean way of calculating ammo fraction to display',
            'float ammoFract = efficiency;',
            'if(findConsumer(f -> f instanceof ConsumeLiquidBase) instanceof ConsumeLiquid cons){',
            'ammoFract = Math.min(ammoFract, liquids.get(cons.liquid) / liquidCapacity);',
            'return ammoFract;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): no consumer
        # returns efficiency / liquid ratio below efficiency
        # caps the fraction / efficiency below the liquid
        # ratio wins / zero efficiency stays zero / each
        # result carries only its one key.
        proof = CONTINUOUS_TURRET_GET_AMMO_FRACTION_PROOF.read_text(encoding='utf-8')
        for key in [
            'ammo_fraction_efficiency_only',
            'ammo_fraction_liquid_caps',
            'ammo_fraction_efficiency_caps',
            'ammo_fraction_zero_efficiency',
            'ammo_fraction_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_get_ammo_fraction(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretGetAmmoFractionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_GET_AMMO_FRACTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'ammo_fraction_efficiency_only',
            'ammo_fraction_liquid_caps',
            'ammo_fraction_efficiency_caps',
            'ammo_fraction_zero_efficiency',
            'ammo_fraction_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
