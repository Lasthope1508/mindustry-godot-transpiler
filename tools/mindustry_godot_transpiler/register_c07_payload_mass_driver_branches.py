"""Register the PayloadMassDriver state branches (N2246).

N2164 proved the PayloadMassDriver live power read and N2245
the updateTile frame/state advance (link refresh, charge
discharge, curSize lerp, effectDelayTimer, reload decay,
shooter cleanup, the idle -> accepting / shooting switch,
the idle/accepting dump, the no-power return) -- but the
port tracked no accepting / shooting branch behavior at
all, so a payload-mass-driver never aligned to a shooter,
never loaded a payload toward the muzzle, never charged,
and never transferred a payload to its link. N2246 is the
state branches (PayloadDriverBuild.updateTile(),
PayloadMassDriver.java:232-342): the no-power return
(:232-234), the accepting bail + targetSize + align
(:236-248), the shooting bail + payRotation + loadLength
advance + moveInPayload intake (:249-270), the fire gate --
enqueue, reload, first-in-queue, partner accepting, both
angles within 1f (:272-294) -- and the charge + transfer
(:295-342, the payload leaves the self frame the moment it
fires, the partner takes payVector / payRotation /
payLength / loaded / effectDelayTimer / lastOther and goes
idle).

Scoping (from real Java, no guesses): (1) the branches run
only when efficiency > 0 (the no-power return,
PayloadMassDriver.java:232-234); the pure function guards
on efficiency itself, and the driver wires it after the
consumption fold, AFTER the N2245 frame/state wiring
position (the coordinator places N2245 between the fold
and the branches at integration -- in this branch N2245
does not exist yet, so the wiring sits right after the
fold with a marker comment). (2) the partner driver state
is an explicit dict (the N2237 MassDriver precedent):
exists / pos / is_payload_mass_driver / same_block /
same_team / within_range / payload / state /
turret_rotation / reload_counter / effect_delay_timer /
pay_vector / pay_rotation / pay_length / loaded /
last_other / waiting_shooters / x / y. same_block is the
DEF match (payload-mass-driver vs large-payload-mass-driver
are different blocks, PayloadMassDriver.java:490-492
`other.block == block`) -- unlike the single-def MassDriver,
where the implementation match was enough. (3) Angles.within
is <= (Arc Angles.java:19-21, `return angleDist(a, b) <=
margin;`), NOT the strict < of Angles.near -- the port has
source_angles_within, so no local helper is needed (unlike
N2237, which ported near locally). (4) moveInPayload()
(PayloadBlock.java:181-197, rotate=true) runs its rotation
toward rotdeg() (`return rotation * 90;`,
BuildingComp.java:582-584) -- the driver passes rot_deg
from the sprite rotation meta; the Vec2.approach port and
the isZero(0.01f) arrival (`return len2() < margin;`, Arc
Vec2.java:679-681, the SQUARED length against the bare
margin) reuse the N2233 deconstructor precedent.
updatePayload() positioning defers (the port payload dict
carries no position). (5) handlePayload
(PayloadBlock.java:121-124) sets the partner payload, but
its payVector / payRotation writes are overwritten in the
same tick by PayloadMassDriver.java:307-308
(`other.payVector.set(-cx, -cy);` / `other.payRotation =
turretRotation;`), so the net transfer is payload +
payVector(-cx,-cy) + payRotation(turretRotation) +
payLength(length) + loaded(true); recPayload is set and
cleared in the same tick (:303 / :314), so it is not a
result key. (6) charge is NOT reset on transfer (Java
leaves it >= chargeTime; the N2245 discharge drains it
once charging stops). (7) the per-def params are chargeTime
(90f / 100f large) and range (700f / 2100f large,
Blocks.java:6621-6636); length 89/8f, knockback 5f,
rotateSpeed 5f, payloadSpeed 0.7f, payloadRotateSpeed 5f
are class constants. (8) the advance runs after
consumption, like Java's Building.update()
(BuildingComp.java:2274-2277), and WITHOUT an enabled
guard: PayloadMassDriver has noUpdateDisabled = false
(the Block default, Block.java:170), so Java runs
updateTile() even when disabled (the N2231 precedent).
(9) a missing shooter record means the shooter sprite is
gone: Java would rotate toward its stale position for one
tick, the port keeps the rotation and targetSize (the
N2237 precedent). Shard note: the register run below
rebuilds every shard and the observed delta is recorded
in the slice report.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
PAYLOAD_MASS_DRIVER = 'core/src/mindustry/world/blocks/payloads/PayloadMassDriver.java'
PAYLOAD_BLOCK = 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java'
BUILD_PAYLOAD = 'core/src/mindustry/world/blocks/payloads/BuildPayload.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/C07PayloadMassDriverBranchesProof'
OWNER = 'SourcePayloadMassDriverBuildState.source_payload_mass_driver_state_branches_state'
TESTS = ['test_c07_payload_mass_driver_branches_registration', 'test_all_c07_payload_mass_driver_branches_input_evidence_is_exact', 'test_payload_mass_driver_state_branches_state', 'test_reference_graph_and_actual_c07_payload_mass_driver_branches']
DEFERRED = [
    'MendProjector booster timer / consume (if(optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal){ consume(); }, MendProjector.java:101-103) -- needs timer + items infrastructure the tick does not track yet; deferred by N2193, which advances smoothEfficiency / heat / charge / phaseHeat but does not consume.',
    'MendProjector heal scan + sound (indexer.eachBlock + other.heal(...) + Fx.healBlockFull + mendSound, MendProjector.java:106-118) -- needs targets/indexer infrastructure; N2193 implements only the charge = 0f reset, which precedes the scan, so the reset does not depend on finding a target; the scan + sound wait for their own slice.',
    'MendProjector draw / drawLight / sense (MendProjector.java:122-170) -- draw uses heat / phaseHeat / smoothEfficiency the N2193 advance now tracks, but the draw / drawLight / sense rows wait for their own slices.',
    'MendProjector runtime-simulation divergence (SourceMendProjectorRuntimeState.runtime_step_state lerps smoothEfficiency / heat toward 1.0 unconditionally and phaseHeat toward booster presence, with no charge reset) -- the older simulation path is a separate state store (game dicts, not the sprite frame) and is not the C07 driver frame; reconciling it with the N2193 Java-exact advance waits for its own slice.',
    'UnitCargoLoader liquid consumer row (consumeLiquid nitrogen 10f/60f, Blocks.java:2279) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'UnitCargoLoader canPlaceOn / Units.canCreate rows (UnitCargoLoader.java:65-68) -- the placement gate waits for its own slice; N2140 proved Units.canCreate live evaluation.',
    'UnitCargoLoader bar rows (setBars units bar, UnitCargoLoader.java:48-63) -- presentation, not tick state; waits for its own slice.',
    'UnitCargoLoader draw rows (Drawf.construct / poly ring, UnitCargoLoader.java:146-162) -- presentation, not state; waits for its own slice.',
    'UnitCargoLoader read/write rows (readUnitId, write unit id, UnitCargoLoader.java:174-188) -- net/serialization, not tick state; waits for its own slice.',
    'PayloadMassDriver shouldConsume gate (PayloadDriverBuild has no shouldConsume override, so the BuildingComp default, BuildingComp.java:755, applies; a stricter gate would need payload/link state the tick does not track yet) -- the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent).',
    'PayloadMassDriver link/config rows (link -1, config Point2/Integer, onConfigureBuildTapped, linkValid, PayloadMassDriver.java:64-65, 321-350) -- needs tile/link state the tick does not track yet; config, not tick state.',
    'PayloadMassDriver charge/reload rows (chargeTime 100f class / 90f payload-mass-driver / 100f large, PayloadMassDriver.java:29 / Blocks.java:6622/6634; reload 30f class / 130f defs, PayloadMassDriver.java:28 / Blocks.java:6621/6633; charge += edelta(), PayloadMassDriver.java:289) -- the charge/reload advance waits for its own slice.',
    'PayloadMassDriver range/maxPayloadSize rows (range 100f class / 700f payload-mass-driver / 2100f large, PayloadMassDriver.java:24 / Blocks.java:6623/6635; maxPayloadSize 3 class / 2.5f / 4f, PayloadMassDriver.java:30 / Blocks.java:6624/6636) -- static defs and the range check wait for their own slice.',
    'PayloadMassDriver acceptPayload rows (acceptPayload fits maxPayloadSize, PayloadMassDriver.java:317-319) -- payload acceptance waits for its own slice.',
    'PayloadMassDriver large variant (large-payload-mass-driver, consumePower 3f, Blocks.java:6637; size 5, Blocks.java:6632) -- the same driver covers both defs via the catalog consumePower; the large def waits for its own verification slice.',
    'PayloadUnloader dynamic power consumer row (consumePowerDynamic, PayloadLoader.java:80, inherited; maxPowerConsumption 40f + basePowerUse when hasBattery() && !exporting, else basePowerUse) -- the tick models the power row only; the dynamic usage value waits for its own slice.',
    'PayloadUnloader accept/handle payload rows (acceptPayload fits maxBlockSize, PayloadLoader.java:102-115, inherited; handlePayload, PayloadLoader.java:118-121, inherited; PayloadUnloaderBuild overrides acceptItem/acceptLiquid to return false, PayloadUnloader.java:35-44) -- payload acceptance waits for its own slice.',
    'PayloadDeconstructor acceptPayload / handlePayload / acceptUnitPayload rows (acceptPayload fits maxPayloadSize + requirements, PayloadDeconstructor.java:104-106; handlePayload clears accum, PayloadDeconstructor.java:98-101; acceptUnitPayload unit type / hitSize / requirements, PayloadDeconstructor.java:92-95) -- payload acceptance waits for its own slice.',
    'PayloadDeconstructor sense rows (sense(Content) deconstructing type/block, PayloadDeconstructor.java:206-210; sense(LAccess.progress) progress, PayloadDeconstructor.java:213-216) -- logic sensing waits for its own slice.',
    'PayloadDeconstructor draw / icons rows (draw input regions / drawPayload / deconstructing shadow / construct effect, PayloadDeconstructor.java:58-89; icons, PayloadDeconstructor.java:40-42) -- presentation, not state; waits for its own slice.',
    'PayloadDeconstructor setBars row (progress bar, PayloadDeconstructor.java:45-49) -- presentation, not tick state; waits for its own slice.',
    'PayloadDeconstructor read/write rows (progress / accum / deconstructing, PayloadDeconstructor.java:224-252) -- net/serialization, not tick state; waits for its own slice.',
    'PayloadDeconstructor dump rows (dumpRate 4, PayloadDeconstructor.java:20; dumpAccumulate, PayloadDeconstructor.java:111-115) -- item dumping waits for its own slice.',
    'PayloadDeconstructor small variant (small-deconstructor, consumePower 1f, Blocks.java:6644; size 3, Blocks.java:6645; deconstructSpeed 3f, Blocks.java:6646; itemCapacity 100, Blocks.java:6643) -- the same driver covers both defs via the catalog consumePower; the small def waits for its own verification slice.',
    'UnitFactory / Reconstructor / UnitAssembler variant verification (air-factory / naval-factory consumePower 1.2f, Blocks.java:6287/6298; multiplicative-reconstructor 6f / exponential-reconstructor 13f / tetrative-reconstructor 25f, Blocks.java:6326/6346/6368; ship-assembler 2.5f / mech-assembler 3f, Blocks.java:6546/6561 -- the same driver covers all defs via the catalog consumePower; the individual defs wait for their own verification slice).',
    'Constructor / BlockProducer updateTile advance (progress / heat / time / moveOutPayload, BlockProducer.java:109-131) -- the N2161 proof carries no progress/heat/recipe keys; the produce gate (BlockProducer.java:110) is what the efficiency keys prove; the advance waits for its own slice.',
    'BlockProducer dynamic item consumer rows (ConsumeItemDynamic over recipe requirements, BlockProducer.java:39-58) -- the tick models no item consumer yet; the row waits for its own slice.',
    'Constructor config / filter rows (filter, minBlockSize 1 / maxBlockSize 2, canProduce, Constructor.java:21-22, 54-56) -- config, not tick state; waits for its own slice.',
    'Constructor buildSpeed rows (buildSpeed 0.6f constructor / 0.75f large-constructor, Blocks.java:6662/6674; base 0.4f, BlockProducer.java:22) -- the progress advance (BlockProducer.java:113) waits for its own slice.',
    'Constructor payload / draw rows (payload placement effect, BlockProducer.java:116-119; drawSelect / draw, Constructor.java:77-87, BlockProducer.java:134-160) -- presentation, not state; waits for its own slice.',
    'RegenProjector suppression gate (checkSuppression(), RegenProjector.java:137; suppressable=true, RegenProjector.java:49) -- needs suppression state the tick does not track yet.',
    'RegenProjector booster item row (regen-projector phaseFabric boost, Blocks.java:2017) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); the row waits for its own slice.',
    'RegenProjector liquid row (hydrogen 1f/60f, Blocks.java:2016) -- the tick models no liquid consumer yet; the liquid row waits for its own slice.',
    'RegenProjector range / heal rows (range 28, Blocks.java:2011; healPercent 4f/60f, Blocks.java:2018; optionalMultiplier 2f / optionalUseTime 60f * 8f, RegenProjector.java:36-37) -- static defs and the optional fold (RegenProjector.java:148) wait for their own slice.',
    'RegenProjector mendMap / effect rows (mendMap, RegenProjector.java:29-31; effect Fx.regenParticle, effectChance 0.003f, RegenProjector.java:40-41) -- needs mend state the tick does not track yet.',
    'BaseShield drawShield rows (shieldColor / animateShields / sides 24 / hit alpha, BaseShield.java:125-147) -- presentation, not state; waits for its own slice.',
    'BaseShield radius / sides rows (radius 200f default / 400f large, BaseShield.java:20 / Blocks.java:2060; sides 24, BaseShield.java:21) -- static defs, not tick state; the radius() accessor (BaseShield.java:101-103) returns smoothRadius, which the tick does not track yet.',
    'BaseShield broken / hit rows (broken flag, hit flash, BaseShield.java:83-84) -- needs buildup/broken state the tick does not track yet.',
    'ForceProjector booster item row (force-projector phaseFabric boost, Blocks.java:1974) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'ForceProjector coolant rows (ConsumeCoolant 0.1f, ForceProjector.java:69-71; cooldownLiquid 1.2f, Blocks.java:1971) -- the tick models no liquid consumer yet; the coolant regen boost waits for its own slice.',
    'ForceProjector phase-radius / phase-shield rows (realRadius = (radius + phaseHeat * phaseRadiusBoost) * radscl, ForceProjector.java:280; shieldHealth + phaseShieldBoost * phaseHeat, ForceProjector.java:195) -- needs phaseHeat state the tick does not track yet.',
    'ForceProjector broken / buildup rows (broken flag, buildup regen with cooldownNormal 1.5f / cooldownBrokenBase 0.35f, ForceProjector.java:223-262) -- needs buildup state the tick does not track yet.',
    'OverdriveProjector booster item rows (overdrive-projector phaseFabric boost, Blocks.java:1948; overdrive-dome phaseFabric + silicon, Blocks.java:1961) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'MendProjector suppression gate (canHeal = !checkSuppression(), MendProjector.java:94) -- needs suppression state the tick does not track yet.',
    'MendProjector booster item rows (mender silicon boost, mend-projector phaseFabric boost, Blocks.java:1929/1941) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'MendProjector range / phase-range rows (realRange = range + phaseHeat * phaseRangeBoost, MendProjector.java:104) -- phaseHeat is now tracked by the N2193 advance, but the realRange fold / drawSelect range display still waits for its own slice.',
    'BeamDrill liquid rows (plasma-bore hydrogen 0.25f/60f booster; large-plasma-bore hydrogen 0.5f/60f + nitrogen 3f/60f booster, Blocks.java:3049/3064-3065) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slices.',
    'BeamDrill facing / laser binding (updateLasers / updateFacing, BeamDrill.java:368-411) -- needs tile/wall proximity state the tick does not track yet.',
    'BeamDrill drillMultipliers / blockedItem rows (BeamDrill.java:36-40) -- drill-time multipliers wait for their own slice.',
    'Pump proximity amount / liquidDrop rows (Pump.java:141-152) -- needs tile / liquid proximity state the tick does not track yet.',
    'Fracker item / liquid rows (consumeItem sand, consumeLiquid water 0.15f, Blocks.java:2976-2978) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); those rows wait for their own slice.',
    'Fracker water-attribute / validTiles / boost fraction rows (SolidPump.java:118, 137-147, inherited via super.updateTile()) -- the tick models no other inputs yet; the attribute fraction waits for its own slice.',
    'SolidPump water-attribute / validTiles / boost fraction rows (SolidPump.java:118, 137-147) -- the tick models no other consumers yet, so the folded efficiency is the min over the modeled consumers (power only); the attribute fraction waits for its own slice.',
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
    'Separator liquid consumer row (consumeLiquid slag 4f/60f separator / 0.12f disassembler, Blocks.java:1244/1264) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'Separator disassembler variant (disassembler, consumePower 4f, Blocks.java:1262; size 3, Blocks.java:1260; craftTime 15f, Blocks.java:1259; itemCapacity 20, Blocks.java:1261) -- the same driver covers both defs via the catalog consumePower; the disassembler def waits for its own verification slice.',
    'Separator sense / canDump rows (sense(LAccess.progress) progress, Separator.java:169-172; canDump !consumesItem, Separator.java:175-177) -- logic, not tick state; waits for its own slice.',
    'Separator draw / drawLight / icons / drawPlanRegion rows (drawer.draw, Separator.java:109-111; drawLight, Separator.java:114-117; icons, Separator.java:71-73; drawPlanRegion, Separator.java:66-69) -- presentation, not tick state; waits for its own slice.',
    'Separator read/write rows (progress / warmup / seed, Separator.java:180-194) -- net/serialization, not tick state; waits for its own slice.',
    'WallCrafter liquid booster row (large-cliff-crusher hydrogen 1f/60f, Blocks.java:3028; liquidBoostIntensity 1.6f, WallCrafter.java:35) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'WallCrafter item booster row (large-cliff-crusher graphite boost, Blocks.java:3030; itemBoostIntensity 1.6f, WallCrafter.java:47; boostItemUseTime 60f/0.75f, Blocks.java:3032) -- the item row waits for its own slice.',
    'WallCrafter large variant (large-cliff-crusher, consumePower 1f, Blocks.java:3018; size 3, Blocks.java:3021; drillTime 48f, Blocks.java:3020) -- the same driver covers both defs via the catalog consumePower; the large def waits for its own verification slice.',
    'WallCrafter attribute / efficiency rows (getEfficiency over adjacent solid tiles, WallCrafter.java:141-180; canPlaceOn efficiency > 0, WallCrafter.java:137-139) -- needs tile proximity / attribute state the tick does not track yet.',
    'WallCrafter setBars row (drillspeed bar, WallCrafter.java:68-76) -- presentation, not tick state; waits for its own slice.',
    'WallCrafter draw / icons / drawPlanRegion / drawPlace rows (draw rotator, WallCrafter.java:231-243; icons, WallCrafter.java:120-122; drawPlanRegion, WallCrafter.java:125-129; drawPlace drillspeed text, WallCrafter.java:131-135) -- presentation, not tick state; waits for its own slice.',
    'MassDriver shouldConsume gate (MassDriverBuild has no shouldConsume override, so the BuildingComp default, BuildingComp.java:755, applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent)).',
    'MassDriver link/config rows (link -1, config Point2/Integer, onConfigureBuildTapped, linkValid, MassDriver.java:58-59, 266-282, 346-349) -- needs tile/link state the tick does not track yet; config, not tick state.',
    'MassDriver handlePayload / receive rows (handlePayload, MassDriver.java:319-340; receiveEffect / receiveSound, MassDriver.java:39/41) -- payload receipt waits for its own slice.',
    'MassDriver sense / draw / drawConfigure / drawPlace / icons rows (sense(LAccess.progress) reloadCounter, MassDriver.java:224-228; draw base/shadow, MassDriver.java:230-242; drawConfigure link circles/arrows, MassDriver.java:244-264; drawPlace range circle, MassDriver.java:80-102; icons, MassDriver.java:75-77) -- presentation/logic, not tick state; waits for its own slice.',
    'MassDriver read/write rows (link / rotation / state, MassDriver.java:358-372) -- net/serialization, not tick state; waits for its own slice.',
    'MassDriver acceptItem rows (acceptItem items.total() < itemCapacity && linkValid(), MassDriver.java:285-288) -- item acceptance waits for its own slice.',
    'LaunchPad liquid consumer row (advanced-launch-pad consumeLiquid oil 9f/60f, Blocks.java:6808) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'LaunchPad advanced variant (advanced-launch-pad, consumePower 8f, Blocks.java:6809; size 4, Blocks.java:6802; launchTime 60f * 30, Blocks.java:6804; liquidCapacity 40f, Blocks.java:6805) -- the same driver covers both defs via the catalog consumePower; the advanced def waits for its own verification slice.',
    'LaunchPad sense rows (sense(LAccess.progress) launchCounter / launchTime, LaunchPad.java:98-101) -- logic sensing waits for its own slice.',
    'LaunchPad draw / drawLiquid / icons rows (draw bottom/liquid/light/pod, LaunchPad.java:104-140; icons, LaunchPad.java:78-81) -- presentation, not tick state; waits for its own slice.',
    'LaunchPad acceptItem rows (acceptItem items.total() < itemCapacity && (acceptMultipleItems || items.total() == 0 || items.first() == item), LaunchPad.java:138-140) -- item acceptance waits for its own slice.',
    'LaunchPad config / display / shouldShowConfigure rows (buildConfiguration sector select, LaunchPad.java:185-...; display destination label, LaunchPad.java:164-178; shouldShowConfigure campaign only, LaunchPad.java:180-183) -- config/presentation, not tick state; waits for its own slice.',
    'Radar shouldConsume gate (RadarBuild has no shouldConsume override, so the BuildingComp default, BuildingComp.java:755, applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent)).',
    'Radar draw / drawSelect / icons rows (draw base/region/glow rotateSpeed * totalProgress, Radar.java:85-90; drawSelect dash circle, Radar.java:80-82; icons, Radar.java:37-39) -- presentation, not tick state; waits for its own slice.',
    'Radar drawPlace rows (dash circle fogRadius * tilesize, Radar.java:42-46) -- presentation, not tick state; waits for its own slice.',
    'Radar read/write rows (progress, Radar.java:98-110) -- net/serialization, not tick state; waits for its own slice.',
    'Radar canPickup / progress() rows (canPickup false, Radar.java:75-77; progress() returns progress, Radar.java:93-95) -- pickup/accessor, not tick state; waits for its own slice.',
    'RepairTurret coolant optional consumer (repair-turret only: ConsumeCoolant, acceptCoolant, coolantUse 0.16f, coolantMultiplier 1.6f, Blocks.java:6404-6406; optional pass, BuildingComp.java:1979-1981) -- the tick models the power row only; the coolant row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'RepairTurret draw / drawSelect / drawPlace / icons rows (drawBeam, RepairTurret.java:106-150; draw, RepairTurret.java:164-174; drawSelect dash circle, RepairTurret.java:177-179; drawPlace dash circle, RepairTurret.java:95-99; icons, RepairTurret.java:102-104) -- presentation, not tick state; waits for its own slice.',
    'RepairTurret read/write rows (rotation, RepairTurret.java:236-249) -- net/serialization, not tick state; waits for its own slice.',
    'RepairTurret status() / range() rows (status() noInput when potentialEfficiency ~0, RepairTurret.java:226-228; range() returns repairRadius, RepairTurret.java:231-233) -- accessor/status, not tick state; waits for its own slice.',
    'RepairTurret per-def stat rows (repairSpeed 0.45f/3f, repairRadius 60f/145f, length 5f/6f, beamWidth 0.73f/1.1f, pulseRadius 5f/6.1f, Blocks.java:6386-6406) -- static defs, wait for their own verification slice.',
    'RepairTower liquid consumer row (consumeLiquid ozone 3f/60f, Blocks.java:6583) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'RepairTower suppression rows (suppressable = true, RepairTower.java:31; checkSuppression() zeroes warmup, RepairTower.java:69-72) -- needs suppression state the tick does not track yet.',
    'RepairTower draw / drawSelect / drawPlace / setStats / range / warmup rows (draw circle/glow, RepairTower.java:94-110; drawSelect dash circle, RepairTower.java:122-124; drawPlace dash circle, RepairTower.java:44-48; setStats range/repairSpeed, RepairTower.java:36-40; range() returns range, RepairTower.java:112-114; warmup() returns warmup, RepairTower.java:117-119) -- presentation/accessor, not tick state; waits for its own slice.',
    'RepairTower per-def stat rows (size 2, range 100f, healAmount 1.5f, graphite 90 / silicon 90 / tungsten 80, Blocks.java:6575-6583) -- static defs, wait for their own verification slice.',
    'ShockwaveTower liquid consumer row (consumeLiquids cyanogen 1.5f/60f, Blocks.java:2041) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'ShockwaveTower sense / warmup rows (sense(LAccess.progress) reloadCounter / reload, ShockwaveTower.java:110; warmup() returns heat, ShockwaveTower.java:117) -- logic/accessor, not tick state; waits for their own slice.',
    'ShockwaveTower draw / drawSelect rows (draw heatRegion / shape poly, ShockwaveTower.java:126-134; drawSelect dash circle, ShockwaveTower.java:137-139) -- presentation, not tick state; waits for their own slice.',
    'ShockwaveTower shape / timer fields rows (shapeRotateSpeed 1f / shapeRadius 6f / shapeSides 4, ShockwaveTower.java:39-40; timerCheck, ShockwaveTower.java:23; shake 2f, ShockwaveTower.java:29; cooldownMultiplier 1f, ShockwaveTower.java:34) -- static fields and the shape advance wait for their own slice.',
    'ShockwaveTower trigger row (Events.fire(Trigger.shockwaveTowerUse), ShockwaveTower.java:97) -- event, not tick state; waits for its own slice.',
    'ShockwaveTower per-def stat rows (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100, Blocks.java:2038-2044) -- static defs, wait for their own verification slice.',
    'ItemBridge shouldConsume gate (ItemBridgeBuild.shouldConsume() returns hadValidLink && enabled, ItemBridge.java:495-496; updateConsumption forces efficiency to 0 when the gate is false, BuildingComp.java:1960 + 1992-1994) -- RED decision: fold power-only and defer the gate (the PointDefenseTurret N2151 precedent); the port tracks no live link on any placed-building frame, so the driver needs a link frame input (public int link, ItemBridge.java:202) or a documented deferral; when unlinked power.status reads 1.0 while Java efficiency is 0.',
    'ItemBridge warmup / draw rows (warmup approach, ItemBridge.java:345; draw warmup `float warmup = hasPower ? this.warmup : 1f;`, ItemBridge.java:387; draw / drawSelect / drawConfigure / drawInput, ItemBridge.java:216-296, 375-394) -- presentation, not tick state; waits for its own slice.',
    'BufferedItemBridge rows (bridge-conveyor, no power def, hasPower false, BufferedItemBridge.java:18; bufferCapacity 14, speed 74f, Blocks.java:2112-2113; ItemBuffer transport, BufferedItemBridge.java:30-60) -- explicitly OUT of scope for this driver; the bridge-conveyor transport does not depend on power.status.',
    'ItemBridge per-def stat rows (size 1, range 12, transportTime 2f, phase-fabric 5 / silicon 7 / lead 10 / graphite 10, Blocks.java:2116-2125; arrowPeriod 0.9f / arrowTimeScl 2.75f, Blocks.java:2120-2121) -- static defs, wait for their own verification slice.',
    'LiquidBridge updateTransport advance (warmup >= 0.25f gate / moveLiquid / moved flag, LiquidBridge.java:22-26) -- the N2179 proof carries no transport/warmup/move keys; the warmup gate (LiquidBridge.java:23) is what the efficiency keys prove; the advance waits for its own slice.',
    'LiquidBridge doDump rows (dumpLiquid current 1f, LiquidBridge.java:29-31) -- liquid dumping waits for its own slice.',
    'LiquidBridge link / findLink / linkValid rows (findLink autolink over lastBuild, ItemBridge.java:167-180; linkValid, ItemBridge.java:145-165; link -1, ItemBridge.java:202; config Point2, ItemBridge.java:500) -- inherited from ItemBridge; needs tile/link state the tick does not track yet; config, not tick state.',
    'bridge-conduit rows (LiquidBridge, no power def, hasPower false, Blocks.java:2380; liquidCapacity 100f, range 4, Blocks.java:2379/2381) -- explicitly OUT of scope for this driver; the bridge-conduit transport does not depend on power.status.',
    'reinforced-bridge-conduit rows (DirectionLiquidBridge, Blocks.java:2432; hasPower false, no consumePower) -- different implementation class (extends DirectionBridge, not ItemBridge); explicitly OUT of scope, a different driver family if ever needed.',
    'LiquidBridge per-def stat rows (size 1, range 12, liquidCapacity 100f, phase-fabric 5 / silicon 7 / metaglass 20 / titanium 10, Blocks.java:2385-2397; arrowPeriod 0.9f / arrowTimeScl 2.75f, Blocks.java:2389-2390) -- static defs, wait for their own verification slice.',
    'StackConveyor shouldConsume gate -- StackConveyorBuild has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755-756, return enabled;) applies; the power-only fold is EXACT, no deferral needed.',
    'StackConveyor onProximityUpdate state machine (stateLoad / stateUnload / blendprox / proxUpdating, StackConveyor.java:217-261) -- needs tile proximity state the tick does not track yet.',
    'StackConveyor blends / rotatedOutput / drawPlanRegion rows (blends, StackConveyor.java:71-88; rotatedOutput, StackConveyor.java:106-112; drawPlanRegion, StackConveyor.java:90-104) -- autotiler/blending, not tick state; waits for its own slice.',
    'StackConveyor draw / drawCached rows (glow alpha by power.status, StackConveyor.java:156-158; stack/item draw, StackConveyor.java:151-192; drawCached, StackConveyor.java:124-149) -- presentation, not tick state; waits for its own slice.',
    'StackConveyor acceptStack / handleStack / removeStack / itemTaken / acceptItem rows (acceptStack, StackConveyor.java:344-348; handleStack, StackConveyor.java:357-363; removeStack, StackConveyor.java:365-372; itemTaken, StackConveyor.java:374-377; acceptItem, StackConveyor.java:379-387) -- item transfer waits for its own slice.',
    'StackConveyor dropped / overwrote / poofIn / poofOut rows (dropped, StackConveyor.java:194-204; overwrote, StackConveyor.java:319-327; poofIn/poofOut, StackConveyor.java:333-342) -- lifecycle/effects, not tick state; waits for its own slice.',
    'StackConveyor read/write rows (link / cooldown, StackConveyor.java:389-403) -- net/serialization, not tick state; waits for its own slice.',
    'plastanium-conveyor rows (StackConveyor, no power def, no hasPower line, Blocks.java:2084; health 90, speed 4f/60f, Blocks.java:2086-2088) -- explicitly OUT of scope for this driver; the plastanium-conveyor transport does not depend on power.status.',
    'StackConveyor per-def stat rows (size 1, speed 5f/60f, itemCapacity 10, health 130, surge-alloy 1 / tungsten 1, Blocks.java:2237-2253; glowAlpha 1f / glowColor Pal.redLight, StackConveyor.java:34-35) -- static defs, wait for their own verification slice.',
    'StackRouter shouldConsume gate -- StackRouterBuild has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755-756, return enabled;) applies; the power-only fold is EXACT, no deferral needed.',
    'StackRouter draw / drawCached rows (glow by power.status, StackRouter.java:78-87; drawCached, StackRouter.java:73-75; parent draw / drawSelect, DuctRouter.java:83-99) -- presentation, not tick state; waits for its own slice.',
    'StackRouter acceptItem / target rows (acceptItem facing gate, StackRouter.java:90-93; target() proximity scan with sortItem gate, DuctRouter.java:139-158; parent acceptItem, DuctRouter.java:160-164) -- needs tile/facing/proximity state the tick does not track yet; item acceptance waits for its own slice.',
    'StackRouter config / sortItem rows (config Item sortItem, DuctRouter.java:44-45; configClear, DuctRouter.java:46; buildConfiguration, DuctRouter.java:124-127; configured recache, DuctRouter.java:129-136; config() returns sortItem, DuctRouter.java:187-189; handleStack / handleItem set current, DuctRouter.java:173-185; removeStack clears current, DuctRouter.java:166-171) -- config, not tick state; waits for its own slice.',
    'StackRouter setStats / icons / drawPlanRegion rows (setStats itemsMoved, DuctRouter.java:48-53; icons, DuctRouter.java:55-57; drawPlanRegion, DuctRouter.java:59-64; minimapColor, DuctRouter.java:66-70; rotatedOutput, DuctRouter.java:72-74) -- presentation/stats, not tick state; waits for its own slice.',
    'StackRouter read/write rows (write sortItem id, DuctRouter.java:197-201; read sortItem, DuctRouter.java:203-209; version 1, DuctRouter.java:192-194) -- net/serialization, not tick state; waits for its own slice.',
    'StackRouter parent updateTile rows (progress += edelta() / speed * 2f, DuctRouter.java:102; progress >= (1f - 1f/speed), DuctRouter.java:105; progress %= (1f - 1f/speed), DuctRouter.java:111) -- overridden by StackRouterBuild.updateTile (StackRouter.java:28); the parent advance never runs for a surge-router.',
    'duct-router rows (DuctRouter, no power def, no hasPower line, Blocks.java:2193; health 90, speed 4f, Blocks.java:2195-2196) -- explicitly OUT of scope for this driver; the duct-router transport does not depend on power.status.',
    'router / distributor rows (Router, no power def, no hasPower line, Blocks.java:2139/2144) -- explicitly OUT of scope for this driver; the router transport does not depend on power.status.',
    'StackRouter per-def stat rows (size 1, speed 6f, itemCapacity 10, health 130, surge-alloy 5 / tungsten 1, Blocks.java:2255-2268; glowAlpha 1f / glowColor Pal.redLight, StackRouter.java:15-16) -- static defs, wait for their own verification slice.',
    'ImpactReactor power-production rows (getPowerProduction, PowerGenerator.java:156-158; productionEfficiency 0.0f, PowerGenerator.java:96; powerProduction 130f, Blocks.java:2636; warmup() returns productionEfficiency, PowerGenerator.java:105) -- the producer side waits for its own slice; this slice folds only the consumer-side power.status.',
    'ImpactReactor item consumer row (consumeItem blast-compound, Blocks.java:2643; consume() on timer, ImpactReactor.java:91-93) -- the tick models the power row only; the item row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'ImpactReactor liquid consumer row (consumeLiquid cryofluid 0.25f, Blocks.java:2644) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'ImpactReactor explosion rows (explosionDamage 1900 * 4, explosionRadius 12, explosionMinWarmup 0.3f, createExplosion / shouldExplode, PowerGenerator.java:120-146; onDestroyed, PowerGenerator.java:111-117) -- explosion waits for its own slice.',
    'ImpactReactor sense rows (sense(LAccess.heat) warmup, ImpactReactor.java:124-127) -- logic sensing waits for its own slice.',
    'ImpactReactor setBars / setStats rows (power bar net output, ImpactReactor.java:48-51; warmupTime stats, ImpactReactor.java:65-66) -- presentation, not tick state; waits for its own slice.',
    'ImpactReactor read/write rows (warmup, ImpactReactor.java:130-140; productionEfficiency / generateTime, PowerGenerator.java:166-177) -- net/serialization, not tick state; waits for its own slice.',
    'ImpactReactor draw rows (DrawMulti / DrawPlasma drawer, ImpactReactor.java:34) -- presentation, not tick state; waits for its own slice.',
    'ImpactReactor per-def stat rows (size 4, health 900, powerProduction 130f, itemDuration 140f, liquidCapacity 80f, requirements lead 500 / silicon 300 / graphite 400 / thorium 100 / surge-alloy 250 / metaglass 250, Blocks.java:2632-2645) -- static defs, wait for their own verification slice.',
    'ImpactReactor shouldConsume gate -- ImpactReactorBuild has NO shouldConsume override (nor does GeneratorBuild / PowerGenerator), so the BuildingComp default (BuildingComp.java:755-756, return enabled;) applies; the power-only fold is EXACT, no deferral needed.',
    'Accelerator canLaunch battery gate (efficiency > 0f && power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f && progress >= 1f && !launching, Accelerator.java:239-240; powerBufferRequirement 1,000,000f, Blocks.java:6826) -- needs battery state the tick does not track yet; the battery gate waits for its own slice; the power-only fold is EXACT for the efficiency side.',
    'Accelerator launch rows (buildConfiguration consume() / useBatteries / progress reset / renderer.showLaunch / Time.runTask launch, Accelerator.java:258-291; beginLaunch / endLaunch / updateLaunch / drawLaunch, Accelerator.java:324-...) -- launch waits for its own slice.',
    'Accelerator item consumer rows (consumeItems launchBlock.requirements, Accelerator.java:91; capacities / getMaximumAccepted / acceptItem, Accelerator.java:86, 293-299; itemCapacity 8000 class / core-nucleus sum in init, Accelerator.java:76, 85-90) -- the tick models the power row only; the item rows wait for their own slices, so the folded efficiency is the min over the modeled consumers (power only).',
    'Accelerator powerBufferRequirement bar rows (setBars powerBufferRequirement bar, Accelerator.java:105-109; getBatteryStored / powerBufferRequirement, Blocks.java:6826) -- presentation + battery state; waits for its own slice.',
    'Accelerator progress / isCoreBuilt rows (progress() returns progress, Accelerator.java:149-150; isCoreBuilt progress >= 1f, Accelerator.java:153-154; progress write/read, Accelerator.java:310, 318) -- the progress accessor + serialization wait for their own slice; the progress advance (Accelerator.java:143) is what the efficiency keys prove.',
    'Accelerator draw rows (draw arrows / launchBlock icons / charge rings / landing, Accelerator.java:157-...) -- presentation, not tick state; waits for its own slice.',
    'Accelerator drawSelect / drawLight / getCursor rows (drawSelect battery warning, Accelerator.java:250-255; drawLight, Accelerator.java:236-238; getCursor canLaunch hand, Accelerator.java:242-244) -- presentation, not tick state; waits for its own slice.',
    'Accelerator shouldConsume gate -- AcceleratorBuild has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755-756, return enabled;) applies; the power-only fold is EXACT, no deferral needed.',
    'Accelerator launch animator rows (LaunchAnimator: launchDuration() 120f+220f, Accelerator.java:324-325; landZoom/chargeZoom interps, Accelerator.java:53-54; chargeRings / ring params, Accelerator.java:56-60) -- launch animation waits for its own slice.',
    'Accelerator per-def stat rows (size 7, scaledHealth 80, powerBufferRequirement 1,000,000f, requirements copper 16000 / silicon 11000 / thorium 13000 / titanium 12000 / surge-alloy 6000 / phase-fabric 5000, Blocks.java:6823-6832) -- static defs, wait for their own verification slice.',
    'BuildTurret updateTile advance (unit tile/team sync / rotation follow / activelyBuilding lookAt / suppression zeroing / buildSpeedMultiplier + speedMultiplier by potentialEfficiency / warmup lerp / controlled vs autonomous branch / follower validation / plan search over team.data().plans / mimic nearby builder / plan validation / break-plan discard / suicide-plan removal / updateBuildLogic, BuildTurret.java:121-226) -- the N2184 proof carries no plan/follow/warmup/build keys; the build-speed fold (BuildTurret.java:136, `unit.buildSpeedMultiplier(potentialEfficiency * timeScale);`) is what the efficiency keys prove; the advance waits for its own slice.',
    'BuildTurret liquid consumer row (consumeLiquid nitrogen 3f/60f, Blocks.java:2006) -- the tick models the power row only; the liquid row waits for its own slice, so the folded efficiency is the min over the modeled consumers (power only).',
    'BuildTurret suppression rows (suppressable = true, BuildTurret.java:46; checkSuppression() zeroes efficiency + potentialEfficiency, BuildTurret.java:132-133; isHealSuppressed, BuildingComp.java:487) -- needs suppression state the tick does not track yet.',
    'BuildTurret unit rows (unitType turret-unit-build-tower, BuildTurret.java:56-68; unit() accessor, BuildTurret.java:113-119; canControl / buildRotation, BuildTurret.java:103-110; BlockUnitc unit create, BuildTurret.java:93) -- unit creation + control waits for its own slice.',
    'BuildTurret plan search / mimic rows (team.data().plans queue, BuildTurret.java:157; Build.validPlace + infiniteResources gate, BuildTurret.java:163; Units.nearby mimic, BuildTurret.java:176-187) -- needs team plan state the tick does not track yet.',
    'BuildTurret plan validation / break rows (timerTarget2 30f re-check, BuildTurret.java:193; isBuilder samePos breaking discard, BuildTurret.java:195-200; valid gate, BuildTurret.java:204-209) -- needs plan validation state the tick does not track yet.',
    'BuildTurret draw rows (baseRegion / shadow / glow additive by warmup / drawBuilding when efficiency > 0, BuildTurret.java:234-251) -- presentation, not tick state; waits for its own slice.',
    'BuildTurret read/write rows (rotation + plans, BuildTurret.java:259-278) -- net/serialization, not tick state; waits for its own slice.',
    'BuildTurret sense rows (sense buildX/buildY + senseObject building/breaking delegate to unit, BuildTurret.java:281-295) -- logic sensing waits for its own slice.',
    'BuildTurret warmup / setStats rows (warmup() returns warmup, BuildTurret.java:254-255; setStats buildSpeed percent, BuildTurret.java:81-84) -- accessor/stats, not tick state; waits for its own slice.',
    'BuildTurret per-def stat rows (size 3, range 200f, buildSpeed 1.5f, silicon 150 / oxide 40 / thorium 60, Blocks.java:1997-2006) -- static defs, wait for their own verification slice.',
    'LightBlock shouldConsume gate -- LightBuild has NO shouldConsume override, so the BuildingComp default (BuildingComp.java:755-756, return enabled;) applies; the power-only fold is EXACT, no deferral needed.',
    'LightBlock drawLight rows (drawLight lightRadius * min(smoothTime, 2f) + brightness * efficiency, LightBlock.java:127-128; lightRadius = radius*2.5f, LightBlock.java:40; lightClipSize / emitLight, LightBlock.java:41-42) -- presentation, not tick state; the brightness fold is what the efficiency keys prove; drawLight itself waits for its own slice.',
    'LightBlock config / color rows (config Integer color, LightBlock.java:35; configured / control / sense color, LightBlock.java:72-94; buildConfiguration color picker, LightBlock.java:109-115; onConfigureBuildTapped, LightBlock.java:117-127; config() returns color, LightBlock.java:132-133) -- config, not tick state; waits for its own slice.',
    'LightBlock init rows (lightRadius = radius*2.5f, LightBlock.java:40; lightClipSize = Math.max(lightClipSize, lightRadius * 3f), LightBlock.java:41; emitLight = true, LightBlock.java:42; brightness 0.9f / radius 200f class defaults, LightBlock.java:22-23) -- static defs + init, wait for their own slice.',
    'LightBlock drawPlace / changePlacementPath / minimapColor rows (dashCircle radius * 0.75f, LightBlock.java:48-53; placeRadius2 nodes, LightBlock.java:55-59; minimapColor color | 0xff, LightBlock.java:61-66) -- placement/presentation, not tick state; waits for its own slice.',
    'LightBlock draw rows (topRegion + color alpha 0.6f, LightBlock.java:96-102; topRegion @Load("@-top"), LightBlock.java:24) -- presentation, not tick state; waits for its own slice.',
    'LightBlock read/write rows (color int, LightBlock.java:137-148) -- net/serialization, not tick state; waits for its own slice.',
    'LightBlock env / placement flag rows (envEnabled space, swapDiagonalPlacement, LightBlock.java:32-33; hasPower / update / configurable / saveConfig, LightBlock.java:28-31) -- static flags, not tick state; wait for their own slice.',
    'LightBlock per-def stat rows (brightness 0.75f, radius 140f, graphite 12 / silicon 8 / lead 8, Blocks.java:6763-6767) -- static defs, wait for their own verification slice.',
    'ItemBridge config() getter / rebuild rows (config() returns the relative Point2, ItemBridge.java:500-502; write serializes link, ItemBridge.java:510-522; read restores link, ItemBridge.java:524-536) -- config serves rebuild/schematic (BuildingComp.java:2022-2026, "Tile configuration. Defaults to null. Used for block rebuilding."); the N2197 pure configure applies configs to the frame, but the getter + save/load round-trip wait for their own slice.',
    'ItemBridge draw / config UI rows (drawSelect / drawInput / drawConfigure, ItemBridge.java:223-296; draw, ItemBridge.java:371-394; draw warmup `float warmup = hasPower ? this.warmup : 1f;`, ItemBridge.java:387) -- presentation, not tick state; the N2197 pure configure covers the config handlers, but the draw/config UI waits for its own slice.',
    'ItemBridge handlePlacementLine (ItemBridge.java:184-193, `cur.config = new Point2(next.x - cur.x, next.y - cur.y);`) -- consecutive placement-line plans get a relative Point2 config pointing at the next plan; the port has no placement lines / BuildPlan list yet, so there is nothing to wire it to; waits for its own slice.',
    'ItemBridge pickedUp link reset (ItemBridge.java:205-207, `link = -1;`) -- a picked-up bridge unlinks; the generic pickup lifecycle exists (SourceBuildingLifecyclePickupState) but no bridge-specific link reset is wired; waits for its own slice.',
    'LiquidBridge tick blocks_match is implementation-loose for cross-def pairs (SourceLiquidBridgeBuildState recompute accepts any LiquidBridge implementation as the partner, but Java requires the SAME block def, ItemBridge.java:152, `other.block() == tile.block()` -- a phase-conduit must not validate against a bridge-conduit); the N2199 auto-link gathers a strict def match (other block id == this block id); the tick needs its own fix slice + proof update.',
    'BufferedItemBridge (bridge-conveyor) link frame state -- BufferedItemBridge extends ItemBridge (BufferedItemBridge.java:9) and inherits link/playerPlaced, but the port has no BufferedItemBridge driver or frame at all (N2178 out of scope); its link frame state + gate + auto-link wait for their own slices.',
    'playerPlaced for schematic / scenario placement -- Java calls playerPlaced only when the builder is the local player unit (ConstructBlock.java:106-109); the port runs auto-link only on the player click path (place_selected_block_at_world); schematic and scenario placement (add_source_block / source_place_schematic_state) place directly with no builder tracking, so their auto-link waits for builder tracking.',
    'ItemBridge drawPlace / drawPlanConfigTop link preview (ItemBridge.java:118-142, :82-96; findLink at :121) -- the placement preview draws the would-be link; draw-only, waits for its own slice.',
    'Separator items intake rows (frame["items"] is read by the N2200 gate but no live intake fills it yet -- acceptItem / conveyor delivery / dump into the building waits for its own slice; the gate reads the frame as-is, so a live separator with no intake stays below capacity and consumes).',
    'WallCrafter frame items intake (no live intake fills frame["items"] yet -- the offload/dump intake is the updateTile advance, WallCrafter.java:213-222, which waits for its own slice; the gate reads the frame as-is, so a live wall crafter with no intake reads 0 < itemCapacity and consumes).',
    'BurstDrill live items fill -- the N2203 gate reads frame["items"] from the shared drill frame (bound {} by the drill proximity path), but no live tick fills burst-drill items yet: the base-Drill driver fills frame["items"] only for its own primary cell and never ticks BurstDrill implementations, and the burst-drill offload (BurstDrill.java:104-107) waits for the updateTile advance slice; until then the live gate reads the empty inventory.',
    'Pump tick-scan proximity for the shouldConsume gate (N2205 calls source_pump_proximity_state every tick from the placed-pump driver; Java computes liquidDrop/amount only in onProximityUpdate, Pump.java:141-152, so the port re-scans the linked tiles each tick and rewrites the sprite source_pump_building meta each tick -- a proximity hook on the live path waits for its own slice).',
    'Pump shouldConsume gate on the scenario pump path (SourcePumpRuntimeState.source_pump_update_state pumps whenever liquidDrop != null with efficiency hardcoded 1.0 and never evaluates shouldConsume(); N2205 wires the gate only into the placed-pump driver, SourceMechanicalPumpBuildState; the scenario path waits for its own slice).',
    'PayloadLoader dynamic power consumer row (consumePowerDynamic, PayloadLoader.java:80; maxPowerConsumption 40f + basePowerUse when hasBattery() && !exporting, else basePowerUse) -- the tick models the power row only; the dynamic usage value waits for its own slice.',
    'PayloadLoader accept/handle payload rows (acceptPayload fits maxBlockSize, PayloadLoader.java:102-115; handlePayload, PayloadLoader.java:118-121) -- payload acceptance waits for its own slice.',
    'PayloadLoader live payload fill (moveInPayload / handlePayload set the payload, takePayload clears it, PayloadBlock.java:121-122, 145-147, 181-199; PayloadLoader.java:104-107) -- no live fill yet; the gate reads frame["payload"] as-is, and fill waits for its own slice (new deferral, N2208).',
    'PayloadUnloader live payload fill (no live fill sets frame["payload"] yet -- moveInPayload / handlePayload / takePayload is the updateTile advance, PayloadUnloader.java:50-110 / PayloadBlock.java:121-122, 145-149, 181-186, which waits for its own slice; the gate reads the frame as-is, so a live payload-unloader with no fill reads payload null and does not consume).',
    'PayloadDeconstructor live deconstructing fill (handlePayload / moveInPayload / updateTile advance, PayloadDeconstructor.java:98-101, 197-199 -- deconstructing = payload when moveInPayload succeeds; the N2210 gate reads frame["deconstructing"] as-is, so a live deconstructor with no fill reads null and never consumes; live fill waits for its own slice).',
    'RepairTurret live target acquire (target clear when dead / out of range / full health, RepairTurret.java:193-194; re-acquire every 20 ticks via Units.closest(team, x, y, repairRadius, Unit::damaged), RepairTurret.java:214-216) -- no live fill sets frame["target"] yet; the gate reads the frame as-is, so a live repair turret with no fill reads target null and does not consume; the acquire waits for the updateTile advance slice.',
    'RepairTower live targets refresh (no live refresh fills frame["targets"] yet -- the gate reads the frame as-is; the periodic refresh (potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval, refreshInterval 6f, Units.nearby(team, x, y, range, damaged), RepairTower.java:59-65) waits for the updateTile advance slice, so a live repair tower with no refresh reads the empty list and does not consume).',
    'RegenProjector targets computation live fill (no live fill sets frame["any_targets"] yet -- the gate reads the frame as-is; the indexer range query (updateTargets, RegenProjector.java:115-119; indexer.eachBlock over buildings in range 28, RegenProjector.java:118) and the contains-damaged fold (anyTargets = targets.contains(b -> b.damaged()), RegenProjector.java:139) wait for the updateTile advance slice, so a live regen-projector with no fill reads any_targets false and does not consume).',
    'BuildTurret live plans / suppression fill (no live fill sets frame["plans"] or frame["heal_suppressed"] yet -- the gate reads the frame as-is; the plan search over team.data().plans (BuildTurret.java:156-171), the mimic of nearby builders (BuildTurret.java:176-187), the plan validation / break-plan discard (BuildTurret.java:189-215), and the heal suppression application (applyHealSuppression, BuildingComp.java:482-485; isHealSuppressed, BuildingComp.java:487-489) wait for the updateTile advance slice, so a live build tower with no fill reads the empty plan list and does not consume).',
    'Constructor live recipe config fill (no live fill sets frame["recipe"] yet -- the gate reads the frame as-is; the config path (config(Block.class, ...) set when canProduce, Constructor.java:32-37; configClear clears to null, Constructor.java:31/38) waits for its own slice, so a live constructor with no fill reads recipe null and does not consume).',
    'BurstDrill updateTile timerDump dump + offload effects + offload neighbor routing (if(timer(timerDump, dumpTime / timeScale)){ dump(items.has(dominantItem) ? dominantItem : null); }, BurstDrill.java:83-85; Effect.shake / drillSound / drillEffect, BurstDrill.java:114-118; offload neighbor acceptItem/handleItem scan, BuildingComp.java:1001-1017) -- the timer dump waits for timer infra (no source_timer/timer_state helper in the port, the N2193 precedent); the shake/sound/drillEffect presentation waits for its own slice; offload currently takes the no-neighbor fallback branch (handleItem(self(), item), BuildingComp.java:1017) via the shared inventory add_item_state helper, so a burst drill with an accepting neighbor still fills its own store -- the neighbor routing waits for its own slice. N2219 advances progress / warmup / timeDrilled / lastDrillSpeed / smoothProgress / invertTime and the offload itself.',
    'SolidPump updateTile live fraction fill (onProximityUpdate validTiles/boost, SolidPump.java:150-159; attribute env(), Attribute.java:31-34) -- the N2220 advance takes fraction inputs explicit (frame valid_tiles/boost/attribute_env, default 0f) and computes the fraction + pump from them, but no live proximity fill sets them yet: boost = sumAttribute(attribute, tile.x, tile.y) / size / size and the canPump scan over linked tiles need tile attribute/proximity state the tick does not track for SolidPump; the N2087 pump proximity helper does not apply (it scans floor liquidDrop/liquidMultiplier, not solid-tile attributes), and the water attribute env() reads state envAttrs the port does not model; the live fill waits for its own slice.',
    'SolidPump dumpLiquid + updateEffect (dumpLiquid(result), SolidPump.java:140; updateEffect chance, SolidPump.java:131-132) -- the N2220 advance pumps into the store but does not dump: the dump needs neighbor liquid transfer (the routing gate exists in SourceBuildingLiquidDumpState and the scenario pump wires source_pump_dump_liquid_state, but no solid-pump driver wires the transfer yet); the updateEffect is presentation (Fx.none by default, SolidPump.java:23); both wait for their own slice.',
    'Pump dumpLiquid on the placed-pump path (dumpLiquid(liquidDrop), Pump.java:178-180) -- N2221 advances maxPump / liquids.add / warmup / totalProgress / consTimer but does not dump: the scenario-path dump helper (SourcePumpRuntimeState.source_pump_dump_liquid_state) is bound to the scenario frame and its own capacity, so the placed pump keeps its pumped liquid until a placed-path dump slice lands; the scenario pump path stays untouched.',
    'Separator shouldAmbientSound row (shouldAmbientSound efficiency > 0, Separator.java:87-89) -- lifecycle/sound, not tick state; waits for its own slice. (The created() seed init it shared an entry with is live since N2222: the driver seeds a fresh frame from Point2.pack(tile) like created(), Separator.java:82-84.)',
    'Separator timerDump dump (if(timer(timerDump, dumpTime / timeScale)){ dump(); }, Separator.java:165-167) -- the port has no timer helper (no source_timer / timer_state in SourceBuilding*.gd); N2222 advances progress/warmup/totalProgress/consume/offload but never dumps held items to neighbors, so a separator keeps its output until the dump slice lands.',
    "Separator offload neighbor routing (BuildingComp.java:1001-1016, the proximity acceptItem/canDump scan in offload()) -- N2222 offloads through offload_item_state with an empty routing context (no neighbor acceptItem query exists for separators), so the picked result always falls back to the separator's own items (the Java no-neighbor-accepts outcome) until a proximity fill lands.",
    'WallCrafter updateTile live fill (getEfficiency adjacent-solid-tile attribute scan, WallCrafter.java:141-180; timerUse booster consume, WallCrafter.java:207-209; timerDump dump, WallCrafter.java:220-222; offload neighbor routing, BuildingComp.java:1001-1014; updateEffect chance, WallCrafter.java:196-205; disabled early return, BuildingComp.java:1954-1957) -- N2223 advances warmup / eff / lastEfficiency / time / totalTime / offload-to-inventory with the base efficiency as frame input efficiency_factor (default 0.0, no live fill yet), item_valid (default false) and has_liquid_booster (default false; false for both defs -- the large def hydrogen consumer is not .boost(), Blocks.java:3028, so hasLiquidBooster stays false, WallCrafter.java:106); the live getEfficiency fill, the timer-gated consume/dump (no timer helper in the port), the neighbor offload routing (the port offloads to own inventory only), and the updateEffect chance wait for their own slices, and the advance runs only when enabled (Java runs updateTile even when disabled, BuildingComp.java:2276-2278, with warmup decaying via the disabled early return -- the driver-wide disabled-early-return slice removes this gate for all families); until the getEfficiency fill lands a live cliff-crusher never accumulates time.',
    'Fracker dumpLiquid (else branch) (dumpLiquid(result), Fracker.java:43) -- the N2224 advance decays warmup and zeroes lastPump when efficiency is 0 but does not dump: the dump needs neighbor liquid transfer (the routing gate exists in SourceBuildingLiquidDumpState and the scenario pump wires source_pump_dump_liquid_state, but no fracker driver wires the transfer yet); the super.updateTile() dump (SolidPump.java:140) and the updateEffect chance (SolidPump.java:131-132; the oil-extractor def sets updateEffect = Fx.pulverize, updateEffectChance = 0.05f, Blocks.java:2967-2968) stay covered by the N2220 "SolidPump dumpLiquid + updateEffect" entry; the Fracker else-branch dump waits for its own slice.',
    'Fracker item intake (sand into the frame items dict) -- the N2224 advance removes 1 sand from frame["items"] when the accumulator reaches itemUseTime (consume(), Fracker.java:33, via ConsumeItems.trigger, ConsumeItems.java:44-48), but no live intake fills the frame items dict yet: a placed fracker starts with an empty items dict, so consume() clamps to the held count (ItemModule.remove, ItemModule.java:258-263) until an intake slice lands; the item consumer efficiency row stays covered by the "Fracker item / liquid rows" entry.',
    'ItemBridge checkAccept facing (checkAccept, ItemBridge.java:441-463; Edges.getFacingEdge + relativeTo facing comparison, ItemBridge.java:445-458) -- the N2225 transport path takes the linked() shortcut (linked(source), ItemBridge.java:464-466), which is always true when hadValidLink holds, so acceptItem there is the capacity gate only; the general facing gate for non-linked sources (a conveyor feeding a bridge from the side) needs facing/geometry state the tick does not track yet; waits for its own slice.',
    'ItemBridge doDump / dumpAccumulate (doDump(), ItemBridge.java:350-353; dumpAccumulate(), BuildingComp.java:1048-1061; dump(), BuildingComp.java:1064-1072) -- the unlinked branch of the N2225 advance zeroes warmup but does not dump: dump needs proximity + neighbor acceptItem/canDump queries the item-bridge driver does not gather (the routing gate exists in SourceBuildingItemDumpState, but no bridge driver wires the transfer yet); waits for its own slice.',
    'ItemBridge live items intake (no live intake fills frame["items"] yet -- acceptItem / conveyor delivery / dump into the building waits for its own slice; the N2225 transport advance reads the frame as-is, so a live bridge with no intake has nothing to transport).',
    'ItemBridge timerCheckMoved / wasMoved snapshot (if(timer(timerCheckMoved, 30f)){ wasMoved = moved; moved = false; }, ItemBridge.java:320-323) -- no timer helper in the port; the N2225 advance sets moved on handoff but never snapshots it into wasMoved, so wasMoved stays the frame input and the timeSpeed approach reads it as-is; the 30-tick snapshot + reset waits for its own slice.',
    'RegenProjector updateTile live fill (updateTargets indexer range query over buildings in range 28, RegenProjector.java:115-119; optionalTimer consume() of the phaseFabric booster, RegenProjector.java:142-144; mendMap flush application + cadence, RegenProjector.java:168-177; effect chance, RegenProjector.java:160-162; suppression live fill, BuildingComp.java:1336-1346; disabled early return, BuildingComp.java:1954-1957) -- N2228 advances warmup / totalTime / optionalTimer / didRegen / anyTargets / mendMap accumulation on the frame with targets as the frame input (each entry: pos, block_health, health, damaged, heal_suppressed; default []), suppressed as the frame input (default false) and tile_changes as the frame input (default 1, World.java:35); the live indexer fill, the consume() item removal (Consume.trigger runs every consumer, BuildingComp.java:1911-1915, and ConsumeItems.trigger removes phaseFabric, ConsumeItems.java:44-48; the frame tracks no items), the mendMap flush (mendMap is static-shared across projectors, RegenProjector.java:23, and the flush heals live buildings via world.build(pos), which the port has no frames for), the effect chance (no RNG in the pure advance) and the disabled early return wait for their own slices, and the advance runs only when enabled (Java runs updateTile even when disabled, BuildingComp.java:2276-2277, with warmup decaying via the disabled early return -- the driver-wide disabled-early-return slice removes this gate for all families); until the targets fill lands a live regen-projector reads any_targets false and does not consume.',
    'RepairTower live targets refresh scan + heal application (Units.nearby(team, x, y, range, damaged), RepairTower.java:62-66; target.heal(healAmount * edelta()), RepairTower.java:78) -- N2227 models the refresh cadence + clear and returns the heal amounts as a pure result (frame["heal_amounts"]), but no live unit query fills the targets (the refill is a supplied list; the tick supplies the frame targets) and no heal is applied to a live unit; the scan + application wait for their own slice.',
    'RepairTower suppression live fill (checkSuppression() / isHealSuppressed(), BuildingComp.java:1336/487-489; suppressable = true, RepairTower.java:31) -- N2227 models the suppressed branch on the frame heal_suppressed input (warmup = 0f, early return), but no live fill sets frame["heal_suppressed"] yet; the suppression application (applyHealSuppression, BuildingComp.java:482-485) waits for its own slice.',
    'RepairTurret updateTile live fill (heal application `target.heal(repairSpeed * strength * edelta() * multiplier);` (RepairTurret.java:207) -- the N2226 advance returns heal_amount as a pure result and does not write into another unit frame, so a live repair turret reports the amount but no unit health changes; timer(timerTarget, 20) re-acquire cadence (RepairTurret.java:214-216) -- the pure selection over an explicit candidate list is live in N2226, but there is no timer helper in the port and no live unit query, so the driver passes an empty candidate list and no live re-acquire happens; coolant multiplier (RepairTurret.java:189-191, `multiplier = 1f + liquids.current().heatCapacity * coolantMultiplier * optionalEfficiency;`) -- the advance uses multiplier 1.0 until the coolant optional consumer row lands (see the RepairTurret coolant optional consumer entry); offset/lastEnd draw mutation (drawBeam, RepairTurret.java:106-150) -- offset is only zeroed by updateTile, its non-zero values come from draw) -- the live fill waits for its own slice.',
    'PayloadDeconstructor Fx.breakBlock finish effect (Fx.breakBlock.at(x, y, deconstructing.size() / tilesize), PayloadDeconstructor.java:191) -- effects/presentation, not tick state; waits for its own slice; N2233 clears deconstructing / accum on finish without it.',
    "PayloadDeconstructor moveInPayload live payload positioning (updatePayload, PayloadBlock.java:174-177: payload.set(x + payVector.x, y + payVector.y, payRotation), called from moveInPayload, PayloadBlock.java:189) -- the port's payload dict carries no position, so the live payload positioning waits for its own slice; N2233 ports the payVector approach + hasArrived arrival check, and the rotate=false intake never takes the rotation branch (PayloadBlock.java:191-193).",
    'PayloadDeconstructor puddles liquid dump (progress == 0f && shift > 0f && BuildPayload: dump build liquids to floor puddles, PayloadDeconstructor.java:147-156; Puddles.deposit per linked tile) -- the port has no Puddles / floor-liquid model, so the begin-deconstruction liquid dump waits for its own slice; N2233 advances progress / accum without it.',
    'PayloadLoader live front gather (front(), BuildingComp.java:550-553; canDump / canMove, PayloadBlock.java:210-211) -- the driver passes no-front defaults (front absent, not solid, no payload flags) because the catalog carries no outputsPayload / acceptsPayload flags and the front tile lookup is not wired; the live gather waits for its own slice.',
    'PayloadLoader load timer cadence (timer(timerLoad, loadTime / efficiency), PayloadLoader.java:157) -- no timer helper in the port; the N2231 pure advance takes an explicit load_tick and the driver passes false, so no live load tick ever fires; the cadence waits for a timer-infra slice.',
    'PayloadLoader movePayload / dumpPayload application (movePayload, BuildingComp.java:819-829; dumpPayload, PayloadBlock.java:230-241; pushOutput unit push, PayloadBlock.java:75) -- needs the live front building + proximity; the N2231 advance reports payload_moved / payload_dumped / pushed_output_fraction through the reused moveOut helper, but the handoff to the front build and the payload.dump() success wait for their own slice.',
    'PayloadLoader payload acceptItem / acceptLiquid per-type rows (default BuildingComp.java:864-870 + StorageBlock open-item rule, StorageBlock.java:54-56 + LiquidRouter open-liquid rule, LiquidRouter.java:41-43 + LiquidVoid accept, LiquidVoid.java:34-36 -- modeled by N2231) -- other payload-block overrides (CoreBlock acceptItem, CoreBlock.java:694-696; conduit/router acceptLiquid gates) wait for their own slice.',
    'PayloadLoader payload dict contract unify (N2231 defines its own payload contract: block flags + build items/liquids/power_status) -- the N2232/N2233 payload slices define theirs separately; unifying the contract waits for its own slice.',
    'PayloadLoader super.updateTile payload update (payload.update(null, this), PayloadBlock.java:158-162) -- the payload entity update; the port has no live payload entity, so the N2231 advance skips it; waits for its own slice.',
    'PayloadUnloader dump rows (dumpLiquid(liquids.current()) + offloadSpeed x dumpAccumulate(), PayloadUnloader.java:104-110 -- no dump infra on this path; unloaded items/liquids accumulate in the frame until a dump slice lands).',
    'PayloadUnloader live front query (front(), PayloadBlock.java:209 -- the moveOut front flags arrive as explicit driver params, the driver passes front-absent until a live-neighbor query slice lands; a live payload-unloader never moves its payload into a front building until then).',
    'PayloadUnloader movePayload/dumpPayload application (moveOutPayload movePayload/dumpPayload, PayloadBlock.java:219-229 -- needs a live front building / payload dump; the pure advance reuses SourceBlockProducerMoveOutPayloadState and reports payload_moved/payload_dumped, the application waits for its own slice).',
    'PayloadUnloader payload entity update + breakEffect presentation (payload.update(null, this), PayloadUnloader.java:51-53; updatePayload() positions the live payload entity, PayloadBlock.java:174-179 -- no live payload entity in the port; payload.block().breakEffect.at(...), PayloadUnloader.java:58 -- presentation; the instant-deconstruct payload = null clear IS modeled since N2232).',
    'PayloadUnloader power-production graph wiring (getPowerProduction returns lastOutputPower, PayloadUnloader.java:44-47; frame last_output_power live since N2232, but SourcePlacedPowerDistributionRuntimeState builds producers from the static block property powerProduction, so the graph cannot see the dynamic value until a distribution-runtime slice reads the frame).',
    'PayloadUnloader updateTile timer cadence (timer(timerLoad, loadTime / efficiency), PayloadUnloader.java:69 -- no timer helper in the port; the pure advance takes load_tick, the driver passes false until a timer-infra slice lands; unload items never fire live until then).',
    'PointDefenseTurret updateTile live fill (timer(timerTarget, retargetTime) re-acquire cadence (PointDefenseTurret.java:65-67, retargetTime 5f) -- the pure retarget over an explicit bullet list is live in N2229, but there is no timer helper in the port and no live bullet query, so the driver passes retarget_tick false and an empty list and no live retarget happens; live bullet scan fill (Groups.bullet.intersect, PointDefenseTurret.java:66) -- the rect intersect over live bullets waits for a bullet-query slice; coolant live fill (updateCooling, ReloadTurret.java:28-41) -- the advance models cooling with explicit params, but the segment def has no ConsumeCoolant consumer (BaseTurret.init :50-51 findConsumer returns null), so the driver passes coolant absent and cooling never runs live; damage application on the live bullet (`target.damage(target.damage() - realDamage);` / `target.remove();`, PointDefenseTurret.java:89-91) -- the N2229 advance returns target_damage_remaining / target_removed as pure results and does not write into another bullet frame, so a live segment reports the shot but no bullet damage changes; beam / hit / shoot effects + shootSound (PointDefenseTurret.java:94-99) -- presentation, waits for its own slice) -- the live fill waits for its own slice.',
    'TractorBeamTurret updateTile live fill (timer(timerTarget, retargetTime) retarget cadence (TractorBeamTurret.java:87-90) -- the pure closestEnemy selection over an explicit candidate list is live in N2230, but there is no timer helper in the port and no live unit query, so the driver passes retarget_tick false and an empty candidate list and no live retarget happens; live enemy scan fill (Units.closestEnemy rect scan + targetable/inFogTo, Units.java:296-313) -- the candidates are explicit inputs, so a live parallax never acquires a target on its own; coolant live fill (coolant consume, TractorBeamTurret.java:92-106) -- the branch is modeled with explicit inputs but the driver passes coolant_present false (parallax has no ConsumeCoolant consumer, Blocks.java:3640-3653) and no liquids store exists on the frame, so no live coolant is ever consumed; damage/impulse/status application (damageContinuousPierce / impulseNet / apply, TractorBeamTurret.java:125-133) -- the N2230 advance returns damage_dealt / impulse / status_applied as pure results and does not write into another unit frame, so a live parallax reports the amounts but no unit health or velocity changes; sound loop + laser draw (control.sound.loop, TractorBeamTurret.java:113; draw laser, TractorBeamTurret.java:152-176) -- presentation, not tick state) -- the live fill waits for its own slice.',
    'UnitCargoLoader updateTile live canCreate check (Units.canCreate(team, unitType) live cap evaluation, Units.java:115-117 -- the N2234 pure advance takes can_create as an explicit param, default true; the driver passes true until the N2140 live helper is wired for this family (manifold keeps the UnitType default useUnitCap = true, UnitType.java:205, so the cap check is live, not vacuous); the placement gate canPlaceOn (UnitCargoLoader.java:65-68) still waits for its own slice).',
    'UnitCargoLoader updateTile live unit fill (Groups.unit.getByID live query + live unit creation/application: unitType.create + BuildingTetherc building(this) + unit.set/add + Call.unitTetherBlockSpawned + Fx.spawn, UnitCargoLoader.java:98-103/114-122/127-133 -- the N2234 pure advance takes found_unit as an explicit param (the driver passes null: no live fill yet) and reports the spawn as the pure result spawned_unit, but creates no live unit entity and fires no remote call; the disabled early return (BuildingComp.java:1954-1957) also waits for the driver-wide slice, so the port keeps the enabled gate (the N2195 precedent).',
    'BaseShield updateTile live fill (live bullet scan fill (Groups.bullet.intersect, BaseShield.java:96) -- the rect intersect over live bullets waits for a bullet-query slice; live enemy-unit scan fill (Units.nearbyEnemies, BaseShield.java:97) -- the nearby-enemies query waits for a unit-query slice; absorb application on the live bullet (bullet.absorb(), BulletComp.java:100-103, absorbed = true + remove()) -- the N2236 advance returns absorbed_bullets as a pure result and does not write into another bullet frame; repel/kill application on live units (unit.vel.setZero() / unit.move(...) / unit.kill(), BaseShield.java:45-50) -- the N2236 advance returns repelled_units / killed_units as pure results and does not write into another unit frame; circleColorSpark effect chance (Mathf.chanceDelta(0.12f * Time.delta), BaseShield.java:52-53) -- presentation, waits for its own slice; the disabled early return (BuildingComp.java:1954-1957) also waits for the driver-wide slice, so the port keeps the enabled gate (the N2195 precedent)) -- the live fill waits for its own slice.',
    'ForceProjector absorbExplosion rows (absorbExplosion, ForceProjector.java:271-281; absorb = !broken && isInRegularPolygon(...), hit = 1f, buildup += damage * crashDamageMultiplier 2f) -- explosion absorption is a separate method from updateTile, not the deflectBullets path; waits for its own slice.',
    'ForceProjector updateTile live fill (timer(timerUse, phaseUseTime / timeScale) cadence + consume() application + Groups.bullet live scan + bullet.absorb() application + coolant live fill (coolantConsumer.efficiency + liquids.current().heatCapacity) + Fx.reactorsmoke / shieldBreakEffect / breakSound / Trigger.forceProjectorBreak, ForceProjector.java:207-268) -- N2235 advances phaseHeat / radscl / warmup / buildup / broken / hit / deflect as a pure function with explicit inputs, but the driver passes consume_tick false, no item/coolant state and an empty bullet list (no timer helper, no items/liquids store on the frame, no live bullet query); the live fill waits for its own slice.',
    'LaunchPad updateTile LaunchPayload entity creation/application (LaunchPayload.create() + entity.set(this) + lifetime(120f) + team + add(), LaunchPad.java:150-155) -- no live entity in the port; N2238 reports the launch as the pure result launched_stacks (the items.each stacks copy, zero amounts skipped like ItemModule.each) + launched + the cleared items; the live entity creation/application waits for its own slice.',
    'LaunchPad updateTile disabled / cheating / no-power advance (BuildingComp.java:2274/2276-2277 updateConsumption then the `if(enabled || !block.noUpdateDisabled){` updateTile gate; Java runs updateTile even when disabled, with the counter frozen by the zeroed efficiency, BuildingComp.java:1954-1957) -- the driver runs the advance only when enabled (the N2195 coordinator-fix precedent); a pad with no power consumer or a cheating team never folds efficiency, so the advance reads the stale/absent frame efficiency (0.0 default) and the counter freezes; the driver-wide disabled-early-return slice removes this gate for all families.',
    'LaunchPad updateTile launch sound / effects (launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand)) + Fx.launchPod.at(this) + Effect.shake(3f, 3f, this), LaunchPad.java:149/156/158) -- sound/presentation; N2238 launches silently (pure result only); waits for its own slice.',
    'MassDriver bullet entity / DriverBulletData rows (bullet.create MassDriverBolt, MassDriver.java:307-309; DriverBulletData pool, MassDriver.java:104-112; shootEffect / smokeEffect / Effect.shake / shootSound, MassDriver.java:311-316) -- bullet entity creation + presentation defer; N2237 ports fire() as items leaving the self frame + fired_items / fired_total / bullet_damage / bullet_speed / bullet_lifetime pure results.',
    'MassDriver dumpAccumulate / dump rows (dumpAccumulate when idle/accepting, MassDriver.java:164-166; dump cadence dumpAccum += delta() / while(dumpAccum >= 1f), BuildingComp.java:1053-1060) -- N2237 ports the state machine but not the dump: dumpAccumulate needs proximity + neighbor acceptItem/canDump queries the mass-driver driver does not gather; the dump waits for its own slice.',
    'MassDriver fire arrival / Time.run cleanup (timeToArrive = min(bulletLifetime / timeScale, dst / (bulletSpeed * timeScale)) + Time.run arrival, MassDriver.java:209-214; other.waitingShooters.remove(this) + other.state = idle on arrival) -- no Time.run in the port, so the arrival cleanup waits for its own slice; N2237 returns the fired items + bullet params as pure results.',
    'StackConveyor live front() query (front(), BuildingComp.java:550-554; if(front() instanceof StackConveyorBuild e && e.team == team && e.link == -1){, StackConveyor.java:303) -- the N2239 advance takes an explicit front dict and returns front_updated values (front_items / front_last_item / front_link / front_cooldown) for the driver to write back (the N2225 partner precedent), but no live front() query fills it yet: the driver passes the no-front default, so a live stack conveyor never transfers until the front-building lookup + frame write-back land.',
    'StackConveyor live items intake (no live intake fills frame["items"] yet -- acceptItem / handleStack / conveyor delivery / dump into the building waits for its own slice, see the existing acceptStack / handleStack entry; the N2239 advance reads the frame as-is and the transfer branch is the only live fill, which itself waits on the front() query above, so a live stack conveyor with no intake has nothing to reel, unload, or transfer).',
    'StackConveyor moveForward / dump application (moveForward, BuildingComp.java:1129-1137; dump(Item), BuildingComp.java:1072-1113; while(lastItem != null && !outputRouter ? moveForward(lastItem) : dump(lastItem)), StackConveyor.java:290) -- the N2239 advance takes explicit move_forward_ok / dump_ok bools (the per-tick live answers, assumed stable within the tick) and drains lastItem through the shared inventory helpers, but no live neighbour query fills them yet: moveForward needs front() + acceptItem + handleItem on the front building and dump needs the proximity acceptItem/canDump scan with cdump rotation (BuildingComp.java:1072-1113, 1115-1120); the driver passes false for both, so a live stack conveyor never unloads until the neighbour queries land; the poofOut link = -1 state effect IS modeled (the unloadEffect.at(this) presentation stays under the existing poofIn/poofOut entry).',
    'StackRouter updateTile live fill (target() live proximity selection `var target = target();` (StackRouter.java:47) -- DuctRouter.target() (DuctRouter.java:139-156) scans proximity with cdump rotation + sortItem/rotation gates + acceptItem, and the port has no live proximity query, so the driver passes an empty targets list and no live handoff happens; the pure advance pops the explicit ordered list, one entry per target() call, with cdump rotation simulated by list order -- to model N items to the same target, repeat its entry N times; handleItem application `target.handleItem(this, current);` (StackRouter.java:49) -- the N2240 advance returns handed_off/handed_to as pure results and does not write into another building frame, so a live surge-router reports the handoff but no target inventory changes) -- the live fill waits for its own slice.',
    'OverdriveProjector useProgress consume() rows (useTime 400f / overdrive-dome 300f, OverdriveProjector.java:117-120) -- N2194 advances useProgress and wraps it at useTime, but consume() needs item infrastructure (phaseFabric / silicon); the dome hasBoost = false (Blocks.java:1960) phaseHeat-stays-0 behaviour is modeled since N2194; the consume side effect waits for its own slice.',
    'OverdriveProjector draw / drawLight / drawSelect / drawPlace rows (draw top region + ring, OverdriveProjector.java:137-158; drawLight smoothEfficiency-scaled light, OverdriveProjector.java:92-94; drawSelect range circle + target highlight, OverdriveProjector.java:128-133; drawPlace range circle, OverdriveProjector.java:54-61) -- presentation, not tick state; waits for its own slice.',
    "LaunchPad shouldConsume gate cheating-path counter advance -- the driver skips the consumption block when cheating (the N2172 guard), so a cheating pad's launchCounter never advances even though Java updateTile still runs after updateConsumption (BuildingComp.java:2274-2278) with efficiency = shouldConsume() ? potentialEfficiency : 0f (BuildingComp.java:1944-1947); the cheating-path advance waits for its own slice.",
    'LaunchPad updateTile launch fire (launchSound / LaunchPayload create / items.each stacks / lifetime / Fx.launchPod / items.clear / launchCounter reset, LaunchPad.java:147-159) -- N2186 tracks launchCounter and advances it by edelta (the counter half of LaunchPad.java:146); the launch fire itself (consume() + pod + clear + reset, `launchCounter = 0f;`, LaunchPad.java:159) waits for its own slice, so a full pad never launches and its counter freezes at launchTime with the gate closed; the N2186 proof carries no launch/payload keys.',
    'BeamDrill draw / drawSelect rows (draw lasers/glow/sparks, BeamDrill.java:275+; drawSelect drawItemSelection, BeamDrill.java:231-234) -- presentation, not tick state; waits for its own slice.',
    'OverdriveProjector range / phase-range rows (realRange = range + phaseHeat * phaseRangeBoost, OverdriveProjector.java:110) -- the tick tracks phaseHeat since N2194, but realRange is only consumed by the deferred boost application (OverdriveProjector.java:113) and drawSelect; waits for the boost-application slice.',
    'ImpactReactor consume-timer rows (timer(timerUse, itemDuration / timeScale), ImpactReactor.java:91; consume(), ImpactReactor.java:92; itemDuration 140f, Blocks.java:2637) -- needs timer + item/liquid consumption infrastructure the tick does not track yet; the N2192 advance runs the warmup/totalProgress/productionEfficiency lines only.',
    'ShockwaveTower fire reset (reloadCounter = 0f, ShockwaveTower.java:84) -- the reset only happens when the fire gate finds bullets (ShockwaveTower.java:73-85); the bullet scan waits for its own slice, so the port never resets the counter once charged: a fully charged tower stays charged with the gate false (efficiency 0) until the fire slice lands.',
    'BeamDrill disabled-early-return rows (BuildingComp.java:1954-1957, potentialEfficiency = efficiency = optionalEfficiency = 0f; when disabled -- the driver skips the consumption fold when disabled and leaves frame efficiency stale, so the N2195 advance is gated on enabled and a disabled beam drill warmup/time freeze in the port instead of warmup decaying toward 0 and time freezing via edelta 0 as in Java; the driver-wide disabled-early-return slice fixes this for all families).',
    'Accelerator launchTime / cloudSeed rows (launchTime, Accelerator.java:124, set in updateLaunch, Accelerator.java:419, reset in endLaunch, Accelerator.java:394; cloudSeed, Accelerator.java:126, set in beginLaunch, Accelerator.java:340) -- launch-animation state, not tick state; waits for the launch-sequence slice.',
    'ImpactReactor impactPower event rows (prevOut / getPowerProduction() > consPower.requestedPower(this), ImpactReactor.java:80, 87-88; Events.fire(Trigger.impactPower), ImpactReactor.java:88) -- needs getPowerProduction() and consPower.requestedPower(this) from the power graph, which the port does not model yet; the N2192 advance tracks warmup/totalProgress/productionEfficiency but fires no event.',
    'ShockwaveTower updateTile advance (fire gate / bullet scan / wave damage / heat / cooldown, ShockwaveTower.java:73-104) -- N2187 models the reloadCounter charge (ShockwaveTower.java:73, `(reloadCounter += edelta())`, edelta() = efficiency * delta(), BuildingComp.java:1927-1929) and the shouldConsume gate (ShockwaveTower.java:121-122); the bullet scan / wave damage / heat / cooldown wait for their own slice; the N2187 proof carries no wave/heat/target keys.',
    'ShockwaveTower random reloadCounter init (public float reloadCounter = Mathf.random(reload);, ShockwaveTower.java:67) -- Mathf.random(reload) is uniform in [0, reload) (Mathf.java:279-282, 0 inclusive, range exclusive), so the gate is always true at spawn; the port starts a fresh frame at 0.0, which preserves the gate outcome at spawn but not the time-to-first-fire; the random initial offset waits for its own slice.',
    'BeamDrill dump timer (timer(timerDump, dumpTime / timeScale) + dump(), BeamDrill.java:264-266) -- needs timer + items/dump infrastructure the tick does not track yet.',
    'Accelerator launching flag transitions (beginLaunch sets launching = true, Accelerator.java:334-337; endLaunch sets launching = false, Accelerator.java:392-394; Time.runTask sets launching = false, Accelerator.java:277) -- the flag exists as frame state defaulting false; setting it true waits for the launch-sequence slice, so the launching branch of the updateTile advance (Accelerator.java:134-138, 140) only runs once the launch slice drives the flag.',
    'BeamDrill drop loop + time reset + lastDrillSpeed (BeamDrill.java:249, 253-262) -- needs lastItem (set by updateFacing, BeamDrill.java:376-411), per-def drillTime (160f / 100f, Blocks.java:3042/3055), facing tiles and items state the tick does not track yet; until the reset slice lands, time grows unbounded (the LaunchPad counter-freeze precedent).',
    'Radar fogRadius rows (fogRadius() = fogRadius * progress * smoothEfficiency, Radar.java:55-57; fogRadius 34, Blocks.java:1991; forceUpdate on radius change, Radar.java:63-66) -- N2190 tracks progress/smoothEfficiency/lastRadius + the force-update condition; the fogControl.forceUpdate call itself + fog visibility wait for their own fog slice.',
    'OverdriveProjector boost application (indexer.eachBlock + other.applyBoost(realBoost(), reload + 1f), OverdriveProjector.java:113) -- N2194 advances charge and resets it at reload, but applying the boost to in-range targets needs indexer/targets infrastructure; the realRange fold (OverdriveProjector.java:110) rides on it; waits for its own slice.',
    'Accelerator disabled-efficiency rows (updateConsumption forces efficiency to 0 when !shouldConsume, BuildingComp.java:1992; the driver skips the consumption fold when disabled, so frame["efficiency"] keeps its last folded value and the updateTile advance reads it stale -- the driver zeroing waits for its own slice).',
    'OverdriveProjector disabled-early-return rows (BuildingComp.java:1954-1957, potentialEfficiency = efficiency = optionalEfficiency = 0f; when disabled -- the driver skips the consumption fold when disabled and leaves frame efficiency stale, so the N2194 advance runs on a stale efficiency when disabled (correct gate: updateTile runs even when disabled) and charge/useProgress keep advancing instead of heat decaying toward 0 and useProgress stopping as in Java; the driver-wide disabled-early-return slice fixes this for all families).',
    'Radar fogControl.forceUpdate call (Vars.fogControl.forceUpdate(team, this), Radar.java:64) -- the N2190 advance tracks lastRadius + the |fogRadius() - lastRadius| >= 0.5f condition (force_update_needed) but does NOT call into the fog system; the fog system has no port-side control yet, so the call waits for its own fog slice.',
    'Radar discoveryTime / rotateSpeed / glow rows (discoveryTime 60f * 10f, rotateSpeed 2f, Radar.java:18-19; glowColor Pal.turretHeat, Radar.java:24; glowScl 5f / glowMag 0.6f, Radar.java:25) -- discoveryTime is consumed by the N2190 advance (progress += edelta() / discoveryTime); rotateSpeed / glow static defs and the glow advance wait for their own slice.',
    'LaunchPad launchCounter advance timeScale -- edelta() is efficiency * delta() with delta() = Time.delta * timeScale (BuildingComp.java:1922-1929); the frame tracks no timeScale (default 1f, BuildingComp.java:98), so the driver advances by efficiency * seconds; a slowed pad (timeScale != 1f) waits for its own slice.',
    'ImpactReactor disabled-early-return rows (BuildingComp.java:1954-1957, potentialEfficiency = efficiency = optionalEfficiency = 0f; when disabled -- the driver skips the consumption fold when disabled and leaves frame efficiency stale, so the N2192 advance is gated on enabled and a disabled reactor warmup freezes in the port instead of decaying as in Java; the driver-wide disabled-early-return slice fixes this for all families).',
    'LightBlock smoothTime Time.delta cap (deltaimpl caps Time.delta at 3f, arc Time.java:26, `private static Floatp deltaimpl = () -> Math.min(Core.graphics.getDeltaTime() * 60f, 3f);` -- the driver converts seconds * 60 without the cap; the cap only binds on frames longer than 50ms; waits for its own slice.)',
    'PayloadMassDriver transfer effects / sound / shake rows (shootEffect / smokeEffect / transferEffect.at / Effect.shake / shootSound, PayloadMassDriver.java:295-301) -- presentation, not tick state; the transfer state (recPayload / effectDelayTimer / handlePayload / lastOther / payVector / payRotation / payLength / loaded / queue cleanup / state reset) is live since N2246; waits for its own slice.',
    'PayloadMassDriver updatePayload live positioning rows (payload.set(x + payVector.x, y + payVector.y, payRotation), PayloadBlock.java:174-177, called from moveInPayload / handlePayload / the updateTile transfer) -- the port payload dict carries no position; the payVector / payRotation state is live since N2246; waits for its own slice.',
]
EXACT_EXPRS = [
    'public class PayloadMassDriver extends PayloadBlock{',
    'public class PayloadDriverBuild extends PayloadBlockBuild<Payload> implements RotBlock{',
    'public float range = 100f;',
    'public float rotateSpeed = 5f;',
    'public float length = 89 / 8f;',
    'public float knockback = 5f;',
    'public float reload = 30f;',
    'public float chargeTime = 100f;',
    'public float maxPayloadSize = 3;',
    'public float grabWidth = 8f, grabHeight = 11/4f;',
    'public Effect transferEffect = new Effect(11f, 600f, e -> {',
    'public int link = -1;',
    'public float turretRotation = 90;',
    'public float reloadCounter = 0f, charge = 0f;',
    'public float targetSize = grabWidth*2f, curSize = targetSize;',
    'public float payLength = 0f, effectDelayTimer = -1f;',
    'public PayloadDriverBuild lastOther;',
    'public boolean loaded;',
    'public boolean charging;',
    'public PayloadDriverState state = idle;',
    'public Queue<Building> waitingShooters = new Queue<>();',
    'public Payload recPayload;',
    'return waitingShooters.isEmpty() ? null : waitingShooters.first();',
    'idle, accepting, shooting;',
    'public void updateTile(){',
    'if(efficiency <= 0f){',
    'if(state == accepting){',
    'if(currentShooter() == null || payload != null){',
    'state = idle;',
    'if(currentShooter().getPayload() != null){',
    'targetSize = recPayload == null ? currentShooter().getPayload().size() : recPayload.size();',
    'turretRotation = Angles.moveToward(turretRotation, angleTo(currentShooter()), rotateSpeed * efficiency);',
    '}else if(state == shooting){',
    'if(!hasLink || (!waitingShooters.isEmpty() && payload == null)){',
    'float targetRotation = angleTo(link);',
    'payRotation = Angles.moveToward(payRotation, turretRotation, payloadRotateSpeed * delta());',
    'float loadLength = length - reloadCounter *knockback;',
    'payLength += payloadSpeed * delta();',
    'if(payLength >= loadLength){',
    'payLength = loadLength;',
    '}else if(moveInPayload()){',
    'payLength = 0f;',
    'loaded = true;',
    'if(movedOut && payload != null && link.getPayload() == null){',
    'var other = (PayloadDriverBuild)link;',
    'if(!other.waitingShooters.contains(this)){',
    'other.waitingShooters.addLast(this);',
    'if(reloadCounter <= 0){',
    'turretRotation = Angles.moveToward(turretRotation, targetRotation, rotateSpeed * efficiency);',
    'if(other.currentShooter() == this &&',
    'other.state == accepting &&',
    'other.reloadCounter <= 0f &&',
    'Angles.within(turretRotation, targetRotation, 1f) && Angles.within(other.turretRotation, targetRotation + 180f, 1f)){',
    'charge += edelta();',
    'charging = true;',
    'if(charge >= chargeTime){',
    'float cx = Angles.trnsx(turretRotation, length), cy = Angles.trnsy(turretRotation, length);',
    'other.recPayload = payload;',
    'other.effectDelayTimer = transferEffect.lifetime;',
    'other.handlePayload(this, pay);',
    'other.lastOther = this;',
    'other.payVector.set(-cx, -cy);',
    'other.payRotation = turretRotation;',
    'other.payLength = length;',
    'other.loaded = true;',
    'other.updatePayload();',
    'other.recPayload = null;',
    'if(other.waitingShooters.size != 0 && other.waitingShooters.first() == this){',
    'other.waitingShooters.removeFirst();',
    'other.state = idle;',
    'payload = null;',
    'loaded = false;',
    'reloadCounter = 1f;',
    'protected boolean linkValid(){',
    'return link != -1 && world.build(this.link) instanceof PayloadDriverBuild other && other.block == block && other.team == team && within(other, range);',
    'public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;',
    'public Vec2 payVector = new Vec2();',
    'public float payRotation;',
    'public @Nullable T payload;',
    'public boolean moveInPayload(){',
    'public boolean moveInPayload(boolean rotate){',
    'if(payload == null) return false;',
    'payRotation = Angles.moveToward(payRotation, block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta());',
    'payVector.approach(Vec2.ZERO, payloadSpeed * delta());',
    'return hasArrived();',
    'return payVector.isZero(0.01f);',
    'this.payload = (T)payload;',
    'this.payRotation = payload.rotation();',
    'return build.block.size * tilesize;',
    'return Time.delta * timeScale;',
    'return efficiency * delta();',
    'return rotation * 90;',
    'updateConsumption();',
    'if(enabled || !block.noUpdateDisabled){',
    'transient float efficiency;',
    'public boolean noUpdateDisabled = false;',
    'payloadMassDriver = new PayloadMassDriver("payload-mass-driver"){{',
    'largePayloadMassDriver = new PayloadMassDriver("large-payload-mass-driver"){{',
    'reload = 130f;',
    'chargeTime = 90f;',
    'chargeTime = 100f;',
    'range = 700f;',
    'range = 2100f;',
    'maxPayloadSize = 2.5f;',
    'maxPayloadSize = 4f;',
    'consumePower(0.5f);',
    'consumePower(3f);',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=PAYLOAD_MASS_DRIVER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2246_inputs = {
        'frame': f('Dictionary', 'public void updateTile(){', 'The building frame carrying the branch state (PayloadMassDriver.java:155, link / turretRotation / reloadCounter / charge / targetSize / payLength / loaded / charging / state / waitingShooters / recPayload / payload / payVector / payRotation / efficiency): the live values the branches read; missing keys fold to the Java field defaults.'),
        'source_delta': f('float', 'return Time.delta * timeScale;', 'Time.delta in ticks (BuildingComp.java:1922-1924, delta() is Time.delta * timeScale): seconds * 60 through game_source_delta, never raw seconds.', source=BUILDING_COMP),
        'time_scale': f('float', 'private transient float timeScale = 1f, timeScaleDuration;', 'The building timeScale (BuildingComp.java:98, default 1f): scales delta() and edelta().', source=BUILDING_COMP),
        'charge_time': f('float', 'chargeTime = 90f;', 'The DEF chargeTime (Blocks.java:6622, 90f; large 100f, Blocks.java:6634): beats the class `public float chargeTime = 100f;` (PayloadMassDriver.java:29); the transfer fires when charge >= chargeTime.', source=BLOCKS),
        'length': f('float', 'public float length = 89 / 8f;', 'The class length (PayloadMassDriver.java:26, 89/8f = 11.125): the loadLength base (length - reloadCounter * knockback) and the transfer payLength / trns distance.'),
        'knockback': f('float', 'public float knockback = 5f;', 'The class knockback (PayloadMassDriver.java:27, 5f): loadLength shrinks by reloadCounter * knockback.'),
        'rotate_speed': f('float', 'public float rotateSpeed = 5f;', 'The class rotateSpeed (PayloadMassDriver.java:25, 5f): the moveToward step is rotateSpeed * efficiency.'),
        'payload_speed': f('float', 'public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', 'The PayloadBlock payloadSpeed (PayloadBlock.java:18, 0.7f): the payLength advance and the moveInPayload approach step are payloadSpeed * delta().', source=PAYLOAD_BLOCK),
        'payload_rotate_speed': f('float', 'public float payloadSpeed = 0.7f, payloadRotateSpeed = 5f;', 'The PayloadBlock payloadRotateSpeed (PayloadBlock.java:18, 5f): the payRotation moveToward step is payloadRotateSpeed * delta().', source=PAYLOAD_BLOCK),
        'rot_deg': f('float', 'return rotation * 90;', 'The block rotation in degrees (BuildingComp.java:582-584, rotdeg() is rotation * 90): the moveInPayload rotate target when block.rotate is true (PayloadMassDriver has rotate=true, PayloadMassDriver.java:60).', source=BUILDING_COMP),
        'tile_pos': f('int', 'entity.link == pos()', 'This building packed position (the shooter-queue identity, PayloadMassDriver.java:201 in the N2245 cleanup): the identity registered on the partner waitingShooters and compared against the partner currentShooter.'),
        'self_x': f('float', 'float targetRotation = angleTo(link);', 'This building world x (PayloadMassDriver.java:256, angleTo(link) reads the self position): the angleTo origin, cell * tilesize from the driver.'),
        'self_y': f('float', 'float targetRotation = angleTo(link);', 'This building world y (PayloadMassDriver.java:256, angleTo(link) reads the self position): the angleTo origin, cell * tilesize from the driver.'),
        'linked': f('Dictionary', 'Building link = world.build(this.link);', 'The linked building snapshot (PayloadMassDriver.java:157, world.build(this.link)): exists / pos / is_payload_mass_driver / same_block / same_team / within_range / payload / state / turret_rotation / reload_counter / effect_delay_timer / pay_vector / pay_rotation / pay_length / loaded / last_other / waiting_shooters / x / y -- the linkValid inputs plus the fire-gate and transfer reads.'),
        'shooters': f('Dictionary', 'var current = currentShooter();', 'The waiting-shooter records by packed position (PayloadMassDriver.java:194, currentShooter() is the first of waitingShooters): x / y / payload -- the accepting angleTo target plus the targetSize source (shooter payload size, or recPayload size).'),
    }
    n2246_outputs = {
        'state': f('String', 'state = idle;', 'The advanced driver state (PayloadMassDriver.java:239 / :252 / :325): idle after either branch bail or the transfer reset; accepting / shooting otherwise.'),
        'target_size': f('float', 'targetSize = recPayload == null ? currentShooter().getPayload().size() : recPayload.size();', 'The advanced targetSize (PayloadMassDriver.java:244): the shooter payload size, or the recPayload size when recPayload is present; unchanged when the shooter has no payload.'),
        'turret_rotation': f('float', 'turretRotation = Angles.moveToward(turretRotation, targetRotation, rotateSpeed * efficiency);', 'The advanced turretRotation (PayloadMassDriver.java:248 / :282): moveToward the shooter angle when accepting, the target rotation when shooting and reloaded.'),
        'pay_rotation': f('float', 'payRotation = Angles.moveToward(payRotation, turretRotation, payloadRotateSpeed * delta());', 'The advanced payRotation (PayloadMassDriver.java:259, plus the moveInPayload rotate toward rotdeg, PayloadBlock.java:192): moveToward the turret rotation every shooting tick, then toward rotdeg while the payload moves in.'),
        'pay_length': f('float', 'payLength += payloadSpeed * delta();', 'The advanced payLength (PayloadMassDriver.java:262-265): advanced by payloadSpeed * delta toward loadLength when loaded, clamped at loadLength; reset to 0f by the moveInPayload arrival (:268) and the transfer reset (:323).'),
        'loaded': f('bool', 'loaded = true;', 'The advanced loaded flag (PayloadMassDriver.java:269 / :324): true when moveInPayload arrives, false after the transfer reset.'),
        'pay_vector': f('Vector2', 'payVector.approach(Vec2.ZERO, payloadSpeed * delta());', 'The advanced payVector (PayloadBlock.java:194): approached toward ZERO by payloadSpeed * delta while the payload moves in; the transfer sets the PARTNER payVector, not this one.', source=PAYLOAD_BLOCK),
        'payload': f('Dictionary', 'payload = null;', 'The advanced payload (PayloadMassDriver.java:322): null after the transfer reset; the held payload dict otherwise.'),
        'charge': f('float', 'charge += edelta();', 'The advanced charge (PayloadMassDriver.java:289): grown by edelta() while the fire gate holds; NOT reset on transfer (Java leaves it >= chargeTime; the N2245 discharge drains it once charging stops).'),
        'charging': f('bool', 'charging = true;', 'The advanced charging flag (PayloadMassDriver.java:290): true while the fire gate holds this tick; the N2245 reset (charging = false, :185) runs before the branches.'),
        'reload_counter': f('float', 'reloadCounter = 1f;', 'The advanced reload counter (PayloadMassDriver.java:326): reset to 1f by the transfer; the per-tick decay is N2245, not this slice.'),
        'partner_waiting_shooters': f('Array', 'other.waitingShooters.addLast(this);', 'The linked building waiting list after the branches (PayloadMassDriver.java:277, the cross-building write-back, the N2237 precedent): this building appended once when movedOut with a payload and an empty link payload; the first entry removed on transfer (:317). The driver writes it back onto the partner frame.'),
        'partner_state': f('String', 'other.state = idle;', 'The linked building state after the branches (PayloadMassDriver.java:319): idle after the transfer; the linked state otherwise.'),
        'partner_effect_delay_timer': f('float', 'other.effectDelayTimer = transferEffect.lifetime;', 'The linked building effectDelayTimer after the branches (PayloadMassDriver.java:304): transferEffect.lifetime (11f) on transfer; the linked timer otherwise.'),
        'partner_pay_vector': f('Vector2', 'other.payVector.set(-cx, -cy);', 'The linked building payVector after the branches (PayloadMassDriver.java:307): (-cx, -cy) from the trns of turretRotation by length on transfer; the linked payVector otherwise. (The handlePayload payVector write is overwritten here in the same tick.)'),
        'partner_pay_rotation': f('float', 'other.payRotation = turretRotation;', 'The linked building payRotation after the branches (PayloadMassDriver.java:308): the shooter turretRotation on transfer; the linked payRotation otherwise. (The handlePayload payRotation write is overwritten here in the same tick.)'),
        'partner_pay_length': f('float', 'other.payLength = length;', 'The linked building payLength after the branches (PayloadMassDriver.java:309): length on transfer; the linked payLength otherwise.'),
        'partner_loaded': f('bool', 'other.loaded = true;', 'The linked building loaded flag after the branches (PayloadMassDriver.java:310): true on transfer; the linked flag otherwise.'),
        'partner_payload': f('Dictionary', 'this.payload = (T)payload;', 'The linked building payload after the branches (PayloadBlock.java:122, handlePayload, called at PayloadMassDriver.java:306): the transferred payload dict on transfer; the linked payload otherwise.', source=PAYLOAD_BLOCK),
        'partner_last_other': f('int', 'other.lastOther = this;', 'The linked building lastOther after the branches (PayloadMassDriver.java:305): this building packed position on transfer; the linked lastOther otherwise.'),
        'fired': f('bool', 'if(charge >= chargeTime){', 'Whether the transfer ran this tick (PayloadMassDriver.java:292): charge reached chargeTime while the fire gate held.'),
    }

    entries = [
        ('N2246', OWNER, 'source_payload_mass_driver_state_branches_state', PAYLOAD_MASS_DRIVER, 'mindustry.world.blocks.payloads.PayloadMassDriver.PayloadDriverBuild', 'PayloadDriverBuild.updateTile()', n2246_inputs, n2246_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadMassDriver state branches from PayloadMassDriver.java / PayloadBlock.java / BuildPayload.java / BuildingComp.java / Blocks.java / Block.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadMassDriver state branches from PayloadMassDriver.java / PayloadBlock.java / BuildPayload.java / BuildingComp.java / Blocks.java / Block.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the advanced self values, then
    # the partner write-back, then the fired flag.
    by_slice['N2246'] = [
        'source_payload_mass_driver_state_branches_state_result.state',
        'source_payload_mass_driver_state_branches_state_result.target_size',
        'source_payload_mass_driver_state_branches_state_result.turret_rotation',
        'source_payload_mass_driver_state_branches_state_result.pay_rotation',
        'source_payload_mass_driver_state_branches_state_result.pay_length',
        'source_payload_mass_driver_state_branches_state_result.loaded',
        'source_payload_mass_driver_state_branches_state_result.pay_vector',
        'source_payload_mass_driver_state_branches_state_result.payload',
        'source_payload_mass_driver_state_branches_state_result.charge',
        'source_payload_mass_driver_state_branches_state_result.charging',
        'source_payload_mass_driver_state_branches_state_result.reload_counter',
        'source_payload_mass_driver_state_branches_state_result.partner_waiting_shooters',
        'source_payload_mass_driver_state_branches_state_result.partner_state',
        'source_payload_mass_driver_state_branches_state_result.partner_effect_delay_timer',
        'source_payload_mass_driver_state_branches_state_result.partner_pay_vector',
        'source_payload_mass_driver_state_branches_state_result.partner_pay_rotation',
        'source_payload_mass_driver_state_branches_state_result.partner_pay_length',
        'source_payload_mass_driver_state_branches_state_result.partner_loaded',
        'source_payload_mass_driver_state_branches_state_result.partner_payload',
        'source_payload_mass_driver_state_branches_state_result.partner_last_other',
        'source_payload_mass_driver_state_branches_state_result.fired',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2246', dict(status='done', java_source=PAYLOAD_MASS_DRIVER, java_class='mindustry.world.blocks.payloads.PayloadMassDriver.PayloadDriverBuild', java_method='PayloadDriverBuild.updateTile()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2246'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
