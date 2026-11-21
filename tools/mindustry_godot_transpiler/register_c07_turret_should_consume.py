"""Register the Turret shouldConsume() gate (N2524).

shouldConsume() is `public boolean shouldConsume(){
return isShooting || reloadCounter < reload; }`
(Turret.java:364-366), the one-line predicate on the turret
build's own two fields. Both inputs are already live on the
frame: `isShooting` (Turret.java:492, ported N2277 --
`source_turret_is_shooting_state`, the tick stamps
`frame["is_shooting"]` in the duo branch) and `reloadCounter`
(ReloadTurret.java:26, ported N2240 -- the aim call stamps
`frame["reload_counter"]` in the duo branch). The driver
tick's consumption branch ran the machinery with
should_consume=true whenever enabled, with a comment saying
there is no shouldConsume gate yet -- that comment is now
STALE for duo (the tick tracks both inputs since N2277 +
N2240). This slice ports the predicate as a pure function
and wires it into the consumption branch, so a power turret
stops consuming when it is neither shooting nor reloading.
Java order is updateConsumption() BEFORE updateTile()
(BuildingComp.java:2274 vs :2277), so the gate reads the
PREVIOUS tick's frame values (the N2270 heat fold
precedent). When the gate is false,
update_consumption_setup_state returns `update =
should_consume and production_valid`
(SourceBuildingEfficiencyState.gd:106-107) and
update_consumption_efficiency_state folds `efficiency =
0.0` (:127-134) -- exactly Java (BuildingComp.java:1947,
`efficiency = ... shouldConsume() ? potentialEfficiency :
0f;`). `reload` is per def, read from the catalog
(`block.properties`, the N2270 precedent -- the catalog
carries reload for every turret def), class default 10f
(ReloadTurret.java:10); the six defs the branch can visit
with consumePower are lancer 80f / 6f, arc 35f / 3.3f,
foreshadow 200f / 10f, meltdown 90f / 17f, afflict 50f /
5f, malign 3.5f / 40f (Blocks.java). This slice does NOT
touch the duo branch, aim/shoot, validate, isShooting,
warmup, recoil, unit sync, or any N2520-N2523 stamp, and
does NOT add a second pure function for the reload lookup
-- the catalog IS the per-def table (the N2270
heatRequirement precedent).

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_should_consume_state(frame, reload), placed
immediately AFTER source_turret_power_status_row_state (the
other helper of the consumption branch) and BEFORE
source_turret_can_heal_state. It reads `enabled` (default
true), `is_shooting` (default false) and `reload_counter`
(default 0.0) from the frame, returns exactly ONE key,
`should_consume` (the N2241 PointDefense precedent -- one
pure function, one key, frame-read inputs; `reload` is the
only scalar param because it is per-def config, not frame
state). (2) ONE tick call site in the consumption branch
(:2497-2499), replacing `var should_consume: bool =
bool(frame.get("enabled", true))` with `var
should_consume_state: Dictionary =
source_turret_should_consume_state(frame,
float(block.properties.get("reload", 10.0)))` then `var
should_consume: bool =
bool(should_consume_state.get("should_consume", true))`.
The downstream lines are UNCHANGED
(`update_consumption_setup_state`,
`update_consumption_state`,
`apply_update_consumption_state`, the PowerTurret heat
fold). (3) The stale "no shouldConsume gate yet" comment
in the consumption branch is removed; the
source_turret_power_status_row_state comment saying the
same is corrected too. (4) No legacy
`source_turret_should_consume_state_result` schema exists,
so the contract validator falls through to the new schema
and no alias is needed. SSOT expected after GREEN: symbols
+1, Done +1, contracts +1, schema +2, 11711/1752/1685/3161
-> 11712/1753/1686/3163; defense shard slices 211 -> 212,
contracts 210 -> 211; comp stays 572/475. (The scope's
inline-match reload table is NOT followed: the catalog
already carries reload per def -- verified against
Blocks.java this run -- so the tick reads
`block.properties.get("reload", 10.0)"` exactly like the
N2270 heatRequirement read; no new table is invented.)
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_controlled_stamp import DEFERRED as N2523_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07TurretShouldConsumeProof'
SHOULD_CONSUME_OWNER = 'SourceTurretBuildState.source_turret_should_consume_state'
TESTS = ['test_c07_turret_should_consume_registration', 'test_all_c07_turret_should_consume_input_evidence_is_exact', 'test_turret_should_consume_state', 'test_reference_graph_and_actual_c07_turret_should_consume']
# The slice sources the N2524 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = [
    'public boolean shouldConsume(){',
    'return isShooting || reloadCounter < reload;',
    'public float reload = 10f;',
    'public float reloadCounter;',
    'protected boolean canReload(){',
    'return reloadCounter < reload;',
    'efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;',
    'updateConsumption();',
    'updateTile();',
    'lancer = new PowerTurret("lancer"){{',
    'arc = new PowerTurret("arc"){{',
    'foreshadow = new ItemTurret("foreshadow"){{',
    'meltdown = new LaserTurret("meltdown"){{',
    'afflict = new PowerTurret("afflict"){{',
    'malign = new PowerTurret("malign"){{',
    'reload = 80f;',
    'reload = 35f;',
    'reload = 200f;',
    'reload = 90f;',
    'reload = 50f;',
    'reload = 3.5f;',
    'consumePower(6f);',
    'consumePower(3.3f);',
    'consumePower(10f);',
    'consumePower(17f);',
    'consumePower(5f);',
    'consumePower(40f);',
]

# DEFERRED is carried from the N2523 register script via import --
# never retyped. No entry is dropped: the gate completes no
# deferred entry except the shouldConsume wiring itself
# (recorded DONE below). New entries below record the gate as
# DONE by this slice, the Windows proof debt, and the
# updateCooling coolant fold (new -- no pool entry mentions it).
# LaserTurret.shouldConsume() and the validateTarget
# effective-team wiring already have pool entries (checked this
# run: 'LaserTurret shouldConsume() wiring' and 'Turret
# validateTarget() effective-team wiring'), so they are NOT
# re-added here.
DEFERRED = N2523_DEFERRED + [
    'Turret shouldConsume() gate (`should_consume` frame key) -- DONE by this slice (N2524): `source_turret_should_consume_state` gates the consumption branch on `enabled && (is_shooting || reload_counter < reload)` (Turret.java:364-366), reading `is_shooting` (N2277 stamp) and `reload_counter` (N2240 stamp) from the frame and `reload` per def from the catalog (`block.properties`, class default 10f, ReloadTurret.java:10); the gate runs in updateConsumption order (before updateTile, BuildingComp.java:2274 vs :2277) so it reads the previous tick\'s frame values. Dormant live today: only duo stamps the two frame keys and duo has no consumePower, so the gate reads the absent defaults (false / 0.0 < reload) and stays true on every live frame; it goes live when aim/shoot drivers land for the power turrets.',
    'Turret shouldConsume() gate Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523: the N2524 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret updateCooling coolant fold (ReloadTurret.java:28-39, called from updateTile :547-551) -- DEFERRED (new, after N2524): needs turret liquid-module state (`liquids.current()`, `coolant.efficiency(this)`, `coolant.update(this)`); the frame carries no liquid state today.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    should_consume_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The turret frame (the port Building state) the tick stamps every tick (`public void updateTile(){`, Turret.java:490 -- the driver tick for every Turret-family build); the gate reads `enabled` (default true), `is_shooting` (default false, N2277 stamp) and `reload_counter` (default 0.0, N2240 stamp) from it and returns exactly one key (the N2241 precedent).'),
        'reload': a('float', 'public float reload = 10f;', 'The per-def reload time in ticks (`public float reload = 10f;`, ReloadTurret.java:10 -- the class default); the tick reads it per def from the catalog (`block.properties`, the N2270 precedent): lancer 80f, arc 35f, foreshadow 200f, meltdown 90f, afflict 50f, malign 3.5f (Blocks.java).', source=RELOAD_TURRET),
    }
    should_consume_outputs = {
        'should_consume': a('bool', 'return isShooting || reloadCounter < reload;', 'Whether the turret should consume this tick (`public boolean shouldConsume(){` / `return isShooting || reloadCounter < reload;`, Turret.java:364-366 -- the consumption branch feeds it to `update_consumption_setup_state`, so a false gate folds efficiency to 0.0, BuildingComp.java:1947).'),
    }
    return should_consume_inputs, should_consume_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    should_consume_inputs, should_consume_outputs = definitions()

    entries = [
        ('N2524', SHOULD_CONSUME_OWNER, 'source_turret_should_consume_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.shouldConsume()', should_consume_inputs, should_consume_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret shouldConsume() gate from Turret.java:364-366 + :490-492 + ReloadTurret.java:10/:26/:46-48 + BuildingComp.java:1947/:2274/:2277.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret shouldConsume() gate from Turret.java:364-366 + :490-492 + ReloadTurret.java:10/:26/:46-48 + BuildingComp.java:1947/:2274/:2277.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: should_consume.
    by_slice['N2524'] = [
        'source_turret_should_consume_state_result.should_consume',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2524', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.shouldConsume()', godot_owner=SHOULD_CONSUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2524'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
