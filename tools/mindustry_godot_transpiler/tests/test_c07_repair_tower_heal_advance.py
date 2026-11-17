import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
REPAIR_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceRepairTowerBuildState.gd'
REPAIR_TOWER_HEAL_ADVANCE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RepairTowerHealAdvanceProof.gd'


class C07RepairTowerHealAdvanceTests(unittest.TestCase):
    def test_c07_repair_tower_heal_advance_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2228']['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_heal_advance_state')
        # N2190 did the target refresh (RepairTower.java:59-66),
        # N2191 the shouldConsume gate (:89-90) and N2211 the
        # driver stamp of the live nearby-damaged count; this
        # slice is the remainder of RepairTowerBuild.updateTile()
        # (RepairTower.java:69-85): the suppression gate
        # (`if(checkSuppression()){` / `warmup = 0f;` /
        # `return;`, :69-72), the heal loop (`boolean any =
        # false;` / `if(efficiency > 0){` / `for(var target :
        # targets){` / `if(target.damaged()){` /
        # `target.heal(healAmount * edelta());` / `any =
        # true;`, :74-82), the warmup lerp (`warmup =
        # Mathf.lerpDelta(warmup, any ? efficiency : 0f,
        # 0.08f);`, :84) and the totalProgress advance
        # (`totalProgress += Time.delta / circleSpeed;`,
        # :85). One pure function on
        # SourceRepairTowerBuildState.gd, plus one driver tick
        # line that stamps warmup / total_progress / targets
        # live (the N2213 heal-advance precedent, with the
        # N2211 driver-line precedent). Seven new result
        # symbols: suppressed + any + healed_count + warmup +
        # total_progress + targets + heal_amount.
        self.assertEqual(
            ledger['N2228']['source_symbols'],
            [
                'source_repair_tower_heal_advance_state_result.suppressed',
                'source_repair_tower_heal_advance_state_result.any',
                'source_repair_tower_heal_advance_state_result.healed_count',
                'source_repair_tower_heal_advance_state_result.warmup',
                'source_repair_tower_heal_advance_state_result.total_progress',
                'source_repair_tower_heal_advance_state_result.targets',
                'source_repair_tower_heal_advance_state_result.heal_amount',
            ],
        )
        for name in ledger['N2228']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/units/RepairTower.java',
                    'core/src/mindustry/entities/comp/HealthComp.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_heal_advance_state')
        self.assertEqual(ledger['N2228']['runtime_proof'], '/root/C07RepairTowerHealAdvanceProof')
        self.assertEqual(
            ledger['N2228']['tests'],
            [
                'test_c07_repair_tower_heal_advance_registration',
                'test_all_c07_repair_tower_heal_advance_input_evidence_is_exact',
                'test_repair_tower_heal_advance_state',
                'test_reference_graph_and_actual_c07_repair_tower_heal_advance',
            ],
        )
        self.assertTrue(ledger['N2228']['deferred_exprs'])

    def test_all_c07_repair_tower_heal_advance_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2228']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRepairTowerBuildState.source_repair_tower_heal_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/RepairTower.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {}
        for source in slice_sources:
            upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
        for expr in ledger['N2228']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_repair_tower_heal_advance_state(self):
        repair_tower = REPAIR_TOWER_STATE.read_text(encoding='utf-8')
        # The heal advance is the remainder of
        # RepairTowerBuild.updateTile() (RepairTower.java:69-85):
        # the suppression gate (`if(checkSuppression()){` /
        # `warmup = 0f;` / `return;`, :69-72) zeroes warmup and
        # returns early -- no heal, no totalProgress advance.
        # `boolean any = false;` (:74) starts the heal loop,
        # which runs only when `efficiency > 0` (:75) and heals
        # each damaged target in the `targets` Seq
        # (`for(var target : targets){` / `if(target.damaged()){`
        # / `target.heal(healAmount * edelta());` / `any =
        # true;`, :76-81). damaged() is `health < maxHealth -
        # 0.001f` (HealthComp.java:47-49), NOT `health <
        # maxHealth`; the heal adds `healAmount * edelta()` and
        # clamps at maxHealth (`health += amount;` /
        # `clampHealth();`, HealthComp.java:109-111, with
        # `health = Math.min(health, maxHealth);`,
        # HealthComp.java:104). edelta() is efficiency * delta()
        # (BuildingComp.java:1927-1928, `return efficiency *
        # delta();`), and delta() is Time.delta * timeScale
        # (BuildingComp.java:1922-1923) -- the driver passes its
        # per-tick seconds as delta, the same `seconds` the
        # N2190 refresh and the N2211 driver use, so the pure
        # function reads edelta = efficiency * delta directly.
        # The warmup lerp (`warmup = Mathf.lerpDelta(warmup,
        # any ? efficiency : 0f, 0.08f);`, :84) and the
        # totalProgress advance (`totalProgress += Time.delta /
        # circleSpeed;`, :85) sit OUTSIDE the `if(efficiency >
        # 0){` block -- they run on every non-suppressed tick.
        # The lerp goes through the shared helper
        # SourceMathState.source_lerp_delta (SourceMathState.gd:52-53,
        # the N2215 strength-lerp math precedent). warmup and
        # totalProgress are Java fields (`public float warmup =
        # 0f;` / `public float totalProgress = 0f;`,
        # RepairTower.java:52-53), default 0. The returned
        # targets are DUPLICATES with the healed health -- the
        # input list is not mutated, so the driver stamps the
        # returned list (the N2213 precedent). Per-def
        # healAmount is 1.5f (`healAmount = 1.5f;`,
        # Blocks.java:6580); the class default is 1f
        # (`public float healAmount = 1f;`,
        # RepairTower.java:24) -- the driver resolves it from
        # the block properties, the N2211 range precedent. The
        # ozone liquid consumer (`consumeLiquid(Liquids.ozone,
        # 3f / 60f);`, Blocks.java:6583) is NOT this slice: its
        # fold needs a liquid-stock observation no frame
        # carries yet. The suppression bridges are the static
        # funcs SourceBuildingLifecycleState.
        # is_heal_suppressed_state (:408) and
        # check_suppression_state (:463) -- N2228 takes
        # `suppressed` as a bool param and calls neither; live
        # suppression plumbing waits for its own slice.
        self.assertIn('static func source_repair_tower_heal_advance_state(frame: Dictionary, targets: Array, heal_amount: float, delta: float, circle_speed: float, suppressed: bool) -> Dictionary:', repair_tower)
        self.assertIn('var warmup: float = float(frame.get("warmup", 0.0))', repair_tower)
        self.assertIn('var total_progress: float = float(frame.get("total_progress", 0.0))', repair_tower)
        self.assertIn('if suppressed:', repair_tower)
        self.assertIn('return {"suppressed": true, "any": false, "healed_count": 0, "warmup": 0.0, "total_progress": total_progress, "targets": targets, "heal_amount": 0.0}', repair_tower)
        self.assertIn('var efficiency: float = float(frame.get("efficiency", 1.0))', repair_tower)
        self.assertIn('var edelta: float = efficiency * delta', repair_tower)
        self.assertIn('var amount: float = heal_amount * edelta', repair_tower)
        self.assertIn('var healed_target: Dictionary = target.duplicate()', repair_tower)
        self.assertIn('if efficiency > 0.0:', repair_tower)
        self.assertIn('if health < max_health - 0.001:', repair_tower)
        self.assertIn('healed_target["health"] = min(health + amount, max_health)', repair_tower)
        self.assertIn('healed_count += 1', repair_tower)
        self.assertIn('var any: bool = healed_count > 0', repair_tower)
        self.assertIn('warmup = SourceMathState.source_lerp_delta(warmup, efficiency if any else 0.0, 0.08, delta)', repair_tower)
        self.assertIn('total_progress += delta / circle_speed', repair_tower)
        self.assertIn('return {"suppressed": false, "any": any, "healed_count": healed_count, "warmup": warmup, "total_progress": total_progress, "targets": healed_targets, "heal_amount": amount}', repair_tower)
        self.assertIn('source_repair_tower_heal_advance_state(frame, frame.get("targets", []), float(block.properties.get("healAmount", 1.0)), seconds, 120.0, bool(frame.get("heal_suppressed", false)))', repair_tower)
        self.assertIn('frame["warmup"] = heal_result.get("warmup", 0.0)', repair_tower)
        self.assertIn('frame["total_progress"] = heal_result.get("total_progress", 0.0)', repair_tower)
        self.assertIn('frame["targets"] = heal_result.get("targets", [])', repair_tower)
        for expr in [
            'if(checkSuppression()){',
            'warmup = 0f;',
            'boolean any = false;',
            'if(efficiency > 0){',
            'for(var target : targets){',
            'if(target.damaged()){',
            'target.heal(healAmount * edelta());',
            'any = true;',
            'warmup = Mathf.lerpDelta(warmup, any ? efficiency : 0f, 0.08f);',
            'totalProgress += Time.delta / circleSpeed;',
            'return health < maxHealth - 0.001f;',
            'health = Math.min(health, maxHealth);',
            'return efficiency * delta();',
            'public float warmup = 0f;',
            'public float totalProgress = 0f;',
            'healAmount = 1.5f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, repair_tower)
        # The proof's keys drive the heal advance through the
        # pure function directly with synthetic frames (the
        # N2213 precedent -- the driver tick line lands with
        # GREEN): suppression zeroes warmup / heals damaged
        # targets / clamps at max health / skips undamaged
        # targets / no heal at zero efficiency / warmup lerps
        # to efficiency / warmup decays with no heal /
        # totalProgress advances. Per-def healAmount 1.5f
        # (Blocks.java:6580); delta 1/60 is one tick.
        proof = REPAIR_TOWER_HEAL_ADVANCE_PROOF.read_text(encoding='utf-8')
        for key in [
            'suppression_zeroes_warmup',
            'heal_damaged_targets',
            'heal_clamps_at_max',
            'undamaged_target_skipped',
            'efficiency_zero_no_heal',
            'warmup_lerps_to_efficiency',
            'warmup_decays_no_heal',
            'total_progress_advances',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_repair_tower_heal_advance(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RepairTowerHealAdvanceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_REPAIR_TOWER_HEAL_ADVANCE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'suppression_zeroes_warmup',
            'heal_damaged_targets',
            'heal_clamps_at_max',
            'undamaged_target_skipped',
            'efficiency_zero_no_heal',
            'warmup_lerps_to_efficiency',
            'warmup_decays_no_heal',
            'total_progress_advances',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
