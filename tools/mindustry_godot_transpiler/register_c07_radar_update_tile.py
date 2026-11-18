"""Register the Radar updateTile advance (N2274).

RadarBuild.updateTile advances the radar's discovery
state every tick (Radar.java:60, `public void
updateTile(){`): `smoothEfficiency =
Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`
(Radar.java:61) lerps the smoothed efficiency toward
the folded efficiency; `if(Math.abs(fogRadius() -
lastRadius) >= 0.5f){` (Radar.java:63) with
`Vars.fogControl.forceUpdate(team, this);`
(Radar.java:64) and `lastRadius = fogRadius();`
(Radar.java:65) forces a fog update when the live fog
radius moved by half a tile or more; `progress +=
edelta() / discoveryTime;` (Radar.java:68) with
`progress = Mathf.clamp(progress);` (Radar.java:69)
advances discovery by edelta() over the discovery
time, clamped to [0, 1]; `totalProgress += efficiency
* edelta();` (Radar.java:71) tracks the
efficiency-weighted tick count. edelta() is efficiency
* delta (BuildingComp.java:1927-1929, `public float
edelta(){` with `return efficiency * delta();`, and
delta() is `Time.delta * timeScale`,
BuildingComp.java:1922-1923 -- timeScale is 1 by
default and the port passes the raw tick seconds, the
N2190 driver convention). The fog radius read is
fogRadius() (Radar.java:55, `public float fogRadius(){`
with `return fogRadius * progress * smoothEfficiency;`,
Radar.java:56): the def fogRadius is 34
(Blocks.java:1991, `fogRadius = 34;`), overriding the
class default 10 (Radar.java:33, `fogRadius = 10;`).
The discovery time is 600f (Radar.java:18, `public
float discoveryTime = 60f * 10f;`).

RED decisions (resolved at RED): (1) One pure
function on the same family file N2173 built,
following the N2207 LaunchPad updateTile precedent
exactly: (frame, delta, discovery_time, fog_radius)
and the driver stamps every returned key on the
frame each tick (the N2204 ShieldWall / N2207
LaunchPad precedent). (2) The frame carries
`smooth_efficiency` (absent -> 1.0, the Java field
init `public float smoothEfficiency = 1f;`,
Radar.java:51), `progress` (absent -> 0.0, `public
float progress;`, Radar.java:49), `last_radius`
(absent -> 0.0, `public float lastRadius = 0f;`,
Radar.java:50), `total_progress` (absent -> 0.0,
`public float totalProgress;`, Radar.java:52) and
`efficiency` (absent -> 0.0, the transient field
default `transient float efficiency;`,
BuildingComp.java:85, the N2192/N2204 precedent).
(3) The fog-radius check uses the NEW smoothed
efficiency and the OLD progress (Java order: the
lerp :61 runs before the check :63-66, the progress
advance :68 runs after), so a frame whose smooth
efficiency just moved can flip the force decision.
(4) `force_update` is the observable flag: the
actual FogControl call (`public void
forceUpdate(Team team, Building build){`,
FogControl.java:177) waits for its own fog slice --
the port has no fog system to call into, and the
flag is the signal that slice will consume. (5)
The driver tick line runs for every ticked radar
AFTER the consumption block (updateConsumption runs
BEFORE updateTile in Java), with efficiency zeroed
first when disabled (`if(!enabled){` with
`potentialEfficiency = efficiency = optionalEfficiency
= 0f;`, BuildingComp.java:1954-1955) -- a disabled
radar never advances (the N2204 precedent). (6)
discovery_time and fog_radius are explicit per-def
params (the N2212 acquire / N2220 draw-place
per-def-param precedent -- the catalog carries
neither); the driver passes the radar-def values
600.0 and 34.0. Six new result symbols:
smooth_efficiency, fog_radius, force_update,
last_radius, progress, total_progress. Slice
sources: Radar.java + BuildingComp.java + Blocks.java
+ FogControl.java.
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
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
FOG_CONTROL = 'core/src/mindustry/game/FogControl.java'
PROOF = '/root/C07RadarUpdateTileProof'
UPDATE_TILE_OWNER = 'SourceRadarBuildState.source_radar_update_tile_state'
TESTS = ['test_c07_radar_update_tile_registration', 'test_all_c07_radar_update_tile_input_evidence_is_exact', 'test_radar_update_tile_state', 'test_reference_graph_and_actual_c07_radar_update_tile']
# The 4 slice sources the N2274 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/Radar.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/game/FogControl.java',
]
EXACT_EXPRS = ['public void updateTile(){', 'smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);', 'if(Math.abs(fogRadius() - lastRadius) >= 0.5f){', 'Vars.fogControl.forceUpdate(team, this);', 'lastRadius = fogRadius();', 'progress += edelta() / discoveryTime;', 'progress = Mathf.clamp(progress);', 'totalProgress += efficiency * edelta();', 'public float fogRadius(){', 'return fogRadius * progress * smoothEfficiency;', 'public float discoveryTime = 60f * 10f;', 'fogRadius = 34;', 'fogRadius = 10;', 'public float edelta(){', 'return efficiency * delta();', 'public float delta(){', 'return Time.delta * timeScale;', 'transient float efficiency;', 'potentialEfficiency = efficiency = optionalEfficiency = 0f;', 'public float progress;', 'public float lastRadius = 0f;', 'public float smoothEfficiency = 1f;', 'public float totalProgress;', 'public class Radar extends Block{', 'public class RadarBuild extends Building{', 'public void forceUpdate(Team team, Building build){']

# DEFERRED is carried from the N2227 register script via import --
# never retyped. The N2227 script's DEFERRED is a computed
# expression (list comprehension over the N2226 import + [...]),
# NOT a plain list literal, so the N2218-style ast.literal_eval
# carry cannot recover it; the import recovers the runtime value
# verbatim. Round 3: the N2247 (ex-N2229) senseObject(config)
# register is DROPPED -- remote N2234 covers that leg -- so the
# chain skips it and imports N2227 directly. One carried entry
# is DROPPED here, not carried: the
# Radar updateTile advance entry -- N2274 IS the updateTile
# advance slice, so carrying it would leave a stale "waits for
# its own slice" row for done work. The fogRadius() accessor
# half stays deferred (N2249 owns fogRadius() itself); only the
# forceUpdate check inside updateTile is done here.
DEFERRED = [e for e in N2227_DEFERRED if 'Radar updateTile advance' not in e] + [
    'Radar updateTile advance Windows Godot proof -- debt in GOAL.md section 5, same as N2173/N2227: the N2274 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=RADAR, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_tile_inputs = {
        'frame': a('Dictionary', 'public void updateTile(){', 'The radar frame (RadarBuild.updateTile, Radar.java:60): carries smooth_efficiency (Java init 1.0), progress (init 0.0), last_radius (init 0.0), total_progress (init 0.0) and the folded efficiency (transient default 0.0, BuildingComp.java:85).', source=RADAR),
        'delta': a('float', 'return Time.delta * timeScale;', 'The tick seconds: delta() is Time.delta * timeScale (BuildingComp.java:1922-1923); timeScale is 1 by default and the port passes the raw tick seconds (the N2190 driver convention). edelta() is efficiency * delta (BuildingComp.java:1927-1929).', source=BUILDING_COMP),
        'discovery_time': a('float', 'public float discoveryTime = 60f * 10f;', 'The per-def discovery time, 600f for the radar def (Radar.java:18); passed explicitly because the catalog carries no discoveryTime (the N2212 per-def-param precedent).', source=RADAR),
        'fog_radius': a('float', 'fogRadius = 34;', 'The per-def fog radius, 34 for the radar def (Blocks.java:1991), overriding the class default 10 (Radar.java:33); passed explicitly because the catalog carries no fogRadius (the N2212 per-def-param precedent).', source=BLOCKS),
    }
    update_tile_outputs = {
        'smooth_efficiency': a('float', 'smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);', 'The smoothed efficiency after the tick: lerpDelta toward the folded efficiency at 0.05f (Radar.java:61), via the port SourceMathState.source_lerp_delta helper (arc Mathf.lerpDelta, clamp(progress * Time.delta)).', source=RADAR),
        'fog_radius': a('float', 'return fogRadius * progress * smoothEfficiency;', 'The live fog radius this tick: fogRadius() (Radar.java:55-56), fogRadius * progress * smoothEfficiency, computed with the NEW smooth efficiency and the OLD progress (Java order :61 before :63-66, advance :68 after).', source=RADAR),
        'force_update': a('bool', 'Vars.fogControl.forceUpdate(team, this);', 'Whether the fog must be force-updated this tick: true when |fogRadius() - lastRadius| >= 0.5f (Radar.java:63-64); the observable flag -- the actual FogControl.forceUpdate call (FogControl.java:177) waits for its own fog slice.', source=RADAR),
        'last_radius': a('float', 'lastRadius = fogRadius();', 'The stored radius after the tick: fogRadius() when force_update fired, the previous lastRadius otherwise (Radar.java:63-65).', source=RADAR),
        'progress': a('float', 'progress += edelta() / discoveryTime;', 'The discovery progress after the tick: advanced by edelta() / discoveryTime and clamped to [0, 1] (Radar.java:68-69, Mathf.clamp one-arg).', source=RADAR),
        'total_progress': a('float', 'totalProgress += efficiency * edelta();', 'The efficiency-weighted tick count after the tick: advanced by efficiency * edelta() (Radar.java:71).', source=RADAR),
    }
    return update_tile_inputs, update_tile_outputs


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
    update_tile_inputs, update_tile_outputs = definitions()

    entries = [
        ('N2274', UPDATE_TILE_OWNER, 'source_radar_update_tile_state', RADAR, 'mindustry.world.blocks.defense.Radar.RadarBuild', 'RadarBuild.updateTile()', update_tile_inputs, update_tile_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Radar updateTile advance from Radar.java + BuildingComp.java + Blocks.java + FogControl.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Radar updateTile advance from Radar.java + BuildingComp.java + Blocks.java + FogControl.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: smooth_efficiency, fog_radius,
    # force_update, last_radius, progress, total_progress.
    by_slice['N2274'] = [
        'source_radar_update_tile_state_result.smooth_efficiency',
        'source_radar_update_tile_state_result.fog_radius',
        'source_radar_update_tile_state_result.force_update',
        'source_radar_update_tile_state_result.last_radius',
        'source_radar_update_tile_state_result.progress',
        'source_radar_update_tile_state_result.total_progress',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2274', dict(status='done', java_source=RADAR, java_class='mindustry.world.blocks.defense.Radar.RadarBuild', java_method='RadarBuild.updateTile()', godot_owner=UPDATE_TILE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2274'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
