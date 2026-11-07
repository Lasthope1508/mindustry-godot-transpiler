from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
CONSUME_SOURCE = "core/src/mindustry/world/consumers/ConsumeLiquids.java"
REQ_IMAGE_SOURCE = "core/src/mindustry/ui/ReqImage.java"
VARS_SOURCE = "core/src/mindustry/Vars.java"
LIQUID_MODULE_SOURCE = "core/src/mindustry/world/modules/LiquidModule.java"
LIQUID_STACK_SOURCE = "core/src/mindustry/type/LiquidStack.java"
CELL_SOURCE = "arc-core/src/arc/scene/ui/layout/Cell.java"
OWNER = "PortGame.source_consume_liquids_build_state"
PROOF = "/root/Main.source_consume_liquids_build_state"
METHOD = "build(Building build, Table table)"


def source_key(type_name: str, expression: str, rule: str, java_source: str = CONSUME_SOURCE, java_method: str = METHOD) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": java_source,
        "java_method": java_method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER.lower()],
    }


def input_alias(type_name: str, name: str) -> dict:
    return {
        "type": type_name,
        "status": "explicit-input",
        "alias_of": f"source_consume_liquids_build_input.{name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    keys = {
        "source_owner": {
            "type": "String",
            "status": "generated",
            "alias_of": OWNER.lower(),
            "used_by": [OWNER.lower()],
        },
        "source": source_key("String", CONSUME_SOURCE, "Canonical upstream source path."),
        "method": source_key("String", "public void build(Building build, Table table){", "ConsumeLiquids build method boundary."),
        "table_expr": source_key("String", "table.table(c -> {", "Nested table creation expression."),
        "i_initial_expr": source_key("String", "int i = 0;", "ReqImage row counter initialization."),
        "loop_expr": source_key("String", "for(var stack : liquids){", "Iterate configured liquid stacks."),
        "add_expr": source_key("String", "c.add(new ReqImage(stack.liquid.uiIcon,", "Add one liquid requirement image."),
        "valid_expr": source_key("String", "() -> build.liquids.get(stack.liquid) > 0)).size(Vars.iconMed).padRight(8);", "Liquid availability predicate and image sizing."),
        "row_expr": source_key("String", "if(++i % 4 == 0) c.row();", "Start a new row after four liquid images."),
        "table_left_expr": source_key("String", "}).left();", "Align the nested table to the left."),
        "req_image_constructor": source_key("String", "public ReqImage(TextureRegion region, Boolp valid){", "ReqImage constructor boundary.", REQ_IMAGE_SOURCE, "ReqImage(TextureRegion region, Boolp valid)"),
        "req_image_valid": source_key("String", "public boolean valid(){", "ReqImage validity callback boundary.", REQ_IMAGE_SOURCE, "valid()"),
        "vars_icon_med": source_key("String", "iconMed = 8*4f", "Canonical medium icon size.", VARS_SOURCE, "Vars static initialization"),
        "liquid_ids": input_alias("Array", "liquid_ids"),
        "liquid_amounts": input_alias("Array", "liquid_amounts"),
        "req_images": source_key("Array", "c.add(new ReqImage(stack.liquid.uiIcon, () -> build.liquids.get(stack.liquid) > 0)).size(Vars.iconMed).padRight(8);", "Evaluated requirement image states."),
        "row_calls": source_key("Array", "if(++i % 4 == 0) c.row();", "Evaluated row calls."),
        "table_left": source_key("bool", "}).left();", "Evaluated left alignment state."),
    }
    source_symbols.upsert_source_state_schema(
        GODOT,
        "source_consume_liquids_build_result",
        {
            "status": "active",
            "owner": OWNER,
            "runtime_proof": PROOF,
            "source_slice": "N1506",
            "rule": "Dictionary returned by the source-backed ConsumeLiquids.build state.",
            "keys": keys,
        },
    )
    for name in ("consumer_slices", "consumer_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
