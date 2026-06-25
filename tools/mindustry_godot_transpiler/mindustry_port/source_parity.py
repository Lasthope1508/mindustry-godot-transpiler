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
BLOCK_SOURCE = "core/src/mindustry/world/Block.java"
CORE_BLOCK_SOURCE = "core/src/mindustry/world/blocks/storage/CoreBlock.java"
ITEM_MODULE_SOURCE = "core/src/mindustry/world/modules/ItemModule.java"
ARC_MATHF_SOURCE = "arc-core/src/arc/math/Mathf.java"
ARC_RAND_SOURCE = "arc-core/src/arc/math/Rand.java"
ARC_STRINGS_SOURCE = "arc-core/src/arc/util/Strings.java"

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

def verify_building_can_be_replaced_source(upstream_root: Path) -> dict[str, Any]:
    building_source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    block_source_path = Path(upstream_root) / BLOCK_SOURCE
    building_source = building_source_path.read_text(encoding="utf-8", errors="replace")
    block_source = block_source_path.read_text(encoding="utf-8", errors="replace")
    building_can_be_replaced_method = "public boolean canBeReplaced(Block other){"
    building_can_be_replaced_delegate = "return other.canReplace(block);"
    block_can_replace_method = "public boolean canReplace(Block other){"
    block_can_replace_always = "if(other.alwaysReplace) return true;"
    block_can_replace_privileged = "if(other.privileged) return false;"
    block_can_replace_replaceable = "return other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this) &&"
    block_can_replace_size = "(size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace)));"
    checks = {
        "building_can_be_replaced_method": building_can_be_replaced_method,
        "building_can_be_replaced_delegate": building_can_be_replaced_delegate,
        "block_can_replace_method": block_can_replace_method,
        "block_can_replace_always": block_can_replace_always,
        "block_can_replace_privileged": block_can_replace_privileged,
        "block_can_replace_replaceable": block_can_replace_replaceable,
        "block_can_replace_size": block_can_replace_size,
    }
    missing = []
    for key, snippet in checks.items():
        source = building_source if key.startswith("building_") else block_source
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "block_source": BLOCK_SOURCE,
        "checked": checks,
        "missing": missing,
    }

def verify_building_default_activity_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    should_consume_method = "public boolean shouldConsume(){"
    should_consume_return = "return enabled;"
    production_valid_method = "public boolean productionValid(){"
    production_valid_return = "return true;"
    consume_trigger_valid_method = "public boolean consumeTriggerValid(){"
    consume_trigger_valid_return = "return false;"
    power_production_method = "public float getPowerProduction(){"
    power_production_return = "return 0f;"
    checked = {
        "should_consume_method": should_consume_method,
        "should_consume_return": should_consume_return,
        "production_valid_method": production_valid_method,
        "production_valid_return": production_valid_return,
        "consume_trigger_valid_method": consume_trigger_valid_method,
        "consume_trigger_valid_return": consume_trigger_valid_return,
        "power_production_method": power_production_method,
        "power_production_return": power_production_return,
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_progress_display_ambient_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    progress_method = "public float getProgressIncrease(float baseTime){"
    progress_return = "return 1f / baseTime * edelta();"
    display_efficiency_method = "public float getDisplayEfficiency(){"
    display_efficiency_return = "return getProgressIncrease(1f) / edelta();"
    ambient_method = "public boolean shouldAmbientSound(){"
    ambient_return = "return shouldConsume();"
    checked = {
        "progress_method": progress_method,
        "progress_return": progress_return,
        "display_efficiency_method": display_efficiency_method,
        "display_efficiency_return": display_efficiency_return,
        "ambient_method": ambient_method,
        "ambient_return": ambient_return,
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_status_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    draw_status_method = "public void drawStatus(){"
    draw_status_guard = "if(block.enableDrawStatus && block.consumers.length > 0){"
    draw_status_multiplier = "float multiplier = block.size > 1 ? 1 : 0.64f;"
    draw_status_brcx = "float brcx = x + (block.size * tilesize / 2f) - (tilesize * multiplier / 2f);"
    draw_status_brcy = "float brcy = y - (block.size * tilesize / 2f) + (tilesize * multiplier / 2f);"
    draw_status_gray_square = "Fill.square(brcx, brcy, 2.5f * multiplier, 45);"
    draw_status_color_square = "Fill.square(brcx, brcy, 1.5f * multiplier, 45);"
    checked = {
        "draw_status_method": draw_status_method,
        "draw_status_guard": draw_status_guard,
        "draw_status_multiplier": draw_status_multiplier,
        "draw_status_brcx": draw_status_brcx,
        "draw_status_brcy": draw_status_brcy,
        "draw_status_gray_square": draw_status_gray_square,
        "draw_status_color_square": draw_status_color_square,
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_cracks_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    draw_cracks_method = "public void drawCracks(){"
    draw_cracks_guard = "if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;"
    draw_cracks_id = "int id = pos();"
    draw_cracks_region = "TextureRegion region = renderer.blocks.cracks[block.size - 1][Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)];"
    draw_cracks_color = "Draw.colorl(0.2f, 0.1f + (1f - healthf())* 0.6f);"
    draw_cracks_rotation = "Draw.rect(region, x, y, (id%4)*90);"
    checked = {
        "draw_cracks_method": draw_cracks_method,
        "draw_cracks_guard": draw_cracks_guard,
        "draw_cracks_id": draw_cracks_id,
        "draw_cracks_region": draw_cracks_region,
        "draw_cracks_color": draw_cracks_color,
        "draw_cracks_rotation": draw_cracks_rotation,
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_select_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    draw_select_method = "public void drawSelect(){"
    draw_select_overlay = "block.drawOverlay(x, y, rotation);"
    draw_select_status_guard = "if(status() == BlockStatus.inactiveUnitFactory){"
    draw_select_place_text = "block.drawPlaceText(Core.bundle.format(\"rules.unitfactoryactivation.objective\", UI.formatTime((float)Math.max(0f, state.rules.unitActivationDelay(team) - state.tick))), tile.x, tile.y, false);"
    checked = {
        "draw_select_method": draw_select_method,
        "draw_select_overlay": draw_select_overlay,
        "draw_select_status_guard": draw_select_status_guard,
        "draw_select_place_text": draw_select_place_text,
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_item_selection_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    draw_item_selection_method = "public void drawItemSelection(@Nullable UnlockableContent selection){"
    draw_item_selection_guard = "if(selection != null){"
    draw_item_selection_geometry = "float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;"
    draw_item_selection_shadow_mix = "Draw.mixcol(Color.darkGray, 1f);"
    draw_item_selection_shadow_rect = "Draw.rect(selection.fullIcon, dx, dy - 1, s, h);"
    draw_item_selection_reset = "Draw.reset();"
    draw_item_selection_rect = "Draw.rect(selection.fullIcon, dx, dy, s, h);"
    checked = {
        "draw_item_selection_method": draw_item_selection_method,
        "draw_item_selection_guard": draw_item_selection_guard,
        "draw_item_selection_geometry": draw_item_selection_geometry,
        "draw_item_selection_shadow_mix": draw_item_selection_shadow_mix,
        "draw_item_selection_shadow_rect": draw_item_selection_shadow_rect,
        "draw_item_selection_reset": draw_item_selection_reset,
        "draw_item_selection_rect": draw_item_selection_rect,
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_disabled_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    draw_disabled_method = "public void drawDisabled(){"
    draw_disabled_color = "Draw.color(Color.scarlet);"
    draw_disabled_alpha = "Draw.alpha(0.8f);"
    draw_disabled_size = "float size = 6f;"
    draw_disabled_rect = "Draw.rect(Icon.cancel.getRegion(), x, y, size, size);"
    draw_disabled_reset = "Draw.reset();"
    checked = {
        "draw_disabled_method": draw_disabled_method,
        "draw_disabled_color": draw_disabled_color,
        "draw_disabled_alpha": draw_disabled_alpha,
        "draw_disabled_size": draw_disabled_size,
        "draw_disabled_rect": draw_disabled_rect,
        "draw_disabled_reset": draw_disabled_reset,
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_drawrot_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    drawrot_method = "public float drawrot(){"
    drawrot_return = "return block.rotate && block.rotateDraw ? rotation * 90 : 0f;"
    checked = {
        "drawrot_method": drawrot_method,
        "drawrot_return": drawrot_return,
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    rand_path = Path(arc_root) / ARC_RAND_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    rand_source = rand_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "draw_method": "public void draw(){",
        "draw_region_guard": "if(block.variants == 0 || block.variantRegions == null){",
        "draw_region_rect": "Draw.rect(block.region, x, y, drawrot());",
        "draw_variant_rect": "Draw.rect(block.variantRegions[Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))], x, y, drawrot());",
        "draw_team_top": "drawTeamTop();",
        "mathf_random_seed_int": "public static int randomSeed(long seed, int min, int max){",
        "mathf_random_seed_set_seed": "seedr.setSeed(seed);",
        "mathf_random_seed_power_two_skip": "if(isPowerOfTwo(max)){",
        "mathf_random_seed_return": "return seedr.nextInt(max - min + 1) + min;",
        "mathf_is_power_of_two": "return value != 0 && (value & value - 1) == 0;",
        "rand_murmur_method": "private static long murmurHash3(long x){",
        "rand_murmur_const1": "x *= 0xff51afd7ed558ccdL;",
        "rand_murmur_const2": "x *= 0xc4ceb9fe1a85ec53L;",
        "rand_next_long_method": "public long nextLong(){",
        "rand_next_long_shift": "s1 ^= s1 << 23;",
        "rand_next_long_return": "return (this.seed1 = (s1 ^ s0 ^ (s1 >>> 17) ^ (s0 >>> 26))) + s0;",
        "rand_next_int_bound": "return (int)nextLong(n);",
        "rand_next_long_bound_bits": "final long bits = nextLong() >>> 1;",
        "rand_next_long_bound_accept": "if(bits - value + (n - 1) >= 0) return value;",
        "rand_set_seed": "long seed0 = murmurHash3(seed == 0 ? Long.MIN_VALUE : seed);",
    }
    source_lookup = {
        "draw_method": source,
        "draw_region_guard": source,
        "draw_region_rect": source,
        "draw_variant_rect": source,
        "draw_team_top": source,
        "mathf_random_seed_int": mathf_source,
        "mathf_random_seed_set_seed": mathf_source,
        "mathf_random_seed_power_two_skip": mathf_source,
        "mathf_random_seed_return": mathf_source,
        "mathf_is_power_of_two": mathf_source,
        "rand_murmur_method": rand_source,
        "rand_murmur_const1": rand_source,
        "rand_murmur_const2": rand_source,
        "rand_next_long_method": rand_source,
        "rand_next_long_shift": rand_source,
        "rand_next_long_return": rand_source,
        "rand_next_int_bound": rand_source,
        "rand_next_long_bound_bits": rand_source,
        "rand_next_long_bound_accept": rand_source,
        "rand_set_seed": rand_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_lookup[key]:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "arc_rand_source": ARC_RAND_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_cached_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "draw_cached_method": "public void drawCached(){",
        "draw_cached_delegate": "draw();",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_recache_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "recache_method": "public void recache(){",
        "recache_guard": "if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_payload_draw_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "payload_draw_method": "public void payloadDraw(){",
        "payload_draw_saved_z": "float z = Draw.z();",
        "payload_draw_cached_guard": "if(block.drawCached){",
        "payload_draw_cached_z": "Draw.z(block.buildingCacheLayer.layer);",
        "payload_draw_cached_call": "drawCached();",
        "payload_draw_dynamic_guard": "if(block.drawDynamic){",
        "payload_draw_restore_z": "Draw.z(z);",
        "payload_draw_dynamic_call": "draw();",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_team_top_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "draw_team_top_method": "public void drawTeamTop(){",
        "draw_team_top_found_guard": "if(block.teamRegion.found()){",
        "draw_team_top_color_guard": "if(block.teamRegions[team.id] == block.teamRegion) Draw.color(team.color);",
        "draw_team_top_rect": "Draw.rect(block.teamRegions[team.id], x, y);",
        "draw_team_top_color_reset": "Draw.color();",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_liquid_light_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "draw_liquid_light_method": "public void drawLiquidLight(Liquid liquid, float amount){",
        "draw_liquid_light_amount_guard": "if(amount > 0.01f){",
        "draw_liquid_light_color": "Color color = liquid.lightColor;",
        "draw_liquid_light_fract": "float fract = 1f;",
        "draw_liquid_light_opacity": "float opacity = color.a * fract;",
        "draw_liquid_light_opacity_guard": "if(opacity > 0.001f){",
        "draw_liquid_light_call": "Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_light_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "draw_light_method": "public void drawLight(){",
        "draw_light_liquid_select": "Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;",
        "draw_light_guard": "if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){",
        "draw_light_lerp": "visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);",
        "draw_light_call": "drawLiquidLight(liq, visualLiquid);",
        "mathf_lerp": "return fromValue + (toValue - fromValue) * progress;",
        "mathf_clamp_01": "return Math.max(Math.min(value, 1f), 0f);",
        "mathf_lerp_delta": "return lerp(fromValue, toValue, clamp(progress * Time.delta));",
    }
    source_lookup = {
        "draw_light_method": source,
        "draw_light_liquid_select": source,
        "draw_light_guard": source,
        "draw_light_lerp": source,
        "draw_light_call": source,
        "mathf_lerp": mathf_source,
        "mathf_clamp_01": mathf_source,
        "mathf_lerp_delta": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_lookup[key]:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_draw_team_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "draw_team_method": "public void drawTeam(){",
        "draw_team_color": "Draw.color(team.color);",
        "draw_team_rect": "Draw.rect(\"block-border\", x - block.size * tilesize / 2f + 4, y - block.size * tilesize / 2f + 4);",
        "draw_team_color_reset": "Draw.color();",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_check_suppression_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "is_heal_suppressed_method": "public boolean isHealSuppressed(){",
        "is_heal_suppressed_return": "return block.suppressable && Time.time <= healSuppressionTime;",
        "check_suppression_method": "public boolean checkSuppression(){",
        "check_suppression_guard": "if(isHealSuppressed()){",
        "check_suppression_chance": "if(Mathf.chanceDelta(0.03)){",
        "check_suppression_effect": "Fx.regenSuppressParticle.at(x + Mathf.range(block.size * tilesize/2f - 1f), y + Mathf.range(block.size * tilesize/2f - 1f), suppressColor);",
        "check_suppression_true": "return true;",
        "check_suppression_false": "return false;",
        "mathf_range_float": "return random(-range, range);",
        "mathf_chance_delta": "return rand.nextFloat() < d * Time.delta;",
    }
    source_lookup = {
        "is_heal_suppressed_method": source,
        "is_heal_suppressed_return": source,
        "check_suppression_method": source,
        "check_suppression_guard": source,
        "check_suppression_chance": source,
        "check_suppression_effect": source,
        "check_suppression_true": source,
        "check_suppression_false": source,
        "mathf_range_float": mathf_source,
        "mathf_chance_delta": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_lookup[key]:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_player_placed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "player_placed_call_super": "@CallSuper",
        "player_placed_method": "public void playerPlaced(Object config){",
        "player_placed_empty_body": "public void playerPlaced(Object config){\n\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_placed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "placed_call_super": "@CallSuper",
        "placed_method": "public void placed(){",
        "placed_client_guard": "if(net.client()) return;",
        "placed_power_guard": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){",
        "placed_links": "PowerNode.getNodeLinks(tile, block, team, other -> {",
        "placed_link_missing_guard": "if(!other.power.links.contains(pos())){",
        "placed_configure": "other.configureAny(pos());",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_repaired_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_repaired_call_super": "@CallSuper",
        "on_repaired_method": "public void onRepaired(){",
        "on_repaired_placed": "placed();",
        "on_repaired_fog_guard": "if(block.flags.contains(BlockFlag.hasFogRadius)){",
        "on_repaired_force_update": "fogControl.forceUpdate(team, self());",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_is_commandable_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "is_commandable_method": "public boolean isCommandable(){",
        "is_commandable_return": "return block.commandable;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_is_payload_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "is_payload_comment": "/** @return whether this building is in a payload */",
        "is_payload_method": "public boolean isPayload(){",
        "is_payload_return": "return tile == emptyTile;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_overwrote_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "overwrote_comment": "Called when a block is placed over some other blocks. This seq will always have at least one item.",
        "overwrote_method": "public void overwrote(Seq<Building> previous){",
        "overwrote_empty_body": "public void overwrote(Seq<Building> previous){\n\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_removed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_removed_method": "public void onRemoved(){",
        "on_removed_empty_body": "public void onRemoved(){\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_unit_on_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_on_comment": "Called every frame a unit is on this. Hovering/flying/steppy units do not apply.",
        "unit_on_method": "public void unitOn(Unit unit){",
        "unit_on_empty_body": "public void unitOn(Unit unit){\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_unit_on_any_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_on_any_comment": "Called every frame a unit is on this. Applies to any unit.",
        "unit_on_any_method": "public void unitOnAny(Unit unit){",
        "unit_on_any_empty_body": "public void unitOnAny(Unit unit){\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_unit_removed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_removed_comment": "Called when a unit that spawned at this tile is removed.",
        "unit_removed_method": "public void unitRemoved(Unit unit){",
        "unit_removed_empty_body": "public void unitRemoved(Unit unit){\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_puddle_on_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "puddle_on_comment": "Called when a puddle is on this building. Only called at an interval (40 ticks).",
        "puddle_on_method": "public void puddleOn(Puddle puddle){",
        "puddle_on_empty_body": "public void puddleOn(Puddle puddle){\n\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_configured_type_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "configured_comment": "Called when arbitrary configuration is applied to a tile.",
        "configured_method": "public void configured(@Nullable Unit builder, @Nullable Object value){",
        "configured_type_line": "Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();",
        "configured_item_type": "if(value instanceof Item) type = Item.class;",
        "configured_block_type": "if(value instanceof Block) type = Block.class;",
        "configured_liquid_type": "if(value instanceof Liquid) type = Liquid.class;",
        "configured_unit_type": "if(value instanceof UnitType) type = UnitType.class;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_configured_last_access_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "configured_player_guard": "if(builder != null && builder.isPlayer()){",
        "configured_update_last_access_call": "updateLastAccess(builder.getPlayer());",
        "update_last_access_method": "public void updateLastAccess(Player player){",
        "update_last_access_assignment": "lastAccessed = player.coloredName();",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_configured_direct_handler_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "configured_handler_guard": "if(block.configurations.containsKey(type)){",
        "configured_handler_call": "block.configurations.get(type).get(this, value);",
        "configured_building_copy_branch": "}else if(value instanceof Building build){",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_configured_copy_config_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "configured_building_copy_branch": "}else if(value instanceof Building build){",
        "configured_copy_comment": "//copy config of another building",
        "configured_copy_config_line": "var conf = build.config();",
        "configured_copy_config_guard": "if(conf != null && !(conf instanceof Building)){",
        "configured_copy_config_recurse": "configured(builder, conf);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_tapped_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "tapped_comment": "Called when the block is tapped by the local player.",
        "tapped_method": "public void tapped(){",
        "tapped_empty_body": "public void tapped(){\n\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_after_destroyed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    arc_root = Path(upstream_root).parent / "arc-upstream"
    mathf_path = arc_root / ARC_MATHF_SOURCE
    rand_path = arc_root / ARC_RAND_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    rand_source = rand_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "after_destroyed_comment": "Called *after* the tile has been removed.",
        "after_destroyed_method": "public void afterDestroyed(){",
        "after_destroyed_guard": "if(block.destroyBullet != null){",
        "after_destroyed_team": "block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));",
        "mathf_random_seed_float_max": "public static float randomSeed(long seed, float max){",
        "mathf_random_seed_float_max_seed": "seedr.setSeed(seed * 99999);",
        "mathf_random_seed_float_max_body": "return seedr.nextFloat() * max;",
        "rand_next_float": "return (float)((nextLong() >>> 40) * NORM_FLOAT);",
        "rand_norm_float": "private static final double NORM_FLOAT = 1.0 / (1L << 24);",
    }
    lookup = {
        "after_destroyed_comment": source,
        "after_destroyed_method": source,
        "after_destroyed_guard": source,
        "after_destroyed_team": source,
        "mathf_random_seed_float_max": mathf_source,
        "mathf_random_seed_float_max_seed": mathf_source,
        "mathf_random_seed_float_max_body": mathf_source,
        "rand_next_float": rand_source,
        "rand_norm_float": rand_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in lookup[key]:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "arc_rand_source": ARC_RAND_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_explosion_item_cap_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "explosion_item_cap_comment": "@return the cap for item amount calculations, used when this block explodes.",
        "explosion_item_cap_method": "public int explosionItemCap(){",
        "explosion_item_cap_return": "return block.itemCapacity;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_splash_liquid_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    mathf_path = Path(upstream_root).parent / "arc-upstream" / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "splash_liquid_method": "public void splashLiquid(Liquid liquid, float amount){",
        "splash_liquid_splash": "float splash = Mathf.clamp(amount / 4f, 0f, 10f);",
        "splash_liquid_loop": "for(int i = 0; i < Mathf.clamp(amount / 5, 0, 30); i++){",
        "splash_liquid_delay": "Time.run(i / 2f, () -> {",
        "splash_liquid_tile_world": "Tile other = world.tileWorld(x + Mathf.range(block.size * tilesize / 2), y + Mathf.range(block.size * tilesize / 2));",
        "splash_liquid_deposit_guard": "if(other != null){",
        "splash_liquid_deposit": "Puddles.deposit(other, liquid, splash);",
        "mathf_clamp_float": "return Math.max(Math.min(value, max), min);",
        "mathf_range_float": "public static float range(float range){",
        "mathf_range_float_body": "return random(-range, range);",
    }
    lookup = {
        "splash_liquid_method": source,
        "splash_liquid_splash": source,
        "splash_liquid_loop": source,
        "splash_liquid_delay": source,
        "splash_liquid_tile_world": source,
        "splash_liquid_deposit_guard": source,
        "splash_liquid_deposit": source,
        "mathf_clamp_float": mathf_source,
        "mathf_range_float": mathf_source,
        "mathf_range_float_body": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in lookup[key]:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_deconstructed_liquid_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_deconstructed_comment": "Called when a block begins (not finishes!) deconstruction. The building is still present at this point.",
        "on_deconstructed_method": "public void onDeconstructed(@Nullable Unit builder){",
        "on_deconstructed_liquid_comment": "//deposit non-incinerable liquid on ground",
        "on_deconstructed_liquid_guard": "if(liquids != null && liquids.currentAmount() > 0 && (!liquids.current().incinerable || block.deconstructDropAllLiquid)){",
        "on_deconstructed_per_cell": "float perCell = liquids.currentAmount() / (block.size * block.size) * 2f;",
        "on_deconstructed_deposit": "tile.getLinkedTiles(other -> Puddles.deposit(other, liquids.current(), perCell));",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_item_explosion_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    mathf_path = Path(upstream_root).parent / "arc-upstream" / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_comment": "Called when the block is destroyed. The tile is still intact at this stage.",
        "on_destroyed_method": "public void onDestroyed(){",
        "on_destroyed_base_explosiveness": "float explosiveness = block.baseExplosiveness;",
        "on_destroyed_flammability_zero": "float flammability = 0f;",
        "on_destroyed_power_zero": "float power = 0f;",
        "on_destroyed_has_items_guard": "if(block.hasItems){",
        "on_destroyed_item_loop": "for(Item item : content.items()){",
        "on_destroyed_item_cap": "int amount = Math.min(items.get(item), explosionItemCap());",
        "on_destroyed_item_explosiveness": "explosiveness += item.explosiveness * amount;",
        "on_destroyed_item_flammability": "flammability += item.flammability * amount;",
        "on_destroyed_item_power": "power += item.charge * Mathf.pow(amount, 1.1f) * 150f;",
        "mathf_pow_float": "public static float pow(float a, float b){",
        "mathf_pow_float_body": "return (float)Math.pow(a, b);",
    }
    lookup = {
        "on_destroyed_comment": source,
        "on_destroyed_method": source,
        "on_destroyed_base_explosiveness": source,
        "on_destroyed_flammability_zero": source,
        "on_destroyed_power_zero": source,
        "on_destroyed_has_items_guard": source,
        "on_destroyed_item_loop": source,
        "on_destroyed_item_cap": source,
        "on_destroyed_item_explosiveness": source,
        "on_destroyed_item_flammability": source,
        "on_destroyed_item_power": source,
        "mathf_pow_float": mathf_source,
        "mathf_pow_float_body": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in lookup[key]:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_liquid_explosion_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_has_liquids_guard": "if(block.hasLiquids){",
        "on_destroyed_liquid_flammability": "flammability += liquids.sum((liquid, amount) -> liquid.flammability * amount / 2f);",
        "on_destroyed_liquid_explosiveness": "explosiveness += liquids.sum((liquid, amount) -> liquid.explosiveness * amount / 2f);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_buffered_power_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_buffered_power_guard": "if(block.consPower != null && block.consPower.buffered){",
        "on_destroyed_buffered_power_add": "power += this.power.status * block.consPower.capacity;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_splash_liquid_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_splash_liquid_guard": "if(block.hasLiquids && state.rules.damageExplosions){",
        "on_destroyed_splash_liquid_each": "liquids.each(this::splashLiquid);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_dynamic_explosion_call_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_dynamic_explosion_comment": "//cap explosiveness so fluid tanks/vaults don't instakill units",
        "on_destroyed_dynamic_explosion_call": "Damage.dynamicExplosion(x, y, flammability * block.flammabilityScale, explosiveness * 3.5f * block.explosivenessScale, power, tilesize * block.size / 2f, state.rules.damageExplosions, block.destroyEffect, block.baseShake);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_rubble_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_rubble_guard": "if(block.createRubble && !floor().solid && !floor().isLiquid){",
        "on_destroyed_rubble_effect": "Effect.rubble(x, y, block.size);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_base_sound_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_headless_guard": "if(!headless){",
        "on_destroyed_play_destroy_sound": "playDestroySound();",
        "play_destroy_sound_method": "public void playDestroySound(){",
        "play_destroy_sound_call": "block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_reactive_sound_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    mathf_path = Path(upstream_root).parent / "arc-upstream" / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_explosive_sound_guard": "if(explosiveness > 40f){",
        "on_destroyed_explosive_sound_call": "(Mathf.chance(0.5) ? Sounds.blockExplodeExplosive : Sounds.blockExplodeExplosiveAlt).at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
        "on_destroyed_flammable_sound_guard": "}else if(flammability > 5f){",
        "on_destroyed_flammable_sound_call": "Sounds.blockExplodeFlammable.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
        "mathf_chance_method": "public static boolean chance(double d){",
        "mathf_chance_body": "return d >= 1f || rand.nextFloat() < d;",
    }
    lookup = {
        "on_destroyed_explosive_sound_guard": source,
        "on_destroyed_explosive_sound_call": source,
        "on_destroyed_flammable_sound_guard": source,
        "on_destroyed_flammable_sound_call": source,
        "mathf_chance_method": mathf_source,
        "mathf_chance_body": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in lookup[key]:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_on_destroyed_power_sound_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_destroyed_big_power_sound_guard": "if(power > 30000f){",
        "on_destroyed_big_power_sound_call": "Sounds.blockExplodeElectricBig.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
        "on_destroyed_power_sound_guard": "}else if(power > 2000f){",
        "on_destroyed_power_sound_call": "Sounds.blockExplodeElectric.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_display_name_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_display_name_method": "public String getDisplayName(){",
        "building_display_name_comment": "//derelict team icon currently doesn't display",
        "building_display_name_derelict": 'block.localizedName + "\\n" + Core.bundle.get("block.derelict")',
        "building_display_name_regular": 'block.localizedName + (team == player.team() || team.emoji.isEmpty() ? "" : " " + team.emoji);',
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_display_icon_flow_items_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_display_icon_method": "public TextureRegion getDisplayIcon(){",
        "building_display_icon_return": "return block.uiIcon;",
        "building_flow_items_comment": "/** @return the item module to use for flow rate calculations */",
        "building_flow_items_method": "public ItemModule flowItems(){",
        "building_flow_items_return": "return items;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_display_ui_gates_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_display_method": "public void display(Table table){",
        "building_display_header_comment": "//display the block stuff",
        "building_display_icon_line": "t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);",
        "building_display_name_line": "t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);",
        "building_display_same_team_comment": "//only display everything else if the team is the same",
        "building_display_same_team_guard": "if(team == player.team()){",
        "building_display_bars_call": "displayBars(bars);",
        "building_display_consumption_call": "table.table(this::displayConsumption).growX();",
        "building_display_flow_gate": "boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;",
        "building_display_last_accessed_guard": "if(net.active() && lastAccessed != null){",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_display_flow_rate_label_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    strings_path = Path(upstream_root).parent / "arc-upstream" / ARC_STRINGS_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    strings_source = strings_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_display_flow_per_second_label": 'String ps = " " + StatUnit.perSecond.localized();',
        "building_display_flow_item_label": 'l.label(() -> flowItems.getFlowRate(item) < 0 ? "..." : Strings.fixed(flowItems.getFlowRate(item), 1) + ps).color(Color.lightGray);',
        "building_display_flow_liquid_label": 'l.label(() -> liquids.getFlowRate(liquid) < 0 ? "..." : Strings.fixed(liquids.getFlowRate(liquid), 1) + ps).color(Color.lightGray);',
        "arc_strings_fixed_method": 'public static String fixed(float d, int decimalPlaces){',
        "arc_strings_fixed_negative": 'boolean negative = d < 0;',
        "arc_strings_fixed_abs": 'd = Math.abs(d);',
        "arc_strings_fixed_scaled": 'dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));',
        "arc_strings_fixed_zero_case": 'if(decimalPlaces == 0){',
        "arc_strings_fixed_zero_prefix": 'result.append("0.");',
    }
    lookup = {
        "building_display_flow_per_second_label": source,
        "building_display_flow_item_label": source,
        "building_display_flow_liquid_label": source,
        "arc_strings_fixed_method": strings_source,
        "arc_strings_fixed_negative": strings_source,
        "arc_strings_fixed_abs": strings_source,
        "arc_strings_fixed_scaled": strings_source,
        "arc_strings_fixed_zero_case": strings_source,
        "arc_strings_fixed_zero_prefix": strings_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in lookup[key]:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "arc_source": ARC_STRINGS_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_cursor_gate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_cursor_method": "public Cursor getCursor(){",
        "building_cursor_comment": "/** Returns whether a hand cursor should be shown over this block. */",
        "building_cursor_hand": "return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_configure_tap_gate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_configure_tap_method": "public boolean onConfigureBuildTapped(Building other){",
        "building_configure_tap_clear_on_double_tap": "if(block.clearOnDoubleTap){",
        "building_configure_tap_same_building": "if(self() == other){",
        "building_configure_tap_deselect": "deselect();",
        "building_configure_tap_configure_null": "configure(null);",
        "building_configure_tap_return_false": "return false;",
        "building_configure_tap_return_true": "return true;",
        "building_configure_tap_return_not_same": "return self() != other;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_configure_position_tap_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_configure_position_tap_comment": "* Called when a position is tapped while this building is selected.",
        "building_configure_position_tap_return_comment": "* @return whether the tap event is consumed - if true, the player will not start shooting or interact with things under the cursor.",
        "building_configure_position_tap_method": "public boolean onConfigureTapped(float x, float y){",
        "building_configure_position_tap_return_false": "return false;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_configure_closed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_configure_closed_comment": "* Called when this block's config menu is closed.",
        "building_configure_closed_method": "public void onConfigureClosed(){}",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_should_show_configure_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_should_show_configure_comment": "/** Returns whether this config menu should show when the specified player taps it. */",
        "building_should_show_configure_method": "public boolean shouldShowConfigure(Player player){",
        "building_should_show_configure_return_true": "return true;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_should_hide_configure_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_should_hide_configure_comment": "/** Whether this configuration should be hidden now. Called every frame the config is open. */",
        "building_should_hide_configure_method": "public boolean shouldHideConfigure(Player player){",
        "building_should_hide_configure_return_false": "return false;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_draw_configure_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_draw_configure_method": "public void drawConfigure(){",
        "building_draw_configure_color": "Draw.color(Pal.accent);",
        "building_draw_configure_stroke": "Lines.stroke(1f);",
        "building_draw_configure_square": "Lines.square(x, y, block.size * tilesize / 2f + 1f);",
        "building_draw_configure_reset": "Draw.reset();",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_check_solid_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_check_solid_method": "public boolean checkSolid(){",
        "building_check_solid_return_false": "return false;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_handle_damage_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_handle_damage_method": "public float handleDamage(float amount){",
        "building_handle_damage_return_amount": "return amount;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_absorb_lasers_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_absorb_lasers_method": "public boolean absorbLasers(){",
        "building_absorb_lasers_return_block_value": "return block.absorbLasers;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }
def verify_building_is_insulated_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_is_insulated_method": "public boolean isInsulated(){",
        "building_is_insulated_return_block_value": "return block.insulated;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_collide_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_collide_method": "public boolean collide(Bullet other){",
        "building_collide_return_true": "return true;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_collision_damage_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_collision_method": "public boolean collision(Bullet other){",
        "building_collision_was_dead": "boolean wasDead = health <= 0;",
        "building_collision_type": "BulletType t = other.type;",
        "building_collision_building_damage": "float damage = other.type.buildingDamage(other);",
        "building_collision_pierce_gate": "if(!t.pierceArmor){",
        "building_collision_apply_armor": "damage = Damage.applyArmor(damage, block.armor * t.armorMultiplier * t.blockArmorMultiplier);",
        "building_collision_damage_call": "damage(other, other.team, damage);",
        "building_collision_destroy_event_gate": "if(health <= 0 && !wasDead){",
        "building_collision_destroy_event": "Events.fire(new BuildingBulletDestroyEvent(self(), other));",
        "building_collision_return_true": "return true;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_damage_delegates_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_damage_team_comment": "/** Used to handle damage from splash damage for certain types of blocks. */",
        "building_damage_team_method": "public void damage(@Nullable Team source, float damage){",
        "building_damage_team_delegate": "damage(damage);",
        "building_damage_bullet_comment": "/** Handles splash damage with a bullet source. */",
        "building_damage_bullet_method": "public void damage(Bullet bullet, Team source, float damage){",
        "building_damage_bullet_delegate": "damage(source, damage);",
        "building_damage_bullet_event": "Events.fire(bulletDamageEvent.set(self(), bullet));",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_change_team_delegate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_change_team_comment": "/** Changes this building's team in a safe manner. */",
        "building_change_team_delegate_method": "public void changeTeam(Team next){",
        "building_change_team_delegate_call": "changeTeam(next, true);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": checked,
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
