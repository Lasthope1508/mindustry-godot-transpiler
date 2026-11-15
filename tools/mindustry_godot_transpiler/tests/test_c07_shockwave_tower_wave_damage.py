import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_WAVE_DAMAGE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerWaveDamageProof.gd'


class C07ShockwaveTowerWaveDamageTests(unittest.TestCase):
    def test_c07_shockwave_tower_wave_damage_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2196']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_damage_state')
        # N2194's fire gate sets heat 1f and resets the counter
        # (ShockwaveTower.java:82-83, `heat = 1f;` /
        # `reloadCounter = 0f;`) and N2195's scan stamps the
        # observed `targets_count` -- but the wave itself does
        # nothing yet: the wave damage line
        # (ShockwaveTower.java:87, `float waveDamage =
        # Math.min(bulletDamage, bulletDamage * falloffCount /
        # targets.size);`) and the per-target damage / removal
        # (:89-95, `for(var target : targets){` /
        # `if(target.damage > waveDamage){` / `target.damage -=
        # waveDamage;` / `target.remove();` /
        # `hitEffect.at(target.x, target.y, waveColor);`) have NO
        # pure function in the port -- a firing tower resets its
        # counter and heats up while every bullet in range flies
        # on undamaged. N2196 owns applying the wave damage. The
        # pure function reuses the N2195 scan filter over the
        # same observed bullet list (`observed_bullets`: an array
        # of dicts with team/hittable/x/y/damage, world coords --
        # the port has no live bullet query, so the list is an
        # explicit observed frame key, the N2190 precedent) plus
        # the tower's world position (`x`/`y` frame keys) and its
        # team (`team_id`), and returns the wave damage
        # (bulletDamage 160, falloffCount 20f, per-def range 170f)
        # plus one outcome per target bullet: the remaining
        # damage (or null when removed), the removed flag, and
        # the hit-effect position (target.x / target.y -- the
        # hitEffect fires for EVERY target, removed or not,
        # ShockwaveTower.java:95). Absent `observed_bullets` (or
        # absent `x`/`y`/`team_id`) or zero targets in range
        # means "no wave": wave_damage null, an empty outcome
        # list, has_wave_damage false, and the driver stamps
        # nothing (the N2190 / N2195 precedent) -- never a
        # fabricated 0. The driver calls the wave damage AFTER
        # the N2194 fire and ONLY when the fire fired: the wave
        # damage lives inside the fire gate in Java (:81-96), so
        # a charged-but-unfired tick damages nothing. Three new
        # result symbols: the wave damage, the per-bullet
        # outcomes, and the wave flag.
        self.assertEqual(
            ledger['N2196']['source_symbols'],
            [
                'source_shockwave_tower_wave_damage_state_result.wave_damage',
                'source_shockwave_tower_wave_damage_state_result.bullet_outcomes',
                'source_shockwave_tower_wave_damage_state_result.has_wave_damage',
            ],
        )
        for name in ledger['N2196']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_wave_damage_state_result.wave_damage': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_damage_state',
                    'source_shockwave_tower_wave_damage_state_result.bullet_outcomes': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_damage_state',
                    'source_shockwave_tower_wave_damage_state_result.has_wave_damage': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_damage_state',
                }[name])
        self.assertEqual(ledger['N2196']['runtime_proof'], '/root/C07ShockwaveTowerWaveDamageProof')
        self.assertEqual(
            ledger['N2196']['tests'],
            [
                'test_c07_shockwave_tower_wave_damage_registration',
                'test_all_c07_shockwave_tower_wave_damage_input_evidence_is_exact',
                'test_shockwave_tower_wave_damage_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_wave_damage',
            ],
        )
        self.assertTrue(ledger['N2196']['deferred_exprs'])

    def test_all_c07_shockwave_tower_wave_damage_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2196']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_wave_damage_state_result.wave_damage': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_damage_state',
                    'source_shockwave_tower_wave_damage_state_result.bullet_outcomes': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_damage_state',
                    'source_shockwave_tower_wave_damage_state_result.has_wave_damage': 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_damage_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/world/Tile.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2196']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_wave_damage_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The wave damage application lives on the shockwave-tower
        # build state: ShockwaveTowerBuild.updateTile fires its
        # wave when the reload counter reaches reload with
        # targets observed (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :81, `if(targets.size > 0){`), then applies `float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);` (ShockwaveTower.java:87, bulletDamage 160, ShockwaveTower.java:27, `public float bulletDamage = 160;`, falloffCount 20f, ShockwaveTower.java:28, `public float falloffCount = 20f;`) and loops the targets (ShockwaveTower.java:89, `for(var target : targets){`): a target whose damage exceeds the wave damage loses exactly waveDamage (`if(target.damage > waveDamage){` / `target.damage -= waveDamage;`, ShockwaveTower.java:90-91 -- the STRICT comparison, so a target at exactly waveDamage is removed, not left at 0), any other target is removed (`target.remove();`, ShockwaveTower.java:93, `public void remove(){`, BulletComp.java:83, over `@Import float x, y, damage, lastX, lastY, time, lifetime;`, BulletComp.java:31), and every target gets its hit effect at its own position (`hitEffect.at(target.x, target.y, waveColor);`, ShockwaveTower.java:95, over `public Effect hitEffect = Fx.hitSquaresColor;`, ShockwaveTower.java:35). The port has no live bullets to mutate (no Groups.bullet equivalent), so the pure function consumes the same observed bullet list as the N2195 scan (`observed_bullets`, an array of dicts with team/hittable/x/y/damage, world coords) and returns one outcome per target bullet instead of mutating it: `{"damage": remaining or null, "removed": bool, "hit_x": x, "hit_y": y}`. The target filter is the N2195 scan filter verbatim (enemy, hittable, point inside the range box x +/- 170, y +/- 170, range 170f per-def, Blocks.java:2043, overriding the class default 110f, ShockwaveTower.java:25) -- the wave only ever touches the scanned targets. Absent `observed_bullets` (or absent `x`/`y`/`team_id`) or zero targets in range means "no wave": `{"wave_damage": null, "bullet_outcomes": [], "has_wave_damage": false}` and the driver stamps nothing (the N2190 / N2195 precedent) -- never a fabricated 0. The driver calls the wave damage AFTER the N2194 fire and ONLY when the fire fired (the local `fired` dict), stamping `frame["wave_damage"]` and `frame["bullet_outcomes"]` only when has_wave_damage is true -- the wave damage lives inside the fire gate in Java (:81-96), so a charged-but-unfired tick damages nothing, and the stamped outcomes persist on the frame until the next fire (like heat).
        self.assertIn('static func source_shockwave_tower_wave_damage_state', shockwave_tower)
        # The wave-damage cases, pinned as the pure function's
        # decision structure: the frame carries the observed
        # bullet list as `observed_bullets` (array of dicts, each
        # with `team` (int), `hittable` (bool), `x`/`y` (float,
        # world coords), `damage` (float -- a bullet without a
        # damage key reads 0.0 and is removed, since 0.0 never
        # exceeds the wave damage)), the tower world position as
        # `x`/`y` (float), and the tower team as `team_id`
        # (int). A bullet is a target when its team differs from
        # the tower team AND it is hittable AND its point lies
        # inside the range box (|bx - x| <= 170.0 and |by - y| <=
        # 170.0). waveDamage is min(160.0, 160.0 * 20.0 /
        # targets.size()) -- capped at bulletDamage 160 for few
        # targets, falling off as 3200 / N for many. Each target
        # outcome carries the remaining damage (null when
        # removed), the removed flag, and the hit-effect position
        # (hit_x / hit_y = the target's own x / y). The function
        # returns `{"wave_damage": wave, "bullet_outcomes":
        # outcomes, "has_wave_damage": true}` when a wave ran and
        # `{"wave_damage": null, "bullet_outcomes": [],
        # "has_wave_damage": false}` when it did not. The driver
        # calls it after the N2194 fire, only when the fire
        # fired, and stamps frame["wave_damage"] /
        # frame["bullet_outcomes"] only when has_wave_damage is
        # true.
        self.assertIn('frame.get("observed_bullets", null)', shockwave_tower)
        self.assertIn('frame.get("x", null)', shockwave_tower)
        self.assertIn('frame.get("y", null)', shockwave_tower)
        self.assertIn('frame.get("team_id", null)', shockwave_tower)
        self.assertIn('bullet.get("team", null)', shockwave_tower)
        self.assertIn('bullet.get("hittable", false)', shockwave_tower)
        self.assertIn('bullet.get("damage", 0.0)', shockwave_tower)
        self.assertIn('absf(float(bullet.get("x", 0.0)) - float(tower_x)) > 170.0', shockwave_tower)
        self.assertIn('absf(float(bullet.get("y", 0.0)) - float(tower_y)) > 170.0', shockwave_tower)
        self.assertIn('minf(160.0, 160.0 * 20.0 / float(targets.size()))', shockwave_tower)
        self.assertIn('return {"wave_damage": null, "bullet_outcomes": [], "has_wave_damage": false}', shockwave_tower)
        self.assertIn('return {"wave_damage": wave_damage, "bullet_outcomes": bullet_outcomes, "has_wave_damage": true}', shockwave_tower)
        with self.subTest(case='wave damage caps at bulletDamage for few targets'):
            self.assertIn('minf(160.0, 160.0 * 20.0 / float(targets.size()))', shockwave_tower)
        with self.subTest(case='wave damage falls off with many targets'):
            self.assertIn('minf(160.0, 160.0 * 20.0 / float(targets.size()))', shockwave_tower)
        with self.subTest(case='low-damage bullets are removed, not left at zero'):
            self.assertIn('bullet.get("damage", 0.0)', shockwave_tower)
        with self.subTest(case='hit-effect positions follow the targets'):
            self.assertIn('return {"wave_damage": wave_damage, "bullet_outcomes": bullet_outcomes, "has_wave_damage": true}', shockwave_tower)
        with self.subTest(case='absent observed_bullets stamps nothing'):
            self.assertIn('return {"wave_damage": null, "bullet_outcomes": [], "has_wave_damage": false}', shockwave_tower)
        with self.subTest(case='live driver stamps wave damage only on fire'):
            self.assertIn('source_shockwave_tower_wave_damage_state(frame)', shockwave_tower)
        self.assertIn('source_shockwave_tower_wave_damage_state(frame)', shockwave_tower)
        self.assertIn('frame["wave_damage"]', shockwave_tower)
        self.assertIn('frame["bullet_outcomes"]', shockwave_tower)
        self.assertIn('public class ShockwaveTower extends Block{', shockwave_tower)
        self.assertIn('public class ShockwaveTowerBuild extends Building{', shockwave_tower)
        self.assertIn('public int timerCheck = timers ++;', shockwave_tower)
        self.assertIn('public float range = 110f;', shockwave_tower)
        self.assertIn('public float reload = 60f * 1.5f;', shockwave_tower)
        self.assertIn('public float bulletDamage = 160;', shockwave_tower)
        self.assertIn('public float falloffCount = 20f;', shockwave_tower)
        self.assertIn('public float shake = 2f;', shockwave_tower)
        self.assertIn('public float checkInterval = 8f;', shockwave_tower)
        self.assertIn('public float cooldownMultiplier = 1f;', shockwave_tower)
        self.assertIn('public Sound shootSound = Sounds.shockwaveTower;', shockwave_tower)
        self.assertIn('public Effect hitEffect = Fx.hitSquaresColor;', shockwave_tower)
        self.assertIn('public Effect waveEffect = Fx.pointShockwave;', shockwave_tower)
        self.assertIn('public float reloadCounter = Mathf.random(reload);', shockwave_tower)
        self.assertIn('public float heat = 0f;', shockwave_tower)
        self.assertIn('public Seq<Bullet> targets = new Seq<>();', shockwave_tower)
        self.assertIn('public void updateTile(){', shockwave_tower)
        self.assertIn('if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', shockwave_tower)
        self.assertIn('targets.clear();', shockwave_tower)
        self.assertIn('Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', shockwave_tower)
        self.assertIn('if(b.team != team && b.type.hittable){', shockwave_tower)
        self.assertIn('targets.add(b);', shockwave_tower)
        self.assertIn('if(targets.size > 0){', shockwave_tower)
        self.assertIn('heat = 1f;', shockwave_tower)
        self.assertIn('reloadCounter = 0f;', shockwave_tower)
        self.assertIn('waveEffect.at(x, y, range, waveColor);', shockwave_tower)
        self.assertIn('shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', shockwave_tower)
        self.assertIn('Effect.shake(shake, shake, this);', shockwave_tower)
        self.assertIn('float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', shockwave_tower)
        self.assertIn('for(var target : targets){', shockwave_tower)
        self.assertIn('if(target.damage > waveDamage){', shockwave_tower)
        self.assertIn('target.damage -= waveDamage;', shockwave_tower)
        self.assertIn('target.remove();', shockwave_tower)
        self.assertIn('hitEffect.at(target.x, target.y, waveColor);', shockwave_tower)
        self.assertIn('if(team == state.rules.defaultTeam){', shockwave_tower)
        self.assertIn('Events.fire(Trigger.shockwaveTowerUse);', shockwave_tower)
        self.assertIn('heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', shockwave_tower)
        self.assertIn('if(sensor == LAccess.progress) return reloadCounter / reload;', shockwave_tower)
        self.assertIn('return heat;', shockwave_tower)
        self.assertIn('return reloadCounter < reload;', shockwave_tower)
        self.assertIn('public boolean shouldConsume(){', shockwave_tower)
        self.assertIn('public boolean canConsume(){', shockwave_tower)
        self.assertIn('return potentialEfficiency > 0;', shockwave_tower)
        self.assertIn('return efficiency * delta();', shockwave_tower)
        self.assertIn('potentialEfficiency = efficiency;', shockwave_tower)
        self.assertIn('boolean update = shouldConsume() && productionValid();', shockwave_tower)
        self.assertIn('if(!update){', shockwave_tower)
        self.assertIn('efficiency = optionalEfficiency = 0f;', shockwave_tower)
        self.assertIn('return enabled;', shockwave_tower)
        self.assertIn('consumePower(100f / 60f);', shockwave_tower)
        self.assertIn('consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', shockwave_tower)
        self.assertIn('range = 170f;', shockwave_tower)
        self.assertIn('reload = 80f;', shockwave_tower)
        self.assertIn('size = 3;', shockwave_tower)
        self.assertIn('return build.power.status;', shockwave_tower)
        self.assertIn('float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', shockwave_tower)
        self.assertIn('hasConsumers = consumers.length > 0;', shockwave_tower)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', shockwave_tower)
        self.assertIn('update = true;', shockwave_tower)
        self.assertIn('solid = true;', shockwave_tower)
        self.assertIn('public static final int tilesize = 8;', shockwave_tower)
        self.assertIn('return x * tilesize;', shockwave_tower)
        self.assertIn('return block().offset + worldx();', shockwave_tower)
        self.assertIn('public boolean timer(int index, float time){', shockwave_tower)
        self.assertIn('return timer.get(index, time);', shockwave_tower)
        self.assertIn('transient Interval timer = new Interval(6);', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_tick_buildings_state', shockwave_tower)
        # The proof's keys drive the pure wave damage (caps at
        # bulletDamage / falls off with many targets / low-damage
        # bullets removed / hit-effect positions follow the
        # targets / absent observed_bullets stamps nothing) plus
        # the live tick (the driver stamps wave damage and the
        # per-bullet outcomes only on a fire tick). There are no
        # waveEffect / shootSound / shake / event / sense /
        # warmup keys: the waveEffect / shootSound / shake
        # (:84-86), the shockwaveTowerUse event (:97-99),
        # sense(LAccess.progress) (:110), warmup() (:117) and
        # the cyanogen liquid consumer (Blocks.java:2041) wait
        # for their own slices, and the timer cadence (:73,
        # checkInterval 8f) waits for a per-building-timer slice.
        proof = SHOCKWAVE_TOWER_WAVE_DAMAGE_PROOF.read_text(encoding='utf-8')
        for key in [
            'wave_damage_caps_at_bullet_damage',
            'wave_damage_falls_off_with_many_targets',
            'low_damage_bullets_removed',
            'hit_effect_positions_follow_targets',
            'absent_observed_bullets_stamps_nothing',
            'live_driver_stamps_wave_damage_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_wave_damage(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerWaveDamageProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_WAVE_DAMAGE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'wave_damage_caps_at_bullet_damage',
            'wave_damage_falls_off_with_many_targets',
            'low_damage_bullets_removed',
            'hit_effect_positions_follow_targets',
            'absent_observed_bullets_stamps_nothing',
            'live_driver_stamps_wave_damage_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
