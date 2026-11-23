"""Register Turret field-decl targeting/shoot defaults (N2445).

Turret field declarations (Turret.java:42, :44, :82, :89, :91,
:93, :99, :101, :109, :111) -- the targeting/shoot defaults
group:
`:42` `public float targetInterval = 20;`
`:44` `public float newTargetInterval = -1f;`
`:82` `public boolean reloadWhileCharging = true;`
`:89` `public boolean targetAir = true;`
`:91` `public boolean targetGround = true;`
`:93` `public boolean targetBlocks = true;`
`:99` `public boolean displayAmmoMultiplier = true;`
`:101` `public boolean targetUnderBlocks = true;`
`:109` `public Boolf<Unit> unitFilter = u -> true;`
`:111` `public Boolf<Building> buildingFilter = b -> targetUnderBlocks || !b.block.underBullets;`
All 10 lines are 0-hit in BOTH ledgers (re-probed at base
8a0c6e4d, exact match).

Field-decl-only slice, main-thread decision with N2440
(BeamDrill): decls belong to no method, so no method slice
can absorb them. One new GD function on the existing
SourceTurretBuildState.gd: source_turret_targeting_defaults_state
takes the two buildingFilter inputs (target_under_blocks,
under_bullets) and returns the 10 defaults as a Dictionary.
The two Boolf lambdas are data, not Callables: unitFilter is
`u -> true` (always true) and buildingFilter is the
`targetUnderBlocks || !b.block.underBullets` predicate
computed from the inputs.

NOT re-registered here: the other Turret field decls
(:46-:108 except these 10 -- maxAmmo, ammoPerShot,
consumeAmmoOnce, heatRequirement, maxHeatEfficiency,
inaccuracy, velocityRnd, scaleLifetimeOffset, shootCone,
shootX/shootY, xRand, drawMinRange, trackingRange, minRange,
minWarmup, accurateDelay, moveWhileCharging,
warmupMaintainTime, shoot, targetHealing,
playerControllable, alwaysShooting, predictTarget, unitSort,
heatColor, ...) -- later slices.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/C07TurretTargetingDefaultsProof'
TARGETING_DEFAULTS_OWNER = 'SourceTurretBuildState.source_turret_targeting_defaults_state'
TESTS = ['test_c07_turret_targeting_defaults_registration', 'test_all_c07_turret_targeting_defaults_input_evidence_is_exact', 'test_turret_targeting_defaults_state', 'test_reference_graph_and_actual_c07_turret_targeting_defaults']
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/Block.java',
]
EXACT_EXPRS = [
    'public float targetInterval = 20;',
    'public float newTargetInterval = -1f;',
    'public boolean reloadWhileCharging = true;',
    'public boolean targetAir = true;',
    'public boolean targetGround = true;',
    'public boolean targetBlocks = true;',
    'public boolean displayAmmoMultiplier = true;',
    'public boolean targetUnderBlocks = true;',
    'public Boolf<Unit> unitFilter = u -> true;',
    'public Boolf<Building> buildingFilter = b -> targetUnderBlocks || !b.block.underBullets;',
]

DEFERRED = [
    'Turret targeting/shoot field defaults Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2445 proof runs headless on Linux here and waits for a Windows Godot run.',
    'The live reads of the 10 defaults are later slices: targetInterval/newTargetInterval are consumed by the updateTile driver via timer_target_ready; reloadWhileCharging is consumed live by the driver param; targetAir/targetGround/targetBlocks and the per-candidate unit_filter/building_filter flags are consumed live by find_enemy; displayAmmoMultiplier is consumed by setStats; the live field read of targetUnderBlocks itself is a later slice (this slice takes it as an input).',
    'The live read of Block.underBullets (Block.java:118, declared without initializer, Java boolean default false) is a later slice: this slice takes under_bullets as an input, it never resolves the block field itself.',
    'The other Turret field decls (Turret.java:46-:108 except the 10 registered here) are later slices, not this one.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    targeting_defaults_inputs = {
        'target_under_blocks': a('bool', 'public boolean targetUnderBlocks = true;', 'Whether under blocks like conveyors are targeted (Turret.java:101, `public boolean targetUnderBlocks = true;`): this slice\'s :101 default -- echoed as both the input default and the returned key; the buildingFilter operand.'),
        'under_bullets': a('bool', 'public boolean underBullets;', 'Whether the candidate building\'s block is under bullets (Block.java:118, `public boolean underBullets;`): declared without initializer, Java boolean default false; read as-is from the input, the negated buildingFilter operand -- its live read is a later slice.', source=BLOCK),
    }
    targeting_defaults_outputs = {
        'target_interval': a('float', 'public float targetInterval = 20;', 'Ticks between attempts at finding a target (Turret.java:42, `public float targetInterval = 20;`).'),
        'new_target_interval': a('float', 'public float newTargetInterval = -1f;', 'Target interval for when this turret already has a valid target; -1 means targetInterval (Turret.java:44, `public float newTargetInterval = -1f;`).'),
        'reload_while_charging': a('bool', 'public boolean reloadWhileCharging = true;', 'Whether this turret can reload while charging (Turret.java:82, `public boolean reloadWhileCharging = true;`).'),
        'target_air': a('bool', 'public boolean targetAir = true;', 'Whether this block targets air units (Turret.java:89, `public boolean targetAir = true;`).'),
        'target_ground': a('bool', 'public boolean targetGround = true;', 'Whether this block targets ground units and structures (Turret.java:91, `public boolean targetGround = true;`).'),
        'target_blocks': a('bool', 'public boolean targetBlocks = true;', 'Whether this block targets blocks (Turret.java:93, `public boolean targetBlocks = true;`).'),
        'display_ammo_multiplier': a('bool', 'public boolean displayAmmoMultiplier = true;', 'Whether this block displays ammo multipliers in its stats (Turret.java:99, `public boolean displayAmmoMultiplier = true;`).'),
        'target_under_blocks': a('bool', 'public boolean targetUnderBlocks = true;', 'Whether under blocks like conveyors are targeted (Turret.java:101, `public boolean targetUnderBlocks = true;`): the returned default, echoing the input.'),
        'unit_filter': a('bool', 'public Boolf<Unit> unitFilter = u -> true;', 'Filter for types of units to attack (Turret.java:109, `public Boolf<Unit> unitFilter = u -> true;`): GDScript has no Java Boolf, so the lambda is data -- always true.'),
        'building_filter': a('bool', 'public Boolf<Building> buildingFilter = b -> targetUnderBlocks || !b.block.underBullets;', 'Filter for types of buildings to attack (Turret.java:111, `public Boolf<Building> buildingFilter = b -> targetUnderBlocks || !b.block.underBullets;`): GDScript has no Java Boolf, so the predicate is computed from the inputs as `target_under_blocks || !under_bullets`.'),
    }
    return targeting_defaults_inputs, targeting_defaults_outputs


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
    targeting_defaults_inputs, targeting_defaults_outputs = definitions()

    entries = [
        ('N2445', TARGETING_DEFAULTS_OWNER, 'source_turret_targeting_defaults_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret', 'Turret field declarations', targeting_defaults_inputs, targeting_defaults_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret targeting/shoot field defaults state from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret targeting/shoot field defaults state from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the 10 result keys in
    # Turret.java declaration order.
    by_slice['N2445'] = [
        'source_turret_targeting_defaults_state_result.target_interval',
        'source_turret_targeting_defaults_state_result.new_target_interval',
        'source_turret_targeting_defaults_state_result.reload_while_charging',
        'source_turret_targeting_defaults_state_result.target_air',
        'source_turret_targeting_defaults_state_result.target_ground',
        'source_turret_targeting_defaults_state_result.target_blocks',
        'source_turret_targeting_defaults_state_result.display_ammo_multiplier',
        'source_turret_targeting_defaults_state_result.target_under_blocks',
        'source_turret_targeting_defaults_state_result.unit_filter',
        'source_turret_targeting_defaults_state_result.building_filter',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2445', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret', java_method='Turret field declarations', godot_owner=TARGETING_DEFAULTS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2445'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
