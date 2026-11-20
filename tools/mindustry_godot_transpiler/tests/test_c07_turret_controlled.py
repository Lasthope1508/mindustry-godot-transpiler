import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_CONTROLLED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretControlledProof.gd'


class C07TurretControlledTests(unittest.TestCase):
    def test_c07_turret_controlled_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2324']['godot_owner'], 'SourceTurretBuildState.source_turret_controlled_state')
        # One read accessor on TurretBuild (Turret.java:277):
        # `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # controlled() (Turret.java:441-443):
        # `public boolean controlled(){`
        # `return unit.isPlayer();`
        # `}`
        # -- unit is the TurretBuild field (`public BlockUnitc unit =
        # (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291),
        # synced by unit() (N2307). isPlayer() (UnitComp.java:949-951,
        # `return controller instanceof Player;`) is NOT re-ported
        # here: its result arrives as an explicit bool param
        # (the N2311/N2261 precedent). NO driver tick line:
        # controlled() is a read accessor its callers read, not a
        # per-tick write (the N2249/N2221 precedent) -- validateTarget()
        # reads it (Turret.java:632) and updateTile's player-control
        # branch reads it (Turret.java:494); both callers wait for
        # their own slices. One new result symbol: controlled.
        self.assertEqual(
            ledger['N2324']['source_symbols'],
            [
                'source_turret_controlled_state_result.controlled',
            ],
        )
        for name in ledger['N2324']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2324']['runtime_proof'], '/root/C07TurretControlledProof')
        self.assertEqual(
            ledger['N2324']['tests'],
            [
                'test_c07_turret_controlled_registration',
                'test_all_c07_turret_controlled_input_evidence_is_exact',
                'test_turret_controlled_state',
                'test_reference_graph_and_actual_c07_turret_controlled',
            ],
        )
        self.assertTrue(ledger['N2324']['deferred_exprs'])

    def test_all_c07_turret_controlled_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2324']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2324']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_controlled_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.controlled() (Turret.java:441-443):
        # `public boolean controlled(){`
        # `return unit.isPlayer();`
        # `}`
        # -- unit is the TurretBuild field (`public BlockUnitc unit =
        # (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291),
        # synced by unit() (N2307). isPlayer() is NOT re-ported: its
        # result arrives as the explicit is_player param (the
        # N2311/N2261 precedent). NO driver tick line: a read accessor
        # its callers read (validateTarget Turret.java:632, updateTile
        # :494), not a per-tick write.
        self.assertIn('static func source_turret_controlled_state(frame: Dictionary, is_player: bool) -> Dictionary:', turret)
        self.assertIn('return {"controlled": is_player}', turret)
        for expr in [
            'public boolean controlled(){',
            'return unit.isPlayer();',
            'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with synthetic
        # frames (no live tick: controlled() is a pure read accessor
        # over an explicit param): a player-controlled unit is true /
        # a non-player unit is false / the result carries only its one
        # key.
        proof = TURRET_CONTROLLED_PROOF.read_text(encoding='utf-8')
        for key in [
            'controlled_player_true',
            'controlled_player_false',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_controlled(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretControlledProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_CONTROLLED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'controlled_player_true',
            'controlled_player_false',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
