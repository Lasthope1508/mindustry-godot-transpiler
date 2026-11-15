import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_USE_EVENT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerUseEventProof.gd'


class C07ShockwaveTowerUseEventTests(unittest.TestCase):
    def test_c07_shockwave_tower_use_event_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2199']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_use_event_state')
        # N2194's fire gate sets heat 1f and resets the counter
        # (ShockwaveTower.java:82-83, `heat = 1f;` /
        # `reloadCounter = 0f;`), N2195's scan stamps the observed
        # `targets_count`, N2196's wave damage applies the wave
        # (`float waveDamage = Math.min(bulletDamage, bulletDamage
        # * falloffCount / targets.size);`,
        # ShockwaveTower.java:87) and stamps one outcome per
        # target bullet (`bullet_outcomes`, with hit_x/hit_y),
        # N2197's fire effects stamp the wave effect, the
        # shoot sound and the shake (ShockwaveTower.java:84-86)
        # and N2198's hit effect stamps one Fx.hitSquaresColor
        # descriptor per target (`hitEffect.at(target.x, target.y,
        # waveColor);`, ShockwaveTower.java:95) -- but the
        # shockwaveTowerUse event (`if(team ==
        # state.rules.defaultTeam){` /
        # `Events.fire(Trigger.shockwaveTowerUse);`,
        # ShockwaveTower.java:98-99, over `shockwaveTowerUse,` in
        # the Trigger enum, EventType.java:28, and `public Team
        # defaultTeam = Team.sharded;`, Rules.java:205) has NO
        # pure function in the port -- a firing default-team tower
        # damages bullets and spawns every effect with no event
        # ever recorded. N2199 owns the event. The pure function
        # reads the frame's `fired` key (the N2194 fire result,
        # stamped on the frame by the GREEN driver alongside
        # `reload_counter` / `heat`) and its `team_id` key
        # (already stamped by the tick wiring from the sprite
        # team meta) and returns `{"event":
        # "shockwaveTowerUse", "event_fired": true}` only when the
        # tower fired AND its team is the default team (sharded,
        # id 1, Team.java:34, `sharded = new Team(1, "sharded",
        # Pal.accent.cpy(), Color.valueOf("ffd37f"),
        # Color.valueOf("eab678"), Color.valueOf("d4816b")),`,
        # read through the port's existing
        # SOURCE_TEAM_SHARDED_ID constant -- the frame's
        # `rules_state` carries no defaultTeam key, so the
        # comparison uses the Java Rules default, a documented
        # limit: a custom rules defaultTeam override is not
        # modeled). Any other combination -- not fired, another
        # team, absent `fired` or absent `team_id` -- means "no
        # event": `{"event": null, "event_fired": false}` and the
        # driver stamps nothing (the N2190 / N2195 / N2196
        # precedent) -- never a fabricated event. The driver
        # calls the event AFTER the N2198 hit effect and ONLY
        # when the fire fired (the Java order :89-95 before
        # :98-99): the event lives inside the fire gate in Java
        # (:81-100), so a charged-but-unfired tick fires nothing.
        # The port fires no real event (no Events / Trigger bus
        # is wired), so the pure function stamps the trigger name
        # instead of firing it -- the same descriptor pattern as
        # the N2197 Fx / sound / shake. No RNG. Two new result
        # symbols: the event name and the event-fired flag.
        self.assertEqual(
            ledger['N2199']['source_symbols'],
            [
                'source_shockwave_tower_use_event_state_result.event',
                'source_shockwave_tower_use_event_state_result.event_fired',
            ],
        )
        for name in ledger['N2199']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_use_event_state_result.event': 'SourceShockwaveTowerBuildState.source_shockwave_tower_use_event_state',
                    'source_shockwave_tower_use_event_state_result.event_fired': 'SourceShockwaveTowerBuildState.source_shockwave_tower_use_event_state',
                }[name])
        self.assertEqual(ledger['N2199']['runtime_proof'], '/root/C07ShockwaveTowerUseEventProof')
        self.assertEqual(
            ledger['N2199']['tests'],
            [
                'test_c07_shockwave_tower_use_event_registration',
                'test_all_c07_shockwave_tower_use_event_input_evidence_is_exact',
                'test_shockwave_tower_use_event_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_use_event',
            ],
        )
        self.assertTrue(ledger['N2199']['deferred_exprs'])

    def test_all_c07_shockwave_tower_use_event_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2199']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_use_event_state_result.event': 'SourceShockwaveTowerBuildState.source_shockwave_tower_use_event_state',
                    'source_shockwave_tower_use_event_state_result.event_fired': 'SourceShockwaveTowerBuildState.source_shockwave_tower_use_event_state',
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
            'core/src/mindustry/game/EventType.java',
            'core/src/mindustry/game/Rules.java',
            'core/src/mindustry/game/Team.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2199']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_use_event_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The use event lives on the shockwave-tower build
        # state: ShockwaveTowerBuild.updateTile fires its wave
        # when the reload counter reaches reload with targets
        # observed (ShockwaveTower.java:73, `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` with :81, `if(targets.size > 0){`), then applies the wave damage (`float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);`, ShockwaveTower.java:87) and loops the targets (`for(var target : targets){`, ShockwaveTower.java:89), and EVERY target gets its hit effect at its own position (`hitEffect.at(target.x, target.y, waveColor);`, ShockwaveTower.java:95, over `public Effect hitEffect = Fx.hitSquaresColor;`, ShockwaveTower.java:35) -- and then, inside the same fire gate, the tower fires the shockwaveTowerUse event when its team is the default team (`if(team == state.rules.defaultTeam){` / `Events.fire(Trigger.shockwaveTowerUse);`, ShockwaveTower.java:98-99, over `shockwaveTowerUse,` in the Trigger enum, EventType.java:28, and `public Team defaultTeam = Team.sharded;`, Rules.java:205 -- sharded is id 1, Team.java:34, `sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),`). The port fires no real event (no Events / Trigger bus is wired), so the pure function stamps the trigger name instead of firing it: `{"event": "shockwaveTowerUse", "event_fired": true}` when the frame records a fire (`fired` true, the N2194 result) AND the tower team is the default team (`team_id` == SOURCE_TEAM_SHARDED_ID, 1), and `{"event": null, "event_fired": false}` otherwise -- not fired, another team (crux is id 2), absent `fired` or absent `team_id` -- and the driver stamps nothing (the N2190 / N2195 / N2196 precedent) -- never a fabricated event. The frame's `rules_state` carries no defaultTeam key, so the comparison uses the Java Rules default (sharded, id 1), a documented limit: a custom rules defaultTeam override is not modeled. The driver calls the event AFTER the N2198 hit effect and ONLY when the fire fired (the Java order :89-95 before :98-99), stamping `frame["shockwave_tower_use_event"]` only when event_fired is true -- the event lives inside the fire gate in Java (:81-100), so a charged-but-unfired tick fires nothing, and the stamped event persists on the frame until the next fire (like heat / the N2196 outcomes). No RNG.
        self.assertIn('static func source_shockwave_tower_use_event_state', shockwave_tower)
        # The use-event cases, pinned as the pure function's
        # decision structure: the frame carries the N2194 `fired`
        # flag (stamped by the GREEN driver alongside
        # `reload_counter` / `heat`) and the `team_id` key
        # (already stamped by the tick wiring). The event fires
        # only when the tower fired AND its team is the default
        # team (sharded, id 1, SOURCE_TEAM_SHARDED_ID). The
        # function returns `{"event": "shockwaveTowerUse",
        # "event_fired": true}` when both hold and `{"event":
        # null, "event_fired": false}` otherwise. The driver calls
        # it after the N2198 hit effect, only when the fire fired,
        # and stamps frame["shockwave_tower_use_event"] only when
        # event_fired is true.
        self.assertIn('frame.get("fired", null)', shockwave_tower)
        self.assertIn('frame.get("team_id", null)', shockwave_tower)
        self.assertIn('source_block_geometry.SOURCE_TEAM_SHARDED_ID', shockwave_tower)
        self.assertIn('return {"event": null, "event_fired": false}', shockwave_tower)
        self.assertIn('return {"event": "shockwaveTowerUse", "event_fired": true}', shockwave_tower)
        with self.subTest(case='event fires on fire for the default team'):
            self.assertIn('return {"event": "shockwaveTowerUse", "event_fired": true}', shockwave_tower)
        with self.subTest(case='event silent for another team'):
            self.assertIn('return {"event": null, "event_fired": false}', shockwave_tower)
        with self.subTest(case='event silent without fire'):
            self.assertIn('return {"event": null, "event_fired": false}', shockwave_tower)
        with self.subTest(case='live driver stamps event only on fire'):
            self.assertIn('source_shockwave_tower_use_event_state(frame)', shockwave_tower)
        self.assertIn('source_shockwave_tower_use_event_state(frame)', shockwave_tower)
        self.assertIn('frame["shockwave_tower_use_event"]', shockwave_tower)
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
        self.assertIn('shockwaveTowerUse,', shockwave_tower)
        self.assertIn('public Team defaultTeam = Team.sharded;', shockwave_tower)
        self.assertIn('sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),', shockwave_tower)
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
        # The proof's keys drive the pure use event (the event
        # fires on a fire tick for the default team / stays silent
        # for another team / stays silent without a fire / absent
        # keys fire nothing) plus the live tick (the driver stamps
        # the event only on a fire tick). There are no sense /
        # warmup keys: sense(LAccess.progress) (:110), warmup()
        # (:117) and the cyanogen liquid consumer
        # (Blocks.java:2041) wait for their own slices, and the
        # timer cadence (:73, checkInterval 8f) waits for a
        # per-building-timer slice.
        proof = SHOCKWAVE_TOWER_USE_EVENT_PROOF.read_text(encoding='utf-8')
        for key in [
            'event_fires_on_fire_for_default_team',
            'event_silent_for_other_team',
            'event_silent_without_fire',
            'absent_keys_fire_nothing',
            'live_driver_stamps_event_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_shockwave_tower_use_event(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerUseEventProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_USE_EVENT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'event_fires_on_fire_for_default_team',
            'event_silent_for_other_team',
            'event_silent_without_fire',
            'absent_keys_fire_nothing',
            'live_driver_stamps_event_on_fire',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
