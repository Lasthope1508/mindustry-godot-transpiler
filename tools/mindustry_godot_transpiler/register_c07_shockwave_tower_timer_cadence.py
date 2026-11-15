"""Register the ShockwaveTower timer cadence (N2200).

The ShockwaveTower's updateTile fire gate has three conjuncts
(`if(potentialEfficiency > 0 && (reloadCounter += edelta()) >=
reload && timer(timerCheck, checkInterval)){`,
ShockwaveTower.java:73, with `public float checkInterval =
8f;`, ShockwaveTower.java:31, over `public int timerCheck =
timers ++;`, ShockwaveTower.java:23, and `public int timers =
0;`, Block.java:231): the first two are modeled -- N2192's
charge advances the counter by edelta() (BuildingComp.java:1927-1929,
`return efficiency * delta();`) and N2194's fire reads the
charged counter against reload 80f (Blocks.java:2044, `reload
= 80f;`) -- but the third conjunct, the per-building Interval
timer (`timer(timerCheck, checkInterval)`), has NO pure
function in the port -- so the port fires on the first tick
the counter is at reload with targets observed, where Java
fires only on a timer tick, up to checkInterval (8 ticks,
Time.delta is ticks: `Math.min(Core.graphics.getDeltaTime() *
60f, 3f)`, Time.java:26, with `timeRaw += delta;` / `time =
(float)timeRaw;`, Time.java:70-75) earlier, and the port
scans every tick where Java scans only on a timer tick (the
N2195 scan comment defers exactly this cadence to the
per-building-timer slice). N2200 owns the timer. The pure
function (source_shockwave_tower_timer_state) reads the
frame's `potential_efficiency` / `reload_counter` gate inputs
(the N2192 charge stamps the counter, the consumption
machinery stamps potential_efficiency) and its
`timer_elapsed` key (seconds since the last due check on the
port's seconds clock -- the N2190 refresh / N2192 charge
precedent: the port's driver clock is seconds, so
checkInterval 8f runs as 8.0 port-seconds, keeping the Java
ratio of 10 checks per 80-reload charge; Java wall time is 8
ticks ~= 0.13s) and returns `{"check_due": bool,
"timer_elapsed": float}`: due when the gate is open
(potential_efficiency > 0 AND reload_counter >= 80.0) AND
the interval elapsed (timer_elapsed >= 8.0, the
Interval.check `>=`); a fresh frame (no `timer_elapsed` key
-- a fresh Interval, whose slots start at 0 over `times =
new float[capacity];`, Interval.java:7, while global
Time.time is long past 8 at any real placement) is due on its
first gated consult; a due check restarts the elapsed clock
at 0.0 (the `if(got) times[id] = Time.time;` stamp); a
closed gate never consumes the due-ness -- the elapsed clock
keeps running, so the check stays due until the gate opens
(the Interval property: the timer is only consulted when the
first two conjuncts hold, and Time.time keeps advancing while
they do not). The backward-time clause (`Time.time <
times[id]`) is not modeled: the port's relative clock never
rewinds. The timer consult is TimerComp.timer (`public
boolean timer(int index, float time){` /
`if(Float.isInfinite(time)) return false;` / `return
timer.get(index, time);`, TimerComp.java:10-13, over
`transient Interval timer = new Interval(6);`,
TimerComp.java:9), and Interval.get stamps the slot on a due
check (`boolean got = check(id, time);` / `if(got)
times[id] = Time.time;`, Interval.java:23-24) when the
global tick clock has advanced past the interval (`return
Time.time - times[id] >= time || Time.time < times[id];`,
Interval.java:29). The driver calls the timer AFTER the
N2192 charge (the Java order: the charge runs inside the gate
condition before the timer consult) and BEFORE the N2195
scan, stamps `timer_elapsed` and `timer_check_due` on the
frame, and runs the scan ONLY when the check is due (Java
:74-79 live inside the :73 if); the N2194 fire still runs
every tick for its heat decay (ShockwaveTower.java:104,
outside the gate) but fires only when `timer_check_due` is
true (absent means due, the backward-compatible default for
N2194's direct calls). No RNG. Two new result symbols: the
check-due flag and the elapsed clock. The driver change is
one timer call + two stamps after the N2192 charge, one
`timer_check_due` guard around the N2195 scan call, and one
`timer_check_due` read in the N2194 fire. No new frame meta
key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change. Shard note: like
N2192/N2193/N2194/N2195/N2196/N2197/N2198/N2199,
ShockwaveTower.java IS selected by the defense_slices shard
(java_source contains /world/blocks/defense/) and its owner
by defense_api_contracts, so the GREEN register run is
expected to mirror N2200 into both defense shards (the N2177
/ N2192 / N2193 / N2194 / N2195 / N2196 / N2197 / N2198 /
N2199 precedent).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false, the N2192 charge
already advances the counter by edelta(), the N2194 fire
already reads the observed `targets_count` and resets the
counter, the N2195 scan already filters the observed bullets,
N2196 already applies the wave damage and stamps one outcome
per target, N2197 already stamps the fire effects, N2198
already stamps the hit effect and N2199 already stamps the
use event. N2200 does not touch any of them. N2200 supplies
the missing pure timer + the driver call and the two stamps
(+ the `timer_check_due` guards on the scan and the fire);
no new consumer rows. The shockwave tower's power draw stays
STATIC (consumePower 100f/60f, Blocks.java:2042 -- a plain
ConsumePower, not the RepairTurret-style conditional draw),
so the folded efficiency is the min over the *modeled*
consumers (power only); the cyanogen liquid consumer
(consumeLiquids cyanogen 1.5f/60f, Blocks.java:2041) is the
second pass and waits for its own slice. Single def
(shockwave-tower, size 3, range 170f, reload 80f,
Blocks.java:2038-2044).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_shockwave_tower_use_event import DEFERRED as _N2199_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SHOCKWAVE_TOWER = 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
TIMER_COMP = 'core/src/mindustry/entities/comp/TimerComp.java'
INTERVAL = 'arc-core/src/arc/util/Interval.java'
TIME = 'arc-core/src/arc/util/Time.java'
VARS = 'core/src/mindustry/Vars.java'
TILE = 'core/src/mindustry/world/Tile.java'
PROOF = '/root/C07ShockwaveTowerTimerCadenceProof'
OWNER = 'SourceShockwaveTowerBuildState.source_shockwave_tower_timer_state'
TESTS = ['test_c07_shockwave_tower_timer_cadence_registration', 'test_all_c07_shockwave_tower_timer_cadence_input_evidence_is_exact', 'test_shockwave_tower_timer_state', 'test_reference_graph_and_actual_c07_shockwave_tower_timer_cadence']
# The 11 slice sources the N2200 test checks exact_exprs
# against -- EventType.java / Rules.java / Team.java are NOT
# among them, so their lines (the `shockwaveTowerUse,` enum
# entry, `public Team defaultTeam = Team.sharded;`, the
# `sharded = new Team(1, ...` line) are NOT in this list even
# though N2199 carried them: the N2200 exact-evidence test
# would fail on any expr outside these 11 files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
    'core/src/mindustry/entities/comp/TimerComp.java',
    'arc-core/src/arc/util/Interval.java',
    'arc-core/src/arc/util/Time.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/consumers/ConsumePower.java',
    'core/src/mindustry/world/blocks/units/UnitAssembler.java',
    'core/src/mindustry/world/Block.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/world/Tile.java',
]
EXACT_EXPRS = ['if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'public float reloadCounter = Mathf.random(reload);', 'public float heat = 0f;', 'public float reload = 60f * 1.5f;', 'public float range = 110f;', 'public float checkInterval = 8f;', 'public float cooldownMultiplier = 1f;', 'public class ShockwaveTower extends Block{', 'public class ShockwaveTowerBuild extends Building{', 'return reloadCounter < reload;', 'public boolean shouldConsume(){', 'if(sensor == LAccess.progress) return reloadCounter / reload;', 'heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', 'return heat;', 'public void updateTile(){', 'heat = 1f;', 'reloadCounter = 0f;', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'public float bulletDamage = 160;', 'public float falloffCount = 20f;', 'public float shake = 2f;', 'public int timerCheck = timers ++;', 'update = true;', 'solid = true;', 'return efficiency * delta();', 'return potentialEfficiency > 0;', 'public boolean canConsume(){', 'potentialEfficiency = efficiency;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'consumePower(100f / 60f);', 'consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', 'range = 170f;', 'reload = 80f;', 'size = 3;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'targets.clear();', 'Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', 'if(b.team != team && b.type.hittable){', 'targets.add(b);', 'if(targets.size > 0){', 'waveEffect.at(x, y, range, waveColor);', 'shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', 'Effect.shake(shake, shake, this);', 'for(var target : targets){', 'if(target.damage > waveDamage){', 'target.damage -= waveDamage;', 'target.remove();', 'hitEffect.at(target.x, target.y, waveColor);', 'if(team == state.rules.defaultTeam){', 'Events.fire(Trigger.shockwaveTowerUse);', 'public Sound shootSound = Sounds.shockwaveTower;', 'public Effect waveEffect = Fx.pointShockwave;', 'public Effect hitEffect = Fx.hitSquaresColor;', 'public boolean timer(int index, float time){', 'return timer.get(index, time);', 'transient Interval timer = new Interval(6);', 'public Seq<Bullet> targets = new Seq<>();', 'public static final int tilesize = 8;', 'offset = ((size + 1) % 2) * tilesize / 2f;', 'return x * tilesize;', 'return block().offset + worldx();', 'public int timers = 0;', 'if(Float.isInfinite(time)) return false;', 'boolean got = check(id, time);', 'if(got) times[id] = Time.time;', 'return Time.time - times[id] >= time || Time.time < times[id];', 'times = new float[capacity];', 'Math.min(Core.graphics.getDeltaTime() * 60f, 3f)', 'timeRaw += delta;', 'time = (float)timeRaw;']

# DEFERRED is carried from the N2199 register script via import --
# never retyped. The N2199 script's DEFERRED is a computed
# expression (list(_N2198_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. NOTE for the next slice:
# N2200's DEFERRED is likewise a computed list(...) + [...]
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
# ShockwaveTower follow-ups from N2200's own standpoint instead
# of retyping the old list. The timer cadence itself is NOT
# carried as deferred: it is THIS slice (N2200) -- the inherited
# N2199 entry still names it as waiting, which is stale history,
# superseded by this slice.
DEFERRED = list(_N2199_DEFERRED) + [
    'ShockwaveTower timer cadence Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2199: the N2200 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ShockwaveTower fire follow-ups after the timer cadence (ShockwaveTower.java:110 sense(LAccess.progress); :117 warmup(); cyanogen liquid consumer Blocks.java:2041; draw :126-134; bullet hitSize -- the scan tests the bullet point against the intersect rect, not the bullet hitbox overlap Java intersect tests) -- N2200 lands ONLY the timer cadence (timer(timerCheck, checkInterval 8f) :73) from the frame gate inputs and the timer_elapsed clock; the sense, warmup, liquid, draw and hitSize wait for their own slices.',
]


def definitions():
    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2200_inputs = {
        'frame': f('Dictionary', 'if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'The building frame carrying the gate inputs the timer consults: `potential_efficiency` (the consumption machinery stamps it each tick, BuildingComp.java:1989, `potentialEfficiency = efficiency;`) and `reload_counter` (the N2192 charge stamps it, starting from deterministic 0.0) plus the elapsed clock `timer_elapsed` (seconds since the last due check; absent on a fresh frame -- a fresh Interval, whose slots start at 0 over `times = new float[capacity];`, Interval.java:7, while global Time.time is long past 8 at any real placement -- so a fresh frame is due on its first gated consult). A closed gate never consumes the due-ness: the elapsed clock keeps running, so the check stays due until the gate opens.'),
        'seconds': f('float', 'Math.min(Core.graphics.getDeltaTime() * 60f, 3f)', 'The tick delta on the port\'s seconds driver clock (the N2190 refresh / N2192 charge precedent: the tick\'s `seconds` is the delta). Java Time.delta is a tick clock (`Math.min(Core.graphics.getDeltaTime() * 60f, 3f)`, Time.java:26, with `timeRaw += delta;` / `time = (float)timeRaw;`, Time.java:70-75), so checkInterval 8f runs as 8.0 port-seconds, keeping the Java ratio of 10 checks per 80-reload charge; Java wall time is 8 ticks ~= 0.13s. The elapsed clock advances by this delta on a not-due check and restarts at 0.0 on a due check.', source=TIME),
    }
    n2200_outputs = {
        'check_due': f('bool', 'if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'Whether the timer check is due (ShockwaveTower.java:73, the third conjunct of the fire gate): true when the gate is open (potential_efficiency > 0 AND reload_counter >= 80.0, the per-def reload, Blocks.java:2044, `reload = 80f;`) AND the interval elapsed (timer_elapsed >= 8.0, the Interval.check `>=`, Interval.java:29, `return Time.time - times[id] >= time || Time.time < times[id];`) -- or the frame is fresh (no `timer_elapsed` key). The driver stamps this on the frame as `timer_check_due` and runs the N2195 scan ONLY when it is due; the N2194 fire fires only when it is true (absent means due, the backward-compatible default for N2194\'s direct calls).'),
        'timer_elapsed': f('float', 'if(got) times[id] = Time.time;', 'The elapsed clock in port-seconds since the last due check (the Interval slot, Interval.java:23-24, `boolean got = check(id, time);` / `if(got) times[id] = Time.time;` -- a due check restarts the clock at 0.0). The driver stamps this on the frame as `timer_elapsed`; on a not-due check the clock advances by the tick delta (the gate inputs stay open but the interval has not elapsed, or the gate is closed -- the elapsed clock keeps running while the gate is closed, so a check that was due while unpowered stays due when power returns). The backward-time clause (`Time.time < times[id]`, Interval.java:29) is not modeled: the port\'s relative clock never rewinds.', source=INTERVAL),
    }
    return n2200_inputs, n2200_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs, outputs = definitions()
    for keys in (inputs, outputs):
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    total = len(EXACT_EXPRS) + len(inputs) + len(outputs)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    n2200_inputs, n2200_outputs = definitions()

    symbols = {}

    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    entries = [
        ('N2200', OWNER, 'source_shockwave_tower_timer_state', SHOCKWAVE_TOWER, 'mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', 'ShockwaveTowerBuild.updateTile()', n2200_inputs, n2200_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShockwaveTower timer cadence from ShockwaveTower.java / TimerComp.java / Interval.java / Time.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShockwaveTower timer cadence from ShockwaveTower.java / TimerComp.java / Interval.java / Time.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the check-due flag, the
    # elapsed clock.
    by_slice['N2200'] = [
        'source_shockwave_tower_timer_state_result.check_due',
        'source_shockwave_tower_timer_state_result.timer_elapsed',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2200', dict(status='done', java_source=SHOCKWAVE_TOWER, java_class='mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', java_method='ShockwaveTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2200'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
