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

	# --- Turret charge sound state (N2271): when shooting begins
	# with a first-shot delay, shoot() plays the charge sound and
	# the bullet type's charge effect (Turret.java:747-749):
	# `if(shoot.firstShotDelay > 0){`
	# `chargeSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax));`
	# `type.chargeEffect.at(bulletX, bulletY, rotation);`
	# The delay defaults to 0 (ShootPattern.java:11, `public float
	# firstShotDelay = 0;`) and the sound to silence
	# (Turret.java:125-126, `/** Sound emitted when
	# shoot.firstShotDelay is >0 and shooting begins. */ public
	# Sound chargeSound = Sounds.none;`). Among turret block defs
	# ONLY lancer sets either: `shoot.firstShotDelay = 40f;`
	# (Blocks.java:3564) and `chargeSound = Sounds.chargeLancer;`
	# (Blocks.java:3579), in `lancer = new PowerTurret("lancer"){{`
	# (Blocks.java:3560) -- every other turret reads the defaults,
	# so the guard stays off and no charge sound plays. The pitch
	# range is the class default (Turret.java:132, `public float
	# soundPitchMin = 0.9f, soundPitchMax = 1.1f;`); no def
	# overrides it. The bullet type's chargeEffect
	# (Turret.java:749, BulletType.java:79, `public Effect
	# chargeEffect = Fx.none;`) waits for its own slice: the
	# effect lives on the bullet type (lancer's LaserBulletType
	# shootType, `chargeEffect = new MultiEffect(
	# Fx.lancerLaserCharge, Fx.lancerLaserChargeBegin);`,
	# Blocks.java:3586), and the catalog has no shootType
	# bullet-effect representation yet, so this read pins the
	# sound side only. There is no driver tick: the emission
	# happens inside shoot(), an event the driver has no
	# equivalent for yet (precedent N2268 / N2269).

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var lancer_block = blocks_by_id["lancer"]
	var duo_block = blocks_by_id["duo"]
	var malign_block = blocks_by_id["malign"]

	# --- Catalog capture (Blocks.java:3564/:3579): the block
	# initializer's own firstShotDelay / chargeSound assignments;
	# duo and malign carry neither key.
	proof["catalog_lancer_40_charge_lancer"] = is_equal_approx(float(lancer_block.properties.get("firstShotDelay", 0.0)), 40.0) and str(lancer_block.properties.get("chargeSound", "none")) == "chargeLancer"

	# --- Pure read (N2271): the class defaults when the catalog
	# carries no override, the per-block values otherwise, null-safe.
	var default_read: Dictionary = turret_build_state.source_turret_charge_sound_state(MindustryBlock.new({}))
	proof["read_default_0_none"] = is_equal_approx(float(default_read.get("first_shot_delay", -1.0)), 0.0) and str(default_read.get("charge_sound", "")) == "none" and bool(default_read.get("charge_emitted", true)) == false
	var null_read: Dictionary = turret_build_state.source_turret_charge_sound_state(null)
	proof["read_null_block_default"] = is_equal_approx(float(null_read.get("first_shot_delay", -1.0)), 0.0) and str(null_read.get("charge_sound", "")) == "none" and bool(null_read.get("charge_emitted", true)) == false
	var lancer_read: Dictionary = turret_build_state.source_turret_charge_sound_state(lancer_block)
	proof["read_lancer_40_charge_lancer"] = is_equal_approx(float(lancer_read.get("first_shot_delay", 0.0)), 40.0) and str(lancer_read.get("charge_sound", "")) == "chargeLancer" and bool(lancer_read.get("charge_emitted", false)) == true
	var duo_read: Dictionary = turret_build_state.source_turret_charge_sound_state(duo_block)
	proof["read_duo_0_none"] = is_equal_approx(float(duo_read.get("first_shot_delay", -1.0)), 0.0) and str(duo_read.get("charge_sound", "")) == "none" and bool(duo_read.get("charge_emitted", true)) == false
	var malign_read: Dictionary = turret_build_state.source_turret_charge_sound_state(malign_block)
	proof["read_malign_0_none"] = is_equal_approx(float(malign_read.get("first_shot_delay", -1.0)), 0.0) and str(malign_read.get("charge_sound", "")) == "none" and bool(malign_read.get("charge_emitted", true)) == false

	# --- Guard (Turret.java:747, `if(shoot.firstShotDelay > 0){`):
	# off for duo / malign (the 0 default), on for lancer (40f).
	proof["guard_off_duo"] = bool(duo_read.get("charge_emitted", true)) == false and bool(malign_read.get("charge_emitted", true)) == false
	proof["guard_on_lancer"] = bool(lancer_read.get("charge_emitted", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretChargeStateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
