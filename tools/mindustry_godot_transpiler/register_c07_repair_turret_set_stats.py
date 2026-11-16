"""Register the RepairTurret setStats() rows (N2224).

RepairTurret carries NO sense/config overrides (checked at
N2222 RED), and the sense rows are DONE at N2223 -- but the
class DOES override setStats() (RepairTurret.java:75-84,
`public void setStats(){`), the last RepairTurret-level
override with no slice. It adds two stat rows unconditionally
(`stats.add(Stat.range, repairRadius / tilesize,
StatUnit.blocks);` -- RepairTurret.java:77 -- and
`stats.add(Stat.repairSpeed, repairSpeed * 60f,
StatUnit.perSecond);` -- RepairTurret.java:78) and, only when
the def accepts coolant, replaces the booster row
(`if(acceptCoolant){` -- RepairTurret.java:80 --
`stats.remove(Stat.booster);` -- :81 --
`stats.add(Stat.booster, StatValues.speedBoosters(
Core.bundle.get("bar.strength"), coolantUse,
coolantMultiplier, true, this::consumesLiquid));` -- :82).
The booster value builder is StatValues.speedBoosters
(StatValues.java:506, `public static StatValue
speedBoosters(String unit, float amount, float speed, boolean
strength, Boolf<Liquid> filter){`).

RED decisions (resolved at RED): (1) One pure function on
the same family file N2174 / N2188 / N2209 / N2212-N2215 /
N2217 / N2219-N2223 built:
source_repair_turret_set_stats_state(repair_radius,
repair_speed, accept_coolant, coolant_use,
coolant_multiplier, tilesize) returning range_blocks
(repairRadius / tilesize), repair_speed_per_second
(repairSpeed * 60f), booster_present (acceptCoolant),
booster_coolant_use and booster_coolant_multiplier (the
speedBoosters amount/speed params). All six params are
explicit floats/bool (the N2212 acquire / N2220 draw-place /
N2223 sense per-def-param precedent -- repairRadius,
repairSpeed, acceptCoolant, coolantUse and coolantMultiplier
are per-def static state, not live frame keys: class defaults
repairRadius 50f / repairSpeed 0.3f / acceptCoolant false /
coolantUse 0.5f / coolantMultiplier 1f, RepairTurret.java:32,
:33, :40, :42, :45; repair-point 60f / 0.45f, Blocks.java:6389,
:6388; repair-turret 145f / 3f / acceptCoolant true /
coolantUse 0.16f / coolantMultiplier 1.6f, Blocks.java:6401,
:6400, :6404, :6405, :6406); tilesize is 8 (Vars.java:135,
`public static final int tilesize = 8;`). (2) There is NO
driver tick line: setStats is a stat-display read, not a
tick write (the N2220 draw-select/draw-place precedent);
the proof calls the pure function directly with per-def
params. (3) The `super.setStats();` leg (RepairTurret.java:76)
is Block-level stat work, NOT this slice: the base stats
come from Block.setStats (N1696) and are not re-emitted
here. Five new result symbols: range_blocks,
repair_speed_per_second, booster_present,
booster_coolant_use, booster_coolant_multiplier. Slice
sources: RepairTurret.java + Vars.java + Blocks.java +
StatValues.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_sense_range_rotation import DEFERRED as N2223_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
VARS = 'core/src/mindustry/Vars.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
STAT_VALUES = 'core/src/mindustry/world/meta/StatValues.java'
PROOF = '/root/C07RepairTurretSetStatsProof'
SET_STATS_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_set_stats_state'
TESTS = ['test_c07_repair_turret_set_stats_registration', 'test_all_c07_repair_turret_set_stats_input_evidence_is_exact', 'test_repair_turret_set_stats_state', 'test_reference_graph_and_actual_c07_repair_turret_set_stats']
# The 4 slice sources the N2224 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/meta/StatValues.java',
]
EXACT_EXPRS = ['public void setStats(){', 'super.setStats();', 'stats.add(Stat.range, repairRadius / tilesize, StatUnit.blocks);', 'stats.add(Stat.repairSpeed, repairSpeed * 60f, StatUnit.perSecond);', 'if(acceptCoolant){', 'stats.remove(Stat.booster);', 'stats.add(Stat.booster, StatValues.speedBoosters(Core.bundle.get("bar.strength"), coolantUse, coolantMultiplier, true, this::consumesLiquid));', 'public float repairRadius = 50f;', 'public float repairSpeed = 0.3f;', 'public boolean acceptCoolant = false;', 'public float coolantUse = 0.5f;', 'public float coolantMultiplier = 1f;', 'public static final int tilesize = 8;', 'public static StatValue speedBoosters(String unit, float amount, float speed, boolean strength, Boolf<Liquid> filter){', 'repairSpeed = 0.45f;', 'repairRadius = 60f;', 'repairSpeed = 3f;', 'repairRadius = 145f;', 'coolantUse = 0.16f;', 'coolantMultiplier = 1.6f;', 'acceptCoolant = true;', 'public class RepairTurret extends Block{']

# DEFERRED is carried from the N2223 register script via import --
# never retyped. The N2223 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2222 import), NOT a plain
# list literal, so the N2218-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2224's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
DEFERRED = list(N2223_DEFERRED) + [
    'RepairTurret setStats() Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2223: the N2224 proof runs headless on Linux here and waits for a Windows Godot run.',
    'RepairTurret display() / senseObject(config) rows -- BuildingComp.display (BuildingComp.java:1556) builds the UI Table (bars + consumption + flow) and senseObject (BuildingComp.java:2139-2146) senses `config` only when block.configSenseable() (Block.java:809-813); RepairTurret registers no configurations in its constructor, so config senses null, and display() is UI Table work, not a pure state read -- both wait for their own slices.',
    'RepairTurret RepairPointBuild.draw() body -- Draw.rect(baseRegion) + shadow + region rect at rotation - 90 (RepairTurret.java:163-175); N2219 landed only the drawBeam() static helper and its call line, the draw() rect/shadow legs wait for their own slice.',
    'RepairTurret init() updateClipRadius -- updateClipRadius(repairRadius + tilesize) (RepairTurret.java:92); the consumePowerCond leg is DONE (N2174/N2188) and the coolant-consume leg is DONE (N2209), the clip-radius leg waits for its own slice.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    set_stats_inputs = {
        'repair_radius': a('float', 'public float repairRadius = 50f;', 'The per-def repair radius in world pixels (RepairTurret.java:32, `public float repairRadius = 50f;`, the class default; repair-point 60f and repair-turret 145f, Blocks.java:6389, :6401); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).'),
        'repair_speed': a('float', 'public float repairSpeed = 0.3f;', 'The per-def repair speed in health per tick (RepairTurret.java:33, `public float repairSpeed = 0.3f;`, the class default; repair-point 0.45f and repair-turret 3f, Blocks.java:6388, :6400); passed explicitly because it is per-def static state, not a live frame key.'),
        'accept_coolant': a('bool', 'public boolean acceptCoolant = false;', 'Whether the def accepts coolant (RepairTurret.java:40, `public boolean acceptCoolant = false;`, the class default; repair-turret true, Blocks.java:6404); passed explicitly because it is per-def static state, not a live frame key.'),
        'coolant_use': a('float', 'public float coolantUse = 0.5f;', 'The per-def coolant use in liquid per tick (RepairTurret.java:42, `public float coolantUse = 0.5f;`, the class default; repair-turret 0.16f, Blocks.java:6405); passed explicitly because it is per-def static state, not a live frame key.'),
        'coolant_multiplier': a('float', 'public float coolantMultiplier = 1f;', 'The per-def coolant heal multiplier (RepairTurret.java:45, `public float coolantMultiplier = 1f;`, the class default; repair-turret 1.6f, Blocks.java:6406); passed explicitly because it is per-def static state, not a live frame key.'),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize in pixels (Vars.java:135, `public static final int tilesize = 8;`); passed explicitly (the N2220 draw-place precedent) so the range leg divides by the caller-supplied world constant.', source=VARS),
    }
    set_stats_outputs = {
        'range_blocks': a('float', 'stats.add(Stat.range, repairRadius / tilesize, StatUnit.blocks);', 'The Stat.range row value in blocks: repairRadius / tilesize (RepairTurret.java:77, `stats.add(Stat.range, repairRadius / tilesize, StatUnit.blocks);`).'),
        'repair_speed_per_second': a('float', 'stats.add(Stat.repairSpeed, repairSpeed * 60f, StatUnit.perSecond);', 'The Stat.repairSpeed row value in health per second: repairSpeed * 60f (RepairTurret.java:78, `stats.add(Stat.repairSpeed, repairSpeed * 60f, StatUnit.perSecond);`).'),
        'booster_present': a('bool', 'if(acceptCoolant){', 'Whether the Stat.booster row is added at all: only when the def accepts coolant (RepairTurret.java:80, `if(acceptCoolant){`, with `stats.remove(Stat.booster);` at :81 removing the base row first).'),
        'booster_coolant_use': a('float', 'stats.add(Stat.booster, StatValues.speedBoosters(Core.bundle.get("bar.strength"), coolantUse, coolantMultiplier, true, this::consumesLiquid));', 'The booster amount param passed to StatValues.speedBoosters: coolantUse (RepairTurret.java:82, `stats.add(Stat.booster, StatValues.speedBoosters(Core.bundle.get("bar.strength"), coolantUse, coolantMultiplier, true, this::consumesLiquid));`).'),
        'booster_coolant_multiplier': a('float', 'stats.add(Stat.booster, StatValues.speedBoosters(Core.bundle.get("bar.strength"), coolantUse, coolantMultiplier, true, this::consumesLiquid));', 'The booster speed param passed to StatValues.speedBoosters: coolantMultiplier (RepairTurret.java:82, same line as booster_coolant_use).'),
    }
    return set_stats_inputs, set_stats_outputs


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
    set_stats_inputs, set_stats_outputs = definitions()

    entries = [
        ('N2224', SET_STATS_OWNER, 'source_repair_turret_set_stats_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret', 'RepairTurret.setStats()', set_stats_inputs, set_stats_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret setStats() state from RepairTurret.java + Vars.java + Blocks.java + StatValues.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret setStats() state from RepairTurret.java + Vars.java + Blocks.java + StatValues.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: range_blocks,
    # repair_speed_per_second, booster_present,
    # booster_coolant_use, booster_coolant_multiplier.
    by_slice['N2224'] = [
        'source_repair_turret_set_stats_state_result.range_blocks',
        'source_repair_turret_set_stats_state_result.repair_speed_per_second',
        'source_repair_turret_set_stats_state_result.booster_present',
        'source_repair_turret_set_stats_state_result.booster_coolant_use',
        'source_repair_turret_set_stats_state_result.booster_coolant_multiplier',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2224', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret', java_method='RepairTurret.setStats()', godot_owner=SET_STATS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2224'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
