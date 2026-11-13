"""Register the UnitCargoLoader power.status live read (N2165).

The UnitCargoLoader family's live read, following the N2145/
N2146/N2147/N2148/N2149/N2150/N2151/N2152/N2153/N2154/N2155/
N2156/N2157/N2158/N2159/N2160/N2161/N2162/N2163/N2164 pure-row
pattern. N2142's live loop stamps frame["power_status"] each
tick, and the write-back is generic -- but the stamp only
reaches frames whose meta key is in
SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS,
and UnitCargoLoader (UnitCargoLoader.java:23, `public class
UnitCargoLoader extends Block{`) has no placed-buildings
driver at all, so unit-cargo-loader (consumePower 8f/60f,
Blocks.java:2276) would build as if power.status were 1.0.
N2165 adds a new unit-cargo-loader driver
(SourceUnitCargoLoaderBuildState) with a pure power row over
the stamped frame value, folded by the shared machinery into
the min efficiency (BuildingComp.java:1969-1976,
ConsumePower.efficiency is build.power.status) so the warmup
fold (UnitCargoLoader.java:105, `warmup =
Mathf.approachDelta(warmup, efficiency, 1f / 60f);`) and the
build advance (UnitCargoLoader.java:109, `buildProgress +=
edelta() / unitBuildTime;`) follow it. UnitCargoLoader
extends Block, not a drill or factory, so it cannot reuse an
existing frame key; the driver uses its own family frame key
("source_unit_cargo_loader_building", the mechanical-pump /
beam-drill / mend-projector / overdrive-projector /
force-projector / base-shield / regen-projector / constructor
/ payload-loader / payload-unloader / payload-mass-driver
precedent), and GREEN adds that key to
SOURCE_CONSUMER_FRAME_META_KEYS so the N2142 stamp/write-back
finds it.

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already folds
{"result": ..., "is_power": true} rows into the min efficiency.
N2165 does not touch it. N2165 supplies the missing pure power
row + the tick-driver wiring + the one-line keys-list addition.
No has_consumers fix is needed: the machinery runs only when the
block has a power consumer, and the power consumer counts toward
hasConsumers (Block.java:1449). The shouldConsume gate is
deferred: UnitTransportSourceBuild overrides shouldConsume() to
return unit == null (UnitCargoLoader.java:141-143), which needs
unit state the tick does not track yet; the machinery runs
with should_consume=true when enabled (the MendProjector
suppression precedent). No updateTile advance:
UnitTransportSourceBuild.updateTile() (UnitCargoLoader.java:92-125,
unit lost/destroyed / readUnitId / warmup / readyness /
buildProgress / totalProgress / unit spawn) waits for its own
slice; the proof carries no warmup/progress/spawn keys. The
unit-cargo-loader power consumer is static (consumePower 8f/60f,
Blocks.java:2276) -- but it also consumes liquid nitrogen
10f/60f (Blocks.java:2279), so the folded efficiency is the min
over the modeled consumers (power only); the liquid row waits
for its own slice.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_CARGO_LOADER = 'core/src/mindustry/world/blocks/units/UnitCargoLoader.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
POWER_MODULE = 'core/src/mindustry/world/modules/PowerModule.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07UnitCargoLoaderPowerStatusProof'
OWNER = 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_power_status_row_state'
TESTS = ['test_c07_unit_cargo_loader_power_status_registration', 'test_all_c07_unit_cargo_loader_power_status_input_evidence_is_exact', 'test_unit_cargo_loader_power_status_row_state', 'test_reference_graph_and_actual_c07_unit_cargo_loader_power_status']
DEFERRED = [
    'UnitCargoLoader updateTile advance (unit lost/destroyed / readUnitId / warmup / readyness / buildProgress / totalProgress / unit spawn, UnitCargoLoader.java:92-125) -- the N2165 proof carries no warmup/readyness/progress/spawn keys; the warmup fold (UnitCargoLoader.java:105) and the build advance (UnitCargoLoader.java:109) are what the efficiency keys prove; the advance waits for its own slice.',
    'UnitCargoLoader shouldConsume gate (unit == null, UnitCargoLoader.java:141-143) -- needs unit state the tick does not track yet; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'UnitCargoLoader liquid consumer row (consumeLiquid nitrogen 10f/60f, Blocks.java:2279) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'UnitCargoLoader unit spawn rows (unitType manifold, unitBuildTime 60f * 8f, UnitCargoLoader.java:24-25; unit creation + Call.unitTetherBlockSpawned, UnitCargoLoader.java:114-122) -- unit spawn waits for its own slice.',
    'UnitCargoLoader canPlaceOn / Units.canCreate rows (UnitCargoLoader.java:65-68) -- the placement gate waits for its own slice; N2140 proved Units.canCreate live evaluation.',
    'UnitCargoLoader bar rows (setBars units bar, UnitCargoLoader.java:48-63) -- presentation, not tick state; waits for its own slice.',
    'UnitCargoLoader draw rows (Drawf.construct / poly ring, UnitCargoLoader.java:146-162) -- presentation, not state; waits for its own slice.',
    'UnitCargoLoader read/write rows (readUnitId, write unit id, UnitCargoLoader.java:174-188) -- net/serialization, not tick state; waits for its own slice.',
    'PayloadMassDriver updateTile advance (link/state-machine idle-accepting-shooting / charge / reloadCounter / waitingShooters / transfer / moveInPayload / moveOutPayload, PayloadMassDriver.java:160-350) -- the N2164 proof carries no link/state/charge keys; the no-power skip (PayloadMassDriver.java:232) is what the efficiency keys prove; the advance waits for its own slice.',
    'PayloadMassDriver shouldConsume gate (PayloadDriverBuild has no shouldConsume override, so the BuildingComp default, BuildingComp.java:755, applies; a stricter gate would need payload/link state the tick does not track yet) -- the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'PayloadMassDriver link/config rows (link -1, config Point2/Integer, onConfigureBuildTapped, linkValid, PayloadMassDriver.java:64-65, 321-350) -- needs tile/link state the tick does not track yet; config, not tick state.',
    'PayloadMassDriver charge/reload rows (chargeTime 100f class / 90f payload-mass-driver / 100f large, PayloadMassDriver.java:29 / Blocks.java:6622/6634; reload 30f class / 130f defs, PayloadMassDriver.java:28 / Blocks.java:6621/6633; charge += edelta(), PayloadMassDriver.java:289) -- the charge/reload advance waits for its own slice.',
    'PayloadMassDriver range/maxPayloadSize rows (range 100f class / 700f payload-mass-driver / 2100f large, PayloadMassDriver.java:24 / Blocks.java:6623/6635; maxPayloadSize 3 class / 2.5f / 4f, PayloadMassDriver.java:30 / Blocks.java:6624/6636) -- static defs and the range check wait for their own slice.',
    'PayloadMassDriver acceptPayload rows (acceptPayload fits maxPayloadSize, PayloadMassDriver.java:317-319) -- payload acceptance waits for its own slice.',
    'PayloadMassDriver large variant (large-payload-mass-driver, consumePower 3f, Blocks.java:6637; size 5, Blocks.java:6632) -- the same driver covers both defs via the catalog consumePower; the large def waits for its own verification slice.',
    'PayloadUnloader updateTile advance (moveInPayload / moveOutPayload / load items+liquids / battery charge, PayloadUnloader.java:50-110) -- the N2163 proof carries no load/export/battery keys; the load gate (PayloadUnloader.java:69) is what the efficiency keys prove; the advance waits for its own slice.',
    'PayloadUnloader shouldConsume gate (inherited from PayloadLoaderBuild, payload != null, PayloadLoader.java:240-242) -- needs payload state the tick does not track yet; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'PayloadUnloader dynamic power consumer row (consumePowerDynamic, PayloadLoader.java:80, inherited; maxPowerConsumption 40f + basePowerUse when hasBattery() && !exporting, else basePowerUse) -- the tick models the power row only; the dynamic usage value waits for its own slice.',
    'PayloadUnloader battery-unload rows (total = payload.build.power.status * cap; unloaded = min(maxPowerUnload * edelta(), total); lastOutputPower = unloaded, PayloadUnloader.java:96-101) -- needs payload battery state the tick does not track yet.',
    'PayloadUnloader shouldExport gate (payload != null && items/liquids/battery empty, PayloadUnloader.java:116-122) -- needs payload state the tick does not track yet; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'PayloadUnloader power-production rows (getPowerProduction returns lastOutputPower, PayloadUnloader.java:46-48; lastOutputPower 0f, PayloadUnloader.java:33; offloadSpeed 4, PayloadUnloader.java:9, 106-108; outputsPower = true / loadPowerDynamic = false / canOverdrive = false, PayloadUnloader.java:15-19) -- power output + dump cadence wait for their own slice.',
    'PayloadUnloader load params (loadTime 2f, itemsLoaded 8, liquidsLoaded 40f, maxBlockSize 3, PayloadLoader.java:22-25, inherited) -- static defs and the load advance wait for their own slice.',
    'PayloadUnloader accept/handle payload rows (acceptPayload fits maxBlockSize, PayloadLoader.java:102-115, inherited; handlePayload, PayloadLoader.java:118-121, inherited; PayloadUnloaderBuild overrides acceptItem/acceptLiquid to return false, PayloadUnloader.java:35-44) -- payload acceptance waits for its own slice.',
    'Payload producer power.status live reads (PayloadDeconstructor) -- separate families; wait for their own slices.',
    'Constructor / BlockProducer updateTile advance (progress / heat / time / moveOutPayload, BlockProducer.java:109-131) -- the N2161 proof carries no progress/heat/recipe keys; the produce gate (BlockProducer.java:110) is what the efficiency keys prove; the advance waits for its own slice.',
    'BlockProducer shouldConsume gate (super.shouldConsume() && recipe() != null, BlockProducer.java:102-104) -- needs recipe state the tick does not track yet; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'BlockProducer dynamic item consumer rows (ConsumeItemDynamic over recipe requirements, BlockProducer.java:39-58) -- the tick models no item consumer yet; the row waits for its own slice.',
    'Constructor config / filter rows (filter, minBlockSize 1 / maxBlockSize 2, canProduce, Constructor.java:21-22, 54-56) -- config, not tick state; waits for its own slice.',
    'Constructor buildSpeed rows (buildSpeed 0.6f constructor / 0.75f large-constructor, Blocks.java:6662/6674; base 0.4f, BlockProducer.java:22) -- the progress advance (BlockProducer.java:113) waits for its own slice.',
    'Constructor payload / draw rows (payload placement effect, BlockProducer.java:116-119; drawSelect / draw, Constructor.java:77-87, BlockProducer.java:134-160) -- presentation, not state; waits for its own slice.',
    'RegenProjector updateTile advance (warmup / totalTime / optionalTimer / didRegen / anyTargets / mendMap / heal, RegenProjector.java:123-179) -- the N2160 proof carries no warmup/heal/target keys; the heal gate (RegenProjector.java:142) is what the efficiency keys prove; the advance waits for its own slice.',
    'RegenProjector shouldConsume gate (anyTargets, RegenProjector.java:206-208) -- needs the targets computation (indexer range query over damaged buildings in range 28, RegenProjector.java:113-117); the tick does not track targets yet.',
    'RegenProjector suppression gate (checkSuppression(), RegenProjector.java:137; suppressable=true, RegenProjector.java:49) -- needs suppression state the tick does not track yet.',
    'RegenProjector booster item row (regen-projector phaseFabric boost, Blocks.java:2017) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); the row waits for its own slice.',
    'RegenProjector liquid row (hydrogen 1f/60f, Blocks.java:2016) -- the tick models no liquid consumer yet; the liquid row waits for its own slice.',
    'RegenProjector range / heal rows (range 28, Blocks.java:2011; healPercent 4f/60f, Blocks.java:2018; optionalMultiplier 2f / optionalUseTime 60f * 8f, RegenProjector.java:36-37) -- static defs and the optional fold (RegenProjector.java:148) wait for their own slice.',
    'RegenProjector mendMap / effect rows (mendMap, RegenProjector.java:29-31; effect Fx.regenParticle, effectChance 0.003f, RegenProjector.java:40-41) -- needs mend state the tick does not track yet.',
    'BaseShield updateTile advance (smoothRadius / bulletConsumer absorb / unitConsumer repel / broken / hit, BaseShield.java:88-99) -- the N2159 proof carries no shield/radius/broken keys; the smooth-radius fold (BaseShield.java:89) is what the efficiency keys prove; the advance waits for its own slice.',
    'BaseShield drawShield rows (shieldColor / animateShields / sides 24 / hit alpha, BaseShield.java:125-147) -- presentation, not state; waits for its own slice.',
    'BaseShield radius / sides rows (radius 200f default / 400f large, BaseShield.java:20 / Blocks.java:2060; sides 24, BaseShield.java:21) -- static defs, not tick state; the radius() accessor (BaseShield.java:101-103) returns smoothRadius, which the tick does not track yet.',
    'BaseShield broken / hit rows (broken flag, hit flash, BaseShield.java:83-84) -- needs buildup/broken state the tick does not track yet.',
    'ForceProjector updateTile advance (phaseValid / phaseHeat / consume() / radscl / warmup / buildup / broken / deflectBullets, ForceProjector.java:207-268) -- the N2158 proof carries no shield/warmup/buildup keys; the warmup fold (ForceProjector.java:221) is what the efficiency keys prove; the advance waits for its own slice.',
    'ForceProjector booster item row (force-projector phaseFabric boost, Blocks.java:1974) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'ForceProjector coolant rows (ConsumeCoolant 0.1f, ForceProjector.java:69-71; cooldownLiquid 1.2f, Blocks.java:1971) -- the tick models no liquid consumer yet; the coolant regen boost waits for its own slice.',
    'ForceProjector phase-radius / phase-shield rows (realRadius = (radius + phaseHeat * phaseRadiusBoost) * radscl, ForceProjector.java:280; shieldHealth + phaseShieldBoost * phaseHeat, ForceProjector.java:195) -- needs phaseHeat state the tick does not track yet.',
    'ForceProjector broken / buildup rows (broken flag, buildup regen with cooldownNormal 1.5f / cooldownBrokenBase 0.35f, ForceProjector.java:223-262) -- needs buildup state the tick does not track yet.',
    'OverdriveProjector updateTile advance (smoothEfficiency / heat / charge / phaseHeat / useProgress / boost application, OverdriveProjector.java:97-120) -- the N2157 proof carries no progress/boost keys; the real-boost fold (OverdriveProjector.java:124) is what the efficiency keys prove; the advance waits for its own slice.',
    'OverdriveProjector booster item rows (overdrive-projector phaseFabric boost, Blocks.java:1948; overdrive-dome phaseFabric + silicon, Blocks.java:1961) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'OverdriveProjector range / phase-range rows (realRange = range + phaseHeat * phaseRangeBoost, OverdriveProjector.java:110) -- needs phaseHeat state the tick does not track yet.',
    'OverdriveProjector useProgress consume() rows (useTime 400f / overdrive-dome 300f, OverdriveProjector.java:117-120; the dome also sets hasBoost = false, Blocks.java:1960, so its phaseHeat stays 0) -- needs useProgress state the tick does not track yet.',
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
    'Fracker item / liquid rows (consumeItem sand, consumeLiquid water 0.15f, Blocks.java:2976-2978) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slice.',
    'Fracker water-attribute / validTiles / boost fraction rows (SolidPump.java:118, 137-147, inherited via super.updateTile()) -- the tick models no other inputs yet; the attribute fraction waits for its own slice.',
    'SolidPump updateTile advance (warmup / pumpTime / lastPump / validTiles / boost, SolidPump.java:118-133) -- the N2150 proof carries no progress keys; the speed fold (SolidPump.java:121) is what the efficiency keys prove; the advance waits for its own slice.',
    'SolidPump shouldConsume gate (liquids.get(result) < liquidCapacity - 0.01f, SolidPump.java:113-115) -- needs liquid state the tick does not track yet.',
    'SolidPump water-attribute / validTiles / boost fraction rows (SolidPump.java:118, 137-147) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); the attribute fraction waits for its own slice.',
    'PointDefenseTurret updateTile advance / shouldConsume gate; TractorBeamTurret updateTile advance / shouldConsume gate / coolant rows (see register script DEFERRED).',
    'BurstDrill updateTile advance (progress / timeDrilled / offload / invertTime / speedCurve, BurstDrill.java:70-125) -- the N2149 proof carries no progress keys; the speed fold (BurstDrill.java:94) is what the efficiency keys prove; the advance waits for its own slice.',
    'BurstDrill shouldConsume gate (items.total() <= itemCapacity - dominantItems && enabled, BurstDrill.java:129) -- needs items/dominant state the tick does not track yet.',
    'BurstDrill liquid rows (eruption hydrogen + cyanogen booster, impact water + ozone booster) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slice.',
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
    'consumePower(8f / 60f);',
    'public class UnitCargoLoader extends Block{',
    'warmup = Mathf.approachDelta(warmup, efficiency, 1f / 60f);',
    'buildProgress += edelta() / unitBuildTime;',
    'public boolean shouldConsume(){',
    'return unit == null;',
    'for(var cons : block.nonOptionalConsumers){',
    'minEfficiency = Math.min(minEfficiency, result);',
    'public float unitBuildTime = 60f * 8f;',
    'consumeLiquid(Liquids.nitrogen, 10f / 60f);',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=UNIT_CARGO_LOADER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2165_inputs = {
        'frame': f('Dictionary', 'return build.power.status;', 'The building frame carrying the graph-stamped power_status (ConsumePower.java:39, the canonical power.status read): the live value the row folds; null before the first graph update, folding to 1.0.', source=CONSUME_POWER),
        'has_power_consumer': f('bool', 'hasConsumers = consumers.length > 0;', 'Whether the block has a power consumer (Block.java:1449): the driver gate -- the row joins the first pass only when the block consumes power, and the power consumer counts toward hasConsumers.', source=BLOCK),
    }
    n2165_outputs = {
        'row': f('Dictionary', 'return build.power.status;', 'The power row for the first pass (ConsumePower.java:39, the canonical power.status read): {"result": live power.status, "is_power": true}, folded by the non-optional pass into the min efficiency.', source=CONSUME_POWER),
        'has_power_row': f('bool', 'for(var cons : block.nonOptionalConsumers){', 'Whether the row joins the first pass (BuildingComp.java:1969): true when the block has a power consumer; the row is the power consumer\'s entry in the non-optional pass.', source=BUILDING_COMP),
    }

    entries = [
        ('N2165', OWNER, 'source_unit_cargo_loader_power_status_row_state', UNIT_CARGO_LOADER, 'mindustry.world.blocks.units.UnitCargoLoader.UnitTransportSourceBuild', 'UnitTransportSourceBuild.updateTile()', n2165_inputs, n2165_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitCargoLoader power.status row from ConsumePower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitCargoLoader power.status row from ConsumePower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the row, then its presence flag.
    by_slice['N2165'] = [
        'source_unit_cargo_loader_power_status_row_state_result.row',
        'source_unit_cargo_loader_power_status_row_state_result.has_power_row',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2165', dict(status='done', java_source=UNIT_CARGO_LOADER, java_class='mindustry.world.blocks.units.UnitCargoLoader.UnitTransportSourceBuild', java_method='UnitTransportSourceBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2165'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
