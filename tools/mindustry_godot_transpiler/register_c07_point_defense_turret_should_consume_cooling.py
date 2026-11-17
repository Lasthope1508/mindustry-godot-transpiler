"""Register the PointDefenseTurret shouldConsume gate + coolant (N2241).

N2151 wired the power.status live read but deferred the
shouldConsume gate ("No shouldConsume gate --
PointDefenseBuild.shouldConsume()
(PointDefenseTurret.java:105-107, `return
super.shouldConsume() && target != null;`) needs live
bullet-target state the tick does not track yet; the
machinery runs with should_consume=true when enabled").
N2239/N2240 now stamp the live target, so the gate is
unblocked: super.shouldConsume() is Building.shouldConsume()
(BuildingComp.java:755-757, `return enabled;` -- neither
ReloadTurretBuild nor BaseTurretBuild overrides it), so the
gate is `enabled && target != null`. TurretBuild.
shouldConsume() (Turret.java:364, `return isShooting ||
reloadCounter < reload;`) is NOT in the chain --
PointDefenseBuild extends ReloadTurretBuild, not
TurretBuild. The same slice closes the other remainder
of updateTile: the coolant call (`if(coolant != null){
updateCooling(); }`, PointDefenseTurret.java:74-76), which
runs before the aim/shoot half (PointDefenseTurret.java:
76-101) so its reloadCounter boost feeds the shoot gate.
updateCooling() (ReloadTurret.java:28-38) gates on
canReload() (`reloadCounter < reload`,
ReloadTurret.java:46-48) && coolant != null &&
coolant.efficiency(this) > 0 && efficiency > 0, then
`reloadCounter += amount * edelta() * capacity *
coolantMultiplier * ammoReloadMultiplier();` with amount
= coolant.amount * coolant.efficiency(this), capacity =
the consumed liquid's heatCapacity (ConsumeCoolant is a
ConsumeLiquidFilter), coolantMultiplier = 2f for
PointDefenseTurret (PointDefenseTurret.java:42) and
ammoReloadMultiplier() = 1f (ReloadTurret.java:41-43).
The coolant efficiency and the consumed liquid's
heatCapacity arrive as parameters (the N2240
block_damage_multiplier precedent) -- the frame carries
no liquid inventory, so the live getConsumed selection
and the coolant.update liquid removal wait for a later
wiring slice. The only PointDefenseTurret def, segment
(Blocks.java:3835-3845), defines NO coolant consumer, so
BaseTurret.init (BaseTurret.java:50-52) leaves coolant
null and the driver call is a faithful no-op for segment.
Two pure functions on SourcePointDefenseTurretBuildState.gd,
plus two driver tick lines (the shouldConsume gate in the
consumption branch, the cooling call before aim/shoot).
Four new result symbols: should_consume +
reload_counter + cooling_applied + coolant_consumed.

GREEN decisions (pinned by this slice): (1) The
shouldConsume pure function is the headline: it gets
the ledger godot_owner, the one new API contract, and
the input/result state schemas (contracts +1, schema
+2 per scope section 3); the cooling function's three
result symbols are registered in the symbol registry
with godot_owner ..._cooling_state, and its inputs /
outputs java_exprs are still verified by --verify, but
it gets no second contract or schema pair -- the
driver call is a faithful no-op for the only def, so
the cooling state is class-level behavior modeled with
synthetic inputs, not a live API. (2) The gate is
`enabled && target != null`, read from the frame keys
the tick (enabled, default true) and N2239 (target,
null when no target is stamped) already carry. The
driver replaces the consumption branch's
`bool(frame.get("enabled", true))` with the pure
function call. (3) The cooling gate is canReload()
(`reloadCounter < reload`) && has_coolant &&
coolant_efficiency > 0 && efficiency > 0; amount =
coolant_amount * coolant_efficiency; coolant_consumed
= amount * edelta (the liquid the future wiring slice
removes -- coolant.update removes `amount * edelta() *
multiplier`, multiplier default 1f, Consume.java:18);
reloadCounter += amount * edelta * capacity *
coolantMultiplier (ammoReloadMultiplier() = 1f, so no
extra factor); cooling_applied is false whenever the
gate fails and reload_counter is unchanged then. The
coolEffect chance (ReloadTurret.java:35) is a random
visual, NOT in the pure function (the N2240
random-pitch precedent). (4) The driver calls cooling
inside the observed_bullets block, after the edelta
computation and before the aim/shoot call (Java order
:74-76 before :77-101), with the per-def segment
values has_coolant=false, coolant_multiplier=2.0,
reload=8.0, other params 0.0, and stamps
frame["reload_counter"] from the result so aim reads
the boosted value. (5) LIVE CONSEQUENCE
(Java-faithful): until the bullet wiring lands, the
frame carries no observed_bullets, so target stays
null and should_consume is false -- the segment
consumes no power and efficiency folds to 0, exactly
like Java with no target in range
(BuildingComp.java:1947 `efficiency = ...
shouldConsume() ? potentialEfficiency : 0f;`). The
proof supplies an observed target to show consumption.
The lumped deferred entry "PointDefenseTurret updateTile
advance / shouldConsume gate; TractorBeamTurret ..."
is NOT dropped here: draw / write-read / setStats /
icons, the real effect/sound spawn, the live coolant
efficiency / getConsumed selection / coolant.update
liquid removal, and TractorBeam still wait. Shard note:
PointDefenseTurret.java lives under
/world/blocks/defense/turrets/ and matches the
defense shard selection (the N2239/N2240 precedent), so
the GREEN register run records the defense shard
count change. SSOT expected after GREEN: symbols
+4, Done +1, contracts +1, schema +2, 11552/1690/
1621/3033 -> 11556/1691/1622/3035.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed
from register_c07_point_defense_turret_aim_shoot import DEFERRED as N2240_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
POINT_DEFENSE = 'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
CONSUME_LIQUID_FILTER = 'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java'
CONSUME_COOLANT = 'core/src/mindustry/world/consumers/ConsumeCoolant.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
PROOF = '/root/C07PointDefenseTurretShouldConsumeCoolantProof'
SHOULD_CONSUME_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_should_consume_state'
COOLING_OWNER = 'SourcePointDefenseTurretBuildState.source_point_defense_turret_cooling_state'
TESTS = ['test_c07_point_defense_turret_should_consume_cooling_registration', 'test_all_c07_point_defense_turret_should_consume_cooling_input_evidence_is_exact', 'test_point_defense_turret_should_consume_cooling_state', 'test_reference_graph_and_actual_c07_point_defense_turret_should_consume_cooling']
# The 8 slice sources the N2241 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PointDefenseTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
    'core/src/mindustry/world/consumers/ConsumeCoolant.java',
    'core/src/mindustry/world/consumers/Consume.java',
]
EXACT_EXPRS = ['return super.shouldConsume() && target != null;', 'public boolean shouldConsume(){', 'return enabled;', 'transient boolean enabled = true;', 'if(coolant != null){', 'updateCooling();', 'coolantMultiplier = 2f;', 'if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){', 'float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);', 'float amount = coolant.amount * coolant.efficiency(this);', 'coolant.update(this);', 'reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();', 'if(Mathf.chance(0.06 * amount)){', 'return reloadCounter < reload;', 'build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));', 'return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;', 'public Floatf<Building> multiplier = b -> 1f;', 'coolant = findConsumer(c -> c instanceof ConsumeCoolant);', 'return efficiency * delta();', 'segment = new PointDefenseTurret("segment"){{', 'consumePower(8f);', 'reload = 8f;', 'public float reloadCounter;', 'public @Nullable Bullet target;']

# DEFERRED is carried from the N2240 register script via import --
# never retyped. Nothing is dropped here: the lumped
# PointDefenseTurret updateTile advance entry still waits for
# the coolant live wiring + draw / write-read / setStats /
# icons + the real effect/sound spawn, and the TractorBeam
# half is untouched. Only the N2241 Windows-proof debt entry
# is appended.
DEFERRED = list(N2240_DEFERRED) + [
    'PointDefenseTurret shouldConsume gate + coolant Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2240: the N2241 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=POINT_DEFENSE, **extra):
        return backed(typ, source, expr, rule, **extra)

    gate = 'return super.shouldConsume() && target != null;'
    should_consume_inputs = {
        'frame': a('Dictionary', gate, 'The turret frame (PointDefenseTurret.java:105-107, `return super.shouldConsume() && target != null;` -- the frame carries enabled (default true, BuildingComp.java:77) and target (null when no target is stamped, PointDefenseTurret.java:60); the driver stamps both live).'),
    }
    should_consume_outputs = {
        'should_consume': a('bool', gate, 'Whether the build should consume (PointDefenseTurret.java:106 -- super.shouldConsume() is Building.shouldConsume(), `return enabled;`, BuildingComp.java:755-757, so the gate is enabled && target != null).'),
    }
    cooling_gate = 'if(canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0){'
    cooling_inputs = {
        'frame': a('Dictionary', 'public float reloadCounter;', 'The turret frame (ReloadTurret.java:26, `public float reloadCounter;` -- the frame carries reload_counter (default 0.0) and efficiency (default 1.0, BuildingComp.java:1928); the driver stamps reload_counter back every tick).', source=RELOAD_TURRET),
        'has_coolant': a('bool', 'if(coolant != null){', 'Whether a coolant consumer exists (PointDefenseTurret.java:74, `if(coolant != null){` -- BaseTurret.init leaves coolant null when no ConsumeCoolant consumer is defined, BaseTurret.java:50-52; the segment def defines none, so the driver passes false).'),
        'coolant_amount': a('float', 'float amount = coolant.amount * coolant.efficiency(this);', 'The coolant amount per second (ReloadTurret.java:31 -- amount = coolant.amount * coolant.efficiency(this); the driver passes 0.0 for the no-coolant segment).', source=RELOAD_TURRET),
        'coolant_efficiency': a('float', 'return liq != null ? Math.min(build.liquids.get(liq) / (amount * ed * multiplier.get(build)), 1f) : 0f;', 'The coolant efficiency for the consumed liquid (ConsumeLiquidFilter.java:50-56 -- min(liquids.get(liq) / (amount * ed * multiplier), 1), 0 when no liquid; passed in precomputed, like N2240\'s block_damage_multiplier).', source=CONSUME_LIQUID_FILTER),
        'heat_capacity': a('float', 'float capacity = coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);', 'The consumed liquid\'s heatCapacity (ReloadTurret.java:30 -- ConsumeCoolant extends ConsumeLiquidFilter, so the filter branch applies; passed in precomputed).', source=RELOAD_TURRET),
        'coolant_multiplier': a('float', 'coolantMultiplier = 2f;', 'The coolant multiplier (PointDefenseTurret.java:42, `coolantMultiplier = 2f;` -- the BaseTurret class default is 5f; the driver passes the per-def 2.0).'),
        'reload': a('float', 'reload = 8f;', 'The per-def reload in seconds (segment 8f, Blocks.java:3845, `reload = 8f;` -- canReload() is reloadCounter < reload, ReloadTurret.java:46-48; the driver passes the per-def 8.0).', source=BLOCKS),
        'edelta': a('float', 'return efficiency * delta();', 'The effective delta in seconds (BuildingComp.java:1927-1929, `return efficiency * delta();` -- the driver passes frame efficiency * seconds precomputed).', source=BUILDING_COMP),
    }
    cooling_outputs = {
        'reload_counter': a('float', 'reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();', 'The reload counter after the cooling boost (ReloadTurret.java:33 -- reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier(), ammoReloadMultiplier() = 1f; unchanged when the gate fails).', source=RELOAD_TURRET),
        'cooling_applied': a('bool', cooling_gate, 'Whether the cooling gate fired (ReloadTurret.java:29 -- canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0; false whenever the gate fails).', source=RELOAD_TURRET),
        'coolant_consumed': a('float', 'build.liquids.remove(liq, amount * build.edelta() * multiplier.get(build));', 'The liquid the cooling consumed, amount * edelta (ConsumeLiquidFilter.java:44-49 -- coolant.update removes amount * edelta() * multiplier, multiplier default 1f; 0.0 when the gate fails; the future wiring slice applies it as a liquid removal).', source=CONSUME_LIQUID_FILTER),
    }
    return should_consume_inputs, should_consume_outputs, cooling_inputs, cooling_outputs


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
    should_consume_inputs, should_consume_outputs, cooling_inputs, cooling_outputs = definitions()

    entries = [
        ('N2241', SHOULD_CONSUME_OWNER, 'source_point_defense_turret_should_consume_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.shouldConsume()', should_consume_inputs, should_consume_outputs, True, 'Dictionary'),
        ('N2241', COOLING_OWNER, 'source_point_defense_turret_cooling_state', POINT_DEFENSE, 'mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', 'PointDefenseBuild.updateTile()', cooling_inputs, cooling_outputs, False, 'Dictionary'),
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
            # Only the headline shouldConsume function gets a
            # contract + input/result schemas (contracts +1,
            # schema +2 per scope section 3); the cooling
            # function's result symbols are registered in the
            # registry above with godot_owner ..._cooling_state,
            # and its inputs/outputs are still --verify checked.
            if has_contract:
                source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret shouldConsume gate + coolant from PointDefenseTurret.java / ReloadTurret.java / BaseTurret.java / BuildingComp.java / Blocks.java / ConsumeLiquidFilter.java / ConsumeCoolant.java / Consume.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PointDefenseTurret shouldConsume gate + coolant from PointDefenseTurret.java / ReloadTurret.java / BaseTurret.java / BuildingComp.java / Blocks.java / ConsumeLiquidFilter.java / ConsumeCoolant.java / Consume.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: should_consume, reload_counter,
    # cooling_applied, coolant_consumed.
    by_slice['N2241'] = [
        'source_point_defense_turret_should_consume_state_result.should_consume',
        'source_point_defense_turret_cooling_state_result.reload_counter',
        'source_point_defense_turret_cooling_state_result.cooling_applied',
        'source_point_defense_turret_cooling_state_result.coolant_consumed',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2241', dict(status='done', java_source=POINT_DEFENSE, java_class='mindustry.world.blocks.defense.turrets.PointDefenseTurret.PointDefenseBuild', java_method='PointDefenseBuild.updateTile()', godot_owner=SHOULD_CONSUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2241'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
