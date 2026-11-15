import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_BULLET_SCAN_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerBulletScanProof.gd'


class C07ShockwaveTowerBulletScanTests(unittest.TestCase):
    def test_c07_shockwave_tower_bullet_scan_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2195']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_bullet_scan_state')
        # N2194's fire gate reads an observed `targets_count`
        # frame key (ShockwaveTower.java:81, `if(targets.size >
        # 0){`) and absent means no fire, never invented targets
        # -- but nothing stamps `targets_count` yet: the live
        # bullet scan (ShockwaveTower.java:74-79,
        # `targets.clear();` /
        # `Groups.bullet.intersect(x - range, y - range, range *
        # 2, range * 2, b -> {` / `if(b.team != team &&
        # b.type.hittable){` / `targets.add(b);`) has NO frame
        # input in the port -- no live bullet query exists -- so
        # N2195 owns stamping it live. The pure function takes
        # the observed bullet list as an explicit frame key
        # (`observed_bullets`: an array of dicts with
        # team/hittable/x/y, world coords) plus the tower's world
        # position (`x`/`y` frame keys) and its team (`team_id`,
        # already stamped by the tick wiring), and returns the
        # count of enemy hittable bullets inside the range box
        # (x +/- range, y +/- range, range 170f per-def,
        # Blocks.java:2043, overriding the class default 110f,
        # ShockwaveTower.java:25). The range box is a point-in-box
        # test against the Java intersect rect -- the port models
        # no bullet hitSize, so the rect overlap is approximated
        # by the bullet point, a documented limit owned by a later
        # bullet-hitSize slice. Absent `observed_bullets` (or
        # absent `x`/`y`/`team_id`) means "no observation yet"
        # and stamps nothing (the N2190 RepairTower precedent:
        # `targets_count` is NOT stamped, so N2194 keeps reading
        # absent as no fire); a present-but-empty list IS an
        # observation and stamps 0. Two new result symbols: the
        # stamped count and the observation flag.
        self.assertEqual(
            ledger['N2195']['source_symbols'],
            [
                'source_shockwave_tower_bullet_scan_state_result.targets_count',
                'source_shockwave_tower_bullet_scan_state_result.has_targets_count',
            ],
        )
        for name in ledger['N2195']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_bullet_scan_state_result.targets_count': 'SourceShockwaveTowerBuildState.source_shockwave_tower_bullet_scan_state',
                    'source_shockwave_tower_bullet_scan_state_result.has_targets_count': 'SourceShockwaveTowerBuildState.source_shockwave_tower_bullet_scan_state',
                }[name])
        self.assertEqual(ledger['N2195']['runtime_proof'], '/root/C07ShockwaveTowerBulletScanProof')
        self.assertEqual(
            ledger['N2195']['tests'],
            [
                'test_c07_shockwave_tower_bullet_scan_registration',
                'test_all_c07_shockwave_tower_bullet_scan_input_evidence_is_exact',
                'test_shockwave_tower_bullet_scan_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_bullet_scan',
            ],
        )
        self.assertTrue(ledger['N2195']['deferred_exprs'])

    def test_all_c07_shockwave_tower_bullet_scan_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2195']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_bullet_scan_state_result.targets_count': 'SourceShockwaveTowerBuildState.source_shockwave_tower_bullet_scan_state',
                    'source_shockwave_tower_bullet_scan_state_result.has_targets_count': 'SourceShockwaveTowerBuildState.source_shockwave_tower_bullet_scan_state',
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
        for expr in ledger['N2195']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_bullet_scan_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The live bullet scan lives on the shockwave-tower build
        # state: ShockwaveTowerBuild.updateTile clears its targets
        # and scans the bullet groups inside the range box
        # (ShockwaveTower.java:72, `public void updateTile(){`
        # with :74, `targets.clear();` and :75,
        # `Groups.bullet.intersect(x - range, y - range, range *
        # 2, range * 2, b -> {` with :76, `if(b.team != team &&
        # b.type.hittable){` and :77, `targets.add(b);`) over the
        # target list (ShockwaveTower.java:68, `public Seq<Bullet>
        # targets = new Seq<>();`). The scan is what N2194's fire
        # gate reads as the observed `targets_count`
        # (ShockwaveTower.java:81, `if(targets.size > 0){`) -- the
        # fire fires only when the scan found targets. The port
        # has no live bullet query (no Groups.bullet equivalent),
        # so the pure function consumes an observed bullet list
        # (`observed_bullets`, an array of dicts with
        # team/hittable/x/y) and counts the enemy hittable
        # bullets inside the range box (x +/- range, y +/- range,
        # range 170f per-def, Blocks.java:2043, overriding the
        # class default 110f, ShockwaveTower.java:25). The tower's
        # world position comes from the frame's `x`/`y` keys,
        # which the driver derives from the placement cell
        # (Tile.java, `return x * tilesize;` / `return block().offset + worldx();`, tilesize 8,
        # Vars.java:135, `public static final int tilesize = 8;`,
        # offset 0 for size 3, Block.java:761, `offset = ((size +
        # 1) % 2) * tilesize / 2f;`), and its team from the
        # frame's `team_id` key (already stamped by the tick
        # wiring). The scan runs every tick in the driver (after
        # the N2192 charge, before the N2194 fire) -- Java scans
        # only when the fire gate (:73) is true, but the port's
        # timer cadence is already deferred (N2194: the port fires
        # on the first tick at reload), so a fresh scan every tick
        # is observably equivalent for the fire decision, and the
        # timer-gated scan cadence waits for the per-building-timer
        # slice with the timer itself. Absent `observed_bullets`
        # (or absent `x`/`y`/`team_id`) means "no observation
        # yet": the function returns targets_count null and
        # has_targets_count false, and the driver stamps nothing
        # (the N2190 precedent) -- never a fabricated 0, so
        # N2194 keeps reading absent as no fire. A present-but-
        # empty list IS an observation and stamps 0.
        self.assertIn('static func source_shockwave_tower_bullet_scan_state', shockwave_tower)
        # The scan cases, pinned as the pure function's decision
        # structure: the frame carries the observed bullet list as
        # `observed_bullets` (array of dicts, each with `team`
        # (int), `hittable` (bool), `x`/`y` (float, world coords)),
        # the tower world position as `x`/`y` (float), and the
        # tower team as `team_id` (int). A bullet counts when its
        # team differs from the tower team AND it is hittable AND
        # its point lies inside the range box (|bx - x| <= 170.0
        # and |by - y| <= 170.0, the Java intersect rect, range
        # 170f per-def). The function returns `{"targets_count":
        # count, "has_targets_count": true}` when an observation
        # exists and `{"targets_count": null, "has_targets_count":
        # false}` when it does not. The driver stamps
        # frame["targets_count"] only when has_targets_count is
        # true, and calls the scan after the N2192 charge and
        # before the N2194 fire.
        self.assertIn('frame.get("observed_bullets", null)', shockwave_tower)
        self.assertIn('frame.get("x", null)', shockwave_tower)
        self.assertIn('frame.get("y", null)', shockwave_tower)
        self.assertIn('frame.get("team_id", null)', shockwave_tower)
        self.assertIn('bullet.get("team", null)', shockwave_tower)
        self.assertIn('bullet.get("hittable", false)', shockwave_tower)
        self.assertIn('absf(float(bullet.get("x", 0.0)) - float(tower_x)) > 170.0', shockwave_tower)
        self.assertIn('absf(float(bullet.get("y", 0.0)) - float(tower_y)) > 170.0', shockwave_tower)
        self.assertIn('return {"targets_count": null, "has_targets_count": false}', shockwave_tower)
        self.assertIn('return {"targets_count": targets_count, "has_targets_count": true}', shockwave_tower)
        with self.subTest(case='counts enemy hittable bullets inside the range box'):
            self.assertIn('absf(float(bullet.get("x", 0.0)) - float(tower_x)) > 170.0', shockwave_tower)
        with self.subTest(case='excludes same-team bullets'):
            self.assertIn('bullet.get("team", null)', shockwave_tower)
        with self.subTest(case='excludes non-hittable bullets'):
            self.assertIn('bullet.get("hittable", false)', shockwave_tower)
        with self.subTest(case='excludes bullets outside the range box'):
            self.assertIn('absf(float(bullet.get("y", 0.0)) - float(tower_y)) > 170.0', shockwave_tower)
        with self.subTest(case='absent observed_bullets stamps nothing'):
            self.assertIn('return {"targets_count": null, "has_targets_count": false}', shockwave_tower)
        with self.subTest(case='live driver stamps targets_count'):
            self.assertIn('source_shockwave_tower_bullet_scan_state(frame)', shockwave_tower)
        self.assertIn('source_shockwave_tower_bullet_scan_state(frame)', shockwave_tower)
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
        # The proof's keys drive the pure scan (counts enemy
        # hittable bullets in range / excludes same-team bullets
        # / excludes non-hittable bullets / excludes bullets
        # outside the range box / absent observed_bullets stamps
        # nothing) plus the live tick (the driver stamps
        # targets_count live). There are no wave-damage / Fx /
        # sound / shake / event / sense / warmup keys: the wave
        # damage application (:87-96), waveEffect / shootSound /
        # shake / hitEffect (:84-86, :95), the shockwaveTowerUse
        # event (:97-99), sense(LAccess.progress) (:110), warmup()
        # (:117) and the cyanogen liquid consumer
        # (Blocks.java:2041) wait for their own slices, and the
        # timer cadence (:73, checkInterval 8f) waits for a
        # per-building-timer slice.
        proof = SHOCKWAVE_TOWER_BULLET_SCAN_PROOF.read_text(encoding='utf-8')
        for key in [
            'counts_enemy_hittable_in_range',
            'excludes_same_team_bullets',
            'excludes_non_hittable_bullets',
            'excludes_bullets_outside_range_box',
            'absent_observed_bullets_stamps_nothing',
            'live_driver_stamps_targets_count',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_bullet_scan(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerBulletScanProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_BULLET_SCAN_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'counts_enemy_hittable_in_range',
            'excludes_same_team_bullets',
            'excludes_non_hittable_bullets',
            'excludes_bullets_outside_range_box',
            'absent_observed_bullets_stamps_nothing',
            'live_driver_stamps_targets_count',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
