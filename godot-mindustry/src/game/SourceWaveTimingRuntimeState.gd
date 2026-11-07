extends RefCounted
class_name SourceWaveTimingRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_RULES_WAVE_SPACING_DEFAULT_EXPR := "public float waveSpacing = 2 * Time.toMinutes;"
const SOURCE_LOGIC_WAVETIME_COUNTDOWN_EXPR := "state.wavetime = Math.max(state.wavetime - Time.delta, 0);"
const SOURCE_LOGIC_RUN_WAVE_GATE_EXPR := "if(!net.client() && state.wavetime <= 0 && state.rules.waves){"

static func wave_timer_state(current_wavetime: float, source_delta: float, wave_spacing_ticks: float, enemy_count: int) -> Dictionary:
	var next_wavetime: float = max(current_wavetime - source_delta, 0.0)
	var should_spawn := enemy_count <= 0 and next_wavetime <= 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_WAVE_TIMING_RUNTIME_WAVE_TIMER_STATE,
		"source_delta": source_delta,
		"wave_spacing_ticks": wave_spacing_ticks,
		"enemy_count": enemy_count,
		"wavetime": wave_spacing_ticks if should_spawn else next_wavetime,
		"should_spawn": should_spawn,
		"rules_wave_spacing_default_expr": SOURCE_RULES_WAVE_SPACING_DEFAULT_EXPR,
		"logic_wavetime_countdown_expr": SOURCE_LOGIC_WAVETIME_COUNTDOWN_EXPR,
		"logic_run_wave_gate_expr": SOURCE_LOGIC_RUN_WAVE_GATE_EXPR,
	}

static func game_wave_timer_state(game: Object, seconds: float) -> Dictionary:
	var enemy_units = game.get("enemy_units")
	var enemy_count := 0
	if enemy_units is Array:
		enemy_count = enemy_units.size()
	return wave_timer_state(
		float(game.get("wave_cooldown")),
		seconds * source_time_defaults.TICK_RATE,
		source_playable_scenario_defaults.PLAYABLE_WAVE_SPACING_SECONDS * source_time_defaults.TICK_RATE,
		enemy_count
	)
