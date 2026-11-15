import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_UPDATE_TILE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerUpdateTileProof.gd'
SHOCKWAVE_TOWER_UPDATE_TILE_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerUpdateTileProof.tscn'


class C07ShockwaveTowerUpdateTileTests(unittest.TestCase):
    def test_c07_shockwave_tower_update_tile_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2247']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_update_tile_advance_state')
        # N2187 charged the reload counter each tick
        # (ShockwaveTower.java:73, `(reloadCounter += edelta())`)
        # and fed the shouldConsume gate to the machinery, but
        # RED-deferred the rest of updateTile: the bullet scan
        # / wave damage / heat / cooldown (ShockwaveTower.java:
        # 73-104) -- a fully charged tower stayed charged
        # forever (gate false, efficiency 0) because the fire
        # reset (`reloadCounter = 0f;`, ShockwaveTower.java:83)
        # never ran. N2247 resolves both deferrals: the pure
        # advance reads the counter N2187 already charged (it
        # does NOT add edelta again), gates on
        # potentialEfficiency > 0 + counter >= reload + the
        # explicit check_ready timer outcome, scans the explicit
        # bullet candidates for enemy hittable targets, fires
        # the wave (heat = 1f, counter reset, waveDamage =
        # min(bulletDamage, bulletDamage * falloffCount /
        # targets.size)), and decays heat every tick
        # (Mathf.clamp(heat - Time.delta / reload *
        # cooldownMultiplier)). Five new result symbols: the
        # fire flag, the counter, the heat, the target list,
        # and the wave damage.
        self.assertEqual(
            ledger['N2247']['source_symbols'],
            [
                'source_shockwave_tower_update_tile_advance_state_result.fired',
                'source_shockwave_tower_update_tile_advance_state_result.reload_counter',
                'source_shockwave_tower_update_tile_advance_state_result.heat',
                'source_shockwave_tower_update_tile_advance_state_result.targets',
                'source_shockwave_tower_update_tile_advance_state_result.wave_damage',
            ],
        )
        for name in ledger['N2247']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java')
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_update_tile_advance_state')
        self.assertEqual(ledger['N2247']['runtime_proof'], '/root/C07ShockwaveTowerUpdateTileProof')
        self.assertEqual(
            ledger['N2247']['tests'],
            [
                'test_c07_shockwave_tower_update_tile_registration',
                'test_all_c07_shockwave_tower_update_tile_input_evidence_is_exact',
                'test_shockwave_tower_update_tile_advance_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_update_tile',
            ],
        )
        self.assertTrue(ledger['N2247']['deferred_exprs'])
        # This slice resolves the updateTile advance deferral
        # and the fire-reset deferral, so both entries are gone
        # from the carried-forward list -- and the random-init
        # deferral (the fresh-frame 0.0 stand-in for
        # Mathf.random(reload)) and the trigger deferral stay.
        self.assertFalse(any(entry.startswith('ShockwaveTower updateTile advance (') for entry in ledger['N2247']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('ShockwaveTower fire reset (') for entry in ledger['N2247']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower random reloadCounter init (') for entry in ledger['N2247']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower trigger row (') for entry in ledger['N2247']['deferred_exprs']))
        # The new live-fill deferrals this slice adds: the
        # timer cadence and the live bullet scan are explicit
        # inputs, so no live fire happens until their slices
        # land; the wave presentation and the damage
        # application on live bullets defer too.
        self.assertTrue(any(entry.startswith('ShockwaveTower updateTile live timer fill (') for entry in ledger['N2247']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower updateTile live bullet scan fill (') for entry in ledger['N2247']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower wave effects / sound / shake (') for entry in ledger['N2247']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower wave damage application on live bullets (') for entry in ledger['N2247']['deferred_exprs']))

    def test_all_c07_shockwave_tower_update_tile_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2247']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_update_tile_advance_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/bullet/BulletType.java',
            'core/src/mindustry/entities/comp/BulletComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2247']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_update_tile_advance_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The pure advance lives on the shockwave-tower build
        # state: ShockwaveTowerBuild.updateTile()
        # (ShockwaveTower.java:72-105). Keep each Java expr on
        # ONE comment line (the N2148 shootWarmup lesson: a
        # split line fails this test). The fire gate
        # (ShockwaveTower.java:73) reads the reload counter
        # N2187 ALREADY charged in the driver -- this slice
        # does NOT add edelta again. potentialEfficiency comes
        # from the frame (stamped by
        # apply_update_consumption_state); the timer outcome is
        # the explicit check_ready input (no timer infra in the
        # port, the N2193 precedent; checkInterval 8f). The
        # scan is a RECTANGLE intersect (Groups.bullet.intersect
        # over the range*2 box); the explicit candidate list IS
        # the intersect result (the N2229 precedent), and the
        # pure filter keeps enemy + hittable bullets only
        # (b.team != team && b.type.hittable -- hittable lives
        # on the bullet TYPE, BulletType.java:143, default
        # true). The wave damage is min(bulletDamage,
        # bulletDamage * falloffCount / targets.size)
        # (bulletDamage 160, falloffCount 20f); each target
        # with damage strictly above waveDamage loses
        # waveDamage, the rest are removed (the boundary is
        # strict: damage == waveDamage removes). Heat is set
        # to 1f on fire, then the unconditional decay runs
        # (Mathf.clamp(heat - Time.delta / reload *
        # cooldownMultiplier) -- Arc's single-arg clamp is
        # [0, 1], Mathf.java:402-404), so a fired tick ends
        # below 1f. Time.delta in the port is seconds * 60
        # through game_source_delta (arc Time.java:26), never
        # raw seconds (the N2186/N2187/N2191 lesson: raw
        # seconds run 60x slow). DEF BEATS CLASS: the
        # shockwave-tower def (Blocks.java:2038-2044) sets
        # range 170f and reload 80f over the class defaults
        # (range 110f, reload 60f * 1.5f = 90f); bulletDamage
        # 160 / falloffCount 20f / cooldownMultiplier 1f have
        # no def override. Line corrections (verified by grep
        # at this pin -- the scope brief drifts): heat = 1f is
        # :82 and reloadCounter = 0f is :83 (not :81/:84);
        # Events.fire(Trigger.shockwaveTowerUse) is :99
        # (guard :98, not :96-98).
        self.assertIn('static func source_shockwave_tower_update_tile_advance_state', shockwave_tower)
        self.assertIn('public float heat = 0f;', shockwave_tower)
        self.assertIn('public Seq<Bullet> targets = new Seq<>();', shockwave_tower)
        self.assertIn('public float bulletDamage = 160;', shockwave_tower)
        self.assertIn('public float falloffCount = 20f;', shockwave_tower)
        self.assertIn('public float checkInterval = 8f;', shockwave_tower)
        self.assertIn('public float cooldownMultiplier = 1f;', shockwave_tower)
        self.assertIn('if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', shockwave_tower)
        self.assertIn('targets.clear();', shockwave_tower)
        self.assertIn('Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', shockwave_tower)
        self.assertIn('if(b.team != team && b.type.hittable){', shockwave_tower)
        self.assertIn('targets.add(b);', shockwave_tower)
        self.assertIn('if(targets.size > 0){', shockwave_tower)
        self.assertIn('heat = 1f;', shockwave_tower)
        self.assertIn('reloadCounter = 0f;', shockwave_tower)
        self.assertIn('float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', shockwave_tower)
        self.assertIn('if(target.damage > waveDamage){', shockwave_tower)
        self.assertIn('target.damage -= waveDamage;', shockwave_tower)
        self.assertIn('target.remove();', shockwave_tower)
        self.assertIn('heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', shockwave_tower)
        self.assertIn('Events.fire(Trigger.shockwaveTowerUse);', shockwave_tower)
        self.assertIn('public boolean hittable = true;', shockwave_tower)
        self.assertIn('return efficiency * delta();', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        self.assertIn('reload = 80f;', shockwave_tower)
        # The class values the tick wiring passes are driver
        # constants (bulletDamage / falloffCount /
        # cooldownMultiplier have no def override); reload
        # comes from the catalog block like the N2187 gate.
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_BULLET_DAMAGE := 160.0', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_FALLOFF_COUNT := 20.0', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_COOLDOWN_MULTIPLIER := 1.0', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_CHECK_INTERVAL := 8.0', shockwave_tower)
        # A fresh frame starts with the N2247 keys (heat 0f,
        # empty targets) alongside the N2187 counter.
        self.assertIn('"heat": 0.0, "targets": []', shockwave_tower)
        # The tick wires the advance after the N2187 charge:
        # the live call passes an empty candidate list and
        # check_ready false (no timer infra, no live bullet
        # query -- the N2229 precedent), so no live fire
        # happens, but heat decays every tick and the frame
        # keys are written back.
        self.assertIn('source_shockwave_tower_update_tile_advance_state(frame, source_placed_block_state.game_source_delta(game, seconds)', shockwave_tower)
        self.assertIn('frame["heat"] = advanced.get("heat"', shockwave_tower)
        self.assertIn('frame["targets"] = advanced.get("targets"', shockwave_tower)
        # The documented limits record the advance as modeled
        # by N2247 (the old "waits for their own slice" text
        # for the scan / wave / heat is gone).
        self.assertIn('updateTile advance live (N2247)', shockwave_tower)
        self.assertNotIn('No updateTile wave advance beyond the counter charge', shockwave_tower)
        self.assertNotIn('Only the charge is modeled here', shockwave_tower)
        # The proof's keys drive the pure advance (the fire
        # gate needs a charged counter AND the timer, the scan
        # filters enemy hittable bullets, the falloff formula,
        # the remove boundary, heat set on fire, and heat
        # decaying every tick) plus the live tick (heat decays
        # on a placed tower). There are no effect / sound /
        # shake / trigger keys: the wave presentation and the
        # team event defer.
        proof = SHOCKWAVE_TOWER_UPDATE_TILE_PROOF.read_text(encoding='utf-8')
        for key in [
            'fire_gate_needs_charge_and_timer',
            'scan_filters_enemy_hittable',
            'wave_damage_falloff_formula',
            'target_removed_below_wave_damage',
            'heat_set_on_fire',
            'heat_decays_every_tick',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.exists())
        self.assertTrue(SHOCKWAVE_TOWER_UPDATE_TILE_PROOF_SCENE.exists())
        self.assertIn('C07ShockwaveTowerUpdateTileProof.gd', SHOCKWAVE_TOWER_UPDATE_TILE_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_shockwave_tower_update_tile(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerUpdateTileProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_UPDATE_TILE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'fire_gate_needs_charge_and_timer',
            'scan_filters_enemy_hittable',
            'wave_damage_falloff_formula',
            'target_removed_below_wave_damage',
            'heat_set_on_fire',
            'heat_decays_every_tick',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
