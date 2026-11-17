import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_BIND_BLOCK_ID_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretBindBlockIdProof.gd'


class C07RepairTurretBindBlockIdTests(unittest.TestCase):
    def test_c07_repair_turret_bind_block_id_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2236']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_bind_frame_state')
        # N2235 left the live repair-turret frame without
        # block_id (bind created an empty frame; the driver
        # read block_id from the sprite meta instead), so the
        # per-def ambientSoundVolume (repair-point 0.9f,
        # Blocks.java:6393; repair-turret 1.25f,
        # Blocks.java:6408) never activated on a live frame
        # -- the loop reads it from `frame.get("block_id",
        # "")` (N2235). RED decisions (resolved at RED,
        # recorded in the register docstring): (1) The bind
        # itself is the stamp point (the N2108 turret-bind
        # precedent registers the bind function with input
        # sprite/block and result applied/frame): the bound
        # frame records `frame["block_id"] = str(block.id)`,
        # the port block identity (catalog id string, e.g.
        # "repair-point"; the Factory precedent
        # SourceFactoryBuildState.gd:117 stamps the same
        # value, and placement stamps it on the sprite meta,
        # SourcePlacedBlockState.gd:81). (2) No new pure
        # function, no signature change, no driver edit --
        # the driver already calls bind (:697) and the stamp
        # rides that call; the already-bound branch returns
        # the frame stamped at its first bind. (3) The bind
        # was never registered before (no
        # source_repair_turret_bind_frame_state_* symbol or
        # schema existed), so N2236 registers it now with
        # the 4-symbol N2108 shape; the frame result symbol's
        # rule documents the block_id stamp. (4) Deferred
        # pool: no entry resolved (none names the bind
        # stamp), +1 Windows-proof debt entry for N2236.
        # Four symbols: input sprite/block, result
        # applied/frame.
        self.assertEqual(
            ledger['N2236']['source_symbols'],
            [
                'source_repair_turret_bind_frame_state_input.sprite',
                'source_repair_turret_bind_frame_state_input.block',
                'source_repair_turret_bind_frame_state_result.applied',
                'source_repair_turret_bind_frame_state_result.frame',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        for name in ledger['N2236']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0] if '_result.' in name else 'SourceRepairTurretBuildState.' + name.rsplit('_input.', 1)[0])
        self.assertEqual(ledger['N2236']['runtime_proof'], '/root/C07RepairTurretBindBlockIdProof')
        self.assertEqual(
            ledger['N2236']['tests'],
            [
                'test_c07_repair_turret_bind_block_id_registration',
                'test_all_c07_repair_turret_bind_block_id_input_evidence_is_exact',
                'test_repair_turret_bind_frame_block_id_state',
                'test_reference_graph_and_actual_c07_repair_turret_bind_block_id',
            ],
        )
        self.assertTrue(ledger['N2236']['deferred_exprs'])

    def test_all_c07_repair_turret_bind_block_id_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2236']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0] if '_result.' in name else 'SourceRepairTurretBuildState.' + name.rsplit('_input.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2236']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_bind_frame_block_id_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # Placement creates the Building (Block.java:1002,
        # `public final Building newBuilding(){`); the port's
        # frame is that Building state, bound on the sprite at
        # placement / on the driver's first tick. The bound
        # frame records the block it belongs to
        # (`frame["block_id"] = str(block.id)`, the port block
        # identity -- the catalog id string, e.g.
        # "repair-point" from `repairPoint = new
        # RepairTurret("repair-point"){{`, Blocks.java:6386,
        # and "repair-turret", Blocks.java:6397). The stamp
        # is what lets the N2235 ambient-sound loop resolve
        # the per-def volume (0.9f / 1.25f, Blocks.java:6393
        # / :6408) from a live frame through
        # `control.sound.loop(block.ambientSound, self(),
        # block.ambientSoundVolume * ambientVolume());`
        # (BuildingComp.java:2271). No new pure function, no
        # signature change, no driver edit: the driver
        # already calls bind and the stamp rides that call.
        self.assertIn('static func source_repair_turret_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:', repair_turret)
        bind_start = repair_turret.index('static func source_repair_turret_bind_frame_state')
        bind_end = repair_turret.find('\nstatic func ', bind_start + 1)
        bind_body = repair_turret[bind_start:bind_end if bind_end != -1 else len(repair_turret)]
        self.assertIn('frame["block_id"] = str(block.id)', bind_body)
        self.assertIn('return {"applied": true, "frame": frame}', bind_body)
        self.assertIn('return {"applied": false, "frame": {}}', bind_body)
        # The stale "bind creates an empty frame" wording in
        # the loop comment is gone: bind now stamps block_id.
        self.assertNotIn('the bind creates an empty', repair_turret)
        self.assertNotIn('stamping it at bind is its own later slice', repair_turret)
        for expr in [
            'public final Building newBuilding(){',
            'repairPoint = new RepairTurret("repair-point"){{',
            'repairTurret = new RepairTurret("repair-turret"){{',
            'public class RepairTurret extends Block{',
            'control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());',
            'ambientSoundVolume = 0.9f;',
            'ambientSoundVolume = 1.25f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        driver_start = repair_turret.index('static func source_repair_turret_tick_buildings_state')
        driver_end = repair_turret.find('\nstatic func ', driver_start + 1)
        driver_body = repair_turret[driver_start:driver_end if driver_end != -1 else len(repair_turret)]
        self.assertIn('source_repair_turret_bind_frame_state(sprite, block)', driver_body)
        # The stamp lives in bind, not in the driver: the
        # driver reads block_id off the sprite meta and
        # passes the looked-up block to bind.
        self.assertNotIn('frame["block_id"]', driver_body)
        # The proof's keys bind both defs (frame carries the
        # right block_id), re-bind (keeps it), bind a
        # non-RepairTurret block (binds nothing), resolve the
        # per-def loop volume off a bound frame, and tick the
        # driver live (frame on the sprite meta carries it).
        proof = REPAIR_TURRET_BIND_BLOCK_ID_PROOF.read_text(encoding='utf-8')
        for key in [
            'bind_frame_repair_point_block_id',
            'bind_frame_repair_turret_block_id',
            'bind_already_bound_keeps_block_id',
            'bind_non_repair_turret_applied_false',
            'loop_volume_repair_point_bound',
            'loop_volume_repair_turret_bound',
            'driver_tick_stamps_block_id',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_bind_block_id(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretBindBlockIdProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_BIND_BLOCK_ID_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bind_frame_repair_point_block_id',
            'bind_frame_repair_turret_block_id',
            'bind_already_bound_keeps_block_id',
            'bind_non_repair_turret_applied_false',
            'loop_volume_repair_point_bound',
            'loop_volume_repair_turret_bound',
            'driver_tick_stamps_block_id',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
