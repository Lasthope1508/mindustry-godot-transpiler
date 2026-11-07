from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
OWNER = "PortGame.source_consume_item_efficiency_display_state"
OWNER_LOWER = OWNER.lower()
SOURCE = "core/src/mindustry/world/consumers/ConsumeItemEfficiency.java"
METHOD = "display(Stats stats)"
STAT_VALUES_SOURCE = "core/src/mindustry/world/meta/StatValues.java"
STAT_VALUES_METHOD = "itemEffMultiplier(Floatf<Item> efficiency, float timePeriod, Boolf<Item> filter, ObjectFloatMap<Item> itemDurationMultipliers)"


def source_key(type_name: str, expression: str, rule: str, source: str = SOURCE, method: str = METHOD) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": source,
        "java_method": method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER_LOWER],
    }


def input_alias(type_name: str, name: str) -> dict:
    return {
        "type": type_name,
        "status": "explicit-input",
        "alias_of": f"source_consume_item_efficiency_display_input.{name}",
        "used_by": [OWNER_LOWER],
    }


def generated_key(type_name: str, expression: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER_LOWER],
    }


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["source_consume_item_efficiency_display_result"]
    entry["keys"].update({
        "source_owner": generated_key("String", OWNER_LOWER, "Canonical PortGame owner label."),
        "source": generated_key("String", SOURCE, "Canonical upstream source path."),
        "method": source_key("String", "public void display(Stats stats){", "Display method boundary."),
        "item_duration_multipliers_field": source_key(
            "String",
            "public @Nullable ObjectFloatMap<Item> itemDurationMultipliers;",
            "Nullable duration multiplier field used by display.",
        ),
        "stats_add_expr": source_key(
            "String",
            "stats.add(booster ? Stat.booster : Stat.input, StatValues.itemEffMultiplier(this::itemEfficiencyMultiplier, stats.timePeriod, filter, itemDurationMultipliers));",
            "Stats.add expression from ConsumeItemEfficiency.display.",
        ),
        "stats_add_call": source_key("String", "stats.add", "Stats.add call marker.", SOURCE, METHOD),
        "selected_stat_expr": source_key("String", "booster ? Stat.booster : Stat.input", "Selected stat expression."),
        "item_eff_multiplier_expr": source_key(
            "String",
            "StatValues.itemEffMultiplier(this::itemEfficiencyMultiplier, stats.timePeriod, filter, itemDurationMultipliers)",
            "StatValue factory call expression.",
        ),
        "item_eff_multiplier_method": source_key(
            "String",
            "public static StatValue itemEffMultiplier(Floatf<Item> efficiency, float timePeriod, Boolf<Item> filter, @Nullable ObjectFloatMap<Item> itemDurationMultipliers){",
            "StatValues item efficiency multiplier method boundary.",
            STAT_VALUES_SOURCE,
            STAT_VALUES_METHOD,
        ),
        "table_cells_grow_expr": source_key(
            "String",
            "if(table.getCells().size > 0) table.getCells().peek().growX();",
            "Previous table spacer growth operation.",
            STAT_VALUES_SOURCE,
            STAT_VALUES_METHOD,
        ),
        "content_filter_expr": source_key(
            "String",
            "for(Item item : content.items().select(i -> filter.get(i) && i.unlockedNow() && !i.isHidden())){",
            "Filtered visible item iteration.",
            STAT_VALUES_SOURCE,
            STAT_VALUES_METHOD,
        ),
        "time_multiplier_expr": source_key(
            "String",
            "float timeMultiplier = itemDurationMultipliers == null ? 1f : itemDurationMultipliers.get(item, 1f);",
            "Nullable item duration multiplier lookup.",
            STAT_VALUES_SOURCE,
            STAT_VALUES_METHOD,
        ),
        "time_expr": source_key(
            "String",
            "float time = 1f / (timePeriod * timeMultiplier / 60f);",
            "Per-item display time formula.",
            STAT_VALUES_SOURCE,
            STAT_VALUES_METHOD,
        ),
        "efficiency_expr": source_key(
            "String",
            'b.add(Core.bundle.format("stat.efficiency", fixValue(efficiency.get(item) * 100f))).right().pad(10f).padRight(15f);',
            "Per-item efficiency display expression.",
            STAT_VALUES_SOURCE,
            STAT_VALUES_METHOD,
        ),
        "booster": input_alias("bool", "booster"),
        "stats_time_period": input_alias("float", "stats_time_period"),
        "filtered_item_ids": input_alias("Array", "filtered_item_ids"),
        "item_efficiency_multipliers": input_alias("Array", "item_efficiency_multipliers"),
        "item_duration_multipliers": input_alias("Array", "item_duration_multipliers"),
        "table_has_cells": input_alias("bool", "table_has_cells"),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_consume_item_efficiency_display_result", entry)
    for name in ("consumer_slices", "consumer_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
