import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LASER_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceLaserTurretBuildPortBridge.gd'
LASER_TURRET_UPDATE_TILE_LEG2_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaserTurretUpdateTileLeg2Proof.gd'


class C07LaserTurretUpdateTileLeg2Tests(unittest.TestCase):
    def test_c07_laser_turret_update_tile_leg2_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2373']['godot_owner'], 'PortGame.source_laser_turret_build_update_tile_leg2_state')
        # LEG 2 of LaserTurretBuild.updateTile()
        # (LaserTurret.java:90-106): the else-if
        # reloadCounter > 0 branch -- with coolant, burn
        # liquid to cool the reload counter down
        # (used * liquid.heatCapacity *
        # coolantMultiplier) and remove the used liquid,
        # sometimes spawning the cool effect; without
        # coolant, the counter falls by edelta(). Leg 1
        # (N2372, the bullets.any() branch) owns the
        # if/else-if guard's first leg and returns the
        # branch flag "reload_branch": "bullets" (leg 2
        # returns "coolant"|"edelta"). The two legs'
        # write-sets are disjoint (leg 1 writes
        # bullets/wasShooting/heat/curRecoil, leg 2
        # writes reloadCounter/liquids). Leg-split
        # approved by the main thread (write-sets
        # disjoint, BurstDrill updateTile leg precedent
        # N2294+N2149+N2296). NO leg-1 expr is
        # re-registered here: the class decls, @Override,
        # `public void updateTile(){` and
        # `if(bullets.any()){` stay owned by N2372 and
        # are only context/callees for this leg. The
        # four distinguishing exprs are
        # `}else if(reloadCounter > 0){`,
        # `float used = (cheating() ? maxUsed :
        # Math.min(liquids.get(liquid), maxUsed)) *
        # delta();`,
        # `reloadCounter -= used * liquid.heatCapacity *
        # coolantMultiplier;` and
        # `reloadCounter -= edelta();` (0 hits in both
        # ledgers at probe time). The shared lines
        # `if(coolant != null){`,
        # `Liquid liquid = liquids.current();`,
        # `float maxUsed = coolant.amount;`,
        # `liquids.remove(liquid, used);`,
        # `if(Mathf.chance(0.06 * used)){` and
        # `coolEffect.at(...);` (shared with N1243-N1246,
        # TractorBeam coolant) are evidence only, never
        # the sole distinguishing expr. NO driver line: a
        # pure function the tick reads, not a per-tick
        # write. Seven new result symbols:
        # reload_counter, liquids, used, max_used,
        # reload_branch, cool_effect_called,
        # cool_effect_call.
        self.assertEqual(
            ledger['N2373']['java_method'],
            'LaserTurretBuild.updateTile()',
        )
        self.assertEqual(
            ledger['N2373']['source_symbols'],
            [
                'source_laser_turret_build_update_tile_leg2_state_result.reload_counter',
                'source_laser_turret_build_update_tile_leg2_state_result.liquids',
                'source_laser_turret_build_update_tile_leg2_state_result.used',
                'source_laser_turret_build_update_tile_leg2_state_result.max_used',
                'source_laser_turret_build_update_tile_leg2_state_result.reload_branch',
                'source_laser_turret_build_update_tile_leg2_state_result.cool_effect_called',
                'source_laser_turret_build_update_tile_leg2_state_result.cool_effect_call',
            ],
        )
        for name in ledger['N2373']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2373']['runtime_proof'], '/root/C07LaserTurretUpdateTileLeg2Proof')
        self.assertEqual(
            ledger['N2373']['tests'],
            [
                'test_c07_laser_turret_update_tile_leg2_registration',
                'test_all_c07_laser_turret_update_tile_leg2_input_evidence_is_exact',
                'test_laser_turret_update_tile_leg2_state',
                'test_reference_graph_and_actual_c07_laser_turret_update_tile_leg2',
            ],
        )
        self.assertTrue(ledger['N2373']['deferred_exprs'])

    def test_all_c07_laser_turret_update_tile_leg2_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2373']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2373']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_laser_turret_update_tile_leg2_state(self):
        bridge = LASER_TURRET_BRIDGE.read_text(encoding='utf-8')
        # LaserTurretBuild.updateTile() leg 2
        # (LaserTurret.java:90-106): the else-if
        # reloadCounter > 0 branch. With coolant, the
        # used liquid is (cheating ? maxUsed :
        # min(liquids.get(liquid), maxUsed)) * delta();
        # reloadCounter falls by used *
        # liquid.heatCapacity * coolantMultiplier and
        # the liquid is removed (capped at zero, the
        # LiquidModule.remove contract); a chance roll
        # of 0.06 * used may spawn coolEffect.at() at a
        # random offset inside size * tilesize / 2.
        # Without coolant, reloadCounter falls by
        # edelta(). When reloadCounter <= 0 the guard
        # fails and nothing happens (reload_branch
        # "none"). The liquids dict arrives as an
        # explicit Dictionary (liquid name -> amount)
        # and is never mutated -- the returned dict is
        # fresh. cheating()/delta()/edelta() are
        # Building methods (BuildingComp.java:1922-1930)
        # arriving as explicit params; the chance roll
        # and the Mathf.range offsets arrive as explicit
        # params (the N1246 TractorBeam coolant-effect
        # precedent). NO driver line.
        self.assertIn('static func source_laser_turret_build_update_tile_leg2_state(reload_counter: float, coolant: Variant, coolant_multiplier: float, cheating: bool, delta: float, edelta: float, liquids: Dictionary, current_liquid: Variant, liquid_heat_capacity: float, chance_result: bool, x: float, y: float, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:', bridge)
        self.assertIn('return {"reload_counter": new_reload_counter, "liquids": new_liquids, "used": used, "max_used": max_used, "reload_branch": reload_branch, "cool_effect_called": cool_effect_called, "cool_effect_call": cool_effect_call}', bridge)
        for expr in [
            '}else if(reloadCounter > 0){',
            'if(coolant != null){',
            'Liquid liquid = liquids.current();',
            'float maxUsed = coolant.amount;',
            'float used = (cheating() ? maxUsed : Math.min(liquids.get(liquid), maxUsed)) * delta();',
            'reloadCounter -= used * liquid.heatCapacity * coolantMultiplier;',
            'liquids.remove(liquid, used);',
            'if(Mathf.chance(0.06 * used)){',
            'coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));',
            '}else{',
            'reloadCounter -= edelta();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): coolant
        # cools the counter and removes liquid / cheating
        # uses maxUsed and caps the removal at zero /
        # no coolant falls back to edelta / a
        # non-positive counter stays idle / the cool
        # effect spawns only when the chance roll hits /
        # the input liquids dict is never mutated / each
        # result carries only its seven keys.
        proof = LASER_TURRET_UPDATE_TILE_LEG2_PROOF.read_text(encoding='utf-8')
        for key in [
            'cools_with_liquid',
            'cheating_uses_max_used',
            'removes_liquid_capped_at_zero',
            'falls_back_to_edelta_without_coolant',
            'stays_idle_when_reload_counter_not_positive',
            'spawns_cool_effect_when_chance_hits',
            'skips_cool_effect_when_chance_misses',
            'does_not_mutate_input_liquids',
            'returns_only_seven_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_laser_turret_update_tile_leg2(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaserTurretUpdateTileLeg2Proof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LASER_TURRET_UPDATE_TILE_LEG_2_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'cools_with_liquid',
            'cheating_uses_max_used',
            'removes_liquid_capped_at_zero',
            'falls_back_to_edelta_without_coolant',
            'stays_idle_when_reload_counter_not_positive',
            'spawns_cool_effect_when_chance_hits',
            'skips_cool_effect_when_chance_misses',
            'does_not_mutate_input_liquids',
            'returns_only_seven_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
