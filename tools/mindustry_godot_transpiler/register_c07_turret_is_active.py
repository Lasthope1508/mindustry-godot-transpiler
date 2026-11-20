"""Register the Turret isActive() derivation (N2280).

isActive() is `public boolean isActive(){ return (target
!= null || wasShooting) && enabled && activationTimer <=
0; }` (Turret.java:449-450) on the fields `public boolean
wasShooting, isShooting;` (Turret.java:292, set false at
:517 and true at :600/:608 in updateTile), `transient
boolean enabled = true;` (BuildingComp.java:77) and
`public float activationTimer = 0;` (BaseTurret.java:115,
decayed live by the N2279 tick). All four clauses are live
on the frame now: has_target through the validateTarget
verdict (N2251), was_shooting stamped from the aim result
every tick (N2240), enabled preserved by the frame tick
(N2125), activation_timer decayed by the N2279 tick. Only
LaserTurret consumes it in Java (`if(bullets.any() ||
isActive()) return true;`, LaserTurret.java:55 in
shouldConsume() :53-57); duo is an ItemTurret with no
consumer, so this slice is stamp-only like N2274-N2276:
one pure function plus one driver tick, no consumer
rewired. The driver tick runs right after the was_shooting
stamp, once every input is its final value for the tick,
so the frame after a driver tick is the self-consistent
snapshot a future consumer reads -- in Java that consumer
runs in updateConsumption() BEFORE updateTile()
(BuildingComp.java:2274 vs :2277), so a live call sees the
previous tick's wasShooting / target; the one-tick
difference waits for the LaserTurret consumer slice, which
also needs the bullets live list the port does not have
yet.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_is_active_state(has_target, was_shooting,
enabled, activation_timer), returning `{"is_active": ..}`
-- the Java return verbatim, with `target != null` mapped
to the has_target bool (the N2277 precedent). It sits
immediately AFTER source_turret_activation_timer_state
(it consumes the activationTimer <= 0 clause N2279
stamps). Plus one driver tick in the duo branch (right
after the was_shooting stamp, before the shot block) that
derives the verdict live from the frame values and stamps
it on frame["is_active"]. (2) No consumer is rewired:
duo never calls isActive(), and LaserTurret.shouldConsume()
needs the bullets live list. (3) No legacy
`source_turret_is_active_result` schema exists, so the
contract validator falls through to the new
source_turret_is_active_state_result schema and no alias
is needed. SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schema +1, 11656/1729/1663/3117 ->
11657/1730/1664/3118; defense shard slices 206 -> 207,
contracts 205 -> 206.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_activation_timer import DEFERRED as N2279_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
PROOF = '/root/C07TurretIsActiveProof'
IS_ACTIVE_OWNER = 'SourceTurretBuildState.source_turret_is_active_state'
TESTS = ['test_c07_turret_is_active_registration', 'test_all_c07_turret_is_active_input_evidence_is_exact', 'test_turret_is_active_state', 'test_reference_graph_and_actual_c07_turret_is_active']
# The slice sources the N2280 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
]
EXACT_EXPRS = [
    'public boolean isActive(){',
    'return (target != null || wasShooting) && enabled && activationTimer <= 0;',
    'public boolean wasShooting, isShooting;',
    'transient boolean enabled = true;',
    'public float activationTimer = 0;',
]

# DEFERRED is carried from the N2279 register script via import --
# never retyped. isActive() is done by this slice; the
# LaserTurret consumer, the activation early-return skip,
# shootp / calculateHeat / findTarget / the other ItemTurret
# defs / controlled() still wait.
DEFERRED = list(N2279_DEFERRED) + [
    'Turret isActive() (`return (target != null || wasShooting) && enabled && activationTimer <= 0;`, Turret.java:449-450) -- DONE by this slice (N2280); the pure function ports the Java return verbatim (target != null mapped to the has_target bool, the N2277 precedent) and the duo driver stamps frame["is_active"] live right after the was_shooting stamp. Duo has no consumer; the stamp is for the future LaserTurret consumer.',
    'LaserTurret shouldConsume() wiring (`if(bullets.any() || isActive()) return true;`, LaserTurret.java:55) -- NOT this slice; it also needs the bullets live list, which the port does not have yet, and Java evaluates it in updateConsumption() before updateTile() (BuildingComp.java:2274 vs :2277), so a live call sees the previous tick\'s wasShooting / target -- the one-tick snapshot difference waits for that consumer slice.',
    'Turret isActive() for defs other than duo -- the pure function takes has_target / was_shooting / enabled / activation_timer as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    is_active_inputs = {
        'has_target': a('bool', 'target != null', 'Whether the turret has an acquired target (Turret.java:450, the `target != null` clause; the driver keeps frame["target"] / frame["has_target"] in sync through the validateTarget verdict, N2251).'),
        'was_shooting': a('bool', 'public boolean wasShooting, isShooting;', 'Whether the turret shot this tick (Turret.java:292, set false at :517 and true at :600/:608 in updateTile; the driver stamps frame["was_shooting"] from the aim result every tick).'),
        'enabled': a('bool', 'transient boolean enabled = true;', 'Whether the building is enabled (BuildingComp.java:77, default true; the frame tick preserves a disabled turret instead of resetting it).', source=BUILDING_COMP),
        'activation_timer': a('float', 'public float activationTimer = 0;', 'The activation timer (BaseTurret.java:115, set to activationTime in placed() :119-120; the class default activationTime is 0f, BaseTurret.java:27, and duo never overrides it, so the live duo value is 0.0; decayed live by the N2279 tick).', source=BASE_TURRET),
    }
    is_active_outputs = {
        'is_active': a('bool', 'return (target != null || wasShooting) && enabled && activationTimer <= 0;', 'Whether the turret build is active (Turret.java:449-450, the isActive() return verbatim; the driver stamps it on frame["is_active"] right after the was_shooting stamp).'),
    }
    return is_active_inputs, is_active_outputs


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
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
    is_active_inputs, is_active_outputs = definitions()

    entries = [
        ('N2280', IS_ACTIVE_OWNER, 'source_turret_is_active_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.isActive()', is_active_inputs, is_active_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret isActive() derivation from TurretBuild.isActive() / Turret.java:449-450.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret isActive() derivation from TurretBuild.isActive() / Turret.java:449-450.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: is_active.
    by_slice['N2280'] = [
        'source_turret_is_active_state_result.is_active',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2280', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.isActive()', godot_owner=IS_ACTIVE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2280'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
