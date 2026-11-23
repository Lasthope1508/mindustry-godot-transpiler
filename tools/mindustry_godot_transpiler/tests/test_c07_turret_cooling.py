import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_COOLING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretCoolingProof.gd'


class C07TurretCoolingTests(unittest.TestCase):
    def test_c07_turret_cooling_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2525']['godot_owner'], 'SourceTurretBuildState.source_turret_cooling_state')
        # updateCooling() is `protected void updateCooling(){` /
        # `if(canReload() && coolant != null &&
        # coolant.efficiency(this) > 0 && efficiency > 0){` /
        # `float capacity = coolant instanceof
        # ConsumeLiquidFilter filter ?
        # filter.getConsumed(this).heatCapacity :
        # (coolant.consumes(liquids.current()) ?
        # liquids.current().heatCapacity : 0.4f);` /
        # `float amount = coolant.amount *
        # coolant.efficiency(this);` / `coolant.update(this);` /
        # `reloadCounter += amount * edelta() * capacity *
        # coolantMultiplier * ammoReloadMultiplier();` /
        # `if(Mathf.chance(0.06 * amount)){`
        # (ReloadTurret.java:28-38), the shared
        # ReloadTurretBuild implementation every ReloadTurret
        # subclass runs from Turret.java:550
        # (`if(reloadWhileCharging || !charging()){` /
        # `updateReload();` / `updateCooling(); }`,
        # "turret always reloads regardless of whether it's
        # targeting something"). This slice ports it for the
        # Turret family as one pure function mirroring
        # `source_point_defense_turret_cooling_state` (N2241):
        # the gate is canReload() (`reloadCounter < reload`,
        # ReloadTurret.java:46-48) plus coolant present plus
        # coolant efficiency > 0 plus efficiency > 0; the
        # reload boost is `amount * edelta() * capacity *
        # coolantMultiplier * ammoReloadMultiplier()` with
        # `coolantMultiplier = 5f` for the Turret family
        # (BaseTurret.java:32 -- no override in ItemTurret /
        # Turret / PowerTurret; only PointDefenseTurret 2f,
        # LaserTurret / ContinuousTurret / TractorBeamTurret
        # 1f) and `ammoReloadMultiplier()` the Turret.java:727
        # override (`return hasAmmo() ?
        # peekAmmo().reloadMultiplier : 1f;`, NOT the
        # ReloadTurret.java:41-43 default 1f); `capacity` is
        # the consumed liquid's heatCapacity
        # (ReloadTurret.java:30, the ConsumeLiquidFilter
        # filter branch -- ConsumeCoolant extends
        # ConsumeLiquidFilter), passed in as a parameter with
        # the 0.4f fallback belonging to the coolant-pick
        # slice, not this function; `edelta()` is
        # `efficiency * delta()` (BuildingComp.java:1927-1929),
        # passed in precomputed; the coolEffect chance is a
        # random visual, NOT in the pure function (the N2240
        # random-pitch precedent); `coolant.update(this)`
        # removes `amount * edelta() * multiplier` -- the pure
        # function returns that as `coolant_consumed` for a
        # later wiring slice to apply, since the frame carries
        # no liquid inventory (the N2241 precedent). NO driver
        # tick call site: the frame carries no liquid state
        # and the catalog records `coolant` for NO block
        # (checked this run: `any('coolant' in props)` is
        # False), so the driver tick cannot read a coolant
        # amount today; the call-site gate
        # (`reloadWhileCharging || !charging()`,
        # Turret.java:550) belongs to the driver-tick slice.
        # Three new result symbols: reload_counter /
        # cooling_applied / coolant_consumed. The ported
        # method is ReloadTurretBuild.updateCooling(), so the
        # java_source is ReloadTurret.java and the slice
        # mirrors into the defense shard (212/211 -> 213/212);
        # comp stays 572/475.
        self.assertEqual(
            ledger['N2525']['source_symbols'],
            [
                'source_turret_cooling_state_result.reload_counter',
                'source_turret_cooling_state_result.cooling_applied',
                'source_turret_cooling_state_result.coolant_consumed',
            ],
        )
        for name in ledger['N2525']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_cooling_state')
        self.assertEqual(ledger['N2525']['runtime_proof'], '/root/C07TurretCoolingProof')
        self.assertEqual(
            ledger['N2525']['tests'],
            [
                'test_c07_turret_cooling_registration',
                'test_all_c07_turret_cooling_input_evidence_is_exact',
                'test_turret_cooling_state',
                'test_reference_graph_and_actual_c07_turret_cooling',
            ],
        )
        self.assertTrue(ledger['N2525']['deferred_exprs'])

    def test_all_c07_turret_cooling_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2525']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_cooling_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2525']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_cooling_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # updateCooling() (ReloadTurret.java:28-38) for the
        # Turret family: the pure function mirrors
        # `source_point_defense_turret_cooling_state` (N2241)
        # with one added parameter, `ammo_reload_multiplier`
        # (the Turret.java:727 override, NOT the
        # ReloadTurret.java:41-43 default 1f). The gate is
        # `canReload() && coolant != null &&
        # coolant.efficiency(this) > 0 && efficiency > 0`
        # (ReloadTurret.java:29, canReload() =
        # `reloadCounter < reload`, :46-48); `amount =
        # coolant.amount * coolant.efficiency(this)` (:31);
        # `coolant.update(this)` (:32) removes `amount *
        # edelta() * multiplier` -- returned as
        # `coolant_consumed` for a later wiring slice, since
        # the frame carries no liquid inventory; the reload
        # boost is `reloadCounter += amount * edelta() *
        # capacity * coolantMultiplier *
        # ammoReloadMultiplier();` (:33) with
        # coolantMultiplier 5f for the Turret family
        # (BaseTurret.java:32); the coolEffect chance
        # (`if(Mathf.chance(0.06 * amount)){`, :35) is a
        # random visual, NOT in the pure function. Gate fail
        # leaves `reload_counter` unchanged,
        # `cooling_applied=false`, `coolant_consumed=0.0`.
        self.assertIn('static func source_turret_cooling_state(frame: Dictionary, has_coolant: bool, coolant_amount: float, coolant_efficiency: float, heat_capacity: float, coolant_multiplier: float, ammo_reload_multiplier: float, reload: float, edelta: float) -> Dictionary:', turret)
        self.assertIn('if has_coolant and reload_counter < reload and coolant_efficiency > 0.0 and efficiency > 0.0:', turret)
        self.assertIn('var amount: float = coolant_amount * coolant_efficiency', turret)
        self.assertIn('coolant_consumed = amount * edelta', turret)
        self.assertIn('reload_counter += amount * edelta * heat_capacity * coolant_multiplier * ammo_reload_multiplier', turret)
        self.assertIn('cooling_applied = true', turret)
        self.assertIn('return {"reload_counter": reload_counter, "cooling_applied": cooling_applied, "coolant_consumed": coolant_consumed}', turret)
        self.assertIn('if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){', turret)
        self.assertIn('float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);', turret)
        self.assertIn('float amount = coolant.amount * coolant.efficiency(this);', turret)
        self.assertIn('coolant.update(this);', turret)
        self.assertIn('reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();', turret)
        self.assertIn('if(Mathf.chance(0.06 * amount)){', turret)
        self.assertIn('return reloadCounter < reload;', turret)
        self.assertIn('return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;', turret)
        self.assertIn('public float coolantMultiplier = 5f;', turret)
        self.assertIn('return efficiency * delta();', turret)
        self.assertIn('updateCooling();', turret)
        self.assertIn('if(reloadWhileCharging || !charging()){', turret)
        # Merge 2026-11-23: in the merged file the cooling
        # function sits early (ReloadTurret region), BEFORE
        # source_turret_should_consume_state and BEFORE
        # source_turret_can_heal_state -- the remote file's
        # should_consume-first order does not survive the
        # merge (function order is cosmetic).
        self.assertLess(turret.index('static func source_turret_cooling_state('), turret.index('static func source_turret_should_consume_state('))
        self.assertLess(turret.index('static func source_turret_cooling_state('), turret.index('static func source_turret_can_heal_state('))
        # NO driver tick call site (the N2248 precedent): the
        # frame carries no liquid state and the catalog
        # records `coolant` for NO block, so the driver tick
        # cannot read a coolant amount today; the
        # Turret.java:550 call-site gate
        # (`reloadWhileCharging || !charging()`) belongs to
        # the driver-tick slice. The tick function must not
        # call the new pure function.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertNotIn('source_turret_cooling_state(', tick)
        # The proof's keys drive the pure function on a duo
        # frame (reload 20f, coolant 0.1f at Blocks.java:3324;
        # the proof uses exact-binary amounts 0.25 / 0.5 so
        # the float equalities are exact): the reload boost
        # applies (0.25 * 1.0 * 0.5 * 5.0 * 1.0 = 0.625) /
        # the gate blocks without coolant / the gate blocks
        # when reloaded (reload_counter == reload) / the gate
        # blocks at zero coolant efficiency / the
        # ammoReloadMultiplier override scales the boost
        # (2.0 -> 1.25, the Turret.java:727 override vs the
        # ReloadTurret.java:41-43 default 1f).
        proof = TURRET_COOLING_PROOF.read_text(encoding='utf-8')
        for key in [
            'cooling_boosts_reload_counter',
            'cooling_gate_blocks_without_coolant',
            'cooling_gate_blocks_when_reloaded',
            'cooling_gate_blocks_zero_efficiency',
            'cooling_ammo_reload_multiplier_scales_boost',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_cooling(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretCoolingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_COOLING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'cooling_boosts_reload_counter',
            'cooling_gate_blocks_without_coolant',
            'cooling_gate_blocks_when_reloaded',
            'cooling_gate_blocks_zero_efficiency',
            'cooling_ammo_reload_multiplier_scales_boost',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
