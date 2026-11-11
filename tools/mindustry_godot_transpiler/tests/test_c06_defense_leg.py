import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREDICT_STATE = ROOT / 'godot-mindustry/src/game/SourcePredictState.gd'
COMBAT_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretCombatState.gd'
ENEMY_STATE = ROOT / 'godot-mindustry/src/game/SourceEnemyUnitRuntimeState.gd'


class C06DefenseLegTests(unittest.TestCase):
    def test_c06_defense_leg_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2122']['godot_owner'], 'SourcePredictState.source_predict_intercept_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourcePredictState.source_predict_intercept_state', 'source_predict_intercept_state_input', 'Dictionary', ['intercept_x', 'intercept_y', 'intercept_time', 'used_intercept'], 'N2122'),
            ('SourcePredictState.source_predict_quad_state', 'source_predict_quad_state_input', 'Dictionary', ['has_roots', 'root0', 'root1'], 'N2122'),
            ('SourceTurretCombatState.source_turret_target_position_state', 'source_turret_target_position_state_input', 'Dictionary', ['target_position', 'used_intercept', 'bullet_speed'], 'N2122'),
            ('SourceEnemyUnitRuntimeState.source_enemy_units_sweep_dead_state', 'source_enemy_units_sweep_dead_state_input', 'Dictionary', ['swept_count', 'swept_health', 'remaining_count'], 'N2122'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourcePredictState.source_predict_intercept_state']['params']],
            ['src_x', 'src_y', 'dst_x', 'dst_y', 'dst_vx', 'dst_vy', 'bullet_speed', 'time_delta'],
        )
        self.assertEqual(
            [param['name'] for param in contracts['SourcePredictState.source_predict_quad_state']['params']],
            ['a', 'b', 'c'],
        )
        self.assertEqual(
            [param['name'] for param in contracts['SourceTurretCombatState.source_turret_target_position_state']['params']],
            ['game', 'origin', 'target'],
        )
        self.assertEqual(
            [param['name'] for param in contracts['SourceEnemyUnitRuntimeState.source_enemy_units_sweep_dead_state']['params']],
            ['game'],
        )
        self.assertEqual(len(ledger['N2122']['source_symbols']), 28)
        self.assertTrue(ledger['N2122']['deferred_exprs'])

    def test_all_c06_defense_leg_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        owners = {
            'source_predict_intercept_state_': 'SourcePredictState.source_predict_intercept_state',
            'source_predict_quad_state_': 'SourcePredictState.source_predict_quad_state',
            'source_turret_target_position_state_': 'SourceTurretCombatState.source_turret_target_position_state',
            'source_enemy_units_sweep_dead_state_': 'SourceEnemyUnitRuntimeState.source_enemy_units_sweep_dead_state',
        }
        for name in ledger['N2122']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                prefix = next(p for p in owners if name.startswith(p))
                self.assertEqual(symbol['godot_owner'], owners[prefix])
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/entities/Predict.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/HealthComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/UnitComp.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2122']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_defense_leg_reads_live_turret_and_enemy_state(self):
        predict = PREDICT_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_predict_intercept_state(src_x: float, src_y: float, dst_x: float, dst_y: float, dst_vx: float, dst_vy: float, bullet_speed: float, time_delta: float) -> Dictionary:', predict)
        self.assertIn('static func source_predict_quad_state(a: float, b: float, c: float) -> Dictionary:', predict)
        self.assertIn('PORT_GAME_SOURCE_PREDICT_INTERCEPT_STATE', predict)
        self.assertIn('PORT_GAME_SOURCE_PREDICT_QUAD_STATE', predict)
        self.assertIn('dst_vx / time_delta', predict)
        self.assertIn('source_predict_quad_state(quad_a, quad_b, quad_c)', predict)
        combat = COMBAT_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_turret_target_position_state(game: Object, origin, target) -> Dictionary:', combat)
        self.assertIn('PORT_GAME_SOURCE_TURRET_TARGET_POSITION_STATE', combat)
        self.assertIn('source_predict_intercept_state(', combat)
        self.assertIn('peek_turret_ammo', combat)
        self.assertIn('source_unit_world_speed', combat)
        self.assertIn('return source_turret_aim_state.game_angle_to_target(game, origin, target)', combat)
        self.assertIn('source_turret_target_position_state(game, origin, target)', combat)
        enemy = ENEMY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_enemy_units_sweep_dead_state(game: Object) -> Dictionary:', enemy)
        self.assertIn('PORT_GAME_SOURCE_ENEMY_UNITS_SWEEP_DEAD_STATE', enemy)
        self.assertIn('source_enemy_units_sweep_dead_state(game)', enemy)
        bridge = (ROOT / 'godot-mindustry/src/game/SourceTurretRuntimePortBridge.gd').read_text(encoding='utf-8')
        self.assertIn('origin = call("grid_to_world", Vector2i(origin))', bridge)
        simulation = (ROOT / 'godot-mindustry/src/game/SourceTurretSimulationState.gd').read_text(encoding='utf-8')
        self.assertIn('shot_context.get("game", null)', simulation)
        self.assertIn('grid_to_world', simulation)
        registry = (ROOT / 'godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd').read_text(encoding='utf-8')
        self.assertIn('PORT_GAME_SOURCE_PREDICT_INTERCEPT_STATE', registry)
        self.assertIn('PORT_GAME_SOURCE_PREDICT_QUAD_STATE', registry)
        self.assertIn('PORT_GAME_SOURCE_TURRET_TARGET_POSITION_STATE', registry)
        self.assertIn('PORT_GAME_SOURCE_ENEMY_UNITS_SWEEP_DEAD_STATE', registry)

    def test_turret_holds_fire_without_target(self):
        # Turret.updateTile (Turret.java:569-601) runs the aim, the
        # turn and the shoot gate inside validateTarget(): with no
        # target the turret holds its rotation and never fires. A
        # null target used to read as an aim at 0 degrees, so the
        # duo burned 8 of its 30 copper rounds into empty air
        # before the dagger entered range and the defense leg came
        # down to a single hit (17 hits needed, 16 landed).
        simulation = (ROOT / 'godot-mindustry/src/game/SourceTurretSimulationState.gd').read_text(encoding='utf-8')
        self.assertIn('if target == null:', simulation)
        self.assertIn('"should_fire": false,', simulation)
        self.assertIn('"next_rotation": current_rotation,', simulation)
        self.assertIn('validateTarget', simulation)

    def test_reference_graph_and_actual_c06_defense_leg(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06DefenseProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_DEFENSE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
