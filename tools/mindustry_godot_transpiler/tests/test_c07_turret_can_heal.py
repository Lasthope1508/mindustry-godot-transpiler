import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_CAN_HEAL_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretCanHealProof.gd'


class C07TurretCanHealTests(unittest.TestCase):
    def test_c07_turret_can_heal_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2281']['godot_owner'], 'SourceTurretBuildState.source_turret_can_heal_state')
        # canHeal() is `protected boolean canHeal(){ return
        # targetHealing && hasAmmo() && peekAmmo().collidesTeam
        # && peekAmmo().heals(); }` (Turret.java:635-637) on
        # the fields `public boolean targetHealing = false;`
        # (Turret.java:95 -- duo never sets it, grep Blocks.java
        # duo 3257-3331: no hit), `public boolean collidesTeam
        # = false;` (BulletType.java:127 -- the duo ammo catalog
        # has no collidesTeam key) and `public boolean heals(){
        # return healPercent > 0 || healAmount > 0; }`
        # (BulletType.java:447-449 -- duo ammo never sets
        # healPercent / healAmount, so heals() is false for
        # duo). Both Java consumers (validateTarget :632 and
        # findTarget :660) need a live entity scan, so no
        # consumer is rewired: this slice is stamp-only like
        # N2280, one pure function plus one driver tick. One
        # new result symbol: can_heal.
        self.assertEqual(
            ledger['N2281']['source_symbols'],
            [
                'source_turret_can_heal_state_result.can_heal',
            ],
        )
        for name in ledger['N2281']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/Turret.java')
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_can_heal_state')
        self.assertEqual(ledger['N2281']['runtime_proof'], '/root/C07TurretCanHealProof')
        self.assertEqual(
            ledger['N2281']['tests'],
            [
                'test_c07_turret_can_heal_registration',
                'test_all_c07_turret_can_heal_input_evidence_is_exact',
                'test_turret_can_heal_state',
                'test_reference_graph_and_actual_c07_turret_can_heal',
            ],
        )
        self.assertTrue(ledger['N2281']['deferred_exprs'])

    def test_all_c07_turret_can_heal_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2281']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_can_heal_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2281']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_can_heal_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # canHeal() (Turret.java:635-637) is `return
        # targetHealing && hasAmmo() && peekAmmo().collidesTeam
        # && peekAmmo().heals();`. The pure function takes the
        # four live inputs -- target_healing (Turret.java:95,
        # false for duo, never set in the duo block), has_ammo
        # (live: the duo ammo stacks are non-empty), ammo_collides_team
        # (BulletType.java:127, default false, read live from the
        # peeked ammo data) and ammo_heals (BulletType.java:447-449,
        # healPercent > 0 || healAmount > 0, read live from the
        # peeked ammo data) -- and returns one key:
        # `{"can_heal": ..}`. The driver tick runs in the duo
        # branch right BEFORE the logic_controlled tick (:1382),
        # before the validateTarget call, and stamps the key on
        # the frame. No consumer is rewired: validateTarget's
        # effective-team resolution (Turret.java:632) and
        # findTarget's ally-tile acquisition (:660) both need a
        # live entity scan, which the port does not have yet.
        self.assertIn('static func source_turret_can_heal_state(target_healing: bool, has_ammo: bool, ammo_collides_team: bool, ammo_heals: bool) -> Dictionary:', turret)
        self.assertIn('var can_heal: bool = target_healing and has_ammo and ammo_collides_team and ammo_heals', turret)
        self.assertIn('return {"can_heal": can_heal}', turret)
        self.assertIn('protected boolean canHeal(){', turret)
        self.assertIn('return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();', turret)
        self.assertIn('public boolean targetHealing = false;', turret)
        self.assertIn('public boolean collidesTeam = false;', turret)
        self.assertIn('return healPercent > 0 || healAmount > 0;', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch right
        # before the logic_controlled tick: it derives can_heal
        # live from the frame values and stamps the key.
        self.assertIn('var can_heal_state: Dictionary = source_turret_can_heal_state(false, not duo_entries.is_empty(), bool(duo_ammo_data.get("collidesTeam", false)), bool(float(duo_ammo_data.get("healPercent", 0.0)) > 0.0 or float(duo_ammo_data.get("healAmount", 0.0)) > 0.0))', turret)
        self.assertIn('frame["can_heal"] = can_heal_state.get("can_heal", false)', turret)
        self.assertLess(turret.index('var can_heal_state: Dictionary = source_turret_can_heal_state('), turret.index('var logic_controlled_state: Dictionary = source_turret_logic_controlled_state('))
        # The pure function sits immediately BEFORE
        # source_turret_logic_controlled_state, since
        # validateTarget (:491) calls canHeal() before
        # isShooting (:492).
        self.assertLess(turret.index('static func source_turret_can_heal_state('), turret.index('static func source_turret_logic_controlled_state('))
        # The proof's keys pin the four clauses through the pure
        # function and the real driver (all four true / each
        # clause false alone -- directly; the key stamped live
        # on the frame by the driver).
        proof = TURRET_CAN_HEAL_PROOF.read_text(encoding='utf-8')
        for key in [
            'can_heal_true_all_clauses',
            'can_heal_false_when_not_target_healing',
            'can_heal_false_when_no_ammo',
            'can_heal_false_when_ammo_not_collides_team',
            'can_heal_false_when_ammo_not_heals',
            'can_heal_stamped_to_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_can_heal(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretCanHealProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CAN_HEAL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'can_heal_true_all_clauses',
            'can_heal_false_when_not_target_healing',
            'can_heal_false_when_no_ammo',
            'can_heal_false_when_ammo_not_collides_team',
            'can_heal_false_when_ammo_not_heals',
            'can_heal_stamped_to_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
