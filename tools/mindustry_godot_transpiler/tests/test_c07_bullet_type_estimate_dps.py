import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BULLET_DAMAGE_STATE = ROOT / 'godot-mindustry/src/game/SourceBulletTypeDamageState.gd'
BULLET_TYPE_ESTIMATE_DPS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BulletTypeEstimateDpsProof.gd'


class C07BulletTypeEstimateDpsTests(unittest.TestCase):
    def test_c07_bullet_type_estimate_dps_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2529']['godot_owner'], 'SourceBulletTypeDamageState.source_bullet_type_estimate_dps_state')
        # estimateDPS() is the BulletType read (BulletType.java:414-435):
        # `public float estimateDPS(){` /
        # `if(cachedDps >= 0f) return cachedDps;` /
        # `if(spawnUnit != null){` / `return spawnUnit.estimateDps();` /
        # `if(despawnUnit != null){` / `return despawnUnit.estimateDps();` /
        # `float sum = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 : Mathf.clamp(pierceCap, 1, 2) : 1f);` /
        # `if(fragBullet != null && fragBullet != this){` /
        # `sum += fragBullet.estimateDPS() * fragBullets / 2f;` /
        # `for(var other : spawnBullets){` / `sum += other.estimateDPS();` /
        # `return cachedDps = sum;`.
        # The legs run in exact Java order: the cache hit returns
        # `cachedDps` first; the spawnUnit / despawnUnit legs
        # return the unit DPS WITHOUT writing the cache (Java
        # returns before the `cachedDps = sum` line); only the
        # computed leg writes the cache, and the pure function
        # returns the new cache value through the `cached_dps`
        # key (it never mutates state outside). `damage` is the
        # BulletType field (`public float damage = 1f;`,
        # BulletType.java:41 -- the class default, a float
        # param, NOT hardcoded to 1). `splash_damage` is the
        # field (`public float splashDamage = 0f;`,
        # BulletType.java:109). `pierce` is the field (`public
        # boolean pierce;`, BulletType.java:53 -- false by
        # default). `pierce_cap` is the field (`public int
        # pierceCap = -1;`, BulletType.java:57). `cached_dps`
        # is the runtime cache (`protected float cachedDps = -1;`,
        # BulletType.java:377 -- -1 means "not computed yet").
        # `has_spawn_unit` / `spawn_unit_dps` and
        # `has_despawn_unit` / `despawn_unit_dps` are bool +
        # float param pairs: UnitType.estimateDps()
        # (UnitType.java:1132-1144, `weapons.sumf(Weapon::dps)`
        # + `/ 15f` on suicide) is NOT ported yet, so the unit
        # DPS arrives as a param (the N2528 precedent -- the
        # peek ammo DPS was a param until this slice). The
        # frag guard (`fragBullet != this`, BulletType.java:425)
        # arrives as the `has_frag_bullet` bool param: the
        # caller passes false when the frag bullet is the bullet
        # itself (self-frag), the function cannot tell identity
        # from a float param. `frag_bullets` is the field
        # (`public int fragBullets = 9;`, BulletType.java:212).
        # `spawn_bullets_dps_sum` is the caller-summed
        # `estimateDPS()` of every `spawnBullets` entry
        # (`for(var other : spawnBullets){ sum +=
        # other.estimateDPS(); }`, BulletType.java:429-431 --
        # the recursion over the bullet catalog is the caller's
        # sum, NOT recomputed in the function). Three new
        # result symbols: estimate_dps, cached_dps, branch (the
        # N2526 precedent -- every return key is a symbol). The
        # slice mirrors into the bullet shard (93/93 -> 94/94);
        # comp stays 572/475.
        self.assertEqual(
            ledger['N2529']['source_symbols'],
            [
                'source_bullet_type_estimate_dps_state_result.estimate_dps',
                'source_bullet_type_estimate_dps_state_result.cached_dps',
                'source_bullet_type_estimate_dps_state_result.branch',
            ],
        )
        for name in ledger['N2529']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/entities/bullet/BulletType.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBulletTypeDamageState.source_bullet_type_estimate_dps_state')
        self.assertEqual(ledger['N2529']['runtime_proof'], '/root/C07BulletTypeEstimateDpsProof')
        self.assertEqual(
            ledger['N2529']['tests'],
            [
                'test_c07_bullet_type_estimate_dps_registration',
                'test_all_c07_bullet_type_estimate_dps_input_evidence_is_exact',
                'test_bullet_type_estimate_dps_state',
                'test_reference_graph_and_actual_c07_bullet_type_estimate_dps',
            ],
        )
        self.assertTrue(ledger['N2529']['deferred_exprs'])

    def test_all_c07_bullet_type_estimate_dps_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2529']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBulletTypeDamageState.source_bullet_type_estimate_dps_state')
        slice_sources = {
            'core/src/mindustry/entities/bullet/BulletType.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2529']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_bullet_type_estimate_dps_state(self):
        bullet = BULLET_DAMAGE_STATE.read_text(encoding='utf-8')
        # estimateDPS() (BulletType.java:414-435) for the
        # BulletType family as one pure function, in exact Java
        # order: 1 `cached_dps >= 0.0` -> return the cached
        # value (branch "cached"); 2 `has_spawn_unit` -> return
        # `spawn_unit_dps`, cached unchanged (branch
        # "spawn_unit"); 3 `has_despawn_unit` -> return
        # `despawn_unit_dps`, cached unchanged (branch
        # "despawn_unit"); 4 otherwise `sum = (damage +
        # splash_damage * 0.75) * (pierce ? (pierce_cap == -1 ?
        # 2 : clamp(pierce_cap, 1, 2)) : 1)`; if
        # `has_frag_bullet` then `sum += frag_bullet_dps *
        # frag_bullets / 2`; `sum += spawn_bullets_dps_sum`;
        # return `sum` with `cached_dps` = `sum` (branch
        # "computed"). The function returns exactly the three
        # keys `estimate_dps`, `cached_dps`, `branch`. NO driver
        # tick call site (the N2525/N2526/N2527/N2528
        # precedent): estimateDPS() is a read/estimate, not
        # per-tick, and no caller reads it today (the N2528
        # turret function still takes `peek_ammo_dps` as a
        # param; wiring N2528 -> N2529 is a separate consumer
        # slice; HUD / stats display is C11).
        self.assertIn('static func source_bullet_type_estimate_dps_state(damage: float, splash_damage: float, pierce: bool, pierce_cap: int, cached_dps: float, has_spawn_unit: bool, spawn_unit_dps: float, has_despawn_unit: bool, despawn_unit_dps: float, has_frag_bullet: bool, frag_bullet_dps: float, frag_bullets: int, spawn_bullets_dps_sum: float) -> Dictionary:', bullet)
        self.assertIn('if cached_dps >= 0.0:', bullet)
        self.assertIn('return {"estimate_dps": cached_dps, "cached_dps": cached_dps, "branch": "cached"}', bullet)
        self.assertIn('if has_spawn_unit:', bullet)
        self.assertIn('return {"estimate_dps": spawn_unit_dps, "cached_dps": cached_dps, "branch": "spawn_unit"}', bullet)
        self.assertIn('if has_despawn_unit:', bullet)
        self.assertIn('return {"estimate_dps": despawn_unit_dps, "cached_dps": cached_dps, "branch": "despawn_unit"}', bullet)
        self.assertIn('var sum: float = (damage + splash_damage * 0.75) * pierce_multiplier', bullet)
        self.assertIn('if has_frag_bullet:', bullet)
        self.assertIn('sum += frag_bullet_dps * float(frag_bullets) / 2.0', bullet)
        self.assertIn('sum += spawn_bullets_dps_sum', bullet)
        self.assertIn('return {"estimate_dps": sum, "cached_dps": sum, "branch": "computed"}', bullet)
        self.assertIn('public float estimateDPS(){', bullet)
        self.assertIn('if(cachedDps >= 0f) return cachedDps;', bullet)
        self.assertIn('return spawnUnit.estimateDps();', bullet)
        self.assertIn('return despawnUnit.estimateDps();', bullet)
        self.assertIn('float sum = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 : Mathf.clamp(pierceCap, 1, 2) : 1f);', bullet)
        self.assertIn('if(fragBullet != null && fragBullet != this){', bullet)
        self.assertIn('sum += fragBullet.estimateDPS() * fragBullets / 2f;', bullet)
        self.assertIn('for(var other : spawnBullets){', bullet)
        self.assertIn('sum += other.estimateDPS();', bullet)
        self.assertIn('return cachedDps = sum;', bullet)
        self.assertIn('public float damage = 1f;', bullet)
        self.assertIn('public boolean pierce;', bullet)
        self.assertIn('public int pierceCap = -1;', bullet)
        self.assertIn('public float splashDamage = 0f;', bullet)
        self.assertIn('public int fragBullets = 9;', bullet)
        self.assertIn('protected float cachedDps = -1;', bullet)
        self.assertIn('DORMANT', bullet)
        # The pure function sits immediately AFTER
        # shield_damage_state (the last function in the file).
        self.assertLess(bullet.index('static func shield_damage_state('), bullet.index('static func source_bullet_type_estimate_dps_state('))
        # NO driver tick call site: the definition is the only
        # occurrence of the function name in this file.
        self.assertEqual(bullet.count('source_bullet_type_estimate_dps_state('), 1)
        # The proof's keys drive the pure function on exact
        # legs: 1 cache hit -> 42.0, cached unchanged; 2 spawn
        # unit -> 55.0, cached stays -1; 3 despawn unit ->
        # 33.0, cached stays -1; 4 pierceCap -1 -> x2 (damage
        # 10 -> 20.0); 5 pierceCap clamped 5 -> x2 and 0 -> x1
        # (damage 10 -> 20.0 / 10.0); 6 no pierce -> x1 (damage
        # 10 -> 10.0); 7 frag + splash + spawn bullets: (10 +
        # 4 * 0.75) * 1 + 6 * 9 / 2 + 5 = 45.0, cached 45.0;
        # 8 Java defaults (damage 1, no pierce, no frag, no
        # spawn bullets) -> 1.0.
        proof = BULLET_TYPE_ESTIMATE_DPS_PROOF.read_text(encoding='utf-8')
        for key in [
            'estimate_dps_cached_hit',
            'estimate_dps_spawn_unit',
            'estimate_dps_despawn_unit',
            'estimate_dps_pierce_cap_minus_one',
            'estimate_dps_pierce_cap_clamped',
            'estimate_dps_no_pierce',
            'estimate_dps_frag_and_splash',
            'estimate_dps_java_defaults',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_bullet_type_estimate_dps(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BulletTypeEstimateDpsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BULLET_TYPE_ESTIMATE_DPS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'estimate_dps_cached_hit',
            'estimate_dps_spawn_unit',
            'estimate_dps_despawn_unit',
            'estimate_dps_pierce_cap_minus_one',
            'estimate_dps_pierce_cap_clamped',
            'estimate_dps_no_pierce',
            'estimate_dps_frag_and_splash',
            'estimate_dps_java_defaults',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
