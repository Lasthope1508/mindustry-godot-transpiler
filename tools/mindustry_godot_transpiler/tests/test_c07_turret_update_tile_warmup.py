import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_UPDATE_TILE_WARMUP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretUpdateTileWarmupProof.gd'


class C07TurretUpdateTileWarmupTests(unittest.TestCase):
    def test_c07_turret_update_tile_warmup_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2308']['godot_owner'], 'SourceTurretBuildState.source_turret_update_tile_warmup_state')
        # TurretBuild.updateTile() warmup advance
        # (Turret.java:502-515): `float warmupTarget =
        # (isShooting && canConsume()) || charging() ? 1f :
        # 0f;` / `if(warmupTarget > 0 && !controlled()){` /
        # `warmupHold = 1f;` / `if(warmupHold > 0f){` /
        # `warmupHold -= Time.delta / warmupMaintainTime;` /
        # `warmupTarget = 1f;` / `if(linearWarmup){` /
        # `shootWarmup = Mathf.approachDelta(shootWarmup,
        # warmupTarget, shootWarmupSpeed * (warmupTarget > 0
        # ? efficiency : 1f));` / `}else{` /
        # `shootWarmup = Mathf.lerpDelta(shootWarmup,
        # warmupTarget, shootWarmupSpeed * (warmupTarget > 0
        # ? efficiency : 1f));` on `public class
        # TurretBuild extends ReloadTurretBuild implements
        # ControlBlock{` (Turret.java:277). canConsume() is
        # the TurretBuild override (Turret.java:624-629,
        # `if(heatRequirement > 0 && heatReq <= 0f){` /
        # `return false;` / `return super.canConsume();`)
        # over the BuildingComp gate
        # (BuildingComp.java:1917-1919, `public boolean
        # canConsume(){` / `return potentialEfficiency >
        # 0;`); heatRequirement is per-def (-1f default,
        # Turret.java:53; 20f afflict / 144f malign,
        # Blocks.java:5122/6240) and heatReq is the live
        # field (Turret.java:295), refreshed each tick at
        # Turret.java:538-539 -- both arrive as explicit
        # params, so a cold heat turret (heatReq <= 0)
        # targets 0 even while shooting with power.
        # charging() is Turret.java:715-717 (`public
        # boolean charging(){` / `return queuedBullets > 0
        # && shoot.firstShotDelay > 0;`); controlled() is
        # Turret.java:441-443 (`public boolean
        # controlled(){` / `return unit.isPlayer();`). The
        # hold / warmup fields are Turret.java:286
        # (`public float shootWarmup, charge, warmupHold =
        # 0f;`); the per-def knobs are warmupMaintainTime
        # (Turret.java:84, `public float
        # warmupMaintainTime = 0f;`, 120f on titan / smite
        # / malign, Blocks.java:4803/5909/6242),
        # shootWarmupSpeed (Turret.java:136, `public float
        # shootWarmupSpeed = 0.1f;`, 0.04f on smite) and
        # linearWarmup (Turret.java:138, `public boolean
        # linearWarmup = false;`, no def sets it true).
        # The approach / lerp legs reuse the ported
        # SourceMathState helpers (N489/N490,
        # source_approach_delta / source_lerp_delta), which
        # already encode arc Mathf.approachDelta /
        # lerpDelta (arc Mathf.java:420/430). All live values
        # arrive as explicit params (the N2188 precedent):
        # is_shooting is set by updateTile :492 (not ported
        # yet), charging / controlled read reload / unit
        # state the tick frame does not track yet, and the
        # tick frame tracks no shoot_warmup / warmup_hold
        # keys yet -- so there is NO driver tick line (the
        # N2256 updateTile precedent): the driver waits
        # until those frame keys are tracked. Three new
        # result symbols: warmup_target, warmup_hold,
        # shoot_warmup.
        self.assertEqual(
            ledger['N2308']['source_symbols'],
            [
                'source_turret_update_tile_warmup_state_result.warmup_target',
                'source_turret_update_tile_warmup_state_result.warmup_hold',
                'source_turret_update_tile_warmup_state_result.shoot_warmup',
            ],
        )
        for name in ledger['N2308']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2308']['runtime_proof'], '/root/C07TurretUpdateTileWarmupProof')
        self.assertEqual(
            ledger['N2308']['tests'],
            [
                'test_c07_turret_update_tile_warmup_registration',
                'test_all_c07_turret_update_tile_warmup_input_evidence_is_exact',
                'test_turret_update_tile_warmup_state',
                'test_reference_graph_and_actual_c07_turret_update_tile_warmup',
            ],
        )
        self.assertTrue(ledger['N2308']['deferred_exprs'])
        self.assertIn(
            'Turret updateTile warmup Windows Godot proof',
            ' '.join(ledger['N2308']['deferred_exprs']),
        )

    def test_all_c07_turret_update_tile_warmup_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2308']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2308']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_update_tile_warmup_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.updateTile() warmup advance
        # (Turret.java:502-515) over the BuildingComp
        # canConsume gate (BuildingComp.java:1917-1919),
        # charging() (Turret.java:715-717) and controlled()
        # (Turret.java:441-443). The set and the decay run
        # in the SAME tick: a hold set to 1f is decayed by
        # Time.delta / warmupMaintainTime before the
        # warmupTarget = 1f force, so a fresh hold reads
        # 1 - delta/maintain, not 1. With the default
        # warmupMaintainTime 0f the Java float division
        # yields Infinity and the hold goes to -Infinity
        # in the same tick -- the pure function keeps that
        # behavior, no invented guard. The lerp leg is the
        # default (linearWarmup false on every def); the
        # approach leg is the linearWarmup branch. The
        # rate folds efficiency only while the target is
        # positive (`warmupTarget > 0 ? efficiency : 1f`),
        # so a decaying warmup ignores efficiency.
        self.assertIn('static func source_turret_update_tile_warmup_state(frame: Dictionary, is_shooting: bool, potential_efficiency: float, charging: bool, controlled: bool, warmup_hold: float, shoot_warmup: float, linear_warmup: bool, shoot_warmup_speed: float, efficiency: float, warmup_maintain_time: float, delta: float, heat_requirement: float, heat_req: float) -> Dictionary:', turret)
        self.assertIn('return {"warmup_target": warmup_target, "warmup_hold": new_warmup_hold, "shoot_warmup": new_shoot_warmup}', turret)
        for expr in [
            'float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;',
            'if(warmupTarget > 0 && !controlled()){',
            'warmupHold = 1f;',
            'if(warmupHold > 0f){',
            'warmupHold -= Time.delta / warmupMaintainTime;',
            'warmupTarget = 1f;',
            'if(linearWarmup){',
            'shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));',
            'shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));',
            'public float warmupMaintainTime = 0f;',
            'public float shootWarmupSpeed = 0.1f;',
            'public boolean linearWarmup = false;',
            'public float shootWarmup, charge, warmupHold = 0f;',
            'public boolean canConsume(){',
            'if(heatRequirement > 0 && heatReq <= 0f){',
            'public float heatRequirement = -1f;',
            'public float heatReq;',
            'return potentialEfficiency > 0;',
            'public boolean charging(){',
            'return queuedBullets > 0 && shoot.firstShotDelay > 0;',
            'public boolean controlled(){',
            'return unit.isPlayer();',
            'transient float efficiency;',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
            'warmupMaintainTime = 120f;',
            'shootWarmupSpeed = 0.04f;',
            'public void updateTile(){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function directly
        # with explicit params: shooting targets 1; idle
        # targets 0; charging targets 1; shooting with
        # potentialEfficiency 0 targets 0 (canConsume
        # false); a cold heat turret (heatRequirement 20,
        # heatReq 0) targets 0 even while shooting with
        # power; a heated one (heatReq 5) targets 1; a
        # turret with no heat requirement (-1f default)
        # ignores heatReq 0 and targets 1; an uncontrolled
        # shooter sets the hold (then decays it the same
        # tick); a controlled shooter never sets it; a
        # stale hold decays by delta/120 and forces the
        # target to 1; a hold with maintain 0 goes to
        # -Infinity; the lerp leg advances 0 -> 0.1/60;
        # the linear leg approaches 0.5 -> 0.5 + 0.1/60;
        # efficiency 0.5 halves the advance rate; a
        # decaying warmup ignores efficiency.
        proof = TURRET_UPDATE_TILE_WARMUP_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_target_shooting',
            'warmup_target_idle',
            'warmup_target_charging',
            'warmup_target_no_consume',
            'warmup_target_heat_blocked',
            'warmup_target_heat_ok',
            'warmup_target_no_heat_requirement',
            'warmup_hold_set_uncontrolled',
            'warmup_hold_not_set_controlled',
            'warmup_hold_decay_maintain_120',
            'warmup_hold_zero_maintain_infinity',
            'warmup_lerp_advance',
            'warmup_linear_approach',
            'warmup_efficiency_fold',
            'warmup_decay_ignores_efficiency',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_update_tile_warmup(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretUpdateTileWarmupProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_UPDATE_TILE_WARMUP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_target_shooting',
            'warmup_target_idle',
            'warmup_target_charging',
            'warmup_target_no_consume',
            'warmup_target_heat_blocked',
            'warmup_target_heat_ok',
            'warmup_target_no_heat_requirement',
            'warmup_hold_set_uncontrolled',
            'warmup_hold_not_set_controlled',
            'warmup_hold_decay_maintain_120',
            'warmup_hold_zero_maintain_infinity',
            'warmup_lerp_advance',
            'warmup_linear_approach',
            'warmup_efficiency_fold',
            'warmup_decay_ignores_efficiency',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
