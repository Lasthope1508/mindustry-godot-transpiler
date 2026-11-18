"""Register the TurretBuild.fogRadius() accessor (N2268).

TurretBuild overrides fogRadius (Turret.java:420-423, `public
float fogRadius(){` / `return (range + (hasAmmo() ?
peekAmmo().rangeChange : 0f)) / tilesize *
fogRadiusMultiplier;`). The range is the BaseTurret def
range (BaseTurret.java:21, `public float range = 80f;`)
and the multiplier is the BaseTurret def
fogRadiusMultiplier (BaseTurret.java:24, `public float
fogRadiusMultiplier = 1f;`); tilesize is the world
constant (Vars.java:135, `public static final int
tilesize = 8;`); the ammo range change is the peeked
bullet's rangeChange (BulletType.java:157, `public float
rangeChange = 0f;`, default 0f). Unlike range()
(Turret.java:342-345, `public float range(){` /
`return range + peekAmmo().rangeChange;`), which adds
rangeChange whenever peekAmmo() is non-null
(Turret.java:693, `public @Nullable BulletType
peekAmmo(){`), fogRadius() adds it only when hasAmmo()
(Turret.java:698, `public boolean hasAmmo(){`) -- the
stricter gate (ammo present, enough for a shot,
canConsume -- Turret.java:698-712, `return ammo.size > 0
&& (ammo.peek().amount >= ammoPerShot || cheating());`)
-- so the pure function takes has_ammo as an explicit
bool, not a peeked bullet. The accessor is what the fog
system reads (FogControl.java:161,
`Mathf.round(build.fogRadius())`; FogRenderer.java:68,
`build.fogRadius() * tilesize`); the fog system itself
waits for its own slice.

RED decisions (resolved at RED): (1) One pure function
on SourceTurretBuildState.gd next to the N2253
shouldConsume / N2254 progress / N2255 sense rows,
following the N2249 Radar fogRadius() accessor precedent
exactly: (frame, range, has_ammo, ammo_range_change,
tilesize, fog_radius_multiplier) and one result key
`fog_radius`. (2) All live values arrive as explicit
params (the N2188 precedent) -- the tick frame
tracks only cheating / enabled / power_status /
efficiency today. (3) Ammo absent preserves the base
range: has_ammo false adds 0f (the N2253/N2254
absent-preserves precedent). (4) NO driver line:
fogRadius() is a load-time accessor the fog system
reads, not a per-tick write (the N2249 precedent); the
fog-system callers wait for their own slices. One new
result symbol: fog_radius. Slice sources: Turret.java +
BaseTurret.java + Vars.java + BulletType.java +
FogControl.java + FogRenderer.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_sense import DEFERRED as N2237_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
VARS = 'core/src/mindustry/Vars.java'
BULLET_TYPE = 'core/src/mindustry/entities/bullet/BulletType.java'
FOG_CONTROL = 'core/src/mindustry/game/FogControl.java'
FOG_RENDERER = 'core/src/mindustry/graphics/FogRenderer.java'
PROOF = '/root/C07TurretFogRadiusProof'
FOG_RADIUS_OWNER = 'SourceTurretBuildState.source_turret_fog_radius_state'
TESTS = ['test_c07_turret_fog_radius_registration', 'test_all_c07_turret_fog_radius_input_evidence_is_exact', 'test_turret_fog_radius_state', 'test_reference_graph_and_actual_c07_turret_fog_radius']
# The 6 slice sources the N2268 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/entities/bullet/BulletType.java',
    'core/src/mindustry/game/FogControl.java',
    'core/src/mindustry/graphics/FogRenderer.java',
]
EXACT_EXPRS = [
    'public float fogRadius(){',
    'return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;',
    'public float range = 80f;',
    'public float fogRadiusMultiplier = 1f;',
    'public static final int tilesize = 8;',
    'public float rangeChange = 0f;',
    'public boolean hasAmmo(){',
    'public @Nullable BulletType peekAmmo(){',
    'public float range(){',
    'return range + peekAmmo().rangeChange;',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public class BaseTurret extends Block{',
    'Mathf.round(build.fogRadius())',
    'build.fogRadius() * tilesize',
]

# DEFERRED is carried from the N2255 register script via import --
# never retyped. Nothing in it closes here: fogRadius() was never
# a deferred entry of the Turret chain. One entry is added: the
# N2268 Windows Godot proof debt (GOAL.md section 5).
DEFERRED = N2237_DEFERRED + [
    'Turret fogRadius() Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2268 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    fog_radius_inputs = {
        'frame': a('Dictionary', 'public float fogRadius(){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'range': a('float', 'public float range = 80f;', 'The def range in world pixels: BaseTurret.range (BaseTurret.java:21), the base of the fogRadius() formula (Turret.java:421, `return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;`); passed explicitly because it is per-def static state, not a live frame key.', source=BASE_TURRET),
        'has_ammo': a('bool', 'public boolean hasAmmo(){', 'Whether the turret has usable ammo: the TurretBuild.hasAmmo() gate (Turret.java:698-712, `return ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating());` after the ammo-swap and canConsume gates); passed explicitly because the tick frame tracks no ammo state yet. False adds 0f (the N2253/N2254 absent-preserves precedent).'),
        'ammo_range_change': a('float', 'public float rangeChange = 0f;', 'The peeked ammo bullet range change: BulletType.rangeChange (BulletType.java:157), default 0f; read by the fogRadius() formula through peekAmmo() (Turret.java:693, `public @Nullable BulletType peekAmmo(){`) only when hasAmmo() holds; passed explicitly because the tick frame tracks no ammo state yet.', source=BULLET_TYPE),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize in pixels (Vars.java:135, `public static final int tilesize = 8;`); passed explicitly (the N2223 sense precedent) so the formula divides by the caller-supplied world constant.', source=VARS),
        'fog_radius_multiplier': a('float', 'public float fogRadiusMultiplier = 1f;', 'The def fog-radius multiplier: BaseTurret.fogRadiusMultiplier (BaseTurret.java:24), the scale of the fogRadius() formula (Turret.java:421); passed explicitly because it is per-def static state, not a live frame key.', source=BASE_TURRET),
    }
    fog_radius_outputs = {
        'fog_radius': a('float', 'return (range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier;', 'The live fog radius in tiles: (range + rangeChange when hasAmmo, else range) / tilesize * fogRadiusMultiplier (Turret.java:420-421); read by the fog system (FogControl.java:161, `Mathf.round(build.fogRadius())`; FogRenderer.java:68, `build.fogRadius() * tilesize`).'),
    }
    return fog_radius_inputs, fog_radius_outputs


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
    fog_radius_inputs, fog_radius_outputs = definitions()

    entries = [
        ('N2268', FOG_RADIUS_OWNER, 'source_turret_fog_radius_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.fogRadius()', fog_radius_inputs, fog_radius_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.fogRadius() state from Turret.java + BaseTurret.java + Vars.java + BulletType.java + FogControl.java + FogRenderer.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.fogRadius() state from Turret.java + BaseTurret.java + Vars.java + BulletType.java + FogControl.java + FogRenderer.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: fog_radius.
    by_slice['N2268'] = [
        'source_turret_fog_radius_state_result.fog_radius',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2268', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.fogRadius()', godot_owner=FOG_RADIUS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2268'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
