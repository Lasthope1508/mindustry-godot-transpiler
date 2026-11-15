import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_HIT_EFFECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerHitEffectProof.gd'


class C07ShockwaveTowerHitEffectTests(unittest.TestCase):
    def test_c07_shockwave_tower_hit_effect_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2198']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_hit_effect_state')
        # N2194's fire gate sets heat 1f and resets the counter
        # (ShockwaveTower.java:82-83, `heat = 1f;` /
        # `reloadCounter = 0f;`), N2195's scan stamps the observed
        # `targets_count`, N2196's wave damage applies the wave
        # (`float waveDamage = Math.min(bulletDamage, bulletDamage
        # * falloffCount / targets.size);`,
        # ShockwaveTower.java:87) and stamps one outcome per
        # target bullet (`bullet_outcomes`, with hit_x/hit_y),
        # and N2197's fire effects stamp the wave effect, the
        # shoot sound and the shake (ShockwaveTower.java:84-86)
        # -- but the per-target hit effect
        # (`hitEffect.at(target.x, target.y, waveColor);`,
        # ShockwaveTower.java:95, over `public Effect hitEffect =
        # Fx.hitSquaresColor;`, ShockwaveTower.java:35) has NO
        # pure function in the port -- a firing tower damages or
        # removes bullets with no hit effect ever recorded at any
        # target position. N2198 owns the hit effect. The pure
        # function consumes the N2196 `bullet_outcomes` stamped on
        # the frame (one outcome per target, in the same order as
        # Java's targets loop: `for(var target : targets){`,
        # ShockwaveTower.java:89) and returns one descriptor per
        # outcome: `{"effect": "hitSquaresColor", "x": hit_x, "y":
        # hit_y, "color": "Pal.accent"}` (Fx.hitSquaresColor
        # takes e.color from the at() color argument -- `color(
        # Color.white, e.color, e.fin());`, Fx.java:891 -- and
        # waveColor is Pal.accent, ShockwaveTower.java:29,
        # `public Color waveColor = Pal.accent, heatColor =
        # Pal.turretHeat, shapeColor = Color.valueOf("f29c83");`,
        # Pal.accent = Color.valueOf("ffd37f"), Pal.java:79).
        # The effect fires for EVERY target in the loop, damaged
        # or removed alike -- it sits after the damage / remove
        # branch (ShockwaveTower.java:90-94), not inside either
        # arm. Absent `bullet_outcomes` (or an empty list) means
        # "no hit effects": `{"hit_effects": [], "has_hit_effects":
        # false}` and the driver stamps nothing (the N2190 /
        # N2195 / N2196 precedent) -- never a fabricated
        # descriptor. The driver calls the hit effect AFTER the
        # N2196 wave damage and ONLY when the fire fired (the
        # Java order :87 before :89-95): the hit effect lives
        # inside the fire gate in Java (:81-96), so a
        # charged-but-unfired tick spawns nothing. Two new result
        # symbols: the hit-effects list and the hit-effects flag.
        self.assertEqual(
            ledger['N2198']['source_symbols'],
            [
                'source_shockwave_tower_hit_effect_state_result.hit_effects',
                'source_shockwave_tower_hit_effect_state_result.has_hit_effects',
            ],
        )
        for name in ledger['N2198']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_hit_effect_state_result.hit_effects': 'SourceShockwaveTowerBuildState.source_shockwave_tower_hit_effect_state',
                    'source_shockwave_tower_hit_effect_state_result.has_hit_effects': 'SourceShockwaveTowerBuildState.source_shockwave_tower_hit_effect_state',
                }[name])
        self.assertEqual(ledger['N2198']['runtime_proof'], '/root/C07ShockwaveTowerHitEffectProof')
        self.assertEqual(
            ledger['N2198']['tests'],
            [
                'test_c07_shockwave_tower_hit_effect_registration',
                'test_all_c07_shockwave_tower_hit_effect_input_evidence_is_exact',
                'test_shockwave_tower_hit_effect_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_hit_effect',
            ],
        )
        self.assertTrue(ledger['N2198']['deferred_exprs'])

    def test_all_c07_shockwave_tower_hit_effect_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2198']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_hit_effect_state_result.hit_effects': 'SourceShockwaveTowerBuildState.source_shockwave_tower_hit_effect_state',
                    'source_shockwave_tower_hit_effect_state_result.has_hit_effects': 'SourceShockwaveTowerBuildState.source_shockwave_tower_hit_effect_state',
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
        for expr in ledger['N2198']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_hit_effect_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The hit effect lives on the shockwave-tower build
        # state: ShockwaveTowerBuild.updateTile fires its wave
        # when the reload counter reaches reload with targets
        # observed (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :81, `if(targets.size > 0){`), then applies the wave damage (`float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`, ShockwaveTower.java:87) and loops the targets (`for(var target : targets){`, ShockwaveTower.java:89): a target whose damage exceeds the wave damage loses exactly waveDamage (`if(target.damage > waveDamage){` / `target.damage -= waveDamage;`, ShockwaveTower.java:90-91 -- the STRICT comparison, so a target at exactly waveDamage is removed, not left at 0), any other target is removed (`target.remove();`, ShockwaveTower.java:93), and EVERY target gets its hit effect at its own position (`hitEffect.at(target.x, target.y, waveColor);`, ShockwaveTower.java:95, over `public Effect hitEffect = Fx.hitSquaresColor;`, ShockwaveTower.java:35 -- Fx.hitSquaresColor takes e.color from the at() color argument, `color(Color.white, e.color, e.fin());`, Fx.java:891, and waveColor is Pal.accent, ShockwaveTower.java:29, `public Color waveColor = Pal.accent, heatColor = Pal.turretHeat, shapeColor = Color.valueOf("f29c83");`, Pal.accent = Color.valueOf("ffd37f"), Pal.java:79). The port spawns no real Fx (no Godot equivalents are wired), so the pure function stamps one descriptor per Java call instead of spawning it: `{"effect": "hitSquaresColor", "x": hit_x, "y": hit_y, "color": "Pal.accent"}` per target. The function consumes the N2196 `bullet_outcomes` stamped on the frame (one outcome per target, in the same order as Java's targets loop, each with hit_x/hit_y) -- never re-filtering the observed bullets, so the hit effects cover exactly the targets the wave damage just processed. Absent `bullet_outcomes` (or an empty list) means "no hit effects": `{"hit_effects": [], "has_hit_effects": false}` and the driver stamps nothing (the N2190 / N2195 / N2196 precedent) -- never a fabricated descriptor. The driver calls the hit effect AFTER the N2196 wave damage and ONLY when the fire fired (the Java order :87 before :89-95), stamping `frame["hit_effects"]` only when has_hit_effects is true -- the hit effect lives inside the fire gate in Java (:81-96), so a charged-but-unfired tick spawns nothing, and the stamped descriptors persist on the frame until the next fire (like heat / the N2196 outcomes).
        self.assertIn('static func source_shockwave_tower_hit_effect_state', shockwave_tower)
        # The hit-effect cases, pinned as the pure function's
        # decision structure: the frame carries the N2196
        # `bullet_outcomes` (an array of dicts with hit_x/hit_y
        # per target, in Java targets order). The hit effect is
        # Fx.hitSquaresColor at each target's own position with
        # color Pal.accent, for EVERY target -- damaged or removed
        # alike. The function returns `{"hit_effects": [...],
        # "has_hit_effects": true}` when the outcomes are present
        # and non-empty and `{"hit_effects": [],
        # "has_hit_effects": false}` when they are absent or
        # empty. The driver calls it after the N2196 wave damage,
        # only when the fire fired, and stamps
        # frame["hit_effects"] only when has_hit_effects is true.
        self.assertIn('frame.get("bullet_outcomes", null)', shockwave_tower)
        self.assertIn('"effect": "hitSquaresColor"', shockwave_tower)
        self.assertIn('"color": "Pal.accent"', shockwave_tower)
        self.assertIn('return {"hit_effects": [], "has_hit_effects": false}', shockwave_tower)
        self.assertIn('return {"hit_effects": hit_effects, "has_hit_effects": true}', shockwave_tower)
        with self.subTest(case='hit effect spawns at each target position'):
            self.assertIn('"effect": "hitSquaresColor"', shockwave_tower)
        with self.subTest(case='removed and damaged bullets both get effects'):
            self.assertIn('"effect": "hitSquaresColor"', shockwave_tower)
        with self.subTest(case='absent outcomes spawn nothing'):
            self.assertIn('return {"hit_effects": [], "has_hit_effects": false}', shockwave_tower)
        with self.subTest(case='live driver stamps hit effects only on fire'):
            self.assertIn('source_shockwave_tower_hit_effect_state(frame)', shockwave_tower)
        self.assertIn('source_shockwave_tower_hit_effect_state(frame)', shockwave_tower)
        self.assertIn('frame["hit_effects"]', shockwave_tower)
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
        # The proof's keys drive the pure hit effect (one
        # descriptor per target at its own position / removed and
        # damaged bullets both get effects / absent or empty
        # outcomes spawn nothing) plus the live tick (the driver
        # stamps the hit effects only on a fire tick). There are
        # no event / sense / warmup keys: the shockwaveTowerUse
        # event (:97-99), sense(LAccess.progress) (:110),
        # warmup() (:117) and the cyanogen liquid consumer
        # (Blocks.java:2041) wait for their own slices, and the
        # timer cadence (:73, checkInterval 8f) waits for a
        # per-building-timer slice.
        proof = SHOCKWAVE_TOWER_HIT_EFFECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'hit_effects_spawn_at_target_positions',
            'removed_and_damaged_bullets_both_get_effects',
            'absent_outcomes_spawn_nothing',
            'empty_outcomes_spawn_nothing',
            'live_driver_stamps_hit_effects_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_hit_effect(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerHitEffectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_HIT_EFFECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'hit_effects_spawn_at_target_positions',
            'removed_and_damaged_bullets_both_get_effects',
            'absent_outcomes_spawn_nothing',
            'empty_outcomes_spawn_nothing',
            'live_driver_stamps_hit_effects_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
