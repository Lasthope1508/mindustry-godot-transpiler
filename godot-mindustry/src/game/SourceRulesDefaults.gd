extends RefCounted
class_name SourceRulesDefaults

const BUILD_COST_MULTIPLIER_DEFAULT := 1.0
const UNIT_COST_MULTIPLIER_DEFAULT := 1.0
# Rules.unitHealthMultiplier (Rules.java:87) and
# TeamRule.unitHealthMultiplier (Rules.java:363) both default
# to 1f: units start at full health unless the map rules scale
# it (N2459 unitHealth, sibling of N2096 unitCost).
const UNIT_HEALTH_MULTIPLIER_DEFAULT := 1.0
# Rules.unitDamageMultiplier (Rules.java:85) and
# TeamRule.unitDamageMultiplier (Rules.java:355) both default
# to 1f: units deal full damage unless the map rules scale
# it (N2462 unitDamage, sibling of N2096 unitCost). Unlike
# unitHealth (N2459) there is NO floor on the product here.
const UNIT_DAMAGE_MULTIPLIER_DEFAULT := 1.0
# Rules.unitBuildSpeedMultiplier (Rules.java:81) and
# TeamRule.unitBuildSpeedMultiplier (Rules.java:353) both default
# to 1f: unit factories build at full speed unless the map rules
# scale it (N2464 unitBuildSpeed, sibling of N2096 unitCost).
# Like unitDamage (N2462) there is NO floor on the product here.
const UNIT_BUILD_SPEED_MULTIPLIER_DEFAULT := 1.0
# Rules.enemyCoreBuildRadius (Rules.java:123) defaults to 400f:
# the no-build zone around the enemy core (N2461 buildRadius).
const ENEMY_CORE_BUILD_RADIUS_DEFAULT := 400.0
# TeamRule.cheat (Rules.java:328) has no explicit initializer, so it
# defaults to false like every Java boolean field: a team does not
# cheat unless its rules say so.
const TEAM_CHEAT_DEFAULT := false
# Rules.unitFactoryActivationDelay (Rules.java:93) and
# TeamRule.unitFactoryActivationDelay (Rules.java:351) both default
# to 0f: a factory activates from tick 0 unless the map rules set a
# delay (Team.activateUnitFactories(), Team.java:127-129).
const UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT := 0.0
const REACTOR_EXPLOSIONS_DEFAULT := true
const BLOCK_DAMAGE_METHOD := "public float blockDamage(Team team){"
const TIME_TO_MINUTES := 60.0 * 60.0
const WAVE_SPACING_TICKS_DEFAULT := 2.0 * TIME_TO_MINUTES
