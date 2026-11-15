import json
import re
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerUpdateTileProof.gd'
REPAIR_TOWER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerUpdateTileProof.tscn'


class C07RepairTowerUpdateTileTests(unittest.TestCase):
    def test_c07_repair_tower_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2227']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_update_tile_advance_state')
        # N2176 proved the live power.status -> efficiency driver
        # for the repair tower (the pure power row folded into
        # the min efficiency, the heal fold
        # RepairTower.java:78 following it) and N2213 wired the
        # shouldConsume gate (targets.size > 0) -- but the port
        # still tracked no refresh / warmup / totalProgress on
        # the placed-building frame, so a repair tower never
        # refreshed its targets, never healed, and never warmed
        # up: the updateTile advance (RepairTower.java:57-86)
        # waited for its own slice. N2227 is that advance: a
        # pure frame advance over the exact Java lines -- the
        # refresh cadence + clear (`if(potentialEfficiency > 0
        # && (refresh += Time.delta) >= refreshInterval){`
        # with refreshInterval 6f, then `targets.clear();` and
        # `refresh = 0f;`), the suppression early return
        # (`if(checkSuppression()){ warmup = 0f; return; }`),
        # the heal loop (`target.heal(healAmount *
        # edelta());` per damaged target, with `any = true;`),
        # the warmup lerp (0.08f toward any ? efficiency : 0f),
        # and the totalProgress advance (`totalProgress +=
        # Time.delta / circleSpeed;` with circleSpeed 120f).
        # The live Units.nearby scan is deferred (no live unit
        # query in the driver): the refill is a supplied
        # damaged list parameter, and the tick supplies the
        # frame's current targets. The heal APPLICATION is
        # deferred too -- the advance returns the heal amounts
        # as a pure result (frame["heal_amounts"]) instead of
        # writing into another frame. Suppression is a frame
        # input (frame["heal_suppressed"], default false, the
        # N2215 BuildTurret precedent); no live fill sets it
        # yet. potentialEfficiency is folded onto the frame by
        # the shared machinery (apply_update_consumption_state
        # writes frame["potential_efficiency"]) and defaults to
        # the folded efficiency (BuildingComp.java:1989,
        # `potentialEfficiency = efficiency;`) before any
        # consumption tick. refresh binds 0.0 deterministically
        # instead of the Java random init (`public float
        # refresh = Mathf.random(refreshInterval);`) -- the
        # N2222 created-seed precedent does not apply (the
        # Separator seed derives from tile.pos(); the tower
        # refresh is a plain global random). Five new result
        # symbols: the five frame values the advance writes.
        self.assertEqual(
            ledger['N2227']['source_symbols'],
            [
                'source_repair_tower_update_tile_advance_result.refresh',
                'source_repair_tower_update_tile_advance_result.warmup',
                'source_repair_tower_update_tile_advance_result.total_progress',
                'source_repair_tower_update_tile_advance_result.targets',
                'source_repair_tower_update_tile_advance_result.heal_amounts',
            ],
        )
        for name in ledger['N2227']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/RepairTower.java')
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_update_tile_advance_state')
        self.assertEqual(ledger['N2227']['runtime_proof'], '/root/C07RepairTowerUpdateTileProof')
        self.assertEqual(
            ledger['N2227']['tests'],
            [
                'test_c07_repair_tower_update_tile_registration',
                'test_all_c07_repair_tower_update_tile_input_evidence_is_exact',
                'test_repair_tower_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_repair_tower_update_tile',
            ],
        )
        self.assertTrue(ledger['N2227']['deferred_exprs'])
        # This slice resolves the N2176 RepairTower updateTile
        # advance deferral, so that entry is gone from DEFERRED
        # -- while the liquid ozone row, the suppression rows,
        # the draw rows, and the per-def stat rows stay
        # deferred, and the live scan + heal application + the
        # suppression live fill are new deferrals.
        self.assertFalse(any(entry.startswith('RepairTower updateTile advance (') for entry in ledger['N2227']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower live targets refresh scan + heal application (') for entry in ledger['N2227']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower suppression live fill (') for entry in ledger['N2227']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RepairTower suppression rows (') for entry in ledger['N2227']['deferred_exprs']))

    def test_all_c07_repair_tower_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2227']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream' / 'arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2227']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_update_tile_advance_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The pure updateTile advance lives on the repair-tower
        # build state: the five frame values advance exactly
        # the Java lines (RepairTower.java:57-86) -- keep each
        # exact expr on ONE comment line, the N2148 lesson: a
        # split line fails this test.
        self.assertIn('static func source_repair_tower_update_tile_advance_state', repair_tower)
        self.assertIn('if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){', repair_tower)
        self.assertIn('targets.clear();', repair_tower)
        self.assertIn('refresh = 0f;', repair_tower)
        self.assertIn('Units.nearby(team, x, y, range, u -> {', repair_tower)
        self.assertIn('if(u.damaged()){', repair_tower)
        self.assertIn('targets.add(u);', repair_tower)
        self.assertIn('if(checkSuppression()){', repair_tower)
        self.assertIn('warmup = 0f;', repair_tower)
        self.assertIn('boolean any = false;', repair_tower)
        self.assertIn('if(efficiency > 0){', repair_tower)
        self.assertIn('for(var target : targets){', repair_tower)
        self.assertIn('if(target.damaged()){', repair_tower)
        self.assertIn('target.heal(healAmount * edelta());', repair_tower)
        self.assertIn('any = true;', repair_tower)
        self.assertIn('warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);', repair_tower)
        self.assertIn('totalProgress += Time.delta / circleSpeed;', repair_tower)
        self.assertIn('public float refresh = Mathf.random(refreshInterval);', repair_tower)
        self.assertIn('public float warmup = 0f;', repair_tower)
        self.assertIn('public float totalProgress = 0f;', repair_tower)
        self.assertIn('public Seq<Unit> targets = new Seq<>();', repair_tower)
        self.assertIn('static final float refreshInterval = 6f;', repair_tower)
        self.assertIn('public float circleSpeed = 120f, circleStroke = 3f, squareRad = 3f, squareSpinScl = 0.8f, glowMag = 0.5f, glowScl = 8f;', repair_tower)
        self.assertIn('public float healAmount = 1f;', repair_tower)
        self.assertIn('healAmount = 1.5f;', repair_tower)
        # The lerpDelta formula comes from Arc, not from a guess:
        # lerpDelta lerps by the UNSCALED Time.delta
        # (Mathf.java:430-432), while the heal amount uses the
        # SCALED edelta() (BuildingComp.java:1927-1929), and the
        # refresh / totalProgress advances use the UNSCALED
        # Time.delta straight from the Java lines.
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', repair_tower)
        self.assertIn('return efficiency * delta();', repair_tower)
        self.assertIn('return Time.delta * timeScale;', repair_tower)
        # potentialEfficiency defaults to the folded efficiency
        # (BuildingComp.java:1989) and suppression reads the
        # frame heal_suppressed input (the isHealSuppressed
        # mirror, BuildingComp.java:487-489, the N2215
        # precedent) -- no live fill sets it yet.
        self.assertIn('potentialEfficiency = efficiency;', repair_tower)
        self.assertIn('return block.suppressable && Time.time <= healSuppressionTime;', repair_tower)
        self.assertIn('frame["heal_suppressed"]', repair_tower)
        self.assertIn('frame["potential_efficiency"]', repair_tower)
        self.assertIn('frame["heal_amounts"]', repair_tower)
        # The tick driver wires the advance for every ticked
        # repair tower, after the consumption fold
        # (updateConsumption runs first, BuildingComp.java:2274,
        # then the updateTile gate `if(enabled ||
        # !block.noUpdateDisabled){` at :2276; noUpdateDisabled
        # defaults false, Block.java:170, so updateTile runs
        # even when disabled): Time.delta in ticks from the
        # placed-block helper, timeScale live from the sprite
        # meta (default 1f, BuildingComp.java:98), the def heal
        # amount 1.5f (Blocks.java:6580) and the class circle
        # speed 120f (RepairTower.java:23), and the refill is
        # the frame's current targets (no live scan yet).
        self.assertIn('source_repair_tower_update_tile_advance_state(frame', repair_tower)
        self.assertIn('game_source_delta(game, seconds)', repair_tower)
        self.assertIn('time_scale(sprite', repair_tower)
        self.assertIn('SOURCE_REPAIR_TOWER_HEAL_AMOUNT', repair_tower)
        self.assertIn('SOURCE_REPAIR_TOWER_CIRCLE_SPEED', repair_tower)
        # The documented limits record the advance as live; the
        # old N2176 deferral text is gone. The N2176 power row
        # and the N2213 gate are preserved.
        self.assertIn('updateTile advance live (N2227)', repair_tower)
        self.assertNotIn('No updateTile heal advance', repair_tower)
        self.assertIn('static func source_repair_tower_power_status_row_state', repair_tower)
        self.assertIn('static func source_repair_tower_should_consume_state', repair_tower)
        # The proof's keys drive the pure advance (refresh
        # cadence + clear at the interval, warmup toward
        # efficiency when healing, warmup zero when suppressed,
        # totalProgress advance, heal amounts folding
        # healAmount * edelta(), frame defaults zero) plus the
        # live tick folded into the warmup key (the N2176 power
        # fold preserved). There are no live-scan keys: the
        # Units.nearby scan is deferred, so the refill is a
        # supplied list, not a query.
        proof = REPAIR_TOWER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'refresh_clears_targets_at_interval',
            'warmup_approaches_efficiency_when_healing',
            'warmup_zero_when_suppressed',
            'total_progress_advances',
            'heal_amounts_fold_heal_amount_edelta',
            'frame_defaults_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Every preload in the proof points at a file that
        # exists (the N2185 lesson: a proof scene that cannot
        # load fails for the wrong reason on Windows).
        for preload in re.findall(r'preload\("res://([^"]+)"\)', proof):
            with self.subTest(preload=preload):
                self.assertTrue((ROOT / 'godot-mindustry' / preload).is_file(), preload)
        scene = REPAIR_TOWER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07RepairTowerUpdateTileProof.gd', scene)
        self.assertIn('[node name="C07RepairTowerUpdateTileProof" type="Node"]', scene)

    def test_reference_graph_and_actual_c07_repair_tower_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'refresh_clears_targets_at_interval',
            'warmup_approaches_efficiency_when_healing',
            'warmup_zero_when_suppressed',
            'total_progress_advances',
            'heal_amounts_fold_heal_amount_edelta',
            'frame_defaults_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
