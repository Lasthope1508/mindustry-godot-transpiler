extends RefCounted
class_name SourceConstructBlockState

const CONSTRUCT_BLOCK_SOUND_MIN_INTERVAL_MS := 32
const CONSTRUCT_BLOCK_PITCH_SEQUENCE_WINDOW_MS := 16 * 30
const CONSTRUCT_BLOCK_PITCH_SEQUENCE_LIMIT := 30
const CONSTRUCT_BLOCK_PITCH_UP_SCALE := 1.9
const CONSTRUCT_BLOCK_PITCH_DOWN_SCALE := -0.4
const CONSTRUCT_BLOCK_RANDOM_PITCH_MIN := 0.7
const CONSTRUCT_BLOCK_RANDOM_PITCH_MAX := 1.3

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func get_state(size: int, max_block_size: int) -> Dictionary:
	var invalid_size := size > max_block_size
	var construct_block_index := size - 1
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"method": "public static ConstructBlock get(int size){",
		"max_guard_expr": "if(size > maxBlockSize) throw new IllegalArgumentException(\"No. Don't place ConstructBlocks of size greater than \" + maxBlockSize);",
		"return_expr": "return consBlocks[size - 1];",
		"size": size,
		"max_block_size": max_block_size,
		"invalid_size": invalid_size,
		"construct_block_index": construct_block_index,
	}

static func should_play_state(time_since_last_played_ms: int, current_millis: int) -> Dictionary:
	var should_play := time_since_last_played_ms >= CONSTRUCT_BLOCK_SOUND_MIN_INTERVAL_MS
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"method": "static boolean shouldPlay(){",
		"guard_expr": "if(Time.timeSinceMillis(lastPlayed) >= 32){",
		"last_played_expr": "lastPlayed = Time.millis();",
		"return_true_expr": "return true;",
		"return_false_expr": "return false;",
		"time_since_last_played_ms": time_since_last_played_ms,
		"current_millis": current_millis,
		"last_played_after": current_millis if should_play else -1,
		"should_play": should_play,
	}

static func calc_pitch_state(up: bool, time_since_last_time_ms: int, current_millis: int, pitch_seq_before: int, random_pitch: float) -> Dictionary:
	var within_sequence_window := time_since_last_time_ms < CONSTRUCT_BLOCK_PITCH_SEQUENCE_WINDOW_MS
	var pitch_seq_after := 0
	var pitch := random_pitch
	if within_sequence_window:
		pitch_seq_after = pitch_seq_before + 1
		if pitch_seq_after > CONSTRUCT_BLOCK_PITCH_SEQUENCE_LIMIT:
			pitch_seq_after = 0
		var scale := CONSTRUCT_BLOCK_PITCH_UP_SCALE if up else CONSTRUCT_BLOCK_PITCH_DOWN_SCALE
		pitch = 1.0 + clampf(float(pitch_seq_after) / float(CONSTRUCT_BLOCK_PITCH_SEQUENCE_LIMIT), 0.0, 1.0) * scale
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"method": "static float calcPitch(boolean up){",
		"window_guard_expr": "if(Time.timeSinceMillis(lastTime) < 16 * 30){",
		"last_time_expr": "lastTime = Time.millis();",
		"increment_expr": "pitchSeq ++;",
		"reset_guard_expr": "if(pitchSeq > 30){",
		"sequence_return_expr": "return 1f + Mathf.clamp(pitchSeq / 30f) * (up ? 1.9f : -0.4f);",
		"random_return_expr": "return Mathf.random(0.7f, 1.3f);",
		"up": up,
		"time_since_last_time_ms": time_since_last_time_ms,
		"current_millis": current_millis,
		"pitch_seq_before": pitch_seq_before,
		"pitch_seq_after": pitch_seq_after,
		"random_pitch": random_pitch,
		"pitch": pitch,
	}

static func play_repair_sound_state(headless: bool, should_play: bool, visible_tile: bool, calc_pitch_up: float) -> Dictionary:
	var repair_sound_called := not headless and should_play and visible_tile
	var repair_sound_call: Variant = null
	if repair_sound_called:
		repair_sound_call = {"call": "Sounds.blockRepair.at(tile, calcPitch(true));", "pitch": calc_pitch_up}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"method": "public static void playRepairSound(Team team, Tile tile){",
		"repair_sound_expr": "if(!headless && shouldPlay() && fogControl.isVisibleTile(team, tile.x, tile.y)) Sounds.blockRepair.at(tile, calcPitch(true));",
		"headless": headless,
		"should_play": should_play,
		"visible_tile": visible_tile,
		"calc_pitch_up": calc_pitch_up,
		"repair_sound_called": repair_sound_called,
		"repair_sound_call": repair_sound_call,
	}

static func is_hidden_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"source": "core/src/mindustry/world/blocks/ConstructBlock.java",
		"method": "public boolean isHidden(){",
		"return_expr": "return true;",
		"is_hidden": true,
	}

static func generated_construct_block_static_helpers_bridge_state(size: int, max_block_size: int, time_since_last_played_ms: int, current_millis: int, up: bool, time_since_last_time_ms: int, pitch_seq_before: int, random_pitch: float, headless: bool, visible_tile: bool) -> Dictionary:
	var get_result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/ConstructBlock.gd", "java_method_get_0", [size, max_block_size], null)
	var should_play_result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/ConstructBlock.gd", "java_method_shouldPlay_3", [time_since_last_played_ms, current_millis], null)
	var calc_pitch_result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/ConstructBlock.gd", "java_method_calcPitch_4", [up, time_since_last_time_ms, current_millis, pitch_seq_before, random_pitch], null)
	var repair_sound_result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/ConstructBlock.gd", "java_method_playRepairSound_5", [headless, should_play_result.get("should_play", false), visible_tile, calc_pitch_result.get("pitch", 1.0)], null)
	var hidden_result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/ConstructBlock.gd", "java_method_isHidden_7", [], null)
	var canonical_get = get_state(size, max_block_size)
	var canonical_should_play = should_play_state(time_since_last_played_ms, current_millis)
	var canonical_calc_pitch = calc_pitch_state(up, time_since_last_time_ms, current_millis, pitch_seq_before, random_pitch)
	var canonical_repair_sound = play_repair_sound_state(headless, canonical_should_play.get("should_play", false), visible_tile, canonical_calc_pitch.get("pitch", 1.0))
	var canonical_hidden = is_hidden_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_CONSTRUCT_BLOCK_STATIC_HELPERS_STATE,
		"generated_owner": "construct_block.static_helpers",
		"get_result": get_result,
		"should_play_result": should_play_result,
		"calc_pitch_result": calc_pitch_result,
		"repair_sound_result": repair_sound_result,
		"hidden_result": hidden_result,
		"canonical_get": canonical_get,
		"canonical_should_play": canonical_should_play,
		"canonical_calc_pitch": canonical_calc_pitch,
		"canonical_repair_sound": canonical_repair_sound,
		"canonical_hidden": canonical_hidden,
		"matches": get_result.get("construct_block_index", null) == canonical_get.get("construct_block_index", null) and should_play_result.get("should_play", null) == canonical_should_play.get("should_play", null) and calc_pitch_result.get("pitch_seq_after", null) == canonical_calc_pitch.get("pitch_seq_after", null) and calc_pitch_result.get("pitch", null) == canonical_calc_pitch.get("pitch", null) and repair_sound_result.get("repair_sound_called", null) == canonical_repair_sound.get("repair_sound_called", null) and hidden_result.get("is_hidden", null) == canonical_hidden.get("is_hidden", null),
	}
