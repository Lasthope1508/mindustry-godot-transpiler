extends "res://src/game/SourceBaseTurretDrawPortBridge.gd"

const source_item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")

func source_item_turret_build_on_proximity_added_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	return source_item_turret_build_state.on_proximity_added_state(has_ammo, cheating, ammo_types_size, first_ammo_item)

func generated_item_turret_build_on_proximity_added_bridge_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_on_proximity_added_bridge_state(has_ammo, cheating, ammo_types_size, first_ammo_item)

func source_item_turret_build_sense_object_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_item_turret_build_state.sense_object_state(sensor, ammo_size, peek_item, super_sense_object_value)

func generated_item_turret_build_sense_object_bridge_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_sense_object_bridge_state(sensor, ammo_size, peek_item, super_sense_object_value)

func source_item_turret_build_get_ammo_content_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	return source_item_turret_build_state.get_ammo_content_state(ammo_size, peek_item)

func generated_item_turret_build_get_ammo_content_bridge_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_content_bridge_state(ammo_size, peek_item)

func source_item_turret_build_get_ammo_fraction_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_item_turret_build_state.get_ammo_fraction_state(total_ammo, max_ammo)

func generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo, max_ammo)

func generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo: float) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo)

func source_item_turret_build_accept_stack_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.accept_stack_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_stack_bridge_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_stack_bridge_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_stack_default_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_stack_default_bridge_state(item, amount)

func source_item_turret_build_handle_stack_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.handle_stack_state(item, amount)

func generated_item_turret_build_handle_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_handle_stack_bridge_state(item, amount)

func source_item_turret_build_remove_stack_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.remove_stack_state(item, amount)

func generated_item_turret_build_remove_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_remove_stack_bridge_state(item, amount)

func generated_item_turret_build_handle_item_bridge_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_handle_item_bridge_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

func generated_item_turret_build_accept_item_bridge_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_item_bridge_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_item_default_bridge_state(item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_item_default_bridge_state(item)

func source_item_turret_build_version_state() -> Dictionary:
	return source_item_turret_build_state.version_state()

func generated_item_turret_build_version_bridge_state() -> Dictionary:
	return source_item_turret_build_state.generated_version_bridge_state()

func source_item_turret_build_write_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.write_state(ammo_entries)

func generated_item_turret_build_write_bridge_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_write_bridge_state(ammo_entries)

func source_item_turret_build_read_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_state.read_state(revision, max_ammo, read_entries)

func generated_item_turret_build_read_bridge_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_read_bridge_state(revision, max_ammo, read_entries)

# Anonymous ConsumeItemFilter.efficiency(Building build)
# inside ItemTurret.init() (ItemTurret.java:83-88).
# `public float efficiency(Building build){`
# `//valid when it can shoot`
# `return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;`
# One efficiency slice (batch 31 slot 3): the 1
# distinguishing return expr only. N1177 owns
# ItemTurret.init() but NOT this efficiency leg; N1467
# owns the base ConsumeItemFilter.efficiency() body
# (`return build.consumeTriggerValid() ||
# getConsumed(build) != null ? 1f : 0f;`); the PAT twin
# (`return build instanceof PayloadTurretBuild it &&
# it.payloads.any() ? 1f : 0f;`) is N2396-owned --
# none is re-registered here. `it.ammo.peek().amount`
# is the peeked ItemEntry amount (ItemTurret.java:226,
# `public class ItemEntry extends AmmoEntry{`),
# `ammoPerShot` is the Turret field (Turret.java:49,
# `public int ammoPerShot = 1;`), `it.cheating()` is
# the BuildingComp call-site -- all arrive as explicit
# params, no live engine is called. Valid when it can
# shoot: 1.0 exactly when the build is an
# ItemTurretBuild with ammo and the peeked entry holds
# at least ammoPerShot -- or the build is cheating --
# else 0.0.
static func source_item_turret_efficiency_state(is_item_turret_build: bool, ammo_size: int, peek_amount: int, ammo_per_shot: int, cheating: bool) -> Dictionary:
	var efficiency: float = 1.0 if is_item_turret_build and ammo_size > 0 and (peek_amount >= ammo_per_shot or cheating) else 0.0
	return {"efficiency": efficiency}

# Anonymous ConsumeItemFilter.build(Building build, Table table)
# inside ItemTurret.init() (ItemTurret.java:70-80).
# `content.items().each(i -> filter.get(i) && i.unlockedNow(),`
# `item -> image.add(new ReqImage(new Image(item.uiIcon),`
# `() -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));`
# One ammo-filter UI slice (batch 35 slot 3): the :76-78
# statement only, registered as its 3 verbatim lines
# (the joined single-line form is NOT verbatim in the
# Java file -- N2428 opener precedent). N1463 owns the
# BASE ConsumeItemFilter.build() each() call (`content
# .items().each(i -> filter.get(i) && i.unlockedNow()
# && !i.hidden, item -> image.add(new ReqImage(
# StatValues.stack(item, 1), ...` + `() -> build.items
# .has(item))));`) -- a different statement (hidden
# filter + StatValues.stack + items.has), NOT this
# ItemTurret override (uiIcon image + ItemTurretBuild
# peek check). N2396 owns the PayloadAmmoTurret PAT
# twin (`image.add(new ReqImage(new Image(content
# .uiIcon), () -> build instanceof PayloadTurretBuild
# it && !it.payloads.isEmpty() && it.currentAmmo() ==
# content));`) -- a different expr. N1463 + N1504 own
# the neighbouring `:74 MultiReqImage` + `:79
# table.add` lines -- neither is re-registered here.
# `content.items()` is the full item list; each entry
# is a Dictionary {"item", "ui_icon", "filter_pass",
# "unlocked_now"} -- filter_pass is the `filter.get(i)`
# call-site and unlocked_now is `i.unlockedNow()`,
# both arrive as explicit bools. `build instanceof
# ItemTurretBuild it` is the pattern guard, `!it.ammo
# .isEmpty()` is the non-empty ammo gate, and
# `((ItemEntry)it.ammo.peek()).item` is the peeked
# ItemEntry item (ItemTurret.java:226, `public class
# ItemEntry extends AmmoEntry{`) -- all arrive as
# explicit params, no live engine is called. The
# ReqImage Boolp is evaluated eagerly here: one
# descriptor per kept item, {"ui_icon", "valid"},
# valid exactly when the build is an ItemTurretBuild
# with non-empty ammo and the peeked item is this
# item. The MultiReqImage itself (:74) and the
# table.add (:79) are N1463/N1504-owned, not ported.
static func source_item_turret_init_ammo_filter_state(items: Array, is_item_turret_build: bool, ammo_empty: bool, peek_item: Variant) -> Dictionary:
	var req_images: Array = []
	for entry in items:
		var item_entry: Dictionary = entry
		if item_entry.get("filter_pass", false) and item_entry.get("unlocked_now", false):
			var valid: bool = is_item_turret_build and not ammo_empty and peek_item == item_entry.get("item")
			req_images.append({"ui_icon": item_entry.get("ui_icon"), "valid": valid})
	return {"req_images": req_images}
