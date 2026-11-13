"""Register the MendProjector power.status live read (N2156).

The MendProjector family's live read, following the N2145/
N2146/N2147/N2148/N2149/N2150/N2151/N2152/N2153/N2154/N2155
pure-row pattern. N2142's live loop stamps frame["power_status"]
each tick, and the write-back is generic -- but the stamp only
reaches frames whose meta key is in
SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS,
and MendProjector (MendProjector.java:21, `public class
MendProjector extends Block{`) has no placed-buildings driver
at all, so mender (consumePower 0.3f) / mend-projector
(consumePower 1.5f) would heal as if power.status were 1.0.
N2156 adds a new mend-projector driver
(SourceMendProjectorBuildState) with a pure power row over the
stamped frame value, folded by the shared machinery into the
min efficiency (BuildingComp.java:1969-1976,
ConsumePower.efficiency is build.power.status) so the heal fold
(MendProjector.java:113, `other.heal(other.maxHealth() *
(healPercent + phaseHeat * phaseBoost) / 100f * efficiency);`)
follows it. MendProjector extends Block, not a drill or
factory, so it cannot reuse an existing frame key; the driver
uses its own family frame key
("source_mend_projector_building", the mechanical-pump /
beam-drill precedent), and GREEN adds that key to
SOURCE_CONSUMER_FRAME_META_KEYS so the N2142 stamp/write-back
finds it.

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already folds
{"result": ..., "is_power": true} rows into the min efficiency.
N2156 does not touch it. N2156 supplies the missing pure power
row + the tick-driver wiring + the one-line keys-list addition.
No has_consumers fix is needed: the machinery runs only when the
block has a power consumer, and the power consumer counts toward
hasConsumers (Block.java:1449). No shouldConsume gate:
MendBuild has no shouldConsume override, so the default
(BuildingComp.java:755-757, `return enabled;`) applies; the
machinery runs with should_consume=true when enabled. No
suppression gate: canHeal = !checkSuppression()
(MendProjector.java:94) needs suppression state the tick does
not track yet. No updateTile advance: MendBuild.updateTile()
(MendProjector.java:94-120, smoothEfficiency / heat / charge /
phaseHeat / heal) waits for its own slices; the proof carries no
progress/heal keys.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
MEND_PROJECTOR = 'core/src/mindustry/world/blocks/defense/MendProjector.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
POWER_MODULE = 'core/src/mindustry/world/modules/PowerModule.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07MendProjectorPowerStatusProof'
OWNER = 'SourceMendProjectorBuildState.source_mend_projector_power_status_row_state'
TESTS = ['test_c07_mend_projector_power_status_registration', 'test_all_c07_mend_projector_power_status_input_evidence_is_exact', 'test_mend_projector_power_status_row_state', 'test_reference_graph_and_actual_c07_mend_projector_power_status']
DEFERRED = [
    'MendProjector updateTile advance (smoothEfficiency / heat / charge / phaseHeat / heal, MendProjector.java:94-120) -- the N2156 proof carries no progress/heal keys; the heal fold (MendProjector.java:113) is what the efficiency keys prove; the advance waits for its own slice.',
    'MendProjector suppression gate (canHeal = !checkSuppression(), MendProjector.java:94) -- needs suppression state the tick does not track yet.',
    'MendProjector booster item rows (mender silicon boost, mend-projector phaseFabric boost, Blocks.java:1929/1941) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'MendProjector range / phase-range rows (realRange = range + phaseHeat * phaseRangeBoost, MendProjector.java:104) -- needs phaseHeat state the tick does not track yet.',
    'BeamDrill updateTile advance (warmup / multiplier / lastDrillSpeed / time / dump, BeamDrill.java:237-263) -- the N2155 proof carries no progress keys; the lastDrillSpeed fold (BeamDrill.java:249) is what the efficiency keys prove; the advance waits for its own slice.',
    'BeamDrill shouldConsume gate (items.total() < itemCapacity && facingAmount > 0 && enabled, BeamDrill.java:270-271) -- needs items/facing state the tick does not track yet.',
    'BeamDrill liquid rows (plasma-bore hydrogen 0.25f/60f booster; large-plasma-bore hydrogen 0.5f/60f + nitrogen 3f/60f booster, Blocks.java:3049/3064-3065) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'BeamDrill facing / laser binding (updateLasers / updateFacing, BeamDrill.java:368-411) -- needs tile/wall proximity state the tick does not track yet.',
    'BeamDrill drillMultipliers / blockedItem rows (BeamDrill.java:36-40) -- drill-time multipliers wait for their own slice.',
    'Pump updateTile advance (maxPump / liquids.add / warmup / totalProgress / consTimer item consume / dumpLiquid, Pump.java:161-182) -- the N2154 proof carries no progress keys; the maxPump fold (Pump.java:162) is what the efficiency keys prove; the advance waits for its own slice.',
    'Pump shouldConsume gate (liquidDrop != null && liquids.get(liquidDrop) < liquidCapacity - 0.01f && enabled, Pump.java:155-156) -- needs liquid state the tick does not track yet.',
    'Pump proximity amount / liquidDrop rows (Pump.java:141-152) -- needs tile / liquid proximity state the tick does not track yet.',
    'Pump warmup / totalProgress rows (Pump.java:171-176) -- the tick models no warmup state yet; waits for its own slice.',
    'Fracker updateTile advance (accumulator / itemUseTime consume / super.updateTile(), Fracker.java:30-44) -- the N2153 proof carries no progress keys; the accumulator fold (Fracker.java:38) and the solid-pump speed fold (SolidPump.java:121) are what the efficiency keys prove; the advance waits for its own slice.',
    'Fracker shouldConsume gate (inherited SolidPumpBuild.shouldConsume(), liquids.get(result) < liquidCapacity - 0.01f, SolidPump.java:113-115) -- needs liquid state the tick does not track yet.',
    'Fracker item / liquid rows (consumeItem sand, consumeLiquid water 0.15f, Blocks.java:2976-2978) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'Fracker water-attribute / validTiles / boost fraction rows (SolidPump.java:118, 137-147, inherited via super.updateTile()) -- the tick models no other inputs yet; the attribute fraction waits for its own slice.',
    'SolidPump updateTile advance (warmup / pumpTime / lastPump / validTiles / boost, SolidPump.java:118-133) -- the N2150 proof carries no progress keys; the speed fold (SolidPump.java:121) is what the efficiency keys prove; the advance waits for its own slice.',
    'SolidPump shouldConsume gate (liquids.get(result) < liquidCapacity - 0.01f, SolidPump.java:113-115) -- needs liquid state the tick does not track yet.',
    'SolidPump water-attribute / validTiles / boost fraction rows (SolidPump.java:118, 137-147) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); the attribute fraction waits for its own slice.',
    'Power.status live read for the remaining projector families (OverdriveProjector 3.5f / overdrive-dome 10f, ForceProjector 4f, BaseShield shield-projector 5f, RegenProjector 1f) -- projector semantics (overdrive / shield / regen) are not a production-efficiency fold; each waits for its own slice.',
    'Power.status live read for the payload-producer families (Constructor 2.5f / large-constructor 3f, PayloadLoader / PayloadUnloader / PayloadMassDriver / UnitCargoLoader / PayloadDeconstructor) -- separate family group; waits for its own slice.',
    'PointDefenseTurret updateTile advance / shouldConsume gate; TractorBeamTurret updateTile advance / shouldConsume gate / coolant rows (see register script DEFERRED).',
    'BurstDrill updateTile advance (progress / timeDrilled / offload / invertTime / speedCurve, BurstDrill.java:70-125) -- the N2149 proof carries no progress keys; the speed fold (BurstDrill.java:94) is what the efficiency keys prove; the advance waits for its own slice.',
    'BurstDrill shouldConsume gate (items.total() <= itemCapacity - dominantItems && enabled, BurstDrill.java:129) -- needs items/dominant state the tick does not track yet.',
    'BurstDrill liquid rows (eruption hydrogen + cyanogen booster, impact water + ozone booster) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'BurstDrill ore / dominant-item binding -- the drill proximity path binds base-Drill frames; BurstDrill dominant selection waits for its own slice.',
    'spawn_occupied / spawn_visual_occupied frame inputs -- checkSolid(spawn, false/true) (UnitAssembler.java:675-680) needs tile solidity + a nearby-units query; the port\'s check_solid_state() is a no-arg stub returning false; waits for a collision/tile-solidity frame-data slice.',
    'allow_update frame input -- the canonical allow_update_state exists (SourceBuildingAccessState, BuildingComp.java:622-627) but the driver cannot supply its inputs: rules_state carries only unitCostMultiplier + teams (no env, limitMapArea, limits), and the catalog carries no block env/privileged flags; waits for a rules-state capture slice.',
    'Per-unit AssemblerAI.inPosition() evaluation from live unit pos/rotation/targetPos/targetAngle -- the count reads the recorded in_position flag; the units list carries no pos/rotation yet.',
    'moveOutPayload() modeling -- the assembler production tick still has no payload move-out.',
    'Net readUnits / whenSyncedUnits drone sync -- presentation/net, not state.',
    'Live UnitComp.add() / remove() lifecycle hooks (UnitComp.java:591-598, 603-604, 752) -- no live unit lifecycle in the port yet.',
    'PayloadComp add/remove count hooks (PayloadComp.java:101, 200) -- same, payload lifecycle not ported yet.',
    'Teams.updateTeamStats full multi-team rebuild (present/bosses/players/unitsByType/unitTree, Teams.java:182-245) -- N2141 rebuilds one team\'s counts only.',
    'Units.notifyUnitSpawn / spawn path, Call.unitCapDeath / Call.unitEnvDeath net calls -- presentation/net, not state.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'return build.power.status;',
    'float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;',
    'hasConsumers = consumers.length > 0;',
    'consumePower(0.3f);',
    'consumePower(1.5f);',
    'public class MendProjector extends Block{',
    'hasPower = true;',
    'smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.08f);',
    'heat = Mathf.lerpDelta(heat, efficiency > 0 && canHeal ? 1f : 0f, 0.08f);',
    'charge += heat * delta();',
    'other.heal(other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency);',
    'for(var cons : block.nonOptionalConsumers){',
    'minEfficiency = Math.min(minEfficiency, result);',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=MEND_PROJECTOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2156_inputs = {
        'frame': f('Dictionary', 'return build.power.status;', 'The building frame carrying the graph-stamped power_status (ConsumePower.java:39, the canonical power.status read): the live value the row folds; null before the first graph update, folding to 1.0.', source=CONSUME_POWER),
        'has_power_consumer': f('bool', 'hasConsumers = consumers.length > 0;', 'Whether the block has a power consumer (Block.java:1449): the driver gate -- the row joins the first pass only when the block consumes power, and the power consumer counts toward hasConsumers.', source=BLOCK),
    }
    n2156_outputs = {
        'row': f('Dictionary', 'return build.power.status;', 'The power row for the first pass (ConsumePower.java:39, the canonical power.status read): {"result": live power.status, "is_power": true}, folded by the non-optional pass into the min efficiency.', source=CONSUME_POWER),
        'has_power_row': f('bool', 'for(var cons : block.nonOptionalConsumers){', 'Whether the row joins the first pass (BuildingComp.java:1969): true when the block has a power consumer; the row is the power consumer\'s entry in the non-optional pass.', source=BUILDING_COMP),
    }

    entries = [
        ('N2156', OWNER, 'source_mend_projector_power_status_row_state', MEND_PROJECTOR, 'mindustry.world.blocks.defense.MendProjector.MendBuild', 'MendBuild.updateTile()', n2156_inputs, n2156_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed MendProjector power.status row from ConsumePower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed MendProjector power.status row from ConsumePower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the row, then its presence flag.
    by_slice['N2156'] = [
        'source_mend_projector_power_status_row_state_result.row',
        'source_mend_projector_power_status_row_state_result.has_power_row',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2156', dict(status='done', java_source=MEND_PROJECTOR, java_class='mindustry.world.blocks.defense.MendProjector.MendBuild', java_method='MendBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2156'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    main()
