import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
POINT_DEFENSE_TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd'
POINT_DEFENSE_TURRET_SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretShouldConsumeProof.gd'
POINT_DEFENSE_TURRET_SHOULD_CONSUME_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PointDefenseTurretShouldConsumeProof.tscn'


class C07PointDefenseTurretShouldConsumeTests(unittest.TestCase):
    def test_c07_point_defense_turret_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2217']['godot_owner'], 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state')
        # N2151 gave the point-defense turret its live power.status
        # read -- a pure power row over the stamped frame value,
        # folded by the shared machinery into the min efficiency
        # (BuildingComp.java:1969-1976, ConsumePower.efficiency is
        # build.power.status) -- but RED-deferred the shouldConsume
        # gate: the port tracked NO bullet-target state on the
        # point-defense frame, so the machinery ran with
        # should_consume=true when enabled -- with no target
        # requestedPower is 0 so power.status reads 1.0 while Java
        # efficiency is 0. PointDefenseBuild overrides
        # shouldConsume (PointDefenseTurret.java:105-107): `return
        # super.shouldConsume() && target != null;` -- the gate
        # reads the enabled flag through super AND the live
        # bullet target. The field is `public @Nullable Bullet
        # target;` (PointDefenseTurret.java:59) on
        # PointDefenseBuild (`public class PointDefenseBuild
        # extends ReloadTurretBuild{`, PointDefenseTurret.java:58);
        # `super` is the BuildingComp default (`return enabled;`,
        # BuildingComp.java:755-756) -- the chain runs
        # PointDefenseBuild -> ReloadTurretBuild -> BaseTurretBuild
        # -> Building, and neither ReloadTurret.java nor
        # BaseTurret.java overrides shouldConsume. Turret.
        # TurretBuild.shouldConsume() (Turret.java:364-366,
        # `return isShooting || reloadCounter < reload;`) is NOT
        # in this chain -- PointDefenseTurret extends ReloadTurret,
        # not Turret. N2217 wires the gate into the point-defense
        # turret's OWN driver (SourcePointDefenseTurretBuildState.
        # gd, frame key "source_point_defense_turret_building"):
        # the frame gets a `target` key (default null, the Java
        # field default), the pure gate returns `enabled &&
        # target != null` plus the null-ness it read, and the
        # driver feeds should_consume to the machinery, so a
        # segment with no target folds efficiency 0 like Java. No
        # live fill sets frame["target"] yet -- the gate reads the
        # frame as-is, and the live bullet-target retarget
        # (Groups.bullet scan + clear when pooled) waits for its
        # own slice (new deferral). Two new result symbols: the
        # gate and the has_target flag it reads.
        self.assertEqual(
            ledger['N2217']['source_symbols'],
            [
                'source_point_defense_turret_should_consume_state_result.should_consume',
                'source_point_defense_turret_should_consume_state_result.has_target',
            ],
        )
        for name in ledger['N2217']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_should_consume_state_result.should_consume': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state',
                    'source_point_defense_turret_should_consume_state_result.has_target': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state',
                }[name])
        self.assertEqual(ledger['N2217']['runtime_proof'], '/root/C07PointDefenseTurretShouldConsumeProof')
        self.assertEqual(
            ledger['N2217']['tests'],
            [
                'test_c07_point_defense_turret_should_consume_registration',
                'test_all_c07_point_defense_turret_should_consume_input_evidence_is_exact',
                'test_point_defense_turret_should_consume_gate_state',
                'test_reference_graph_and_actual_c07_point_defense_turret_should_consume',
            ],
        )
        self.assertTrue(ledger['N2217']['deferred_exprs'])
        # This slice resolves the point-defense half of the merged
        # turret-gate deferral, so the merged entry is gone from
        # DEFERRED -- while the TractorBeamTurret half keeps its
        # coverage in N2218's register (the merged entry is
        # replaced, per slice, by a broad live-fill entry that
        # keeps the remaining advance covered). The new broad
        # PointDefenseTurret live-fill entry is present.
        self.assertFalse(any(entry.startswith('PointDefenseTurret updateTile advance / shouldConsume gate;') for entry in ledger['N2217']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PointDefenseTurret live bullet-target retarget') for entry in ledger['N2217']['deferred_exprs']))

    def test_all_c07_point_defense_turret_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2217']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_point_defense_turret_should_consume_state_result.should_consume': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state',
                    'source_point_defense_turret_should_consume_state_result.has_target': 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2217']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_point_defense_turret_should_consume_gate_state(self):
        point_defense_turret = POINT_DEFENSE_TURRET_STATE.read_text(encoding='utf-8')
        # The pure gate lives on the point-defense-turret build
        # state: PointDefenseBuild.shouldConsume()
        # (PointDefenseTurret.java:105, `public boolean
        # shouldConsume(){` with `return super.shouldConsume() &&
        # target != null;`, PointDefenseTurret.java:106) -- the
        # gate reads the enabled flag through super AND the live
        # bullet target. The field is `public @Nullable Bullet
        # target;` (PointDefenseTurret.java:59) -- the target is a
        # BULLET, not a Unit -- on PointDefenseBuild (`public
        # class PointDefenseBuild extends ReloadTurretBuild{`,
        # PointDefenseTurret.java:58). `super` is the BuildingComp
        # default (`return enabled;`, BuildingComp.java:755-756):
        # the chain runs PointDefenseBuild -> ReloadTurretBuild
        # (ReloadTurret.java:25) -> BaseTurretBuild
        # (BaseTurret.java:113) -> Building, and neither
        # ReloadTurret.java nor BaseTurret.java overrides
        # shouldConsume, so the default applies -- the gate is
        # `enabled && target != null`, and the pure gate reads
        # frame["enabled"] too (the RepairTurret N2212 precedent:
        # the super default is read as an internal frame key).
        # Turret.TurretBuild.shouldConsume() (Turret.java:364,
        # `return isShooting || reloadCounter < reload;`) is NOT
        # in this chain -- PointDefenseTurret extends ReloadTurret
        # (PointDefenseTurret.java:19, `public class
        # PointDefenseTurret extends ReloadTurret{`), not Turret.
        # When the gate is false updateConsumption forces
        # efficiency to zero (BuildingComp.java:1960, `boolean
        # update = shouldConsume() && productionValid();` +
        # 1992, `if(!update){`). The frame carries the target
        # (frame["target"], default null for a frame bound
        # before this slice -- the Java field default); no live
        # fill sets it yet -- the live bullet-target retarget
        # (Groups.bullet scan, PointDefenseTurret.java:66,
        # `target = Groups.bullet.intersect(x - range, y -
        # range, range*2, range*2).min(b -> b.team != team &&
        # b.type().hittable, b -> b.dst2(this));`, plus the clear
        # when the bullet is pooled, PointDefenseTurret.java:70,
        # `if(target != null && !target.isAdded()){`) is the
        # updateTile advance (PointDefenseTurret.java:62-103)
        # and waits for its own slice. The rotation advance
        # (PointDefenseTurret.java:81, `rotation = Angles.
        # moveToward(rotation, dest, rotateSpeed * edelta());`)
        # follows the folded efficiency. The only def is segment
        # (Blocks.java:3835-3847): `consumePower(8f);`, `range
        # = 180f;`, `reload = 8f;`, size 2.
        self.assertIn('static func source_point_defense_turret_should_consume_state', point_defense_turret)
        self.assertIn('"should_consume": enabled and target != null', point_defense_turret)
        self.assertIn('"has_target": target != null', point_defense_turret)
        self.assertIn('public boolean shouldConsume(){', point_defense_turret)
        self.assertIn('return super.shouldConsume() && target != null;', point_defense_turret)
        self.assertIn('public @Nullable Bullet target;', point_defense_turret)
        self.assertIn('public class PointDefenseBuild extends ReloadTurretBuild{', point_defense_turret)
        self.assertIn('public class PointDefenseTurret extends ReloadTurret{', point_defense_turret)
        self.assertIn('target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', point_defense_turret)
        self.assertIn('if(target != null && !target.isAdded()){', point_defense_turret)
        self.assertIn('rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());', point_defense_turret)
        self.assertIn('boolean update = shouldConsume() && productionValid();', point_defense_turret)
        self.assertIn('if(!update){', point_defense_turret)
        self.assertIn('return enabled;', point_defense_turret)
        self.assertIn('consumePower(8f);', point_defense_turret)
        self.assertIn('range = 180f;', point_defense_turret)
        self.assertIn('reload = 8f;', point_defense_turret)
        # The Turret.java:364 trap is documented, not cited as
        # the super: TurretBuild.shouldConsume is a different
        # family and NOT in this chain.
        self.assertIn('return isShooting || reloadCounter < reload;', point_defense_turret)
        self.assertIn('Turret.java:364', point_defense_turret)
        self.assertIn('"target": null', point_defense_turret)
        self.assertIn('frame["target"]', point_defense_turret)
        # The driver feeds the live gate to the machinery: the
        # pure gate reads the frame target key and the gate call
        # feeds should_consume into the fold.
        self.assertIn('static func source_point_defense_turret_tick_buildings_state', point_defense_turret)
        self.assertIn('source_point_defense_turret_should_consume_state(frame)', point_defense_turret)
        self.assertIn('bool(gate.get("should_consume", true))', point_defense_turret)
        # The documented limits record the gate as live; the old
        # N2151 deferral text is gone. The N2151 power row is
        # preserved.
        self.assertIn('shouldConsume gate live (N2217)', point_defense_turret)
        self.assertNotIn('runs with should_consume=true when enabled', point_defense_turret)
        self.assertNotIn('No shouldConsume gate', point_defense_turret)
        self.assertNotIn('no shouldConsume gate yet', point_defense_turret)
        self.assertIn('static func source_point_defense_turret_power_status_row_state', point_defense_turret)
        # The proof's keys drive the pure gate (true when a
        # bullet target is present and enabled, false when the
        # target is null, false when disabled -- the gate reads
        # enabled through the super default) plus the live tick
        # (efficiency 0 when the gate is false, the N2151 power
        # fold preserved when the gate is true) plus the fresh
        # frame default (target null on bind). There are no
        # retarget / rotation / reload / beam keys: the updateTile
        # advance (PointDefenseTurret.java:62-103) waits for its
        # own slice, so the rotation advance
        # (PointDefenseTurret.java:81) is what the efficiency
        # keys prove. Static checks: the proof preloads the
        # point-defense-turret state file that exists, and the
        # scene file references the proof script that exists.
        proof = POINT_DEFENSE_TURRET_SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
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
        self.assertIn('preload("res://src/game/SourcePointDefenseTurretBuildState.gd")', proof)
        self.assertIn('point_defense_turret_build_state.source_point_defense_turret_should_consume_state(', proof)
        self.assertIn('point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)', proof)
        self.assertTrue(POINT_DEFENSE_TURRET_STATE.is_file())
        scene = POINT_DEFENSE_TURRET_SHOULD_CONSUME_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07PointDefenseTurretShouldConsumeProof.gd', scene)
        self.assertTrue(POINT_DEFENSE_TURRET_SHOULD_CONSUME_PROOF.is_file())

    def test_reference_graph_and_actual_c07_point_defense_turret_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PointDefenseTurretShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POINT_DEFENSE_TURRET_SHOULD_CONSUME_PROOF ')]
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
