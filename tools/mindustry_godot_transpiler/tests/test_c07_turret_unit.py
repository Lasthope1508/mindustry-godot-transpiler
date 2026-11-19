import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_UNIT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretUnitProof.gd'


class C07TurretUnitTests(unittest.TestCase):
    def test_c07_turret_unit_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2307']['godot_owner'], 'SourceTurretBuildState.source_turret_unit_state')
        # One accessor on TurretBuild (Turret.java:277):
        # `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # unit() (Turret.java:434-439):
        # `public Unit unit(){`
        # `unit.tile(this);`
        # `unit.team(team);`
        # `return (Unit)unit;`
        # `}`
        # -- unit is the TurretBuild field (Turret.java:291,
        # `public BlockUnitc unit =
        # (BlockUnitc)UnitTypes.block.create(team);`), created
        # once from UnitTypes.block -- NOT re-ported here
        # (Unit/BlockUnitc are not ported); it arrives as an
        # explicit param (the N2268/N2261 precedent). team_id
        # is the building team as an int (the tick-frame
        # convention: source_turret_tick_frame_state binds
        # frame["team_id"]). The function performs the sync
        # itself: it copies the input unit dict, sets tile to
        # the building frame (`this`) and team_id to the
        # building team, and returns {"unit": synced}. NO
        # driver tick line: a read accessor its callers read,
        # not a per-tick write (the N2249/N2221 precedent).
        # The stat derivation INSIDE BlockUnitComp.tile(Building)
        # (maxHealth/health/hitSize/set, BlockUnitComp.java:17-27)
        # is NOT ported here: tile() is a separate method on a
        # different component -- it stays deferred for its own
        # slice. controlled() (Turret.java:441-443) is
        # EXPLICITLY OUT OF SCOPE: a separate later slice.
        # BuildTurret.BuildTurretBuild.unit() is a DIFFERENT
        # method on a different class (evidence only in local
        # N2184) -- NOT re-ported here. One new result symbol:
        # unit.
        self.assertEqual(
            ledger['N2307']['source_symbols'],
            [
                'source_turret_unit_state_result.unit',
            ],
        )
        for name in ledger['N2307']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2307']['runtime_proof'], '/root/C07TurretUnitProof')
        self.assertEqual(
            ledger['N2307']['tests'],
            [
                'test_c07_turret_unit_registration',
                'test_all_c07_turret_unit_input_evidence_is_exact',
                'test_turret_unit_state',
                'test_reference_graph_and_actual_c07_turret_unit',
            ],
        )
        self.assertTrue(ledger['N2307']['deferred_exprs'])

    def test_all_c07_turret_unit_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2307']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BlockUnitComp.java',
            'core/src/mindustry/entities/comp/TeamComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2307']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_unit_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.unit() (Turret.java:434-439):
        # `public Unit unit(){`
        # `unit.tile(this);`
        # `unit.team(team);`
        # `return (Unit)unit;`
        # `}`
        # -- unit is the TurretBuild field (Turret.java:291,
        # `public BlockUnitc unit =
        # (BlockUnitc)UnitTypes.block.create(team);`), created
        # once from UnitTypes.block. `unit.tile(this);`
        # resolves to BlockUnitComp.tile(Building)
        # (BlockUnitComp.java:17, `public void tile(Building
        # tile){`) on the tile field (`@ReadOnly transient
        # Building tile;`, BlockUnitComp.java:14) -- the stat
        # derivation inside tile() (maxHealth/health/hitSize/
        # set) stays deferred for its own slice. `team` is the
        # Building team (`@Import Team team;`,
        # BuildingComp.java:62); the unit team field defaults
        # to derelict (`Team team = Team.derelict;`,
        # TeamComp.java:15). controlled() (Turret.java:441-443)
        # is EXPLICITLY OUT OF SCOPE for this slice.
        self.assertIn('static func source_turret_unit_state(frame: Dictionary, unit: Dictionary, team_id: int) -> Dictionary:', turret)
        self.assertIn('return {"unit": synced}', turret)
        self.assertIn('synced["tile"] = frame', turret)
        self.assertIn('synced["team_id"] = team_id', turret)
        for expr in [
            'public Unit unit(){',
            'unit.tile(this);',
            'unit.team(team);',
            'return (Unit)unit;',
            'public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);',
            'public void tile(Building tile){',
            '@ReadOnly transient Building tile;',
            'Team team = Team.derelict;',
            '@Import Team team;',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: unit() is a pure
        # accessor over explicit params): the returned unit
        # carries the input unit's keys / its tile is the
        # building frame / its team_id is the building team /
        # the input unit dict is NOT mutated (pure function:
        # the sync lands on a copy) / an empty unit dict
        # syncs cleanly / other keys survive the sync / the
        # result carries only its one key.
        proof = TURRET_UNIT_PROOF.read_text(encoding='utf-8')
        for key in [
            'unit_returns_same_unit',
            'unit_tile_is_frame',
            'unit_team_is_team_id',
            'unit_input_unmutated',
            'unit_empty_dict',
            'unit_preserves_keys',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_unit(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretUnitProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_UNIT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'unit_returns_same_unit',
            'unit_tile_is_frame',
            'unit_team_is_team_id',
            'unit_input_unmutated',
            'unit_empty_dict',
            'unit_preserves_keys',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
