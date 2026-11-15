import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REGEN_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceRegenProjectorBuildState.gd'
REGEN_PROJECTOR_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorUpdateTileProof.gd'
REGEN_PROJECTOR_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RegenProjectorUpdateTileProof.tscn'


class C07RegenProjectorUpdateTileTests(unittest.TestCase):
    def test_c07_regen_projector_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2228']['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_tile_advance_state')
        # N2160 proved the RegenProjector family's live power read
        # and N2214 the shouldConsume gate (return anyTargets, no
        # enabled term) -- but the port tracked no warmup /
        # totalTime / optionalTimer / didRegen / mendMap at all,
        # so a regen-projector never advanced its warmup, never
        # accumulated mend amounts, and any_targets only ever
        # changed when a test seeded it. N2228 is the updateTile
        # advance (RegenProjectorBuild.updateTile(),
        # RegenProjector.java:122-179): lastChange refresh on
        # tileChanges, warmup approachDelta toward (didRegen ? 1
        # : 0) at 1f/70f, totalTime += warmup * Time.delta, the
        # suppression early return, anyTargets =
        # targets.contains(damaged), the efficiency-gated
        # optionalTimer advance + consume threshold + reset, the
        # healAmount lerp fold, and the mendMap accumulation over
        # damaged, non-heal-suppressed targets. The indexer
        # updateTargets query has no helper in the port, so the
        # pure advance takes targets as the frame input (each
        # entry: pos, block_health, health, damaged,
        # heal_suppressed; default []); suppressed (default
        # false) and tile_changes (default 1, the Java
        # World.tileChanges initial value) are frame inputs too.
        # consume() defers (it triggers every consumer --
        # ConsumeItems.trigger removes phaseFabric -- and the
        # frame tracks no items, the N2193 precedent), but the
        # optionalTimer advance + reset is modeled and the tick
        # where consume() would fire is reported as `consumed`.
        # The mendMap flush defers whole (application + cadence):
        # mendMap is static-shared across projectors and the
        # flush heals live buildings via world.build(pos), which
        # the port has no frames for. Nine new result symbols.
        self.assertEqual(
            ledger['N2228']['source_symbols'],
            [
                'source_regen_projector_update_tile_advance_state_result.last_change',
                'source_regen_projector_update_tile_advance_state_result.warmup',
                'source_regen_projector_update_tile_advance_state_result.total_time',
                'source_regen_projector_update_tile_advance_state_result.optional_timer',
                'source_regen_projector_update_tile_advance_state_result.did_regen',
                'source_regen_projector_update_tile_advance_state_result.any_targets',
                'source_regen_projector_update_tile_advance_state_result.mend_map',
                'source_regen_projector_update_tile_advance_state_result.heal_amount',
                'source_regen_projector_update_tile_advance_state_result.consumed',
            ],
        )
        for name in ledger['N2228']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/RegenProjector.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_tile_advance_state')
        self.assertEqual(ledger['N2228']['runtime_proof'], '/root/C07RegenProjectorUpdateTileProof')
        self.assertEqual(
            ledger['N2228']['tests'],
            [
                'test_c07_regen_projector_update_tile_registration',
                'test_all_c07_regen_projector_update_tile_input_evidence_is_exact',
                'test_regen_projector_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_regen_projector_update_tile',
            ],
        )
        self.assertTrue(ledger['N2228']['deferred_exprs'])
        # This slice resolves the N2160 RegenProjector updateTile
        # advance deferral, so the advance entry is gone from
        # DEFERRED -- while the live-fill entry (updateTargets
        # query + consume() + mendMap flush + effect chance +
        # suppression fill + disabled early return) takes its
        # place. The N2214 targets-computation live-fill entry
        # stays: its live-fill half is still true (no live fill
        # sets the targets list), even though the
        # contains-damaged fold it names now runs in this
        # advance -- the N2223 precedent (the WallCrafter frame
        # items intake entry stayed verbatim after N2223 landed
        # the offload).
        self.assertFalse(any(entry.startswith('RegenProjector updateTile advance (') for entry in ledger['N2228']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector updateTile live fill (') for entry in ledger['N2228']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector targets computation live fill (') for entry in ledger['N2228']['deferred_exprs']))

    def test_all_c07_regen_projector_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2228']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRegenProjectorBuildState.source_regen_projector_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/RegenProjector.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/core/World.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2228']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_regen_projector_update_tile_advance_state(self):
        regen_projector = REGEN_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the regen-projector build
        # state: the lastChange refresh (RegenProjector.java:
        # 123-125), warmup approachDelta (RegenProjector.java:
        # 129), totalTime (RegenProjector.java:130), the
        # didRegen / anyTargets reset (RegenProjector.java:
        # 131-132), the suppression early return
        # (RegenProjector.java:135-137), the contains-damaged
        # fold (RegenProjector.java:139), the efficiency gate
        # (RegenProjector.java:141), the optionalTimer advance +
        # consume threshold + reset (RegenProjector.java:
        # 142-144), the healAmount fold (RegenProjector.java:
        # 147), the mendMap accumulation (RegenProjector.java:
        # 150-158), the effect chance (RegenProjector.java:160,
        # deferred) and the flush (RegenProjector.java:168-177,
        # deferred). Keep each Java expr on ONE comment line
        # (the N2148 shootWarmup lesson: a split line fails
        # this test). Cite corrections (all verified by grep at
        # this pin -- the N2160 driver and the scope brief drift
        # on every one of them): updateTile is 122-179, the heal
        # gate is :141 (not :142), healAmount is :147 (not
        # :148), the suppression return is :135-137 (not :137),
        # optionalMultiplier / optionalUseTime are :29-30 (not
        # :36-37), mendMap / taken / lastUpdateFrame are :22-24
        # (not :29-31), effectChance is :35 (not :40-41), the
        # class is `public class RegenProjector extends Block{`
        # at :20 (not :29), range = 28 is Blocks.java:2012 (not
        # :2011) and healPercent = 4f / 60f is Blocks.java:2019
        # (not :2018). The Arc formulas are approachDelta(from,
        # to, speed) = approach(from, to, Time.delta * speed)
        # with approach = from + clamp(to - from, -speed,
        # speed), lerp = from + (to - from) * progress, num(b) =
        # b ? 1 : 0 (Mathf.java:208, 415-427); Time.delta in the
        # port is seconds * 60 through game_source_delta (arc
        # Time.java:26), never raw seconds (the
        # N2186/N2187/N2191 lesson: raw seconds run 60x slow).
        # totalTime uses the UNSCALED Time.delta
        # (RegenProjector.java:130), while edelta() = efficiency
        # * delta() with delta() = Time.delta * timeScale
        # (BuildingComp.java:1922-1929).
        self.assertIn('static func source_regen_projector_update_tile_advance_state', regen_projector)
        self.assertIn('if(lastChange != world.tileChanges){', regen_projector)
        self.assertIn('lastChange = world.tileChanges;', regen_projector)
        self.assertIn('warmup = Mathf.approachDelta(warmup, didRegen ? 1f : 0f, 1f / 70f);', regen_projector)
        self.assertIn('totalTime += warmup * Time.delta;', regen_projector)
        self.assertIn('didRegen = false;', regen_projector)
        self.assertIn('anyTargets = false;', regen_projector)
        self.assertIn('if(checkSuppression()){', regen_projector)
        self.assertIn('anyTargets = targets.contains(b -> b.damaged());', regen_projector)
        self.assertIn('if(efficiency > 0){', regen_projector)
        self.assertIn('if((optionalTimer += edelta() * optionalEfficiency) >= optionalUseTime){', regen_projector)
        self.assertIn('consume();', regen_projector)
        self.assertIn('optionalTimer = 0f;', regen_projector)
        self.assertIn('float healAmount = Mathf.lerp(1f, optionalMultiplier, optionalEfficiency) * healPercent;', regen_projector)
        self.assertIn('for(var build : targets){', regen_projector)
        self.assertIn('if(!build.damaged() || build.isHealSuppressed()) continue;', regen_projector)
        self.assertIn('didRegen = true;', regen_projector)
        self.assertIn('int pos = build.pos();', regen_projector)
        self.assertIn('float value = mendMap.get(pos);', regen_projector)
        self.assertIn('mendMap.put(pos, Math.min(Math.max(value, healAmount * edelta() * build.block.health / 100f), build.block.health - build.health));', regen_projector)
        self.assertIn('if(value <= 0 && Mathf.chanceDelta(effectChance * build.block.size * build.block.size)){', regen_projector)
        self.assertIn('if(lastUpdateFrame != state.updateId){', regen_projector)
        self.assertIn('lastUpdateFrame = state.updateId;', regen_projector)
        self.assertIn('build.heal(entry.value);', regen_projector)
        self.assertIn('mendMap.clear();', regen_projector)
        self.assertIn('public Seq<Building> targets = new Seq<>();', regen_projector)
        self.assertIn('public int lastChange = -2;', regen_projector)
        self.assertIn('public float warmup, totalTime, optionalTimer;', regen_projector)
        self.assertIn('public boolean anyTargets = false;', regen_projector)
        self.assertIn('public boolean didRegen = false;', regen_projector)
        self.assertIn('private static final IntFloatMap mendMap = new IntFloatMap();', regen_projector)
        self.assertIn('public float healPercent = 12f / 60f;', regen_projector)
        self.assertIn('public float optionalMultiplier = 2f;', regen_projector)
        self.assertIn('public float optionalUseTime = 60f * 8f;', regen_projector)
        self.assertIn('healPercent = 4f / 60f;', regen_projector)
        self.assertIn('public int tileChanges = 1, floorChanges = 1;', regen_projector)
        self.assertIn('public boolean isHealSuppressed(){', regen_projector)
        self.assertIn('return block.suppressable && Time.time <= healSuppressionTime;', regen_projector)
        # The def values are driver constants (single def --
        # regen-projector; the catalog carries no healPercent):
        # healPercent 4f/60f (Blocks.java:2019, the def override
        # of the class 12f/60f), optionalMultiplier 2f and
        # optionalUseTime 60f * 8f = 480f (RegenProjector.java:
        # 29-30, class values, no def override), warmup speed
        # 1f/70f (RegenProjector.java:129).
        self.assertIn('SOURCE_REGEN_PROJECTOR_WARMUP_SPEED := 1.0 / 70.0', regen_projector)
        self.assertIn('SOURCE_REGEN_PROJECTOR_HEAL_PERCENT := 4.0 / 60.0', regen_projector)
        self.assertIn('SOURCE_REGEN_PROJECTOR_OPTIONAL_MULTIPLIER := 2.0', regen_projector)
        self.assertIn('SOURCE_REGEN_PROJECTOR_OPTIONAL_USE_TIME := 480.0', regen_projector)
        # The driver wires the advance into the live tick: the
        # source delta is game_source_delta(game, seconds) and
        # timeScale reads live from the sprite meta
        # (SourcePlacedBlockState.time_scale, default 1.0,
        # BuildingComp.java:98 `private transient float timeScale
        # = 1f, timeScaleDuration;`); the advance runs after
        # consumption, like Java's Building.update()
        # (BuildingComp.java:2274 updateConsumption(), then the
        # updateTile gate `if(enabled || !block.noUpdateDisabled){`
        # at BuildingComp.java:2276-2277; noUpdateDisabled
        # defaults false, Block.java:170, so Java runs updateTile
        # even when disabled -- the port keeps the enabled gate
        # as a pragmatic choice, the N2195 coordinator-fix
        # precedent, because the driver skips the consumption
        # fold when disabled and the frame efficiency goes stale).
        # super.updateTile() is an empty no-op
        # (BuildingComp.java:2010-2012), so the driver owes it
        # nothing.
        self.assertIn('game_source_delta(game, seconds)', regen_projector)
        self.assertIn('time_scale(sprite', regen_projector)
        self.assertIn('source_regen_projector_update_tile_advance_state(frame, source_delta, time_scale)', regen_projector)
        self.assertIn('frame["warmup"]', regen_projector)
        self.assertIn('frame["total_time"]', regen_projector)
        self.assertIn('frame["optional_timer"]', regen_projector)
        self.assertIn('frame["did_regen"]', regen_projector)
        self.assertIn('frame["any_targets"]', regen_projector)
        self.assertIn('frame["mend_map"]', regen_projector)
        self.assertIn('frame["heal_amount"]', regen_projector)
        self.assertIn('frame["consumed"]', regen_projector)
        self.assertIn('frame["last_change"]', regen_projector)
        self.assertIn('if(enabled || !block.noUpdateDisabled){', regen_projector)
        # The deferred live fills arrive as frame inputs with
        # Java-faithful defaults: no supplied targets means an
        # empty list, no suppression state means not suppressed,
        # and tileChanges starts at 1 (World.java:35) against
        # lastChange -2 (RegenProjector.java:110), so the first
        # tick refreshes.
        self.assertIn('frame.get("targets", [])', regen_projector)
        self.assertIn('frame.get("mend_map", {})', regen_projector)
        self.assertIn('frame.get("suppressed", false)', regen_projector)
        self.assertIn('frame.get("tile_changes", 1)', regen_projector)
        self.assertIn('frame.get("last_change", -2)', regen_projector)
        # The fresh frame binds the new state keys with the Java
        # field defaults.
        self.assertIn('"warmup": 0.0', regen_projector)
        self.assertIn('"total_time": 0.0', regen_projector)
        self.assertIn('"optional_timer": 0.0', regen_projector)
        self.assertIn('"did_regen": false', regen_projector)
        self.assertIn('"targets": []', regen_projector)
        self.assertIn('"mend_map": {}', regen_projector)
        self.assertIn('"last_change": -2', regen_projector)
        # The documented limits now record the advance as done
        # and the remaining deferrals (updateTargets live query,
        # consume(), mendMap flush, effect chance, suppression
        # fill, disabled early return); the shouldConsume gate
        # stays live (N2214) and the N2160 power row is
        # preserved.
        self.assertIn('updateTile advance live (N2228)', regen_projector)
        self.assertNotIn('No updateTile advance', regen_projector)
        self.assertIn('shouldConsume gate live (N2214)', regen_projector)
        self.assertIn('static func source_regen_projector_power_status_row_state', regen_projector)
        self.assertIn('static func source_regen_projector_should_consume_state', regen_projector)
        # The proof's keys drive the pure advance (the
        # contains-damaged fold + lastChange refresh, the
        # mendMap accumulation with the max/cap, the warmup
        # approach + totalTime, the optionalTimer advance +
        # consume threshold + reset, the suppression early
        # return with its warmup/totalTime still advancing)
        # plus the live tick (fresh-frame defaults + a seeded
        # damaged target advancing warmup / mend_map /
        # optional_timer on a placed regen-projector, efficiency
        # still folding power.status).
        proof = REGEN_PROJECTOR_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'any_targets_folds_damaged_targets',
            'mend_map_accumulates_heal_amount',
            'warmup_approaches_one_when_regen',
            'optional_timer_advances_and_resets',
            'no_heal_when_suppressed',
            'live_tick_advances_regen_frame',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceRegenProjectorBuildState.gd")', proof)
        self.assertTrue(REGEN_PROJECTOR_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = REGEN_PROJECTOR_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RegenProjectorUpdateTileProof.gd', scene)
        self.assertIn('C07RegenProjectorUpdateTileProof', scene)

    def test_reference_graph_and_actual_c07_regen_projector_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RegenProjectorUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REGEN_PROJECTOR_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'any_targets_folds_damaged_targets',
            'mend_map_accumulates_heal_amount',
            'warmup_approaches_one_when_regen',
            'optional_timer_advances_and_resets',
            'no_heal_when_suppressed',
            'live_tick_advances_regen_frame',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
