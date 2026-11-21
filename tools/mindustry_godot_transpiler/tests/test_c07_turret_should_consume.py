import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretShouldConsumeProof.gd'


class C07TurretShouldConsumeTests(unittest.TestCase):
    def test_c07_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2524']['godot_owner'], 'SourceTurretBuildState.source_turret_should_consume_state')
        # shouldConsume() is `public boolean shouldConsume(){` /
        # `return isShooting || reloadCounter < reload;`
        # (Turret.java:364-366), the one-line predicate on the
        # turret build's own two fields. Both inputs are already
        # live on the frame: `isShooting` (Turret.java:492,
        # ported N2277 -- `source_turret_is_shooting_state`,
        # tick stamps `frame["is_shooting"]` in the duo branch)
        # and `reloadCounter` (ReloadTurret.java:26, ported
        # N2240 -- the aim call stamps
        # `frame["reload_counter"]` in the duo branch). The
        # driver tick's consumption branch ran the machinery
        # with should_consume=true whenever enabled, with a
        # comment saying there is no shouldConsume gate yet --
        # that comment is now STALE for duo (the tick tracks
        # both inputs since N2277 + N2240). This slice ports
        # the predicate as a pure function and wires it into
        # the consumption branch, so a power turret stops
        # consuming when it is neither shooting nor reloading.
        # Java order is updateConsumption() BEFORE updateTile()
        # (BuildingComp.java:2274 vs :2277), so the gate reads
        # the PREVIOUS tick's frame values (the N2270 heat fold
        # precedent). When the gate is false,
        # update_consumption_setup_state returns
        # `update = should_consume and production_valid`
        # (SourceBuildingEfficiencyState.gd:106-107) and
        # update_consumption_efficiency_state folds
        # `efficiency = 0.0` (:127-134) -- exactly Java
        # (BuildingComp.java:1947, `efficiency = ...
        # shouldConsume() ? potentialEfficiency : 0f;`).
        # `reload` is per def, read from the catalog
        # (`block.properties`, the N2270 precedent -- the
        # catalog carries reload for every turret def), class
        # default 10f (ReloadTurret.java:10); the six defs the
        # branch can visit with consumePower are lancer 80f /
        # 6f, arc 35f / 3.3f, foreshadow 200f / 10f, meltdown
        # 90f / 17f, afflict 50f / 5f, malign 3.5f / 40f
        # (Blocks.java). One new result symbol:
        # should_consume. The ported method is
        # TurretBuild.shouldConsume(), so the java_source is
        # Turret.java and the slice mirrors into the defense
        # shard (211/210 -> 212/211); comp stays 572/475.
        self.assertEqual(
            ledger['N2524']['source_symbols'],
            [
                'source_turret_should_consume_state_result.should_consume',
            ],
        )
        for name in ledger['N2524']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_should_consume_state')
        self.assertEqual(ledger['N2524']['runtime_proof'], '/root/C07TurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2524']['tests'],
            [
                'test_c07_turret_should_consume_registration',
                'test_all_c07_turret_should_consume_input_evidence_is_exact',
                'test_turret_should_consume_state',
                'test_reference_graph_and_actual_c07_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2524']['deferred_exprs'])

    def test_all_c07_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2524']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_should_consume_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2524']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_should_consume_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # shouldConsume() (Turret.java:364-366) is the one-line
        # predicate on the turret build's own fields:
        # `public boolean shouldConsume(){` /
        # `return isShooting || reloadCounter < reload; }`.
        # The pure function takes the frame (which already
        # carries `is_shooting` and `reload_counter` from the
        # N2277 / N2240 stamps) plus the per-def `reload` (the
        # catalog read, class default 10f --
        # ReloadTurret.java:10) and returns exactly one key,
        # `should_consume` (the N2241 PointDefense precedent:
        # one pure function, one key, frame-read inputs). The
        # driver tick calls it in the consumption branch
        # (:2497-2499), replacing the
        # "should_consume=true when enabled" approximation;
        # the downstream lines are UNCHANGED
        # (`update_consumption_setup_state`,
        # `update_consumption_state`,
        # `apply_update_consumption_state`, the PowerTurret
        # heat fold). LIVE CONSEQUENCE (Java-faithful, stated
        # in the function comment): the gate is DORMANT live
        # today -- duo has no consumePower so the branch never
        # runs for duo, and the six power defs have no
        # aim/shoot branch stamping `is_shooting` /
        # `reload_counter`, so the gate reads the absent
        # defaults (false / 0.0 < reload) and stays true on
        # every live frame. It goes live when aim/shoot
        # drivers land for the power turrets (the N2241
        # precedent: the gate was false-live until the N2242
        # bullet wiring landed).
        self.assertIn('static func source_turret_should_consume_state(frame: Dictionary, reload: float) -> Dictionary:', turret)
        self.assertIn('bool(frame.get("enabled", true))', turret)
        self.assertIn('bool(frame.get("is_shooting", false))', turret)
        self.assertIn('float(frame.get("reload_counter", 0.0)) < reload', turret)
        self.assertIn('return {"should_consume": should_consume}', turret)
        self.assertIn('public boolean shouldConsume(){', turret)
        self.assertIn('return isShooting || reloadCounter < reload;', turret)
        self.assertIn('public float reload = 10f;', turret)
        self.assertIn('public float reloadCounter;', turret)
        # The pure function sits immediately AFTER
        # source_turret_power_status_row_state (the other
        # helper of the consumption branch) and BEFORE
        # source_turret_can_heal_state.
        self.assertLess(turret.index('static func source_turret_power_status_row_state('), turret.index('static func source_turret_should_consume_state('))
        self.assertLess(turret.index('static func source_turret_should_consume_state('), turret.index('static func source_turret_can_heal_state('))
        # The two frame inputs are stamped by the duo branch
        # (N2277 is_shooting, N2240 reload_counter) -- the
        # gate reads them, it does not stamp them.
        self.assertIn('frame["is_shooting"] = is_shooting_state.get("is_shooting", false)', turret)
        self.assertIn('frame["reload_counter"] = aim.get("reload_counter", 0.0)', turret)
        # The tick call site sits inside
        # source_turret_tick_buildings_state, in the
        # consumption branch, replacing the old
        # should_consume=true-when-enabled line; the reload
        # comes from the catalog per def (the N2270
        # heatRequirement precedent), class default 10f.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertIn('var should_consume_state: Dictionary = source_turret_should_consume_state(frame, float(block.properties.get("reload", 10.0)))', tick)
        self.assertIn('var should_consume: bool = bool(should_consume_state.get("should_consume", true))', tick)
        self.assertNotIn('var should_consume: bool = bool(frame.get("enabled", true))', tick)
        self.assertLess(tick.index('var should_consume_state: Dictionary = source_turret_should_consume_state(frame, float(block.properties.get("reload", 10.0)))'), tick.index('var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)'))
        # The downstream consumption lines are UNCHANGED: the
        # gate feeds the same setup / state / apply calls, and
        # the PowerTurret heat fold still follows.
        self.assertIn('var setup: Dictionary = source_building_efficiency_state.update_consumption_setup_state(should_consume, valid)', tick)
        self.assertIn('source_building_efficiency_state.apply_update_consumption_state(consumption, frame)', tick)
        self.assertIn('var heat_requirement_state: Dictionary = source_turret_heat_requirement_state(block)', tick)
        # The stale "no shouldConsume gate yet" comment in the
        # consumption branch is gone (the gate now exists).
        self.assertNotIn('there is no shouldConsume gate yet', turret)
        # The proof's keys drive the gate through the pure
        # function and the real driver (shooting -> true /
        # reloading -> true / idle + reloaded -> false / the
        # efficiency fold is 0.0 when the gate is false /
        # efficiency is kept when the gate is true).
        proof = TURRET_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'should_consume_shooting',
            'should_consume_reloading',
            'should_consume_idle_reloaded',
            'should_consume_efficiency_fold_zero',
            'should_consume_efficiency_kept',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'should_consume_shooting',
            'should_consume_reloading',
            'should_consume_idle_reloaded',
            'should_consume_efficiency_fold_zero',
            'should_consume_efficiency_kept',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
