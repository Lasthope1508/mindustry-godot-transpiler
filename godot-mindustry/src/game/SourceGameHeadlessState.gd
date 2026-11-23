extends RefCounted
class_name SourceGameHeadlessState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

# Vars.headless (Vars.java:208-209):
# `/** whether the game is running on a headless server */`
# `public static boolean headless;`
# -- a static boolean, default false (Java static booleans
# default false). The only assignment in the whole repo is
# ServerLauncher.init() (ServerLauncher.java:45):
# `headless = true;`
# The port derives it from the display server instead
# (decision 2026-11-17 ~12:56, Option 1, the first
# DisplayServer use in the port):
# `DisplayServer.get_name() == "headless"`, stamped onto the
# game node by SourceGameLoopRuntimeState.ready(). The ambient
# gate (N657) already takes this value as its headless_mode
# input (BuildingComp.update, BuildingComp.java:2270-2271):
# `if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){`
# `control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());`
# This slice only supplies the input, it builds no second gate.
static func source_game_headless_state(game: Object) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_GAME_HEADLESS_STATE,
		"headless": false,
	}
	if game == null:
		return result
	# bool() has no null overload in GDScript: bool(null) is a
	# parse error when the null is static and a runtime "No
	# constructor" error when the Variant holds null -- so a game
	# without the flag must never reach bool(). The stamped value
	# is always a real bool (ready() stamps the DisplayServer
	# comparison), so comparing with true reads exactly it, and a
	# missing flag reads null, which is not headless like the
	# Java default.
	result["headless"] = game.get("headless") == true
	return result
