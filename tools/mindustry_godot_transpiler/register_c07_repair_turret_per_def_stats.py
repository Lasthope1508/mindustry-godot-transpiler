"""Register the RepairTurret per-def stat rows (N2237).

The per-def stat rows (Blocks.java:6386-6406 + class defaults
RepairTurret.java:32-37): repair-point repairSpeed 0.45f
(`repairSpeed = 0.45f;`, Blocks.java:6388), repairRadius 60f
(`repairRadius = 60f;`, Blocks.java:6389), beamWidth 0.73f
(`beamWidth = 0.73f;`, Blocks.java:6390), pulseRadius 5f
(`pulseRadius = 5f;`, Blocks.java:6392), length the 5f class
default (`public float length = 5f;`, RepairTurret.java:35 --
no override); repair-turret length 6f (`length = 6f;`,
Blocks.java:6399), repairSpeed 3f (`repairSpeed = 3f;`,
Blocks.java:6400), repairRadius 145f (`repairRadius = 145f;`,
Blocks.java:6401), beamWidth 1.1f (`beamWidth = 1.1f;`,
Blocks.java:6403), pulseRadius 6.1f (`pulseRadius = 6.1f;`,
Blocks.java:6404); class defaults repairSpeed 0.3f
(`public float repairSpeed = 0.3f;`, RepairTurret.java:33),
repairRadius 50f (`public float repairRadius = 50f;`,
RepairTurret.java:32), length 5f (RepairTurret.java:35),
beamWidth 1f (`public float beamWidth = 1f;`,
RepairTurret.java:36), pulseRadius 6f (`public float
pulseRadius = 6f;`, RepairTurret.java:37). The two defs are
`repairPoint = new RepairTurret("repair-point"){{`
(Blocks.java:6386) and `repairTurret = new
RepairTurret("repair-turret"){{` (Blocks.java:6397), of the
block `public class RepairTurret extends Block{`
(RepairTurret.java:25).

RED decisions (resolved at RED): (1) One pure function on
the same family file, taking the block id explicitly (per-def
static state, not a live frame key -- the N2212 / N2220 /
N2235 precedent) and returning all five rows, reusing the
four existing per-def helpers (`_repair_speed_for_block_id`,
`_repair_radius_for_block_id`, `_beam_length_for_block_id`,
`_beam_width_for_block_id`) plus a new
`_pulse_radius_for_block_id` helper -- no duplicated
constants. (2) There is NO driver tick line: a static read
(the N2233 range / N2235 ambient volume precedent). (3)
The deferred pool entry "RepairTurret per-def stat rows" is
dropped here and replaced by the N2237 Windows-proof debt
entry; the RepairTower per-def stat rows entry survives
(different family). (4) powerUse (1f/5f) is NOT in this
slice: it lives in the catalog consumePower /
consumePowerCond. (5) Suppression live + targets live list
stay BLOCKED: no `frame["units"] =` stamp exists anywhere
in src/game, and no frame stamps `heal_suppressed` /
`heal_suppression_time`. Five new result symbols:
repair_speed, repair_radius, length, beam_width,
pulse_radius. SSOT expected after GREEN: symbols +5, Done
+1, contracts +1, schema +2, 11532/1686/1617/3025 ->
11537/1687/1618/3027. Slice sources: RepairTurret.java +
Blocks.java. No shard change: RepairTurret.java matches no
shard (the N2213-N2236 precedent).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_bind_block_id import DEFERRED as N2236_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07RepairTurretPerDefStatsProof'
STATS_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_per_def_stats_state'
TESTS = ['test_c07_repair_turret_per_def_stats_registration', 'test_all_c07_repair_turret_per_def_stats_input_evidence_is_exact', 'test_repair_turret_per_def_stats_state', 'test_reference_graph_and_actual_c07_repair_turret_per_def_stats']
# The 2 slice sources the N2237 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/content/Blocks.java',
]
EXACT_EXPRS = ['public float repairRadius = 50f;', 'public float repairSpeed = 0.3f;', 'public float length = 5f;', 'public float beamWidth = 1f;', 'public float pulseRadius = 6f;', 'repairSpeed = 0.45f;', 'repairRadius = 60f;', 'beamWidth = 0.73f;', 'pulseRadius = 5f;', 'length = 6f;', 'repairSpeed = 3f;', 'repairRadius = 145f;', 'beamWidth = 1.1f;', 'pulseRadius = 6.1f;', 'public class RepairTurret extends Block{', 'repairPoint = new RepairTurret("repair-point"){{', 'repairTurret = new RepairTurret("repair-turret"){{']

# DEFERRED is carried from the N2236 register script via import --
# never retyped. The lumped entry "RepairTurret per-def stat
# rows" is DROPPED here -- the verification slice lands here --
# and replaced by the new entry below, which keeps the
# Windows-proof debt; every other entry is carried verbatim
# (the N2211/N2228 lesson -- never retype the pool). The
# filter drops only the entry carrying the exact RepairTurret
# phrase, so the RepairTower per-def stat rows entry survives
# untouched.
DEFERRED = [e for e in N2236_DEFERRED if 'RepairTurret per-def stat rows' not in e] + [
    'RepairTurret per-def stat rows Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2236: the N2237 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    stats_inputs = {
        'block_id': a('String', 'repairPoint = new RepairTurret("repair-point"){{', 'The block id (Blocks.java:6386, `repairPoint = new RepairTurret("repair-point"){{` -- repair-turret, Blocks.java:6397, `repairTurret = new RepairTurret("repair-turret"){{`): the per-def identity whose catalog stat overrides the resolver returns, passed explicitly because it is per-def static state, not a live frame key (the N2212 / N2220 / N2235 per-def-param precedent).', source=BLOCKS),
    }
    stats_outputs = {
        'repair_speed': a('float', 'repairSpeed = 0.45f;', 'The per-def repair speed (repair-point 0.45f, Blocks.java:6388, `repairSpeed = 0.45f;`; repair-turret 3f, Blocks.java:6400, `repairSpeed = 3f;`; class default 0.3f, RepairTurret.java:33, `public float repairSpeed = 0.3f;`): the heal rate RepairPointBuild.updateTile() heals with (RepairTurret.java:207, `target.heal(repairSpeed * strength * edelta() * multiplier);`).', source=BLOCKS),
        'repair_radius': a('float', 'repairRadius = 60f;', 'The per-def repair radius (repair-point 60f, Blocks.java:6389, `repairRadius = 60f;`; repair-turret 145f, Blocks.java:6401, `repairRadius = 145f;`; class default 50f, RepairTurret.java:32, `public float repairRadius = 50f;`): the range RepairPointBuild.range() returns (RepairTurret.java:232, `return repairRadius;`).', source=BLOCKS),
        'length': a('float', 'length = 6f;', 'The per-def beam length (repair-turret 6f, Blocks.java:6399, `length = 6f;`; repair-point the 5f class default, RepairTurret.java:35, `public float length = 5f;`): the beam origin offset drawBeam() uses (RepairTurret.java:115-116, `originX = x + Angles.trnsx(rotation, length);`).', source=BLOCKS),
        'beam_width': a('float', 'beamWidth = 0.73f;', 'The per-def beam width (repair-point 0.73f, Blocks.java:6390, `beamWidth = 0.73f;`; repair-turret 1.1f, Blocks.java:6403, `beamWidth = 1.1f;`; class default 1f, RepairTurret.java:36, `public float beamWidth = 1f;`): the laser width drawBeam() draws (RepairTurret.java:145, `Drawf.laser(laser, laserEnd, originX, originY, lastEnd.x, lastEnd.y, strength * beamWidth);`).', source=BLOCKS),
        'pulse_radius': a('float', 'pulseRadius = 5f;', 'The per-def pulse radius (repair-point 5f, Blocks.java:6392, `pulseRadius = 5f;`; repair-turret 6.1f, Blocks.java:6404, `pulseRadius = 6.1f;`; class default 6f, RepairTurret.java:37, `public float pulseRadius = 6f;`): the pulse-circle radius drawBeam() draws (RepairTurret.java:142, `Lines.circle(lastEnd.x, lastEnd.y, 1f + f * pulseRadius);`) -- it feeds only the deferred pulse circle, so this row pins the value, not the circle.', source=BLOCKS),
    }
    return stats_inputs, stats_outputs


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
    stats_inputs, stats_outputs = definitions()

    entries = [
        ('N2237', STATS_OWNER, 'source_repair_turret_per_def_stats_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.updateTile()/RepairPointBuild.draw()/drawBeam()/RepairPointBuild.range()', stats_inputs, stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret per-def stat rows from RepairTurret.java + Blocks.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret per-def stat rows from RepairTurret.java + Blocks.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: repair_speed, repair_radius,
    # length, beam_width, pulse_radius.
    by_slice['N2237'] = [
        'source_repair_turret_per_def_stats_state_result.repair_speed',
        'source_repair_turret_per_def_stats_state_result.repair_radius',
        'source_repair_turret_per_def_stats_state_result.length',
        'source_repair_turret_per_def_stats_state_result.beam_width',
        'source_repair_turret_per_def_stats_state_result.pulse_radius',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2237', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.updateTile()/RepairPointBuild.draw()/drawBeam()/RepairPointBuild.range()', godot_owner=STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2237'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
