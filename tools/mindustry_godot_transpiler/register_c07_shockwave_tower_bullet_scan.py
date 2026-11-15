"""Register the ShockwaveTower live bullet scan (N2195).

The ShockwaveTower's updateTile bullet scan, following the N2177
pure-row pattern and the N2190/N2194 observed-key precedent.
N2194's fire gate reads an observed `targets_count` frame key
(ShockwaveTower.java:81, `if(targets.size > 0){`) and absent
means no fire, never invented targets -- but nothing stamps
`targets_count` yet: the live bullet scan
(ShockwaveTower.java:74-79, `targets.clear();` /
`Groups.bullet.intersect(x - range, y - range, range * 2, range
* 2, b -> {` / `if(b.team != team && b.type.hittable){` /
`targets.add(b);`) has NO frame input in the port -- no live
bullet query exists (no Groups.bullet equivalent) -- so N2195
owns stamping it live. The pure function
(source_shockwave_tower_bullet_scan_state) takes the observed
bullet list as an explicit frame key (`observed_bullets`: an
array of dicts with team/hittable/x/y, world coords) plus the
tower's world position (`x`/`y` frame keys, which the driver
derives from the placement cell: Tile.java, `return x *
tilesize;` / `return block().offset + worldx();`, tilesize 8,
Vars.java:135, `public static final int tilesize = 8;`, offset 0
for size 3, Block.java:761, `offset = ((size + 1) % 2) *
tilesize / 2f;`) and its team (`team_id`, already stamped by
the tick wiring), and returns the count of enemy hittable
bullets inside the range box (x +/- range, y +/- range, range
170f per-def, Blocks.java:2043, overriding the class default
110f, ShockwaveTower.java:25). The range box is a point-in-box
test against the Java intersect rect -- the port models no
bullet hitSize, so the rect overlap is approximated by the
bullet point, a documented limit owned by a later
bullet-hitSize slice. Absent `observed_bullets` (or absent
`x`/`y`/`team_id`) means "no observation yet" and stamps
nothing (the N2190 RepairTower precedent: `targets_count` is
NOT stamped, so N2194 keeps reading absent as no fire); a
present-but-empty list IS an observation and stamps 0. The
scan runs every tick in the driver (after the N2192 charge,
before the N2194 fire) -- Java scans only when the fire gate
(:73) is true, but the port's timer cadence is already
deferred (N2194: the port fires on the first tick at reload),
so a fresh scan every tick is observably equivalent for the
fire decision, and the timer-gated scan cadence waits for the
per-building-timer slice with the timer itself. No wave damage
application, no Fx / sound / shake, no shockwaveTowerUse
event, no sense, no warmup, no draw: those wait for their own
slices. The driver change is one call + comment in the
existing source_shockwave_tower_tick_buildings_state, AFTER
the N2192 charge call and BEFORE the N2194 fire call (the Java
order: the scan :74-79 runs inside the fire gate before the
targets.size check :81), stamping `frame["x"]` /
`frame["y"]` from the placement cell and `frame["targets_count"]`
only when the scan reports an observation. No new frame meta
key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no
simulate_factory wiring change. Shard note: like
N2192/N2193/N2194, ShockwaveTower.java IS selected by the
defense_slices shard (java_source contains
/world/blocks/defense/) and its owner by
defense_api_contracts, so the GREEN register run is expected
to mirror N2195 into both defense shards (the N2177 / N2192 /
N2193 / N2194 precedent).

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already zeroes
efficiency when should_consume is false, the N2192 charge
already advances the counter by edelta(), and the N2194 fire
already reads the observed `targets_count`. N2195 does not
touch any of them. N2195 supplies the missing pure bullet scan
+ the one-line driver change; no new consumer rows. The
shockwave tower's power draw stays STATIC (consumePower
100f/60f, Blocks.java:2042 -- a plain ConsumePower, not the
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
from register_c07_shockwave_tower_fire import DEFERRED as _N2194_DEFERRED

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
PROOF = '/root/C07ShockwaveTowerBulletScanProof'
OWNER = 'SourceShockwaveTowerBuildState.source_shockwave_tower_bullet_scan_state'
TESTS = ['test_c07_shockwave_tower_bullet_scan_registration', 'test_all_c07_shockwave_tower_bullet_scan_input_evidence_is_exact', 'test_shockwave_tower_bullet_scan_state', 'test_reference_graph_and_actual_c07_shockwave_tower_bullet_scan']
EXACT_EXPRS = ['if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){', 'public float reloadCounter = Mathf.random(reload);', 'public float heat = 0f;', 'public float reload = 60f * 1.5f;', 'public float range = 110f;', 'public float checkInterval = 8f;', 'public float cooldownMultiplier = 1f;', 'public class ShockwaveTower extends Block{', 'public class ShockwaveTowerBuild extends Building{', 'return reloadCounter < reload;', 'public boolean shouldConsume(){', 'if(sensor == LAccess.progress) return reloadCounter / reload;', 'heat = Mathf.clamp(heat - Time.delta / reload * cooldownMultiplier);', 'return heat;', 'public void updateTile(){', 'heat = 1f;', 'reloadCounter = 0f;', 'float waveDamage = Math.min(bulletDamage, bulletDamage * falloffCount / targets.size);', 'public float bulletDamage = 160;', 'public float falloffCount = 20f;', 'public float shake = 2f;', 'public int timerCheck = timers ++;', 'update = true;', 'solid = true;', 'return efficiency * delta();', 'return potentialEfficiency > 0;', 'public boolean canConsume(){', 'potentialEfficiency = efficiency;', 'boolean update = shouldConsume() && productionValid();', 'if(!update){', 'efficiency = optionalEfficiency = 0f;', 'return enabled;', 'consumePower(100f / 60f);', 'consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f));', 'range = 170f;', 'reload = 80f;', 'size = 3;', 'return build.power.status;', 'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;', 'hasConsumers = consumers.length > 0;', 'targets.clear();', 'Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', 'if(b.team != team && b.type.hittable){', 'targets.add(b);', 'if(targets.size > 0){', 'waveEffect.at(x, y, range, waveColor);', 'shootSound.at(x, y, 1f + Mathf.range(0.15f), 1f);', 'Effect.shake(shake, shake, this);', 'for(var target : targets){', 'if(target.damage > waveDamage){', 'target.damage -= waveDamage;', 'target.remove();', 'hitEffect.at(target.x, target.y, waveColor);', 'if(team == state.rules.defaultTeam){', 'Events.fire(Trigger.shockwaveTowerUse);', 'public Sound shootSound = Sounds.shockwaveTower;', 'public Effect waveEffect = Fx.pointShockwave;', 'public Effect hitEffect = Fx.hitSquaresColor;', 'public boolean timer(int index, float time){', 'return timer.get(index, time);', 'transient Interval timer = new Interval(6);', 'public Seq<Bullet> targets = new Seq<>();', 'public static final int tilesize = 8;', 'offset = ((size + 1) % 2) * tilesize / 2f;', 'return x * tilesize;', 'return block().offset + worldx();']

# DEFERRED is carried from the N2194 register script via import --
# never retyped. The N2194 script's DEFERRED is a computed
# expression (list(_N2193_DEFERRED) + [...]), NOT a plain list
# literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node, ast.Call); the import
# recovers the runtime value verbatim. NOTE for the next slice:
# N2195's DEFERRED is likewise a computed list(...) + [...]
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
# ShockwaveTower follow-ups from N2195's own standpoint instead
# of retyping the old list. The bullet scan itself is NOT carried
# as deferred: it is THIS slice (N2195) -- the inherited N2194
# entry still names it as waiting, which is stale history,
# superseded by this slice.
DEFERRED = list(_N2194_DEFERRED) + [
    'ShockwaveTower bullet scan Windows Godot proof -- debt in GOAL.md section 5, same as N2182-N2194: the N2195 proof runs headless on Linux here and waits for a Windows Godot run.',
    'ShockwaveTower fire follow-ups after the live bullet scan (ShockwaveTower.java:87-96 wave damage application; :84-86, :95 waveEffect / shootSound / shake / hitEffect; :97-99 shockwaveTowerUse event; :73 timer cadence timer(timerCheck, checkInterval 8f) -- the port tracks no per-building Interval timer state, so the port fires on the first ready tick where Java waits for a timer tick, and the scan runs every tick where Java scans only on a timer tick; :110 sense(LAccess.progress); :117 warmup(); cyanogen liquid consumer Blocks.java:2041; draw :126-134; bullet hitSize -- the scan tests the bullet point against the intersect rect, not the bullet hitbox overlap Java intersect tests) -- N2195 lands ONLY the live scan stamping targets_count from the observed bullet list; the damage, Fx/sound/shake, event, timer cadence, sense, warmup, liquid, draw and hitSize wait for their own slices.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=SHOCKWAVE_TOWER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2195_inputs = {
        'frame': f('Dictionary', 'Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', 'The building frame carrying the observed_bullets list (an array of dicts with team/hittable/x/y, world coords -- the port has no live bullet query, so the list is an explicit observed frame key, the N2190 precedent) plus the tower world position (x/y frame keys, derived by the driver from the placement cell: Tile.java `return x * tilesize;` / `return block().offset + worldx();`, tilesize 8, offset 0 for size 3) and the tower team (team_id, stamped by the tick wiring). The per-def range is 170f (Blocks.java:2043), overriding the class default `110f` (ShockwaveTower.java:25).', source=BUILDING_COMP),
    }
    n2195_outputs = {
        'targets_count': f('int', 'if(b.team != team && b.type.hittable){', 'The count of enemy hittable bullets inside the range box (ShockwaveTower.java:76-77): a bullet counts when its team differs from the tower team AND its type is hittable AND its point lies inside x +/- range, y +/- range (range 170f per-def, Blocks.java:2043); null when no observation exists (absent observed_bullets, x, y, or team_id), so the driver stamps nothing and N2194 keeps reading absent as no fire.'),
        'has_targets_count': f('bool', 'Groups.bullet.intersect(x - range, y - range, range * 2, range * 2, b -> {', 'Whether the scan had an observation to run over (ShockwaveTower.java:75): true when observed_bullets, x, y, and team_id are all present on the frame (a present-but-empty list IS an observation and stamps 0), false otherwise -- the driver stamps frame["targets_count"] only when this is true.'),
    }

    entries = [
        ('N2195', OWNER, 'source_shockwave_tower_bullet_scan_state', SHOCKWAVE_TOWER, 'mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', 'ShockwaveTowerBuild.updateTile()', n2195_inputs, n2195_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ShockwaveTower live bullet scan from ShockwaveTower.java / BuildingComp.java / Tile.java / Vars.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ShockwaveTower live bullet scan from ShockwaveTower.java / BuildingComp.java / Tile.java / Vars.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the stamped count, the observation flag.
    by_slice['N2195'] = [
        'source_shockwave_tower_bullet_scan_state_result.targets_count',
        'source_shockwave_tower_bullet_scan_state_result.has_targets_count',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2195', dict(status='done', java_source=SHOCKWAVE_TOWER, java_class='mindustry.world.blocks.defense.ShockwaveTower.ShockwaveTowerBuild', java_method='ShockwaveTowerBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2195'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
