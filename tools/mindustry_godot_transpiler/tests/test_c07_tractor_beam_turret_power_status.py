import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TRACTOR_BEAM_STATE = ROOT / 'godot-mindustry/src/game/SourceTractorBeamTurretBuildState.gd'
TRACTOR_BEAM_POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TractorBeamTurretPowerStatusProof.gd'


class C07TractorBeamTurretPowerStatusTests(unittest.TestCase):
    def test_c07_tractor_beam_turret_power_status_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2152']['godot_owner'], 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_power_status_row_state')
        # N2142 stamped every consumer's live power.status onto its
        # building frame each tick, and N2148 proved the pure
        # power-row pattern on the TurretBuild driver -- but
        # TractorBeamTurret extends BaseTurret, not Turret, so
        # parallax is NOT a TurretBuild (SourceTurretBuildState.gd,
        # the turret driver explicitly excludes it) and no driver
        # ticks it at all: it would rotate and pull as if
        # power.status were 1.0. N2152 is the TractorBeamTurret
        # family's live read: a new driver with a pure power row
        # over the stamped frame value, folded by the shared
        # machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) and the tractor-beam eff/edelta fold
        # (TractorBeamTurret.java:84, 117, BuildingComp.java:1928)
        # follows it. Two new result symbols: the row and its
        # presence flag.
        self.assertEqual(
            ledger['N2152']['source_symbols'],
            [
                'source_tractor_beam_turret_power_status_row_state_result.row',
                'source_tractor_beam_turret_power_status_row_state_result.has_power_row',
            ],
        )
        for name in ledger['N2152']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_tractor_beam_turret_power_status_row_state_result.row': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_power_status_row_state',
                    'source_tractor_beam_turret_power_status_row_state_result.has_power_row': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_power_status_row_state',
                }[name])
        self.assertEqual(ledger['N2152']['runtime_proof'], '/root/C07TractorBeamTurretPowerStatusProof')
        self.assertEqual(
            ledger['N2152']['tests'],
            [
                'test_c07_tractor_beam_turret_power_status_registration',
                'test_all_c07_tractor_beam_turret_power_status_input_evidence_is_exact',
                'test_tractor_beam_turret_power_status_row_state',
                'test_reference_graph_and_actual_c07_tractor_beam_turret_power_status',
            ],
        )
        self.assertTrue(ledger['N2152']['deferred_exprs'])

    def test_all_c07_tractor_beam_turret_power_status_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2152']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_tractor_beam_turret_power_status_row_state_result.row': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_power_status_row_state',
                    'source_tractor_beam_turret_power_status_row_state_result.has_power_row': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_power_status_row_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2152']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tractor_beam_turret_power_status_row_state(self):
        tractor_beam = TRACTOR_BEAM_STATE.read_text(encoding='utf-8')
        # The pure power row lives on the TractorBeamTurret build
        # state: the live frame value is ConsumePower.efficiency
        # (ConsumePower.java:39, `return build.power.status;`),
        # folded by the first pass (BuildingComp.java:1969-1976)
        # into the min efficiency; a missing stamp folds to 1.0
        # before the first graph update, the assembler fold
        # (UnitAssembler.java:469, `float powerStatus = !enabled
        # ? 0f : power == null ? 1f : power.status;`).
        self.assertIn('static func source_tractor_beam_turret_power_status_row_state', tractor_beam)
        self.assertIn('return build.power.status;', tractor_beam)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', tractor_beam)
        # The tick driver folds the row into the first pass when the
        # block has a power consumer (the driver gate,
        # block.properties.has("consumePower")); parallax is the only
        # TractorBeamTurret and its power consumer counts toward
        # hasConsumers (Block.java:1449, `hasConsumers =
        # consumers.length > 0;`). The tractor-beam rotation and
        # pull follow the folded efficiency through eff/edelta
        # (BuildingComp.java:1928, `return efficiency * delta();`,
        # TractorBeamTurret.java:84, `float eff = efficiency *
        # coolantMultiplier, edelta = eff * delta();`,
        # TractorBeamTurret.java:117, `rotation =
        # Angles.moveToward(rotation, dest, rotateSpeed * edelta);`
        # -- keep on ONE comment line, the N2148 shootWarmup
        # lesson: a split line fails this test).
        self.assertIn('"is_power": true', tractor_beam)
        self.assertIn('block.properties.has("consumePower")', tractor_beam)
        self.assertIn('hasConsumers = consumers.length > 0;', tractor_beam)
        self.assertIn('return efficiency * delta();', tractor_beam)
        self.assertIn('float eff = efficiency * coolantMultiplier, edelta = eff * delta();', tractor_beam)
        self.assertIn('rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);', tractor_beam)
        self.assertIn('static func source_tractor_beam_turret_tick_buildings_state', tractor_beam)
        # The proof's keys drive the pure row (half / absent /
        # null-folds-one) plus the live tick (efficiency folds the
        # min, zero at no power). There are no progress keys: the
        # tractor-beam tick advances no retarget/coolant/rotation/
        # strength yet (TractorBeamTurret.java:78-139 waits for its
        # own slice), so the eff/edelta fold
        # (TractorBeamTurret.java:84, 117) is what the efficiency
        # keys prove.
        proof = TRACTOR_BEAM_POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'parallax_has_power_consumer',
            'power_row_half',
            'power_row_absent_without_consumer',
            'power_row_null_folds_one',
            'efficiency_folds_power_min',
            'efficiency_zero_at_no_power',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_tractor_beam_turret_power_status(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TractorBeamTurretPowerStatusProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TRACTOR_BEAM_TURRET_POWER_STATUS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'parallax_has_power_consumer',
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
