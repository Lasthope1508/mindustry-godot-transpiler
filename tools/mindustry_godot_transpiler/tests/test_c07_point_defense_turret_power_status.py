import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretPowerStatusProof.gd'


class C07PointDefenseTurretPowerStatusTests(unittest.TestCase):
    def test_c07_point_defense_turret_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2151']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2148 proved the pure
        # power-row pattern on the TurretBuild driver -- but
        # PointDefenseTurret extends ReloadTurret, not Turret, so
        # segment is NOT a TurretBuild (SourceTurretBuildState.gd,
        # the turret driver explicitly excludes it) and no driver
        # ticks it at all: it would rotate and reload as if
        # power.status were 1.0. N2151 is the PointDefenseTurret
        # family's live read: a new driver with a pure power row
        # over the stamped frame value, folded by the shared
        # machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) and the point-defense edelta fold
        # (PointDefenseTurret.java:81-82, BuildingComp.java:1928)
        # follows it. Two new result symbols: the row and its
        # presence flag.
        self.assertEqual(
            ledger['N2151']['source_symbols'],
            [
                'source_point_defense_turret_power_status_row_state_result.row',
                'source_point_defense_turret_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2151']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_power_status_row_state_result.row': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_power_status_row_state',
                    'source_point_defense_turret_power_status_row_state_result.has_power_row': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2151']['runtime_proof'], '/root/C07PointDefenseTurretPowerStatusProof')
        self.assertEqual(
            ledger['N2151']['tests'],
            [
                'test_c07_point_defense_turret_power_status_registration',
                'test_all_c07_point_defense_turret_power_status_input_evidence_is_exact',
                'test_point_defense_turret_power_status_row_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_power_status',
            ],
        )
        self.assertTrue(ledger['N2151']['deferred_exprs'])

    def test_all_c07_point_defense_turret_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2151']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_power_status_row_state_result.row': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_power_status_row_state',
                    'source_point_defense_turret_power_status_row_state_result.has_power_row': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2151']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_power_status_row_state(self):
        point_defense = POINT_DEFENSE_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the PointDefenseTurret build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_point_defense_turret_power_status_row_state', point_defense)
        self.assertIn('return build.power.status;', point_defense)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', point_defense)
        # The tick driver folds the row into the first pass when the
        # block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); segment is the only
        # PointDefenseTurret and its power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The point-defense rotation and
        # reload follow the folded efficiency through edelta
        # (BuildingComp.java:1928, `return efficiency * delta();`,
        # PointDefenseTurret.java:81, `rotation =
        # Angles.moveToward(rotation, dest, rotateSpeed * edelta());`
        # -- keep on ONE comment line, the N2148 shootWarmup
        # lesson: a split line fails this test).
        self.assertIn('"is_power": true', point_defense)
        self.assertIn('block.properties.has("consumePower")', point_defense)
        self.assertIn('hasConsumers = consumers.length > 0;', point_defense)
        self.assertIn('return efficiency * delta();', point_defense)
        self.assertIn('rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());', point_defense)
        self.assertIn('static func source_point_defense_turret_tick_buildings_state', point_defense)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress keys: the
        # point-defense tick advances no retarget/rotation/reload
        # yet (PointDefenseTurret.java:62-103 waits for its own
        # slice), so the edelta fold (PointDefenseTurret.java:81-82)
        # is what the efficiency keys prove.
        proof = POINT_DEFENSE_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'segment_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_point_defense_turret_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'segment_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
