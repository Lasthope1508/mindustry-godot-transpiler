extends RefCounted
class_name SourceRulesDefaults

const BUILD_COST_MULTIPLIER_DEFAULT := 1.0
const UNIT_COST_MULTIPLIER_DEFAULT := 1.0
# TeamRule.cheat (Rules.java:328) has no explicit initializer, so it
# defaults to false like every Java boolean field: a team does not
# cheat unless its rules say so.
const TEAM_CHEAT_DEFAULT := false
const REACTOR_EXPLOSIONS_DEFAULT := true
const BLOCK_DAMAGE_METHOD := "public float blockDamage(Team team){"
const TIME_TO_MINUTES := 60.0 * 60.0
const WAVE_SPACING_TICKS_DEFAULT := 2.0 * TIME_TO_MINUTES
