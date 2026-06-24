import json
import re
from pathlib import Path
from typing import Any


DUO_SOURCE = "core/src/mindustry/content/Blocks.java"
MEND_PROJECTOR_SOURCE = "core/src/mindustry/world/blocks/defense/MendProjector.java"
OVERDRIVE_PROJECTOR_SOURCE = "core/src/mindustry/world/blocks/defense/OverdriveProjector.java"
BUILDING_COMP_SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
CONVEYOR_SOURCE = "core/src/mindustry/world/blocks/distribution/Conveyor.java"
DRILL_SOURCE = "core/src/mindustry/world/blocks/production/Drill.java"
BUILDING_COMP_SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
CORE_BLOCK_SOURCE = "core/src/mindustry/world/blocks/storage/CoreBlock.java"
ITEM_MODULE_SOURCE = "core/src/mindustry/world/modules/ItemModule.java"

def verify_overdrive_projector_params_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    blocks_path = Path(upstream_root) / DUO_SOURCE
    overdrive_path = Path(upstream_root) / OVERDRIVE_PROJECTOR_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    blocks_source = blocks_path.read_text(encoding="utf-8", errors="replace")
    overdrive_source = overdrive_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_overdrive_projector_params(blocks_source, overdrive_source, "overdriveProjector", "OverdriveProjector")
    actual_props = _registry_block(registry, "overdrive-projector").get("properties", {})
    mismatches: list[dict[str, Any]] = []
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    return {
        "source": DUO_SOURCE,
        "block": "overdrive-projector",
        "checked": expected,
        "mismatches": mismatches,
    }

def verify_overdrive_projector_target_filter_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / OVERDRIVE_PROJECTOR_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    predicate = "other.block.canOverdrive"
    action = "other.applyBoost(realBoost(), reload + 1f)"
    missing = []
    if predicate not in source:
        missing.append(predicate)
    if action not in source:
        missing.append(action)
    return {
        "source": OVERDRIVE_PROJECTOR_SOURCE,
        "checked": {"predicate": predicate, "action": action},
        "missing": missing,
    }

def verify_building_time_scale_decay_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    duration_decay = "if((timeScaleDuration -= Time.delta) <= 0f)"
    reset = "timeScale = 1f;"
    missing = []
    if duration_decay not in source:
        missing.append(duration_decay)
    if reset not in source:
        missing.append(reset)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {"duration_decay": duration_decay, "reset": reset},
        "missing": missing,
    }

def verify_building_delta_edelta_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    delta = "return Time.delta * timeScale;"
    edelta = "return efficiency * delta();"
    missing = []
    if delta not in source:
        missing.append(delta)
    if edelta not in source:
        missing.append(edelta)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {"delta": delta, "edelta": edelta},
        "missing": missing,
    }

def verify_conveyor_edelta_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / CONVEYOR_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    movement = "float moved = speed * edelta();"
    missing = []
    if movement not in source:
        missing.append(movement)
    return {
        "source": CONVEYOR_SOURCE,
        "checked": {"movement": movement},
        "missing": missing,
    }

def verify_drill_delta_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DRILL_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    progress = "progress += delta() * dominantItems * speed * warmup;"
    missing = []
    if progress not in source:
        missing.append(progress)
    return {
        "source": DRILL_SOURCE,
        "checked": {"progress": progress},
        "missing": missing,
    }

def verify_drill_warmup_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DRILL_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    warmup_default = "public float warmupSpeed = 0.015f;"
    warmup_active = "warmup = Mathf.approachDelta(warmup, speed, warmupSpeed);"
    warmup_inactive = "warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);"
    missing = []
    for snippet in [warmup_default, warmup_active, warmup_inactive]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": DRILL_SOURCE,
        "checked": {"warmup_default": warmup_default, "warmup_active": warmup_active, "warmup_inactive": warmup_inactive},
        "missing": missing,
    }

def verify_drill_time_drilled_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DRILL_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    time_drilled = "timeDrilled += warmup * delta();"
    missing = []
    if time_drilled not in source:
        missing.append(time_drilled)
    return {
        "source": DRILL_SOURCE,
        "checked": {"time_drilled": time_drilled},
        "missing": missing,
    }

def verify_drill_last_speed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DRILL_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    speed = "float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;"
    last_speed_active = "lastDrillSpeed = (speed * dominantItems * warmup) / delay;"
    last_speed_inactive = "lastDrillSpeed = 0f;"
    missing = []
    for snippet in [speed, last_speed_active, last_speed_inactive]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": DRILL_SOURCE,
        "checked": {"speed": speed, "last_speed_active": last_speed_active, "last_speed_inactive": last_speed_inactive},
        "missing": missing,
    }

def verify_drill_item_capacity_source(upstream_root: Path) -> dict[str, Any]:
    block_path = Path(upstream_root) / "core/src/mindustry/world/Block.java"
    drill_path = Path(upstream_root) / DRILL_SOURCE
    block_source = block_path.read_text(encoding="utf-8", errors="replace")
    drill_source = drill_path.read_text(encoding="utf-8", errors="replace")
    block_item_capacity_default = "public int itemCapacity = 10;"
    drill_has_items = "hasItems = true;"
    missing = []
    if block_item_capacity_default not in block_source:
        missing.append(block_item_capacity_default)
    if drill_has_items not in drill_source:
        missing.append(drill_has_items)
    return {
        "source": "core/src/mindustry/world/Block.java",
        "checked": {"block_item_capacity_default": block_item_capacity_default, "drill_has_items": drill_has_items},
        "missing": missing,
    }

def verify_drill_output_batch_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DRILL_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    output_gate = "if(dominantItems > 0 && progress >= delay && items.total() < itemCapacity){"
    amount = "int amount = (int)(progress / delay);"
    offload = "offload(dominantItem);"
    progress_modulo = "progress %= delay;"
    missing = []
    for snippet in [output_gate, amount, offload, progress_modulo]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": DRILL_SOURCE,
        "checked": {"output_gate": output_gate, "amount": amount, "offload": offload, "progress_modulo": progress_modulo},
        "missing": missing,
    }

def verify_drill_dump_timer_source(upstream_root: Path) -> dict[str, Any]:
    drill_path = Path(upstream_root) / DRILL_SOURCE
    block_path = Path(upstream_root) / "core/src/mindustry/world/Block.java"
    drill_source = drill_path.read_text(encoding="utf-8", errors="replace")
    block_source = block_path.read_text(encoding="utf-8", errors="replace")
    timer_dump = "protected final int timerDump = timers++;"
    dump_time_default = "public int dumpTime = 5;"
    dump_gate = "if(timer(timerDump, dumpTime / timeScale)){"
    dump_call = "dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);"
    missing = []
    for snippet, source in [
        (timer_dump, block_source),
        (dump_time_default, block_source),
        (dump_gate, drill_source),
        (dump_call, drill_source),
    ]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": DRILL_SOURCE,
        "checked": {
            "timer_dump": timer_dump,
            "dump_time_default": dump_time_default,
            "dump_gate": dump_gate,
            "dump_call": dump_call,
        },
        "missing": missing,
    }

def verify_drill_progress_fraction_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DRILL_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    progress_method = "public float progress(){"
    progress_fraction = "return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));"
    missing = []
    for snippet in [progress_method, progress_fraction]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": DRILL_SOURCE,
        "checked": {"progress_method": progress_method, "progress_fraction": progress_fraction},
        "missing": missing,
    }

def verify_building_offload_inventory_fallback_source(upstream_root: Path) -> dict[str, Any]:
    building_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    item_module_path = Path(upstream_root) / ITEM_MODULE_SOURCE
    building_source = building_path.read_text(encoding="utf-8", errors="replace")
    item_module_source = item_module_path.read_text(encoding="utf-8", errors="replace")
    offload_method = "public void offload(Item item){"
    offload_produced = "produced(item, 1);"
    offload_neighbor = "other.handleItem(self(), item);"
    offload_fallback = "handleItem(self(), item);"
    item_module_add = "items[item] += amount;"
    missing = []
    for snippet, source in [
        (offload_method, building_source),
        (offload_produced, building_source),
        (offload_neighbor, building_source),
        (offload_fallback, building_source),
        (item_module_add, item_module_source),
    ]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "offload_method": offload_method,
            "offload_produced": offload_produced,
            "offload_neighbor": offload_neighbor,
            "offload_fallback": offload_fallback,
            "item_module_add": item_module_add,
        },
        "missing": missing,
    }

def verify_building_dump_remove_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    dump_method = "public boolean dump(Item todump){"
    dump_guard = "if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;"
    dump_neighbor = "other.handleItem(self(), todump);"
    dump_remove = "items.remove(todump, 1);"
    dump_success = "return true;"
    missing = []
    for snippet in [dump_method, dump_guard, dump_neighbor, dump_remove, dump_success]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "dump_method": dump_method,
            "dump_guard": dump_guard,
            "dump_neighbor": dump_neighbor,
            "dump_remove": dump_remove,
            "dump_success": dump_success,
        },
        "missing": missing,
    }

def verify_building_dump_accept_source(upstream_root: Path) -> dict[str, Any]:
    building_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    core_path = Path(upstream_root) / CORE_BLOCK_SOURCE
    building_source = building_path.read_text(encoding="utf-8", errors="replace")
    core_source = core_path.read_text(encoding="utf-8", errors="replace")
    dump_accept_guard = "if(other.acceptItem(self(), todump) && canDump(other, todump)){"
    dump_neighbor = "other.handleItem(self(), todump);"
    dump_remove = "items.remove(todump, 1);"
    core_accept_item = "return state.rules.coreIncinerates || items.get(item) < getMaximumAccepted(item);"
    core_maximum_accepted = "return state.rules.coreIncinerates ? Integer.MAX_VALUE/2 : storageCapacity;"
    missing = []
    for snippet, source in [
        (dump_accept_guard, building_source),
        (dump_neighbor, building_source),
        (dump_remove, building_source),
        (core_accept_item, core_source),
        (core_maximum_accepted, core_source),
    ]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "core_source": CORE_BLOCK_SOURCE,
        "checked": {
            "dump_accept_guard": dump_accept_guard,
            "dump_neighbor": dump_neighbor,
            "dump_remove": dump_remove,
            "core_accept_item": core_accept_item,
            "core_maximum_accepted": core_maximum_accepted,
        },
        "missing": missing,
    }

def verify_core_handle_item_source(upstream_root: Path) -> dict[str, Any]:
    core_path = Path(upstream_root) / CORE_BLOCK_SOURCE
    building_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    core_source = core_path.read_text(encoding="utf-8", errors="replace")
    building_source = building_path.read_text(encoding="utf-8", errors="replace")
    core_handle_method = "public void handleItem(Building source, Item item){"
    core_full_gate = "if(items.get(item) >= storageCapacity || incinerate){"
    core_handle_else = "}else{"
    core_super_handle = "super.handleItem(source, item);"
    building_handle_add = "items.add(item, 1);"
    missing = []
    for snippet, source in [
        (core_handle_method, core_source),
        (core_full_gate, core_source),
        (core_handle_else, core_source),
        (core_super_handle, core_source),
        (building_handle_add, building_source),
    ]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": CORE_BLOCK_SOURCE,
        "building_source": BUILDING_COMP_SOURCE,
        "checked": {
            "core_handle_method": core_handle_method,
            "core_full_gate": core_full_gate,
            "core_handle_else": core_handle_else,
            "core_super_handle": core_super_handle,
            "building_handle_add": building_handle_add,
        },
        "missing": missing,
    }

def verify_building_dump_cursor_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    cursor_field = "transient int cdump;"
    cursor_snapshot = "int dump = this.cdump;"
    cursor_index = "Building other = proximity.get((i + dump) % proximity.size);"
    increment_call = "incrementDump(proximity.size);"
    increment_method = "public void incrementDump(int prox){"
    increment_guard = "if(prox != 0){"
    increment_modulo = "cdump = ((cdump + 1) % prox);"
    missing = []
    for snippet in [
        cursor_field,
        cursor_snapshot,
        cursor_index,
        increment_call,
        increment_method,
        increment_guard,
        increment_modulo,
    ]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "cursor_field": cursor_field,
            "cursor_snapshot": cursor_snapshot,
            "cursor_index": cursor_index,
            "increment_call": increment_call,
            "increment_method": increment_method,
            "increment_guard": increment_guard,
            "increment_modulo": increment_modulo,
        },
        "missing": missing,
    }

def verify_building_dump_accumulate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    accum_field = "private transient float dumpAccum;"
    accum_no_arg = "public boolean dumpAccumulate(){"
    accum_no_arg_call = "return dumpAccumulate(null);"
    accum_method = "public boolean dumpAccumulate(Item item){"
    accum_result = "boolean res = false;"
    accum_add_delta = "dumpAccum += delta();"
    accum_loop = "while(dumpAccum >= 1f){"
    accum_dump = "res |= dump(item);"
    accum_subtract = "dumpAccum -=1f;"
    accum_return = "return res;"
    missing = []
    for snippet in [
        accum_field,
        accum_no_arg,
        accum_no_arg_call,
        accum_method,
        accum_result,
        accum_add_delta,
        accum_loop,
        accum_dump,
        accum_subtract,
        accum_return,
    ]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "accum_field": accum_field,
            "accum_no_arg": accum_no_arg,
            "accum_no_arg_call": accum_no_arg_call,
            "accum_method": accum_method,
            "accum_result": accum_result,
            "accum_add_delta": accum_add_delta,
            "accum_loop": accum_loop,
            "accum_dump": accum_dump,
            "accum_subtract": accum_subtract,
            "accum_return": accum_return,
        },
        "missing": missing,
    }

def verify_building_move_forward_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    move_method = "public boolean moveForward(Item item){"
    front_lookup = "Building other = front();"
    move_guard = "if(other != null && other.team == team && other.acceptItem(self(), item)){"
    move_handle = "other.handleItem(self(), item);"
    move_success = "return true;"
    move_failure = "return false;"
    missing = []
    for snippet in [move_method, front_lookup, move_guard, move_handle, move_success, move_failure]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "move_method": move_method,
            "front_lookup": front_lookup,
            "move_guard": move_guard,
            "move_handle": move_handle,
            "move_success": move_success,
            "move_failure": move_failure,
        },
        "missing": missing,
    }

def verify_building_handle_accept_item_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    handle_method = "public void handleItem(Building source, Item item){"
    handle_add = "items.add(item, 1);"
    accept_method = "public boolean acceptItem(Building source, Item item){"
    accept_guard = "return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);"
    missing = []
    for snippet in [handle_method, handle_add, accept_method, accept_guard]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "handle_method": handle_method,
            "handle_add": handle_add,
            "accept_method": accept_method,
            "accept_guard": accept_guard,
        },
        "missing": missing,
    }

def verify_building_handle_accept_liquid_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    accept_method = "public boolean acceptLiquid(Building source, Liquid liquid){"
    accept_guard = "return block.hasLiquids && block.consumesLiquid(liquid);"
    handle_method = "public void handleLiquid(Building source, Liquid liquid, float amount){"
    handle_add = "liquids.add(liquid, amount);"
    missing = []
    for snippet in [accept_method, accept_guard, handle_method, handle_add]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "accept_method": accept_method,
            "accept_guard": accept_guard,
            "handle_method": handle_method,
            "handle_add": handle_add,
        },
        "missing": missing,
    }

def verify_building_maximum_accepted_stack_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    maximum_method = "public int getMaximumAccepted(Item item){"
    maximum_return = "return block.itemCapacity;"
    stack_method = "public void handleStack(Item item, int amount, @Nullable Teamc source){"
    stack_no_sleep = "noSleep();"
    stack_add = "items.add(item, amount);"
    missing = []
    for snippet in [maximum_method, maximum_return, stack_method, stack_no_sleep, stack_add]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "maximum_method": maximum_method,
            "maximum_return": maximum_return,
            "stack_method": stack_method,
            "stack_no_sleep": stack_no_sleep,
            "stack_add": stack_add,
        },
        "missing": missing,
    }

def verify_building_accept_stack_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    accept_stack_method = "public int acceptStack(Item item, int amount, Teamc source){"
    accept_stack_guard = "if(acceptItem(self(), item) && block.hasItems && (source == null || source.team() == team)){"
    accept_stack_amount = "return Math.min(getMaximumAccepted(item) - items.get(item), amount);"
    accept_stack_failure = "return 0;"
    missing = []
    for snippet in [accept_stack_method, accept_stack_guard, accept_stack_amount, accept_stack_failure]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "accept_stack_method": accept_stack_method,
            "accept_stack_guard": accept_stack_guard,
            "accept_stack_amount": accept_stack_amount,
            "accept_stack_failure": accept_stack_failure,
        },
        "missing": missing,
    }

def verify_building_remove_stack_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    remove_stack_method = "public int removeStack(Item item, int amount){"
    remove_stack_null_guard = "if(items == null) return 0;"
    remove_stack_clamp = "amount = Math.min(amount, items.get(item));"
    remove_stack_no_sleep = "noSleep();"
    remove_stack_remove = "items.remove(item, amount);"
    remove_stack_return = "return amount;"
    missing = []
    for snippet in [remove_stack_method, remove_stack_null_guard, remove_stack_clamp, remove_stack_no_sleep, remove_stack_remove, remove_stack_return]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "remove_stack_method": remove_stack_method,
            "remove_stack_null_guard": remove_stack_null_guard,
            "remove_stack_clamp": remove_stack_clamp,
            "remove_stack_no_sleep": remove_stack_no_sleep,
            "remove_stack_remove": remove_stack_remove,
            "remove_stack_return": remove_stack_return,
        },
        "missing": missing,
    }

def verify_building_payload_default_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    accept_payload_method = "public boolean acceptPayload(Building source, Payload payload){"
    accept_payload_return = "return false;"
    handle_payload_method = "public void handlePayload(Building source, Payload payload){"
    handle_payload_empty_body = "public void handlePayload(Building source, Payload payload){\n\n    }"
    missing = []
    for snippet in [accept_payload_method, accept_payload_return, handle_payload_method, handle_payload_empty_body]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "accept_payload_method": accept_payload_method,
            "accept_payload_return": accept_payload_return,
            "handle_payload_method": handle_payload_method,
            "handle_payload_empty_body": handle_payload_empty_body,
        },
        "missing": missing,
    }

def verify_building_move_payload_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    move_payload_method = "public boolean movePayload(Payload todump){"
    move_payload_offset = "int trns = block.size/2 + 1;"
    move_payload_next = "Tile next = tile.nearby(Geometry.d4(rotation).x * trns, Geometry.d4(rotation).y * trns);"
    move_payload_guard = "if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){"
    move_payload_handle = "next.build.handlePayload(self(), todump);"
    move_payload_success = "return true;"
    move_payload_failure = "return false;"
    missing = []
    for snippet in [move_payload_method, move_payload_offset, move_payload_next, move_payload_guard, move_payload_handle, move_payload_success, move_payload_failure]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "move_payload_method": move_payload_method,
            "move_payload_offset": move_payload_offset,
            "move_payload_next": move_payload_next,
            "move_payload_guard": move_payload_guard,
            "move_payload_handle": move_payload_handle,
            "move_payload_success": move_payload_success,
            "move_payload_failure": move_payload_failure,
        },
        "missing": missing,
    }

def verify_building_dump_payload_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    dump_payload_method = "public boolean dumpPayload(Payload todump){"
    dump_payload_empty_guard = "if(proximity.size == 0) return false;"
    dump_payload_cursor_snapshot = "int dump = this.cdump;"
    dump_payload_loop = "for(int i = 0; i < proximity.size; i++){"
    dump_payload_index = "Building other = proximity.get((i + dump) % proximity.size);"
    dump_payload_accept_guard = "if(other.acceptPayload(self(), todump)){"
    dump_payload_handle = "other.handlePayload(self(), todump);"
    dump_payload_increment = "incrementDump(proximity.size);"
    dump_payload_success = "return true;"
    dump_payload_failure = "return false;"
    missing = []
    for snippet in [dump_payload_method, dump_payload_empty_guard, dump_payload_cursor_snapshot, dump_payload_loop, dump_payload_index, dump_payload_accept_guard, dump_payload_handle, dump_payload_increment, dump_payload_success, dump_payload_failure]:
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {
            "dump_payload_method": dump_payload_method,
            "dump_payload_empty_guard": dump_payload_empty_guard,
            "dump_payload_cursor_snapshot": dump_payload_cursor_snapshot,
            "dump_payload_loop": dump_payload_loop,
            "dump_payload_index": dump_payload_index,
            "dump_payload_accept_guard": dump_payload_accept_guard,
            "dump_payload_handle": dump_payload_handle,
            "dump_payload_increment": dump_payload_increment,
            "dump_payload_success": dump_payload_success,
            "dump_payload_failure": dump_payload_failure,
        },
        "missing": missing,
    }

def verify_mend_projector_light_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / MEND_PROJECTOR_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_mend_projector_light(source)
    actual_props = _registry_block(registry, "mend-projector").get("properties", {})
    mismatches: list[dict[str, Any]] = []
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    return {
        "source": MEND_PROJECTOR_SOURCE,
        "block": "mend-projector",
        "checked": expected,
        "mismatches": mismatches,
    }

def verify_mend_projector_scaled_health_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DUO_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_scaled_health_block(source, "mendProjector", "MendProjector")
    actual = _registry_block(registry, "mend-projector")
    mismatches: list[dict[str, Any]] = []
    actual_props = actual.get("properties", {})
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    return {
        "source": DUO_SOURCE,
        "block": "mend-projector",
        "checked": expected,
        "mismatches": mismatches,
    }

def verify_mend_projector_repair_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DUO_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_mend_projector_repair(source, "mendProjector", "MendProjector")
    actual = _registry_block(registry, "mend-projector")
    mismatches: list[dict[str, Any]] = []
    actual_props = actual.get("properties", {})
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    return {
        "source": DUO_SOURCE,
        "block": "mend-projector",
        "checked": expected,
        "mismatches": mismatches,
    }

def verify_mend_projector_repair_amount_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DUO_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    repair = _extract_mend_projector_repair(source, "mendProjector", "MendProjector")
    health = _extract_scaled_health_block(source, "mendProjector", "MendProjector")["health"]
    expected = _mend_projector_repair_amount(health, repair["healPercent"], repair["phaseBoost"])
    actual_props = _registry_block(registry, "mend-projector").get("properties", {})
    actual = _mend_projector_repair_amount(actual_props.get("health"), actual_props.get("healPercent"), actual_props.get("phaseBoost"))
    mismatches: list[dict[str, Any]] = []
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, key, expected_value, actual.get(key))
    return {
        "source": DUO_SOURCE,
        "block": "mend-projector",
        "checked": expected,
        "mismatches": mismatches,
    }


def verify_duo_source_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DUO_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_source_duo(source)
    actual = _registry_block(registry, "duo")
    mismatches = _compare_duo(expected, actual)
    return {
        "source": DUO_SOURCE,
        "block": "duo",
        "checked": expected,
        "mismatches": mismatches,
    }


def _extract_source_duo(source: str) -> dict[str, Any]:
    match = re.search(r"\bduo\s*=\s*new\s+ItemTurret\s*\(\s*\"duo\"\s*\)", source)
    if not match:
        raise ValueError("duo ItemTurret initializer not found in Blocks.java")
    body = _double_brace_body(source, match.end())
    properties: dict[str, Any] = {}
    for key in ["reload", "range", "health", "shootY", "inaccuracy", "rotateSpeed", "shootCone", "recoil", "recoils"]:
        value = _numeric_assignment(body, key)
        if value is not None:
            properties[key] = value
    shoot_pattern = _shoot_alternate_pattern(body)
    if shoot_pattern is not None:
        properties["shootPattern"] = shoot_pattern
    limit_range_margin = _limit_range_margin(body)
    if limit_range_margin is not None:
        properties["limitRangeMargin"] = limit_range_margin
    ammo = {}
    ammo_pattern = re.compile(
        r"Items\.([A-Za-z_]\w*)\s*,\s*new\s+BasicBulletType\s*\(\s*"
        r"([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*,\s*"
        r"([0-9_]+(?:\.[0-9_]+)?[fFdD]?)"
        r"(?:\s*,\s*\"([^\"]+)\")?",
        re.MULTILINE,
    )
    for ammo_match in ammo_pattern.finditer(body):
        item, speed, damage, sprite = ammo_match.groups()
        bullet_body = _double_brace_body(body, ammo_match.end())
        entry: dict[str, Any] = {
            "speed": _number_literal(speed),
            "damage": _number_literal(damage),
            "sprite": sprite or "bullet",
        }
        for key in ["width", "height", "hitSize", "lifetime", "ammoMultiplier", "reloadMultiplier", "rangeChange", "extraRangeMargin", "inaccuracy"]:
            value = _numeric_assignment(bullet_body, key)
            if value is not None:
                entry[key] = value
        if limit_range_margin is not None:
            entry["lifetime"] = _limit_range_lifetime(properties, entry, limit_range_margin)
        ammo[_camel_to_kebab(item)] = entry
    return {"properties": properties, "ammo": ammo}


def _registry_block(registry: dict[str, Any], block_id: str) -> dict[str, Any]:
    for block in registry.get("blocks", []):
        if block.get("id") == block_id:
            return block
    raise ValueError(f"generated registry block not found: {block_id}")


def _compare_duo(expected: dict[str, Any], actual_block: dict[str, Any]) -> list[dict[str, Any]]:
    mismatches: list[dict[str, Any]] = []
    actual_props = actual_block.get("properties", {})
    for key, expected_value in expected["properties"].items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    actual_ammo = {entry.get("item"): entry for entry in actual_props.get("ammo", [])}
    for item, expected_entry in expected["ammo"].items():
        actual_entry = actual_ammo.get(item, {})
        for key, expected_value in expected_entry.items():
            _append_mismatch(mismatches, f"ammo.{item}.{key}", expected_value, actual_entry.get(key))
    return mismatches


def _append_mismatch(mismatches: list[dict[str, Any]], field: str, expected: Any, actual: Any) -> None:
    if isinstance(expected, float) or isinstance(actual, float):
        if actual is None or abs(float(expected) - float(actual)) > 0.000001:
            mismatches.append({"field": field, "expected": expected, "actual": actual})
    elif expected != actual:
        mismatches.append({"field": field, "expected": expected, "actual": actual})


def _double_brace_body(source: str, start: int) -> str:
    double_brace = source.find("{{", start)
    if double_brace == -1:
        return ""
    depth = 0
    for index in range(double_brace, len(source)):
        char = source[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[double_brace:index + 1]
    return ""


def _numeric_assignment(source: str, key: str) -> int | float | None:
    match = re.search(rf"\b{key}\s*=\s*([0-9_]+(?:\.[0-9_]+)?[fFdDlL]?)\s*;", source)
    return _number_literal(match.group(1)) if match else None

def _shoot_alternate_pattern(source: str) -> dict[str, Any] | None:
    match = re.search(r"\bshoot\s*=\s*new\s+ShootAlternate\s*\(\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*\)", source)
    if not match:
        return None
    return {"type": "ShootAlternate", "spread": _number_literal(match.group(1))}

def _limit_range_margin(source: str) -> float | None:
    match = re.search(r"\blimitRange\s*\(\s*(-?[0-9_]+(?:\.[0-9_]+)?[fFdD]?)?\s*\)\s*;", source)
    if not match:
        return None
    raw = match.group(1)
    return 9.0 if raw is None else float(_number_literal(raw))

def _limit_range_lifetime(properties: dict[str, Any], bullet: dict[str, Any], margin: float) -> float:
    speed = float(bullet.get("speed", 0.0))
    if speed == 0.0:
        return float(bullet.get("lifetime", 40.0))
    real_range = float(properties.get("range", 0.0)) + float(bullet.get("rangeChange", 0.0))
    return (real_range + margin + float(bullet.get("extraRangeMargin", 0.0)) + 10.0) / speed


def _number_literal(raw: str) -> int | float:
    number = raw.replace("_", "")
    suffix = number[-1:] if number else ""
    if suffix in "fFdDlL":
        number = number[:-1]
    return float(number) if "." in number or suffix in "fFdD" else int(number)


def _camel_to_kebab(name: str) -> str:
    return re.sub(r"(?<!^)([A-Z])", r"-\1", name).lower()

def _extract_scaled_health_block(source: str, field: str, implementation: str) -> dict[str, Any]:
    match = re.search(rf'\b{field}\s*=\s*new\s+{implementation}\s*\(\s*"[^"]+"\s*\)', source)
    if not match:
        raise ValueError(f"{field} {implementation} initializer not found in Blocks.java")
    body = _double_brace_body(source, match.end())
    size = int(_numeric_assignment(body, "size") or 1)
    scaled_health = _numeric_assignment(body, "scaledHealth")
    if scaled_health is None:
        raise ValueError(f"{field} scaledHealth assignment not found in Blocks.java")
    return {"size": size, "scaledHealth": scaled_health, "health": int(size * size * float(scaled_health))}

def _extract_mend_projector_repair(source: str, field: str, implementation: str) -> dict[str, Any]:
    match = re.search(rf'\b{field}\s*=\s*new\s+{implementation}\s*\(\s*"[^"]+"\s*\)', source)
    if not match:
        raise ValueError(f"{field} {implementation} initializer not found in Blocks.java")
    body = _double_brace_body(source, match.end())
    expected: dict[str, Any] = {}
    for key, default in {"healPercent": 12.0, "phaseBoost": 12.0, "phaseRangeBoost": 50.0}.items():
        value = _numeric_assignment(body, key)
        expected[key] = float(value) if value is not None else default
    booster_item = _boost_item(body)
    if booster_item is not None:
        expected["boosterItem"] = booster_item
        expected["boosterUseTime"] = float(_numeric_assignment(body, "useTime") or 400.0)
    return expected

def _extract_overdrive_projector_params(blocks_source: str, overdrive_source: str, field: str, implementation: str) -> dict[str, Any]:
    match = re.search(rf'\b{field}\s*=\s*new\s+{implementation}\s*\(\s*"[^"]+"\s*\)', blocks_source)
    if not match:
        raise ValueError(f"{field} {implementation} initializer not found in Blocks.java")
    body = _double_brace_body(blocks_source, match.end())
    expected: dict[str, Any] = {}
    for key in ["range", "reload", "speedBoost", "speedBoostPhase", "phaseRangeBoost"]:
        value = _numeric_assignment(body, key)
        if value is None:
            value = _numeric_assignment(overdrive_source, key)
        if value is None:
            raise ValueError(f"OverdriveProjector {key} default not found")
        expected[key] = float(value)
    booster_item = _boost_item(body)
    if booster_item is not None:
        expected["boosterItem"] = booster_item
        expected["boosterUseTime"] = float(_numeric_assignment(body, "useTime") or _numeric_assignment(overdrive_source, "useTime") or 400.0)
    for key in ["baseColor", "phaseColor"]:
        value = _color_value_assignment(body, key)
        if value is None:
            value = _color_value_assignment(overdrive_source, key)
        if value is None:
            raise ValueError(f"OverdriveProjector {key} default not found")
        expected[key] = value
    emit_light = _boolean_assignment(body, "emitLight")
    if emit_light is None:
        emit_light = _boolean_assignment(overdrive_source, "emitLight")
    if emit_light is None:
        raise ValueError("OverdriveProjector emitLight assignment not found")
    expected["emitLight"] = emit_light
    light_radius = _numeric_assignment(body, "lightRadius")
    if light_radius is None:
        light_radius = _numeric_assignment(overdrive_source, "lightRadius")
    if light_radius is None:
        raise ValueError("OverdriveProjector lightRadius assignment not found")
    expected["lightRadius"] = float(light_radius)
    has_boost = _boolean_assignment(body, "hasBoost")
    if has_boost is None:
        has_boost = _boolean_assignment(overdrive_source, "hasBoost")
    if has_boost is None:
        raise ValueError("OverdriveProjector hasBoost assignment not found")
    expected["hasBoost"] = has_boost
    can_overdrive = _boolean_assignment(body, "canOverdrive")
    if can_overdrive is None:
        can_overdrive = _boolean_assignment(overdrive_source, "canOverdrive")
    if can_overdrive is None:
        raise ValueError("OverdriveProjector canOverdrive assignment not found")
    expected["canOverdrive"] = can_overdrive
    return expected
def _mend_projector_repair_amount(health: Any, heal_percent: Any, phase_boost: Any, phase_heat: float = 0.0, efficiency: float = 1.0) -> dict[str, Any]:
    health_value = float(health)
    heal_value = float(heal_percent)
    phase_boost_value = float(phase_boost)
    return {
        "health": int(health_value) if health_value.is_integer() else health_value,
        "healPercent": heal_value,
        "phaseBoost": phase_boost_value,
        "phaseHeat": phase_heat,
        "efficiency": efficiency,
        "repairAmount": health_value * (heal_value + phase_heat * phase_boost_value) / 100.0 * efficiency,
    }

def _boost_item(source: str) -> str | None:
    match = re.search(r"\bconsumeItem\s*\(\s*Items\.([A-Za-z_]\w*)\s*(?:,\s*[0-9_]+)?\s*\)\s*\.\s*boost\s*\(", source)
    return _camel_to_kebab(match.group(1)) if match else None

def _extract_mend_projector_light(source: str) -> dict[str, Any]:
    base_color = _color_value_assignment(source, "baseColor")
    emit_light = _boolean_assignment(source, "emitLight")
    light_radius = _numeric_assignment(source, "lightRadius")
    if base_color is None:
        raise ValueError("MendProjector baseColor default not found")
    if emit_light is None:
        raise ValueError("MendProjector emitLight assignment not found")
    if light_radius is None:
        raise ValueError("MendProjector lightRadius assignment not found")
    return {"baseColor": base_color, "emitLight": emit_light, "lightRadius": float(light_radius)}

def _boolean_assignment(source: str, key: str) -> bool | None:
    match = re.search(rf"\b{key}\s*=\s*(true|false)\s*;", source)
    return match.group(1) == "true" if match else None

def _color_value_assignment(source: str, key: str) -> str | None:
    match = re.search(rf"\b{key}\s*=\s*Color\.valueOf\(\s*\"([0-9A-Fa-f]+)\"\s*\)\s*;", source)
    return match.group(1).lower() if match else None
