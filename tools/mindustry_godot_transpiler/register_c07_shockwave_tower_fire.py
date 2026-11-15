"""Register the ShockwaveTower fire gate (N2194).

The ShockwaveTower's updateTile fire branch, following the N2177
pure-row pattern and the N2192/N2193 charge/gate precedent. N2192
stamped the reload counter: the charge advance is the ONLY writer
of `reload_counter` (ShockwaveTower.java:73,
`if(potentialEfficiency > 0 && (reloadCounter += edelta()) >=
reload && timer(timerCheck, checkInterval)){`), and the driver
stamps it every tick after apply_update_consumption_state; N2193
wired the shouldConsume gate over it (`return reloadCounter <
reload;`, ShockwaveTower.java:122). N2194 closes the fire branch
itself (ShockwaveTower.java:73-104) with one pure function
(source_shockwave_tower_fire_state) over the observed frame keys:
it reads the counter the charge stamped -- it does NOT re-advance
it, the charge already advanced it this tick -- and, on fire,
returns the reset counter 0.0 and heat 1.0
(ShockwaveTower.java:82-83, `heat = 1f;` / `reloadCounter =
0f;`); every tick it also returns the heat decay
(ShockwaveTower.java:104, `heat = Mathf.clamp(heat - Time.delta /
reload * cooldownMultiplier);`, reload 80f per-def,
Blocks.java:2044, cooldownMultiplier 1f,
ShockwaveTower.java:34). The fire condition is the :73 gate over
the observed frame keys: `potential_efficiency > 0` AND
`reload_counter >= 80.0` AND an observed `targets_count > 0`.
The live bullet scan (Groups.bullet.intersect,
ShockwaveTower.java:75-79) has NO frame input in the port -- no
live bullet query exists -- so the fire reads an observed
`targets_count` frame key (the N2190 RepairTower precedent:
stamped only when observed) and absent means no fire, never
invented targets. The timer cadence (`timer(timerCheck,
checkInterval)`, checkInterval 8f, ShockwaveTower.java:31) is
DEFERRED: the port tracks no per-building Interval timer state
(TimerComp.java:10-13, `public boolean timer(int index, float
time){` / `return timer.get(index, time);` over `transient
Interval timer = new Interval(6);`), so the port fires on the
first tick the counter is at reload with targets observed, where
Java fires only on a timer tick -- up to checkInterval earlier, a
documented fidelity gap owned by a later per-building-timer
slice. Absent `reload_counter` starts from deterministic 0.0
(the N2192 precedent -- Java inits `reloadCounter =
Mathf.random(reload);`, ShockwaveTower.java:67, but the port
never uses `randf` in game code); absent
`potential_efficiency` is 0.0, so no fire; absent `heat` is 0.0
(Java init `heat = 0f;`, ShockwaveTower.java:68). On a fire tick
Java sets heat 1f (:82) and then decays it the same tick (:104),
so the pure function applies the decay AFTER the fire set, in
the same order. No wave damage application, no Fx / sound /
shake, no shockwaveTowerUse event, no sense, no warmup, no draw:
those wait for their own slices. The driver change is one call +
comment in the existing
source_shockwave_tower_tick_buildings_state, AFTER the N2192
charge call (the Java order: updateConsumption runs BEFORE
updateTile, so the fire reads THIS tick's freshly stamped
potential_efficiency / efficiency and the counter the charge
just advanced), passing the tick's `seconds` as the delta (the
N2190 driver convention) and stamping `frame["reload_counter"]`
and `frame["heat"]` from the result. No new frame meta key, no
SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory
wiring change. Shard note: like N2192/N2193,
ShockwaveTower.java IS selected by the defense_slices shard
(java_source contains /world/blocks/defense/) and its owner by
defense_api_contracts, so the GREEN register run is expected to
mirror N2194 into both defense shards (the N2177 / N2192 / N2193
precedent).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false, and the N2192 charge
already advances the counter by edelta(). N2194 does not touch
either. N2194 supplies the missing pure fire gate + the
one-line driver change; no new consumer rows. The shockwave
tower's power draw stays STATIC (consumePower 100f/60f,
Blocks.java:2042 -- a plain ConsumePower, not the
RepairTurret-style conditional draw), so the folded efficiency
is the min over the *modeled* consumers (power only); the
cyanogen liquid consumer (consumeLiquids cyanogen 1.5f/60f,
Blocks.java:2041) is the second pass and waits for its own
slice. Single def (shockwave-tower, size 3, range 170f, reload
80f, Blocks.java:2038-2044).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_shockwave_tower_should_consume import DEFERRED as _N2193_DEFERRED

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SHOCKWAVE_TOWER = 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
TIMER_COMP = 'core/src/mindustry/entities/comp/TimerComp.java'
PROOF = '/root/C07ShockwaveTowerFireProof'
OWNER = 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_state'
TESTS = ['test_c07_shockwave_tower_fire_registration', 'test_all_c07_shockwave_tower_fire_input_evidence_is_exact', 'test_shockwave_tower_fire_state', 'test_reference_graph_and_actual_c07_shockwave_tower_fire']
EXACT_EXPRS = ['if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'public float reloadCounter = Mathf.random(reload);', 'public float heat = 0f;', 'public float reload = 60f * 1.5f;', 'public float range = 110f;', 'public float checkInterval = 8f;', 'public float cooldownMultiplier = 1f;', 'public class ShockwaveTower extends Block{', 'public class ShockwaveTowerBuild extends Building{', 'return reloadCounter < reload;', 'public boolean shouldConsume(){', 'if(sensor == LAccess.progress) return reloadCounter / reload;', 'heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', 'return heat;', 'public void updateTile(){', 'heat = 1f;', 'reloadCounter = 0f;', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'public float bulletDamage = 160;', 'public float falloffCount = 20f;', 'public float shake = 2f;', 'public int timerCheck = timers ++;', 'update = true;', 'solid = true;', 'return efficiency * delta();', 'return potentialEfficiency > 0;', 'public boolean canConsume(){', 'potentialEfficiency = efficiency;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'consumePower(100f / 60f);', 'consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', 'range = 170f;', 'reload = 80f;', 'size = 3;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'targets.clear();', 'Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', 'if(b.team != team && b.type.hittable){', 'targets.add(b);', 'if(targets.size > 0){', 'waveEffect.at(x, y, range, waveColor);', 'shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', 'Effect.shake(shake, shake, this);', 'for(var target : targets){', 'if(target.damage > waveDamage){', 'target.damage -= waveDamage;', 'target.remove();', 'hitEffect.at(target.x, target.y, waveColor);', 'if(team == state.rules.defaultTeam){', 'Events.fire(Trigger.shockwaveTowerUse);', 'public Sound shootSound = Sounds.shockwaveTower;', 'public Effect waveEffect = Fx.pointShockwave;', 'public Effect hitEffect = Fx.hitSquaresColor;', 'public boolean timer(int index, float time){', 'return timer.get(index, time);', 'transient Interval timer = new Interval(6);']

# DEFERRED is carried from the N2193 register script via import --
# never retyped. The N2193 script's DEFERRED is a computed
# expression (list(_N2192_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. NOTE for the next slice:
# N2194's DEFERRED is likewise a computed list(...) + [...]
# expression, so carry it forward by import too, not by
# ast.literal_eval. Chain gap, recorded 2026-11-15 at N2192 RED
# and still true: the inherited 160-entry list contains NO
# ShockwaveTower entries -- N2177's register script added them
# as a literal, but the chain forked between N2185 and N2190 and
# the later slices carried the pre-N2177 list forward, so the
# N2177 ShockwaveTower deferred items (fire gate / shouldConsume
# gate / liquid / sense-warmup / draw / shape-timer / trigger /
# per-def) live only in the N2177 ledger row, not in this carried
# list. The new entries below re-pin the still-deferred
# ShockwaveTower follow-ups from N2194's own standpoint instead
# of retyping the old list. The fire gate itself is NOT carried
# as deferred: it is THIS slice (N2194) -- the inherited N2193
# entry still names it as waiting, which is stale history,
# superseded by this slice.
DEFERRED = list(_N2193_DEFERRED) + [
    'ShockwaveTower fire Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2193: the N2194 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ShockwaveTower fire follow-ups after the fire gate (ShockwaveTower.java:75-79 live bullet scan via Groups.bullet.intersect -- the port has no live bullet query, targets_count is observed-only; :87-96 wave damage application; :84-86, :95 waveEffect / shootSound / shake / hitEffect; :97-99 shockwaveTowerUse event; :73 timer cadence timer(timerCheck, checkInterval 8f) -- the port tracks no per-building Interval timer state, so the port fires on the first ready tick where Java waits for a timer tick; :110 sense(LAccess.progress); :117 warmup(); cyanogen liquid consumer Blocks.java:2041; draw :126-134) -- N2194 lands ONLY the fire condition over the observed frame keys plus the heat decay; the scan, damage, Fx/sound/shake, event, timer cadence, sense, warmup, liquid and draw wait for their own slices.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2194_inputs = {
        'frame': f('Dictionary', 'if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'The building frame carrying the reload_counter observation (ShockwaveTower.java:67, `public float reloadCounter = Mathf.random(reload);`, stamped by the N2192 charge every tick after apply_update_consumption_state) plus potential_efficiency (stamped by apply_update_consumption_state, BuildingComp.java:1989), heat, and the observed targets_count (stamped only when observed -- absent means no fire, never invented targets). The per-def reload is 80f (Blocks.java:2044), overriding the class default `60f * 1.5f` (ShockwaveTower.java:26).', source=BUILDING_COMP),
    }
    n2194_outputs = {
        'fired': f('bool', 'if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'The fire flag (ShockwaveTower.java:73-83): true when potential_efficiency > 0 and the charge-stamped reload_counter >= 80.0 and an observed targets_count > 0; the timer cadence (timerCheck, checkInterval 8f) is deferred -- the port tracks no per-building Interval timer state (TimerComp.java:10-13).'),
        'reload_counter': f('float', 'reloadCounter = 0f;', 'The reload counter after the fire evaluation (ShockwaveTower.java:83): 0.0 on fire, the charge-stamped counter unchanged otherwise -- Java resets only on a successful fire, never on a failed gate.'),
        'heat': f('float', 'heat = 1f;', 'The heat after the fire evaluation (ShockwaveTower.java:82, `heat = 1f;` on fire, and :104, `heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);` every tick against the per-def reload 80f and cooldownMultiplier 1f); on a fire tick the decay applies after the set, in the Java order.'),
    }

    entries = [
        ('N2194', OWNER, 'source_shockwave_tower_fire_state', SHOCKWAVE_TOWER, 'mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', 'ShockwaveTowerBuild.updateTile()', n2194_inputs, n2194_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShockwaveTower fire gate from ShockwaveTower.java / BuildingComp.java / TimerComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShockwaveTower fire gate from ShockwaveTower.java / BuildingComp.java / TimerComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the fire flag, the reset counter, the heat.
    by_slice['N2194'] = [
        'source_shockwave_tower_fire_state_result.fired',
        'source_shockwave_tower_fire_state_result.reload_counter',
        'source_shockwave_tower_fire_state_result.heat',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2194', dict(status='done', java_source=SHOCKWAVE_TOWER, java_class='mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', java_method='ShockwaveTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2194'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
