import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BEAM_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBeamDrillBuildState.gd'
BEAM_DRILL_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillUpdateTileProof.gd'
BEAM_DRILL_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BeamDrillUpdateTileProof.tscn'


class C07BeamDrillUpdateTileTests(unittest.TestCase):
    def test_c07_beam_drill_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2195']['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_update_tile_advance_state')
        # N2155 proved the BeamDrill family's live power read: the
        # tick folds power.status into the min efficiency and the
        # lastDrillSpeed fold (BeamDrill.java:249) follows it --
        # but the port tracked no warmup / boostWarmup / time at
        # all, so a beam drill never accumulated time toward
        # drillTime and never dropped anything. N2195 is the
        # updateTile advance (BeamDrill.java:237-263, the
        # internal part): warmup approachDelta toward
        # num(efficiency > 0), the boost multiplier lerp(1, 2.5,
        # optionalEfficiency), boostWarmup lerpDelta toward
        # optionalEfficiency, and time += edelta() * multiplier.
        # optionalEfficiency is already folded by the shared
        # machinery (apply_update_consumption_state stamps
        # frame["optional_efficiency"]; with no optional rows
        # modeled yet it is min(1.0, minEfficiency), the Java
        # default for zero optional consumers,
        # BuildingComp.java:1965/1986), so no blocker. The drop
        # loop + time reset + lastDrillSpeed wait: the port
        # tracks no lastItem (set by updateFacing,
        # BeamDrill.java:376-411, deferred), so time grows
        # unbounded -- a documented consequence, the LaunchPad
        # counter-freeze precedent. updateLasers / updateFacing /
        # the dump timer wait for their own slices.
        # Four new result symbols: the advanced frame values.
        self.assertEqual(
            ledger['N2195']['source_symbols'],
            [
                'source_beam_drill_update_tile_advance_state_result.warmup',
                'source_beam_drill_update_tile_advance_state_result.boost_warmup',
                'source_beam_drill_update_tile_advance_state_result.multiplier',
                'source_beam_drill_update_tile_advance_state_result.time',
            ],
        )
        for name in ledger['N2195']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BeamDrill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_update_tile_advance_state')
        self.assertEqual(ledger['N2195']['runtime_proof'], '/root/C07BeamDrillUpdateTileProof')
        self.assertEqual(
            ledger['N2195']['tests'],
            [
                'test_c07_beam_drill_update_tile_registration',
                'test_all_c07_beam_drill_update_tile_input_evidence_is_exact',
                'test_beam_drill_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_beam_drill_update_tile',
            ],
        )
        self.assertTrue(ledger['N2195']['deferred_exprs'])

    def test_all_c07_beam_drill_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2195']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBeamDrillBuildState.source_beam_drill_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BeamDrill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2195']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_beam_drill_update_tile_advance_state(self):
        beam_drill = BEAM_DRILL_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the beam-drill build state:
        # warmup approachDelta (BeamDrill.java:242), the boost
        # multiplier (BeamDrill.java:246), boostWarmup lerpDelta
        # (BeamDrill.java:248), time += edelta() * multiplier
        # (BeamDrill.java:251). Keep each Java expr on ONE comment
        # line (the N2148 shootWarmup lesson: a split line fails
        # this test). The Arc formulas are approachDelta(from, to,
        # speed) = approach(from, to, Time.delta * speed) with
        # approach = from + clamp(to - from, -speed, speed),
        # lerpDelta = lerp(from, to, clamp(progress * Time.delta)),
        # lerp = from + (to - from) * progress, num(b) = b ? 1 : 0
        # (Mathf.java:208-210, 415-432); Time.delta in the port is
        # seconds * 60 through game_source_delta (arc Time.java:26,
        # `Math.min(Core.graphics.getDeltaTime() * 60f, 3f)`), never
        # raw seconds (the N2186/N2187/N2191 lesson: raw seconds
        # run 60x slow).
        self.assertIn('static func source_beam_drill_update_tile_advance_state', beam_drill)
        self.assertIn('warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 60f);', beam_drill)
        self.assertIn('float multiplier = Mathf.lerp(1f, optionalBoostIntensity, optionalEfficiency);', beam_drill)
        self.assertIn('boostWarmup = Mathf.lerpDelta(boostWarmup, optionalEfficiency, 0.1f);', beam_drill)
        self.assertIn('time += edelta() * multiplier;', beam_drill)
        # optionalBoostIntensity is the class default 2.5f
        # (BeamDrill.java:44); neither def overrides it
        # (Blocks.java:3038-3061 only override drillTime, 160f /
        # 100f), so both defs share the 2.5 boost.
        self.assertIn('SOURCE_BEAM_DRILL_OPTIONAL_BOOST_INTENSITY := 2.5', beam_drill)
        self.assertIn('public float optionalBoostIntensity = 2.5f;', beam_drill)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs only when
        # enabled (BuildingComp.java:2277-2279, `if(enabled ||
        # !block.noUpdateDisabled){ updateTile(); }`, and
        # noUpdateDisabled defaults false, Block.java:170).
        # super.updateTile() is an empty no-op
        # (BuildingComp.java:2010-2012), so the driver owes it
        # nothing.
        self.assertIn('game_source_delta(game, seconds)', beam_drill)
        self.assertIn('time_scale(sprite', beam_drill)
        self.assertIn('source_beam_drill_update_tile_advance_state(frame, source_delta, time_scale)', beam_drill)
        self.assertIn('frame["warmup"]', beam_drill)
        self.assertIn('frame["boost_warmup"]', beam_drill)
        self.assertIn('frame["multiplier"]', beam_drill)
        self.assertIn('frame["time"]', beam_drill)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', beam_drill)
        # The documented limits now record the advance as done
        # and the remaining deferrals (updateLasers/updateFacing,
        # drop loop + time reset + lastDrillSpeed, dump timer);
        # time grows unbounded until the reset slice lands.
        self.assertIn('time grows unbounded', beam_drill)
        # The proof's keys drive the pure advance (warmup up/down,
        # boostWarmup lerp, multiplier lerp, time advance) plus
        # the live tick (warmup + time advance on a placed
        # plasma-bore, efficiency still folding power.status).
        proof = BEAM_DRILL_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_approaches_one_when_powered',
            'warmup_decays_to_zero_without_power',
            'boost_warmup_lerps_to_optional_efficiency',
            'multiplier_lerps_boost_intensity',
            'time_advances_by_edelta_times_multiplier',
            'live_tick_advances_warmup_and_time',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBeamDrillBuildState.gd")', proof)
        self.assertTrue(BEAM_DRILL_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = BEAM_DRILL_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BeamDrillUpdateTileProof.gd', scene)
        self.assertIn('C07BeamDrillUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_beam_drill_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BeamDrillUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BEAM_DRILL_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_approaches_one_when_powered',
            'warmup_decays_to_zero_without_power',
            'boost_warmup_lerps_to_optional_efficiency',
            'multiplier_lerps_boost_intensity',
            'time_advances_by_edelta_times_multiplier',
            'live_tick_advances_warmup_and_time',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
