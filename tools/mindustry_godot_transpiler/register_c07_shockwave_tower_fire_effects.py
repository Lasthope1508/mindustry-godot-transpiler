"""Register the ShockwaveTower fire effects (N2197).

The ShockwaveTower's updateTile fire Fx / sound / shake,
following the N2177 pure-row pattern and the N2190/N2194/N2195
observed-key precedent. N2194's fire gate sets heat 1f and
resets the counter (ShockwaveTower.java:82-83), N2195's scan
stamps the observed `targets_count`, and N2196's wave damage
applies the wave -- but the fire's Fx / sound / shake
(ShockwaveTower.java:84-86, `waveEffect.at(x, y, range,
waveColor);` / `shootSound.at(x, y, 1f + Mathf.range(0.15f),
1f);` / `Effect.shake(shake, shake, this);`) have NO pure
function in the port -- a firing tower resets its counter,
heats up and damages bullets while no wave effect, no sound
and no shake is ever recorded. N2197 owns the fire effects.
The pure function (source_shockwave_tower_fire_effects_state)
needs only the tower's world position (`x`/`y` frame keys,
derived by the driver from the placement cell: Tile.java
`return x * tilesize;` / `return block().offset + worldx();`,
tilesize 8, offset 0 for size 3) and returns one descriptor per
Java call: the wave effect (Fx.pointShockwave,
ShockwaveTower.java:35, at the tower, rotation = range 170f
per-def, Blocks.java:2043, color waveColor Pal.accent,
ShockwaveTower.java:29 -- Fx.pointShockwave draws
`Lines.circle(e.x, e.y, e.finpow() * e.rotation)`,
Fx.java:223-228, so the `range` argument is the effect
rotation and the final circle radius is range), the shoot
sound (Sounds.shockwaveTower, ShockwaveTower.java:30, at the
tower, pitch 1f + Mathf.range(0.15f) -- a DETERMINISTIC pitch
range [0.85, 1.15], never a sampled pitch, since the pure
function takes no RNG -- volume 1f), and the shake
(Effect.shake(float intensity, float duration, Position loc),
Effect.java:210-211, called with (shake, shake, this):
intensity 2f, duration 2f, ShockwaveTower.java:27, at the
tower). Absent `x`/`y` means "no effects": wave_effect /
shoot_sound / shake null, has_fire_effects false, and the
driver stamps nothing (the N2190 / N2195 / N2196 precedent) --
never a fabricated descriptor. The driver calls the effects
AFTER the N2194 fire and ONLY when the fire fired, and BEFORE
the N2196 wave damage (the Java order :84-86 before :87): the
effects live inside the fire gate in Java (:81-96), so a
charged-but-unfired tick spawns nothing, and the fire gate
already established targets.size > 0, so no separate targets
check is needed. No hitEffect spawning, no shockwaveTowerUse
event, no sense, no warmup, no draw: those wait for their own
slices. The driver change is one gated call + comment in the
existing source_shockwave_tower_tick_buildings_state, AFTER the
N2194 fire call and BEFORE the N2196 wave damage call,
stamping `frame["wave_effect"]`, `frame["shoot_sound"]` and
`frame["shake"]` only when the effects report one. No new frame
meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change. Shard note: like
N2192/N2193/N2194/N2195/N2196, ShockwaveTower.java IS selected
by the defense_slices shard (java_source contains
/world/blocks/defense/) and its owner by
defense_api_contracts, so the GREEN register run is expected
to mirror N2197 into both defense shards (the N2177 / N2192 /
N2193 / N2194 / N2195 / N2196 precedent).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false, the N2192 charge
already advances the counter by edelta(), the N2194 fire
already reads the observed `targets_count` and resets the
counter, the N2195 scan already filters the observed bullets,
and N2196 already applies the wave damage. N2197 does not
touch any of them. N2197 supplies the missing pure fire
effects + the one gated driver call; no new consumer rows. The
shockwave tower's power draw stays STATIC (consumePower
100f/60f, Blocks.java:2042 -- a plain ConsumePower, not the
RepairTurret-style conditional draw), so the folded efficiency
is the min over the *modeled* consumers (power only); the
cyanogen liquid consumer (consumeLiquids cyanogen 1.5f/60f,
Blocks.java:2041) is the second pass and waits for its own
slice. Single def (shockwave-tower, size 3, range 170f,
reload 80f, Blocks.java:2038-2044).
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_shockwave_tower_wave_damage import DEFERRED as _N2196_DEFERRED

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
PROOF = '/root/C07ShockwaveTowerFireEffectsProof'
OWNER = 'SourceShockwaveTowerBuildState.source_shockwave_tower_fire_effects_state'
TESTS = ['test_c07_shockwave_tower_fire_effects_registration', 'test_all_c07_shockwave_tower_fire_effects_input_evidence_is_exact', 'test_shockwave_tower_fire_effects_state', 'test_reference_graph_and_actual_c07_shockwave_tower_fire_effects']
EXACT_EXPRS = ['if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'public float reloadCounter = Mathf.random(reload);', 'public float heat = 0f;', 'public float reload = 60f * 1.5f;', 'public float range = 110f;', 'public float checkInterval = 8f;', 'public float cooldownMultiplier = 1f;', 'public class ShockwaveTower extends Block{', 'public class ShockwaveTowerBuild extends Building{', 'return reloadCounter < reload;', 'public boolean shouldConsume(){', 'if(sensor == LAccess.progress) return reloadCounter / reload;', 'heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', 'return heat;', 'public void updateTile(){', 'heat = 1f;', 'reloadCounter = 0f;', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'public float bulletDamage = 160;', 'public float falloffCount = 20f;', 'public float shake = 2f;', 'public int timerCheck = timers ++;', 'update = true;', 'solid = true;', 'return efficiency * delta();', 'return potentialEfficiency > 0;', 'public boolean canConsume(){', 'potentialEfficiency = efficiency;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'consumePower(100f / 60f);', 'consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', 'range = 170f;', 'reload = 80f;', 'size = 3;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'targets.clear();', 'Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', 'if(b.team != team && b.type.hittable){', 'targets.add(b);', 'if(targets.size > 0){', 'waveEffect.at(x, y, range, waveColor);', 'shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', 'Effect.shake(shake, shake, this);', 'for(var target : targets){', 'if(target.damage > waveDamage){', 'target.damage -= waveDamage;', 'target.remove();', 'hitEffect.at(target.x, target.y, waveColor);', 'if(team == state.rules.defaultTeam){', 'Events.fire(Trigger.shockwaveTowerUse);', 'public Sound shootSound = Sounds.shockwaveTower;', 'public Effect waveEffect = Fx.pointShockwave;', 'public Effect hitEffect = Fx.hitSquaresColor;', 'public boolean timer(int index, float time){', 'return timer.get(index, time);', 'transient Interval timer = new Interval(6);', 'public Seq<Bullet> targets = new Seq<>();', 'public static final int tilesize = 8;', 'offset = ((size + 1) % 2) * tilesize / 2f;', 'return x * tilesize;', 'return block().offset + worldx();']

# DEFERRED is carried from the N2196 register script via import --
# never retyped. The N2196 script's DEFERRED is a computed
# expression (list(_N2195_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. NOTE for the next slice:
# N2197's DEFERRED is likewise a computed list(...) + [...]
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
# ShockwaveTower follow-ups from N2197's own standpoint instead
# of retyping the old list. The fire effects themselves are NOT
# carried as deferred: they are THIS slice (N2197) -- the
# inherited N2196 entry still names them as waiting, which is
# stale history, superseded by this slice.
DEFERRED = list(_N2196_DEFERRED) + [
    'ShockwaveTower fire effects Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2196: the N2197 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ShockwaveTower fire follow-ups after the fire effects (ShockwaveTower.java:95 hitEffect placement -- the N2196 outcomes carry hit_x/hit_y but no effect is spawned; :97-99 shockwaveTowerUse event; :73 timer cadence timer(timerCheck, checkInterval 8f) -- the port tracks no per-building Interval timer state, so the port fires on the first ready tick where Java waits for a timer tick, and the scan runs every tick where Java scans only on a timer tick; :110 sense(LAccess.progress); :117 warmup(); cyanogen liquid consumer Blocks.java:2041; draw :126-134; bullet hitSize -- the scan tests the bullet point against the intersect rect, not the bullet hitbox overlap Java intersect tests) -- N2197 lands ONLY the fire effects (waveEffect / shootSound / shake :84-86) from the tower position; the hitEffect, event, timer cadence, sense, warmup, liquid, draw and hitSize wait for their own slices.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2197_inputs = {
        'frame': f('Dictionary', 'if(targets.size > 0){', 'The building frame carrying the tower world position (x/y frame keys, derived by the driver from the placement cell: Tile.java `return x * tilesize;` / `return block().offset + worldx();`, tilesize 8, offset 0 for size 3). The fire gate (N2194) already established targets.size > 0, so the effects need no observed bullet list and no separate targets check -- the driver calls them only when the fire fired.', source=BUILDING_COMP),
    }
    n2197_outputs = {
        'wave_effect': f('Dictionary', 'waveEffect.at(x, y, range, waveColor);', 'The wave-effect descriptor for this fire (ShockwaveTower.java:84): {"effect": "pointShockwave" (Fx.pointShockwave, ShockwaveTower.java:35), "x": the tower world x, "y": the tower world y, "rotation": range 170f per-def (Blocks.java:2043 -- the range argument is the effect rotation, Fx.pointShockwave draws Lines.circle(e.x, e.y, e.finpow() * e.rotation), Fx.java:223-228), "color": "Pal.accent" (waveColor, ShockwaveTower.java:29)}; null when no effects ran (absent position), so the driver stamps nothing.'),
        'shoot_sound': f('Dictionary', 'shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', 'The shoot-sound descriptor for this fire (ShockwaveTower.java:85): {"sound": "shockwaveTower" (Sounds.shockwaveTower, ShockwaveTower.java:30), "x": the tower world x, "y": the tower world y, "pitch_min": 0.85, "pitch_max": 1.15 (the DETERMINISTIC range of 1f + Mathf.range(0.15f) -- never a sampled pitch, the pure function takes no RNG), "volume": 1.0}; null when no effects ran, so the driver stamps nothing.'),
        'shake': f('Dictionary', 'Effect.shake(shake, shake, this);', 'The shake descriptor for this fire (ShockwaveTower.java:86): {"intensity": 2.0, "duration": 2.0 (Effect.shake(float intensity, float duration, Position loc), Effect.java:210-211, called with (shake, shake, this), shake 2f, ShockwaveTower.java:27), "x": the tower world x, "y": the tower world y}; null when no effects ran, so the driver stamps nothing.'),
        'has_fire_effects': f('bool', 'if(targets.size > 0){', 'Whether the fire effects ran (ShockwaveTower.java:81): true when the tower world position is present, false otherwise -- the driver stamps frame["wave_effect"] / frame["shoot_sound"] / frame["shake"] only when this is true, and only on a tick where the N2194 fire fired, before the N2196 wave damage.'),
    }

    entries = [
        ('N2197', OWNER, 'source_shockwave_tower_fire_effects_state', SHOCKWAVE_TOWER, 'mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', 'ShockwaveTowerBuild.updateTile()', n2197_inputs, n2197_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShockwaveTower fire effects from ShockwaveTower.java / BuildingComp.java / Tile.java / Vars.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShockwaveTower fire effects from ShockwaveTower.java / BuildingComp.java / Tile.java / Vars.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the wave-effect descriptor, the
    # shoot-sound descriptor, the shake descriptor, the effects
    # flag.
    by_slice['N2197'] = [
        'source_shockwave_tower_fire_effects_state_result.wave_effect',
        'source_shockwave_tower_fire_effects_state_result.shoot_sound',
        'source_shockwave_tower_fire_effects_state_result.shake',
        'source_shockwave_tower_fire_effects_state_result.has_fire_effects',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2197', dict(status='done', java_source=SHOCKWAVE_TOWER, java_class='mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', java_method='ShockwaveTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2197'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
