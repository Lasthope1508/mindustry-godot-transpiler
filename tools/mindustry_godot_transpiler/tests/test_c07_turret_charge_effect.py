import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
EXTRACTOR = ROOT / 'tools/mindustry_godot_transpiler/mindustry_port/content_registry.py'
REGISTRY_JSON = ROOT / 'godot-mindustry/src/generated/content_registry.json'
TURRET_CHARGE_EFFECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretChargeEffectProof.gd'


class C07TurretChargeEffectTests(unittest.TestCase):
    def test_c07_turret_charge_effect_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2273']['godot_owner'], 'SourceTurretBuildState.source_turret_charge_effect_state')
        # N2271 pinned only the charge sound side of the
        # firstShotDelay > 0 branch -- the bullet type's
        # charge effect was never modeled: when shooting
        # begins with a first-shot delay, shoot() plays the
        # charge sound and the bullet type's charge effect
        # (Turret.java:747-749):
        # `if(shoot.firstShotDelay > 0){`
        # `chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));`
        # `type.chargeEffect.at(bulletX, bulletY, rotation);`
        # The effect defaults to none (BulletType.java:78-79,
        # `/** Effect created when charging starts; only
        # usable in single-shot weapons with a firstShotDelay
        # / shotDelay. */ public Effect chargeEffect =
        # Fx.none;`) and the delay defaults to 0
        # (ShootPattern.java:11 `public float firstShotDelay
        # = 0;`). Among turret block defs ONLY lancer sets
        # either: `shoot.firstShotDelay = 40f;`
        # (Blocks.java:3564) and, on its LaserBulletType
        # shootType (`shootType = new LaserBulletType(140){{`,
        # Blocks.java:3583), `chargeEffect = new
        # MultiEffect(Fx.lancerLaserCharge,
        # Fx.lancerLaserChargeBegin);` (Blocks.java:3586), in
        # `lancer = new PowerTurret("lancer"){{`
        # (Blocks.java:3560) -- every other turret reads the
        # defaults, so the guard stays off and no charge
        # effect plays. This slice is the N2143/N2271
        # catalog-capture pattern applied to the charge
        # effect: (1) the emitter captures chargeEffect (the
        # MultiEffect construction verbatim, without `new`)
        # for Turret-family blocks from the block
        # initializer's own assignment -- only lancer
        # carries it; (2) one pure read on the block,
        # source_turret_charge_effect_state(block), returns
        # {first_shot_delay, charge_effect,
        # charge_effect_emitted} -- the catalog values when
        # present, the class defaults 0.0 / "none"
        # otherwise, null-safe, with charge_effect_emitted
        # exactly the :747 guard (first_shot_delay > 0);
        # (3) NO driver tick: the emission happens inside
        # shoot(), an event the driver has no equivalent
        # for yet -- the same event-driven precedent as
        # N2268 / N2269 / N2271. Three new result symbols:
        # first_shot_delay, charge_effect,
        # charge_effect_emitted.
        self.assertEqual(
            ledger['N2273']['source_symbols'],
            [
                'source_turret_charge_effect_state_result.first_shot_delay',
                'source_turret_charge_effect_state_result.charge_effect',
                'source_turret_charge_effect_state_result.charge_effect_emitted',
            ],
        )
        for name in ledger['N2273']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/pattern/ShootPattern.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_charge_effect_state_result.first_shot_delay': 'SourceTurretBuildState.source_turret_charge_effect_state',
                    'source_turret_charge_effect_state_result.charge_effect': 'SourceTurretBuildState.source_turret_charge_effect_state',
                    'source_turret_charge_effect_state_result.charge_effect_emitted': 'SourceTurretBuildState.source_turret_charge_effect_state',
                }[name])
        self.assertEqual(ledger['N2273']['runtime_proof'], '/root/C07TurretChargeEffectProof')
        self.assertEqual(
            ledger['N2273']['tests'],
            [
                'test_c07_turret_charge_effect_registration',
                'test_all_c07_turret_charge_effect_input_evidence_is_exact',
                'test_turret_charge_effect',
                'test_reference_graph_and_actual_c07_turret_charge_effect',
            ],
        )
        self.assertTrue(ledger['N2273']['deferred_exprs'])

    def test_all_c07_turret_charge_effect_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2273']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_charge_effect_state_result.first_shot_delay': 'SourceTurretBuildState.source_turret_charge_effect_state',
                    'source_turret_charge_effect_state_result.charge_effect': 'SourceTurretBuildState.source_turret_charge_effect_state',
                    'source_turret_charge_effect_state_result.charge_effect_emitted': 'SourceTurretBuildState.source_turret_charge_effect_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2273']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_charge_effect(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        extractor = EXTRACTOR.read_text(encoding='utf-8')
        # The pure read lives on the shared TurretBuild driver
        # file (SourceTurretBuildState.gd), after
        # source_turret_charge_sound_state and before
        # source_turret_can_consume_heat_gate_state, following
        # the N2143 has_upgrade / plan-requirements pattern
        # (block: Object, null-safe): the class defaults
        # (ShootPattern.java:11 `public float firstShotDelay
        # = 0;`, BulletType.java:79 `public Effect
        # chargeEffect = Fx.none;`) when the catalog carries
        # no override, the per-block values otherwise --
        # lancer 40.0 / "MultiEffect(Fx.lancerLaserCharge,
        # Fx.lancerLaserChargeBegin)" (Blocks.java:3564 /
        # :3586, `shoot.firstShotDelay = 40f;` /
        # `chargeEffect = new MultiEffect(Fx.lancerLaserCharge,
        # Fx.lancerLaserChargeBegin);`). Only lancer sets
        # either among turrets, so every other turret reads
        # the defaults and the charge guard
        # (`if(shoot.firstShotDelay > 0){`, Turret.java:747)
        # stays off. charge_effect_emitted is exactly that
        # guard (first_shot_delay > 0). The function returns
        # the three keys `{"first_shot_delay": ..,
        # "charge_effect": .., "charge_effect_emitted": ..}`.
        # There is no driver tick: the emission happens
        # inside shoot(), an event the driver has no
        # equivalent for yet (precedent N2268 / N2269 /
        # N2271). The first_shot_delay key is kept for
        # consistency with N2271: the guard reads it, and
        # the two charge slices share the same guard input.
        self.assertIn('static func source_turret_charge_effect_state(block: Object) -> Dictionary:', turret)
        self.assertIn('return {"first_shot_delay": first_shot_delay, "charge_effect": charge_effect, "charge_effect_emitted": charge_effect_emitted}', turret)
        self.assertIn('public Effect chargeEffect = Fx.none;', turret)
        self.assertIn('public float firstShotDelay = 0;', turret)
        self.assertIn('shoot.firstShotDelay = 40f;', turret)
        self.assertIn('chargeEffect = new MultiEffect(Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin);', turret)
        # The extractor captures chargeEffect (the
        # MultiEffect construction) for blocks from the block
        # initializer's own assignment.
        self.assertIn('"chargeEffect"', extractor)
        # The regenerated catalog carries the real values, so
        # the driver no longer falls back to 0.0 / "none" for
        # lancer -- and no other turret carries either key.
        registry = json.loads(REGISTRY_JSON.read_text(encoding='utf-8'))
        by_id = {block['id']: block for block in registry['blocks']}
        self.assertEqual(by_id['lancer']['properties'].get('firstShotDelay'), 40.0)
        self.assertEqual(by_id['lancer']['properties'].get('chargeEffect'), 'MultiEffect(Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin)')
        self.assertIsNone(by_id['duo']['properties'].get('firstShotDelay'))
        self.assertIsNone(by_id['duo']['properties'].get('chargeEffect'))
        self.assertIsNone(by_id['malign']['properties'].get('firstShotDelay'))
        self.assertIsNone(by_id['malign']['properties'].get('chargeEffect'))
        # The proof's keys drive the catalog value (lancer),
        # the read's default + catalog + null paths, the guard
        # off for duo / malign and on for lancer.
        proof = TURRET_CHARGE_EFFECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'catalog_lancer_40_charge_effect',
            'read_default_0_none',
            'read_null_block_default',
            'read_lancer_40_charge_effect',
            'read_duo_0_none',
            'read_malign_0_none',
            'guard_off_duo',
            'guard_on_lancer',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_charge_effect(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretChargeEffectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CHARGE_EFFECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'catalog_lancer_40_charge_effect',
            'read_default_0_none',
            'read_null_block_default',
            'read_lancer_40_charge_effect',
            'read_duo_0_none',
            'read_malign_0_none',
            'guard_off_duo',
            'guard_on_lancer',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
