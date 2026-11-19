import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
EXTRACTOR = ROOT / 'tools/mindustry_godot_transpiler/mindustry_port/content_registry.py'
REGISTRY_JSON = ROOT / 'godot-mindustry/src/generated/content_registry.json'
TURRET_CHARGE_STATE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretChargeStateProof.gd'


class C07TurretChargeStateTests(unittest.TestCase):
    def test_c07_turret_charge_state_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2271']['godot_owner'], 'SourceTurretBuildState.source_turret_charge_sound_state')
        # N2269 pinned only that the firstShotDelay > 0 branch
        # exists (Turret.java:747-748) -- but the branch itself
        # was never modeled: when shooting begins with a
        # first-shot delay, shoot() plays the charge sound and
        # the bullet type's charge effect (Turret.java:747-749):
        # `if(shoot.firstShotDelay > 0){`
        # `chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));`
        # `type.chargeEffect.at(bulletX, bulletY, rotation);`
        # The delay defaults to 0 (ShootPattern.java:11
        # `public float firstShotDelay = 0;`) and the sound to
        # silence (Turret.java:125-126, `/** Sound emitted when
        # shoot.firstShotDelay is >0 and shooting begins. */
        # public Sound chargeSound = Sounds.none;`). Among
        # turret block defs ONLY lancer sets either:
        # `shoot.firstShotDelay = 40f;` (Blocks.java:3564) and
        # `chargeSound = Sounds.chargeLancer;`
        # (Blocks.java:3579), in `lancer = new PowerTurret(
        # "lancer"){{` (Blocks.java:3560) -- every other turret
        # reads the defaults, so the guard stays off and no
        # charge sound plays. The pitch range is the class
        # default (Turret.java:132 `public float soundPitchMin
        # = 0.9f, soundPitchMax = 1.1f;`); no def overrides it.
        # This slice is the N2143/N2270 catalog-capture
        # pattern applied to the charge sound: (1) the emitter
        # captures firstShotDelay (the `range` / `reload`
        # numeric pattern) and chargeSound (the Sounds.* name)
        # for Turret-family blocks from the block initializer's
        # own assignment -- only lancer carries them; (2) one
        # pure read on the block,
        # source_turret_charge_sound_state(block), returns
        # {first_shot_delay, charge_sound, charge_emitted} --
        # the catalog values when present, the class defaults
        # 0.0 / "none" otherwise, null-safe, with
        # charge_emitted exactly the :747 guard
        # (first_shot_delay > 0); (3) NO driver tick: the
        # emission happens inside shoot(), an event the driver
        # has no equivalent for yet -- the same event-driven
        # precedent as N2268/N2269. The bullet type's
        # chargeEffect (Turret.java:749, BulletType.java:79
        # `public Effect chargeEffect = Fx.none;`) waits for
        # its own slice: the effect lives on the bullet type
        # (lancer's LaserBulletType shootType, `chargeEffect =
        # new MultiEffect(Fx.lancerLaserCharge,
        # Fx.lancerLaserChargeBegin);`, Blocks.java:3586), and
        # the catalog has no shootType bullet-effect
        # representation yet, so this read pins the sound side
        # only. Three new result symbols: first_shot_delay,
        # charge_sound, charge_emitted.
        self.assertEqual(
            ledger['N2271']['source_symbols'],
            [
                'source_turret_charge_sound_state_result.first_shot_delay',
                'source_turret_charge_sound_state_result.charge_sound',
                'source_turret_charge_sound_state_result.charge_emitted',
            ],
        )
        for name in ledger['N2271']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/pattern/ShootPattern.java',
                    'core/src/mindustry/entities/bullet/BulletType.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_charge_sound_state_result.first_shot_delay': 'SourceTurretBuildState.source_turret_charge_sound_state',
                    'source_turret_charge_sound_state_result.charge_sound': 'SourceTurretBuildState.source_turret_charge_sound_state',
                    'source_turret_charge_sound_state_result.charge_emitted': 'SourceTurretBuildState.source_turret_charge_sound_state',
                }[name])
        self.assertEqual(ledger['N2271']['runtime_proof'], '/root/C07TurretChargeStateProof')
        self.assertEqual(
            ledger['N2271']['tests'],
            [
                'test_c07_turret_charge_state_registration',
                'test_all_c07_turret_charge_state_input_evidence_is_exact',
                'test_turret_charge_state',
                'test_reference_graph_and_actual_c07_turret_charge_state',
            ],
        )
        self.assertTrue(ledger['N2271']['deferred_exprs'])

    def test_all_c07_turret_charge_state_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2271']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_charge_sound_state_result.first_shot_delay': 'SourceTurretBuildState.source_turret_charge_sound_state',
                    'source_turret_charge_sound_state_result.charge_sound': 'SourceTurretBuildState.source_turret_charge_sound_state',
                    'source_turret_charge_sound_state_result.charge_emitted': 'SourceTurretBuildState.source_turret_charge_sound_state',
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
        for expr in ledger['N2271']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_charge_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        extractor = EXTRACTOR.read_text(encoding='utf-8')
        # The pure read lives on the shared TurretBuild driver
        # file (SourceTurretBuildState.gd), after
        # source_turret_heat_requirement_state and before the
        # tick driver, following the N2143 has_upgrade /
        # plan-requirements pattern (block: Object, null-safe):
        # the class defaults (ShootPattern.java:11 `public
        # float firstShotDelay = 0;`, Turret.java:126 `public
        # Sound chargeSound = Sounds.none;`) when the catalog
        # carries no override, the per-block values otherwise
        # -- lancer 40.0 / "chargeLancer" (Blocks.java:3564 /
        # :3579, `shoot.firstShotDelay = 40f;` /
        # `chargeSound = Sounds.chargeLancer;`). Only lancer
        # sets either among turrets, so every other turret
        # reads the defaults and the charge guard
        # (`if(shoot.firstShotDelay > 0){`, Turret.java:747)
        # stays off. charge_emitted is exactly that guard
        # (first_shot_delay > 0). The function returns the
        # three keys `{"first_shot_delay": .., "charge_sound":
        # .., "charge_emitted": ..}`. There is no driver tick:
        # the emission happens inside shoot(), an event the
        # driver has no equivalent for yet (precedent N2268 /
        # N2269).
        self.assertIn('static func source_turret_charge_sound_state(block: Object) -> Dictionary:', turret)
        self.assertIn('return {"first_shot_delay": first_shot_delay, "charge_sound": charge_sound, "charge_emitted": charge_emitted}', turret)
        self.assertIn('public Sound chargeSound = Sounds.none;', turret)
        self.assertIn('public float firstShotDelay = 0;', turret)
        self.assertIn('shoot.firstShotDelay = 40f;', turret)
        self.assertIn('chargeSound = Sounds.chargeLancer;', turret)
        # The extractor captures firstShotDelay (the `range` /
        # `reload` numeric pattern) and chargeSound (the
        # Sounds.* name) for blocks from the block
        # initializer's own assignment.
        self.assertIn('"firstShotDelay"', extractor)
        self.assertIn('"chargeSound"', extractor)
        # The regenerated catalog carries the real values, so
        # the driver no longer falls back to 0.0 / "none" for
        # lancer -- and no other turret carries either key.
        registry = json.loads(REGISTRY_JSON.read_text(encoding='utf-8'))
        by_id = {block['id']: block for block in registry['blocks']}
        self.assertEqual(by_id['lancer']['properties'].get('firstShotDelay'), 40.0)
        self.assertEqual(by_id['lancer']['properties'].get('chargeSound'), 'chargeLancer')
        self.assertIsNone(by_id['duo']['properties'].get('firstShotDelay'))
        self.assertIsNone(by_id['duo']['properties'].get('chargeSound'))
        self.assertIsNone(by_id['malign']['properties'].get('firstShotDelay'))
        self.assertIsNone(by_id['malign']['properties'].get('chargeSound'))
        # The proof's keys drive the catalog value (lancer),
        # the read's default + catalog + null paths, the guard
        # off for duo / malign and on for lancer.
        proof = TURRET_CHARGE_STATE_PROOF.read_text(encoding='utf-8')
        for key in [
            'catalog_lancer_40_charge_lancer',
            'read_default_0_none',
            'read_null_block_default',
            'read_lancer_40_charge_lancer',
            'read_duo_0_none',
            'read_malign_0_none',
            'guard_off_duo',
            'guard_on_lancer',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_charge_state(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretChargeStateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CHARGE_STATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'catalog_lancer_40_charge_lancer',
            'read_default_0_none',
            'read_null_block_default',
            'read_lancer_40_charge_lancer',
            'read_duo_0_none',
            'read_malign_0_none',
            'guard_off_duo',
            'guard_on_lancer',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
