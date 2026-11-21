import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretStatusProof.gd'


class C07TurretStatusTests(unittest.TestCase):
    def test_c07_turret_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2527']['godot_owner'], 'SourceTurretBuildState.source_turret_status_state')
        # status() is the TurretBuild read (Turret.java:369-372):
        # `public BlockStatus status(){` /
        # `if(enabled && !hasAmmo()) return BlockStatus.noInput;` /
        # `return super.status();`,
        # with super.status() the BuildingComp chain
        # (BuildingComp.java:632-646):
        # `if(!enabled){` / `return BlockStatus.logicDisable;` /
        # `if(!shouldConsume()){` / `return BlockStatus.noOutput;` /
        # `if(efficiency <= 0 || !productionValid()){` /
        # `return BlockStatus.noInput;` /
        # `return ((state.tick / 30f) % 1f) < efficiency ?
        # BlockStatus.active : BlockStatus.noInput;`.
        # The Turret leg runs BEFORE super -- order matters: a
        # turret with ammo falls through to super, a turret
        # without ammo reports noInput even when enabled. The
        # shouldConsume leg reuses
        # `source_turret_should_consume_state(frame, reload)`
        # (N2524, Turret.java:364-366, `return isShooting ||
        # reloadCounter < reload;` -- `reload` is the per-def
        # reload time, `public float reload = 10f;`,
        # ReloadTurret.java:10, read from the catalog
        # `block.properties` with the 10.0 default, the tick
        # :2665 precedent -- NOT hardcoded to duo).
        # `has_ammo` is a bool param, NOT computed in the
        # function: hasAmmo() MUTATES the ammo stack
        # (`ammo.swap(ammo.size - 1, i);`, Turret.java:703),
        # so it cannot be a pure read; the boolean equivalent
        # (no swap) is `canConsume() && size > 0 && (any entry
        # amount >= ammoPerShot || cheating())` -- the swap
        # only moves a sufficient entry to peek, it never
        # changes the boolean. The live hasAmmo computation
        # (stacks + canConsume via the heat gate +
        # ammoPerShot per-def: default 1, Turret.java:49;
        # ripple 2, foreshadow 5, spectre 2, diffuse 3,
        # titan 4, smite 15, malign 2, Blocks.java) is a
        # follow-up -- this slice ports super.status() + the
        # Turret leg with the param. One new result symbol:
        # status. The slice mirrors into the defense shard
        # (214/213 -> 215/214); comp stays 572/475.
        self.assertEqual(
            ledger['N2527']['source_symbols'],
            [
                'source_turret_status_state_result.status',
            ],
        )
        for name in ledger['N2527']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_status_state')
        self.assertEqual(ledger['N2527']['runtime_proof'], '/root/C07TurretStatusProof')
        self.assertEqual(
            ledger['N2527']['tests'],
            [
                'test_c07_turret_status_registration',
                'test_all_c07_turret_status_input_evidence_is_exact',
                'test_turret_status_state',
                'test_reference_graph_and_actual_c07_turret_status',
            ],
        )
        self.assertTrue(ledger['N2527']['deferred_exprs'])

    def test_all_c07_turret_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2527']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.source_turret_status_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2527']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_status_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # status() (Turret.java:369-372) + super.status()
        # (BuildingComp.java:632-646) for the Turret family
        # as one pure function, in exact Java order:
        # 1 `enabled && !has_ammo` -> NO_INPUT (the Turret
        # leg, BEFORE super); 2 `!enabled` -> LOGIC_DISABLE;
        # 3 `!should_consume` (via
        # source_turret_should_consume_state(frame, reload),
        # N2524) -> NO_OUTPUT; 4 `efficiency <= 0 ||
        # !production_valid_state()` -> NO_INPUT
        # (productionValid() is the canonical true default,
        # BuildingComp.java:759-761, `return true;` -- no
        # override in world/blocks/defense/turrets/ or
        # world/blocks/defense/); 5 `fmod(tick / 30.0, 1.0)
        # < efficiency` -> ACTIVE else NO_INPUT. The tick
        # arrives as an explicit float param, not from the
        # frame (the RepairTurret precedent). NO driver tick
        # call site (the N2525/N2526 precedent): status() is
        # a read function, not per-tick, and no caller reads
        # it today (UI/status display is C11).
        self.assertIn('static func source_turret_status_state(frame: Dictionary, tick: float, has_ammo: bool, reload: float) -> Dictionary:', turret)
        self.assertIn('if enabled and not has_ammo:', turret)
        self.assertIn('if not enabled:', turret)
        self.assertIn('var should_consume: bool = bool(source_turret_should_consume_state(frame, reload).get("should_consume", true))', turret)
        self.assertIn('if not should_consume:', turret)
        self.assertIn('var efficiency: float = float(frame.get("efficiency", 1.0))', turret)
        self.assertIn('if efficiency <= 0.0 or not production_valid:', turret)
        self.assertIn('if fmod(tick / 30.0, 1.0) < efficiency:', turret)
        self.assertIn('if(enabled && !hasAmmo()) return BlockStatus.noInput;', turret)
        self.assertIn('return super.status();', turret)
        self.assertIn('if(!enabled){', turret)
        self.assertIn('return BlockStatus.logicDisable;', turret)
        self.assertIn('if(!shouldConsume()){', turret)
        self.assertIn('return BlockStatus.noOutput;', turret)
        self.assertIn('if(efficiency <= 0 || !productionValid()){', turret)
        self.assertIn('return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;', turret)
        self.assertIn('return isShooting || reloadCounter < reload;', turret)
        self.assertIn('public float reload = 10f;', turret)
        # The pure function sits immediately AFTER
        # source_turret_range_state (N2526) and BEFORE
        # source_turret_can_heal_state.
        self.assertLess(turret.index('static func source_turret_range_state('), turret.index('static func source_turret_status_state('))
        self.assertLess(turret.index('static func source_turret_status_state('), turret.index('static func source_turret_can_heal_state('))
        # NO driver tick call site: status() is a read
        # function, not per-tick. The tick function must not
        # call the new pure function.
        tick = turret[turret.index('static func source_turret_tick_buildings_state('):]
        self.assertNotIn('source_turret_status_state(', tick)
        # The proof's keys drive the pure function on exact
        # legs: 1 enabled + no ammo -> noInput (the Turret
        # leg, before super); 2 disabled + ammo ->
        # logicDisable; 3 enabled + ammo + no consume
        # (reload_counter 10.0 >= reload 10.0, not shooting)
        # -> noOutput; 4 efficiency 0.0 -> noInput; 5 tick
        # 0.0 / efficiency 1.0 -> active (0.0 < 1.0); 6 tick
        # 15.0 / efficiency 0.5 -> noInput (0.5 < 0.5 is
        # false -- the exact boundary); 7 tick 12.0 /
        # efficiency 0.5 -> active (0.4 < 0.5); 8 disabled +
        # no ammo -> logicDisable (the Turret leg needs
        # enabled, so the disabled leg wins -- precedence).
        proof = TURRET_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'status_no_input_enabled_no_ammo',
            'status_logic_disable',
            'status_no_output_no_consume',
            'status_no_input_zero_efficiency',
            'status_active_tick_zero',
            'status_no_input_tick_edge',
            'status_active_partial_efficiency',
            'status_logic_disable_beats_no_ammo',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'status_no_input_enabled_no_ammo',
            'status_logic_disable',
            'status_no_output_no_consume',
            'status_no_input_zero_efficiency',
            'status_active_tick_zero',
            'status_no_input_tick_edge',
            'status_active_partial_efficiency',
            'status_logic_disable_beats_no_ammo',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
