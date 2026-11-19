extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- BuildingComp super.control() enabled/config cases (N2267):
	# TurretBuild.control() ends both overloads with a
	# super.control() call (Turret.java:388/:402,
	# `super.control(type, p1, p2, p3, p4);`), so the
	# BuildingComp cases run for every logic control
	# instruction the turret does not handle itself. The
	# double overload (BuildingComp.java:2150-2155) only
	# handles enabled:
	# `public void control(LAccess type, double p1, double p2, double p3, double p4){`
	# `if(type == LAccess.enabled){`
	# `enabled = !Mathf.zero((float)p1);`
	# `}`
	# `}`
	# and the Object overload (:2157-2162) only handles
	# config:
	# `public void control(LAccess type, Object p1, double p2, double p3, double p4){`
	# `//don't execute configure instructions that copy logic building configures; this can cause extreme lag`
	# `if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){`
	# `//change config only if it's new`
	# `configured(null, p1);`
	# `}`
	# `}`
	# The enabled field is `transient boolean enabled =
	# true;` (BuildingComp.java:77), the flag the
	# shouldConsume / efficiency folds read (frame
	# ["enabled"], default true). LAccess pins
	# `enabled("to"), //"to" is standard for single
	# parameter access` (LAccess.java:80) and `config(true,
	# "to"),` (:83). Mathf.zero is `return Math.abs(value)
	# <= FLOAT_ROUNDING_ERROR;` (arc Mathf.java:522-524)
	# with `public static final float FLOAT_ROUNDING_ERROR
	# = 0.000001f; // 32 bits` (:10), so a p1 of 0.0000005
	# reads zero (disabled) and a p1 of 0.00001 reads
	# non-zero (enabled). logicConfigurable is `public
	# boolean logicConfigurable = false;` (Block.java:270),
	# set true in init() (:1463-1466) only when some
	# configuration key is an UnlockableContent -- duo
	# registers no configuration at all (no `config(` in
	# ItemTurret.java, Turret.java, ReloadTurret.java or
	# BaseTurret.java), so for duo the config guard never
	# fires and configured() is never called. The config
	# case only reports config_applied -- that Java would
	# call configured(null, p1); the handler dispatch
	# itself waits for its own slice. There is NO driver
	# tick: control() is event-driven (the N2248
	# precedent, N2264/N2266) -- the logic executor does
	# not exist in the driver yet, so the pure function is
	# called directly. The direct pure-function calls pin
	# the cases behind the driver observables below:
	# enabled with p1 0 disables / enabled with p1 1
	# enables / the flag reads zero at the 1e-6 epsilon /
	# the flag reads non-zero above it / a non-enabled type
	# leaves enabled untouched / config applies when the
	# block is logic-configurable and the arg is not a
	# LogicBuild / config is blocked when the block is not
	# logic-configurable (duo) / config is blocked when the
	# arg is a LogicBuild / the duo live case disables the
	# placed duo and reports no config applied.

	# The direct pure-function calls pin the cases behind
	# the driver observables below. The current enabled
	# flag is true (the BuildingComp.java:77 default) unless
	# noted; the config flags are false unless noted.
	var direct_disables: Dictionary = turret_build_state.source_turret_super_control_state("enabled", 0.0, true, false, false)
	var direct_enables: Dictionary = turret_build_state.source_turret_super_control_state("enabled", 1.0, false, false, false)
	var direct_zero_epsilon: Dictionary = turret_build_state.source_turret_super_control_state("enabled", 0.0000005, true, false, false)
	var direct_nonzero: Dictionary = turret_build_state.source_turret_super_control_state("enabled", 0.00001, true, false, false)
	var direct_other_type: Dictionary = turret_build_state.source_turret_super_control_state("shoot", 0.0, true, false, false)
	var direct_config_applies: Dictionary = turret_build_state.source_turret_super_control_state("config", 0.0, true, true, false)
	var direct_config_not_configurable: Dictionary = turret_build_state.source_turret_super_control_state("config", 0.0, true, false, false)
	var direct_config_logic_build: Dictionary = turret_build_state.source_turret_super_control_state("config", 0.0, true, true, true)

	# Enabled with p1 0 disables -- directly (BuildingComp
	# .java:2151-2152, `enabled = !Mathf.zero((float)p1);`,
	# and zero(0) is true, so enabled becomes false).
	proof["super_enabled_disables"] = direct_disables.get("enabled", true) == false
	# Enabled with p1 1 enables -- directly (zero(1) is
	# false, so enabled becomes true even from false).
	proof["super_enabled_enables"] = direct_enables.get("enabled", false) == true
	# The flag reads zero at the 1e-6 epsilon -- directly
	# (p1 0.0000005: abs <= 0.000001, so zero is true and
	# enabled becomes false).
	proof["super_enabled_flag_zero_epsilon"] = direct_zero_epsilon.get("enabled", true) == false
	# The flag reads non-zero above the epsilon -- directly
	# (p1 0.00001: abs > 0.000001, so zero is false and
	# enabled stays true).
	proof["super_enabled_flag_nonzero"] = direct_nonzero.get("enabled", false) == true
	# A non-enabled type leaves enabled untouched --
	# directly (the double overload only handles enabled at
	# :2151; "shoot" with p1 0 returns the input true).
	proof["super_enabled_other_type_noop"] = direct_other_type.get("enabled", false) == true and direct_other_type.get("config_applied", true) == false
	# Config applies when the block is logic-configurable
	# and the arg is not a LogicBuild -- directly (the
	# :2159 guard holds, so Java calls configured(null,
	# p1) at :2161).
	proof["super_config_applies_when_configurable"] = direct_config_applies.get("config_applied", false) == true and direct_config_applies.get("enabled", false) == true
	# Config is blocked when the block is not
	# logic-configurable -- directly (duo: logicConfigurable
	# stays false, Block.java:270/:1463-1466, so the :2159
	# guard fails and configured() is never called).
	proof["super_config_blocked_when_not_configurable"] = direct_config_not_configurable.get("config_applied", true) == false
	# Config is blocked when the arg is a LogicBuild --
	# directly (the :2159 guard requires !(p1 instanceof
	# LogicBuild); the lag comment at :2158 says why).
	proof["super_config_blocked_when_logic_build"] = direct_config_logic_build.get("config_applied", true) == false

	# One duo segment, live on the driver: the placed duo
	# carries the duo pins (enabled default true,
	# BuildingComp.java:77; logicConfigurable false, no
	# `config(` registration anywhere in the turret chain).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
	# The raw Sprite2D node never passes through the texture
	# path (SourceTextureRuntimeState.configure_block_sprite),
	# which is what assigns a placed block its world position
	# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
	# so without this the segment sits at the origin (0, 0)
	# and the turret-centred query cannot be distinguished
	# from an origin-centred one. Seed the position exactly
	# the way the game does (the N2211 proof lesson).
	segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)

	var duo_call: Dictionary = turret_build_state.source_turret_super_control_state("enabled", 0.0, true, false, false)
	var duo_config: Dictionary = turret_build_state.source_turret_super_control_state("config", 0.0, true, false, false)
	proof["super_duo_live"] = duo_call.get("enabled", true) == false and duo_config.get("config_applied", true) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretSuperControlProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
