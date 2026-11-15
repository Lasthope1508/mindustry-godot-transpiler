import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorUpdateTileProof.gd'
IMPACT_REACTOR_UPDATE_TILE_PROOF_TSCN = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorUpdateTileProof.tscn'
PLACED_POWER_GRAPH_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C07ImpactReactorUpdateTileTests(unittest.TestCase):
    def test_c07_impact_reactor_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2192']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_update_tile_advance_state')
        # N2182 wired the impact reactor's live power.status read:
        # the pure power row folds the stamped frame value into the
        # min efficiency, so the warmup gate
        # (ImpactReactor.java:79, `if(efficiency >= 0.9999f &&
        # power.status >= 0.99f){`) follows it -- but the port
        # still never advanced the warmup itself: no frame key
        # tracked warmup / totalProgress / productionEfficiency,
        # so the reactor could never warm up to
        # `productionEfficiency = Mathf.pow(warmup, 5f);`
        # (ImpactReactor.java:100), and `warmup()` /
        # `totalProgress()` / `ambientVolume()` / `sense(
        # LAccess.heat)` (ImpactReactor.java:104-121) all read a
        # warmup that never moved. N2192 is the updateTile
        # advance: a pure advance over the folded efficiency and
        # the stamped power.status, run by the driver AFTER the
        # consumption fold (BuildingComp.update(),
        # BuildingComp.java:2274 `updateConsumption();` then
        # :2277 `updateTile();`) -- in Java updateTile runs even
        # when disabled (BuildingComp.java:2276, `if(enabled ||
        # !block.noUpdateDisabled){`, default false,
        # Block.java:170 -- ImpactReactor sets no override, so the
        # OR holds via !noUpdateDisabled); the port driver gates
        # the advance on enabled only because the driver does not
        # model the disabled efficiency-zeroing yet (see the
        # driver comment in SourceImpactReactorBuildState.gd).
        # The warmup lerps toward 1 at warmupSpeed * timeScale
        # (ImpactReactor.java:82, warmupSpeed 0.001f class
        # default, ImpactReactor.java:19, NOT overridden by the
        # single impact-reactor def, Blocks.java:2632-2645),
        # snaps to 1f when Mathf.equal(warmup, 1f, 0.001f)
        # (ImpactReactor.java:83-84), decays toward 0 at 0.01f
        # when the gate fails (ImpactReactor.java:95),
        # totalProgress accumulates warmup * Time.delta
        # (ImpactReactor.java:98, Time.delta is seconds * 60,
        # arc Time.java:26, the N2093 pump precedent), and
        # productionEfficiency is pow(warmup, 5f)
        # (ImpactReactor.java:100). DEFERRED, not done here:
        # the first-production event (ImpactReactor.java:87-88,
        # `Events.fire(Trigger.impactPower);` -- needs
        # getPowerProduction() and consPower.requestedPower(this)
        # from the power graph, which the port does not model
        # yet) and the consume timer (ImpactReactor.java:91-92,
        # `if(timer(timerUse, itemDuration / timeScale)){` with
        # `consume();` -- needs timer + item/liquid consumption
        # infrastructure). The producer fold
        # (PowerGenerator.java:156-158, `return enabled ?
        # powerProduction * productionEfficiency : 0f;`) does
        # NOT read the new production_efficiency frame key yet:
        # the key is tracked here and waits for its consumer
        # slice. Three new result symbols: the advanced warmup,
        # totalProgress and productionEfficiency.
        self.assertEqual(
            ledger['N2192']['source_symbols'],
            [
                'source_impact_reactor_update_tile_advance_state_result.warmup',
                'source_impact_reactor_update_tile_advance_state_result.total_progress',
                'source_impact_reactor_update_tile_advance_state_result.production_efficiency',
            ],
        )
        for name in ledger['N2192']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/power/ImpactReactor.java')
                self.assertEqual(symbol['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_update_tile_advance_state')
        self.assertEqual(ledger['N2192']['runtime_proof'], '/root/C07ImpactReactorUpdateTileProof')
        self.assertEqual(
            ledger['N2192']['tests'],
            [
                'test_c07_impact_reactor_update_tile_registration',
                'test_all_c07_impact_reactor_update_tile_input_evidence_is_exact',
                'test_impact_reactor_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_impact_reactor_update_tile',
            ],
        )
        self.assertTrue(ledger['N2192']['deferred_exprs'])
        # This slice resolves the updateTile advance deferral the
        # N2182/N2185 registers carried -- it must be gone --
        # and records the two halves it still defers.
        self.assertFalse(any(entry.startswith('ImpactReactor updateTile advance (warmup lerp / prevOut') for entry in ledger['N2192']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor impactPower event rows') for entry in ledger['N2192']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor consume-timer rows') for entry in ledger['N2192']['deferred_exprs']))

    def test_all_c07_impact_reactor_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2192']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_update_tile_advance_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/power/ImpactReactor.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/power/PowerGenerator.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/Block.java'),
            ('mindustry-upstream', 'core/src/mindustry/content/Blocks.java'),
            ('arc-upstream', 'arc-core/src/arc/math/Mathf.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Time.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2192']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_update_tile_advance_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the impact-reactor
        # build state: the warmup gate (ImpactReactor.java:79,
        # `if(efficiency >= 0.9999f && power.status >= 0.99f){`,
        # keep on ONE comment line, the N2148 shootWarmup
        # lesson: a split line fails this test) decides the
        # lerp direction; the warmup lerps toward 1 at
        # warmupSpeed * timeScale (ImpactReactor.java:82) and
        # snaps to 1f when Mathf.equal(warmup, 1f, 0.001f)
        # (ImpactReactor.java:83-84), or decays toward 0 at
        # 0.01f when the gate fails (ImpactReactor.java:95);
        # totalProgress accumulates warmup * Time.delta
        # (ImpactReactor.java:98) and productionEfficiency is
        # pow(warmup, 5f) (ImpactReactor.java:100). The advance
        # runs AFTER the consumption fold (BuildingComp.update(),
        # BuildingComp.java:2274/:2277) -- in Java updateTile runs
        # even when disabled (BuildingComp.java:2276, `if(enabled ||
        # !block.noUpdateDisabled){`, default false,
        # Block.java:170); the port driver gates the advance on
        # enabled only because the driver does not model the
        # disabled efficiency-zeroing yet (see the driver comment
        # in SourceImpactReactorBuildState.gd). Mathf.lerpDelta is `return lerp(
        # fromValue, toValue, clamp(progress * Time.delta));`
        # (Mathf.java:430-431), ported as
        # SourceMathState.source_lerp_delta; Mathf.equal is
        # `return Math.abs(a - b) <= tolerance;`
        # (Mathf.java:554-555), inlined as absf(warmup - 1.0)
        # <= 0.001 because the port has no Mathf.equal helper;
        # Mathf.pow is `return (float)Math.pow(a, b);`
        # (Mathf.java:212-213), Godot pow(). Time.delta is the
        # frame delta in 60fps ticks (`Math.min(Core.graphics.
        # getDeltaTime() * 60f, 3f)`, arc Time.java:26), so the
        # driver passes seconds * 60 (the N2093 pump
        # precedent). The frame carries the build fields
        # (`public float warmup, totalProgress;`,
        # ImpactReactor.java:75, both 0f by default) plus the
        # folded efficiency (1.0 before the first fold -- the
        # cheating / no-consumer early return sets it to 1f
        # when enabled, BuildingComp.java:1945-1947) and the
        # stamped power.status (1.0 when missing, the assembler
        # fold). timeScale is the sprite-meta timeScale
        # (BuildingComp.java:98, `private transient float
        # timeScale = 1f, timeScaleDuration;`, read as `return
        # timeScale;`, BuildingComp.java:599-600, default 1.0).
        # DEFERRED: the first-production event
        # (ImpactReactor.java:80, `boolean prevOut = consPower
        # != null && getPowerProduction() <=
        # consPower.requestedPower(this);` with
        # ImpactReactor.java:87-88, `Events.fire(Trigger.
        # impactPower);`) and the consume timer
        # (ImpactReactor.java:91, `if(timer(timerUse,
        # itemDuration / timeScale)){` with
        # ImpactReactor.java:92, `consume();`). The producer
        # fold (`return enabled ? powerProduction *
        # productionEfficiency : 0f;`,
        # PowerGenerator.java:156-158) does NOT read the new
        # frame key yet.
        self.assertIn('static func source_impact_reactor_update_tile_advance_state(frame: Dictionary, time_scale: float, source_delta: float) -> Dictionary:', impact_reactor)
        self.assertIn('const source_math_state := preload("res://src/game/SourceMathState.gd")', impact_reactor)
        self.assertIn('const SOURCE_IMPACT_REACTOR_WARMUP_SPEED := 0.001', impact_reactor)
        self.assertIn('public float warmup, totalProgress;', impact_reactor)
        self.assertIn('public float warmupSpeed = 0.001f;', impact_reactor)
        self.assertIn('if(efficiency >= 0.9999f && power.status >= 0.99f){', impact_reactor)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 1f, warmupSpeed * timeScale);', impact_reactor)
        self.assertIn('if(Mathf.equal(warmup, 1f, 0.001f)){', impact_reactor)
        self.assertIn('warmup = 1f;', impact_reactor)
        self.assertIn('boolean prevOut = consPower != null && getPowerProduction() <= consPower.requestedPower(this);', impact_reactor)
        self.assertIn('if(!prevOut && consPower != null && (getPowerProduction() > consPower.requestedPower(this))){', impact_reactor)
        self.assertIn('Events.fire(Trigger.impactPower);', impact_reactor)
        self.assertIn('if(timer(timerUse, itemDuration / timeScale)){', impact_reactor)
        self.assertIn('consume();', impact_reactor)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, 0f, 0.01f);', impact_reactor)
        self.assertIn('totalProgress += warmup * Time.delta;', impact_reactor)
        self.assertIn('productionEfficiency = Mathf.pow(warmup, 5f);', impact_reactor)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', impact_reactor)
        self.assertIn('return Math.abs(a - b) <= tolerance;', impact_reactor)
        self.assertIn('return (float)Math.pow(a, b);', impact_reactor)
        self.assertIn('Math.min(Core.graphics.getDeltaTime() * 60f, 3f)', impact_reactor)
        self.assertIn('public float warmup(){', impact_reactor)
        self.assertIn('public float totalProgress(){', impact_reactor)
        self.assertIn('public float productionEfficiency = 0.0f;', impact_reactor)
        self.assertIn('return enabled ? powerProduction * productionEfficiency : 0f;', impact_reactor)
        self.assertIn('updateConsumption();', impact_reactor)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', impact_reactor)
        self.assertIn('public boolean noUpdateDisabled = false;', impact_reactor)
        self.assertIn('if(!block.hasConsumers || cheating()){', impact_reactor)
        self.assertIn('efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;', impact_reactor)
        self.assertIn('private transient float timeScale = 1f, timeScaleDuration;', impact_reactor)
        self.assertIn('return timeScale;', impact_reactor)
        self.assertIn('itemDuration = 140f;', impact_reactor)
        self.assertIn('powerProduction = 130f;', impact_reactor)
        self.assertIn('consumePower(25f);', impact_reactor)
        # The advance itself: lerpDelta toward 1 at warmupSpeed
        # * timeScale with the 0.001 snap, lerpDelta toward 0
        # at 0.01 when the gate fails, totalProgress += warmup
        # * source_delta, productionEfficiency = pow(warmup, 5).
        self.assertIn('source_math_state.source_lerp_delta(warmup, 1.0, SOURCE_IMPACT_REACTOR_WARMUP_SPEED * time_scale, source_delta)', impact_reactor)
        self.assertIn('if absf(warmup - 1.0) <= 0.001:', impact_reactor)
        self.assertIn('source_math_state.source_lerp_delta(warmup, 0.0, 0.01, source_delta)', impact_reactor)
        self.assertIn('total_progress += warmup * source_delta', impact_reactor)
        self.assertIn('pow(warmup, 5.0)', impact_reactor)
        self.assertIn('return {"warmup": warmup, "total_progress": total_progress, "production_efficiency": production_efficiency}', impact_reactor)
        # The driver runs the advance after the consumption fold,
        # gated on enabled (port-only gate -- in Java updateTile
        # runs even when disabled; see the driver comment),
        # with the sprite-meta timeScale and
        # seconds * 60 as Time.delta -- and writes all three
        # frame keys back.
        self.assertIn('source_impact_reactor_update_tile_advance_state(frame, source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game)), source_placed_block_state.game_source_delta(game, seconds))', impact_reactor)
        self.assertIn('frame["warmup"] = advance.get("warmup", 0.0)', impact_reactor)
        self.assertIn('frame["total_progress"] = advance.get("total_progress", 0.0)', impact_reactor)
        self.assertIn('frame["production_efficiency"] = advance.get("production_efficiency", 0.0)', impact_reactor)
        # The documented limits record the advance as done and
        # the event / timer as still deferred.
        self.assertIn('updateTile warmup / production advance DONE (N2192)', impact_reactor)
        self.assertIn('No producer-side fold yet', impact_reactor)
        placed_power_graph = PLACED_POWER_GRAPH_STATE.read_text(encoding='utf-8')
        self.assertIn('"source_impact_reactor_building"', placed_power_graph)
        factory_runtime = FACTORY_RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_impact_reactor_tick_buildings_state(game, delta)', factory_runtime)
        # The proof's keys drive the advance (rise / snap /
        # decay / totalProgress / pow-5) plus the live tick,
        # which keeps the old power-status behaviour (efficiency
        # folds the power min) and advances the warmup.
        proof = IMPACT_REACTOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'warmup_rises_toward_one',
            'warmup_snaps_to_one',
            'warmup_decays_toward_zero',
            'total_progress_advances',
            'production_efficiency_pow_five',
            'live_tick_keeps_power_row_and_advances',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof checks (BRIEF-COMMON): every preload in
        # the proof points at a file that exists, and the scene
        # loads this proof script.
        for preload_path in re.findall(r'preload\("(res://[^"]+)"\)', proof):
            with self.subTest(preload=preload_path):
                self.assertTrue((ROOT / 'godot-mindustry' / preload_path[len('res://'):]).is_file(), preload_path)
        tscn = IMPACT_REACTOR_UPDATE_TILE_PROOF_TSCN.read_text(encoding='utf-8')
        self.assertIn('res://tools/runtime_proofs/C07ImpactReactorUpdateTileProof.gd', tscn)

    def test_reference_graph_and_actual_c07_impact_reactor_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'warmup_rises_toward_one',
            'warmup_snaps_to_one',
            'warmup_decays_toward_zero',
            'total_progress_advances',
            'production_efficiency_pow_five',
            'live_tick_keeps_power_row_and_advances',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
