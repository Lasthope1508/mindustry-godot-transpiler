"""Register the Turret canHeal() derivation (N2281).

canHeal() is `protected boolean canHeal(){ return
targetHealing && hasAmmo() && peekAmmo().collidesTeam &&
peekAmmo().heals(); }` (Turret.java:635-637) on the fields
`public boolean targetHealing = false;` (Turret.java:95,
duo never sets it, grep Blocks.java duo 3257-3331: no
hit), `public boolean collidesTeam = false;`
(BulletType.java:127, the duo ammo catalog has no
collidesTeam key) and `public boolean heals(){ return
healPercent > 0 || healAmount > 0; }`
(BulletType.java:447-449, on healPercent = 0f (:165) and
the healAmount default 0f; duo ammo never sets either).
hasAmmo() is `public boolean hasAmmo(){`
(Turret.java:698), read live from the duo ammo stacks.
Both Java consumers (validateTarget :632 and findTarget
:660) need a live entity scan, so no consumer is rewired:
this slice is stamp-only like N2280, one pure function
plus one driver tick, no consumer rewired. The driver tick
runs right before the logic_controlled tick, before the
validateTarget call (Java order :491 validate calls
canHeal, before :492 isShooting), so the frame carries
the verdict as a live key for the future findTarget slice
to feed into the effective-team resolution.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_can_heal_state(target_healing, has_ammo,
ammo_collides_team, ammo_heals), returning `{"can_heal": ..}`
-- the Java return verbatim. It sits immediately BEFORE
source_turret_logic_controlled_state (validateTarget :491
calls canHeal before isShooting :492). Plus one driver
tick in the duo branch (right before the logic_controlled
tick) that derives the verdict live from the frame values
and stamps it on frame["can_heal"]. (2) No consumer is
rewired: validateTarget's effective-team resolution
(Turret.java:632) still reads frame["target_same_team_effective"]
(stamped by test/fixture) and findTarget's ally-tile
acquisition (:660) waits for its own slice; both need the
live entity scan the port does not have yet. (3) No legacy
`source_turret_can_heal_result` schema exists, so the
contract validator falls through to the new
source_turret_can_heal_state_result schema and no alias
is needed. SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schema +2, 11657/1730/1664/3119 ->
11658/1731/1665/3121; defense shard slices 207 -> 208,
contracts 206 -> 207.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_is_active import DEFERRED as N2280_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
PROOF = '/root/C07TurretCanHealProof'
CAN_HEAL_OWNER = 'SourceTurretBuildState.source_turret_can_heal_state'
TESTS = ['test_c07_turret_can_heal_registration', 'test_all_c07_turret_can_heal_input_evidence_is_exact', 'test_turret_can_heal_state', 'test_reference_graph_and_actual_c07_turret_can_heal']
# The slice sources the N2281 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
]
EXACT_EXPRS = [
    'protected boolean canHeal(){',
    'return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();',
    'public boolean targetHealing = false;',
    'public boolean collidesTeam = false;',
    'return healPercent > 0 || healAmount > 0;',
]

# DEFERRED is carried from the N2280 register script via import --
# never retyped. canHeal() is done by this slice; the
# validateTarget effective-team wiring, the findTarget
# ally-tile acquisition, shootp / calculateHeat / the other
# ItemTurret defs / controlled() still wait.
DEFERRED = list(N2280_DEFERRED) + [
    'Turret canHeal() (`return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();`, Turret.java:635-637) -- DONE by this slice (N2281); the pure function ports the Java return verbatim and the duo driver stamps frame["can_heal"] live right before the logic_controlled tick, before the validateTarget call. Duo has no consumer; the stamp is for the future findTarget slice.',
    'Turret validateTarget() effective-team wiring (`canHeal() ? Team.derelict : team`, Turret.java:632) -- NOT this slice; it needs the live entity scan the port does not have yet, so the driver still reads frame["target_same_team_effective"] (stamped by test/fixture); can_heal live will feed it when the findTarget slice lands.',
    'Turret findTarget() ally-tile acquisition (`if(target == null && canHeal()){ target = Units.findAllyTile(team, x, y, range, b -> b.damaged() && b != this); }`, Turret.java:660) -- NOT this slice; BLOCKED, live entity scan.',
    'Turret canHeal() for defs other than duo -- the pure function takes target_healing / has_ammo / ammo_collides_team / ammo_heals as params; only duo is wired in the driver.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    can_heal_inputs = {
        'target_healing': a('bool', 'public boolean targetHealing = false;', 'Whether the turret targets friendly blocks to heal them (Turret.java:95, default false; duo never sets it, grep Blocks.java duo 3257-3331: no hit, so the driver passes a false literal).'),
        'has_ammo': a('bool', 'public boolean hasAmmo(){', 'Whether the turret has ammo (Turret.java:698, the hasAmmo() check on the ammo stacks; the driver reads it live as the duo ammo stacks being non-empty).'),
        'ammo_collides_team': a('bool', 'public boolean collidesTeam = false;', 'Whether the peeked ammo collides with tiles of the same team (BulletType.java:127, default false; the duo ammo catalog has no collidesTeam key, so the driver falls back to the field default).', source=BULLET_TYPE),
        'ammo_heals': a('bool', 'return healPercent > 0 || healAmount > 0;', 'Whether the peeked ammo heals (BulletType.java:447-449, the heals() return on healPercent = 0f (:165) and the healAmount default 0f; duo ammo never sets either, so the driver reads it live from the peeked ammo data).', source=BULLET_TYPE),
    }
    can_heal_outputs = {
        'can_heal': a('bool', 'return targetHealing && hasAmmo() && peekAmmo().collidesTeam && peekAmmo().heals();', 'Whether the turret build can heal (Turret.java:635-637, the canHeal() return verbatim; the driver stamps it on frame["can_heal"] right before the logic_controlled tick).'),
    }
    return can_heal_inputs, can_heal_outputs


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
    can_heal_inputs, can_heal_outputs = definitions()

    entries = [
        ('N2281', CAN_HEAL_OWNER, 'source_turret_can_heal_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.canHeal()', can_heal_inputs, can_heal_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret canHeal() derivation from TurretBuild.canHeal() / Turret.java:635-637.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret canHeal() derivation from TurretBuild.canHeal() / Turret.java:635-637.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: can_heal.
    by_slice['N2281'] = [
        'source_turret_can_heal_state_result.can_heal',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2281', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.canHeal()', godot_owner=CAN_HEAL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2281'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
