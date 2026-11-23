"""Register the TurretBuild findEnemy() ammo binding + bestTarget opener (N2425).

TurretBuild.findEnemy() (Turret.java:639-649), else branch:
`var ammo = peekAmmo();` (:643) and
`return Units.bestTarget(team, x, y, range,` (:645, opener of the
multi-line call). Everything else in the method is already owned at
N2316 (the findEnemy signature, the air-only bestEnemy branch, the
`boolean buildings = ...` line :644 and the two predicate lambdas)
and is NOT re-registered here.

This slice extends the existing GD function
source_turret_find_enemy_state (N2316): it adds no new owner, no new
contract and no new schema. The ammo binding arrives as the three
ammo flags (ammo_is_null / ammo_target_blocks / ammo_target_missiles),
which the driver derives from the peekAmmo() result (N2329 owns
peekAmmo); the bestTarget call is the unit loop (units first,
bestEnemy) plus the building fallback (findEnemyTile) that the
function already implements. The single result symbol is shared with
N2316 (the shared-symbol precedent: building_cursor.* is listed by
several slices).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_find_target import DEFERRED as N2316_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
UNITS = 'core/src/mindustry/entities/Units.java'
PROOF = '/root/C07TurretFindEnemyProof'
FIND_ENEMY_OWNER = 'SourceTurretBuildState.source_turret_find_enemy_state'
TESTS = ['test_c07_turret_find_enemy_registration', 'test_all_c07_turret_find_enemy_input_evidence_is_exact', 'test_turret_find_enemy_state', 'test_reference_graph_and_actual_c07_turret_find_enemy']
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/Units.java',
]
EXACT_EXPRS = [
    'var ammo = peekAmmo();',
    'return Units.bestTarget(team, x, y, range,',
]
# The shared result symbol's java_expr (Units.bestTarget signature)
# must appear verbatim in its upstream source.
SHARED_SYMBOL_EXPRS = [
    'public static Teamc bestTarget(Team team, float x, float y, float range, Boolf<Unit> unitPred, Boolf<Building> tilePred, Sortf sort){',
]

# DEFERRED is carried from the N2316 register script via import --
# never retyped. Two entries are added: the N2425 Windows Godot
# proof debt (GOAL.md section 5) and the ammo-binding driver side
# (the driver derives the three ammo flags from the peekAmmo()
# result; N2329 owns peekAmmo).
DEFERRED = N2316_DEFERRED + [
    'Turret findEnemy() ammo binding + bestTarget opener Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2425 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Derive the findEnemy ammo flags (ammo_is_null / ammo_target_blocks / ammo_target_missiles) on the driver side from the peekAmmo() result (N2329 owns peekAmmo); N2425 proves the flag semantics only and ports no live peekAmmo() call.',
]


def verify():
    """Check every EXACT_EXPRS line and the shared symbol's java_expr
    appear verbatim in their upstream sources, without touching any
    SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    units_text = upstream[UNITS]
    for expr in SHARED_SYMBOL_EXPRS:
        if expr not in units_text:
            missing.append(expr)
    total = len(EXACT_EXPRS) + len(SHARED_SYMBOL_EXPRS)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    source_symbols.upsert_source_slice(GODOT, 'N2425', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.findEnemy(float)', godot_owner=FIND_ENEMY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=['source_turret_find_enemy_state_result.target'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {FIND_ENEMY_OWNER}
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
