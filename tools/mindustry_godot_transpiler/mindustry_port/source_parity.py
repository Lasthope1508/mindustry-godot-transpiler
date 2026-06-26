import json
import re
from pathlib import Path
from typing import Any


DUO_SOURCE = "core/src/mindustry/content/Blocks.java"
MEND_PROJECTOR_SOURCE = "core/src/mindustry/world/blocks/defense/MendProjector.java"
OVERDRIVE_PROJECTOR_SOURCE = "core/src/mindustry/world/blocks/defense/OverdriveProjector.java"
BUILDING_COMP_SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
UNIT_COMP_SOURCE = "core/src/mindustry/entities/comp/UnitComp.java"
PAYLOAD_COMP_SOURCE = "core/src/mindustry/entities/comp/PayloadComp.java"
UNIT_TYPES_CONTENT_SOURCE = "core/src/mindustry/content/UnitTypes.java"
TEAM_SOURCE = "core/src/mindustry/game/Team.java"
TEAMS_SOURCE = "core/src/mindustry/game/Teams.java"
RULES_SOURCE = "core/src/mindustry/game/Rules.java"
UNITS_SOURCE = "core/src/mindustry/entities/Units.java"
EFFECT_SOURCE = "core/src/mindustry/entities/Effect.java"
FX_SOURCE = "core/src/mindustry/content/Fx.java"
EVENT_TYPE_SOURCE = "core/src/mindustry/game/EventType.java"
CONVEYOR_SOURCE = "core/src/mindustry/world/blocks/distribution/Conveyor.java"
DRILL_SOURCE = "core/src/mindustry/world/blocks/production/Drill.java"
BUILDING_COMP_SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
HEALTH_COMP_SOURCE = "core/src/mindustry/entities/comp/HealthComp.java"
BLOCK_SOURCE = "core/src/mindustry/world/Block.java"
CORE_BLOCK_SOURCE = "core/src/mindustry/world/blocks/storage/CoreBlock.java"
ITEM_MODULE_SOURCE = "core/src/mindustry/world/modules/ItemModule.java"
WORLD_SOURCE = "core/src/mindustry/core/World.java"
FLOOR_SOURCE = "core/src/mindustry/world/blocks/environment/Floor.java"
UNIT_TYPE_SOURCE = "core/src/mindustry/type/UnitType.java"
UNIT_CONTROLLER_SOURCE = "core/src/mindustry/entities/units/UnitController.java"
AI_CONTROLLER_SOURCE = "core/src/mindustry/entities/units/AIController.java"
COMMAND_AI_SOURCE = "core/src/mindustry/ai/types/CommandAI.java"
LOGIC_AI_SOURCE = "core/src/mindustry/ai/types/LogicAI.java"
TRAIL_SOURCE = "core/src/mindustry/graphics/Trail.java"
ARC_MATHF_SOURCE = "arc-core/src/arc/math/Mathf.java"
ARC_ANGLES_SOURCE = "arc-core/src/arc/math/Angles.java"
ARC_POSITION_SOURCE = "arc-core/src/arc/math/geom/Position.java"
ARC_VEC2_SOURCE = "arc-core/src/arc/math/geom/Vec2.java"
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

def verify_building_change_team_initial_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_change_team_method": "public void changeTeam(Team next, boolean updatePower){",
        "building_change_team_same_team_return": "if(this.team == next) return;",
        "building_change_team_force_team": "if(block.forceTeam != null) team = block.forceTeam;",
        "building_change_team_last_snapshot": "Team last = this.team;",
        "building_change_team_last_next_return": "if(last == next) return;",
        "building_change_team_was_valid": "boolean was = isValid();",
        "building_change_team_remove_index": "if(was) indexer.removeIndex(tile);",
        "building_change_team_assign_next": "this.team = next;",
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

def verify_building_change_team_power_proximity_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_change_team_power_guard": "if(power != null && updatePower){",
        "building_change_team_old_graph": "var oldGraph = power.graph;",
        "building_change_team_proximity_loop": "for(var other : proximity){",
        "building_change_team_proximity_reflow_guard": "if(other != null && other.team != team && other.power != null && other.power.graph == oldGraph){",
        "building_change_team_proximity_reflow": "new PowerGraph().reflow(other);",
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

def verify_building_change_team_power_links_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_change_team_links_loop": "for(int i = 0; i < power.links.size; i++){",
        "building_change_team_world_build": "var other = world.build(power.links.items[i]);",
        "building_change_team_links_comment": "//only reflow links that were connected to the old power graph; ones that have a new one were already covered.",
        "building_change_team_links_guard": "if(other != null && other.team != team && other.power != null && other.power.graph == oldGraph){",
        "building_change_team_remove_link": "power.links.removeIndex(i);",
        "building_change_team_remove_other_link": "other.power.links.removeValue(pos());",
        "building_change_team_reflow_other": "new PowerGraph().reflow(other);",
        "building_change_team_decrement_index": "i --;",
        "building_change_team_reflow_self": "new PowerGraph().reflow(self());",
        "building_change_team_update_power_graph": "updatePowerGraph();",
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

def verify_building_change_team_final_state_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_change_team_was_guard": "if(was){",
        "building_change_team_add_index": "indexer.addIndex(tile);",
        "building_change_team_event": "Events.fire(teamChangeEvent.set(last, self()));",
        "building_change_team_check_allow_update": "checkAllowUpdate();",
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

def verify_building_can_pickup_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "building_can_pickup_signature": "public boolean canPickup(){",
        "building_can_pickup_block_field": "return block.canPickup;",
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

def verify_building_picked_up_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "picked_up_comment": "Called right before this building is picked up.",
        "picked_up_method": "public void pickedUp(){",
        "picked_up_empty_body": "public void pickedUp(){\n\n    }",
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

def verify_building_after_picked_up_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "after_picked_up_comment": "Called right after this building is picked up.",
        "after_picked_up_signature": "public void afterPickedUp(){",
        "after_picked_up_power_guard": "if(power != null){",
        "after_picked_up_new_graph": "power.graph = new PowerGraph();",
        "after_picked_up_clear_links": "power.links.clear();",
        "after_picked_up_status_reset": "power.status = 0f;",
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

def verify_building_remove_from_proximity_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "remove_from_proximity_signature": "public void removeFromProximity(){",
        "remove_from_proximity_on_removed": "onProximityRemoved();",
        "remove_from_proximity_tmp_clear": "tmpTiles.clear();",
        "remove_from_proximity_edges": "Point2[] nearby = Edges.getEdges(block.size);",
        "remove_from_proximity_comment": "//remove this tile from all nearby tile's proximities",
        "remove_from_proximity_null_guard": "if(other != null){",
        "remove_from_proximity_tmp_add": "tmpTiles.add(other);",
        "remove_from_proximity_remove": "other.proximity.remove(self(), true);",
        "remove_from_proximity_update": "other.onProximityUpdate();",
        "remove_from_proximity_clear": "proximity.clear();",
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

def verify_building_update_proximity_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_proximity_signature": "public void updateProximity(){",
        "update_proximity_tmp_clear": "tmpTiles.clear();",
        "update_proximity_clear": "proximity.clear();",
        "update_proximity_edges": "Point2[] nearby = Edges.getEdges(block.size);",
        "update_proximity_world_build": "Building other = world.build(tile.x + point.x, tile.y + point.y);",
        "update_proximity_team_guard": "if(other == null || other.team != team) continue;",
        "update_proximity_add_unique": "other.proximity.addUnique(self());",
        "update_proximity_tmp_add": "tmpTiles.add(other);",
        "update_proximity_dedup_comment": "//using a set to prevent duplicates",
        "update_proximity_self_add": "proximity.add(tile);",
        "update_proximity_added": "onProximityAdded();",
        "update_proximity_self_update": "onProximityUpdate();",
        "update_proximity_other_update": "other.onProximityUpdate();",
        "update_proximity_recache": "if(!headless && block.drawCached) recache();",
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

def verify_building_on_nearby_build_added_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "on_nearby_build_added_empty": "public void onNearbyBuildAdded(Building other){}",
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

def verify_building_consume_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "consume_signature": "public void consume(){",
        "consume_loop": "for(Consume cons : block.consumers){",
        "consume_trigger": "cons.trigger(self());",
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

def verify_building_can_consume_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "can_consume_signature": "public boolean canConsume(){",
        "can_consume_return": "return potentialEfficiency > 0;",
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

def verify_building_efficiency_multiplier_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_efficiency_multiplier_signature": "public void updateEfficiencyMultiplier(){",
        "update_efficiency_multiplier_scale": "float scale = efficiencyScale();",
        "update_efficiency_multiplier_efficiency": "efficiency *= scale;",
        "update_efficiency_multiplier_optional": "optionalEfficiency *= scale;",
        "efficiency_scale_signature": "public float efficiencyScale(){",
        "efficiency_scale_return": "return 1f;",
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

def verify_building_update_consumption_initial_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_consumption_signature": "public void updateConsumption(){",
        "update_consumption_initial_comment": "//everything is valid when cheating",
        "update_consumption_initial_guard": "if(!block.hasConsumers || cheating()){",
        "update_consumption_initial_potential": "potentialEfficiency = enabled && productionValid() ? 1f : 0f;",
        "update_consumption_initial_efficiency": "efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;",
        "update_consumption_initial_power": "shouldConsumePower = true;",
        "update_consumption_initial_multiplier": "updateEfficiencyMultiplier();",
        "update_consumption_initial_return": "return;",
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

def verify_building_update_consumption_disabled_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_consumption_disabled_comment": "//disabled -> nothing works",
        "update_consumption_disabled_guard": "if(!enabled){",
        "update_consumption_disabled_efficiencies": "potentialEfficiency = efficiency = optionalEfficiency = 0f;",
        "update_consumption_disabled_power": "shouldConsumePower = false;",
        "update_consumption_disabled_return": "return;",
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

def verify_building_update_consumption_setup_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_consumption_setup_update": "boolean update = shouldConsume() && productionValid();",
        "update_consumption_setup_min_efficiency": "float minEfficiency = 1f;",
        "update_consumption_setup_comment": "//assume efficiency is 1 for the calculations below",
        "update_consumption_setup_efficiencies": "efficiency = optionalEfficiency = 1f;",
        "update_consumption_setup_power": "shouldConsumePower = true;",
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

def verify_building_update_consumption_non_optional_pass_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_consumption_non_optional_comment": "//first pass: get the minimum efficiency of any consumer",
        "update_consumption_non_optional_loop": "for(var cons : block.nonOptionalConsumers){",
        "update_consumption_non_optional_result": "float result = cons.efficiency(self());",
        "update_consumption_non_optional_power_gate": "if(cons != block.consPower && result <= 0.0000001f){",
        "update_consumption_non_optional_power_state": "shouldConsumePower = false;",
        "update_consumption_non_optional_min": "minEfficiency = Math.min(minEfficiency, result);",
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

def verify_building_update_consumption_optional_pass_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_consumption_optional_comment": "//same for optionals",
        "update_consumption_optional_loop": "for(var cons : block.optionalConsumers){",
        "update_consumption_optional_min": "optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));",
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

def verify_building_update_consumption_efficiency_assignment_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_consumption_efficiency_comment": "//efficiency is now this minimum value",
        "update_consumption_efficiency_assign": "efficiency = minEfficiency;",
        "update_consumption_efficiency_optional_min": "optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);",
        "update_consumption_potential_comment": "//assign \"potential\"",
        "update_consumption_potential_assign": "potentialEfficiency = efficiency;",
        "update_consumption_no_update_comment": "//no updating means zero efficiency",
        "update_consumption_no_update_guard": "if(!update){",
        "update_consumption_no_update_zero": "efficiency = optionalEfficiency = 0f;",
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

def verify_building_update_consumption_second_pass_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_consumption_multiplier_call": "updateEfficiencyMultiplier();",
        "update_consumption_second_pass_comment": "//second pass: update every consumer based on efficiency",
        "update_consumption_second_pass_guard": "if(update && efficiency > 0){",
        "update_consumption_second_pass_loop": "for(var cons : block.updateConsumers){",
        "update_consumption_second_pass_update": "cons.update(self());",
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

def verify_building_ambient_volume_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "ambient_volume_method": "public float ambientVolume(){",
        "ambient_volume_return": "return efficiency;",
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

def verify_building_config_default_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "config_comment": "/** Tile configuration. Defaults to null. Used for block rebuilding. */",
        "config_nullable": "@Nullable",
        "config_method": "public Object config(){",
        "config_return": "return null;",
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

def verify_building_is_valid_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "is_valid_method": "public boolean isValid(){",
        "is_valid_return": "return tile.build == self() && !dead();",
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

def verify_building_heal_health_changed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "heal_priority": "@MethodPriority(100)",
        "heal_method": "public void heal(){",
        "heal_amount_method": "public void heal(float amount){",
        "health_changed_call": "healthChanged();",
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

def verify_building_hit_size_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "hit_size_method": "public float hitSize(){",
        "hit_size_return": "return tile.block().size * tilesize;",
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

def verify_building_kill_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "kill_replace": "@Replace",
        "kill_method": "public void kill(){",
        "kill_call": "Call.buildDestroyed(self());",
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

def verify_building_damage_dead_guard_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "damage_replace": "@Replace",
        "damage_method": "public void damage(float damage){",
        "damage_dead_guard": "if(dead()) return;",
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

def verify_building_damage_block_health_scale_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "damage_block_health": "float dm = state.rules.blockHealth(team);",
        "damage_last_damage_time": "lastDamageTime = Time.time;",
        "damage_zero_guard": "if(Mathf.zero(dm)){",
        "damage_zero_assignment": "damage = health + 1;",
        "damage_scale_assignment": "damage /= dm;",
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

def verify_building_damage_handle_damage_gate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "damage_client_todo": "//TODO handle this better on the client.",
        "damage_non_client_guard": "if(!net.client()){",
        "damage_handle_damage": "health -= handleDamage(damage);",
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

def verify_building_damage_health_changed_call_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "damage_health_changed_call": "healthChanged();",
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

def verify_building_health_changed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "health_changed_method": "public void healthChanged(){",
        "health_changed_server_comment": "//server-side, health updates are batched.",
        "health_changed_server_guard": "if(net.server()){",
        "health_changed_server_update": "netServer.buildHealthUpdate(self());",
        "health_changed_indexer_notify": "indexer.notifyHealthChanged(self());",
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

def verify_building_sense_position_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    world_source_path = Path(upstream_root) / WORLD_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    world_source = world_source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sense_method": "public double sense(LAccess sensor){",
        "sense_switch": "return switch(sensor){",
        "sense_x": "case x -> World.conv(x);",
        "sense_y": "case y -> World.conv(y);",
        "world_conv_method": "public static float conv(float coord){",
        "world_conv_return": "return coord / tilesize;",
    }
    missing = []
    for key, snippet in checked.items():
        haystack = world_source if key.startswith("world_") else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "world_source": WORLD_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_sense_health_process_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sense_health": "case health -> health;",
        "sense_max_health": "case maxHealth -> maxHealth;",
        "sense_efficiency": "case efficiency -> efficiency;",
        "sense_timescale": "case timescale -> timeScale;",
        "sense_range": "case range -> this instanceof Ranged r ? r.range() / tilesize : 0;",
        "sense_rotation": "case rotation -> rotation;",
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

def verify_building_sense_totals_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sense_total_items": "case totalItems -> items == null ? 0 : items.total();",
        "sense_total_liquids_comment": "//totalLiquids is inherently bad design, but unfortunately it is useful for conduits/tanks",
        "sense_total_liquids": "case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();",
        "sense_total_power": "case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);",
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

def verify_building_sense_capacity_power_net_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sense_item_capacity": "case itemCapacity -> block.hasItems ? block.itemCapacity : 0;",
        "sense_liquid_capacity": "case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;",
        "sense_power_capacity": "case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;",
        "sense_power_net_in": "case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;",
        "sense_power_net_out": "case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;",
        "sense_power_net_stored": "case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();",
        "sense_power_net_capacity": "case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();",
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

def verify_building_sense_enabled_controlled_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sense_enabled": "case enabled -> enabled ? 1 : 0;",
        "sense_controlled": "case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;",
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

def verify_building_sense_payload_size_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sense_payload_count": "case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);",
        "sense_size": "case size -> block.size;",
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

def verify_building_sense_object_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sense_object_method": "public Object senseObject(LAccess sensor){",
        "sense_object_type": "case type -> block;",
        "sense_object_first_item": "case firstItem -> items == null ? null : items.first();",
        "sense_object_config": "case config -> block.configSenseable() ? config() : null;",
        "sense_object_payload_type": "case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;",
        "sense_object_default": "default -> noSensed;",
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

def verify_building_sense_content_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sense_content_method": "public double sense(Content content){",
        "sense_content_item": "if(content instanceof Item i && items != null) return items.get(i);",
        "sense_content_liquid": "if(content instanceof Liquid l && liquids != null) return liquids.get(l);",
        "sense_content_payloads_guard": "if(getPayloads() != null){",
        "sense_content_unit": "if(content instanceof UnitType u) return getPayloads().get(u);",
        "sense_content_block": "if(content instanceof Block b) return getPayloads().get(b);",
        "sense_content_invalid": "return Float.NaN; //invalid sense",
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

def verify_building_control_enabled_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "control_enabled_method": "public void control(LAccess type, double p1, double p2, double p3, double p4){",
        "control_enabled_guard": "if(type == LAccess.enabled){",
        "control_enabled_assignment": "enabled = !Mathf.zero((float)p1);",
        "mathf_float_rounding_error": "public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits",
        "mathf_zero_float_method": "public static boolean zero(float value){",
        "mathf_zero_float_return": "return Math.abs(value) <= FLOAT_ROUNDING_ERROR;",
    }
    building_keys = {
        "control_enabled_method",
        "control_enabled_guard",
        "control_enabled_assignment",
    }
    missing = []
    for key, snippet in checked.items():
        haystack = source if key in building_keys else mathf_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": BUILDING_COMP_SOURCE,
        "mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_building_control_config_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "control_config_method": "public void control(LAccess type, Object p1, double p2, double p3, double p4){",
        "control_config_lag_comment": "//don't execute configure instructions that copy logic building configures; this can cause extreme lag",
        "control_config_guard": "if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){",
        "control_config_new_comment": "//change config only if it's new",
        "control_config_call": "configured(null, p1);",
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

def verify_building_set_prop_health_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "set_prop_double_method": "public void setProp(LAccess prop, double value){",
        "set_prop_switch": "switch(prop){",
        "set_prop_health_case": "case health -> {",
        "set_prop_health_clamp": "health = (float)Mathf.clamp(value, 0, maxHealth);",
        "set_prop_health_destroy_guard": "if(health <= 0f && !dead()){",
        "set_prop_health_destroy_call": "Call.buildDestroyed(self());",
        "set_prop_health_else": "}else{",
        "set_prop_health_changed": "healthChanged();",
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

def verify_building_set_prop_team_double_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "set_prop_double_method": "public void setProp(LAccess prop, double value){",
        "set_prop_team_case": "case team -> {",
        "set_prop_team_get": "Team team = Team.get((int)value);",
        "set_prop_team_guard": "if(this.team != team){",
        "set_prop_team_change": "changeTeam(team);",
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

def verify_building_set_prop_total_power_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "set_prop_double_method": "public void setProp(LAccess prop, double value){",
        "set_prop_total_power_case": "case totalPower -> {",
        "set_prop_total_power_guard": "if(power != null && block.consPower != null && block.consPower.buffered){",
        "set_prop_total_power_status": "power.status = Mathf.clamp((float)(value / block.consPower.capacity));",
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

def verify_building_set_prop_team_object_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "set_prop_object_method": "public void setProp(LAccess prop, Object value){",
        "set_prop_object_switch": "switch(prop){",
        "set_prop_object_team_case": "case team -> {",
        "set_prop_object_team_guard": "if(value instanceof Team team && this.team != team){",
        "set_prop_object_team_change": "changeTeam(team);",
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

def verify_building_set_prop_item_content_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "set_prop_content_method": "public void setProp(UnlockableContent content, double value){",
        "set_prop_item_guard": "if(content instanceof Item item && items != null){",
        "set_prop_item_amount": "int amount = (int)value;",
        "set_prop_item_diff_guard": "if(items.get(item) != amount){",
        "set_prop_item_increase_guard": "if(items.get(item) < amount){",
        "set_prop_item_handle_stack": "handleStack(item, acceptStack(item, amount - items.get(item), null), null);",
        "set_prop_item_decrease_guard": "}else if(amount >= 0){",
        "set_prop_item_remove_stack": "removeStack(item, items.get(item) - amount);",
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

def verify_building_set_prop_liquid_content_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "set_prop_content_method": "public void setProp(UnlockableContent content, double value){",
        "set_prop_liquid_guard": "}else if(content instanceof Liquid liquid && liquids != null){",
        "set_prop_liquid_amount": "float amount = Mathf.clamp((float)value, 0f, block.liquidCapacity);",
        "set_prop_liquid_decrease_comment": "//decreasing amount is always allowed",
        "set_prop_liquid_gate": "if(amount < liquids.get(liquid) || (acceptLiquid(self(), liquid) && (liquids.current() == liquid || liquids.currentAmount() <= 0.1f || block.consumesLiquid(liquid)))){",
        "set_prop_liquid_set": "liquids.set(liquid, amount);",
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

def verify_building_in_fog_initial_gate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "in_fog_replace": "@Replace",
        "in_fog_override": "@Override",
        "in_fog_method": "public boolean inFogTo(Team viewer){",
        "in_fog_initial_gate": "if(team == viewer || !state.rules.fog) return false;",
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

def verify_building_in_fog_discovery_gate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "in_fog_method": "public boolean inFogTo(Team viewer){",
        "in_fog_grid_snapshot": "int size = block.size, of = block.sizeOffset, tx = tile.x, ty = tile.y;",
        "in_fog_discovered_gate": "if(!isDiscovered(viewer)) return true;",
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

def verify_building_in_fog_visibility_loop_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "in_fog_x_loop": "for(int x = 0; x < size; x++){",
        "in_fog_y_loop": "for(int y = 0; y < size; y++){",
        "in_fog_visible_check": "if(fogControl.isVisibleTile(viewer, tx + x + of, ty + y + of)){",
        "in_fog_visible_return": "return false;",
        "in_fog_final_return": "return true;",
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

def verify_building_killed_initial_side_effects_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "killed_method": "public void killed(){",
        "killed_dead_assignment": "dead = true;",
        "killed_destroy_event": "Events.fire(new BlockDestroyEvent(tile));",
        "killed_on_destroyed": "onDestroyed();",
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

def verify_building_killed_removal_side_effects_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "killed_tile_gate": "if(tile != emptyTile){",
        "killed_tile_remove": "tile.remove();",
        "killed_remove": "remove();",
        "killed_after_destroyed": "afterDestroyed();",
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

def verify_building_check_allow_update_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "check_allow_update_method": "public void checkAllowUpdate(){",
        "check_allow_update_gate": "if(!allowUpdate()){",
        "check_allow_update_disable": "enabled = false;",
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

def verify_building_update_timescale_decay_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_final_replace": "@Replace",
        "update_method": "public void update(){",
        "update_timescale_decay_gate": "if((timeScaleDuration -= Time.delta) <= 0f){",
        "update_timescale_reset": "timeScale = 1f;",
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

def verify_building_update_ambient_sound_gate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_ambient_sound_comment": "//TODO separate multithreaded system for sound? AudioSource, etc",
        "update_ambient_sound_gate": "if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){",
        "update_ambient_sound_loop": "control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());",
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

def verify_building_update_consumption_call_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_consumption_call": "updateConsumption();",
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

def verify_building_update_tile_gate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_tile_gate": "if(enabled || !block.noUpdateDisabled){",
        "update_tile_call": "updateTile();",
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

def verify_building_update_fog_visibility_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_fog_visibility_method": "public void updateFogVisibility(){",
        "update_fog_visibility_gate": "if(!wasVisible && !inFogTo(player.team())){",
        "update_fog_visibility_flag": "visibleFlags |= (1L << player.team().id);",
        "update_fog_visibility_was_visible": "wasVisible = true;",
        "update_fog_visibility_shadow": "renderer.blocks.updateShadow(self());",
        "update_fog_visibility_minimap": "renderer.minimap.update(tile);",
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

def verify_building_hitbox_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "hitbox_override": "@Override",
        "hitbox_method": "public void hitbox(Rect out){",
        "hitbox_set_centered": "out.setCentered(x, y, block.size * tilesize, block.size * tilesize);",
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

def verify_building_to_string_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "to_string_override": "@Override",
        "to_string_replace": "@Replace",
        "to_string_method": "public String toString(){",
        "to_string_return": 'return "Building#" + id() + "[" + tileX() + "," + tileY() + "]:" + block;',
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

def verify_unit_grounded_flying_target_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "check_target_method": "public boolean checkTarget(boolean targetAir, boolean targetGround){",
        "check_target_return": "return (isGrounded() && targetGround) || (isFlying() && targetAir);",
        "is_grounded_method": "public boolean isGrounded(){",
        "is_grounded_return": "return elevation < 0.001f;",
        "is_flying_method": "public boolean isFlying(){",
        "is_flying_return": "return elevation >= 0.09f;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_can_drown_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "can_drown_method": "public boolean canDrown(){",
        "can_drown_return": "return isGrounded() && type.canDrown;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_drown_floor_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "drown_floor_method": "public @Nullable Floor drownFloor(){",
        "drown_floor_return": "return floorOn();",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_wobble_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "wobble_method": "public void wobble(){",
        "wobble_x": "x += Mathf.sin(Time.time + (id % 10) * 12, 25f, 0.05f) * Time.delta * elevation;",
        "wobble_y": "y += Mathf.cos(Time.time + (id % 10) * 12, 25f, 0.05f) * Time.delta * elevation;",
        "sin_bits": "private static final int sinBits = 14;",
        "sin_mask": "private static final int sinMask = ~(-1 << sinBits);",
        "sin_table_fill": "sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);",
        "sin_lookup": "return sinTable[(int)(radians * radToIndex) & sinMask];",
        "cos_lookup": "return sinTable[(int)((radians + PI / 2) * radToIndex) & sinMask];",
        "sin_scaled": "return sin(radians / scl) * mag;",
        "cos_scaled": "return cos(radians / scl) * mag;",
    }
    unit_keys = {"wobble_method", "wobble_x", "wobble_y"}
    missing = []
    for key, snippet in checked.items():
        haystack = source if key in unit_keys else mathf_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_move_at_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    vec2_path = Path(arc_root) / ARC_VEC2_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "move_at_method": "public void moveAt(Vec2 vector, float acceleration){",
        "move_at_target": "Vec2 t = tmp1.set(vector); //target vector",
        "move_at_delta": "tmp2.set(t).sub(vel).limit(acceleration * vector.len() * Time.delta); //delta vector",
        "move_at_add": "vel.add(tmp2);",
        "vec2_len": "return (float)Math.sqrt(x * x + y * y);",
        "vec2_set": "public Vec2 set(Vec2 v){",
        "vec2_sub": "public Vec2 sub(Vec2 v){",
        "vec2_add": "public Vec2 add(Vec2 v){",
        "vec2_limit": "public Vec2 limit(float limit){",
        "vec2_limit2": "if(len2 > limit2){",
        "vec2_limit2_scale": "return scl((float)Math.sqrt(limit2 / len2));",
    }
    unit_keys = {"move_at_method", "move_at_target", "move_at_delta", "move_at_add"}
    missing = []
    for key, snippet in checked.items():
        haystack = source if key in unit_keys else vec2_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_move_at_default_accel_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "move_at_default_method": "public void moveAt(Vec2 vector){",
        "move_at_default_call": "moveAt(vector, type.accel);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_approach_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    vec2_path = Path(arc_root) / ARC_VEC2_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_approach_method": "public void approach(Vec2 vector){",
        "unit_approach_call": "vel.approachDelta(vector, type.accel * speed());",
        "vec2_approach_delta": "return approach(target, Time.delta * alpha);",
        "vec2_approach_method": "public Vec2 approach(Vec2 target, float alpha){",
        "vec2_dx_dy": "float dx = x - target.x, dy = y - target.y;",
        "vec2_alpha2": "float alpha2 = alpha*alpha;",
        "vec2_len2": "float len2 = Mathf.len2(dx, dy);",
        "vec2_scl": "float scl = Mathf.sqrt(alpha2 / len2);",
        "vec2_sub": "return sub(dx, dy);",
        "vec2_set": "return set(target);",
    }
    unit_keys = {"unit_approach_method", "unit_approach_call"}
    missing = []
    for key, snippet in checked.items():
        haystack = source if key in unit_keys else vec2_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_rotate_move_motion_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    vec2_path = Path(arc_root) / ARC_VEC2_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "rotate_move_method": "public void rotateMove(Vec2 vec){",
        "rotate_move_motion": "moveAt(Tmp.v2.trns(rotation, vec.len()));",
        "vec2_trns": "return set(amount, 0).rotate(angle);",
        "vec2_len": "return (float)Math.sqrt(x * x + y * y);",
        "vec2_rotate": "return rotateRad(degrees * Mathf.degreesToRadians);",
        "vec2_rotate_rad": "public Vec2 rotateRad(float radians){",
        "vec2_rotate_new_x": "float newX = this.x * cos - this.y * sin;",
        "vec2_rotate_new_y": "float newY = this.x * sin + this.y * cos;",
    }
    unit_keys = {"rotate_move_method", "rotate_move_motion"}
    missing = []
    for key, snippet in checked.items():
        haystack = source if key in unit_keys else vec2_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_rotate_move_rotation_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    vec2_path = Path(arc_root) / ARC_VEC2_SOURCE
    angles_path = Path(arc_root) / ARC_ANGLES_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    angles_source = angles_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "rotate_move_gate": "if(!vec.isZero()){",
        "rotate_move_rotation": "rotation = Angles.moveToward(rotation, vec.angle(), type.rotateSpeed * Time.delta * speedMultiplier);",
        "vec2_is_zero": "return x == 0 && y == 0;",
        "vec2_angle": "float angle = Mathf.atan2(x, y) * Mathf.radiansToDegrees;",
        "vec2_angle_wrap": "if(angle < 0) angle += 360;",
        "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
        "angles_move_snap": "if(Math.abs(angleDist(angle, to)) < speed) return to;",
        "angles_move_branch": "if(angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)){",
        "angles_forward_distance": "return Math.abs(angle1 - angle2);",
        "angles_backward_distance": "return 360 - Math.abs(angle1 - angle2);",
        "mathf_mod_float": "return ((f % n) + n) % n;",
    }
    unit_keys = {"rotate_move_gate", "rotate_move_rotation"}
    vec2_keys = {"vec2_is_zero", "vec2_angle", "vec2_angle_wrap"}
    mathf_keys = {"mathf_mod_float"}
    missing = []
    for key, snippet in checked.items():
        if key in unit_keys:
            haystack = source
        elif key in vec2_keys:
            haystack = vec2_source
        elif key in mathf_keys:
            haystack = mathf_source
        else:
            haystack = angles_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "arc_angles_source": ARC_ANGLES_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_aim_look_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "aim_look_position_method": "public void aimLook(Position pos){",
        "aim_look_position_aim": "aim(pos);",
        "aim_look_position_look_at": "lookAt(pos);",
        "aim_look_xy_method": "public void aimLook(float x, float y){",
        "aim_look_xy_aim": "aim(x, y);",
        "aim_look_xy_look_at": "lookAt(x, y);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_look_at_angle_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    angles_path = Path(arc_root) / ARC_ANGLES_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    angles_source = angles_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "look_at_angle_method": "public void lookAt(float angle){",
        "look_at_angle_rotation": "rotation = Angles.moveToward(rotation, angle, type.rotateSpeed * Time.delta * speedMultiplier());",
        "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
        "angles_move_snap": "if(Math.abs(angleDist(angle, to)) < speed) return to;",
        "angles_move_branch": "if(angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)){",
        "mathf_mod_float": "return ((f % n) + n) % n;",
    }
    unit_keys = {"look_at_angle_method", "look_at_angle_rotation"}
    mathf_keys = {"mathf_mod_float"}
    missing = []
    for key, snippet in checked.items():
        if key in unit_keys:
            haystack = source
        elif key in mathf_keys:
            haystack = mathf_source
        else:
            haystack = angles_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_angles_source": ARC_ANGLES_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_look_at_position_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    position_path = Path(arc_root) / ARC_POSITION_SOURCE
    angles_path = Path(arc_root) / ARC_ANGLES_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    position_source = position_path.read_text(encoding="utf-8", errors="replace")
    angles_source = angles_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "look_at_position_method": "public void lookAt(Position pos){",
        "look_at_position_call": "lookAt(angleTo(pos));",
        "position_angle_to_method": "default float angleTo(Position other){",
        "position_angle_to_return": "return Angles.angle(getX(), getY(), other.getX(), other.getY());",
        "angles_angle_method": "public static float angle(float x, float y, float x2, float y2){",
        "angles_angle_delta": "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;",
        "angles_angle_wrap": "if(ang < 0) ang += 360f;",
    }
    unit_keys = {"look_at_position_method", "look_at_position_call"}
    position_keys = {"position_angle_to_method", "position_angle_to_return"}
    missing = []
    for key, snippet in checked.items():
        if key in unit_keys:
            haystack = source
        elif key in position_keys:
            haystack = position_source
        else:
            haystack = angles_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_position_source": ARC_POSITION_SOURCE,
        "arc_angles_source": ARC_ANGLES_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_look_at_xy_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    position_path = Path(arc_root) / ARC_POSITION_SOURCE
    angles_path = Path(arc_root) / ARC_ANGLES_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    position_source = position_path.read_text(encoding="utf-8", errors="replace")
    angles_source = angles_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "look_at_xy_method": "public void lookAt(float x, float y){",
        "look_at_xy_call": "lookAt(angleTo(x, y));",
        "position_angle_to_xy_method": "default float angleTo(float x, float y){",
        "position_angle_to_xy_return": "return Angles.angle(getX(), getY(), x, y);",
        "angles_angle_method": "public static float angle(float x, float y, float x2, float y2){",
        "angles_angle_delta": "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;",
        "angles_angle_wrap": "if(ang < 0) ang += 360f;",
    }
    unit_keys = {"look_at_xy_method", "look_at_xy_call"}
    position_keys = {"position_angle_to_xy_method", "position_angle_to_xy_return"}
    missing = []
    for key, snippet in checked.items():
        if key in unit_keys:
            haystack = source
        elif key in position_keys:
            haystack = position_source
        else:
            haystack = angles_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_position_source": ARC_POSITION_SOURCE,
        "arc_angles_source": ARC_ANGLES_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_controller_predicates_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    ai_controller_path = Path(upstream_root) / AI_CONTROLLER_SOURCE
    command_ai_path = Path(upstream_root) / COMMAND_AI_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    ai_controller_source = ai_controller_path.read_text(encoding="utf-8", errors="replace")
    command_ai_source = command_ai_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "is_ai_method": "public boolean isAI(){",
        "is_ai_return": "return controller instanceof AIController;",
        "allow_command_method": "public boolean allowCommand(){",
        "allow_command_return": "return controller instanceof CommandAI;",
        "is_commandable_method": "public boolean isCommandable(){",
        "is_commandable_return": "return controller instanceof CommandAI;",
        "ai_controller_class": "public class AIController implements UnitController{",
        "command_ai_class": "public class CommandAI extends AIController{",
    }
    ai_controller_keys = {"ai_controller_class"}
    command_ai_keys = {"command_ai_class"}
    missing = []
    for key, snippet in checked.items():
        if key in ai_controller_keys:
            haystack = ai_controller_source
        elif key in command_ai_keys:
            haystack = command_ai_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "ai_controller_source": AI_CONTROLLER_SOURCE,
        "command_ai_source": COMMAND_AI_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_can_target_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "can_target_method": "public boolean canTarget(Teamc other){",
        "can_target_return": "return other != null && (other instanceof Unit u ? u.checkTarget(type.targetAir, type.targetGround) : (other instanceof Building b && type.targetGround));",
        "check_target_method": "public boolean checkTarget(boolean targetAir, boolean targetGround){",
        "check_target_return": "return (isGrounded() && targetGround) || (isFlying() && targetAir);",
        "unit_type_target_air": "targetAir = true,",
        "unit_type_target_ground": "targetGround = true,",
    }
    unit_type_keys = {"unit_type_target_air", "unit_type_target_ground"}
    missing = []
    for key, snippet in checked.items():
        haystack = unit_type_source if key in unit_type_keys else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_command_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    command_ai_path = Path(upstream_root) / COMMAND_AI_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    command_ai_source = command_ai_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "command_method": "public CommandAI command(){",
        "command_ai_gate": "if(controller instanceof CommandAI ai){",
        "command_return": "return ai;",
        "command_else": "}else{",
        "command_throw": "throw new IllegalArgumentException(\"Unit cannot be commanded - check isCommandable() first.\");",
        "command_ai_class": "public class CommandAI extends AIController{",
    }
    missing = []
    for key, snippet in checked.items():
        haystack = command_ai_source if key == "command_ai_class" else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "command_ai_source": COMMAND_AI_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_is_missile_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_types_path = Path(upstream_root) / UNIT_TYPES_CONTENT_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_types_source = unit_types_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "is_missile_method": "public boolean isMissile(){",
        "is_missile_return": "return this instanceof TimedKillc;",
        "missile_comment": "missile definition, unused here but needed for codegen",
        "missile_entity_def": "public static @EntityDef({Unitc.class, TimedKillc.class}) UnitType missile;",
    }
    unit_types_keys = {"missile_comment", "missile_entity_def"}
    missing = []
    for key, snippet in checked.items():
        haystack = unit_types_source if key in unit_types_keys else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_types_source": UNIT_TYPES_CONTENT_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_count_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    team_path = Path(upstream_root) / TEAM_SOURCE
    teams_path = Path(upstream_root) / TEAMS_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    team_source = team_path.read_text(encoding="utf-8", errors="replace")
    teams_source = teams_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "count_method": "public int count(){",
        "count_return": "return team.data().countType(type);",
        "team_data_method": "public TeamData data(){",
        "team_data_return": "return state.teams.get(this);",
        "team_count_type_method": "public int countType(UnitType type){",
        "team_count_type_return": "return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];",
    }
    team_keys = {"team_data_method", "team_data_return"}
    teams_keys = {"team_count_type_method", "team_count_type_return"}
    missing = []
    for key, snippet in checked.items():
        if key in team_keys:
            haystack = team_source
        elif key in teams_keys:
            haystack = teams_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "team_source": TEAM_SOURCE,
        "teams_source": TEAMS_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_cap_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    units_path = Path(upstream_root) / UNITS_SOURCE
    rules_path = Path(upstream_root) / RULES_SOURCE
    team_path = Path(upstream_root) / TEAM_SOURCE
    teams_path = Path(upstream_root) / TEAMS_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    units_source = units_path.read_text(encoding="utf-8", errors="replace")
    rules_source = rules_path.read_text(encoding="utf-8", errors="replace")
    team_source = team_path.read_text(encoding="utf-8", errors="replace")
    teams_source = teams_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "cap_method": "public int cap(){",
        "cap_return": "return Units.getCap(team);",
        "get_cap_method": "public static int getCap(Team team){",
        "get_cap_wave_comment": "wave team has no cap",
        "get_cap_guard": "if((team == state.rules.waveTeam && !state.rules.pvp) || (state.isCampaign() && team == state.rules.waveTeam) || state.rules.disableUnitCap || team.ignoreUnitCap){",
        "get_cap_max": "return Integer.MAX_VALUE;",
        "get_cap_return": "return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);",
        "rules_unit_cap_variable": "public boolean unitCapVariable = true;",
        "rules_unit_cap": "public int unitCap = 0;",
        "rules_disable_unit_cap": "public boolean disableUnitCap;",
        "team_ignore_unit_cap": "public boolean ignoreUnitCap = false;",
        "team_data_unit_cap": "public int unitCap;",
    }
    units_keys = {"get_cap_method", "get_cap_wave_comment", "get_cap_guard", "get_cap_max", "get_cap_return"}
    rules_keys = {"rules_unit_cap_variable", "rules_unit_cap", "rules_disable_unit_cap"}
    team_keys = {"team_ignore_unit_cap"}
    teams_keys = {"team_data_unit_cap"}
    missing = []
    for key, snippet in checked.items():
        if key in units_keys:
            haystack = units_source
        elif key in rules_keys:
            haystack = rules_source
        elif key in team_keys:
            haystack = team_source
        elif key in teams_keys:
            haystack = teams_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "units_source": UNITS_SOURCE,
        "rules_source": RULES_SOURCE,
        "team_source": TEAM_SOURCE,
        "teams_source": TEAMS_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_set_type_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "set_type_method": "public void setType(UnitType type){",
        "assign_type": "this.type = type;",
        "assign_max_health": "this.maxHealth = type.health;",
        "assign_drag": "this.drag = type.drag;",
        "assign_armor": "this.armor = type.armor;",
        "assign_hit_size": "this.hitSize = type.hitSize;",
        "setup_weapons_guard": "if(mounts().length != type.weapons.size) setupWeapons(type);",
        "abilities_guard": "if(abilities.length != type.abilities.size || (abilities.length > 0 && abilities[0] instanceof EmptyDataAbility)){",
        "abilities_array": "abilities = new Ability[type.abilities.size];",
        "ability_copy": "abilities[i] = type.abilities.get(i).copy();",
        "ability_data_carry": "abilities[i].data = old[i].data;",
        "controller_guard": "if(controller == null) controller(type.createController(self()));",
        "unit_type_health": "health = 200f,",
        "unit_type_drag": "drag = 0.3f,",
        "unit_type_armor": "armor = 0f,",
        "unit_type_hit_size": "hitSize = 6f,",
        "unit_type_abilities": "public Seq<Ability> abilities = new Seq<>();",
        "unit_type_weapons": "public Seq<Weapon> weapons = new Seq<>();",
        "unit_type_create_controller": "public UnitController createController(Unit unit){",
    }
    unit_type_keys = {
        "unit_type_health",
        "unit_type_drag",
        "unit_type_armor",
        "unit_type_hit_size",
        "unit_type_abilities",
        "unit_type_weapons",
        "unit_type_create_controller",
    }
    missing = []
    for key, snippet in checked.items():
        haystack = unit_type_source if key in unit_type_keys else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_player_controllable_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    logic_ai_path = Path(upstream_root) / LOGIC_AI_SOURCE
    block_path = Path(upstream_root) / BLOCK_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    logic_ai_source = logic_ai_path.read_text(encoding="utf-8", errors="replace")
    block_source = block_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "player_controllable_method": "public boolean playerControllable(){",
        "player_controllable_return": "return type.playerControllable && !(controller instanceof LogicAI ai && ai.controller != null && ai.controller.block.privileged);",
        "unit_type_player_controllable": "playerControllable = true,",
        "logic_ai_class": "public class LogicAI extends AIController{",
        "logic_ai_controller": "public @Nullable Building controller;",
        "block_privileged": "public boolean privileged = false;",
    }
    missing = []
    for key, snippet in checked.items():
        if key.startswith("unit_type_"):
            haystack = unit_type_source
        elif key.startswith("logic_ai_"):
            haystack = logic_ai_source
        elif key.startswith("block_"):
            haystack = block_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "logic_ai_source": LOGIC_AI_SOURCE,
        "block_source": BLOCK_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_targetable_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    payload_comp_path = Path(upstream_root) / PAYLOAD_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    payload_comp_source = payload_comp_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_targetable_method": "public boolean targetable(Team targeter){",
        "unit_targetable_return": "return type.targetable(self(), targeter);",
        "type_targetable_method": "public boolean targetable(Unit unit, Team targeter){",
        "type_targetable_return": "return targetable || (vulnerableWithPayloads && unit instanceof Payloadc p && p.hasPayload());",
        "type_targetable_default": "targetable = true,",
        "type_vulnerable_with_payloads_default": "vulnerableWithPayloads = false,",
        "payload_comp_has_payload": "boolean hasPayload(){",
        "payload_comp_has_payload_return": "return payloads.size > 0;",
    }
    missing = []
    for key, snippet in checked.items():
        if key.startswith("type_"):
            haystack = unit_type_source
        elif key.startswith("payload_comp_"):
            haystack = payload_comp_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "payload_comp_source": PAYLOAD_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_killable_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_killable_method": "public boolean killable(){",
        "unit_killable_return": "return type.killable(self());",
        "type_killable_method": "public boolean killable(Unit unit){",
        "type_killable_return": "return killable;",
        "type_killable_default": "killable = true,",
    }
    missing = []
    for key, snippet in checked.items():
        haystack = unit_type_source if key.startswith("type_") else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_hittable_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    payload_comp_path = Path(upstream_root) / PAYLOAD_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    payload_comp_source = payload_comp_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_hittable_method": "public boolean hittable(){",
        "unit_hittable_return": "return type.hittable(self());",
        "type_hittable_method": "public boolean hittable(Unit unit){",
        "type_hittable_return": "return hittable || (vulnerableWithPayloads && unit instanceof Payloadc p && p.hasPayload());",
        "type_hittable_default": "hittable = true,",
        "type_vulnerable_with_payloads_default": "vulnerableWithPayloads = false,",
        "payload_comp_has_payload": "boolean hasPayload(){",
        "payload_comp_has_payload_return": "return payloads.size > 0;",
    }
    missing = []
    for key, snippet in checked.items():
        if key.startswith("type_"):
            haystack = unit_type_source
        elif key.startswith("payload_comp_"):
            haystack = payload_comp_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "payload_comp_source": PAYLOAD_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_after_sync_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_controller_path = Path(upstream_root) / UNIT_CONTROLLER_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_controller_source = unit_controller_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "after_sync_override": "@Override\n    public void afterSync(){",
        "after_sync_comment": "set up type info after reading",
        "after_sync_set_type": "setType(this.type);",
        "after_sync_controller_unit": "controller.unit(self());",
        "unit_controller_unit": "void unit(Unit unit);",
        "unit_controller_unit_getter": "@Nullable Unit unit();",
    }
    unit_controller_keys = {"unit_controller_unit", "unit_controller_unit_getter"}
    missing = []
    for key, snippet in checked.items():
        haystack = unit_controller_source if key in unit_controller_keys else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_controller_source": UNIT_CONTROLLER_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_after_read_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    ai_controller_path = Path(upstream_root) / AI_CONTROLLER_SOURCE
    command_ai_path = Path(upstream_root) / COMMAND_AI_SOURCE
    logic_ai_path = Path(upstream_root) / LOGIC_AI_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    ai_controller_source = ai_controller_path.read_text(encoding="utf-8", errors="replace")
    command_ai_source = command_ai_path.read_text(encoding="utf-8", errors="replace")
    logic_ai_source = logic_ai_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "after_read_override": "@Override\n    public void afterRead(){",
        "after_read_set_type": "setType(this.type);",
        "after_read_controller_unit": "controller.unit(self());",
        "after_read_reset_comment": "reset controller state",
        "after_read_reset_guard": "if(!(controller instanceof AIController ai && ai.keepState())){",
        "after_read_create_controller": "controller(type.createController(self()));",
        "ai_keep_state_method": "public boolean keepState(){",
        "ai_keep_state_return": "return false;",
        "command_ai_keep_state": "public boolean keepState(){\n        return true;\n    }",
        "logic_ai_keep_state_comment": "LogicAI state should not be reset after reading.",
    }
    missing = []
    for key, snippet in checked.items():
        if key.startswith("ai_"):
            haystack = ai_controller_source
        elif key.startswith("command_ai_"):
            haystack = command_ai_source
        elif key.startswith("logic_ai_"):
            haystack = logic_ai_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "ai_controller_source": AI_CONTROLLER_SOURCE,
        "command_ai_source": COMMAND_AI_SOURCE,
        "logic_ai_source": LOGIC_AI_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_after_read_all_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_controller_path = Path(upstream_root) / UNIT_CONTROLLER_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_controller_source = unit_controller_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "after_read_all_override": "@Override\n    public void afterReadAll(){",
        "after_read_all_controller_after_read": "controller.afterRead(self());",
        "unit_controller_after_read": "default void afterRead(Unit unit){",
    }
    missing = []
    for key, snippet in checked.items():
        haystack = unit_controller_source if key.startswith("unit_controller_") else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_controller_source": UNIT_CONTROLLER_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_add_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    teams_path = Path(upstream_root) / TEAMS_SOURCE
    units_path = Path(upstream_root) / UNITS_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    rules_path = Path(upstream_root) / RULES_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    teams_source = teams_path.read_text(encoding="utf-8", errors="replace")
    units_source = units_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    rules_source = rules_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "add_override": "@Override\n    public void add(){",
        "add_update_count": "team.data().updateCount(type, 1);",
        "add_unit_cap_comment": "check if over unit cap",
        "add_cap_guard": "if(type.useUnitCap && count() > cap() && !spawnedByCore && !dead && !state.rules.editor){",
        "add_unit_cap_death": "Call.unitCapDeath(self());",
        "add_update_count_negative": "team.data().updateCount(type, -1);",
        "team_data_update_count": "public void updateCount(UnitType type, int amount){",
        "team_data_update_null": "if(type == null) return;",
        "team_data_update_unit_count": "unitCount = Math.max(amount + unitCount, 0);",
        "team_data_update_type_count": "typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);",
        "units_unit_cap_death": "public static void unitCapDeath(Unit unit){",
        "unit_cap_death_dead": "unit.dead = true;",
        "unit_type_use_unit_cap_default": "useUnitCap = true,",
        "rules_editor_default": "public boolean editor = false;",
    }
    missing = []
    for key, snippet in checked.items():
        if key.startswith("team_data_"):
            haystack = teams_source
        elif key.startswith("units_") or key.startswith("unit_cap_death_"):
            haystack = units_source
        elif key.startswith("unit_type_"):
            haystack = unit_type_source
        elif key.startswith("rules_"):
            haystack = rules_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "teams_source": TEAMS_SOURCE,
        "units_source": UNITS_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "rules_source": RULES_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_remove_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    teams_path = Path(upstream_root) / TEAMS_SOURCE
    unit_controller_path = Path(upstream_root) / UNIT_CONTROLLER_SOURCE
    fx_path = Path(upstream_root) / FX_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    trail_path = Path(upstream_root) / TRAIL_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    teams_source = teams_path.read_text(encoding="utf-8", errors="replace")
    unit_controller_source = unit_controller_path.read_text(encoding="utf-8", errors="replace")
    fx_source = fx_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    trail_source = trail_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "remove_override": "@Override\n    public void remove(){",
        "remove_update_count": "team.data().updateCount(type, -1);",
        "remove_controller_removed": "controller.removed(self());",
        "remove_trail_comment": "make sure trail doesn't just go poof",
        "remove_trail_guard": "if(trail != null && trail.size() > 0){",
        "remove_trail_fade": "Fx.trailFade.at(x, y, trail.width(), type.trailColor == null ? team.color : type.trailColor, trail.copy());",
        "team_data_update_count": "public void updateCount(UnitType type, int amount){",
        "team_data_update_type_count": "typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);",
        "unit_controller_removed": "default void removed(Unit unit){",
        "fx_trail_fade": "trailFade = new Effect(400f, e -> {",
        "fx_trail_instance_guard": "if(!(e.data instanceof Trail trail)) return;",
        "unit_type_trail_color": "public @Nullable Color trailColor;",
        "trail_copy": "public Trail copy(){",
        "trail_width": "public float width(){",
        "trail_size": "public int size(){",
    }
    missing = []
    for key, snippet in checked.items():
        if key.startswith("team_data_"):
            haystack = teams_source
        elif key.startswith("unit_controller_"):
            haystack = unit_controller_source
        elif key.startswith("fx_"):
            haystack = fx_source
        elif key.startswith("unit_type_"):
            haystack = unit_type_source
        elif key.startswith("trail_"):
            haystack = trail_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "teams_source": TEAMS_SOURCE,
        "unit_controller_source": UNIT_CONTROLLER_SOURCE,
        "fx_source": FX_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "trail_source": TRAIL_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_landed_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    effect_path = Path(upstream_root) / EFFECT_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    effect_source = effect_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "landed_override": "@Override\n    public void landed(){",
        "landed_shake_guard": "if(type.mechLandShake > 0f){",
        "landed_shake_call": "Effect.shake(type.mechLandShake, type.mechLandShake, this);",
        "landed_type_call": "type.landed(self());",
        "unit_type_mech_land_shake": "public float mechLandShake = 0f;",
        "unit_type_landed": "public void landed(Unit unit){}",
        "effect_shake_position": "public static void shake(float intensity, float duration, Position loc){",
        "effect_shake_position_call": "shake(intensity, duration, loc.getX(), loc.getY());",
    }
    missing = []
    for key, snippet in checked.items():
        if key.startswith("unit_type_"):
            haystack = unit_type_source
        elif key.startswith("effect_"):
            haystack = effect_source
        else:
            haystack = source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "effect_source": EFFECT_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_heal_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    health_comp_path = Path(upstream_root) / HEALTH_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    health_comp_source = health_comp_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "was_healed_field": "private transient boolean wasHealed;",
        "heal_override": "@Override\n    public void heal(float amount){",
        "heal_guard": "if(health < maxHealth && amount > 0){",
        "heal_was_healed": "wasHealed = true;",
        "update_was_healed_gate": "if(wasHealed && healTime <= -1f){",
        "update_heal_time": "healTime = 1f;",
        "update_was_healed_reset": "wasHealed = false;",
        "health_comp_heal_comment": "Heals by a flat amount.",
        "health_comp_heal_method": "void heal(float amount){",
        "health_comp_heal_add": "health += amount;",
        "health_comp_heal_clamp": "clampHealth();",
    }
    missing = []
    for key, snippet in checked.items():
        haystack = health_comp_source if key.startswith("health_comp_") else source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "health_comp_source": HEALTH_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_move_pref_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "move_pref_comment": "Move based on preferred unit movement type.",
        "move_pref_method": "public void movePref(Vec2 movement){",
        "omni_gate": "if(type.omniMovement){",
        "omni_call": "moveAt(movement);",
        "rotate_call": "rotateMove(movement);",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_floor_speed_multiplier_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    floor_path = Path(upstream_root) / FLOOR_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    floor_source = floor_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "floor_speed_method": "public float floorSpeedMultiplier(){",
        "floor_speed_floor": "Floor on = isFlying() || type.hovering ? Blocks.air.asFloor() : floorOn();",
        "floor_speed_return": "return (float)Math.pow(on.speedMultiplier, type.floorMultiplier) * speedMultiplier;",
        "floor_speed_default": "public float speedMultiplier = 1f;",
        "unit_floor_multiplier_default": "floorMultiplier = 1f,",
    }
    unit_keys = {"floor_speed_method", "floor_speed_floor", "floor_speed_return"}
    floor_keys = {"floor_speed_default"}
    missing = []
    for key, snippet in checked.items():
        if key in unit_keys:
            haystack = source
        elif key in floor_keys:
            haystack = floor_source
        else:
            haystack = unit_type_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "floor_source": FLOOR_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_unloaded_noop_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unloaded_comment": "Called when this unit was unloaded from a factory or spawn point.",
        "unloaded_method": "public void unloaded(){",
        "unloaded_empty_body": "public void unloaded(){\n\n    }",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_boosting_default_event_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_boosting_default_method": "public void updateBoosting(boolean boost){",
        "update_boosting_default_call": "updateBoosting(boost, false);",
        "update_boosting_overload_method": "public void updateBoosting(boolean boost, boolean event){",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_boosting_guard_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_boosting_overload_method": "public void updateBoosting(boolean boost, boolean event){",
        "update_boosting_guard": "if(!type.canBoost || dead) return;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_boosting_should_boost_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "should_boost_line": "boolean shouldBoost = boost || onSolid() || (isFlying() && !canLand());",
        "is_flying_return": "return elevation >= 0.09f;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_boosting_elevation_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "elevation_line": "elevation = Mathf.approachDelta(elevation, type.canBoost ? Mathf.num(shouldBoost) : 0f, shouldBoost ? type.riseSpeed : type.descentSpeed);",
        "mathf_num_method": "public static int num(boolean b){",
        "mathf_num_return": "return b ? 1 : 0;",
        "mathf_approach_delta": "return approach(from, to, Time.delta * speed);",
        "mathf_approach": "return from + Mathf.clamp(to - from, -speed, speed);",
        "mathf_clamp_float": "public static float clamp(float value, float min, float max){",
    }
    unit_keys = {"elevation_line"}
    missing = []
    for key, snippet in checked.items():
        haystack = source if key in unit_keys else mathf_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_boosting_event_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    event_path = Path(upstream_root) / EVENT_TYPE_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    event_source = event_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "event_gate": "if(event){",
        "fire_trigger": "Events.fire(Trigger.unitCommandBoost);",
        "trigger_enum": "public enum Trigger{",
        "unit_command_boost": "unitCommandBoost,",
    }
    unit_keys = {"event_gate", "fire_trigger"}
    missing = []
    for key, snippet in checked.items():
        haystack = source if key in unit_keys else event_source
        if snippet not in haystack:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "event_source": EVENT_TYPE_SOURCE,
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
