"""Register the WallCrafter power.status live read (N2170).

The WallCrafter's live read, following the N2145/N2146/N2147/N2148/
N2149/N2150/N2151/N2152/N2153/N2154/N2155/N2156/N2157/N2158/N2159/
N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169 pure-row
pattern. N2142's live loop stamps frame["power_status"] each tick --
but the WallCrafter has NO driver at all: it extends Block
(WallCrafter.java:25), not a factory or crafter, so no existing driver
matches it, and its updateTile warmup fold (WallCrafter.java:193)
gates on efficiency > 0, so a wall crafter with no power would warm
up as if power.status were 1.0. N2170 adds the pure power row
(source_wall_crafter_power_status_row_state) on a new family state
file, its own driver (source_wall_crafter_tick_buildings_state, the
separator N2169 precedent), its own frame key
("source_wall_crafter_building", added to N2142's
SOURCE_CONSUMER_FRAME_META_KEYS), and the simulate_factory wiring,
folded by the shared machinery into the min efficiency
(BuildingComp.java:1969-1976, ConsumePower.efficiency is
build.power.status) so the warmup fold (WallCrafter.java:193) follows
it.

Composition, not re-implementation: the shared efficiency
machinery (SourceBuildingEfficiencyState.update_consumption_state,
via update_consumption_non_optional_pass_state) already folds
{"result": ..., "is_power": true} rows into the min efficiency.
N2170 does not touch it. N2170 supplies the missing pure power
row + the driver fold + the frame key + the simulate_factory
wiring; no new consumer rows. No has_consumers fix is needed: the
machinery runs only when the block has a power consumer, and the
power consumer counts toward hasConsumers (Block.java:1449).
WallCrafterBuild overrides shouldConsume() to return items.get(output)
< itemCapacity (WallCrafter.java:226-228), so the default
(BuildingComp.java:755) does NOT apply here; the gate is deferred
(items state is not tracked yet) and the machinery runs with
should_consume=true when enabled (the MendProjector suppression
precedent). No updateTile advance: the warmup / lastEfficiency /
time / offload / totalTime / dump advance (WallCrafter.java:187-223)
waits for its own slice; the proof carries no warmup/time/offload
keys. The wall crafter's power consumers are static (consumePower
11 / 60f cliff-crusher, Blocks.java:3004; consumePower 1f
large-cliff-crusher, Blocks.java:3018), so the folded efficiency is
the min over the modeled consumers (power only); the liquid booster
(hydrogen 1f/60f, Blocks.java:3028) and the item booster (graphite,
Blocks.java:3030) wait for their own slices. The same driver covers
both defs via the catalog consumePower; the large-cliff-crusher def
waits for its own verification slice.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
WALL_CRAFTER = 'core/src/mindustry/world/blocks/production/WallCrafter.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
CONSUME_POWER = 'core/src/mindustry/world/consumers/ConsumePower.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
POWER_MODULE = 'core/src/mindustry/world/modules/PowerModule.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07WallCrafterPowerStatusProof'
OWNER = 'SourceWallCrafterBuildState.source_wall_crafter_power_status_row_state'
TESTS = ['test_c07_wall_crafter_power_status_registration', 'test_all_c07_wall_crafter_power_status_input_evidence_is_exact', 'test_wall_crafter_power_status_row_state', 'test_reference_graph_and_actual_c07_wall_crafter_power_status']
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
    'PayloadDeconstructor updateTile advance (dumpAccumulate / progress reset / payRotation / canProgress / accum / speedScl / progress += shift / item transfer / finish deconstruction, PayloadDeconstructor.java:109-204) -- the N2166 proof carries no progress/accum/dump keys; the progress advance (PayloadDeconstructor.java:142) is what the efficiency keys prove; the advance waits for its own slice.',
    'PayloadDeconstructor shouldConsume gate (deconstructing != null && enabled, PayloadDeconstructor.java:219-221) -- needs deconstructing state the tick does not track yet; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'PayloadDeconstructor acceptPayload / handlePayload / acceptUnitPayload rows (acceptPayload fits maxPayloadSize + requirements, PayloadDeconstructor.java:104-106; handlePayload clears accum, PayloadDeconstructor.java:98-101; acceptUnitPayload unit type / hitSize / requirements, PayloadDeconstructor.java:92-95) -- payload acceptance waits for its own slice.',
    'PayloadDeconstructor sense rows (sense(Content) deconstructing type/block, PayloadDeconstructor.java:206-210; sense(LAccess.progress) progress, PayloadDeconstructor.java:213-216) -- logic sensing waits for its own slice.',
    'PayloadDeconstructor draw / icons rows (draw input regions / drawPayload / deconstructing shadow / construct effect, PayloadDeconstructor.java:58-89; icons, PayloadDeconstructor.java:40-42) -- presentation, not state; waits for its own slice.',
    'PayloadDeconstructor setBars row (progress bar, PayloadDeconstructor.java:45-49) -- presentation, not tick state; waits for its own slice.',
    'PayloadDeconstructor read/write rows (progress / accum / deconstructing, PayloadDeconstructor.java:224-252) -- net/serialization, not tick state; waits for its own slice.',
    'PayloadDeconstructor dump rows (dumpRate 4, PayloadDeconstructor.java:20; dumpAccumulate, PayloadDeconstructor.java:111-115) -- item dumping waits for its own slice.',
    'PayloadDeconstructor small variant (small-deconstructor, consumePower 1f, Blocks.java:6644; size 3, Blocks.java:6645; deconstructSpeed 3f, Blocks.java:6646; itemCapacity 100, Blocks.java:6643) -- the same driver covers both defs via the catalog consumePower; the small def waits for its own verification slice.',
    'UnitFactory / Reconstructor / UnitAssembler variant verification (air-factory / naval-factory consumePower 1.2f, Blocks.java:6287/6298; multiplicative-reconstructor 6f / exponential-reconstructor 13f / tetrative-reconstructor 25f, Blocks.java:6326/6346/6368; ship-assembler 2.5f / mech-assembler 3f, Blocks.java:6546/6561 -- the same driver covers all defs via the catalog consumePower; the individual defs wait for their own verification slice).',
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
    "spawn_occupied / spawn_visual_occupied frame inputs -- checkSolid(spawn, false/true) (UnitAssembler.java:675-680) needs tile solidity + a nearby-units query; the port's check_solid_state() is a no-arg stub returning false; waits for a collision/tile-solidity frame-data slice.",
    'allow_update frame input -- the canonical allow_update_state exists (SourceBuildingAccessState, BuildingComp.java:622-627) but the driver cannot supply its inputs: rules_state carries only unitCostMultiplier + teams (no env, limitMapArea, limits), and the catalog carries no block env/privileged flags; waits for a rules-state capture slice.',
    'Per-unit AssemblerAI.inPosition() evaluation from live unit pos/rotation/targetPos/targetAngle -- the count reads the recorded in_position flag; the units list carries no pos/rotation yet.',
    'moveOutPayload() modeling -- the assembler production tick still has no payload move-out.',
    'Net readUnits / whenSyncedUnits drone sync -- presentation/net, not state.',
    'Live UnitComp.add() / remove() lifecycle hooks (UnitComp.java:591-598, 603-604, 752) -- no live unit lifecycle in the port yet.',
    'PayloadComp add/remove count hooks (PayloadComp.java:101, 200) -- same, payload lifecycle not ported yet.',
    "Teams.updateTeamStats full multi-team rebuild (present/bosses/players/unitsByType/unitTree, Teams.java:182-245) -- N2141 rebuilds one team's counts only.",
    'Units.notifyUnitSpawn / spawn path, Call.unitCapDeath / Call.unitEnvDeath net calls -- presentation/net, not state.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
    'UnitAssemblerModule updateTile advance (findLink on tileChanges / moveInPayload / yeetPayload to the linked assembler, UnitAssemblerModule.java:129-141) -- the N2168 proof carries no link/payload keys; the efficiency > 0 gate (UnitAssemblerModule.java:138) is what the efficiency keys prove; the advance waits for its own slice.',
    'UnitAssemblerModule link / findLink rows (getLink over the flagged unitAssembler builds, UnitAssemblerModule.java:64-69; findLink / removeModule / updateModules, UnitAssemblerModule.java:75-83; moduleFits, UnitAssembler.java:323) -- link state waits for its own slice.',
    'UnitAssemblerModule tier rows (tier = 1, UnitAssemblerModule.java:22; tier(), UnitAssemblerModule.java:85-86; setStats moduleTier, UnitAssemblerModule.java:30-35) -- tier is content-defined; the tier fold waits for its own slice.',
    'UnitAssemblerModule canPlaceOn rows (getLink != null, UnitAssemblerModule.java:53-55) -- the placement gate waits for its own slice.',
    'UnitAssemblerModule draw / drawPlace / drawPlanRegion / icons rows (draw side regions / payload / top region, UnitAssemblerModule.java:31-50, 59-63, 90-108; icons, UnitAssemblerModule.java:59-63) -- presentation, not tick state; waits for its own slice.',
    'UnitAssemblerModule acceptPayload rows (link != null && payload == null && link.acceptPayload, UnitAssemblerModule.java:125-127) -- payload acceptance waits for its own slice.',
    'UnitAssemblerModule onRemoved / drawSelect rows (removeModule on remove, UnitAssemblerModule.java:111-115; drawSelect link highlight, UnitAssemblerModule.java:118-123) -- lifecycle / presentation, not tick state; waits for its own slice.',
    'Separator updateTile advance (progress / warmup / totalProgress / consume() / offload random result item / dump, Separator.java:128-166) -- the N2169 proof carries no progress/warmup/offload keys; the progress advance (Separator.java:134, `progress += getProgressIncrease(craftTime);`) is what the efficiency keys prove; the advance waits for its own slice.',
    'Separator shouldConsume gate (total < itemCapacity && enabled, Separator.java:92-100) -- needs items/consItems state the tick does not track yet; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'Separator liquid consumer row (consumeLiquid slag 4f/60f separator / 0.12f disassembler, Blocks.java:1244/1264) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'Separator disassembler variant (disassembler, consumePower 4f, Blocks.java:1262; size 3, Blocks.java:1260; craftTime 15f, Blocks.java:1259; itemCapacity 20, Blocks.java:1261) -- the same driver covers both defs via the catalog consumePower; the disassembler def waits for its own verification slice.',
    'Separator sense / canDump rows (sense(LAccess.progress) progress, Separator.java:169-172; canDump !consumesItem, Separator.java:175-177) -- logic, not tick state; waits for its own slice.',
    'Separator draw / drawLight / icons / drawPlanRegion rows (drawer.draw, Separator.java:109-111; drawLight, Separator.java:114-117; icons, Separator.java:71-73; drawPlanRegion, Separator.java:66-69) -- presentation, not tick state; waits for its own slice.',
    'Separator read/write rows (progress / warmup / seed, Separator.java:180-194) -- net/serialization, not tick state; waits for its own slice.',
    'Separator created / shouldAmbientSound rows (seed = Mathf.randomSeed(tile.pos(), 0, Integer.MAX_VALUE - 1), Separator.java:78-80; shouldAmbientSound efficiency > 0, Separator.java:83-85) -- lifecycle / ambient, not tick state; waits for its own slice.',
    'WallCrafter updateTile advance (warmup / lastEfficiency / time / offload / totalTime / dump, WallCrafter.java:187-223) -- the N2170 proof carries no warmup/time/offload keys; the warmup fold (WallCrafter.java:193, `warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);`) is what the efficiency keys prove; the advance waits for its own slice.',
    'WallCrafter shouldConsume gate (items.get(output) < itemCapacity, WallCrafter.java:226-228) -- needs items state the tick does not track yet; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'WallCrafter liquid booster row (large-cliff-crusher hydrogen 1f/60f, Blocks.java:3028; liquidBoostIntensity 1.6f, WallCrafter.java:35) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'WallCrafter item booster row (large-cliff-crusher graphite boost, Blocks.java:3030; itemBoostIntensity 1.6f, WallCrafter.java:47; boostItemUseTime 60f/0.75f, Blocks.java:3032) -- the item row waits for its own slice.',
    'WallCrafter large variant (large-cliff-crusher, consumePower 1f, Blocks.java:3018; size 3, Blocks.java:3021; drillTime 48f, Blocks.java:3020) -- the same driver covers both defs via the catalog consumePower; the large def waits for its own verification slice.',
    'WallCrafter attribute / efficiency rows (getEfficiency over adjacent solid tiles, WallCrafter.java:141-180; canPlaceOn efficiency > 0, WallCrafter.java:137-139) -- needs tile proximity / attribute state the tick does not track yet.',
    'WallCrafter setBars row (drillspeed bar, WallCrafter.java:68-76) -- presentation, not tick state; waits for its own slice.',
    'WallCrafter draw / icons / drawPlanRegion / drawPlace rows (draw rotator, WallCrafter.java:231-243; icons, WallCrafter.java:120-122; drawPlanRegion, WallCrafter.java:125-129; drawPlace drillspeed text, WallCrafter.java:131-135) -- presentation, not tick state; waits for its own slice.',
]


EXACT_EXPRS = [
    "return build.power.status;",
    "float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;",
    "hasConsumers = consumers.length > 0;",
    "consumePower(11 / 60f);",
    "consumePower(1f);",
    "public class WallCrafter extends Block{",
    "public boolean shouldConsume(){",
    "for(var cons : block.nonOptionalConsumers){",
    "minEfficiency = Math.min(minEfficiency, result);",
    "public class WallCrafterBuild extends Building{",
    "warmup = Mathf.approachDelta(warmup, Mathf.num(efficiency > 0), 1f / 40f);",
    "lastEfficiency = eff * timeScale * efficiency;",
    "return items.get(output) < itemCapacity;"
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=WALL_CRAFTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2170_inputs = {
        'frame': f('Dictionary', 'return build.power.status;', 'The building frame carrying the graph-stamped power_status (ConsumePower.java:39, the canonical power.status read): the live value the row folds; null before the first graph update, folding to 1.0.', source=CONSUME_POWER),
        'has_power_consumer': f('bool', 'hasConsumers = consumers.length > 0;', 'Whether the block has a power consumer (Block.java:1449): the driver gate -- the row joins the first pass only when the block consumes power, and the power consumer counts toward hasConsumers.', source=BLOCK),
    }
    n2170_outputs = {
        'row': f('Dictionary', 'return build.power.status;', 'The power row for the first pass (ConsumePower.java:39, the canonical power.status read): {"result": live power.status, "is_power": true}, folded by the non-optional pass into the min efficiency.', source=CONSUME_POWER),
        'has_power_row': f('bool', 'for(var cons : block.nonOptionalConsumers){', 'Whether the row joins the first pass (BuildingComp.java:1969): true when the block has a power consumer; the row is the power consumer\'s entry in the non-optional pass.', source=BUILDING_COMP),
    }

    entries = [
        ('N2170', OWNER, 'source_wall_crafter_power_status_row_state', WALL_CRAFTER, 'mindustry.world.blocks.production.WallCrafter.WallCrafterBuild', 'WallCrafterBuild.updateTile()', n2170_inputs, n2170_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed WallCrafter power.status row from ConsumePower.java / BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed WallCrafter power.status row from ConsumePower.java / BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the row, then its presence flag.
    by_slice['N2170'] = [
        'source_wall_crafter_power_status_row_state_result.row',
        'source_wall_crafter_power_status_row_state_result.has_power_row',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2170', dict(status='done', java_source=WALL_CRAFTER, java_class='mindustry.world.blocks.production.WallCrafter.WallCrafterBuild', java_method='WallCrafterBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2170'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
