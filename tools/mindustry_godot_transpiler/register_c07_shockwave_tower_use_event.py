"""Register the ShockwaveTower shockwaveTowerUse event (N2199).

The ShockwaveTower's updateTile shockwaveTowerUse event,
following the N2177 pure-row pattern and the N2190/N2194/N2195
observed-key precedent. N2194's fire gate sets heat 1f and
resets the counter (ShockwaveTower.java:82-83), N2195's scan
stamps the observed `targets_count`, N2196's wave damage
applies the wave (`float waveDamage =
Math.min(bulletDamage, bulletDamage * falloffCount /
targets.size);`, ShockwaveTower.java:87) and stamps one outcome
per target bullet (`bullet_outcomes`, with hit_x/hit_y),
N2197's fire effects stamp the wave effect, the shoot sound
and the shake (ShockwaveTower.java:84-86) and N2198's hit
effect stamps one Fx.hitSquaresColor descriptor per target
(`hitEffect.at(target.x, target.y, waveColor);`,
ShockwaveTower.java:95) -- but the shockwaveTowerUse event
(`if(team == state.rules.defaultTeam){` /
`Events.fire(Trigger.shockwaveTowerUse);`,
ShockwaveTower.java:98-99, over `shockwaveTowerUse,` in the
Trigger enum, EventType.java:28, and `public Team defaultTeam =
Team.sharded;`, Rules.java:205) has NO pure function in the
port -- a firing default-team tower damages bullets and spawns
every effect with no event ever recorded. N2199 owns the
event. The pure function
(source_shockwave_tower_use_event_state) reads the frame's
`fired` key (the N2194 fire result, stamped on the frame by
the GREEN driver alongside `reload_counter` / `heat`) and its
`team_id` key (already stamped by the tick wiring from the
sprite team meta) and returns `{"event":
"shockwaveTowerUse", "event_fired": true}` only when the
tower fired AND its team is the default team (sharded, id 1,
Team.java:34, `sharded = new Team(1, "sharded",
Pal.accent.cpy(), Color.valueOf("ffd37f"),
Color.valueOf("eab678"), Color.valueOf("d4816b")),`, read
through the port's existing SOURCE_TEAM_SHARDED_ID constant
-- the frame's `rules_state` carries no defaultTeam key, so
the comparison uses the Java Rules default, a documented
limit: a custom rules defaultTeam override is not modeled).
Any other combination -- not fired, another team, absent
`fired` or absent `team_id` -- means "no event": `{"event":
null, "event_fired": false}` and the driver stamps nothing
(the N2190 / N2195 / N2196 precedent) -- never a fabricated
event. The driver calls the event AFTER the N2198 hit effect
and ONLY when the fire fired (the Java order :89-95 before
:98-99): the event lives inside the fire gate in Java
(:81-100), so a charged-but-unfired tick fires nothing. The
port fires no real event (no Events / Trigger bus is wired),
so the pure function stamps the trigger name instead of
firing it -- the same descriptor pattern as the N2197 Fx /
sound / shake. The achievement hook
(GameService.java:397, `trigger(Trigger.shockwaveTowerUse,
shockwaveTowerUse);` over Achievement.java:110) is downstream
of the event bus and is not modeled. No sense, no warmup, no
draw: those wait for their own slices. The driver change is
one `fired` stamp next to the N2194 reload_counter / heat
stamps plus one gated call + comment in the existing
source_shockwave_tower_tick_buildings_state, AFTER the N2198
hit effect call, stamping `frame["shockwave_tower_use_event"]`
only when the event reports one. No new frame meta key, no
SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change. Shard note: like
N2192/N2193/N2194/N2195/N2196/N2197/N2198,
ShockwaveTower.java IS selected by the defense_slices shard
(java_source contains /world/blocks/defense/) and its owner
by defense_api_contracts, so the GREEN register run is
expected to mirror N2199 into both defense shards (the N2177
/ N2192 / N2193 / N2194 / N2195 / N2196 / N2197 / N2198
precedent).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false, the N2192 charge
already advances the counter by edelta(), the N2194 fire
already reads the observed `targets_count` and resets the
counter, the N2195 scan already filters the observed bullets,
N2196 already applies the wave damage and stamps one outcome
per target, N2197 already stamps the fire effects and N2198
already stamps the hit effect. N2199 does not touch any of
them. N2199 supplies the missing pure use event + the one
gated driver call (+ the `fired` frame stamp the pure function
reads); no new consumer rows. The shockwave tower's power draw
stays STATIC (consumePower 100f/60f, Blocks.java:2042 -- a
plain ConsumePower, not the RepairTurret-style conditional
draw), so the folded efficiency is the min over the *modeled*
consumers (power only); the cyanogen liquid consumer
(consumeLiquids cyanogen 1.5f/60f, Blocks.java:2041) is the
second pass and waits for its own slice. Single def
(shockwave-tower, size 3, range 170f, reload 80f,
Blocks.java:2038-2044).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_shockwave_tower_hit_effect import DEFERRED as _N2198_DEFERRED

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SHOCKWAVE_TOWER = 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
TIMER_COMP = 'core/src/mindustry/entities/comp/TimerComp.java'
VARS = 'core/src/mindustry/Vars.java'
TILE = 'core/src/mindustry/world/Tile.java'
EVENT_TYPE = 'core/src/mindustry/game/EventType.java'
RULES = 'core/src/mindustry/game/Rules.java'
TEAM = 'core/src/mindustry/game/Team.java'
PROOF = '/root/C07ShockwaveTowerUseEventProof'
OWNER = 'SourceShockwaveTowerBuildState.source_shockwave_tower_use_event_state'
TESTS = ['test_c07_shockwave_tower_use_event_registration', 'test_all_c07_shockwave_tower_use_event_input_evidence_is_exact', 'test_shockwave_tower_use_event_state', 'test_reference_graph_and_actual_c07_shockwave_tower_use_event']
EXACT_EXPRS = ['if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'public float reloadCounter = Mathf.random(reload);', 'public float heat = 0f;', 'public float reload = 60f * 1.5f;', 'public float range = 110f;', 'public float checkInterval = 8f;', 'public float cooldownMultiplier = 1f;', 'public class ShockwaveTower extends Block{', 'public class ShockwaveTowerBuild extends Building{', 'return reloadCounter < reload;', 'public boolean shouldConsume(){', 'if(sensor == LAccess.progress) return reloadCounter / reload;', 'heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', 'return heat;', 'public void updateTile(){', 'heat = 1f;', 'reloadCounter = 0f;', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'public float bulletDamage = 160;', 'public float falloffCount = 20f;', 'public float shake = 2f;', 'public int timerCheck = timers ++;', 'update = true;', 'solid = true;', 'return efficiency * delta();', 'return potentialEfficiency > 0;', 'public boolean canConsume(){', 'potentialEfficiency = efficiency;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'consumePower(100f / 60f);', 'consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', 'range = 170f;', 'reload = 80f;', 'size = 3;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'targets.clear();', 'Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', 'if(b.team != team && b.type.hittable){', 'targets.add(b);', 'if(targets.size > 0){', 'waveEffect.at(x, y, range, waveColor);', 'shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', 'Effect.shake(shake, shake, this);', 'for(var target : targets){', 'if(target.damage > waveDamage){', 'target.damage -= waveDamage;', 'target.remove();', 'hitEffect.at(target.x, target.y, waveColor);', 'if(team == state.rules.defaultTeam){', 'Events.fire(Trigger.shockwaveTowerUse);', 'public Sound shootSound = Sounds.shockwaveTower;', 'public Effect waveEffect = Fx.pointShockwave;', 'public Effect hitEffect = Fx.hitSquaresColor;', 'public boolean timer(int index, float time){', 'return timer.get(index, time);', 'transient Interval timer = new Interval(6);', 'public Seq<Bullet> targets = new Seq<>();', 'public static final int tilesize = 8;', 'offset = ((size + 1) % 2) * tilesize / 2f;', 'return x * tilesize;', 'return block().offset + worldx();', 'shockwaveTowerUse,', 'public Team defaultTeam = Team.sharded;', 'sharded = new Team(1, "sharded", Pal.accent.cpy(), Color.valueOf("ffd37f"), Color.valueOf("eab678"), Color.valueOf("d4816b")),']

# DEFERRED is carried from the N2198 register script via import --
# never retyped. The N2198 script's DEFERRED is a computed
# expression (list(_N2197_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. NOTE for the next slice:
# N2199's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval. Chain gap, recorded 2026-11-15 at N2192 RED
# and still true: the inherited 164-entry list contains NO
# ShockwaveTower entries -- N2177's register script added them
# as a literal, but the chain forked between N2185 and N2190 and
# the later slices carried the pre-N2177 list forward, so the
# N2177 ShockwaveTower deferred items (fire gate / shouldConsume
# gate / liquid / sense-warmup / draw / shape-timer / trigger /
# per-def) live only in the N2177 ledger row, not in this carried
# list. The new entries below re-pin the still-deferred
# ShockwaveTower follow-ups from N2199's own standpoint instead
# of retyping the old list. The use event itself is NOT carried
# as deferred: it is THIS slice (N2199) -- the inherited N2198
# entry still names it as waiting, which is stale history,
# superseded by this slice.
DEFERRED = list(_N2198_DEFERRED) + [
    'ShockwaveTower use event Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2198: the N2199 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ShockwaveTower fire follow-ups after the use event (ShockwaveTower.java:73 timer cadence timer(timerCheck, checkInterval 8f) -- the port tracks no per-building Interval timer state, so the port fires on the first ready tick where Java waits for a timer tick, and the scan runs every tick where Java scans only on a timer tick; :110 sense(LAccess.progress); :117 warmup(); cyanogen liquid consumer Blocks.java:2041; draw :126-134; bullet hitSize -- the scan tests the bullet point against the intersect rect, not the bullet hitbox overlap Java intersect tests) -- N2199 lands ONLY the use event (if(team == state.rules.defaultTeam) Events.fire(Trigger.shockwaveTowerUse) :98-99) from the N2194 fire result and the frame team_id; the timer cadence, sense, warmup, liquid, draw and hitSize wait for their own slices.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2199_inputs = {
        'frame': f('Dictionary', 'if(team == state.rules.defaultTeam){', 'The building frame carrying the N2194 `fired` flag (the fire result, stamped on the frame by the GREEN driver alongside `reload_counter` / `heat`) and the `team_id` key (already stamped by the tick wiring from the sprite team meta, SOURCE_TEAM_SHARDED_ID 1 for a placed default-team tower) -- the event fires only when the tower fired AND its team is the default team. Absent `fired` or absent `team_id` means "no event" and the driver stamps nothing (the N2190 / N2195 / N2196 precedent).', source=BUILDING_COMP),
    }
    n2199_outputs = {
        'event': f('String', 'Events.fire(Trigger.shockwaveTowerUse);', 'The fired trigger name (ShockwaveTower.java:99): "shockwaveTowerUse" (`shockwaveTowerUse,` in the Trigger enum, EventType.java:28) when the tower fired on a default-team frame, null otherwise. The port fires no real event (no Events / Trigger bus is wired), so the pure function stamps the trigger name instead of firing it -- the same descriptor pattern as the N2197 Fx / sound / shake. The achievement hook (GameService.java:397 `trigger(Trigger.shockwaveTowerUse, shockwaveTowerUse);` over Achievement.java:110) is downstream of the event bus and is not modeled.'),
        'event_fired': f('bool', 'if(team == state.rules.defaultTeam){', 'Whether the event fired (ShockwaveTower.java:98): true only when the frame records a fire (`fired` true, the N2194 result) AND the tower team is the default team (`team_id` == SOURCE_TEAM_SHARDED_ID, 1 -- Rules.java:205 `public Team defaultTeam = Team.sharded;`, Team.java:34; the frame `rules_state` carries no defaultTeam key, so the comparison uses the Java Rules default, a documented limit) -- the driver stamps frame["shockwave_tower_use_event"] only when this is true, and only on a tick where the N2194 fire fired, after the N2198 hit effect.'),
    }

    entries = [
        ('N2199', OWNER, 'source_shockwave_tower_use_event_state', SHOCKWAVE_TOWER, 'mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', 'ShockwaveTowerBuild.updateTile()', n2199_inputs, n2199_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShockwaveTower use event from ShockwaveTower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShockwaveTower use event from ShockwaveTower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the event name, the
    # event-fired flag.
    by_slice['N2199'] = [
        'source_shockwave_tower_use_event_state_result.event',
        'source_shockwave_tower_use_event_state_result.event_fired',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2199', dict(status='done', java_source=SHOCKWAVE_TOWER, java_class='mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', java_method='ShockwaveTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2199'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
