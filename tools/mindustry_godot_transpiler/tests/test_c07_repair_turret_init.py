import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTurretBuildState.gd'
REPAIR_TURRET_INIT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTurretInitProof.gd'


class C07RepairTurretInitTests(unittest.TestCase):
    def test_c07_repair_turret_init_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2226']['godot_owner'], 'SourceRepairTurretBuildState.source_repair_turret_init_state')
        # RepairTurret.init() (RepairTurret.java:83-92,
        # `public void init(){`) pins the clip radius with
        # one call (`updateClipRadius(repairRadius +
        # tilesize);` -- RepairTurret.java:90). The other
        # init() legs are NOT this slice: the coolant leg
        # (`if(acceptCoolant){ hasLiquids = true;
        # consume(new ConsumeCoolant(coolantUse)).optional(true,
        # true); }` -- :84-86) registers a coolant consumer
        # and waits for its own slice; the power leg
        # (`consumePowerCond(powerUse, (RepairPointBuild
        # entity) -> entity.target != null);` -- :89)
        # registers a power-condition consumer and waits for
        # its own slice; `super.init();` (:91) is Block.init
        # internals, deferred (the N1234
        # TractorBeamTurret.init() precedent: "Inherited
        # BaseTurret.init internals and Block.updateClipRadius
        # side effects remain deferred; this slice records
        # the exact TractorBeamTurret updateClipRadius
        # argument"). The Block.updateClipRadius side effect
        # itself (`clipSize = Math.max(clipSize, this.size *
        # tilesize + radiusInWorldUnits * 2f);`,
        # Block.java:1007) is likewise deferred -- this slice
        # pins only the call argument, repairRadius +
        # tilesize: class default 50f + 8 = 58.0
        # (RepairTurret.java:32, `public float repairRadius =
        # 50f;`), repair-point 60f + 8 = 68.0
        # (Blocks.java:6389, `repairRadius = 60f;`),
        # repair-turret 145f + 8 = 153.0 (Blocks.java:6401,
        # `repairRadius = 145f;`); tilesize is 8
        # (Vars.java:135, `public static final int tilesize =
        # 8;`).
        # RED decisions (resolved at RED, recorded in the
        # register docstring): (1) One pure function on the
        # same family file N2174 / N2188 / N2209 / N2212-N2215 /
        # N2217 / N2219-N2225 built:
        # source_repair_turret_init_state(repair_radius,
        # tilesize) returning clip_radius (repair_radius +
        # tilesize). Both params are explicit floats (the
        # N2212 acquire / N2220 draw-place / N2223 sense
        # per-def-param precedent: repairRadius is per-def
        # static state, not a live frame key; tilesize is
        # the Vars constant). (2) There is NO driver tick
        # line: init() runs once at block init, not per
        # tick (the N2217 read/write + N2224 setStats
        # lifecycle precedent). One new result symbol:
        # clip_radius.
        self.assertEqual(
            ledger['N2226']['source_symbols'],
            [
                'source_repair_turret_init_state_result.clip_radius',
            ],
        )
        for name in ledger['N2226']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTurret.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/Vars.java',
                    'core/src/mindustry/world/Block.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2226']['runtime_proof'], '/root/C07RepairTurretInitProof')
        self.assertEqual(
            ledger['N2226']['tests'],
            [
                'test_c07_repair_turret_init_registration',
                'test_all_c07_repair_turret_init_input_evidence_is_exact',
                'test_repair_turret_init_state',
                'test_reference_graph_and_actual_c07_repair_turret_init',
            ],
        )
        self.assertTrue(ledger['N2226']['deferred_exprs'])

    def test_all_c07_repair_turret_init_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2226']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTurret.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2226']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_turret_init_state(self):
        repair_turret = REPAIR_TURRET_STATE.read_text(encoding='utf-8')
        # RepairTurret.init() (RepairTurret.java:83-92,
        # `public void init(){`): `updateClipRadius(repairRadius
        # + tilesize);` (:90) pins the clip radius argument to
        # repairRadius + tilesize. The coolant leg (:84-86)
        # and the consumePowerCond leg (:89) are NOT this
        # slice; `super.init();` (:91) is deferred Block.init
        # internals (the N1234 precedent). The
        # Block.updateClipRadius side effect (`clipSize =
        # Math.max(clipSize, this.size * tilesize +
        # radiusInWorldUnits * 2f);`, Block.java:1007) is
        # likewise deferred -- only the call argument is
        # pinned. repairRadius defaults to 50f
        # (RepairTurret.java:32, `public float repairRadius =
        # 50f;`); repair-point 60f (Blocks.java:6389,
        # `repairRadius = 60f;`), repair-turret 145f
        # (Blocks.java:6401, `repairRadius = 145f;`); tilesize
        # is 8 (Vars.java:135, `public static final int
        # tilesize = 8;`). There is NO driver tick line:
        # init() runs once at block init, not per tick (the
        # N2217 / N2224 lifecycle precedent).
        self.assertIn('static func source_repair_turret_init_state(repair_radius: float, tilesize: float) -> Dictionary:', repair_turret)
        self.assertIn('return {"clip_radius": clip_radius}', repair_turret)
        for expr in [
            'public void init(){',
            'updateClipRadius(repairRadius + tilesize);',
            'public float repairRadius = 50f;',
            'repairRadius = 60f;',
            'repairRadius = 145f;',
            'public static final int tilesize = 8;',
            'public void updateClipRadius(float radiusInWorldUnits){',
            'clipSize = Math.max(clipSize, this.size * tilesize + radiusInWorldUnits * 2f);',
            'public class RepairTurret extends Block{',
            'super.init();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_turret)
        # The proof's keys drive the pure function directly
        # with the per-def repairRadius values: class
        # default 50f -> 58.0, repair-point 60f -> 68.0,
        # repair-turret 145f -> 153.0 (tilesize 8 each).
        proof = REPAIR_TURRET_INIT_PROOF.read_text(encoding='utf-8')
        for key in [
            'clip_radius_default',
            'clip_radius_repair_point',
            'clip_radius_repair_turret',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_turret_init(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTurretInitProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TURRET_INIT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'clip_radius_default',
            'clip_radius_repair_point',
            'clip_radius_repair_turret',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
