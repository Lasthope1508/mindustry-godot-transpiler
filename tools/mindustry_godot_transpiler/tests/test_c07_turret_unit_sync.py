import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_UNIT_SYNC_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretUnitSyncProof.gd'


class C07TurretUnitSyncTests(unittest.TestCase):
    def test_c07_turret_unit_sync_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2260']['godot_owner'], 'SourceTurretBuildState.source_turret_unit_sync_state')
        # TurretBuild.updateTile() syncs its block unit every
        # tick, after the charge advance and before the
        # recoilOffset draw:
        # `unit.tile(this);`
        # `unit.rotation(rotation);`
        # `unit.team(team);`
        # (Turret.java:529-531). The unit is the per-building
        # BlockUnitc,
        # `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`
        # (:291). tile() re-asserts the tile link and re-derives
        # the unit stats from the building
        # (`this.tile = tile;` / `hitSize(tile.block.size * tilesize * 0.7f);`,
        # BlockUnitComp.java:18/:23); rotation() is the plain
        # RotComp field assignment (RotComp.java,
        # `@SyncField(false) @SyncLocal float rotation;`); team()
        # re-syncs the unit team and only calls back into the
        # building when the teams drifted
        # (`if(tile != null && this.team != team){` /
        # `tile.changeTeam(team);`, BlockUnitComp.java:79/:83).
        # This slice is the LIVE frame tick on the new duo
        # driver: one pure function on the shared TurretBuild
        # driver file plus one driver tick in the duo branch
        # AFTER the N2259 charge tick and BEFORE the N2258
        # recoilOffset tick (Java order :527 charge, :529-531
        # unit sync, :532 offset). Five new result symbols:
        # unit_tile, unit_rotation, unit_team, unit_hit_size
        # and tile_change_team_called. The maxHealth/health
        # re-sync of tile() and the set(tile) world position
        # wait for their own slices: the frame carries no live
        # building-health key yet, and the frame works in cells
        # while set() positions the unit in world coordinates.
        self.assertEqual(
            ledger['N2260']['source_symbols'],
            [
                'source_turret_unit_sync_state_result.unit_tile',
                'source_turret_unit_sync_state_result.unit_rotation',
                'source_turret_unit_sync_state_result.unit_team',
                'source_turret_unit_sync_state_result.unit_hit_size',
                'source_turret_unit_sync_state_result.tile_change_team_called',
            ],
        )
        for name in ledger['N2260']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/comp/BlockUnitComp.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_unit_sync_state_result.unit_tile': 'SourceTurretBuildState.source_turret_unit_sync_state',
                    'source_turret_unit_sync_state_result.unit_rotation': 'SourceTurretBuildState.source_turret_unit_sync_state',
                    'source_turret_unit_sync_state_result.unit_team': 'SourceTurretBuildState.source_turret_unit_sync_state',
                    'source_turret_unit_sync_state_result.unit_hit_size': 'SourceTurretBuildState.source_turret_unit_sync_state',
                    'source_turret_unit_sync_state_result.tile_change_team_called': 'SourceTurretBuildState.source_turret_unit_sync_state',
                }[name])
        self.assertEqual(ledger['N2260']['runtime_proof'], '/root/C07TurretUnitSyncProof')
        self.assertEqual(
            ledger['N2260']['tests'],
            [
                'test_c07_turret_unit_sync_registration',
                'test_all_c07_turret_unit_sync_input_evidence_is_exact',
                'test_turret_unit_sync_state',
                'test_reference_graph_and_actual_c07_turret_unit_sync',
            ],
        )
        self.assertTrue(ledger['N2260']['deferred_exprs'])

    def test_all_c07_turret_unit_sync_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2260']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_unit_sync_state_result.unit_tile': 'SourceTurretBuildState.source_turret_unit_sync_state',
                    'source_turret_unit_sync_state_result.unit_rotation': 'SourceTurretBuildState.source_turret_unit_sync_state',
                    'source_turret_unit_sync_state_result.unit_team': 'SourceTurretBuildState.source_turret_unit_sync_state',
                    'source_turret_unit_sync_state_result.unit_hit_size': 'SourceTurretBuildState.source_turret_unit_sync_state',
                    'source_turret_unit_sync_state_result.tile_change_team_called': 'SourceTurretBuildState.source_turret_unit_sync_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BlockUnitComp.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2260']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_unit_sync_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() (Turret.java:490-532)
        # syncs its block unit every tick:
        # `unit.tile(this);`
        # `unit.rotation(rotation);`
        # `unit.team(team);`
        # (:529-531), after the charge advance (:527) and
        # before the recoilOffset draw (:532). The unit is
        # `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`
        # (:291). tile() re-asserts the tile link
        # (`this.tile = tile;`, BlockUnitComp.java:18) and
        # re-derives the hit size
        # (`hitSize(tile.block.size * tilesize * 0.7f);`, :23 --
        # the port already has it as
        # SourceBlockGeometry.block_unit_tile_hit_size, scale
        # 0.7); rotation() is the plain RotComp field
        # assignment; team() re-syncs the unit team and only
        # calls back into the building when the teams drifted
        # (`if(tile != null && this.team != team){` /
        # `tile.changeTeam(team);`, BlockUnitComp.java:79/:83 --
        # tile is `this` at this call site, so the null guard
        # is always true and the steady state never calls
        # changeTeam). Duo size is 1 (the Block.java:215
        # default, never overridden) and tilesize is 8
        # (Vars.tilesize), so the live duo hit size is
        # 1 * 8 * 0.7 = 5.6. The pure function takes the
        # building cell, the frame rotation, the previous
        # unit team, the building team, the tile team, the
        # block size and tilesize, and returns all five
        # keys:
        # `{"unit_tile": .., "unit_rotation": .., "unit_team": .., "unit_hit_size": .., "tile_change_team_called": ..}`.
        # The driver tick reads the cell, the frame rotation
        # (default 90.0, the aim stamp default) and the
        # previous unit team (default team_id -- the unit is
        # created on the building team), calls the pure
        # function with duo size 1.0 and tilesize 8.0, then
        # stamps all five keys back on the frame so logic /
        # control reads (controlled(), unit.controller()) see
        # a live unit mirror.
        self.assertIn('static func source_turret_unit_sync_state(unit_tile: Vector2i, rotation: float, unit_team: int, team_id: int, tile_team: int, block_size: float, tilesize: float) -> Dictionary:', turret)
        self.assertIn('return {"unit_tile": unit_tile, "unit_rotation": rotation, "unit_team": team_id, "unit_hit_size": hit_size, "tile_change_team_called": tile_change_team_called}', turret)
        self.assertIn('unit.tile(this);', turret)
        self.assertIn('unit.rotation(rotation);', turret)
        self.assertIn('unit.team(team);', turret)
        self.assertIn('public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);', turret)
        self.assertIn('this.tile = tile;', turret)
        self.assertIn('hitSize(tile.block.size * tilesize * 0.7f);', turret)
        self.assertIn('tile.changeTeam(team);', turret)
        # The driver tick lives in the shared TurretBuild driver
        # (SourceTurretBuildState.gd), in the duo branch AFTER
        # the N2259 charge tick and BEFORE the N2258
        # recoilOffset tick (Java order :527 charge, :529-531
        # unit sync, :532 offset): it reads the cell, the
        # frame rotation and the previous unit team, calls the
        # new pure function with duo size 1.0 and tilesize 8.0,
        # then stamps all five keys back on the frame.
        self.assertIn('var unit_sync: Dictionary = source_turret_unit_sync_state(cell, float(frame.get("rotation", 90.0)), int(frame.get("unit_team", team_id)), team_id, team_id, 1.0, 8.0)', turret)
        self.assertIn('frame["unit_tile"] = unit_sync.get("unit_tile", cell)', turret)
        self.assertIn('frame["unit_rotation"] = unit_sync.get("unit_rotation", 90.0)', turret)
        self.assertIn('frame["unit_team"] = unit_sync.get("unit_team", team_id)', turret)
        self.assertIn('frame["unit_hit_size"] = unit_sync.get("unit_hit_size", 5.6)', turret)
        self.assertIn('frame["tile_change_team_called"] = unit_sync.get("tile_change_team_called", false)', turret)
        # The proof's keys drive the unit sync through the pure
        # function and the real driver (the tile link is
        # re-asserted every tick / the unit rotation follows
        # the building rotation / the unit team follows the
        # building team / the duo hit size is 1 * 8 * 0.7 =
        # 5.6 / a synced team never calls changeTeam / a
        # drifted team calls changeTeam once and the unit team
        # lands on the building team / all five keys are
        # stamped on the frame after the tick / the duo live
        # tick stamps tile + rotation + team + hit size 5.6).
        # There are no maxHealth/health/set keys: the tile()
        # health re-sync waits for a live building-health
        # source and set(tile) waits for a world-position
        # representation (the frame works in cells).
        proof = TURRET_UNIT_SYNC_PROOF.read_text(encoding='utf-8')
        for key in [
            'unit_tile_reasserted',
            'unit_rotation_follows_building',
            'unit_team_follows_building',
            'unit_hit_size_duo',
            'unit_team_no_change_team_when_synced',
            'unit_team_change_team_when_drifted',
            'unit_sync_stamped_to_frame',
            'unit_sync_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_unit_sync(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretUnitSyncProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_UNIT_SYNC_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'unit_tile_reasserted',
            'unit_rotation_follows_building',
            'unit_team_follows_building',
            'unit_hit_size_duo',
            'unit_team_no_change_team_when_synced',
            'unit_team_change_team_when_drifted',
            'unit_sync_stamped_to_frame',
            'unit_sync_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
