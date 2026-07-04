# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/ItemTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemTurret"
const JAVA_EXTENDS := "Turret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "ammoTypes", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ItemTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "ammo", "parameters": [{"name": "objects", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [{"name": "margin", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_ammo_0(_args: Array = []) -> Variant:
	return null

func java_method_limitRange_1(_args: Array = []) -> Variant:
	var margin: float = 9.0
	var limit_range_call: Dictionary = {"call": "limitRange(9f);", "margin": margin}
	return {"source_owner": "PortGame.source_item_turret_limit_range_default_state", "method": "public void limitRange(){", "comment": "/** Limits bullet range to this turret's range value. */", "dispatch_expr": "limitRange(9f);", "margin": margin, "limit_range_called": true, "limit_range_call": limit_range_call}

func java_method_limitRange_2(_args: Array = []) -> Variant:
	var margin: float = float(_args[0] if _args.size() > 0 else 0.0)
	var ammo_entries: Array = _args[1] if _args.size() > 1 else []
	var limit_range_calls: Array = []
	for entry in ammo_entries:
		var entry_value: Variant = entry.get("value", null) if entry is Dictionary else entry
		limit_range_calls.append({"call": "limitRange(entry.value, margin);", "entry_value": entry_value, "margin": margin})
	return {"source_owner": "PortGame.source_item_turret_limit_range_entries_state", "method": "public void limitRange(float margin){", "comment": "/** Limits bullet range to this turret's range value. */", "loop_expr": "for(var entry : ammoTypes.entries()){", "dispatch_expr": "limitRange(entry.value, margin);", "margin": margin, "ammo_entries": ammo_entries, "limit_range_calls": limit_range_calls, "limit_range_call_count": limit_range_calls.size()}

func java_method_setStats_3(_args: Array = []) -> Variant:
	var ammo_types: Variant = _args[0] if _args.size() > 0 else null
	var name_value: String = str(_args[1] if _args.size() > 1 else "")
	var max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)
	var ammo_per_shot: float = float(_args[3] if _args.size() > 3 else 1.0)
	var ammo_capacity_divisor: float = maxf(ammo_per_shot, 1.0)
	var ammo_capacity: float = max_ammo / ammo_capacity_divisor
	var stats_item_capacity_remove_call: Dictionary = {"call": "stats.remove(Stat.itemCapacity);", "stat": "Stat.itemCapacity"}
	var ammo_values_call: Dictionary = {"call": "StatValues.ammo(ammoTypes, name)", "ammo_types": ammo_types, "name": name_value}
	var stats_ammo_add_call: Dictionary = {"call": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));", "stat": "Stat.ammo", "ammo_values_call": ammo_values_call}
	var stats_ammo_capacity_add_call: Dictionary = {"call": "stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);", "stat": "Stat.ammoCapacity", "value": ammo_capacity, "unit": "StatUnit.shots"}
	return {"source_owner": "PortGame.source_item_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "stats_remove_expr": "stats.remove(Stat.itemCapacity);", "stats_ammo_add_expr": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));", "stats_ammo_capacity_add_expr": "stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);", "ammo_types": ammo_types, "name_value": name_value, "max_ammo": max_ammo, "ammo_per_shot": ammo_per_shot, "ammo_capacity_divisor": ammo_capacity_divisor, "ammo_capacity": ammo_capacity, "super_set_stats_called": true, "stats_item_capacity_removed": true, "stats_ammo_added": true, "stats_ammo_capacity_added": true, "stats_item_capacity_remove_call": stats_item_capacity_remove_call, "ammo_values_call": ammo_values_call, "stats_ammo_add_call": stats_ammo_add_call, "stats_ammo_capacity_add_call": stats_ammo_capacity_add_call}

func java_method_setBars_4(_args: Array = []) -> Variant:
	var total_ammo: float = float(_args[0] if _args.size() > 0 else 0.0)
	var max_ammo: float = float(_args[1] if _args.size() > 1 else 1.0)
	var ammo_bar_fraction: float = total_ammo / max_ammo
	var bar_call: Dictionary = {"call": "addBar(\"ammo\", (ItemTurretBuild entity) -> new Bar(...));", "name": "ammo", "bar_text": "stat.ammo", "color": "Pal.ammo", "fraction": ammo_bar_fraction}
	return {"source_owner": "PortGame.source_item_turret_set_bars_state", "method": "public void setBars(){", "override_expr": "@Override", "super_set_bars_expr": "super.setBars();", "add_bar_expr": "addBar(\"ammo\", (ItemTurretBuild entity) -> new Bar(\"stat.ammo\", Pal.ammo, () -> (float)entity.totalAmmo / maxAmmo));", "bar_fraction_expr": "() -> (float)entity.totalAmmo / maxAmmo", "total_ammo": total_ammo, "max_ammo": max_ammo, "ammo_bar_fraction": ammo_bar_fraction, "super_set_bars_called": true, "bar_added": true, "bar_call": bar_call}

func java_method_init_5(_args: Array = []) -> Variant:
	var target_ground: bool = bool(_args[0] if _args.size() > 0 else false)
	var place_overlap_range: float = float(_args[1] if _args.size() > 1 else 0.0)
	var range_value: float = float(_args[2] if _args.size() > 2 else 0.0)
	var place_overlap_margin: float = float(_args[3] if _args.size() > 3 else 0.0)
	var ammo_entries: Array = _args[4] if _args.size() > 4 else []
	var place_overlap_range_after: float = place_overlap_range
	var place_overlap_updates: Array = []
	if target_ground:
		for entry in ammo_entries:
			var entry_value: Variant = entry.get("value", entry) if entry is Dictionary else entry
			var range_change: float = float(entry_value.get("range_change", entry_value.get("rangeChange", 0.0)) if entry_value is Dictionary else 0.0)
			var candidate_range: float = range_value + range_change + place_overlap_margin
			place_overlap_range_after = maxf(place_overlap_range_after, candidate_range)
			place_overlap_updates.append({"call": "placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin)", "range_change": range_change, "candidate_range": candidate_range, "place_overlap_range_after": place_overlap_range_after})
	return {"source_owner": "PortGame.source_item_turret_init_ground_overlap_state", "method": "public void init(){", "override_expr": "@Override", "consume_expr": "consume(new ConsumeItemFilter(i -> ammoTypes.containsKey(i)))", "consume_filter_deferred": true, "target_ground_guard_expr": "if(targetGround){", "overlap_expr": "placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin)", "super_init_expr": "super.init();", "target_ground": target_ground, "place_overlap_range": place_overlap_range, "range_value": range_value, "place_overlap_margin": place_overlap_margin, "ammo_entries": ammo_entries, "place_overlap_range_after": place_overlap_range_after, "place_overlap_updates": place_overlap_updates, "place_overlap_update_count": place_overlap_updates.size(), "super_init_called": true}

func java_inner_class_ItemTurretBuild_method_onProximityAdded_0(_args: Array = []) -> Variant:
	var has_ammo: bool = bool(_args[0] if _args.size() > 0 else false)
	var cheating: bool = bool(_args[1] if _args.size() > 1 else false)
	var ammo_types_size: int = int(_args[2] if _args.size() > 2 else 0)
	var first_ammo_item: Variant = _args[3] if _args.size() > 3 else null
	var should_handle_first_ammo: bool = (not has_ammo) and cheating and ammo_types_size > 0
	var handle_item_call: Dictionary = {}
	if should_handle_first_ammo:
		handle_item_call = {"call": "handleItem(this, ammoTypes.keys().next());", "source": "this", "item": first_ammo_item}
	return {"source_owner": "PortGame.source_item_turret_build_on_proximity_added_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public void onProximityAdded(){", "override_expr": "@Override", "super_on_proximity_added_expr": "super.onProximityAdded();", "comment": "//add first ammo item to cheaty blocks so they can shoot properly", "guard_expr": "if(!hasAmmo() && cheating() && ammoTypes.size > 0){", "handle_item_expr": "handleItem(this, ammoTypes.keys().next());", "has_ammo": has_ammo, "cheating": cheating, "ammo_types_size": ammo_types_size, "first_ammo_item": first_ammo_item, "should_handle_first_ammo": should_handle_first_ammo, "handle_item_call": handle_item_call, "super_on_proximity_added_called": true}

func java_inner_class_ItemTurretBuild_method_senseObject_1(_args: Array = []) -> Variant:
	var sensor: String = str(_args[0] if _args.size() > 0 else "")
	var ammo_size: int = int(_args[1] if _args.size() > 1 else 0)
	var peek_item: Variant = _args[2] if _args.size() > 2 else null
	var super_sense_object_value: Variant = _args[3] if _args.size() > 3 else null
	var sense_object_value: Variant = null
	if sensor == "currentAmmoType":
		sense_object_value = peek_item if ammo_size > 0 else null
	else:
		sense_object_value = super_sense_object_value
	return {"source_owner": "PortGame.source_item_turret_build_sense_object_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public Object senseObject(LAccess sensor){", "override_expr": "@Override", "switch_return_expr": "return switch(sensor){", "current_ammo_type_case": "case currentAmmoType -> ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;", "default_case": "default -> super.senseObject(sensor);", "sensor": sensor, "ammo_size": ammo_size, "peek_item": peek_item, "super_sense_object_value": super_sense_object_value, "sense_object_value": sense_object_value}

func java_inner_class_ItemTurretBuild_method_getAmmoContent_2(_args: Array = []) -> Variant:
	var ammo_size: int = int(_args[0] if _args.size() > 0 else 0)
	var peek_item: Variant = _args[1] if _args.size() > 1 else null
	var ammo_content: Variant = peek_item if ammo_size > 0 else null
	return {"source_owner": "PortGame.source_item_turret_build_get_ammo_content_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public UnlockableContent getAmmoContent(){", "override_expr": "@Override", "return_expr": "return ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;", "ammo_size": ammo_size, "peek_item": peek_item, "ammo_content": ammo_content}

func java_inner_class_ItemTurretBuild_method_getAmmoFraction_3(_args: Array = []) -> Variant:
	var total_ammo: float = float(_args[0] if _args.size() > 0 else 0.0)
	var max_ammo: float = float(_args[1] if _args.size() > 1 else 1.0)
	var ammo_fraction: float = total_ammo / max_ammo
	return {"source_owner": "PortGame.source_item_turret_build_get_ammo_fraction_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public float getAmmoFraction(){", "override_expr": "@Override", "return_expr": "return (float)totalAmmo / maxAmmo;", "total_ammo": total_ammo, "max_ammo": max_ammo, "ammo_fraction": ammo_fraction}

func java_inner_class_ItemTurretBuild_method_acceptStack_4(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var amount: int = int(_args[1] if _args.size() > 1 else 0)
	var max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)
	var total_ammo: float = float(_args[3] if _args.size() > 3 else 0.0)
	var ammo_multiplier: float = float(_args[4] if _args.size() > 4 else 1.0)
	var ammo_type_null: bool = bool(_args[5] if _args.size() > 5 else false)
	var accept_stack: int = 0 if ammo_type_null else min(int((max_ammo - total_ammo) / ammo_multiplier), amount)
	return {"source_owner": "PortGame.source_item_turret_build_accept_stack_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public int acceptStack(Item item, int amount, Teamc source){", "override_expr": "@Override", "type_lookup": "BulletType type = ammoTypes.get(item);", "null_guard": "if(type == null) return 0;", "return_expr": "return Math.min((int)((maxAmmo - totalAmmo) / ammoTypes.get(item).ammoMultiplier), amount);", "item": item, "amount": amount, "max_ammo": max_ammo, "total_ammo": total_ammo, "ammo_multiplier": ammo_multiplier, "ammo_type_null": ammo_type_null, "accept_stack": accept_stack}

func java_inner_class_ItemTurretBuild_method_handleStack_5(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var amount: int = int(_args[1] if _args.size() > 1 else 0)
	var handle_item_calls: Array = []
	for _i in range(amount):
		handle_item_calls.append({"call": "handleItem(null, item);", "source": null, "item": item})
	return {"source_owner": "PortGame.source_item_turret_build_handle_stack_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public void handleStack(Item item, int amount, Teamc source){", "override_expr": "@Override", "loop_expr": "for(int i = 0; i < amount; i++){", "handle_item_expr": "handleItem(null, item);", "item": item, "amount": amount, "handle_item_calls": handle_item_calls, "handle_item_call_count": handle_item_calls.size()}

func java_inner_class_ItemTurretBuild_method_removeStack_6(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var amount: int = int(_args[1] if _args.size() > 1 else 0)
	var removed_stack: int = 0
	return {"source_owner": "PortGame.source_item_turret_build_remove_stack_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "comment": "//currently can't remove items from turrets.", "method": "public int removeStack(Item item, int amount){", "override_expr": "@Override", "return_expr": "return 0;", "item": item, "amount": amount, "removed_stack": removed_stack}

func java_inner_class_ItemTurretBuild_method_handleItem_7(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var item_is_pyratite: bool = bool(_args[1] if _args.size() > 1 else false)
	var total_ammo: int = int(_args[2] if _args.size() > 2 else 0)
	var ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 0.0)
	var ammo_type_null: bool = bool(_args[4] if _args.size() > 4 else false)
	var ammo_entries: Array = _args[5] if _args.size() > 5 and _args[5] is Array else []
	var ammo_entries_after: Array = ammo_entries.duplicate(true)
	var flame_ammo_event_fired: bool = item_is_pyratite
	var resupply_turret_event_fired: bool = total_ammo == 0
	var total_ammo_after: int = total_ammo
	var type_null_returned: bool = ammo_type_null
	var entry_found: bool = false
	var entry_added: bool = false
	var swapped: bool = false
	if not ammo_type_null:
		total_ammo_after = int(total_ammo + ammo_multiplier)
		for i in range(ammo_entries_after.size()):
			var entry_copy: Dictionary = ammo_entries_after[i] if ammo_entries_after[i] is Dictionary else {}
			if entry_copy.get("item", null) == item:
				entry_copy["amount"] = int(entry_copy.get("amount", 0)) + int(ammo_multiplier)
				ammo_entries_after[i] = entry_copy
				var last_index: int = ammo_entries_after.size() - 1
				var last_entry: Variant = ammo_entries_after[last_index]
				ammo_entries_after[last_index] = ammo_entries_after[i]
				ammo_entries_after[i] = last_entry
				entry_found = true
				swapped = true
				break
		if not entry_found:
			ammo_entries_after.append({"item": item, "amount": int(ammo_multiplier)})
			entry_added = true
	return {"source_owner": "PortGame.source_item_turret_build_handle_item_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public void handleItem(Building source, Item item){", "override_expr": "@Override", "todo_comment": "//TODO instead of all this \"entry\" crap, turrets could just accept only one type of ammo at a time - simpler for both users and the code", "pyratite_guard": "if(item == Items.pyratite){", "flame_event_expr": "Events.fire(Trigger.flameAmmo);", "resupply_guard": "if(totalAmmo == 0){", "resupply_event_expr": "Events.fire(Trigger.resupplyTurret);", "type_lookup": "BulletType type = ammoTypes.get(item);", "type_null_guard": "if(type == null) return;", "total_ammo_update_expr": "totalAmmo += type.ammoMultiplier;", "loop_expr": "for(int i = 0; i < ammo.size; i++){", "entry_cast": "ItemEntry entry = (ItemEntry)ammo.get(i);", "found_guard": "if(entry.item == item){", "entry_update_expr": "entry.amount += type.ammoMultiplier;", "swap_expr": "ammo.swap(i, ammo.size - 1);", "add_expr": "ammo.add(new ItemEntry(item, (int)type.ammoMultiplier));", "item": item, "item_is_pyratite": item_is_pyratite, "total_ammo": total_ammo, "ammo_multiplier": ammo_multiplier, "ammo_type_null": ammo_type_null, "flame_ammo_event_fired": flame_ammo_event_fired, "resupply_turret_event_fired": resupply_turret_event_fired, "type_null_returned": type_null_returned, "total_ammo_after": total_ammo_after, "ammo_entries_after": ammo_entries_after, "entry_found": entry_found, "entry_added": entry_added, "swapped": swapped}

func java_inner_class_ItemTurretBuild_method_acceptItem_8(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var total_ammo: int = int(_args[1] if _args.size() > 1 else 0)
	var max_ammo: float = float(_args[2] if _args.size() > 2 else 0.0)
	var ammo_multiplier: float = float(_args[3] if _args.size() > 3 else 0.0)
	var ammo_type_null: bool = bool(_args[4] if _args.size() > 4 else false)
	var accept_item: bool = not ammo_type_null and total_ammo + ammo_multiplier <= max_ammo
	return {"source_owner": "PortGame.source_item_turret_build_accept_item_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public boolean acceptItem(Building source, Item item){", "override_expr": "@Override", "return_expr": "return ammoTypes.get(item) != null && totalAmmo + ammoTypes.get(item).ammoMultiplier <= maxAmmo;", "item": item, "total_ammo": total_ammo, "max_ammo": max_ammo, "ammo_multiplier": ammo_multiplier, "ammo_type_null": ammo_type_null, "accept_item": accept_item}

func java_inner_class_ItemTurretBuild_method_version_9(_args: Array = []) -> Variant:
	var version_value: int = 2
	return {"source_owner": "PortGame.source_item_turret_build_version_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public byte version(){", "override_expr": "@Override", "return_expr": "return 2;", "version": version_value}

func java_inner_class_ItemTurretBuild_method_write_10(_args: Array = []) -> Variant:
	var ammo_entries: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var write_calls: Array = []
	var entry_writes: Array = []
	write_calls.append({"call": "super.write(write);"})
	write_calls.append({"call": "write.b(ammo.size);", "value": ammo_entries.size()})
	for entry in ammo_entries:
		var entry_copy: Dictionary = entry.duplicate(true) if entry is Dictionary else {}
		entry_writes.append({"item_id": int(entry_copy.get("item_id", 0)), "amount": int(entry_copy.get("amount", 0))})
		write_calls.append({"call": "write.s(i.item.id);", "value": int(entry_copy.get("item_id", 0))})
		write_calls.append({"call": "write.s(i.amount);", "value": int(entry_copy.get("amount", 0))})
	return {"source_owner": "PortGame.source_item_turret_build_write_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public void write(Writes write){", "override_expr": "@Override", "super_write_expr": "super.write(write);", "write_size_expr": "write.b(ammo.size);", "loop_expr": "for(AmmoEntry entry : ammo){", "entry_cast": "ItemEntry i = (ItemEntry)entry;", "write_item_id_expr": "write.s(i.item.id);", "write_amount_expr": "write.s(i.amount);", "ammo_size": ammo_entries.size(), "entry_writes": entry_writes, "write_calls": write_calls}

func java_inner_class_ItemTurretBuild_method_read_11(_args: Array = []) -> Variant:
	var revision: int = int(_args[0] if _args.size() > 0 else 0)
	var max_ammo: int = int(_args[1] if _args.size() > 1 else 0)
	var read_entries: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []
	var read_calls: Array = []
	var ammo_entries_after: Array = []
	var total_ammo_after: int = 0
	read_calls.append({"call": "super.read(read, revision);", "revision": revision})
	read_calls.append({"call": "ammo.clear();"})
	read_calls.append({"call": "totalAmmo = 0;", "value": 0})
	read_calls.append({"call": "read.ub();", "target": "amount", "value": read_entries.size()})
	for entry in read_entries:
		var entry_copy: Dictionary = entry.duplicate(true) if entry is Dictionary else {}
		var item: Variant = entry_copy.get("item", null)
		var ammo_type_valid: bool = bool(entry_copy.get("ammo_type_valid", false))
		var item_read_call: String = "read.ub();" if revision < 2 else "read.s();"
		read_calls.append({"call": item_read_call, "target": "item", "item": item})
		var item_amount: int = min(int(entry_copy.get("amount", 0)), max_ammo)
		read_calls.append({"call": "read.s();", "target": "itemAmount", "value": item_amount})
		if item != null and ammo_type_valid:
			total_ammo_after += item_amount
			ammo_entries_after.append({"item": item, "amount": item_amount})
			read_calls.append({"call": "totalAmmo += itemAmount;", "value": total_ammo_after})
			read_calls.append({"call": "ammo.add(new ItemEntry(item, itemAmount));", "item": item, "amount": item_amount})
	return {"source_owner": "PortGame.source_item_turret_build_read_state", "inner_class": "public class ItemTurretBuild extends TurretBuild{", "method": "public void read(Reads read, byte revision){", "override_expr": "@Override", "super_read_expr": "super.read(read, revision);", "clear_expr": "ammo.clear();", "total_reset_expr": "totalAmmo = 0;", "amount_expr": "int amount = read.ub();", "loop_expr": "for(int i = 0; i < amount; i++){", "item_lookup_expr": "Item item = Vars.content.item(revision < 2 ? read.ub() : read.s());", "item_amount_expr": "int itemAmount = Math.min(read.s(), maxAmmo);", "valid_comment": "//only add ammo if this is a valid ammo type", "valid_ammo_guard": "if(item != null && ammoTypes.containsKey(item)){", "total_add_expr": "totalAmmo += itemAmount;", "ammo_add_expr": "ammo.add(new ItemEntry(item, itemAmount));", "read_count": read_entries.size(), "total_ammo_after": total_ammo_after, "ammo_entries_after": ammo_entries_after, "read_calls": read_calls}

func java_inner_class_ItemEntry_constructor_ItemEntry_0(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var amount: int = int(_args[1] if _args.size() > 1 else 0)
	return {"source_owner": "PortGame.source_item_entry_constructor_state", "inner_class": "public class ItemEntry extends AmmoEntry{", "field": "public Item item;", "constructor": "ItemEntry(Item item, int amount){", "item_assign_expr": "this.item = item;", "amount_assign_expr": "this.amount = amount;", "item": item, "amount": amount, "item_after": item, "amount_after": amount}
