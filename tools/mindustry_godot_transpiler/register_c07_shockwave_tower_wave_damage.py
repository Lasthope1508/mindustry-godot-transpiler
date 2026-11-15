"""Register the ShockwaveTower wave damage application (N2196).

The ShockwaveTower's updateTile wave damage, following the N2177
pure-row pattern and the N2190/N2194/N2195 observed-key
precedent. N2194's fire gate sets heat 1f and resets the counter
(ShockwaveTower.java:82-83) and N2195's scan stamps the observed
`targets_count` -- but the wave itself does nothing yet: the wave
damage line (ShockwaveTower.java:87, `float waveDamage =
Math.min(bulletDamage, bulletDamage * falloffCount /
targets.size);`) and the per-target damage / removal (:89-95,
`for(var target : targets){` / `if(target.damage > waveDamage){`
/ `target.damage -= waveDamage;` / `target.remove();` /
`hitEffect.at(target.x, target.y, waveColor);`) have NO pure
function in the port -- a firing tower resets its counter and
heats up while every bullet in range flies on undamaged. N2196
owns applying the wave damage. The pure function
(source_shockwave_tower_wave_damage_state) reuses the N2195
scan filter over the same observed bullet list
(`observed_bullets`: an array of dicts with
team/hittable/x/y/damage, world coords -- the port has no live
bullet query, so the list is an explicit observed frame key,
the N2190 precedent) plus the tower's world position (`x`/`y`
frame keys, derived by the driver from the placement cell:
Tile.java, `return x * tilesize;` / `return block().offset +
worldx();`, tilesize 8, offset 0 for size 3) and its team
(`team_id`, stamped by the tick wiring), and returns the wave
damage (bulletDamage 160, falloffCount 20f, per-def range 170f)
plus one outcome per target bullet: the remaining damage (or
null when removed), the removed flag, and the hit-effect
position (target.x / target.y -- the hitEffect fires for EVERY
target, removed or not, ShockwaveTower.java:95). Absent
`observed_bullets` (or absent `x`/`y`/`team_id`) or zero
targets in range means "no wave": wave_damage null, an empty
outcome list, has_wave_damage false, and the driver stamps
nothing (the N2190 / N2195 precedent) -- never a fabricated 0.
The driver calls the wave damage AFTER the N2194 fire and ONLY
when the fire fired: the wave damage lives inside the fire gate
in Java (:81-96), so a charged-but-unfired tick damages
nothing. No waveEffect / shootSound / shake, no
shockwaveTowerUse event, no sense, no warmup, no draw: those
wait for their own slices. The driver change is one gated call
+ comment in the existing
source_shockwave_tower_tick_buildings_state, AFTER the N2194
fire call, stamping `frame["wave_damage"]` and
`frame["bullet_outcomes"]` only when the wave reports one. No
new frame meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change,
no simulate_factory wiring change. Shard note: like
N2192/N2193/N2194/N2195, ShockwaveTower.java IS selected by the
defense_slices shard (java_source contains
/world/blocks/defense/) and its owner by
defense_api_contracts, so the GREEN register run is expected
to mirror N2196 into both defense shards (the N2177 / N2192 /
N2193 / N2194 / N2195 precedent).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false, the N2192 charge
already advances the counter by edelta(), the N2194 fire
already reads the observed `targets_count` and resets the
counter, and the N2195 scan already filters the observed
bullets. N2196 does not touch any of them. N2196 supplies the
missing pure wave damage + the one gated driver call; no new
consumer rows. The shockwave tower's power draw stays STATIC
(consumePower 100f/60f, Blocks.java:2042 -- a plain
ConsumePower, not the RepairTurret-style conditional draw), so
the folded efficiency is the min over the *modeled* consumers
(power only); the cyanogen liquid consumer (consumeLiquids
cyanogen 1.5f/60f, Blocks.java:2041) is the second pass and
waits for its own slice. Single def (shockwave-tower, size 3,
range 170f, reload 80f, Blocks.java:2038-2044).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_shockwave_tower_bullet_scan import DEFERRED as _N2195_DEFERRED

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
PROOF = '/root/C07ShockwaveTowerWaveDamageProof'
OWNER = 'SourceShockwaveTowerBuildState.source_shockwave_tower_wave_damage_state'
TESTS = ['test_c07_shockwave_tower_wave_damage_registration', 'test_all_c07_shockwave_tower_wave_damage_input_evidence_is_exact', 'test_shockwave_tower_wave_damage_state', 'test_reference_graph_and_actual_c07_shockwave_tower_wave_damage']
EXACT_EXPRS = ['if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'public float reloadCounter = Mathf.random(reload);', 'public float heat = 0f;', 'public float reload = 60f * 1.5f;', 'public float range = 110f;', 'public float checkInterval = 8f;', 'public float cooldownMultiplier = 1f;', 'public class ShockwaveTower extends Block{', 'public class ShockwaveTowerBuild extends Building{', 'return reloadCounter < reload;', 'public boolean shouldConsume(){', 'if(sensor == LAccess.progress) return reloadCounter / reload;', 'heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', 'return heat;', 'public void updateTile(){', 'heat = 1f;', 'reloadCounter = 0f;', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'public float bulletDamage = 160;', 'public float falloffCount = 20f;', 'public float shake = 2f;', 'public int timerCheck = timers ++;', 'update = true;', 'solid = true;', 'return efficiency * delta();', 'return potentialEfficiency > 0;', 'public boolean canConsume(){', 'potentialEfficiency = efficiency;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'consumePower(100f / 60f);', 'consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', 'range = 170f;', 'reload = 80f;', 'size = 3;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'targets.clear();', 'Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', 'if(b.team != team && b.type.hittable){', 'targets.add(b);', 'if(targets.size > 0){', 'waveEffect.at(x, y, range, waveColor);', 'shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', 'Effect.shake(shake, shake, this);', 'for(var target : targets){', 'if(target.damage > waveDamage){', 'target.damage -= waveDamage;', 'target.remove();', 'hitEffect.at(target.x, target.y, waveColor);', 'if(team == state.rules.defaultTeam){', 'Events.fire(Trigger.shockwaveTowerUse);', 'public Sound shootSound = Sounds.shockwaveTower;', 'public Effect waveEffect = Fx.pointShockwave;', 'public Effect hitEffect = Fx.hitSquaresColor;', 'public boolean timer(int index, float time){', 'return timer.get(index, time);', 'transient Interval timer = new Interval(6);', 'public Seq<Bullet> targets = new Seq<>();', 'public static final int tilesize = 8;', 'offset = ((size + 1) % 2) * tilesize / 2f;', 'return x * tilesize;', 'return block().offset + worldx();']

# DEFERRED is carried from the N2195 register script via import --
# never retyped. The N2195 script's DEFERRED is a computed
# expression (list(_N2194_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. NOTE for the next slice:
# N2196's DEFERRED is likewise a computed list(...) + [...]
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
# ShockwaveTower follow-ups from N2196's own standpoint instead
# of retyping the old list. The wave damage itself is NOT carried
# as deferred: it is THIS slice (N2196) -- the inherited N2195
# entry still names it as waiting, which is stale history,
# superseded by this slice.
DEFERRED = list(_N2195_DEFERRED) + [
    'ShockwaveTower wave damage Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2195: the N2196 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ShockwaveTower fire follow-ups after the wave damage (ShockwaveTower.java:84-86 waveEffect / shootSound / shake; :95 hitEffect placement -- the outcomes carry hit_x/hit_y but no effect is spawned; :97-99 shockwaveTowerUse event; :73 timer cadence timer(timerCheck, checkInterval 8f) -- the port tracks no per-building Interval timer state, so the port fires on the first ready tick where Java waits for a timer tick, and the scan runs every tick where Java scans only on a timer tick; :110 sense(LAccess.progress); :117 warmup(); cyanogen liquid consumer Blocks.java:2041; draw :126-134; bullet hitSize -- the scan tests the bullet point against the intersect rect, not the bullet hitbox overlap Java intersect tests) -- N2196 lands ONLY the wave damage application from the observed bullet list; the Fx/sound/shake, event, timer cadence, sense, warmup, liquid, draw and hitSize wait for their own slices.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2196_inputs = {
        'frame': f('Dictionary', 'for(var target : targets){', 'The building frame carrying the observed_bullets list (an array of dicts with team/hittable/x/y/damage, world coords -- the port has no live bullet query, so the list is an explicit observed frame key, the N2190 precedent) plus the tower world position (x/y frame keys, derived by the driver from the placement cell: Tile.java `return x * tilesize;` / `return block().offset + worldx();`, tilesize 8, offset 0 for size 3) and the tower team (team_id, stamped by the tick wiring). The per-def range is 170f (Blocks.java:2043), overriding the class default `110f` (ShockwaveTower.java:25).', source=BUILDING_COMP),
    }
    n2196_outputs = {
        'wave_damage': f('float', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'The wave damage for this fire (ShockwaveTower.java:87): min(bulletDamage 160, bulletDamage * falloffCount 20 / targets.size) -- capped at 160 for few targets, falling off as 3200 / N for many; null when no wave ran (absent observation, or zero targets in range), so the driver stamps nothing.'),
        'bullet_outcomes': f('Array', 'for(var target : targets){', 'One outcome per target bullet, in scan order (ShockwaveTower.java:89-95): {"damage": the remaining damage after subtracting waveDamage, or null when the bullet was removed, "removed": whether the bullet was removed (damage <= waveDamage -- the STRICT comparison, so a bullet at exactly waveDamage is removed, not left at 0), "hit_x": the bullet x (the hitEffect position, hitEffect.at(target.x, target.y, waveColor)), "hit_y": the bullet y}. Empty when no wave ran.'),
        'has_wave_damage': f('bool', 'if(targets.size > 0){', 'Whether the wave ran (ShockwaveTower.java:81): true when the observation exists and at least one enemy hittable bullet lies inside the range box, false otherwise -- the driver stamps frame["wave_damage"] / frame["bullet_outcomes"] only when this is true, and only on a tick where the N2194 fire fired.'),
    }

    entries = [
        ('N2196', OWNER, 'source_shockwave_tower_wave_damage_state', SHOCKWAVE_TOWER, 'mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', 'ShockwaveTowerBuild.updateTile()', n2196_inputs, n2196_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShockwaveTower wave damage from ShockwaveTower.java / BuildingComp.java / Tile.java / Vars.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShockwaveTower wave damage from ShockwaveTower.java / BuildingComp.java / Tile.java / Vars.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the wave damage, the per-bullet
    # outcomes, the wave flag.
    by_slice['N2196'] = [
        'source_shockwave_tower_wave_damage_state_result.wave_damage',
        'source_shockwave_tower_wave_damage_state_result.bullet_outcomes',
        'source_shockwave_tower_wave_damage_state_result.has_wave_damage',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2196', dict(status='done', java_source=SHOCKWAVE_TOWER, java_class='mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', java_method='ShockwaveTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2196'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
