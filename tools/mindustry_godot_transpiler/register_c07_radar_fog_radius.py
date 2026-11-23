"""Register the Radar fogRadius() accessor (N2321).

RadarBuild.fogRadius() (Radar.java:55, `public float
fogRadius(){` with `return fogRadius * progress *
smoothEfficiency;`, Radar.java:56) is the live fog radius:
the def fogRadius (34 for the radar def, Blocks.java:1991,
`fogRadius = 34;`, overriding the class default 10,
Radar.java:33, `fogRadius = 10;`) scaled by the discovery
progress (Radar.java:49, `public float progress;`, init
0.0) and the smoothed efficiency (Radar.java:51, `public
float smoothEfficiency = 1f;`, init 1.0). The accessor is
what updateTile reads for its force-update check
(Radar.java:63, `if(Math.abs(fogRadius() - lastRadius) >=
0.5f){`) and what drawSelect draws (Radar.java:80-82,
`Drawf.dashCircle(x, y, fogRadius() * tilesize,
Pal.accent);`).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2173 built, following the N2248
updateTile precedent: (frame, fog_radius) and the driver
passes the radar-def value 34.0 when it lands. (2) The
frame carries `progress` (absent -> 0.0, the Java field
`public float progress;`, Radar.java:49) and
`smooth_efficiency` (absent -> 1.0, the Java field init
`public float smoothEfficiency = 1f;`, Radar.java:51).
(3) fog_radius is an explicit per-def param (the N2212
per-def-param precedent -- the catalog carries no
fogRadius); the radar def passes 34.0, the class default
is 10. (4) No driver tick line lands here: this base has
no updateTile driver yet, and the accessor is the read
its callers (the updateTile force-update check, N2248;
drawSelect, its own slice) will share. (5) One new result
symbol: fog_radius. Slice sources: Radar.java +
Blocks.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_icons import DEFERRED as N2227_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
RADAR = 'core/src/mindustry/world/blocks/defense/Radar.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RadarFogRadiusProof'
FOG_RADIUS_OWNER = 'SourceRadarBuildState.source_radar_fog_radius_state'
TESTS = ['test_c07_radar_fog_radius_registration', 'test_all_c07_radar_fog_radius_input_evidence_is_exact', 'test_radar_fog_radius_state', 'test_reference_graph_and_actual_c07_radar_fog_radius']
# The 2 slice sources the N2321 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public float fogRadius(){', 'return fogRadius * progress * smoothEfficiency;', 'fogRadius = 34;', 'fogRadius = 10;', 'public float progress;', 'public float smoothEfficiency = 1f;', 'if(Math.abs(fogRadius() - lastRadius) >= 0.5f){', 'Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);', 'public class Radar extends Block{', 'public class RadarBuild extends Building{']

# DEFERRED is carried from the N2227 register script via import --
# never retyped. Round 3: the N2247 (ex-N2229) senseObject(config)
# register is DROPPED (remote N2234 covers that leg), so the chain
# skips it and imports N2227 directly. One carried entry is
# DROPPED here, not carried:
# the Radar fogRadius rows entry -- N2321 IS the fogRadius()
# accessor slice, so carrying it would leave a stale "waits for
# its own slice" row for done work. The forceUpdate half of that
# entry stays deferred through the separate Radar updateTile
# advance entry (N2248 owns the advance in its own worktree);
# the drawSelect / drawPlace / read-write / canPickup /
# discoveryTime-glow rows stay deferred in their own entries.
DEFERRED = [e for e in N2227_DEFERRED if 'Radar fogRadius rows' not in e] + [
    'Radar fogRadius() Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2320: the N2321 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    fog_radius_inputs = {
        'frame': a('Dictionary', 'public float fogRadius(){', 'The radar frame (RadarBuild.fogRadius, Radar.java:55): carries progress (Java init 0.0, Radar.java:49) and smooth_efficiency (Java init 1.0, Radar.java:51).', source=RADAR),
        'fog_radius': a('float', 'fogRadius = 34;', 'The per-def fog radius, 34 for the radar def (Blocks.java:1991), overriding the class default 10 (Radar.java:33); passed explicitly because the catalog carries no fogRadius (the N2212 per-def-param precedent).', source=BLOCKS),
    }
    fog_radius_outputs = {
        'fog_radius': a('float', 'return fogRadius * progress * smoothEfficiency;', 'The live fog radius: fogRadius() (Radar.java:55-56), fogRadius * progress * smoothEfficiency; 0.0 before discovery (progress 0.0), the full def radius at progress 1.0 and smooth efficiency 1.0.', source=RADAR),
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
        ('N2321', FOG_RADIUS_OWNER, 'source_radar_fog_radius_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.fogRadius()', fog_radius_inputs, fog_radius_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar fogRadius() accessor from Radar.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar fogRadius() accessor from Radar.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: fog_radius.
    by_slice['N2321'] = [
        'source_radar_fog_radius_state_result.fog_radius',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2321', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar.RadarBuild', java_method='RadarBuild.fogRadius()', godot_owner=FOG_RADIUS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2321'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
