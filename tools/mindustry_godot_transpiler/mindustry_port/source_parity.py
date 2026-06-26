import json
import re
from pathlib import Path
from typing import Any


DUO_SOURCE = "core/src/mindustry/content/Blocks.java"
MEND_PROJECTOR_SOURCE = "core/src/mindustry/world/blocks/defense/MendProjector.java"
OVERDRIVE_PROJECTOR_SOURCE = "core/src/mindustry/world/blocks/defense/OverdriveProjector.java"
BUILDING_COMP_SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
UNIT_COMP_SOURCE = "core/src/mindustry/entities/comp/UnitComp.java"
WEAPONS_COMP_SOURCE = "core/src/mindustry/entities/comp/WeaponsComp.java"
HITBOX_COMP_SOURCE = "core/src/mindustry/entities/comp/HitboxComp.java"
PAYLOAD_COMP_SOURCE = "core/src/mindustry/entities/comp/PayloadComp.java"
UNIT_TYPES_CONTENT_SOURCE = "core/src/mindustry/content/UnitTypes.java"
TEAM_SOURCE = "core/src/mindustry/game/Team.java"
GAME_STATE_SOURCE = "core/src/mindustry/core/GameState.java"
SECTOR_SOURCE = "core/src/mindustry/type/Sector.java"
VARS_SOURCE = "core/src/mindustry/Vars.java"
SOUND_CONTROL_SOURCE = "core/src/mindustry/audio/SoundControl.java"
TEAMS_SOURCE = "core/src/mindustry/game/Teams.java"
RULES_SOURCE = "core/src/mindustry/game/Rules.java"
UNITS_SOURCE = "core/src/mindustry/entities/Units.java"
ABILITY_SOURCE = "core/src/mindustry/entities/abilities/Ability.java"
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
ARC_TIME_SOURCE = "arc-core/src/arc/util/Time.java"
ARC_TMP_SOURCE = "arc-core/src/arc/util/Tmp.java"

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

def verify_unit_update_heal_time_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    time_path = Path(arc_root) / ARC_TIME_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    time_source = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "heal_time_field": "transient float shadowAlpha = -1f, healTime;",
        "was_healed_field": "private transient boolean wasHealed;",
        "drowning_before_heal": "updateDrowning();",
        "was_healed_gate": "if(wasHealed && healTime <= -1f){",
        "heal_time_reset": "healTime = 1f;",
        "heal_time_decay": "healTime -= Time.delta / 20f;",
        "was_healed_reset": "wasHealed = false;",
        "time_delta_default": "public static float delta = 1f;",
    }
    source_map = {
        "heal_time_field": source,
        "was_healed_field": source,
        "drowning_before_heal": source,
        "was_healed_gate": source,
        "heal_time_reset": source,
        "heal_time_decay": source,
        "was_healed_reset": source,
        "time_delta_default": time_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "arc_time_source": ARC_TIME_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_captured_sector_death_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    team_path = Path(upstream_root) / TEAM_SOURCE
    game_state_path = Path(upstream_root) / GAME_STATE_SOURCE
    sector_path = Path(upstream_root) / SECTOR_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    team_source = team_path.read_text(encoding="utf-8", errors="replace")
    game_state_source = game_state_path.read_text(encoding="utf-8", errors="replace")
    sector_source = sector_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "captured_comment": "//die on captured sectors immediately",
        "captured_guard": "if(team.isOnlyAI() && state.isCampaign() && state.getSector().isCaptured()){",
        "kill_call": "kill();",
        "team_is_only_ai": "public boolean isOnlyAI(){",
        "team_is_only_ai_body": "return isAI() && data().players.size == 0;",
        "state_is_campaign": "public boolean isCampaign(){",
        "state_is_campaign_body": "return rules.sector != null;",
        "state_get_sector": "public @Nullable Sector getSector(){",
        "state_get_sector_body": "return rules.sector;",
        "sector_is_captured": "public boolean isCaptured(){",
        "sector_playing_capture": "if(isBeingPlayed()) return !state.rules.waves && !state.rules.attackMode;",
        "sector_save_capture": "return save != null && !info.waves && !info.attack;",
    }
    source_map = {
        "captured_comment": source,
        "captured_guard": source,
        "kill_call": source,
        "team_is_only_ai": team_source,
        "team_is_only_ai_body": team_source,
        "state_is_campaign": game_state_source,
        "state_is_campaign_body": game_state_source,
        "state_get_sector": game_state_source,
        "state_get_sector_body": game_state_source,
        "sector_is_captured": sector_source,
        "sector_playing_capture": sector_source,
        "sector_save_capture": sector_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "team_source": TEAM_SOURCE,
        "game_state_source": GAME_STATE_SOURCE,
        "sector_source": SECTOR_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_sound_loop_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    vars_path = Path(upstream_root) / VARS_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    sound_control_path = Path(upstream_root) / SOUND_CONTROL_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    vec2_path = Path(arc_root) / ARC_VEC2_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    vars_source = vars_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    sound_control_source = sound_control_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "headless_guard": "if(!headless){",
        "loop_sound_call": "control.sound.loop(type.loopSound, this, type.loopSoundVolume);",
        "move_sound_guard": "if(type.moveSound != Sounds.none){",
        "move_progress": "float progress = Mathf.clamp(vel.len() / type.speed);",
        "move_pitch": "float pitch = Mathf.lerp(type.moveSoundPitchMin,  type.moveSoundPitchMax, progress);",
        "move_sound_call": "control.sound.loop(type.moveSound, this, type.moveSoundVolume * progress, pitch);",
        "vars_headless": "public static boolean headless;",
        "unit_loop_sound": "public Sound loopSound = Sounds.none;",
        "unit_loop_sound_volume": "public float loopSoundVolume = 0.5f;",
        "unit_move_sound": "public Sound moveSound = Sounds.none;",
        "unit_move_sound_volume": "public float moveSoundVolume = 1f;",
        "unit_move_sound_pitch": "public float moveSoundPitchMin = 1f, moveSoundPitchMax = 1f;",
        "sound_control_loop_pos": "public void loop(Sound sound, Position pos, float volume, float pitch){",
        "sound_control_guard": "if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return;",
        "mathf_clamp_unit": "public static float clamp(float value){",
        "mathf_clamp_unit_body": "return Math.max(Math.min(value, 1f), 0f);",
        "mathf_lerp": "public static float lerp(float fromValue, float toValue, float progress){",
        "mathf_lerp_body": "return fromValue + (toValue - fromValue) * progress;",
        "vec2_len": "public float len(){",
        "vec2_len_body": "return (float)Math.sqrt(x * x + y * y);",
    }
    source_map = {
        "headless_guard": source,
        "loop_sound_call": source,
        "move_sound_guard": source,
        "move_progress": source,
        "move_pitch": source,
        "move_sound_call": source,
        "vars_headless": vars_source,
        "unit_loop_sound": unit_type_source,
        "unit_loop_sound_volume": unit_type_source,
        "unit_move_sound": unit_type_source,
        "unit_move_sound_volume": unit_type_source,
        "unit_move_sound_pitch": unit_type_source,
        "sound_control_loop_pos": sound_control_source,
        "sound_control_guard": sound_control_source,
        "mathf_clamp_unit": mathf_source,
        "mathf_clamp_unit_body": mathf_source,
        "mathf_lerp": mathf_source,
        "mathf_lerp_body": mathf_source,
        "vec2_len": vec2_source,
        "vec2_len_body": vec2_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "vars_source": VARS_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "sound_control_source": SOUND_CONTROL_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_unsupported_env_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    units_path = Path(upstream_root) / UNITS_SOURCE
    teams_path = Path(upstream_root) / TEAMS_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    units_source = units_path.read_text(encoding="utf-8", errors="replace")
    teams_source = teams_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unsupported_env_comment": "//check if environment is unsupported",
        "unsupported_env_guard": "if(!type.supportsEnv(state.rules.env) && !dead){",
        "unit_env_death_call": "Call.unitEnvDeath(self());",
        "update_count_negative": "team.data().updateCount(type, -1);",
        "unit_supports_env_method": "public boolean supportsEnv(int env){",
        "unit_supports_env_body": "return (envEnabled & env) != 0 && (envDisabled & env) == 0 && (envRequired == 0 || (envRequired & env) == envRequired);",
        "units_unit_env_death": "public static void unitEnvDeath(Unit unit){",
        "units_unit_env_dead": "unit.dead = true;",
        "units_unit_env_effect": "Fx.unitEnvKill.at(unit);",
        "units_unit_env_destroy": "Core.app.post(() -> Call.unitDestroy(unit.id));",
        "team_data_update_count": "public void updateCount(UnitType type, int amount){",
        "team_data_update_count_null_guard": "if(type == null) return;",
        "team_data_update_count_total": "unitCount = Math.max(amount + unitCount, 0);",
        "team_data_update_count_type": "typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);",
    }
    source_map = {
        "unsupported_env_comment": source,
        "unsupported_env_guard": source,
        "unit_env_death_call": source,
        "update_count_negative": source,
        "unit_supports_env_method": unit_type_source,
        "unit_supports_env_body": unit_type_source,
        "units_unit_env_death": units_source,
        "units_unit_env_dead": units_source,
        "units_unit_env_effect": units_source,
        "units_unit_env_destroy": units_source,
        "team_data_update_count": teams_source,
        "team_data_update_count_null_guard": teams_source,
        "team_data_update_count_total": teams_source,
        "team_data_update_count_type": teams_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "units_source": UNITS_SOURCE,
        "teams_source": TEAMS_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_abilities_loop_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    ability_path = Path(upstream_root) / ABILITY_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    ability_source = ability_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_abilities_field": "Ability[] abilities = {};",
        "abilities_loop": "for(Ability a : abilities){",
        "ability_update_call": "a.update(self());",
        "ability_update_method": "public void update(Unit unit){}",
    }
    source_map = {
        "unit_abilities_field": source,
        "abilities_loop": source,
        "ability_update_call": source,
        "ability_update_method": ability_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "ability_source": ABILITY_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_trail_position_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    trail_path = Path(upstream_root) / TRAIL_SOURCE
    angles_path = Path(arc_root) / ARC_ANGLES_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    trail_source = trail_path.read_text(encoding="utf-8", errors="replace")
    angles_source = angles_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "trail_field": "transient @Nullable Trail trail;",
        "trail_guard": "if(trail != null){",
        "trail_length_set": "trail.length = type.trailLength;",
        "trail_scale": "float scale = type.useEngineElevation ? elevation : 1f;",
        "trail_offset": "float offset = type.engineOffset/2f + type.engineOffset/2f*scale;",
        "trail_position": "float cx = x + Angles.trnsx(rotation + 180, offset), cy = y + Angles.trnsy(rotation + 180, offset);",
        "trail_update_call": "trail.update(cx, cy);",
        "unit_engine_offset": "engineOffset = 5f,",
        "unit_use_engine_elevation": "public boolean useEngineElevation = true;",
        "unit_trail_length": "public int trailLength = 0;",
        "trail_update_xy": "public void update(float x, float y){",
        "trail_update_width_delegate": "update(x, y, 1f);",
        "angles_trnsx": "public static float trnsx(float angle, float len){",
        "angles_trnsx_body": "return len * Mathf.cosDeg(angle);",
        "angles_trnsy": "public static float trnsy(float angle, float len){",
        "angles_trnsy_body": "return len * Mathf.sinDeg(angle);",
        "mathf_sin_deg": "public static float sinDeg(float degrees){",
        "mathf_cos_deg": "public static float cosDeg(float degrees){",
    }
    source_map = {
        "trail_field": source,
        "trail_guard": source,
        "trail_length_set": source,
        "trail_scale": source,
        "trail_offset": source,
        "trail_position": source,
        "trail_update_call": source,
        "unit_engine_offset": unit_type_source,
        "unit_use_engine_elevation": unit_type_source,
        "unit_trail_length": unit_type_source,
        "trail_update_xy": trail_source,
        "trail_update_width_delegate": trail_source,
        "angles_trnsx": angles_source,
        "angles_trnsx_body": angles_source,
        "angles_trnsy": angles_source,
        "angles_trnsy_body": angles_source,
        "mathf_sin_deg": mathf_source,
        "mathf_cos_deg": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "trail_source": TRAIL_SOURCE,
        "arc_angles_source": ARC_ANGLES_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_drag_formula_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    floor_path = Path(upstream_root) / FLOOR_SOURCE
    rules_path = Path(upstream_root) / RULES_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    floor_source = floor_path.read_text(encoding="utf-8", errors="replace")
    rules_source = rules_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_import_drag": "@Import float x, y, rotation, maxHealth, drag, armor, hitSize, health, shield, dragMultiplier, armorOverride, speedMultiplier;",
        "drag_formula": "drag = type.drag * (isGrounded() ? (floorOn().dragMultiplier) : 1f) * dragMultiplier * state.rules.dragMultiplier;",
        "unit_type_drag_default": "drag = 0.3f,",
        "floor_drag_multiplier": "public float dragMultiplier = 1f;",
        "rules_drag_multiplier": "public float dragMultiplier = 1f;",
    }
    source_map = {
        "unit_import_drag": source,
        "drag_formula": source,
        "unit_type_drag_default": unit_type_source,
        "floor_drag_multiplier": floor_source,
        "rules_drag_multiplier": rules_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "floor_source": FLOOR_SOURCE,
        "rules_source": RULES_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_spawn_knockback_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    rules_path = Path(upstream_root) / RULES_SOURCE
    game_state_path = Path(upstream_root) / GAME_STATE_SOURCE
    wave_spawner_path = Path(upstream_root) / "core/src/mindustry/ai/WaveSpawner.java"
    net_path = Path(upstream_root) / "core/src/mindustry/net/Net.java"
    vel_comp_path = Path(upstream_root) / "core/src/mindustry/entities/comp/VelComp.java"
    position_path = Path(arc_root) / ARC_POSITION_SOURCE
    vec2_path = Path(arc_root) / ARC_VEC2_SOURCE
    time_path = Path(arc_root) / "arc-core/src/arc/util/Time.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    rules_source = rules_path.read_text(encoding="utf-8", errors="replace")
    game_state_source = game_state_path.read_text(encoding="utf-8", errors="replace")
    wave_spawner_source = wave_spawner_path.read_text(encoding="utf-8", errors="replace")
    net_source = net_path.read_text(encoding="utf-8", errors="replace")
    vel_comp_source = vel_comp_path.read_text(encoding="utf-8", errors="replace")
    position_source = position_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    time_source = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "spawn_knockback_comment": "//apply knockback based on spawns",
        "spawn_knockback_guard": "if(team != state.rules.waveTeam && state.hasSpawns() && (!net.client() || isLocal()) && hittable()){",
        "relative_size": "float relativeSize = state.rules.dropZoneRadius + hitSize/2f + 1f;",
        "spawn_loop": "for(Tile spawn : spawner.getSpawns()){",
        "spawn_within_guard": "if(within(spawn.worldx(), spawn.worldy(), relativeSize)){",
        "vel_add_net_call": "velAddNet(Tmp.v1.set(this).sub(spawn.worldx(), spawn.worldy()).setLength(0.1f + 1f - dst(spawn) / relativeSize).scl(0.45f * Time.delta));",
        "rules_drop_zone_radius": "public float dropZoneRadius = 300f;",
        "rules_wave_team": "public Team waveTeam = Team.crux;",
        "state_has_spawns": "public boolean hasSpawns(){",
        "state_has_spawns_body": "return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);",
        "spawner_get_spawns": "public Seq<Tile> getSpawns(){",
        "spawner_get_spawns_body": "return spawns;",
        "net_client": "public boolean client(){",
        "net_client_body": "return !server && active;",
        "vel_add_net_vec": "void velAddNet(Vec2 v){",
        "vel_add_net_add": "vel.add(v);",
        "vel_add_net_remote_x": "x += v.x;",
        "vel_add_net_remote_y": "y += v.y;",
        "position_within": "default boolean within(float x, float y, float dst){",
        "position_within_body": "return Mathf.dst2(getX(), getY(), x, y) < dst*dst;",
        "position_dst": "default float dst(float x, float y){",
        "position_dst_body": "return Mathf.sqrt(xd * xd + yd * yd);",
        "vec2_set_position": "public Vec2 set(Position v){",
        "vec2_set_position_x": "x = v.getX();",
        "vec2_sub": "public Vec2 sub(float x, float y){",
        "vec2_set_length": "public Vec2 setLength(float len){",
        "vec2_scl": "public Vec2 scl(float scalar){",
        "time_delta_default": "public static float delta = 1f;",
    }
    source_map = {
        "spawn_knockback_comment": source,
        "spawn_knockback_guard": source,
        "relative_size": source,
        "spawn_loop": source,
        "spawn_within_guard": source,
        "vel_add_net_call": source,
        "rules_drop_zone_radius": rules_source,
        "rules_wave_team": rules_source,
        "state_has_spawns": game_state_source,
        "state_has_spawns_body": game_state_source,
        "spawner_get_spawns": wave_spawner_source,
        "spawner_get_spawns_body": wave_spawner_source,
        "net_client": net_source,
        "net_client_body": net_source,
        "vel_add_net_vec": vel_comp_source,
        "vel_add_net_add": vel_comp_source,
        "vel_add_net_remote_x": vel_comp_source,
        "vel_add_net_remote_y": vel_comp_source,
        "position_within": position_source,
        "position_within_body": position_source,
        "position_dst": position_source,
        "position_dst_body": position_source,
        "vec2_set_position": vec2_source,
        "vec2_set_position_x": vec2_source,
        "vec2_sub": vec2_source,
        "vec2_set_length": vec2_source,
        "vec2_scl": vec2_source,
        "time_delta_default": time_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "rules_source": RULES_SOURCE,
        "game_state_source": GAME_STATE_SOURCE,
        "wave_spawner_source": "core/src/mindustry/ai/WaveSpawner.java",
        "net_source": "core/src/mindustry/net/Net.java",
        "vel_comp_source": "core/src/mindustry/entities/comp/VelComp.java",
        "arc_position_source": ARC_POSITION_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "arc_time_source": "arc-core/src/arc/util/Time.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_falling_drag_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "unit_import_dead": "@Import boolean dead, disarmed;",
        "unit_import_health_drag": "@Import float x, y, rotation, maxHealth, drag, armor, hitSize, health, shield, dragMultiplier, armorOverride, speedMultiplier;",
        "falling_comment": "//simulate falling down",
        "falling_guard": "if(dead || health <= 0){",
        "less_drag_comment": "//less drag when dead",
        "falling_drag": "drag = 0.01f;",
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

def verify_unit_update_falling_smoke_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    fx_path = Path(upstream_root) / FX_SOURCE
    effect_path = Path(upstream_root) / EFFECT_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    vec2_path = Path(arc_root) / ARC_VEC2_SOURCE
    tmp_path = Path(arc_root) / ARC_TMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    fx_source = fx_path.read_text(encoding="utf-8", errors="replace")
    effect_source = effect_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    tmp_source = tmp_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "standard_fall_smoke_comment": "//standard fall smoke",
        "standard_fall_smoke_chance": "if(Mathf.chanceDelta(0.1)){",
        "standard_fall_smoke_tmp": "Tmp.v1.rnd(Mathf.range(hitSize));",
        "standard_fall_smoke_effect": "type.fallEffect.at(x + Tmp.v1.x, y + Tmp.v1.y);",
        "unit_type_fall_effect": "public Effect fallEffect = Fx.fallSmoke;",
        "fx_fall_smoke": "fallSmoke = new Effect(110, e -> {",
        "mathf_range_float": "public static float range(float range){",
        "mathf_range_float_body": "return random(-range, range);",
        "mathf_chance_delta": "public static boolean chanceDelta(double d){",
        "mathf_chance_delta_body": "return rand.nextFloat() < d * Time.delta;",
        "tmp_v1": "public static final Vec2 v1 = new Vec2();",
        "vec2_rnd": "public Vec2 rnd(float length){",
        "vec2_rnd_body": "setToRandomDirection().scl(length);",
        "effect_at_xy": "public void at(float x, float y){",
        "effect_at_xy_body": "create(x, y, 0, Color.white, null);",
    }
    source_map = {
        "standard_fall_smoke_comment": source,
        "standard_fall_smoke_chance": source,
        "standard_fall_smoke_tmp": source,
        "standard_fall_smoke_effect": source,
        "unit_type_fall_effect": unit_type_source,
        "fx_fall_smoke": fx_source,
        "mathf_range_float": mathf_source,
        "mathf_range_float_body": mathf_source,
        "mathf_chance_delta": mathf_source,
        "mathf_chance_delta_body": mathf_source,
        "tmp_v1": tmp_source,
        "vec2_rnd": vec2_source,
        "vec2_rnd_body": vec2_source,
        "effect_at_xy": effect_source,
        "effect_at_xy_body": effect_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "fx_source": FX_SOURCE,
        "effect_source": EFFECT_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "arc_tmp_source": ARC_TMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_falling_engine_trail_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    angles_path = Path(arc_root) / ARC_ANGLES_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    angles_source = angles_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "thruster_fall_trail_comment": "//thruster fall trail",
        "thruster_chance": "if(Mathf.chanceDelta(0.2)){",
        "thruster_offset": "float offset = type.engineOffset/2f + type.engineOffset/2f * elevation;",
        "thruster_range": "float range = Mathf.range(type.engineSize);",
        "thruster_effect_call": "type.fallEngineEffect.at(",
        "thruster_effect_x": "x + Angles.trnsx(rotation + 180, offset) + Mathf.range(range),",
        "thruster_effect_y": "y + Angles.trnsy(rotation + 180, offset) + Mathf.range(range),",
        "thruster_effect_rotation": "Mathf.random()",
        "unit_type_fall_engine_effect": "public Effect fallEngineEffect = Fx.fallSmoke;",
        "unit_engine_offset": "engineOffset = 5f,",
        "unit_engine_size": "engineSize = 2.5f,",
        "mathf_chance_delta": "public static boolean chanceDelta(double d){",
        "mathf_range_float": "public static float range(float range){",
        "mathf_random": "public static float random(){",
        "angles_trnsx": "public static float trnsx(float angle, float len){",
        "angles_trnsx_body": "return len * Mathf.cosDeg(angle);",
        "angles_trnsy": "public static float trnsy(float angle, float len){",
        "angles_trnsy_body": "return len * Mathf.sinDeg(angle);",
    }
    source_map = {
        "thruster_fall_trail_comment": source,
        "thruster_chance": source,
        "thruster_offset": source,
        "thruster_range": source,
        "thruster_effect_call": source,
        "thruster_effect_x": source,
        "thruster_effect_y": source,
        "thruster_effect_rotation": source,
        "unit_type_fall_engine_effect": unit_type_source,
        "unit_engine_offset": unit_type_source,
        "unit_engine_size": unit_type_source,
        "mathf_chance_delta": mathf_source,
        "mathf_range_float": mathf_source,
        "mathf_random": mathf_source,
        "angles_trnsx": angles_source,
        "angles_trnsx_body": angles_source,
        "angles_trnsy": angles_source,
        "angles_trnsy_body": angles_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "arc_angles_source": ARC_ANGLES_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_falling_descent_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    units_path = Path(upstream_root) / UNITS_SOURCE
    time_path = Path(arc_root) / ARC_TIME_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    units_source = units_path.read_text(encoding="utf-8", errors="replace")
    time_source = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "move_down_comment": "//move down",
        "fall_descent": "elevation -= type.fallSpeed * Time.delta;",
        "destroy_guard": "if(isGrounded() || health <= -maxHealth * type.wreckHealthMultiplier){",
        "unit_destroy_call": "Call.unitDestroy(id);",
        "unit_type_fall_speed": "fallSpeed = 0.018f,",
        "unit_type_wreck_health_multiplier": "wreckHealthMultiplier = 0.25f,",
        "time_delta": "public static float delta = 1f;",
        "units_unit_destroy_remote": "@Remote(called = Loc.server)",
        "units_unit_destroy": "public static void unitDestroy(int uid){",
        "units_destroy_body": "unit.destroy();",
    }
    source_map = {
        "move_down_comment": source,
        "fall_descent": source,
        "destroy_guard": source,
        "unit_destroy_call": source,
        "unit_type_fall_speed": unit_type_source,
        "unit_type_wreck_health_multiplier": unit_type_source,
        "time_delta": time_source,
        "units_unit_destroy_remote": units_source,
        "units_unit_destroy": units_source,
        "units_destroy_body": units_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "units_source": UNITS_SOURCE,
        "arc_time_source": ARC_TIME_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_tile_unit_on_any_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    building_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    tile_source_path = Path(upstream_root) / "core/src/mindustry/world/Tile.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    building_source = building_path.read_text(encoding="utf-8", errors="replace")
    tile_source = tile_source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "tile_build_guard": "if(tile != null && tile.build != null){",
        "tile_build_unit_on_any": "tile.build.unitOnAny(self());",
        "tile_build_field": "public @Nullable Building build;",
        "building_unit_on_any_comment": "/** Called every frame a unit is on this. Applies to any unit.  */",
        "building_unit_on_any": "public void unitOnAny(Unit unit){",
    }
    source_map = {
        "tile_build_guard": source,
        "tile_build_unit_on_any": source,
        "tile_build_field": tile_source,
        "building_unit_on_any_comment": building_source,
        "building_unit_on_any": building_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "building_source": BUILDING_COMP_SOURCE,
        "tile_source": "core/src/mindustry/world/Tile.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_tile_unit_on_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    building_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    tile_source_path = Path(upstream_root) / "core/src/mindustry/world/Tile.java"
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    building_source = building_path.read_text(encoding="utf-8", errors="replace")
    tile_source = tile_source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "grounded_tile_guard": "if(tile != null && isGrounded() && !type.hovering){",
        "unit_block_update_comment": "//unit block update",
        "tile_build_guard": "if(tile.build != null){",
        "tile_build_unit_on": "tile.build.unitOn(self());",
        "apply_damage_comment": "//apply damage",
        "tile_build_field": "public @Nullable Building build;",
        "unit_type_hovering_default": "hovering = false,",
        "building_unit_on_comment": "/** Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  */",
        "building_unit_on": "public void unitOn(Unit unit){",
    }
    source_map = {
        "grounded_tile_guard": source,
        "unit_block_update_comment": source,
        "tile_build_guard": source,
        "tile_build_unit_on": source,
        "apply_damage_comment": source,
        "tile_build_field": tile_source,
        "unit_type_hovering_default": unit_type_source,
        "building_unit_on_comment": building_source,
        "building_unit_on": building_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "building_source": BUILDING_COMP_SOURCE,
        "tile_source": "core/src/mindustry/world/Tile.java",
        "unit_type_source": UNIT_TYPE_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_floor_damage_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    floor_path = Path(upstream_root) / FLOOR_SOURCE
    health_path = Path(upstream_root) / HEALTH_COMP_SOURCE
    time_path = Path(arc_root) / ARC_TIME_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    floor_source = floor_path.read_text(encoding="utf-8", errors="replace")
    health_source = health_path.read_text(encoding="utf-8", errors="replace")
    time_source = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "grounded_tile_guard": "if(tile != null && isGrounded() && !type.hovering){",
        "apply_damage_comment": "//apply damage",
        "floor_damage_guard": "if(floor.damageTaken > 0f){",
        "floor_damage_call": "damageContinuous(floor.damageTaken);",
        "floor_damage_taken_default": "public float damageTaken = 0f;",
        "floor_damages": "return damageTaken > 0f || (status != null && status.damage > 0f);",
        "health_damage_continuous": "void damageContinuous(float amount){",
        "health_damage_continuous_body": "damage(amount * Time.delta, hitTime <= -10 + hitDuration);",
        "time_delta": "public static float delta = 1f;",
    }
    source_map = {
        "grounded_tile_guard": source,
        "apply_damage_comment": source,
        "floor_damage_guard": source,
        "floor_damage_call": source,
        "floor_damage_taken_default": floor_source,
        "floor_damages": floor_source,
        "health_damage_continuous": health_source,
        "health_damage_continuous_body": health_source,
        "time_delta": time_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "floor_source": FLOOR_SOURCE,
        "health_source": HEALTH_COMP_SOURCE,
        "arc_time_source": ARC_TIME_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_solid_tile_response_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    vel_path = Path(upstream_root) / "core/src/mindustry/entities/comp/VelComp.java"
    entity_path = Path(upstream_root) / "core/src/mindustry/entities/comp/EntityComp.java"
    net_path = Path(upstream_root) / "core/src/mindustry/net/Net.java"
    vars_path = Path(upstream_root) / VARS_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    vel_source = vel_path.read_text(encoding="utf-8", errors="replace")
    entity_source = entity_path.read_text(encoding="utf-8", errors="replace")
    net_source = net_path.read_text(encoding="utf-8", errors="replace")
    vars_source = vars_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "solid_tile_comment": "//kill entities on tiles that are solid to them",
        "solid_tile_guard": "if(tile != null && !canPassOn()){",
        "boost_comment": "//boost if possible",
        "can_boost_guard": "if(type.canBoost){",
        "boost_elevation": "elevation = 1f;",
        "kill_guard": "else if(!net.client() && !(!headless && isRemote())){",
        "kill_call": "kill();",
        "unit_type_can_boost_default": "canBoost = false,",
        "vel_can_pass_on": "boolean canPassOn(){",
        "vel_can_pass_on_body": "return canPass(tileX(), tileY());",
        "entity_is_remote": "boolean isRemote(){",
        "entity_is_remote_body": "return ((Object)this) instanceof Unitc u && u.isPlayer() && !isLocal();",
        "net_client": "public boolean client(){",
        "net_client_body": "return !server && active;",
        "vars_headless": "public static boolean headless;",
    }
    source_map = {
        "solid_tile_comment": source,
        "solid_tile_guard": source,
        "boost_comment": source,
        "can_boost_guard": source,
        "boost_elevation": source,
        "kill_guard": source,
        "kill_call": source,
        "unit_type_can_boost_default": unit_type_source,
        "vel_can_pass_on": vel_source,
        "vel_can_pass_on_body": vel_source,
        "entity_is_remote": entity_source,
        "entity_is_remote_body": entity_source,
        "net_client": net_source,
        "net_client_body": net_source,
        "vars_headless": vars_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "vel_source": "core/src/mindustry/entities/comp/VelComp.java",
        "entity_source": "core/src/mindustry/entities/comp/EntityComp.java",
        "net_source": "core/src/mindustry/net/Net.java",
        "vars_source": VARS_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_ai_controller_server_gate_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_controller_path = Path(upstream_root) / "core/src/mindustry/entities/units/UnitController.java"
    net_path = Path(upstream_root) / "core/src/mindustry/net/Net.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_controller_source = unit_controller_path.read_text(encoding="utf-8", errors="replace")
    net_source = net_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "controller_field": "private UnitController controller;",
        "dead_import": "@Import boolean dead, disarmed;",
        "ai_server_comment": "//AI only updates on the server",
        "ai_server_guard": "if(!net.client() && !dead && shouldUpdateController()){",
        "controller_update_call": "controller.updateUnit();",
        "should_update_method": "public boolean shouldUpdateController(){",
        "should_update_default": "return true;",
        "unit_controller_update": "default void updateUnit(){",
        "net_client": "public boolean client(){",
        "net_client_body": "return !server && active;",
    }
    source_map = {
        "controller_field": source,
        "dead_import": source,
        "ai_server_comment": source,
        "ai_server_guard": source,
        "controller_update_call": source,
        "should_update_method": source,
        "should_update_default": source,
        "unit_controller_update": unit_controller_source,
        "net_client": net_source,
        "net_client_body": net_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_controller_source": "core/src/mindustry/entities/units/UnitController.java",
        "net_source": "core/src/mindustry/net/Net.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_invalid_controller_reset_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_controller_path = Path(upstream_root) / "core/src/mindustry/entities/units/UnitController.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_controller_source = unit_controller_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "clear_controller_comment": "//clear controller when it becomes invalid",
        "invalid_controller_guard": "if(!controller.isValidController()){",
        "reset_controller_call": "resetController();",
        "reset_controller_method": "public void resetController(){",
        "reset_controller_body": "controller(type.createController(self()));",
        "controller_setter": "public void controller(UnitController next){",
        "controller_unit_sync": "if(controller.unit() != self()) controller.unit(self());",
        "unit_controller_is_valid": "default boolean isValidController(){",
        "unit_controller_is_valid_default": "return true;",
    }
    source_map = {
        "clear_controller_comment": source,
        "invalid_controller_guard": source,
        "reset_controller_call": source,
        "reset_controller_method": source,
        "reset_controller_body": source,
        "controller_setter": source,
        "controller_unit_sync": source,
        "unit_controller_is_valid": unit_controller_source,
        "unit_controller_is_valid_default": unit_controller_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_controller_source": "core/src/mindustry/entities/units/UnitController.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_spawned_core_despawn_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    units_path = Path(upstream_root) / "core/src/mindustry/entities/Units.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    units_source = units_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "spawned_by_core_field": "boolean spawnedByCore;",
        "dead_import": "@Import boolean dead, disarmed;",
        "core_despawn_comment": "//remove units spawned by the core",
        "core_despawn_guard": "if(spawnedByCore && !isPlayer() && !dead){",
        "core_despawn_call": "Call.unitDespawn(self());",
        "is_player_method": "public boolean isPlayer(){",
        "is_player_body": "return controller instanceof Player;",
        "unit_despawn_remote": "@Remote(called = Loc.server)",
        "unit_despawn_method": "public static void unitDespawn(Unit unit){",
        "unit_despawn_null_guard": "if(unit == null) return;",
        "unit_despawn_effect": "Fx.unitDespawn.at(unit.x, unit.y, 0, unit);",
        "unit_despawn_remove": "unit.remove();",
    }
    source_map = {
        "spawned_by_core_field": source,
        "dead_import": source,
        "core_despawn_comment": source,
        "core_despawn_guard": source,
        "core_despawn_call": source,
        "is_player_method": source,
        "is_player_body": source,
        "unit_despawn_remote": units_source,
        "unit_despawn_method": units_source,
        "unit_despawn_null_guard": units_source,
        "unit_despawn_effect": units_source,
        "unit_despawn_remove": units_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "units_source": "core/src/mindustry/entities/Units.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_icon_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unlockable_path = Path(upstream_root) / "core/src/mindustry/ctype/UnlockableContent.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unlockable_source = unlockable_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "icon_comment": "/** @return a preview UI icon for this unit. */",
        "icon_method": "public TextureRegion icon(){",
        "icon_return": "return type.uiIcon;",
        "unlockable_ui_icon": "public TextureRegion uiIcon;",
        "unlockable_ui_icon_load": "uiIcon = Core.atlas.find(getContentType().name() + \"-\" + name + \"-ui\", fullIcon);",
    }
    source_map = {
        "icon_comment": source,
        "icon_method": source,
        "icon_return": source,
        "unlockable_ui_icon": unlockable_source,
        "unlockable_ui_icon_load": unlockable_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unlockable_content_source": "core/src/mindustry/ctype/UnlockableContent.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_initial_payload_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    entity_path = Path(upstream_root) / "core/src/mindustry/entities/comp/EntityComp.java"
    items_path = Path(upstream_root) / "core/src/mindustry/entities/comp/ItemsComp.java"
    item_path = Path(upstream_root) / "core/src/mindustry/type/Item.java"
    item_stack_path = Path(upstream_root) / "core/src/mindustry/type/ItemStack.java"
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    entity_source = entity_path.read_text(encoding="utf-8", errors="replace")
    items_source = items_path.read_text(encoding="utf-8", errors="replace")
    item_source = item_path.read_text(encoding="utf-8", errors="replace")
    item_stack_source = item_stack_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "destroy_comment": "/** Actually destroys the unit, removing it and creating explosions. **/",
        "destroy_method": "public void destroy(){",
        "destroy_guard": "if(!isAdded() || !killable()) return;",
        "explosiveness_formula": "float explosiveness = 2f + item().explosiveness * stack().amount * 1.53f;",
        "flammability_formula": "float flammability = item().flammability * stack().amount / 1.9f;",
        "power_formula": "float power = item().charge * Mathf.pow(stack().amount, 1.11f) * 160f;",
        "entity_is_added": "boolean isAdded(){",
        "entity_is_added_body": "return added;",
        "unit_killable": "public boolean killable(){",
        "unit_killable_body": "return type.killable(self());",
        "items_item": "Item item(){",
        "items_item_body": "return stack.item;",
        "item_explosiveness": "public float explosiveness = 0f;",
        "item_flammability": "public float flammability = 0f;",
        "item_charge": "public float charge = 0f;",
        "item_stack_amount": "public int amount = 0;",
        "mathf_pow": "public static float pow(float a, float b){",
        "mathf_pow_body": "return (float)Math.pow(a, b);",
    }
    source_map = {
        "destroy_comment": source,
        "destroy_method": source,
        "destroy_guard": source,
        "explosiveness_formula": source,
        "flammability_formula": source,
        "power_formula": source,
        "entity_is_added": entity_source,
        "entity_is_added_body": entity_source,
        "unit_killable": source,
        "unit_killable_body": source,
        "items_item": items_source,
        "items_item_body": items_source,
        "item_explosiveness": item_source,
        "item_flammability": item_source,
        "item_charge": item_source,
        "item_stack_amount": item_stack_source,
        "mathf_pow": mathf_source,
        "mathf_pow_body": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "entity_source": "core/src/mindustry/entities/comp/EntityComp.java",
        "items_source": "core/src/mindustry/entities/comp/ItemsComp.java",
        "item_source": "core/src/mindustry/type/Item.java",
        "item_stack_source": "core/src/mindustry/type/ItemStack.java",
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_explosion_dispatch_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / "core/src/mindustry/type/UnitType.java"
    damage_path = Path(upstream_root) / "core/src/mindustry/entities/Damage.java"
    rules_path = Path(upstream_root) / "core/src/mindustry/game/Rules.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    damage_source = damage_path.read_text(encoding="utf-8", errors="replace")
    rules_source = rules_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "destroy_not_spawned_guard": "if(!spawnedByCore){",
        "destroy_dynamic_explosion_call": "Damage.dynamicExplosion(x, y, flammability, explosiveness, power, (bounds() + type.legLength/1.7f) / 2f, state.rules.damageExplosions && state.rules.unitCrashDamage(team) > 0, item().flammability > 1, team, type.deathExplosionEffect, 0f);",
        "destroy_spawned_core_else": "}else{",
        "destroy_spawned_core_effect": "type.deathExplosionEffect.at(x, y, bounds() / 2f / 8f);",
        "unit_death_explosion_effect": "public Effect deathExplosionEffect = Fx.dynamicExplosion;",
        "unit_leg_length": "public float legLength = 10f,",
        "damage_dynamic_explosion_overload": "public static void dynamicExplosion(float x, float y, float flammability, float explosiveness, float power, float radius, boolean damage, boolean fire, @Nullable Team ignoreTeam, Effect explosionFx, float baseShake){",
        "rules_unit_crash_damage": "public float unitCrashDamage(Team team){",
        "rules_unit_crash_damage_body": "return unitDamage(team) * unitCrashDamageMultiplier * teams.get(team).unitCrashDamageMultiplier;",
    }
    source_map = {
        "destroy_not_spawned_guard": source,
        "destroy_dynamic_explosion_call": source,
        "destroy_spawned_core_else": source,
        "destroy_spawned_core_effect": source,
        "unit_death_explosion_effect": unit_type_source,
        "unit_leg_length": unit_type_source,
        "damage_dynamic_explosion_overload": damage_source,
        "rules_unit_crash_damage": rules_source,
        "rules_unit_crash_damage_body": rules_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": "core/src/mindustry/type/UnitType.java",
        "damage_source": "core/src/mindustry/entities/Damage.java",
        "rules_source": "core/src/mindustry/game/Rules.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_visual_effects_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / "core/src/mindustry/type/UnitType.java"
    effect_path = Path(upstream_root) / "core/src/mindustry/entities/Effect.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    effect_source = effect_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "destroy_shake_formula": "float shake = type.deathShake < 0 ? 3f + hitSize / 3f : type.deathShake;",
        "destroy_create_scorch_guard": "if(type.createScorch){",
        "destroy_scorch_call": "Effect.scorch(x, y, (int)(hitSize / 5));",
        "destroy_shake_call": "Effect.shake(shake, shake, this);",
        "unit_hit_size_default": "hitSize = 6f,",
        "unit_death_shake_default": "deathShake = -1f,",
        "unit_create_scorch_default": "createScorch = true,",
        "effect_shake_position_overload": "public static void shake(float intensity, float duration, Position loc){",
        "effect_shake_position_body": "shake(intensity, duration, loc.getX(), loc.getY());",
        "effect_scorch_method": "public static void scorch(float x, float y, int size){",
    }
    source_map = {
        "destroy_shake_formula": source,
        "destroy_create_scorch_guard": source,
        "destroy_scorch_call": source,
        "destroy_shake_call": source,
        "unit_hit_size_default": unit_type_source,
        "unit_death_shake_default": unit_type_source,
        "unit_create_scorch_default": unit_type_source,
        "effect_shake_position_overload": effect_source,
        "effect_shake_position_body": effect_source,
        "effect_scorch_method": effect_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": "core/src/mindustry/type/UnitType.java",
        "effect_source": "core/src/mindustry/entities/Effect.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_sound_and_event_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / "core/src/mindustry/type/UnitType.java"
    event_type_path = Path(upstream_root) / "core/src/mindustry/game/EventType.java"
    sound_path = Path(arc_root) / "arc-core/src/arc/audio/Sound.java"
    events_path = Path(arc_root) / "arc-core/src/arc/Events.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    event_type_source = event_type_path.read_text(encoding="utf-8", errors="replace")
    sound_source = sound_path.read_text(encoding="utf-8", errors="replace")
    events_source = events_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "destroy_death_sound_call": "type.deathSound.at(this, 1f, type.deathSoundVolume);",
        "destroy_unit_destroy_event": "Events.fire(new UnitDestroyEvent(self()));",
        "unit_death_sound_field": "public Sound deathSound = Sounds.unset;",
        "unit_death_sound_volume": "public float deathSoundVolume = 1f;",
        "sound_at_position": "public int at(Position pos, float pitch, float volume){",
        "sound_at_position_body": "return at(pos.getX(), pos.getY(), pitch, volume);",
        "unit_destroy_event_class": "public static class UnitDestroyEvent{",
        "unit_destroy_event_unit": "public final Unit unit;",
        "unit_destroy_event_constructor": "public UnitDestroyEvent(Unit unit){",
        "arc_events_fire_object": "public static <T> void fire(T type){",
        "arc_events_fire_object_body": "fire(type.getClass(), type);",
    }
    source_map = {
        "destroy_death_sound_call": source,
        "destroy_unit_destroy_event": source,
        "unit_death_sound_field": unit_type_source,
        "unit_death_sound_volume": unit_type_source,
        "sound_at_position": sound_source,
        "sound_at_position_body": sound_source,
        "unit_destroy_event_class": event_type_source,
        "unit_destroy_event_unit": event_type_source,
        "unit_destroy_event_constructor": event_type_source,
        "arc_events_fire_object": events_source,
        "arc_events_fire_object_body": events_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": "core/src/mindustry/type/UnitType.java",
        "event_type_source": "core/src/mindustry/game/EventType.java",
        "arc_sound_source": "arc-core/src/arc/audio/Sound.java",
        "arc_events_source": "arc-core/src/arc/Events.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_suicide_bomb_trigger_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    entity_path = Path(upstream_root) / "core/src/mindustry/entities/comp/EntityComp.java"
    event_type_path = Path(upstream_root) / "core/src/mindustry/game/EventType.java"
    events_path = Path(arc_root) / "arc-core/src/arc/Events.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    entity_source = entity_path.read_text(encoding="utf-8", errors="replace")
    event_type_source = event_type_path.read_text(encoding="utf-8", errors="replace")
    events_source = events_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "was_player_field": "private transient boolean wasPlayer;",
        "destroy_suicide_bomb_guard": "if(explosiveness > 7f && (isLocal() || wasPlayer)){",
        "destroy_suicide_bomb_event": "Events.fire(Trigger.suicideBomb);",
        "entity_is_local": "boolean isLocal(){",
        "entity_is_local_body": "return ((Object)this) == player || ((Object)this) instanceof Unitc u && u.controller() == player;",
        "killed_was_player": "wasPlayer = isLocal();",
        "trigger_suicide_bomb": "suicideBomb,",
        "arc_events_fire_enum": "public static <T extends Enum<T>> void fire(Enum<T> type){",
    }
    source_map = {
        "was_player_field": source,
        "destroy_suicide_bomb_guard": source,
        "destroy_suicide_bomb_event": source,
        "entity_is_local": entity_source,
        "entity_is_local_body": entity_source,
        "killed_was_player": source,
        "trigger_suicide_bomb": event_type_source,
        "arc_events_fire_enum": events_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "entity_source": "core/src/mindustry/entities/comp/EntityComp.java",
        "event_type_source": "core/src/mindustry/game/EventType.java",
        "arc_events_source": "arc-core/src/arc/Events.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_shoot_on_death_mounts_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    weapon_path = Path(upstream_root) / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = Path(upstream_root) / "core/src/mindustry/entities/units/WeaponMount.java"
    bullet_type_path = Path(upstream_root) / "core/src/mindustry/entities/bullet/BulletType.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_source = weapon_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_source = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    bullet_type_source = bullet_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "mounts_import": "@Import WeaponMount[] mounts;",
        "has_target_field": "transient boolean hasTarget;",
        "destroy_mount_loop": "for(WeaponMount mount : mounts){",
        "destroy_shoot_on_death_guard": "if(mount.weapon.shootOnDeath && !(mount.weapon.bullet.killShooter && mount.totalShots > 0)){",
        "destroy_shoot_on_death_effect_guard": "if(mount.weapon.shootOnDeathEffect != null && !hasTarget){",
        "destroy_allow_shoot_effects_false": "mount.allowShootEffects = false;",
        "destroy_shoot_on_death_effect_at": "mount.weapon.shootOnDeathEffect.at(x, y, rotation);",
        "destroy_mount_reload_zero": "mount.reload = 0f;",
        "destroy_mount_shoot_true": "mount.shoot = true;",
        "destroy_weapon_update": "mount.weapon.update(self(), mount);",
        "weapon_shoot_on_death": "public boolean shootOnDeath = false;",
        "weapon_shoot_on_death_effect": "public @Nullable Effect shootOnDeathEffect = null;",
        "weapon_mount_weapon": "public final Weapon weapon;",
        "weapon_mount_reload": "public float reload;",
        "weapon_mount_shoot": "public boolean shoot = false;",
        "weapon_mount_allow_effects": "public boolean allowShootEffects = true;",
        "weapon_mount_total_shots": "public int totalShots;",
        "bullet_type_kill_shooter": "public boolean killShooter;",
    }
    source_map = {
        "mounts_import": source,
        "has_target_field": source,
        "destroy_mount_loop": source,
        "destroy_shoot_on_death_guard": source,
        "destroy_shoot_on_death_effect_guard": source,
        "destroy_allow_shoot_effects_false": source,
        "destroy_shoot_on_death_effect_at": source,
        "destroy_mount_reload_zero": source,
        "destroy_mount_shoot_true": source,
        "destroy_weapon_update": source,
        "weapon_shoot_on_death": weapon_source,
        "weapon_shoot_on_death_effect": weapon_source,
        "weapon_mount_weapon": weapon_mount_source,
        "weapon_mount_reload": weapon_mount_source,
        "weapon_mount_shoot": weapon_mount_source,
        "weapon_mount_allow_effects": weapon_mount_source,
        "weapon_mount_total_shots": weapon_mount_source,
        "bullet_type_kill_shooter": bullet_type_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "weapon_source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": "core/src/mindustry/entities/units/WeaponMount.java",
        "bullet_type_source": "core/src/mindustry/entities/bullet/BulletType.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_crash_landing_damage_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = Path(arc_root)
    source_path = upstream_root / UNIT_COMP_SOURCE
    unit_type_path = upstream_root / UNIT_TYPE_SOURCE
    rules_path = upstream_root / RULES_SOURCE
    damage_path = upstream_root / "core/src/mindustry/entities/Damage.java"
    explosion_shield_path = upstream_root / "core/src/mindustry/world/blocks/ExplosionShield.java"
    block_flag_path = upstream_root / "core/src/mindustry/world/meta/BlockFlag.java"
    mathf_path = arc_root / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    rules_source = rules_path.read_text(encoding="utf-8", errors="replace")
    damage_source = damage_path.read_text(encoding="utf-8", errors="replace")
    explosion_shield_source = explosion_shield_path.read_text(encoding="utf-8", errors="replace")
    block_flag_source = block_flag_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "destroy_crash_landing_comment": "//if this unit crash landed (was flying), damage stuff in a radius",
        "destroy_crash_landing_guard": "if(type.flying && !spawnedByCore && type.createWreck && state.rules.unitCrashDamage(team) > 0){",
        "destroy_shield_lookup": "var shields = indexer.getEnemy(team, BlockFlag.shield);",
        "destroy_crash_damage_formula": "float crashDamage = Mathf.pow(hitSize, 0.75f) * type.crashDamageMultiplier * 2.5f * state.rules.unitCrashDamage(team);",
        "destroy_shield_absorb_guard": "if(shields.isEmpty() || !shields.contains(b -> b instanceof ExplosionShield s && s.absorbExplosion(x, y, crashDamage))){",
        "destroy_damage_call": "Damage.damage(team, x, y, Mathf.pow(hitSize, 0.94f) * 1.25f, crashDamage, true, false, true);",
        "unit_type_crash_damage_multiplier": "crashDamageMultiplier = 1f,",
        "unit_type_flying": "flying = false,",
        "unit_type_create_wreck": "createWreck = true,",
        "rules_unit_crash_damage_multiplier": "public float unitCrashDamageMultiplier = 1f;",
        "rules_unit_crash_damage": "return unitDamage(team) * unitCrashDamageMultiplier * teams.get(team).unitCrashDamageMultiplier;",
        "team_rules_unit_crash_damage_multiplier": "public float unitCrashDamageMultiplier = 1f;",
        "explosion_shield_absorb": "boolean absorbExplosion(float x, float y, float damage);",
        "block_flag_shield": "shield,",
        "damage_overload": "public static void damage(Team team, float x, float y, float radius, float damage, boolean complete, boolean air, boolean ground){",
        "mathf_pow_float": "public static float pow(float a, float b){",
    }
    source_map = {
        "destroy_crash_landing_comment": source,
        "destroy_crash_landing_guard": source,
        "destroy_shield_lookup": source,
        "destroy_crash_damage_formula": source,
        "destroy_shield_absorb_guard": source,
        "destroy_damage_call": source,
        "unit_type_crash_damage_multiplier": unit_type_source,
        "unit_type_flying": unit_type_source,
        "unit_type_create_wreck": unit_type_source,
        "rules_unit_crash_damage_multiplier": rules_source,
        "rules_unit_crash_damage": rules_source,
        "team_rules_unit_crash_damage_multiplier": rules_source,
        "explosion_shield_absorb": explosion_shield_source,
        "block_flag_shield": block_flag_source,
        "damage_overload": damage_source,
        "mathf_pow_float": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "rules_source": RULES_SOURCE,
        "damage_source": "core/src/mindustry/entities/Damage.java",
        "explosion_shield_source": "core/src/mindustry/world/blocks/ExplosionShield.java",
        "block_flag_source": "core/src/mindustry/world/meta/BlockFlag.java",
        "mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_wreck_decal_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = Path(arc_root)
    source_path = upstream_root / UNIT_COMP_SOURCE
    unit_type_path = upstream_root / UNIT_TYPE_SOURCE
    effect_path = upstream_root / EFFECT_SOURCE
    vars_path = upstream_root / VARS_SOURCE
    texture_region_path = arc_root / "arc-core/src/arc/graphics/g2d/TextureRegion.java"
    tmp_path = arc_root / ARC_TMP_SOURCE
    vec2_path = arc_root / ARC_VEC2_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    effect_source = effect_path.read_text(encoding="utf-8", errors="replace")
    vars_source = vars_path.read_text(encoding="utf-8", errors="replace")
    texture_region_source = texture_region_path.read_text(encoding="utf-8", errors="replace")
    tmp_source = tmp_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "vars_static_import": "import static mindustry.Vars.*;",
        "destroy_wreck_decal_guard": "if(!headless && type.createScorch){",
        "destroy_wreck_region_loop": "for(int i = 0; i < type.wreckRegions.length; i++){",
        "destroy_wreck_region_found_guard": "if(type.wreckRegions[i].found()){",
        "destroy_wreck_range": "float range = type.hitSize /4f;",
        "destroy_tmp_rnd": "Tmp.v1.rnd(range);",
        "destroy_decal_call": "Effect.decal(type.wreckRegions[i], x + Tmp.v1.x, y + Tmp.v1.y, rotation - 90);",
        "unit_type_hit_size": "hitSize = 6f,",
        "unit_type_create_scorch": "createScorch = true,",
        "unit_type_wreck_regions": "public TextureRegion[] wreckRegions, segmentRegions, segmentCellRegions, segmentOutlineRegions;",
        "unit_type_wreck_region_init": "wreckRegions = new TextureRegion[3];",
        "unit_type_wreck_region_load": "wreckRegions[i] = Core.atlas.find(name + \"-wreck\" + i);",
        "vars_headless": "public static boolean headless;",
        "texture_region_found": "public boolean found(){",
        "effect_decal_overload": "public static void decal(TextureRegion region, float x, float y, float rotation){",
        "tmp_v1": "public static final Vec2 v1 = new Vec2();",
        "vec2_rnd": "public Vec2 rnd(float length){",
    }
    source_map = {
        "vars_static_import": source,
        "destroy_wreck_decal_guard": source,
        "destroy_wreck_region_loop": source,
        "destroy_wreck_region_found_guard": source,
        "destroy_wreck_range": source,
        "destroy_tmp_rnd": source,
        "destroy_decal_call": source,
        "unit_type_hit_size": unit_type_source,
        "unit_type_create_scorch": unit_type_source,
        "unit_type_wreck_regions": unit_type_source,
        "unit_type_wreck_region_init": unit_type_source,
        "unit_type_wreck_region_load": unit_type_source,
        "vars_headless": vars_source,
        "texture_region_found": texture_region_source,
        "effect_decal_overload": effect_source,
        "tmp_v1": tmp_source,
        "vec2_rnd": vec2_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "effect_source": EFFECT_SOURCE,
        "vars_source": VARS_SOURCE,
        "texture_region_source": "arc-core/src/arc/graphics/g2d/TextureRegion.java",
        "tmp_source": ARC_TMP_SOURCE,
        "vec2_source": ARC_VEC2_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_ability_death_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    source_path = upstream_root / UNIT_COMP_SOURCE
    ability_path = upstream_root / ABILITY_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    ability_source = ability_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "ability_import": "import mindustry.entities.abilities.*;",
        "abilities_field": "Ability[] abilities = {};",
        "destroy_ability_loop": "for(Ability a : abilities){",
        "destroy_ability_death_call": "a.death(self());",
        "ability_death_default": "public void death(Unit unit){}",
    }
    source_map = {
        "ability_import": source,
        "abilities_field": source,
        "destroy_ability_loop": source,
        "destroy_ability_death_call": source,
        "ability_death_default": ability_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "ability_source": ABILITY_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_destroy_type_killed_remove_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    source_path = upstream_root / UNIT_COMP_SOURCE
    unit_type_path = upstream_root / UNIT_TYPE_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    destroy_start = source.index("public void destroy(){")
    destroy_end = source.index("    @Override\n    public void killed(){", destroy_start)
    destroy_source = source[destroy_start:destroy_end]
    checked = {
        "destroy_type_killed_call": "type.killed(self());",
        "destroy_remove_call": "remove();",
        "unit_type_killed_default": "public void killed(Unit unit){}",
        "unit_remove_override": "@Override\n    public void remove(){",
    }
    source_map = {
        "destroy_type_killed_call": destroy_source,
        "destroy_remove_call": destroy_source,
        "unit_type_killed_default": unit_type_source,
        "unit_remove_override": source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_killed_state_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    source_path = upstream_root / UNIT_COMP_SOURCE
    unit_type_path = upstream_root / UNIT_TYPE_SOURCE
    entity_path = upstream_root / "core/src/mindustry/entities/comp/EntityComp.java"
    sound_path = arc_root / "arc-core/src/arc/audio/Sound.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    entity_source = entity_path.read_text(encoding="utf-8", errors="replace")
    sound_source = sound_path.read_text(encoding="utf-8", errors="replace")
    killed_start = source.index("public void killed(){")
    killed_end = source.index("    @Override\n    @Replace\n    public void kill(){", killed_start)
    killed_source = source[killed_start:killed_end]
    checked = {
        "was_player_field": "private transient boolean wasPlayer;",
        "killed_method": "public void killed(){",
        "killed_was_player": "wasPlayer = isLocal();",
        "entity_is_local": "boolean isLocal(){",
        "entity_is_local_controller": "return ((Object)this) == player || ((Object)this) instanceof Unitc u && u.controller() == player;",
        "killed_health_clamp": "health = Math.min(health, 0);",
        "killed_dead_assignment": "dead = true;",
        "killed_destroy_guard": "if(!type.flying || !type.createWreck){",
        "killed_destroy_call": "destroy();",
        "killed_wreck_sound_call": "type.wreckSound.at(this, 1f, type.wreckSoundVolume);",
        "unit_type_create_wreck": "createWreck = true,",
        "unit_type_wreck_sound": "public Sound wreckSound = Sounds.unset;",
        "unit_type_wreck_sound_volume": "public float wreckSoundVolume = 1f;",
        "sound_at_position_pitch_volume": "public int at(Position pos, float pitch, float volume){",
    }
    source_map = {
        "was_player_field": source,
        "killed_method": killed_source,
        "killed_was_player": killed_source,
        "entity_is_local": entity_source,
        "entity_is_local_controller": entity_source,
        "killed_health_clamp": killed_source,
        "killed_dead_assignment": killed_source,
        "killed_destroy_guard": killed_source,
        "killed_destroy_call": killed_source,
        "killed_wreck_sound_call": killed_source,
        "unit_type_create_wreck": unit_type_source,
        "unit_type_wreck_sound": unit_type_source,
        "unit_type_wreck_sound_volume": unit_type_source,
        "sound_at_position_pitch_volume": sound_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "entity_source": "core/src/mindustry/entities/comp/EntityComp.java",
        "sound_source": "arc-core/src/arc/audio/Sound.java",
        "checked": checked,
        "missing": missing,
    }

def verify_unit_kill_sync_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    source_path = upstream_root / UNIT_COMP_SOURCE
    units_path = upstream_root / UNITS_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    units_source = units_path.read_text(encoding="utf-8", errors="replace")
    kill_start = source.index("@Replace\n    public void kill(){")
    kill_end = source.index("    @Override\n    @Replace\n    public String toString(){", kill_start)
    kill_source = source[kill_start:kill_end]
    unit_death_start = units_source.index("@Remote(called = Loc.server)\n    public static void unitDeath(int uid){")
    unit_death_end = units_source.index("    //destroys immediately", unit_death_start)
    unit_death_source = units_source[unit_death_start:unit_death_end]
    checked = {
        "kill_replace": "@Replace\n    public void kill(){",
        "kill_guard": "if(dead || net.client() || !killable()) return;",
        "kill_sync_comment": "//deaths are synced; this calls killed()",
        "kill_call": "Call.unitDeath(id);",
        "unit_killable": "public boolean killable(){",
        "unit_killable_delegate": "return type.killable(self());",
        "unit_death_remote": "@Remote(called = Loc.server)",
        "unit_death_method": "public static void unitDeath(int uid){",
        "unit_death_lookup": "Unit unit = Groups.unit.getByID(uid);",
        "unit_death_removed_entity": "netClient.addRemovedEntity(uid);",
        "unit_death_killed": "unit.killed();",
    }
    source_map = {
        "kill_replace": kill_source,
        "kill_guard": kill_source,
        "kill_sync_comment": kill_source,
        "kill_call": kill_source,
        "unit_killable": source,
        "unit_killable_delegate": source,
        "unit_death_remote": unit_death_source,
        "unit_death_method": unit_death_source,
        "unit_death_lookup": unit_death_source,
        "unit_death_removed_entity": unit_death_source,
        "unit_death_killed": unit_death_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "units_source": UNITS_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapons_setup_mounts_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    source_path = upstream_root / WEAPONS_COMP_SOURCE
    unit_type_path = upstream_root / UNIT_TYPE_SOURCE
    weapon_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / "core/src/mindustry/entities/units/WeaponMount.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    weapon_source = weapon_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_source = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "mounts_field": "@SyncLocal WeaponMount[] mounts = {};",
        "setup_method": "void setupWeapons(UnitType def){",
        "setup_array": "mounts = new WeaponMount[def.weapons.size];",
        "setup_loop": "for(int i = 0; i < mounts.length; i++){",
        "setup_mount_type_get": "mounts[i] = def.weapons.get(i).mountType.get(def.weapons.get(i));",
        "unit_type_weapons": "public Seq<Weapon> weapons = new Seq<>();",
        "weapon_mount_type": "public Func<Weapon, WeaponMount> mountType = WeaponMount::new;",
        "weapon_mount_constructor": "public WeaponMount(Weapon weapon){",
        "weapon_mount_weapon": "this.weapon = weapon;",
        "weapon_mount_base_rotation": "this.rotation = weapon.baseRotation;",
    }
    source_map = {
        "mounts_field": source,
        "setup_method": source,
        "setup_array": source,
        "setup_loop": source,
        "setup_mount_type_get": source,
        "unit_type_weapons": unit_type_source,
        "weapon_mount_type": weapon_source,
        "weapon_mount_constructor": weapon_mount_source,
        "weapon_mount_weapon": weapon_mount_source,
        "weapon_mount_base_rotation": weapon_mount_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": WEAPONS_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "weapon_source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": "core/src/mindustry/entities/units/WeaponMount.java",
        "checked": checked,
        "missing": missing,
    }

def verify_weapons_set_rotation_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    source_path = upstream_root / WEAPONS_COMP_SOURCE
    weapon_mount_path = upstream_root / "core/src/mindustry/entities/units/WeaponMount.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_source = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "mounts_field": "@SyncLocal WeaponMount[] mounts = {};",
        "set_rotation_method": "void setWeaponRotation(float rotation){",
        "set_rotation_loop": "for(WeaponMount mount : mounts){",
        "set_rotation_assignment": "mount.rotation = rotation;",
        "weapon_mount_rotation": "public float rotation;",
    }
    source_map = {
        "mounts_field": source,
        "set_rotation_method": source,
        "set_rotation_loop": source,
        "set_rotation_assignment": source,
        "weapon_mount_rotation": weapon_mount_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": WEAPONS_COMP_SOURCE,
        "weapon_mount_source": "core/src/mindustry/entities/units/WeaponMount.java",
        "checked": checked,
        "missing": missing,
    }

def verify_weapons_control_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    source_path = upstream_root / WEAPONS_COMP_SOURCE
    weapon_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / "core/src/mindustry/entities/units/WeaponMount.java"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_source = weapon_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_source = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "is_rotate_field": "@ReadOnly transient boolean isRotate;",
        "is_shooting_field": "boolean isShooting;",
        "control_single_method": "void controlWeapons(boolean rotateShoot){",
        "control_single_delegate": "controlWeapons(rotateShoot, rotateShoot);",
        "control_pair_method": "void controlWeapons(boolean rotate, boolean shoot){",
        "control_loop": "for(WeaponMount mount : mounts){",
        "control_controllable_guard": "if(mount.weapon.controllable){",
        "control_rotate_assignment": "mount.rotate = rotate;",
        "control_shoot_assignment": "mount.shoot = shoot;",
        "control_is_rotate": "isRotate = rotate;",
        "control_is_shooting": "isShooting = shoot;",
        "weapon_controllable": "public boolean controllable = true;",
        "weapon_mount_shoot": "public boolean shoot = false;",
        "weapon_mount_rotate": "public boolean rotate = false;",
    }
    source_map = {
        "is_rotate_field": source,
        "is_shooting_field": source,
        "control_single_method": source,
        "control_single_delegate": source,
        "control_pair_method": source,
        "control_loop": source,
        "control_controllable_guard": source,
        "control_rotate_assignment": source,
        "control_shoot_assignment": source,
        "control_is_rotate": source,
        "control_is_shooting": source,
        "weapon_controllable": weapon_source,
        "weapon_mount_shoot": weapon_mount_source,
        "weapon_mount_rotate": weapon_mount_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": WEAPONS_COMP_SOURCE,
        "weapon_source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": "core/src/mindustry/entities/units/WeaponMount.java",
        "checked": checked,
        "missing": missing,
    }

def verify_weapons_aim_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    source_path = upstream_root / WEAPONS_COMP_SOURCE
    unit_type_path = upstream_root / UNIT_TYPE_SOURCE
    weapon_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / "core/src/mindustry/entities/units/WeaponMount.java"
    position_path = arc_root / ARC_POSITION_SOURCE
    tmp_path = arc_root / ARC_TMP_SOURCE
    vec2_path = arc_root / ARC_VEC2_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    weapon_source = weapon_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_source = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    position_source = position_path.read_text(encoding="utf-8", errors="replace")
    tmp_source = tmp_path.read_text(encoding="utf-8", errors="replace")
    vec2_source = vec2_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "aim_position_method": "void aim(Position pos){",
        "aim_position_delegate": "aim(pos.getX(), pos.getY());",
        "aim_float_method": "void aim(float x, float y){",
        "aim_tmp_set_sub": "Tmp.v1.set(x, y).sub(this.x, this.y);",
        "aim_dst_guard": "if(Tmp.v1.len() < type.aimDst) Tmp.v1.setLength(type.aimDst);",
        "aim_x_adjust": "x = Tmp.v1.x + this.x;",
        "aim_y_adjust": "y = Tmp.v1.y + this.y;",
        "aim_loop": "for(WeaponMount mount : mounts){",
        "aim_controllable_guard": "if(mount.weapon.controllable){",
        "aim_mount_x": "mount.aimX = x;",
        "aim_mount_y": "mount.aimY = y;",
        "aim_unit_x": "aimX = x;",
        "aim_unit_y": "aimY = y;",
        "unit_type_aim_dst": "aimDst = -1f,",
        "weapon_controllable": "public boolean controllable = true;",
        "weapon_mount_aim": "public float aimX, aimY;",
        "position_get_x": "float getX();",
        "position_get_y": "float getY();",
        "tmp_v1": "public static final Vec2 v1 = new Vec2();",
        "vec2_set_length": "public Vec2 setLength(float len){",
        "vec2_set_length_zero_noop": "return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));",
    }
    source_map = {
        "aim_position_method": source,
        "aim_position_delegate": source,
        "aim_float_method": source,
        "aim_tmp_set_sub": source,
        "aim_dst_guard": source,
        "aim_x_adjust": source,
        "aim_y_adjust": source,
        "aim_loop": source,
        "aim_controllable_guard": source,
        "aim_mount_x": source,
        "aim_mount_y": source,
        "aim_unit_x": source,
        "aim_unit_y": source,
        "unit_type_aim_dst": unit_type_source,
        "weapon_controllable": weapon_source,
        "weapon_mount_aim": weapon_mount_source,
        "position_get_x": position_source,
        "position_get_y": position_source,
        "tmp_v1": tmp_source,
        "vec2_set_length": vec2_source,
        "vec2_set_length_zero_noop": vec2_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": WEAPONS_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "weapon_source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": "core/src/mindustry/entities/units/WeaponMount.java",
        "arc_position_source": ARC_POSITION_SOURCE,
        "arc_tmp_source": ARC_TMP_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapons_can_shoot_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    source_path = upstream_root / WEAPONS_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "disarmed_import": "@Import boolean disarmed;",
        "can_shoot_method": "boolean canShoot(){",
        "can_shoot_return": "return !disarmed;",
    }
    missing = []
    for snippet in checked.values():
        if snippet not in source:
            missing.append(snippet)
    return {
        "source": WEAPONS_COMP_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapons_remove_continuous_bullet_cleanup_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    weapon_source = "core/src/mindustry/type/Weapon.java"
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    bullet_comp_source = "core/src/mindustry/entities/comp/BulletComp.java"
    source_path = upstream_root / WEAPONS_COMP_SOURCE
    weapon_path = upstream_root / weapon_source
    weapon_mount_path = upstream_root / weapon_mount_source
    bullet_comp_path = upstream_root / bullet_comp_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_text = weapon_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    bullet_comp_text = bullet_comp_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "remove_override": "@Override\n    public void remove(){",
        "remove_loop": "for(WeaponMount mount : mounts){",
        "continuous_bullet_guard": "if(mount.weapon.continuous && mount.bullet != null && mount.bullet.owner == self()){",
        "bullet_time_assignment": "mount.bullet.time = mount.bullet.lifetime - 10f;",
        "bullet_clear": "mount.bullet = null;",
        "weapon_continuous": "public boolean continuous;",
        "weapon_mount_bullet": "public @Nullable Bullet bullet;",
        "bullet_owner": "@Import Entityc owner;",
        "bullet_time_lifetime": "@Import float x, y, damage, lastX, lastY, time, lifetime;",
    }
    source_map = {
        "remove_override": source,
        "remove_loop": source,
        "continuous_bullet_guard": source,
        "bullet_time_assignment": source,
        "bullet_clear": source,
        "weapon_continuous": weapon_text,
        "weapon_mount_bullet": weapon_mount_text,
        "bullet_owner": bullet_comp_text,
        "bullet_time_lifetime": bullet_comp_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": WEAPONS_COMP_SOURCE,
        "weapon_source": weapon_source,
        "weapon_mount_source": weapon_mount_source,
        "bullet_comp_source": bullet_comp_source,
        "checked": checked,
        "missing": missing,
    }

def verify_weapons_remove_sound_stop_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    sound_loop_source = "core/src/mindustry/audio/SoundLoop.java"
    source_path = upstream_root / WEAPONS_COMP_SOURCE
    weapon_mount_path = upstream_root / weapon_mount_source
    sound_loop_path = upstream_root / sound_loop_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    sound_loop_text = sound_loop_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "remove_override": "@Override\n    public void remove(){",
        "remove_loop": "for(WeaponMount mount : mounts){",
        "sound_guard": "if(mount.sound != null){",
        "sound_stop_call": "mount.sound.stop();",
        "weapon_mount_sound_comment": "/** sound loop for continuous weapons */",
        "weapon_mount_sound": "public @Nullable SoundLoop sound;",
        "sound_loop_stop_method": "public void stop(){",
        "sound_loop_id_guard": "if(id != -1){",
        "sound_loop_core_stop": "Core.audio.stop(id);",
        "sound_loop_id_reset": "id = -1;",
        "sound_loop_volume_reset": "volume = 0f;",
    }
    source_map = {
        "remove_override": source,
        "remove_loop": source,
        "sound_guard": source,
        "sound_stop_call": source,
        "weapon_mount_sound_comment": weapon_mount_text,
        "weapon_mount_sound": weapon_mount_text,
        "sound_loop_stop_method": sound_loop_text,
        "sound_loop_id_guard": sound_loop_text,
        "sound_loop_core_stop": sound_loop_text,
        "sound_loop_id_reset": sound_loop_text,
        "sound_loop_volume_reset": sound_loop_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": WEAPONS_COMP_SOURCE,
        "weapon_mount_source": weapon_mount_source,
        "sound_loop_source": sound_loop_source,
        "checked": checked,
        "missing": missing,
    }

def verify_weapons_update_dispatch_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    weapon_source = "core/src/mindustry/type/Weapon.java"
    source_path = upstream_root / WEAPONS_COMP_SOURCE
    weapon_mount_path = upstream_root / weapon_mount_source
    weapon_path = upstream_root / weapon_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    weapon_text = weapon_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "mounts_field_comment": "/** weapon mount array, never null */",
        "mounts_field": "@SyncLocal WeaponMount[] mounts = {};",
        "update_comment": "/** Update shooting and rotation for this unit. */",
        "update_override": "@Override\n    public void update(){",
        "update_loop": "for(WeaponMount mount : mounts){",
        "weapon_update_call": "mount.weapon.update(self(), mount);",
        "weapon_mount_weapon_comment": "/** weapon associated with this mount */",
        "weapon_mount_weapon": "public final Weapon weapon;",
        "weapon_update_method": "public void update(Unit unit, WeaponMount mount){",
    }
    source_map = {
        "mounts_field_comment": source,
        "mounts_field": source,
        "update_comment": source,
        "update_override": source,
        "update_loop": source,
        "weapon_update_call": source,
        "weapon_mount_weapon_comment": weapon_mount_text,
        "weapon_mount_weapon": weapon_mount_text,
        "weapon_update_method": weapon_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": WEAPONS_COMP_SOURCE,
        "weapon_mount_source": weapon_mount_source,
        "weapon_source": weapon_source,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_passive_timers_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    status_comp_source = "core/src/mindustry/entities/comp/StatusComp.java"
    shoot_pattern_source = "core/src/mindustry/entities/pattern/ShootPattern.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    unit_comp_path = upstream_root / UNIT_COMP_SOURCE
    status_comp_path = upstream_root / status_comp_source
    shoot_pattern_path = upstream_root / shoot_pattern_source
    time_path = arc_root / ARC_TIME_SOURCE
    mathf_path = arc_root / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    unit_comp_text = unit_comp_path.read_text(encoding="utf-8", errors="replace")
    status_comp_text = status_comp_path.read_text(encoding="utf-8", errors="replace")
    shoot_pattern_text = shoot_pattern_path.read_text(encoding="utf-8", errors="replace")
    time_text = time_path.read_text(encoding="utf-8", errors="replace")
    mathf_text = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "weapon_update_method": "public void update(Unit unit, WeaponMount mount){",
        "can_shoot_call": "boolean can = unit.canShoot();",
        "last_reload": "float lastReload = mount.reload;",
        "reload_decay": "mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);",
        "recoil_approach": "mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);",
        "recoils_guard": "if(recoils > 0){",
        "recoils_init": "if(mount.recoils == null) mount.recoils = new float[recoils];",
        "recoils_loop": "for(int i = 0; i < recoils; i++){",
        "recoils_approach": "mount.recoils[i] = Mathf.approachDelta(mount.recoils[i], 0, unit.reloadMultiplier / recoilTime);",
        "smooth_reload": "mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);",
        "charge_update": "mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;",
        "warmup_target": "float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;",
        "linear_warmup_guard": "if(linearWarmup){",
        "warmup_approach": "mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed);",
        "warmup_lerp": "mount.warmup = Mathf.lerpDelta(mount.warmup, warmupTarget, shootWarmupSpeed);",
        "weapon_reload_field": "public float reload = 1;",
        "weapon_recoils_field": "public int recoils = -1;",
        "weapon_recoil_time_field": "public float recoilTime = -1f;",
        "weapon_warmup_fields": "public float shootWarmupSpeed = 0.1f, smoothReloadSpeed = 0.15f;",
        "weapon_linear_warmup": "public boolean linearWarmup = false;",
        "weapon_mount_reload": "public float reload;",
        "weapon_mount_recoils": "public @Nullable float[] recoils;",
        "weapon_mount_warmup": "public float warmup;",
        "unit_can_shoot": "return !disarmed && !(type.canBoost && isFlying());",
        "status_reload_multiplier": "reloadMultiplier = 1",
        "shoot_first_delay": "public float firstShotDelay = 0;",
        "time_delta": "public static float delta = 1f;",
        "mathf_approach_delta": "public static float approachDelta(float from, float to, float speed){",
        "mathf_approach_delta_return": "return approach(from, to, Time.delta * speed);",
        "mathf_lerp_delta": "public static float lerpDelta(float fromValue, float toValue, float progress){",
        "mathf_lerp_delta_return": "return lerp(fromValue, toValue, clamp(progress * Time.delta));",
    }
    source_map = {
        "weapon_update_method": source,
        "can_shoot_call": source,
        "last_reload": source,
        "reload_decay": source,
        "recoil_approach": source,
        "recoils_guard": source,
        "recoils_init": source,
        "recoils_loop": source,
        "recoils_approach": source,
        "smooth_reload": source,
        "charge_update": source,
        "warmup_target": source,
        "linear_warmup_guard": source,
        "warmup_approach": source,
        "warmup_lerp": source,
        "weapon_reload_field": source,
        "weapon_recoils_field": source,
        "weapon_recoil_time_field": source,
        "weapon_warmup_fields": source,
        "weapon_linear_warmup": source,
        "weapon_mount_reload": weapon_mount_text,
        "weapon_mount_recoils": weapon_mount_text,
        "weapon_mount_warmup": weapon_mount_text,
        "unit_can_shoot": unit_comp_text,
        "status_reload_multiplier": status_comp_text,
        "shoot_first_delay": shoot_pattern_text,
        "time_delta": time_text,
        "mathf_approach_delta": mathf_text,
        "mathf_approach_delta_return": mathf_text,
        "mathf_lerp_delta": mathf_text,
        "mathf_lerp_delta_return": mathf_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "unit_comp_source": UNIT_COMP_SOURCE,
        "status_comp_source": status_comp_source,
        "shoot_pattern_source": shoot_pattern_source,
        "arc_time_source": ARC_TIME_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_mount_origin_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    unit_comp_path = upstream_root / UNIT_COMP_SOURCE
    angles_path = arc_root / ARC_ANGLES_SOURCE
    vec2_path = arc_root / ARC_VEC2_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_comp_text = unit_comp_path.read_text(encoding="utf-8", errors="replace")
    angles_text = angles_path.read_text(encoding="utf-8", errors="replace")
    vec2_text = vec2_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "weapon_update_method": "public void update(Unit unit, WeaponMount mount){",
        "mount_origin_block": "float\n        mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),\n        mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);",
        "weapon_mount_offsets": "public float x = 5f, y = 0f;",
        "unit_imports": "@Import float x, y, rotation, maxHealth, drag, armor, hitSize, health, shield, dragMultiplier, armorOverride, speedMultiplier;",
        "angles_trnsx_vec": "public static float trnsx(float angle, float x, float y){",
        "angles_trnsx_return": "return rv.set(x, y).rotate(angle).x;",
        "angles_trnsy_vec": "public static float trnsy(float angle, float x, float y){",
        "angles_trnsy_return": "return rv.set(x, y).rotate(angle).y;",
        "vec2_rotate_degrees": "public Vec2 rotate(float degrees){",
        "vec2_rotate_rad_call": "return rotateRad(degrees * Mathf.degreesToRadians);",
        "vec2_rotate_rad": "public Vec2 rotateRad(float radians){",
        "vec2_rotate_new_x": "float newX = this.x * cos - this.y * sin;",
        "vec2_rotate_new_y": "float newY = this.x * sin + this.y * cos;",
    }
    source_map = {
        "weapon_update_method": source,
        "mount_origin_block": source,
        "weapon_mount_offsets": source,
        "unit_imports": unit_comp_text,
        "angles_trnsx_vec": angles_text,
        "angles_trnsx_return": angles_text,
        "angles_trnsy_vec": angles_text,
        "angles_trnsy_return": angles_text,
        "vec2_rotate_degrees": vec2_text,
        "vec2_rotate_rad_call": vec2_text,
        "vec2_rotate_rad": vec2_text,
        "vec2_rotate_new_x": vec2_text,
        "vec2_rotate_new_y": vec2_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "unit_comp_source": UNIT_COMP_SOURCE,
        "arc_angles_source": ARC_ANGLES_SOURCE,
        "arc_vec2_source": ARC_VEC2_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_auto_target_retarget_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    bullet_type_source = "core/src/mindustry/entities/bullet/BulletType.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    bullet_type_path = upstream_root / bullet_type_source
    time_path = arc_root / ARC_TIME_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    bullet_type_text = bullet_type_path.read_text(encoding="utf-8", errors="replace")
    time_text = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "find_target_comment": "//find a new target",
        "auto_target_gate": "if(!controllable && autoTarget){",
        "retarget_decrement_gate": "if((mount.retarget -= Time.delta) <= 0f){",
        "find_target_call": "mount.target = findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround);",
        "retarget_assignment": "mount.retarget = mount.target == null ? targetInterval : targetSwitchInterval;",
        "weapon_controllable": "public boolean controllable = true;",
        "weapon_auto_target": "public boolean autoTarget = false;",
        "weapon_target_intervals": "public float targetInterval = 40f, targetSwitchInterval = 70f;",
        "weapon_mount_target": "public @Nullable Teamc target;",
        "weapon_mount_retarget_comment": "/** retarget counter */",
        "weapon_mount_retarget": "public float retarget = 0f;",
        "find_target_method": "protected Teamc findTarget(Unit unit, float x, float y, float range, boolean air, boolean ground){",
        "find_target_return": "return Units.closestTarget(unit.team, x, y, range + Math.abs(shootY), u -> u.checkTarget(air, ground), t -> ground && (unit.type.targetUnderBlocks || !t.block.underBullets));",
        "bullet_collision_fields": "public boolean collidesAir = true, collidesGround = true;",
        "bullet_range_field": "public float range = 0f;",
        "time_delta": "public static float delta = 1f;",
    }
    source_map = {
        "find_target_comment": source,
        "auto_target_gate": source,
        "retarget_decrement_gate": source,
        "find_target_call": source,
        "retarget_assignment": source,
        "weapon_controllable": source,
        "weapon_auto_target": source,
        "weapon_target_intervals": source,
        "weapon_mount_target": weapon_mount_text,
        "weapon_mount_retarget_comment": weapon_mount_text,
        "weapon_mount_retarget": weapon_mount_text,
        "find_target_method": source,
        "find_target_return": source,
        "bullet_collision_fields": bullet_type_text,
        "bullet_range_field": bullet_type_text,
        "time_delta": time_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "bullet_type_source": bullet_type_source,
        "arc_time_source": ARC_TIME_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_auto_target_invalidation_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    bullet_type_source = "core/src/mindustry/entities/bullet/BulletType.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    units_path = upstream_root / UNITS_SOURCE
    bullet_type_path = upstream_root / bullet_type_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    units_text = units_path.read_text(encoding="utf-8", errors="replace")
    bullet_type_text = bullet_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "auto_target_gate": "if(!controllable && autoTarget){",
        "check_target_guard": "if(mount.target != null && checkTarget(unit, mount.target, mountX, mountY, bullet.range)){",
        "target_clear": "mount.target = null;",
        "check_target_method": "protected boolean checkTarget(Unit unit, Teamc target, float x, float y, float range){",
        "check_target_return": "return Units.invalidateTarget(target, unit.team, x, y, range + Math.abs(shootY));",
        "units_invalidate_method": "public static boolean invalidateTarget(Posc target, Team team, float x, float y, float range){",
        "units_invalidate_null": "return target == null ||",
        "units_invalidate_range": "(range != Float.MAX_VALUE && !target.within(x, y, range + (target instanceof Sized hb ? hb.hitSize()/2f : 0f))) ||",
        "units_invalidate_team": "(target instanceof Teamc t && t.team() == team) ||",
        "units_invalidate_health": "(target instanceof Healthc h && !h.isValid()) ||",
        "units_invalidate_unit": "(target instanceof Unit u && !u.targetable(team));",
        "weapon_mount_target": "public @Nullable Teamc target;",
        "weapon_auto_target": "public boolean autoTarget = false;",
        "weapon_controllable": "public boolean controllable = true;",
        "weapon_shoot_offsets": "public float shootX = 0f, shootY = 3f;",
        "bullet_range_field": "public float range = 0f;",
    }
    source_map = {
        "auto_target_gate": source,
        "check_target_guard": source,
        "target_clear": source,
        "check_target_method": source,
        "check_target_return": source,
        "units_invalidate_method": units_text,
        "units_invalidate_null": units_text,
        "units_invalidate_range": units_text,
        "units_invalidate_team": units_text,
        "units_invalidate_health": units_text,
        "units_invalidate_unit": units_text,
        "weapon_mount_target": weapon_mount_text,
        "weapon_auto_target": source,
        "weapon_controllable": source,
        "weapon_shoot_offsets": source,
        "bullet_range_field": bullet_type_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "units_source": UNITS_SOURCE,
        "bullet_type_source": bullet_type_source,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_auto_target_shoot_aim_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    predict_source = "core/src/mindustry/entities/Predict.java"
    bullet_type_source = "core/src/mindustry/entities/bullet/BulletType.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    predict_path = upstream_root / predict_source
    bullet_type_path = upstream_root / bullet_type_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    predict_text = predict_path.read_text(encoding="utf-8", errors="replace")
    bullet_type_text = bullet_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "shoot_init": "boolean shoot = false;",
        "target_guard": "if(mount.target != null){",
        "shoot_assignment": "shoot = mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f)) && can;",
        "predict_guard": "if(predictTarget){",
        "predict_call": "Vec2 to = Predict.intercept(unit, mount.target, bullet);",
        "predict_aim_x": "mount.aimX = to.x;",
        "predict_aim_y": "mount.aimY = to.y;",
        "direct_aim_x": "mount.aimX = mount.target.x();",
        "direct_aim_y": "mount.aimY = mount.target.y();",
        "shoot_rotate_assignment": "mount.shoot = mount.rotate = shoot;",
        "logic_note": "//note that shooting state is not affected, as these cannot be controlled",
        "weapon_predict_target": "public boolean predictTarget = true;",
        "weapon_shoot_y": "public float shootX = 0f, shootY = 3f;",
        "weapon_mount_target": "public @Nullable Teamc target;",
        "weapon_mount_aim": "public float aimX, aimY;",
        "weapon_mount_shoot": "public boolean shoot = false;",
        "weapon_mount_rotate": "public boolean rotate = false;",
        "predict_intercept_bullet": "public static Vec2 intercept(Position src, Position dst, BulletType bullet){",
        "predict_intercept_bullet_return": "return intercept(src, dst, 0f, 0f, bullet.keepVelocity, bullet.speed);",
        "bullet_speed": "public float speed = 1f;",
        "bullet_keep_velocity": "public boolean keepVelocity = true;",
        "bullet_range": "public float range = 0f;",
    }
    source_map = {
        "shoot_init": source,
        "target_guard": source,
        "shoot_assignment": source,
        "predict_guard": source,
        "predict_call": source,
        "predict_aim_x": source,
        "predict_aim_y": source,
        "direct_aim_x": source,
        "direct_aim_y": source,
        "shoot_rotate_assignment": source,
        "logic_note": source,
        "weapon_predict_target": source,
        "weapon_shoot_y": source,
        "weapon_mount_target": weapon_mount_text,
        "weapon_mount_aim": weapon_mount_text,
        "weapon_mount_shoot": weapon_mount_text,
        "weapon_mount_rotate": weapon_mount_text,
        "predict_intercept_bullet": predict_text,
        "predict_intercept_bullet_return": predict_text,
        "bullet_speed": bullet_type_text,
        "bullet_keep_velocity": bullet_type_text,
        "bullet_range": bullet_type_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "predict_source": predict_source,
        "bullet_type_source": bullet_type_source,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_rotate_toward_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    angles_path = arc_root / ARC_ANGLES_SOURCE
    mathf_path = arc_root / ARC_MATHF_SOURCE
    time_path = arc_root / ARC_TIME_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    angles_text = angles_path.read_text(encoding="utf-8", errors="replace")
    mathf_text = mathf_path.read_text(encoding="utf-8", errors="replace")
    time_text = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "rotate_comment": "//rotate if applicable",
        "rotate_gate": "if(rotate && (mount.rotate || mount.shoot) && can){",
        "axis_x": "float axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y),",
        "axis_y": "axisY = unit.y + Angles.trnsy(unit.rotation - 90,  x, y);",
        "target_rotation": "mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;",
        "rotation_move_toward": "mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);",
        "weapon_rotate": "public boolean rotate = false;",
        "weapon_offsets": "public float x = 5f, y = 0f;",
        "weapon_rotate_speed": "public float rotateSpeed = 20f;",
        "weapon_mount_rotation": "public float rotation;",
        "weapon_mount_target_rotation": "public float targetRotation;",
        "weapon_mount_aim": "public float aimX, aimY;",
        "weapon_mount_shoot": "public boolean shoot = false;",
        "weapon_mount_rotate": "public boolean rotate = false;",
        "angles_angle": "public static float angle(float x, float y, float x2, float y2){",
        "angles_angle_body": "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;",
        "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
        "angles_move_toward_snap": "if(Math.abs(angleDist(angle, to)) < speed) return to;",
        "angles_move_toward_mod_angle": "angle = Mathf.mod(angle, 360f);",
        "angles_move_toward_mod_to": "to = Mathf.mod(to, 360f);",
        "angles_angle_dist": "public static float angleDist(float a, float b){",
        "mathf_mod": "public static float mod(float f, float n){",
        "time_delta": "public static float delta = 1f;",
    }
    source_map = {
        "rotate_comment": source,
        "rotate_gate": source,
        "axis_x": source,
        "axis_y": source,
        "target_rotation": source,
        "rotation_move_toward": source,
        "weapon_rotate": source,
        "weapon_offsets": source,
        "weapon_rotate_speed": source,
        "weapon_mount_rotation": weapon_mount_text,
        "weapon_mount_target_rotation": weapon_mount_text,
        "weapon_mount_aim": weapon_mount_text,
        "weapon_mount_shoot": weapon_mount_text,
        "weapon_mount_rotate": weapon_mount_text,
        "angles_angle": angles_text,
        "angles_angle_body": angles_text,
        "angles_move_toward": angles_text,
        "angles_move_toward_snap": angles_text,
        "angles_move_toward_mod_angle": angles_text,
        "angles_move_toward_mod_to": angles_text,
        "angles_angle_dist": angles_text,
        "mathf_mod": mathf_text,
        "time_delta": time_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "angles_source": ARC_ANGLES_SOURCE,
        "mathf_source": ARC_MATHF_SOURCE,
        "time_source": ARC_TIME_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_rotation_limit_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    angles_path = arc_root / ARC_ANGLES_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    angles_text = angles_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "rotation_limit_guard": "if(rotationLimit < 360){",
        "limit_dst": "float dst = Angles.angleDist(mount.rotation, baseRotation);",
        "limit_guard": "if(dst > rotationLimit/2f){",
        "limit_move_toward": "mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);",
        "weapon_rotation_limit": "public float rotationLimit = 361f;",
        "weapon_base_rotation": "public float baseRotation = 0f;",
        "angles_angle_dist": "public static float angleDist(float a, float b){",
        "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
    }
    source_map = {
        "rotation_limit_guard": source,
        "limit_dst": source,
        "limit_guard": source,
        "limit_move_toward": source,
        "weapon_rotation_limit": source,
        "weapon_base_rotation": source,
        "angles_angle_dist": angles_text,
        "angles_move_toward": angles_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "angles_source": ARC_ANGLES_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_non_rotate_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    position_source = "arc-core/src/arc/math/geom/Position.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    position_path = arc_root / position_source
    angles_path = arc_root / ARC_ANGLES_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    position_text = position_path.read_text(encoding="utf-8", errors="replace")
    angles_text = angles_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "non_rotate_guard": "}else if(!rotate){",
        "rotation_base": "mount.rotation = baseRotation;",
        "target_rotation_angle_to": "mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);",
        "weapon_rotate": "public boolean rotate = false;",
        "weapon_base_rotation": "public float baseRotation = 0f;",
        "weapon_mount_rotation": "public float rotation;",
        "weapon_mount_target_rotation": "public float targetRotation;",
        "weapon_mount_aim": "public float aimX, aimY;",
        "position_angle_to_float": "default float angleTo(float x, float y){",
        "position_angle_to_return": "return Angles.angle(getX(), getY(), x, y);",
        "angles_angle": "public static float angle(float x, float y, float x2, float y2){",
    }
    source_map = {
        "non_rotate_guard": source,
        "rotation_base": source,
        "target_rotation_angle_to": source,
        "weapon_rotate": source,
        "weapon_base_rotation": source,
        "weapon_mount_rotation": weapon_mount_text,
        "weapon_mount_target_rotation": weapon_mount_text,
        "weapon_mount_aim": weapon_mount_text,
        "position_angle_to_float": position_text,
        "position_angle_to_return": position_text,
        "angles_angle": angles_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "position_source": position_source,
        "angles_source": ARC_ANGLES_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_bullet_origin_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    position_source = "arc-core/src/arc/math/geom/Position.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    position_path = arc_root / position_source
    angles_path = arc_root / ARC_ANGLES_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    position_text = position_path.read_text(encoding="utf-8", errors="replace")
    angles_text = angles_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "weapon_rotation": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),",
        "bullet_x": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),",
        "bullet_y": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),",
        "shoot_angle": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY);",
        "bullet_rotation_method": "protected float bulletRotation(Unit unit, WeaponMount mount, float bulletX, float bulletY){",
        "bullet_rotation_return": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;",
        "weapon_rotate": "public boolean rotate = false;",
        "weapon_base_rotation": "public float baseRotation = 0f;",
        "weapon_shoot_offsets": "public float shootX = 0f, shootY = 3f;",
        "weapon_mount_rotation": "public float rotation;",
        "weapon_mount_aim": "public float aimX, aimY;",
        "angles_trnsx_vec": "public static float trnsx(float angle, float x, float y){",
        "angles_trnsy_vec": "public static float trnsy(float angle, float x, float y){",
        "angles_angle": "public static float angle(float x, float y, float x2, float y2){",
        "position_angle_to_float": "default float angleTo(float x, float y){",
    }
    source_map = {
        "weapon_rotation": source,
        "bullet_x": source,
        "bullet_y": source,
        "shoot_angle": source,
        "bullet_rotation_method": source,
        "bullet_rotation_return": source,
        "weapon_rotate": source,
        "weapon_base_rotation": source,
        "weapon_shoot_offsets": source,
        "weapon_mount_rotation": weapon_mount_text,
        "weapon_mount_aim": weapon_mount_text,
        "angles_trnsx_vec": angles_text,
        "angles_trnsy_vec": angles_text,
        "angles_angle": angles_text,
        "position_angle_to_float": position_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "position_source": position_source,
        "angles_source": ARC_ANGLES_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_always_shooting_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "always_shooting_assignment": "if(alwaysShooting) mount.shoot = true;",
        "weapon_always_shooting": "public boolean alwaysShooting = false;",
        "weapon_mount_shoot": "public boolean shoot = false;",
        "continuous_comment": "//update continuous state",
        "continuous_guard": "if(continuous && mount.bullet != null){",
    }
    source_map = {
        "always_shooting_assignment": source,
        "weapon_always_shooting": source,
        "weapon_mount_shoot": weapon_mount_text,
        "continuous_comment": source,
        "continuous_guard": source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_continuous_invalidation_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    bullet_comp_source = "core/src/mindustry/entities/comp/BulletComp.java"
    timed_comp_source = "core/src/mindustry/entities/comp/TimedComp.java"
    entity_comp_source = "core/src/mindustry/entities/comp/EntityComp.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    bullet_comp_path = upstream_root / bullet_comp_source
    timed_comp_path = upstream_root / timed_comp_source
    entity_comp_path = upstream_root / entity_comp_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    bullet_comp_text = bullet_comp_path.read_text(encoding="utf-8", errors="replace")
    timed_comp_text = timed_comp_path.read_text(encoding="utf-8", errors="replace")
    entity_comp_text = entity_comp_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "continuous_comment": "//update continuous state",
        "continuous_guard": "if(continuous && mount.bullet != null){",
        "continuous_invalid_condition": "if(!mount.bullet.isAdded() || mount.bullet.time >= mount.bullet.lifetime || mount.bullet.type != bullet){",
        "continuous_clear_bullet": "mount.bullet = null;",
        "weapon_continuous": "public boolean continuous;",
        "weapon_bullet": "public BulletType bullet = Bullets.placeholder;",
        "weapon_mount_bullet": "public @Nullable Bullet bullet;",
        "bullet_comp_type": "BulletType type;",
        "timed_comp_time_lifetime": "float time, lifetime;",
        "entity_comp_is_added": "boolean isAdded(){",
    }
    source_map = {
        "continuous_comment": source,
        "continuous_guard": source,
        "continuous_invalid_condition": source,
        "continuous_clear_bullet": source,
        "weapon_continuous": source,
        "weapon_bullet": source,
        "weapon_mount_bullet": weapon_mount_text,
        "bullet_comp_type": bullet_comp_text,
        "timed_comp_time_lifetime": timed_comp_text,
        "entity_comp_is_added": entity_comp_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "bullet_comp_source": bullet_comp_source,
        "timed_comp_source": timed_comp_source,
        "entity_comp_source": entity_comp_source,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_continuous_live_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    bullet_type_source = "core/src/mindustry/entities/bullet/BulletType.java"
    unit_comp_source = "core/src/mindustry/entities/comp/UnitComp.java"
    vec2_source = "arc-core/src/arc/math/geom/Vec2.java"
    time_source = "arc-core/src/arc/util/Time.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    bullet_type_path = upstream_root / bullet_type_source
    unit_comp_path = upstream_root / unit_comp_source
    vec2_path = arc_root / vec2_source
    time_path = arc_root / time_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    bullet_type_text = bullet_type_path.read_text(encoding="utf-8", errors="replace")
    unit_comp_text = unit_comp_path.read_text(encoding="utf-8", errors="replace")
    vec2_text = vec2_path.read_text(encoding="utf-8", errors="replace")
    time_text = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "continuous_else": "}else{",
        "bullet_rotation_set": "mount.bullet.rotation(weaponRotation + 90);",
        "bullet_position_set": "mount.bullet.set(bulletX, bulletY);",
        "mount_reload_set": "mount.reload = reload;",
        "mount_recoil_set": "mount.recoil = 1f;",
        "unit_vel_recoil_add": "unit.vel.add(Tmp.v1.trns(mount.bullet.rotation() + 180f, mount.bullet.type.recoil * Time.delta));",
        "sound_guard_reserved": "if(shootSound != Sounds.none && !headless){",
        "weapon_reload": "public float reload = 1;",
        "weapon_mount_reload": "public float reload;",
        "weapon_mount_recoil": "public float recoil;",
        "bullet_type_recoil": "public float recoil;",
        "unit_vel": "@Import Vec2 vel;",
        "vec2_trns_amount": "public Vec2 trns(float angle, float amount){",
        "vec2_trns_amount_body": "return set(amount, 0).rotate(angle);",
        "vec2_add": "public Vec2 add(Vec2 v){",
        "time_delta": "public static float delta = 1f;",
    }
    source_map = {
        "continuous_else": source,
        "bullet_rotation_set": source,
        "bullet_position_set": source,
        "mount_reload_set": source,
        "mount_recoil_set": source,
        "unit_vel_recoil_add": source,
        "sound_guard_reserved": source,
        "weapon_reload": source,
        "weapon_mount_reload": weapon_mount_text,
        "weapon_mount_recoil": weapon_mount_text,
        "bullet_type_recoil": bullet_type_text,
        "unit_vel": unit_comp_text,
        "vec2_trns_amount": vec2_text,
        "vec2_trns_amount_body": vec2_text,
        "vec2_add": vec2_text,
        "time_delta": time_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "bullet_type_source": bullet_type_source,
        "unit_comp_source": unit_comp_source,
        "vec2_source": vec2_source,
        "time_source": time_source,
        "checked": checked,
        "missing": missing,
    }

def verify_weapon_update_continuous_sound_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    weapon_mount_source = "core/src/mindustry/entities/units/WeaponMount.java"
    sound_loop_source = "core/src/mindustry/audio/SoundLoop.java"
    vars_source = "core/src/mindustry/Vars.java"
    source_path = upstream_root / "core/src/mindustry/type/Weapon.java"
    weapon_mount_path = upstream_root / weapon_mount_source
    sound_loop_path = upstream_root / sound_loop_source
    vars_path = upstream_root / vars_source
    source = source_path.read_text(encoding="utf-8", errors="replace")
    weapon_mount_text = weapon_mount_path.read_text(encoding="utf-8", errors="replace")
    sound_loop_text = sound_loop_path.read_text(encoding="utf-8", errors="replace")
    vars_text = vars_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "sound_guard": "if(shootSound != Sounds.none && !headless){",
        "sound_create_guard": "if(mount.sound == null) mount.sound = new SoundLoop(shootSound, 1f);",
        "sound_update_call": "mount.sound.update(bulletX, bulletY, true);",
        "laser_length_reserved": "//target length of laser",
        "weapon_shoot_sound": "public Sound shootSound = Sounds.shoot;",
        "weapon_mount_sound_comment": "/** sound loop for continuous weapons */",
        "weapon_mount_sound": "public @Nullable SoundLoop sound;",
        "sound_loop_constructor": "public SoundLoop(Sound sound, float baseVolume){",
        "sound_loop_update": "public void update(float x, float y, boolean play){",
        "sound_loop_update_delegate": "update(x, y, play, 1f);",
        "vars_headless": "public static boolean headless;",
    }
    source_map = {
        "sound_guard": source,
        "sound_create_guard": source,
        "sound_update_call": source,
        "laser_length_reserved": source,
        "weapon_shoot_sound": source,
        "weapon_mount_sound_comment": weapon_mount_text,
        "weapon_mount_sound": weapon_mount_text,
        "sound_loop_constructor": sound_loop_text,
        "sound_loop_update": sound_loop_text,
        "sound_loop_update_delegate": sound_loop_text,
        "vars_headless": vars_text,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": "core/src/mindustry/type/Weapon.java",
        "weapon_mount_source": weapon_mount_source,
        "sound_loop_source": sound_loop_source,
        "vars_source": vars_source,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_drowning_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    source_path = upstream_root / UNIT_COMP_SOURCE
    floor_path = upstream_root / FLOOR_SOURCE
    event_type_path = upstream_root / EVENT_TYPE_SOURCE
    unit_type_path = upstream_root / UNIT_TYPE_SOURCE
    mathf_path = arc_root / ARC_MATHF_SOURCE
    time_path = arc_root / ARC_TIME_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    floor_source = floor_path.read_text(encoding="utf-8", errors="replace")
    event_type_source = event_type_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    time_source = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "drown_time_field": "transient float drownTime;",
        "last_drown_floor_field": "transient @Nullable Floor lastDrownFloor;",
        "method": "public void updateDrowning(){",
        "floor_lookup": "Floor floor = drownFloor();",
        "drown_guard": "if(floor != null && floor.isLiquid && floor.drownTime > 0 && canDrown()){",
        "last_floor_set": "lastDrownFloor = floor;",
        "drown_increment": "drownTime += Time.delta / (hitSize / 8f * type.drownTimeMultiplier * floor.drownTime);",
        "chance_gate": "if(Mathf.chanceDelta(0.05f)){",
        "drown_effect_call": "floor.drownUpdateEffect.at(x, y, hitSize, floor.mapColor);",
        "kill_guard": "if(drownTime >= 0.999f && !net.client()){",
        "kill_call": "kill();",
        "event_call": "Events.fire(new UnitDrownEvent(self()));",
        "dry_decay": "drownTime -= Time.delta / 50f;",
        "clamp": "drownTime = Mathf.clamp(drownTime);",
        "floor_drown_time": "public float drownTime = 0f;",
        "floor_drown_update_effect": "public Effect drownUpdateEffect = Fx.bubble;",
        "floor_is_liquid": "public boolean isLiquid;",
        "unit_drown_event": "public static class UnitDrownEvent{",
        "unit_drown_event_unit": "public final Unit unit;",
        "unit_type_drown_multiplier": "drownTimeMultiplier = 1f,",
        "mathf_chance_delta": "public static boolean chanceDelta(double d){",
        "mathf_chance_delta_delta": "return rand.nextFloat() < d * Time.delta;",
        "mathf_clamp_unit": "public static float clamp(float value){",
        "mathf_clamp_unit_body": "return Math.max(Math.min(value, 1f), 0f);",
        "time_delta_default": "public static float delta = 1f;",
    }
    source_map = {
        "drown_time_field": source,
        "last_drown_floor_field": source,
        "method": source,
        "floor_lookup": source,
        "drown_guard": source,
        "last_floor_set": source,
        "drown_increment": source,
        "chance_gate": source,
        "drown_effect_call": source,
        "kill_guard": source,
        "kill_call": source,
        "event_call": source,
        "dry_decay": source,
        "clamp": source,
        "floor_drown_time": floor_source,
        "floor_drown_update_effect": floor_source,
        "floor_is_liquid": floor_source,
        "unit_drown_event": event_type_source,
        "unit_drown_event_unit": event_type_source,
        "unit_type_drown_multiplier": unit_type_source,
        "mathf_chance_delta": mathf_source,
        "mathf_chance_delta_delta": mathf_source,
        "mathf_clamp_unit": mathf_source,
        "mathf_clamp_unit_body": mathf_source,
        "time_delta_default": time_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "floor_source": FLOOR_SOURCE,
        "event_type_source": EVENT_TYPE_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "arc_time_source": ARC_TIME_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_type_hook_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "update_override": "@Override\n    public void update(){",
        "type_update_call": "type.update(self());",
        "unit_type_update_hook": "public void update(Unit unit){",
    }
    source_map = {
        "update_override": source,
        "type_update_call": source,
        "unit_type_update_hook": unit_type_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "unit_type_source": UNIT_TYPE_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_bounds_source(upstream_root: Path) -> dict[str, Any]:
    upstream_root = Path(upstream_root)
    arc_root = upstream_root.parent / "arc-upstream"
    source_path = upstream_root / UNIT_COMP_SOURCE
    vars_path = upstream_root / "core/src/mindustry/Vars.java"
    rules_path = upstream_root / RULES_SOURCE
    world_path = upstream_root / WORLD_SOURCE
    mathf_path = arc_root / ARC_MATHF_SOURCE
    time_path = arc_root / ARC_TIME_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    vars_source = vars_path.read_text(encoding="utf-8", errors="replace")
    rules_source = rules_path.read_text(encoding="utf-8", errors="replace")
    world_source = world_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    time_source = time_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "warp_dst": "static final float warpDst = 8f;",
        "bounded_guard": "if(type.bounded){",
        "world_bounds": "float bot = 0f, left = 0f, top = world.unitHeight(), right = world.unitWidth();",
        "limit_area_guard": "if(state.rules.limitMapArea && !team.isAI()){",
        "limit_bot": "bot = state.rules.limitY * tilesize;",
        "limit_left": "left = state.rules.limitX * tilesize;",
        "limit_top": "top = state.rules.limitHeight * tilesize + bot;",
        "limit_right": "right = state.rules.limitWidth * tilesize + left;",
        "net_local_guard": "if(!net.client() || isLocal()){",
        "dx_left": "if(x < left) dx += (-(x - left)/warpDst);",
        "dy_bot": "if(y < bot) dy += (-(y - bot)/warpDst);",
        "dx_right": "if(x > right - tilesize) dx -= (x - (right - tilesize))/warpDst;",
        "dy_top": "if(y > top - tilesize) dy -= (y - (top - tilesize))/warpDst;",
        "vel_add_net": "velAddNet(dx * Time.delta, dy * Time.delta);",
        "margin": "float margin = tilesize * 1f;",
        "margin_clamp_x": "x = Mathf.clamp(x, left - margin, right - tilesize + margin);",
        "margin_clamp_y": "y = Mathf.clamp(y, bot - margin, top - tilesize + margin);",
        "grounded_guard": "if(isGrounded()){",
        "grounded_clamp_x": "x = Mathf.clamp(x, left, right - tilesize);",
        "grounded_clamp_y": "y = Mathf.clamp(y, bot, top - tilesize);",
        "kill_guard": "if(x < -finalWorldBounds + left || y < -finalWorldBounds + bot || x >= right + finalWorldBounds || y >= top + finalWorldBounds){",
        "kill_call": "kill();",
        "tilesize": "public static final int tilesize = 8;",
        "final_world_bounds": "public static final float finalWorldBounds = 250;",
        "rules_limit_map_area": "public boolean limitMapArea = false;",
        "rules_limit_rect": "public int limitX, limitY, limitWidth = 1, limitHeight = 1;",
        "world_unit_width": "public int unitWidth(){",
        "world_unit_width_body": "return width()*tilesize;",
        "world_unit_height": "public int unitHeight(){",
        "world_unit_height_body": "return height()*tilesize;",
        "mathf_clamp_range": "public static float clamp(float value, float min, float max){",
        "mathf_clamp_range_body": "return Math.max(Math.min(value, max), min);",
        "time_delta_default": "public static float delta = 1f;",
    }
    source_map = {
        "warp_dst": source,
        "bounded_guard": source,
        "world_bounds": source,
        "limit_area_guard": source,
        "limit_bot": source,
        "limit_left": source,
        "limit_top": source,
        "limit_right": source,
        "net_local_guard": source,
        "dx_left": source,
        "dy_bot": source,
        "dx_right": source,
        "dy_top": source,
        "vel_add_net": source,
        "margin": source,
        "margin_clamp_x": source,
        "margin_clamp_y": source,
        "grounded_guard": source,
        "grounded_clamp_x": source,
        "grounded_clamp_y": source,
        "kill_guard": source,
        "kill_call": source,
        "tilesize": vars_source,
        "final_world_bounds": vars_source,
        "rules_limit_map_area": rules_source,
        "rules_limit_rect": rules_source,
        "world_unit_width": world_source,
        "world_unit_width_body": world_source,
        "world_unit_height": world_source,
        "world_unit_height_body": world_source,
        "mathf_clamp_range": mathf_source,
        "mathf_clamp_range_body": mathf_source,
        "time_delta_default": time_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "vars_source": "core/src/mindustry/Vars.java",
        "rules_source": RULES_SOURCE,
        "world_source": WORLD_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
        "arc_time_source": ARC_TIME_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_nan_health_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "nan_guard": "if(Float.isNaN(health)){",
        "health_zero": "health = 0f;",
        "kill_call": "kill();",
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

def verify_unit_update_flying_transition_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    floor_path = Path(upstream_root) / FLOOR_SOURCE
    tile_path = Path(upstream_root) / "core/src/mindustry/world/Tile.java"
    fx_path = Path(upstream_root) / FX_SOURCE
    effect_path = Path(upstream_root) / EFFECT_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    floor_source = floor_path.read_text(encoding="utf-8", errors="replace")
    tile_source = tile_path.read_text(encoding="utf-8", errors="replace")
    fx_source = fx_path.read_text(encoding="utf-8", errors="replace")
    effect_source = effect_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "floor_lookup": "Floor floor = floorOn();",
        "tile_lookup": "Tile tile = tileOn();",
        "transition_guard": "if(isFlying() != wasFlying){",
        "was_flying_guard": "if(wasFlying){",
        "tile_guard": "if(tile != null){",
        "unit_land_call": "Fx.unitLand.at(x, y, floor.isLiquid ? 1f : 0.5f, tile.getFloorColor());",
        "was_flying_assign": "wasFlying = isFlying();",
        "floor_is_liquid": "public boolean isLiquid;",
        "tile_get_floor_color": "public Color getFloorColor(){",
        "tile_get_floor_color_body": "return floor.getColor(this);",
        "fx_unit_land": "unitLand = new Effect(30, e -> {",
        "effect_at_rotation_color": "public void at(float x, float y, float rotation, Color color){",
        "effect_at_rotation_color_body": "create(x, y, rotation, color, null);",
    }
    source_map = {
        "floor_lookup": source,
        "tile_lookup": source,
        "transition_guard": source,
        "was_flying_guard": source,
        "tile_guard": source,
        "unit_land_call": source,
        "was_flying_assign": source,
        "floor_is_liquid": floor_source,
        "tile_get_floor_color": tile_source,
        "tile_get_floor_color_body": tile_source,
        "fx_unit_land": fx_source,
        "effect_at_rotation_color": effect_source,
        "effect_at_rotation_color_body": effect_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "floor_source": FLOOR_SOURCE,
        "tile_source": "core/src/mindustry/world/Tile.java",
        "fx_source": FX_SOURCE,
        "effect_source": EFFECT_SOURCE,
        "checked": checked,
        "missing": missing,
    }

def verify_unit_update_walk_effect_source(upstream_root: Path, arc_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / UNIT_COMP_SOURCE
    floor_path = Path(upstream_root) / FLOOR_SOURCE
    tile_path = Path(upstream_root) / "core/src/mindustry/world/Tile.java"
    unit_type_path = Path(upstream_root) / UNIT_TYPE_SOURCE
    hitbox_path = Path(upstream_root) / HITBOX_COMP_SOURCE
    mathf_path = Path(arc_root) / ARC_MATHF_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    floor_source = floor_path.read_text(encoding="utf-8", errors="replace")
    tile_source = tile_path.read_text(encoding="utf-8", errors="replace")
    unit_type_source = unit_type_path.read_text(encoding="utf-8", errors="replace")
    hitbox_source = hitbox_path.read_text(encoding="utf-8", errors="replace")
    mathf_source = mathf_path.read_text(encoding="utf-8", errors="replace")
    checked = {
        "walk_gate": "if(!type.hovering && isGrounded() && type.emitWalkEffect){",
        "timer_add_threshold": "if((splashTimer += Mathf.dst(deltaX(), deltaY())) >= (7f + hitSize()/8f)){",
        "walk_effect_call": "floor.walkEffect.at(x, y, hitSize() / 8f, tile != null ? tile.getFloorColor() : floor.mapColor);",
        "splash_timer_reset": "splashTimer = 0f;",
        "walk_sound_guard": "if(type.emitWalkSound){",
        "walk_sound_call": "floor.walkSound.at(x, y, Mathf.random(floor.walkSoundPitchMin, floor.walkSoundPitchMax), floor.walkSoundVolume);",
        "floor_walk_effect": "public Effect walkEffect = Fx.none;",
        "floor_walk_sound": "public Sound walkSound = Sounds.none;",
        "floor_walk_sound_params": "public float walkSoundVolume = 0.1f, walkSoundPitchMin = 0.8f, walkSoundPitchMax = 1.2f;",
        "liquid_walk_effect": "walkEffect = Fx.ripple;",
        "liquid_walk_sound": "walkSound = Sounds.stepWater;",
        "tile_get_floor_color": "public Color getFloorColor(){",
        "tile_get_floor_color_body": "return floor.getColor(this);",
        "unit_type_emit_walk_sound": "public boolean emitWalkSound = true;",
        "unit_type_emit_walk_effect": "public boolean emitWalkEffect = true;",
        "hitbox_delta_fields": "transient float lastX, lastY, deltaX, deltaY, hitSize;",
        "hitbox_delta_x_assign": "deltaX = x - lastX;",
        "hitbox_delta_y_assign": "deltaY = y - lastY;",
        "mathf_dst": "public static float dst(float x1, float y1){",
        "mathf_dst_body": "return (float)Math.sqrt(x1 * x1 + y1*y1);",
        "mathf_random_float_range": "public static float random(float start, float end){",
        "mathf_random_float_range_body": "return start + rand.nextFloat() * (end - start);",
    }
    source_map = {
        "walk_gate": source,
        "timer_add_threshold": source,
        "walk_effect_call": source,
        "splash_timer_reset": source,
        "walk_sound_guard": source,
        "walk_sound_call": source,
        "floor_walk_effect": floor_source,
        "floor_walk_sound": floor_source,
        "floor_walk_sound_params": floor_source,
        "liquid_walk_effect": floor_source,
        "liquid_walk_sound": floor_source,
        "tile_get_floor_color": tile_source,
        "tile_get_floor_color_body": tile_source,
        "unit_type_emit_walk_sound": unit_type_source,
        "unit_type_emit_walk_effect": unit_type_source,
        "hitbox_delta_fields": hitbox_source,
        "hitbox_delta_x_assign": hitbox_source,
        "hitbox_delta_y_assign": hitbox_source,
        "mathf_dst": mathf_source,
        "mathf_dst_body": mathf_source,
        "mathf_random_float_range": mathf_source,
        "mathf_random_float_range_body": mathf_source,
    }
    missing = []
    for key, snippet in checked.items():
        if snippet not in source_map[key]:
            missing.append(snippet)
    return {
        "source": UNIT_COMP_SOURCE,
        "floor_source": FLOOR_SOURCE,
        "tile_source": "core/src/mindustry/world/Tile.java",
        "unit_type_source": UNIT_TYPE_SOURCE,
        "hitbox_source": HITBOX_COMP_SOURCE,
        "arc_mathf_source": ARC_MATHF_SOURCE,
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
