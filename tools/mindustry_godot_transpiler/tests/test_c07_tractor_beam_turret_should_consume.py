import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TRACTOR_BEAM_STATE = ROOT / 'godot-mindustry/src/game/SourceTractorBeamTurretBuildState.gd'
TRACTOR_BEAM_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TractorBeamTurretShouldConsumeProof.gd'
TRACTOR_BEAM_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TractorBeamTurretShouldConsumeProof.tscn'


class C07TractorBeamTurretShouldConsumeTests(unittest.TestCase):
    def test_c07_tractor_beam_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2218']['godot_owner'], 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_should_consume_state')
        # N2152 gave the tractor-beam turret its live power.status
        # read -- a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO target state on the
        # tractor-beam frame, so the machinery ran with
        # should_consume=true when enabled (the MendProjector
        # suppression precedent) -- with no target requestedPower
        # is 0 so power.status reads 1.0 while Java efficiency is
        # 0. TractorBeamBuild overrides shouldConsume
        # (TractorBeamTurret.java:141-143): `return
        # super.shouldConsume() && target != null;` -- the gate
        # reads the live target AND the super default. The super
        # is the BuildingComp default `return enabled;`
        # (BuildingComp.java:755-756): the chain is
        # TractorBeamBuild (TractorBeamTurret.java:71, `public
        # class TractorBeamBuild extends BaseTurretBuild{`) ->
        # BaseTurretBuild (BaseTurret.java:113, `public class
        # BaseTurretBuild extends Building implements Ranged,
        # RotBlock{`) -> Building, and neither BaseTurret.java
        # nor ReloadTurret.java overrides shouldConsume (grep 0
        # matches). Turret.TurretBuild.shouldConsume()
        # (Turret.java:364-366, `return isShooting ||
        # reloadCounter < reload;`) is NOT in this chain -- the
        # tractor beam extends BaseTurret, NOT Turret -- so it
        # is never cited as the super. The field is `public
        # @Nullable Unit target;` (TractorBeamTurret.java:72) --
        # the target is a UNIT (the N2152 driver comment's
        # "bullet-target state" wording was sloppy; this slice
        # uses the correct word). N2218 wires the gate into
        # the tractor beam's OWN driver
        # (SourceTractorBeamTurretBuildState.gd, frame key
        # "source_tractor_beam_turret_building"): the frame
        # gets a `target` key (default null, the Java field
        # default), the pure gate returns `target != null &&
        # enabled` plus the null-ness it read, and the driver
        # feeds should_consume to the machinery, so a parallax
        # with no target folds efficiency 0 like Java. No live
        # fill sets frame["target"] yet -- the gate reads the
        # frame as-is, and the live retarget
        # (Units.closestEnemy every retargetTime 5f,
        # TractorBeamTurret.java:87-89) waits for its own slice
        # (new deferral). Two new result symbols: the gate and
        # the has_target flag it reads.
        self.assertEqual(
            ledger['N2218']['source_symbols'],
            [
                'source_tractor_beam_turret_should_consume_state_result.should_consume',
                'source_tractor_beam_turret_should_consume_state_result.has_target',
            ],
        )
        for name in ledger['N2218']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_tractor_beam_turret_should_consume_state_result.should_consume': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_should_consume_state',
                    'source_tractor_beam_turret_should_consume_state_result.has_target': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2218']['runtime_proof'], '/root/C07TractorBeamTurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2218']['tests'],
            [
                'test_c07_tractor_beam_turret_should_consume_registration',
                'test_all_c07_tractor_beam_turret_should_consume_input_evidence_is_exact',
                'test_tractor_beam_turret_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_tractor_beam_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2218']['deferred_exprs'])
        # This slice resolves the TractorBeamTurret half of the
        # merged turret-gate deferral, so the merged entry is
        # gone from DEFERRED -- while the PointDefenseTurret
        # half stays covered by the N2217 slice's own register
        # and the live retarget + coolant rows + updateTile
        # advance stay deferred under this slice's new broad
        # entry.
        self.assertFalse(any(entry.startswith('PointDefenseTurret updateTile advance / shouldConsume gate; TractorBeamTurret') for entry in ledger['N2218']['deferred_exprs']))
        self.assertTrue(any('TractorBeamTurret live target retarget' in entry for entry in ledger['N2218']['deferred_exprs']))

    def test_all_c07_tractor_beam_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2218']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_tractor_beam_turret_should_consume_state_result.should_consume': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_should_consume_state',
                    'source_tractor_beam_turret_should_consume_state_result.has_target': 'SourceTractorBeamTurretBuildState.source_tractor_beam_turret_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java',
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2218']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tractor_beam_turret_should_consume_gate_state(self):
        tractor_beam = TRACTOR_BEAM_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the tractor-beam build state:
        # TractorBeamBuild.shouldConsume()
        # (TractorBeamTurret.java:141, `public boolean
        # shouldConsume(){` with `return super.shouldConsume()
        # && target != null;`, TractorBeamTurret.java:142) --
        # the gate reads the live target AND the super default.
        # The super is the BuildingComp default (`return
        # enabled;`, BuildingComp.java:755-756): the chain is
        # TractorBeamBuild (TractorBeamTurret.java:71, `public
        # class TractorBeamBuild extends BaseTurretBuild{`) ->
        # BaseTurretBuild (BaseTurret.java:113, `public class
        # BaseTurretBuild extends Building implements Ranged,
        # RotBlock{`) -> Building; BaseTurret.java does NOT
        # override shouldConsume. Turret.TurretBuild.
        # shouldConsume() (Turret.java:364, `return isShooting
        # || reloadCounter < reload;`) is NOT in this chain.
        # The field is `public @Nullable Unit target;`
        # (TractorBeamTurret.java:72) -- the target is a UNIT.
        # The gate reads frame["enabled"] internal (the super
        # default, the N2212 RepairTurret precedent: the
        # override's super term is the enabled check, so the
        # pure gate reads both frame keys). When the gate is
        # false updateConsumption forces efficiency to zero
        # (BuildingComp.java:1960, `boolean update =
        # shouldConsume() && productionValid();` + 1992,
        # `if(!update){`). The frame carries the target
        # (frame["target"], default null for a frame bound
        # before this slice -- the Java field default); no live
        # fill sets it yet -- the live retarget
        # (Units.closestEnemy, TractorBeamTurret.java:88,
        # `target = Units.closestEnemy(team, x, y, range, u ->
        # u.checkTarget(targetAir, targetGround));`, every
        # retargetTime 5f, TractorBeamTurret.java:21, 87) is
        # the updateTile advance (TractorBeamTurret.java:78-139)
        # and waits for its own slice. The rotation and pull
        # follow the folded efficiency through eff/edelta
        # (TractorBeamTurret.java:84, `float eff = efficiency *
        # coolantMultiplier, edelta = eff * delta();`,
        # TractorBeamTurret.java:117, `rotation =
        # Angles.moveToward(rotation, dest, rotateSpeed *
        # edelta);`). The only def is parallax (size 2, range
        # 300f, Blocks.java:3640-3653, `consumePower(3.3f);`,
        # Blocks.java:3652).
        self.assertIn('static func source_tractor_beam_turret_should_consume_state', tractor_beam)
        self.assertIn('"should_consume": target != null and enabled', tractor_beam)
        self.assertIn('"has_target": target != null', tractor_beam)
        self.assertIn('public boolean shouldConsume(){', tractor_beam)
        self.assertIn('return super.shouldConsume() && target != null;', tractor_beam)
        self.assertIn('public @Nullable Unit target;', tractor_beam)
        self.assertIn('public class TractorBeamBuild extends BaseTurretBuild{', tractor_beam)
        self.assertIn('public class TractorBeamTurret extends BaseTurret{', tractor_beam)
        self.assertIn('public class BaseTurretBuild extends Building implements Ranged, RotBlock{', tractor_beam)
        self.assertIn('return enabled;', tractor_beam)
        self.assertIn('boolean update = shouldConsume() && productionValid();', tractor_beam)
        self.assertIn('if(!update){', tractor_beam)
        self.assertIn('target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));', tractor_beam)
        self.assertIn('float eff = efficiency * coolantMultiplier, edelta = eff * delta();', tractor_beam)
        self.assertIn('rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);', tractor_beam)
        self.assertIn('consumePower(3.3f);', tractor_beam)
        self.assertIn('range = 300f;', tractor_beam)
        self.assertIn('"target": null', tractor_beam)
        self.assertIn('frame["target"]', tractor_beam)
        # The driver feeds the live gate to the machinery: the
        # pure gate reads the frame target key and the gate call
        # feeds should_consume into the fold.
        self.assertIn('static func source_tractor_beam_turret_tick_buildings_state', tractor_beam)
        self.assertIn('source_tractor_beam_turret_should_consume_state(frame)', tractor_beam)
        self.assertIn('bool(gate.get("should_consume", true))', tractor_beam)
        # The documented limits record the gate as live; the old
        # N2152 deferral text is gone (including the sloppy
        # "bullet-target" wording -- the target is a unit). The
        # N2152 power row is preserved.
        self.assertIn('shouldConsume gate live (N2218)', tractor_beam)
        self.assertNotIn('runs with should_consume=true when enabled', tractor_beam)
        self.assertNotIn('bullet-target', tractor_beam)
        self.assertIn('static func source_tractor_beam_turret_power_status_row_state', tractor_beam)
        # The proof's keys drive the pure gate (true when a
        # target is present and enabled, false when the target
        # is null, false when disabled -- the gate HAS the
        # super `&& enabled` term) plus the live tick
        # (efficiency 0 when the gate is false, the N2152 power
        # fold preserved when the gate is true) plus the fresh
        # frame default (target null on bind). There are no
        # retarget / coolant / rotation / strength / laser /
        # impulse keys: the updateTile advance
        # (TractorBeamTurret.java:78-139) waits for its own
        # slice, so the eff/edelta fold
        # (TractorBeamTurret.java:84, 117) is what the
        # efficiency keys prove. Static checks: the proof
        # preloads the tractor-beam state file that exists,
        # and the scene file references the proof script that
        # exists.
        proof = TRACTOR_BEAM_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'gate_true_when_target_present',
            'gate_false_when_target_null',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_target_default_null',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertIn('preload("res://src/game/SourceTractorBeamTurretBuildState.gd")', proof)
        self.assertIn('tractor_beam_turret_build_state.source_tractor_beam_turret_should_consume_state(', proof)
        self.assertIn('tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(TRACTOR_BEAM_STATE.is_file())
        scene = TRACTOR_BEAM_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07TractorBeamTurretShouldConsumeProof.gd', scene)
        self.assertTrue(TRACTOR_BEAM_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_tractor_beam_turret_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TractorBeamTurretShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TRACTOR_BEAM_TURRET_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'gate_true_when_target_present',
            'gate_false_when_target_null',
            'gate_false_when_disabled',
            'efficiency_zero_when_gate_false',
            'efficiency_folds_power_when_gate_true',
            'frame_target_default_null',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
