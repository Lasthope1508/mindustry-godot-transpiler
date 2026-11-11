extends RefCounted
class_name SourceRulesDefaults

const BUILD_COST_MULTIPLIER_DEFAULT := 1.0
const UNIT_COST_MULTIPLIER_DEFAULT := 1.0
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
