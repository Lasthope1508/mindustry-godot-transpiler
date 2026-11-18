"""Register the PointDefenseTurret spawn-side team stamp (N2243).

N2242 left should_consume dead in live play: live
`game["bullets"]` dicts carry no team (the only writer,
SourceBulletSpawnState.gd source_spawn_turret_bullet_from_state,
appends sprite / target / velocity / speed / damage /
hitSize / lifetime_remaining only), so the N2242 wiring
excludes every live bullet and the N2239 acquire never
sees an enemy target. Java gives every live Bullet a
team: the firing building passes its own team into the
create chain (`handleBullet(type.create(this, team, ...`,
Turret.java:790; `bullet.team = team;`,
BulletType.java:954; `@Import Team team;`,
BulletComp.java:29). This slice stamps the firing
turret's team onto each live bullet dict at spawn,
threading one extra `team_id: int` parameter
turret-sim -> bridge -> runtime -> spawn state. One new
result symbol: team.

RED decisions (pinned by this slice): (1) One extra
`team_id: int` parameter on each of the four functions
in the chain (no new synonym; the name is the
SourceTurretBuildState.gd:199 precedent), and the sim
loop reads the firing cell's team from the placed sprite
that owns the cell (`origin_cell` meta,
SourcePlacedBlockState.gd:90; the team meta key,
SourceBlockGeometry.gd:161, derelict default 0). (2) The
appended live dict gains exactly one key, `"team":
team_id`; nothing else in the dict changes. (3) NO
change to the N2242 mapping function (it already reads
`team` when present); NO per-type `hittable` lookup
(damageLightning / fireball wait for their own slice).
(4) The deferred pool resolves the N2242 spawn-team
entry and gains the N2243 Windows-proof debt entry, so
the pool stays 284. Shard note: Turret.java lives under
/world/blocks/defense/turrets/ and matches the defense
shard selection (the N2239-N2242 precedent), so the
GREEN register run records the defense shard count
change. SSOT expected after GREEN: symbols +1, Done +1,
contracts +1, schema +2, 11557/1692/1623/3037 ->
11558/1693/1624/3039. Contract note: the spawn helper was
renamed `spawn_turret_bullet_from_state` ->
`source_spawn_turret_bullet_from_state` (pure rename, no
gameplay change) so the validator discovers it
(`_discover_godot_owner_functions` in source_symbols.py
only discovers `source_` / `generated_` / `tile_`
functions) and a contract IS registered for it. The
unprefixed name could not carry a contract (the catalog
validator reported 'facade/module function not
discovered' + 'void return requires an explicit
-> void implementation', N2243 gate 1: 10 failures), and
dropping the contract instead broke the defense mirror
invariant (every defense slice owner must have a
contract, N2243 gate 4: 1 failure). The stamped team
stays documented by the result schema + result symbol
as well as by the contract.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_point_defense_turret_live_bullets_wiring import DEFERRED as N2242_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
BULLET_COMP = 'core/src/mindustry/entities/comp/BulletComp.java'
PROOF = '/root/C07PointDefenseTurretSpawnTeamStampProof'
SPAWN_OWNER = 'SourceBulletSpawnState.source_spawn_turret_bullet_from_state'
TESTS = ['test_c07_point_defense_turret_spawn_team_stamp_registration', 'test_all_c07_point_defense_turret_spawn_team_stamp_input_evidence_is_exact', 'test_point_defense_turret_spawn_team_stamp_state', 'test_reference_graph_and_actual_c07_point_defense_turret_spawn_team_stamp']
# The 3 slice sources the N2243 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/entities/comp/BulletComp.java',
]
HANDLE_BULLET = 'handleBullet(type.create(this, team, bulletX, bulletY, shootAngle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd), lifeScl, null, mover, targetPos.x, targetPos.y), xOffset, yOffset, shootAngle - rotation);'
EXACT_EXPRS = [HANDLE_BULLET, 'bullet.team = team;', '@Import Team team;']

# DEFERRED is carried from the N2242 register script via import --
# never retyped. The N2242 spawn-side team stamp entry is
# RESOLVED by this slice (the chain now stamps the firing
# turret's team), and the N2243 Windows-proof debt entry is
# appended, so the pool stays 284.
DEFERRED = [entry for entry in N2242_DEFERRED if 'spawn-side team stamp -- live bullets carry no team' not in entry] + [
    'PointDefenseTurret spawn-side team stamp Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2242: the N2243 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    spawn_inputs = {
        'team_id': a('int', 'bullet.team = team;', 'The firing turret\'s team the spawn chain stamps onto the live bullet dict (BulletType.java:954 -- the create chain stamps the firing building\'s team, passed in by Turret.java:790; every live Bullet carries the field, BulletComp.java:29).', source=BULLET_TYPE),
    }
    spawn_outputs = {
        'team': a('int', HANDLE_BULLET, 'The team stamped onto the appended live bullet dict (Turret.java:790 -- the firing building passes its own team into the create chain, so the live bullet carries the firing turret\'s team and the N2242 wiring can include it with its real team).'),
    }
    return spawn_inputs, spawn_outputs


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
    spawn_inputs, spawn_outputs = definitions()

    entries = [
        ('N2243', SPAWN_OWNER, 'spawn_turret_bullet_from_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.bullet(BulletType, float, float, float, Mover)', spawn_inputs, spawn_outputs, True, 'void'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret spawn-side team stamp from Turret.java / BulletType.java / BulletComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=[] if return_type == 'void' else list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret spawn-side team stamp from Turret.java / BulletType.java / BulletComp.java. The function is -> void (it mutates game["bullets"]); the stamped team is a side-effect output documented by the result schema + result symbol.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: team.
    by_slice['N2243'] = [
        'spawn_turret_bullet_from_state_result.team',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2243', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.bullet(BulletType, float, float, float, Mover)', godot_owner=SPAWN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2243'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
