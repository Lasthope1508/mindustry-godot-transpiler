"""Register the PointDefenseTurret bullet hitSize + live bullet removal (N2247).

N2239 acquired targets by the bullet POINT against the Java
intersect rect and N2242 mapped the live bullets to observed
dicts dropping the live dict's hitSize -- but Java's intersect
tests the bullet HITBOX (`target = Groups.bullet.intersect(x -
range, y - range, range*2, range*2).min(b -> b.team != team &&
b.type().hittable, b -> b.dst2(this));` --
PointDefenseTurret.java:66; BulletComp implements Hitboxc,
`abstract class BulletComp implements Timedc, Damagec, Hitboxc,
Teamc, Posc, Drawc, Shielderc, Ownerc, Bulletc, Timerc,
Senseable, Settable{` -- BulletComp.java:28; hitSize is the
BulletType hitbox size, `public float hitSize = 4;` --
BulletType.java:43, stamped onto the live bullet at spawn,
`bullet.hitSize = hitSize;` -- BulletType.java:970), so a bullet
whose centre sits just outside the rect but whose hitbox
overlaps it IS inside the intersect. And N2240 nulled the frame
target on a lethal shot but left the live dict in
`game["bullets"]` forever, so the sim kept moving a dead bullet
and the next tick's acquire could re-acquire it by id -- Java
removes the bullet itself (`if(target.damage() >
realDamage){` / `target.remove();` --
PointDefenseTurret.java:85-88, in the else branch), which is
what makes the next tick's pooled check true (`if(target !=
null && !target.isAdded()){` / `target = null;` --
PointDefenseTurret.java:69-71).

RED decisions (resolved at RED): (1) One new pure function on
the same family file N2240-N2246 built:
source_point_defense_turret_bullet_removal_state(live_bullets,
removed_id) returning remaining_bullets (the live list minus
the removed id) and removed (whether anything was dropped);
identity keys on the sprite instance id (the N2242 precedent --
the observed dict's id IS the sprite instance id). The hitSize
fix is two lines on existing functions: the N2242 wiring maps
`"hit_size": float(bullet.get("hitSize", 4.0))` onto the
observed dicts (the BulletType 4f default when the live dict
carries no hitSize) and the N2239 acquire tests the hitbox
overlap `|bx - x| <= range + hit_size/2`, `|by - y| <= range +
hit_size/2`, with the min-dst2 pick still on the bullet centre
(Java `b.dst2(this)` is centre distance,
PointDefenseTurret.java:67). (2) One driver tick line: on the
lethally-shot tick (target_removed) the driver calls the
removal pure function and writes the filtered list back to the
live list (game.set("bullets", ...), the
SourceBulletTargetRuntimeState.gd game.set precedent); a
damaged (non-lethal) target keeps its dict and every other
bullet is untouched. (3) The live coolant efficiency / subtract
liquid / coolEffect half the N2246 handoff's Next line grouped
under N2247 is NOT this slice: the frame carries no liquids
dict and the catalog consumeCoolant key is unverified, so it
waits for its own slice (N2248) after that plumbing is
verified. Two new result symbols: remaining_bullets / removed.
SSOT expected after GREEN: symbols +2, Done +1, contracts +1,
schema +2; defense shard slices 175 -> 176.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_point_defense_turret_setstats_icons import DEFERRED as N2246_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
BULLET_COMP = 'core/src/mindustry/entities/comp/BulletComp.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
GROUP_DEFS = 'core/src/mindustry/entities/GroupDefs.java'
PROOF = '/root/C07PointDefenseTurretHitSizeRemovalProof'
REMOVAL_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_bullet_removal_state'
TESTS = ['test_c07_point_defense_turret_hit_size_removal_registration', 'test_all_c07_point_defense_turret_hit_size_removal_input_evidence_is_exact', 'test_point_defense_turret_hit_size_removal', 'test_reference_graph_and_actual_c07_point_defense_turret_hit_size_removal']
# The 5 slice sources the N2247 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/entities/comp/BulletComp.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/GroupDefs.java',
]
EXACT_EXPRS = ['target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'if(target != null && !target.isAdded()){', 'if(target.damage() > realDamage){', 'target.remove();', 'public float hitSize = 4;', 'bullet.hitSize = hitSize;', 'abstract class BulletComp implements Timedc, Damagec, Hitboxc, Teamc, Posc, Drawc, Shielderc, Ownerc, Bulletc, Timerc, Senseable, Settable{', 'range = 180f;', 'segment = new PointDefenseTurret("segment"){{', '@GroupDef(value = Bulletc.class, spatial = true, collide = true) G bullet;']

# DEFERRED is carried from the N2246 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the live coolant wiring + the real effect/sound spawn, and the
# TractorBeam half is untouched. Only the N2247 Windows-proof
# debt entry is appended.
DEFERRED = list(N2246_DEFERRED) + [
    'PointDefenseTurret bullet hitSize + live bullet removal Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2246: the N2247 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    removal_inputs = {
        'live_bullets': a('Array', 'target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));', 'The live bullet list Java reads every retarget (PointDefenseTurret.java:66, `target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));`): the port passes `game["bullets"]`, the live dicts the N2242 wiring maps; the driver writes the filtered list back on the lethally-shot tick.'),
        'removed_id': a('int', 'if(target != null && !target.isAdded()){', 'The id of the lethally shot bullet to drop, the sprite instance id (the N2242 precedent -- the observed dict\'s id IS the sprite instance id); Java identifies the bullet by the live reference and the pooled check (`if(target != null && !target.isAdded()){`, PointDefenseTurret.java:69) is what the removal makes true on the next tick. A target with no id cannot be re-identified (the N2239 precedent), so removed_id -1 matches nothing.'),
    }
    removal_outputs = {
        'remaining_bullets': a('Array', 'target.remove();', 'The live list minus the removed bullet (PointDefenseTurret.java:88, `target.remove();`, in the else branch of `if(target.damage() > realDamage){`, PointDefenseTurret.java:85): the driver writes this back to `game["bullets"]`, so the sim stops moving the dead bullet and the next tick\'s acquire cannot re-acquire it by id. A damaged (non-lethal) target is never passed here -- the driver only calls this when target_removed is true.'),
        'removed': a('bool', 'if(target.damage() > realDamage){', 'Whether the removed id was found in the live list: true when the lethally shot bullet was dropped, false when the id is absent (PointDefenseTurret.java:85, `if(target.damage() > realDamage){`, the lethal branch that triggers the removal; the list is unchanged then).'),
    }
    return removal_inputs, removal_outputs


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
    removal_inputs, removal_outputs = definitions()

    entries = [
        ('N2247', REMOVAL_OWNER, 'source_point_defense_turret_bullet_removal_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret', 'PointDefenseBuild.updateTile()', removal_inputs, removal_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret bullet hitSize + live bullet removal state from PointDefenseTurret.java + BulletComp.java + BulletType.java + Blocks.java + GroupDefs.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret bullet hitSize + live bullet removal state from PointDefenseTurret.java + BulletComp.java + BulletType.java + Blocks.java + GroupDefs.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: remaining_bullets, removed.
    by_slice['N2247'] = [
        'source_point_defense_turret_bullet_removal_state_result.remaining_bullets',
        'source_point_defense_turret_bullet_removal_state_result.removed',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2247', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret', java_method='PointDefenseBuild.updateTile()', godot_owner=REMOVAL_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2247'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
