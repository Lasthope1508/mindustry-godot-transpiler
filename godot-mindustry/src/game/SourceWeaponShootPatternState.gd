extends RefCounted
class_name SourceWeaponShootPatternState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_shoot_pattern_defaults := preload("res://src/game/SourceShootPatternDefaults.gd")
const source_shoot_pattern_source_text_state := preload("res://src/game/SourceShootPatternSourceTextState.gd")

const SOURCE_SHOOT_PATTERN_GENERATED_CLASS := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_GENERATED_CLASS
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_JAVA_METHOD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_JAVA_METHOD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_GENERATED_OWNER := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_GENERATED_OWNER
const SOURCE_SHOOT_PATTERN_COMPAT_DISPATCH_JAVA_METHOD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_COMPAT_DISPATCH_JAVA_METHOD
const SOURCE_SHOOT_PATTERN_COMPAT_DISPATCH_GENERATED_OWNER := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_COMPAT_DISPATCH_GENERATED_OWNER
const SOURCE_SHOOT_PATTERN_FLIP_JAVA_METHOD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_FLIP_JAVA_METHOD
const SOURCE_SHOOT_PATTERN_FLIP_GENERATED_OWNER := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_FLIP_GENERATED_OWNER
const SOURCE_SHOOT_PATTERN_COPY_JAVA_METHOD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_COPY_JAVA_METHOD
const SOURCE_SHOOT_PATTERN_COPY_GENERATED_OWNER := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_COPY_GENERATED_OWNER
const SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT := source_shoot_pattern_defaults.SHOTS_DEFAULT
const SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT := source_shoot_pattern_defaults.FIRST_SHOT_DELAY_DEFAULT
const SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT := source_shoot_pattern_defaults.SHOT_DELAY_DEFAULT
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOTS_FIELD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOTS_FIELD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_FIRST_SHOT_DELAY_FIELD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_FIRST_SHOT_DELAY_FIELD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOT_DELAY_FIELD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOT_DELAY_FIELD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_METHOD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_METHOD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_LOOP := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_LOOP
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_HANDLER_CALL := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_HANDLER_CALL
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_MOVER_NULL := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_MOVER_NULL
const SOURCE_SHOOT_PATTERN_SOURCE := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_SOURCE
const SOURCE_SHOOT_PATTERN_FLIP_METHOD := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_FLIP_METHOD
const SOURCE_SHOOT_PATTERN_FLIP_COMMENT := source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_FLIP_COMMENT

static func _shoot_pattern_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_SHOOT_PATTERN_GENERATED_CLASS, generated_method, generated_args, null)

static func shoot_pattern_default_events(shoot_state: Dictionary) -> Array:
	var shots := int(shoot_state.get("shots", SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT))
	var first_shot_delay := float(shoot_state.get("firstShotDelay", SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT))
	var shot_delay := float(shoot_state.get("shotDelay", SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT))
	var events := []
	for i in shots:
		events.append({
			"xOffset": 0.0,
			"yOffset": 0.0,
			"angleOffset": 0.0,
			"delay": first_shot_delay + shot_delay * float(i),
			"mover": null,
		})
	return events

static func generated_shoot_pattern_default_events_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	var result = _shoot_pattern_call(SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_JAVA_METHOD, [shots, first_shot_delay, shot_delay])
	var canonical = shoot_pattern_default_events({
		"shots": shots,
		"firstShotDelay": first_shot_delay,
		"shotDelay": shot_delay,
	})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS,
		"generated_owner": SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("events", []) == canonical,
	}

static func generated_shoot_pattern_default_events_default_bridge_state() -> Dictionary:
	var result = _shoot_pattern_call(SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_JAVA_METHOD, [])
	var canonical = shoot_pattern_default_events({})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS,
		"generated_owner": SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["shots", "firstShotDelay", "shotDelay"],
		"matches": result.get("events", []) == canonical,
	}

static func generated_shoot_pattern_compat_dispatch_bridge_state(total_shots: int, shots: int, first_shot_delay: float, shot_delay: float, barrel_incrementer_present: bool) -> Dictionary:
	var result = _shoot_pattern_call(SOURCE_SHOOT_PATTERN_COMPAT_DISPATCH_JAVA_METHOD, [total_shots, shots, first_shot_delay, shot_delay, barrel_incrementer_present])
	var canonical = shoot_pattern_default_events({
		"shots": shots,
		"firstShotDelay": first_shot_delay,
		"shotDelay": shot_delay,
	})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS,
		"generated_owner": SOURCE_SHOOT_PATTERN_COMPAT_DISPATCH_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("events", []) == canonical and int(result.get("barrelIncrementerCalls", -1)) == 0,
	}

static func generated_shoot_pattern_flip_bridge_state() -> Dictionary:
	var result = _shoot_pattern_call(SOURCE_SHOOT_PATTERN_FLIP_JAVA_METHOD, [])
	var canonical = {"source_owner": source_runtime_owner_registry.SOURCE_SHOOT_PATTERN_FLIP, "generated_owner": SOURCE_SHOOT_PATTERN_FLIP_GENERATED_OWNER, "source": SOURCE_SHOOT_PATTERN_SOURCE, "method": SOURCE_SHOOT_PATTERN_FLIP_METHOD, "comment": SOURCE_SHOOT_PATTERN_FLIP_COMMENT, "no_op": true, "mutated_fields": []}
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_SHOOT_PATTERN_FLIP,
		"generated_owner": SOURCE_SHOOT_PATTERN_FLIP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": bool(result.get("no_op", false)) and result.get("mutated_fields", []) == [],
	}

static func generated_shoot_pattern_copy_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	var result = _shoot_pattern_call(SOURCE_SHOOT_PATTERN_COPY_JAVA_METHOD, [shots, first_shot_delay, shot_delay])
	var expected_copy := {"shots": shots, "firstShotDelay": first_shot_delay, "shotDelay": shot_delay}
	var canonical := expected_copy
	return {
		"source_owner": source_runtime_owner_registry.SOURCE_SHOOT_PATTERN_COPY,
		"generated_owner": SOURCE_SHOOT_PATTERN_COPY_GENERATED_OWNER,
		"result": result,
		"expected_copy": expected_copy,
		"canonical": canonical,
		"matches": result.get("copy", {}) == expected_copy and bool(result.get("same_reference", true)) == false,
	}

static func shoot_default_pattern_dispatch_state(mount_state: Dictionary, shoot_state: Dictionary) -> Dictionary:
	var total_shots := int(mount_state.get("totalShots", 0))
	var barrel_counter := int(mount_state.get("barrelCounter", 0))
	var pattern_events := shoot_pattern_default_events(shoot_state)
	var bullet_calls := []
	var scheduled_calls := []
	for event in pattern_events:
		total_shots += 1
		var event_barrel := barrel_counter
		var event_delay := float(event.get("delay", 0.0))
		var bullet_call := {
			"xOffset": float(event.get("xOffset", 0.0)),
			"yOffset": float(event.get("yOffset", 0.0)),
			"angleOffset": float(event.get("angleOffset", 0.0)),
			"mover": event.get("mover", null),
			"barrel": event_barrel,
		}
		if event_delay > 0.0:
			scheduled_calls.append({
				"delay": event_delay,
				"setBarrelCounter": event_barrel,
				"bulletCall": bullet_call,
				"restoreBarrelCounter": barrel_counter,
			})
		else:
			bullet_calls.append(bullet_call)
	return {
		"patternEvents": pattern_events,
		"bulletCalls": bullet_calls,
		"scheduledCalls": scheduled_calls,
		"totalShots": total_shots,
		"barrelCounter": barrel_counter,
		"barrelIncrementerCalls": 0,
		"shootDispatchSource": "shoot.shoot(mount.barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {",
		"patternCompatSource": "shoot(totalShots, handler)",
		"patternHandlerSource": "handler.shoot(0, 0, 0, firstShotDelay + shotDelay * i);",
		"totalShotsSource": "mount.totalShots ++;",
		"barrelCaptureSource": "int barrel = mount.barrelCounter;",
		"timeRunSource": "Time.run(delay, () -> {",
		"restoreBarrelSource": "mount.barrelCounter = prev;",
		"directBulletSource": "bullet(unit, mount, xOffset, yOffset, angle, mover);",
		"barrelIncrementerSource": "}, () -> mount.barrelCounter++);",
	}
