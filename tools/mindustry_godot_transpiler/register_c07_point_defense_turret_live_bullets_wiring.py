"""Register the PointDefenseTurret live-bullets wiring (N2242).

N2241 left should_consume dead in live play: the frame never
carries `observed_bullets`, so the target stays null and
`should_consume` is false (PointDefenseTurret.java:105-107,
`return super.shouldConsume() && target != null;`). The driver
only runs the acquire when `frame.has("observed_bullets")`
(SourcePointDefenseTurretBuildState.gd) and never stamps that
key. This slice is the wiring: map the live `game["bullets"]`
dicts to the observed dicts the N2239 acquire consumes, and
stamp `frame["observed_bullets"]` every driver tick. One pure
function plus one driver tick line. One new result symbol:
observed_bullets.

RED decisions (pinned by this slice): (1) One pure function on
SourcePointDefenseTurretBuildState.gd,
source_point_defense_turret_live_bullets_state(live_bullets),
returning `{"observed_bullets": [...]}`, plus one driver tick
line right before the acquire block that stamps the mapped list
every tick (an empty list is still an observation -- the
N2190/N2195 present-but-empty precedent -- so the acquire runs
and a pooled target clears). (2) The mapping, field by field
(source-backed, nothing invented): id is the sprite instance
id (SourcePlacedBlockState.gd:11 precedent -- stable while the
sprite lives, so a freed sprite means the bullet left the live
list and the N2239 id-absent invalidation drops the target);
x/y are sprite.position
(SourceBulletTargetRuntimeState.gd:20-25 precedent; an invalid
sprite drops the bullet, the simulate_bullets pending_removals
precedent); damage is the live dict's damage; team is read ONLY
when the live dict carries it -- a team-less bullet is EXCLUDED,
never defaulted to -1 (the acquire reads
`int(bullet.get("team", -1))`, and -1 != team_id for every real
team -- derelict is 0, SourceBlockGeometry.gd:159 -- so
defaulting -1 would misclassify own-team turret fire, the only
live bullets today, as enemy); hittable defaults to the
BulletType class default true (BulletType.java:143, `public
boolean hittable = true;`; the damageLightning / fireball
`hittable = false` types wait for a per-type lookup slice);
has_type is true because every live bullet was created with
`bullet.type = this` (SourceBulletTypeCreateCoreState.gd
bullet_identity_state typeSource). (3) The spawn-side team
stamp (turret-sim -> bridge -> runtime chain carries no team
today) is DEFERRED to its own slice; this slice maps only
what the live dict carries. (4) No acquire / aim / shoot /
should-consume / cooling change (N2239-N2241 untouched). (5)
The driver line reads the live list with the 1-arg
`game.get("bullets")` (the SourceBulletSpawnState.gd:38
precedent) and guards the Array cast inline -- the RED test
pinned `game.get("bullets", [])`, but Object.get() takes at
most 1 argument in Godot 4.6 (verified against the 4.6.2
binary), so that line could never parse; the test was fixed
in GREEN (the N2239/N2241 RED-test-fix precedent). Shard
note: PointDefenseTurret.java lives under
/world/blocks/defense/turrets/ and matches the defense shard
selection (the N2239/N2240/N2241 precedent), so the GREEN
register run records the defense shard count change. SSOT
expected after GREEN: symbols +1, Done +1, contracts +1,
schema +2, 11556/1691/1622/3035 -> 11557/1692/1623/3037.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_point_defense_turret_should_consume_cooling import DEFERRED as N2241_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
BULLET_COMP = 'core/src/mindustry/entities/comp/BulletComp.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
GROUP_DEFS = 'core/src/mindustry/entities/GroupDefs.java'
PROOF = '/root/C07PointDefenseTurretLiveBulletsWiringProof'
WIRING_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_live_bullets_state'
TESTS = ['test_c07_point_defense_turret_live_bullets_wiring_registration', 'test_all_c07_point_defense_turret_live_bullets_wiring_input_evidence_is_exact', 'test_point_defense_turret_live_bullets_state', 'test_reference_graph_and_actual_c07_point_defense_turret_live_bullets_wiring']
# The 5 slice sources the N2242 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files. Groups.java is build-generated from
# GroupDefs.java (@GroupDef(value = Bulletc.class, spatial =
# true, collide = true) G bullet;, GroupDefs.java:9), so it
# never exists on disk: the on-disk source is GroupDefs.java.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/entities/comp/BulletComp.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/GroupDefs.java',
]
EXACT_EXPRS = ['target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'if(target != null && !target.isAdded()){', 'target = null;', 'public @Nullable Bullet target;', '@Import Team team;', 'public boolean hittable = true;', 'range = 180f;', '@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;']

# DEFERRED is carried from the N2241 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the coolant live wiring + draw / write-read / setStats /
# icons + the real effect/sound spawn, and the TractorBeam half
# is untouched. Two N2242 entries are appended: the Windows-proof
# debt and the spawn-side team stamp, which is the next slice.
DEFERRED = list(N2241_DEFERRED) + [
    'PointDefenseTurret live bullets wiring Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2241: the N2242 proof runs headless on Linux here and waits for a Windows Godot run.',
    'PointDefenseTurret spawn-side team stamp -- live bullets carry no team until spawn_turret_bullet_from_state + the turret-sim -> bridge -> runtime chain stamps the firing turret team; until then the N2242 wiring excludes team-less bullets and should_consume stays false in live play.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    query = 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));'
    wiring_inputs = {
        'live_bullets': a('Array', query, 'The live bullets the wiring maps (PointDefenseTurret.java:66 -- Java reads the live bullet group every retarget; the port reads the live `game["bullets"]` dicts, whose only writer is SourceBulletSpawnState.gd spawn_turret_bullet_from_state: sprite / target / velocity / speed / damage / hitSize / lifetime_remaining, no team / hittable / id / type).'),
    }
    wiring_outputs = {
        'observed_bullets': a('Array', query, 'The observed bullets the N2239 acquire consumes (PointDefenseTurret.java:66 -- one observed dict per live bullet: id from sprite.get_instance_id(), x/y from sprite.position, damage from the live dict, team only when the live dict carries it (team-less bullets excluded, never defaulted to -1), hittable defaulting to the BulletType class default true, has_type true).'),
    }
    return wiring_inputs, wiring_outputs


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
    wiring_inputs, wiring_outputs = definitions()

    entries = [
        ('N2242', WIRING_OWNER, 'source_point_defense_turret_live_bullets_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.updateTile()', wiring_inputs, wiring_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret live-bullets wiring from PointDefenseTurret.java / BulletComp.java / BulletType.java / Blocks.java / GroupDefs.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret live-bullets wiring from PointDefenseTurret.java / BulletComp.java / BulletType.java / Blocks.java / GroupDefs.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: observed_bullets.
    by_slice['N2242'] = [
        'source_point_defense_turret_live_bullets_state_result.observed_bullets',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2242', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', java_method='PointDefenseBuild.updateTile()', godot_owner=WIRING_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2242'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
