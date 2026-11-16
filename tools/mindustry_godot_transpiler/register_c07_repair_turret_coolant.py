"""Register the RepairTurret coolant heal multiplier (N2209).

The RepairTurret's coolant boost, following the N2208 pure-function
precedent (a pure function with NO driver tick line -- the
multiplier is a read the updateTile heal advance uses, not a tick
write). RepairPointBuild.updateTile computes the heal multiplier
as `float multiplier = 1f;` then `if(acceptCoolant){ multiplier
= 1f + liquids.current().heatCapacity * coolantMultiplier *
optionalEfficiency; }` (RepairTurret.java:188-190), and heals
with it: `target.heal(repairSpeed * strength * edelta() *
multiplier);` (RepairTurret.java:207). The coolant consumer is
registered in init() only when the block accepts coolant:
`if(acceptCoolant){ hasLiquids = true; consume(new
ConsumeCoolant(coolantUse)).optional(true, true); }`
(RepairTurret.java:84-86) -- an OPTIONAL consumer, so its
efficiency folds into optionalEfficiency in the optional pass
(BuildingComp.java:1979-1981, `optionalEfficiency =
Math.min(optionalEfficiency, cons.efficiency(self()));`), which
updateConsumption initializes to 1f before the pass
(BuildingComp.java:1965, `efficiency = optionalEfficiency =
1f;`). ConsumeCoolant is a ConsumeLiquidFilter whose filter
admits only real coolants (`liquid.coolant && ... &&
liquid.temperature <= maxTemp && liquid.flammability <
maxFlammability`, ConsumeCoolant.java:12, maxTemp 0.5f,
maxFlammability 0.1f) and whose efficiency is the available
liquid over the per-tick need (`return liq != null ?
Math.min(build.liquids.get(liq) / (amount * ed *
multiplier.get(build)), 1f) : 0f;`,
ConsumeLiquidFilter.java:53). Per-def, only repair-turret
accepts coolant: coolantUse 0.16f, coolantMultiplier 1.6f,
acceptCoolant true (Blocks.java:6404-6406); class defaults are
coolantUse 0.5f, coolantMultiplier 1f, acceptCoolant false
(RepairTurret.java:39-45), so repair-point never boosts. N2209
closes the N2174/N2188 deferred coolant item with one pure
function (source_repair_turret_coolant_multiplier_state) over
two frame keys (`liquids_current_heat_capacity`, float, and
`optional_efficiency`, float) plus the per-def accept_coolant
and coolant_multiplier params, returning `heal_multiplier`
(+ `coolant_active`). RED decisions (pinned by this slice):
(1) accept_coolant=false returns 1.0 with coolant_active false
-- the Java `if(acceptCoolant){` guard leaves multiplier at
1f, so repair-point never boosts even with coolant liquid
present. (2) An absent `liquids_current_heat_capacity` key
reads 0.0 -- no current coolant liquid observed yet, so no
boost, never a crash; the future liquid-state slice stamps it
from `liquids.current().heatCapacity`. Java's `current()` can
never be null in practice (`private Liquid current =
content.liquid(0);`, LiquidModule.java:24), but the port frame
carries no liquid observation yet, and absent means "no
observation", not "a liquid with zero heat capacity" -- the
observable (multiplier 1.0) is the same either way. (3) An
absent `optional_efficiency` key reads 1.0 -- BuildingComp
initializes `efficiency = optionalEfficiency = 1f` before
the optional pass (BuildingComp.java:1965), so a frame the
driver has not stamped yet reads the pre-pass value, not 0.
(4) coolantUse is NOT a parameter: it belongs to the
ConsumeCoolant consumer's efficiency/update (the optional
coolant row that folds optionalEfficiency from the liquid
amount), which waits for its own slice -- the multiplier
formula never reads it. (5) NO driver tick line for this
function: the multiplier feeds the updateTile heal advance
(RepairTurret.java:187-218), which waits for its own slice
-- the N2208 precedent. No new frame meta key, no
SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory
wiring change. Shard note: RepairTurret.java lives under
/world/blocks/units/ and no shard selection matches it (the
N2188 precedent), so the GREEN register run must record that
no source_modules shard changes.

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_optional_pass_state) already folds
optional-consumer rows into optionalEfficiency, and the driver
already stamps frame["optional_efficiency"] every tick. N2209
does not touch it -- the optional coolant row itself (liquid
amount -> optionalEfficiency) is a later slice, and this slice
supplies only the missing pure multiplier over the already-
stamped optionalEfficiency. The heal advance that consumes the
multiplier is its own later slice. Do NOT confuse the coolant
multiplier with the tractor-beam coolant rows
(SourceTractorBeamTurretBuildUpdateTileCoolantState): those port
TractorBeamBuild.updateTile's own consume-coolant block
(`float used = Math.min(...)`, `coolantMultiplier = 1f + (used
* liquid.heatCapacity * coolantMultiplier);`), a different
class with a different formula -- RepairTurret multiplies by
optionalEfficiency, TractorBeam multiplies by the used amount.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_repair_turret_should_consume import DEFERRED as _N2188_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
CONSUME_COOLANT = 'core/src/mindustry/world/consumers/ConsumeCoolant.java'
CONSUME_LIQUID_FILTER = 'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
LIQUID = 'core/src/mindustry/type/Liquid.java'
PROOF = '/root/C07RepairTurretCoolantProof'
OWNER = 'SourceRepairTurretBuildState.source_repair_turret_coolant_multiplier_state'
TESTS = ['test_c07_repair_turret_coolant_registration', 'test_all_c07_repair_turret_coolant_input_evidence_is_exact', 'test_repair_turret_coolant_multiplier_state', 'test_reference_graph_and_actual_c07_repair_turret_coolant']
# The 7 slice sources the N2209 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files, and no expr may name a file outside them.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/world/consumers/ConsumeCoolant.java',
    'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/modules/LiquidModule.java',
    'core/src/mindustry/type/Liquid.java',
]
EXACT_EXPRS = ['public class RepairTurret extends Block{', 'public boolean acceptCoolant = false;', 'public float coolantUse = 0.5f;', 'public float coolantMultiplier = 1f;', 'if(acceptCoolant){', 'consume(new ConsumeCoolant(coolantUse)).optional(true, true);', 'float multiplier = 1f;', 'multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;', 'target.heal(repairSpeed * strength * edelta() * multiplier);', 'public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'hasLiquids = true;', 'coolantUse = 0.16f;', 'coolantMultiplier = 1.6f;', 'acceptCoolant = true;', 'public class ConsumeCoolant extends ConsumeLiquidFilter{', 'public float maxTemp = 0.5f, maxFlammability = 0.1f;', 'liquid.coolant && (this.allowLiquid && !liquid.gas || this.allowGas && liquid.gas) && liquid.temperature <= maxTemp && liquid.flammability < maxFlammability;', 'return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;', 'optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));', 'efficiency = optionalEfficiency = 1f;', 'private Liquid current = content.liquid(0);', 'public float heatCapacity = 0.5f;', 'public boolean coolant = true;', 'public float repairSpeed = 0.3f;']

# DEFERRED is carried from the N2188 register script via import --
# never retyped. The N2188 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2174 import), NOT a plain
# list literal, so the N2188-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2209's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval. The
# RepairTurret coolant optional consumer itself is NOT carried as
# deferred: it is THIS slice (N2209) -- the inherited N2174 entry
# still names it as waiting, which is stale history, superseded
# by this slice (the multiplier half; the optional coolant row
# itself -- liquid amount -> optionalEfficiency -- still waits
# for its own slice, as this script's docstring records).
DEFERRED = list(_N2188_DEFERRED) + [
    'RepairTurret coolant Windows Godot proof -- debt in GOAL.md section 5, same as N2175-N2208: the N2209 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def f(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2209_inputs = {
        'frame': f('Dictionary', 'multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;', 'The building frame carrying the liquids_current_heat_capacity observation (RepairTurret.java:190, `liquids.current().heatCapacity`) and the optional_efficiency the driver stamps every tick; a missing liquids_current_heat_capacity key reads 0.0 -- no current coolant liquid observed yet -- and a missing optional_efficiency key reads 1.0 -- BuildingComp initializes `efficiency = optionalEfficiency = 1f` before the optional pass (BuildingComp.java:1965).'),
        'accept_coolant': f('bool', 'public boolean acceptCoolant = false;', 'Whether this def accepts coolant (RepairTurret.java:39, `public boolean acceptCoolant = false;` class default; repair-turret sets `acceptCoolant = true;`, Blocks.java:6406); false returns the 1.0 base multiplier -- the Java `if(acceptCoolant){` guard (RepairTurret.java:189) leaves multiplier at 1f.'),
        'coolant_multiplier': f('float', 'public float coolantMultiplier = 1f;', 'The per-def coolant multiplier (RepairTurret.java:45, `public float coolantMultiplier = 1f;` class default; repair-turret sets `coolantMultiplier = 1.6f;`, Blocks.java:6405); the caller passes it in, the N2207 launch-pad precedent.'),
    }
    n2209_outputs = {
        'heal_multiplier': f('float', 'multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;', 'The heal multiplier (RepairTurret.java:188-190): 1.0 when acceptCoolant is false, else `1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency` -- the factor the updateTile heal advance multiplies by (`target.heal(repairSpeed * strength * edelta() * multiplier);`, RepairTurret.java:207).'),
    }
    return n2209_inputs, n2209_outputs


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
    inputs, outputs = definitions()
    for keys in [inputs, outputs]:
        for field, meta in keys.items():
            source = meta['java_source']
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    total = len(EXACT_EXPRS) + len(inputs) + len(outputs)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    n2209_inputs, n2209_outputs = definitions()

    entries = [
        ('N2209', OWNER, 'source_repair_turret_coolant_multiplier_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'RepairPointBuild.updateTile()', n2209_inputs, n2209_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret coolant heal multiplier from RepairTurret.java / ConsumeCoolant.java / ConsumeLiquidFilter.java / BuildingComp.java / LiquidModule.java / Liquid.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret coolant heal multiplier from RepairTurret.java / ConsumeCoolant.java / ConsumeLiquidFilter.java / BuildingComp.java / LiquidModule.java / Liquid.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the heal multiplier, the slice's only result key.
    by_slice['N2209'] = [
        'source_repair_turret_coolant_multiplier_state_result.heal_multiplier',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2209', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='RepairPointBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2209'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
