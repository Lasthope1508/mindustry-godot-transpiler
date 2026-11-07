from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
METHOD = "dumpLiquid(Liquid liquid, float scaling, int outputDir) orchestration"
OWNER = "PortGame.source_building_dump_liquid_state"
SLICE = "N1900"
PROOF = "/root/Main.BuildingLiquidStateModuleProof"
TESTS = ["test_building_unit_payload_slice.py", "test_source_symbols.py"]
EXPRESSIONS = [
    "public void dumpLiquid(Liquid liquid){",
    "dumpLiquid(liquid, 2f);",
    "public void dumpLiquid(Liquid liquid, float scaling){",
    "dumpLiquid(liquid, scaling, -1);",
    "public void dumpLiquid(Liquid liquid, float scaling, int outputDir){",
    "if(liquids.get(liquid) <= 0.0001f) return;",
    "if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();",
    "for(int i = 0; i < proximity.size; i++){",
    "if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);",
]


def schema_key(type_name: str, expression: str, rule: str, status: str = "source-backed") -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": METHOD,
        "java_expr": expression,
        "rule": rule,
    }


def symbol(name: str, result_key: str, expression: str, rule: str) -> tuple[str, dict]:
    return name, {
        "status": "source-backed",
        "godot_owner": OWNER,
        "godot_symbol": f"source_building_dump_liquid_result.{result_key}",
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": METHOD,
        "java_expr": expression,
    }


def main() -> None:
    symbols = [
        symbol("building_dump_liquid.method_default", "method_default", EXPRESSIONS[0], "Default overload boundary."),
        symbol("building_dump_liquid.default_scaling", "overload_state", EXPRESSIONS[1], "Default overload supplies scaling 2f."),
        symbol("building_dump_liquid.method_scaling", "method_scaling", EXPRESSIONS[2], "Scaling overload boundary."),
        symbol("building_dump_liquid.output_dir_default", "overload_state", EXPRESSIONS[3], "Scaling overload supplies output direction -1."),
        symbol("building_dump_liquid.method_output_dir", "method_output_dir", EXPRESSIONS[4], "Full overload boundary."),
        symbol("building_dump_liquid.empty_gate", "overload_state", EXPRESSIONS[5], "Empty liquid returns before all side effects."),
        symbol("building_dump_liquid.campaign_unlock", "campaign_state", EXPRESSIONS[6], "Campaign unlock branch."),
        symbol("building_dump_liquid.routing", "routing_state", EXPRESSIONS[7], "Proximity routing executes after the campaign gate."),
        symbol("building_dump_liquid.transfer", "transfer_states_by_index", EXPRESSIONS[8], "Transfer executes sequentially for each eligible destination."),
    ]
    source_symbols.upsert_source_slice(GODOT, SLICE, {
        "status": "done",
        "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": METHOD,
        "godot_owner": OWNER,
        "exact_exprs": EXPRESSIONS,
        "source_symbols": [name for name, _entry in symbols],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Canonical composite for all BuildingComp.dumpLiquid overloads; composes the existing liquid primitives without duplicating their behavior.",
    })
    params = [
        ("liquid", "Variant"), ("scaling", "float"), ("output_dir", "int"),
        ("current_liquid_amount", "float"), ("net_client", "bool"), ("state_is_campaign", "bool"),
        ("team_is_default_team", "bool"), ("proximity_size", "int"), ("dump_cursor", "int"),
        ("rotation_value", "int"), ("relative_to_by_index", "Array"), ("destination_present_by_index", "Array"),
        ("other_has_liquids_by_index", "Array"), ("can_dump_liquid_by_index", "Array"),
        ("other_liquids_present_by_index", "Array"), ("other_liquid_amount_by_index", "Array"),
        ("other_block_liquid_capacity_by_index", "Array"), ("other_accepts_liquid_by_index", "Array"),
        ("block_liquid_capacity", "float"),
    ]
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active",
        "source_slice": SLICE,
        "java_source": SOURCE,
        "source_method": METHOD,
        "params": [{"name": name, "type": type_name, "schema": f"source_building_dump_liquid_input.{name}"} for name, type_name in params],
        "return_keys": ["source_owner", "method_default", "method_scaling", "method_output_dir", "liquid", "scaling", "output_dir", "overload_state", "campaign_state", "routing_state", "transfer_states_by_index", "current_liquid_amount_after", "other_liquid_amount_by_index_after", "unlock_called", "final_cdump"],
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Public source-backed BuildingComp.dumpLiquid overload orchestration contract.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_dump_liquid_input", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {name: schema_key(type_name, name, "Explicit generated runtime input.", "explicit-input") for name, type_name in params},
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_dump_liquid_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "source_owner": schema_key("String", EXPRESSIONS[4], "Canonical contract owner."),
            "method_default": schema_key("String", EXPRESSIONS[0], "Default overload boundary."),
            "method_scaling": schema_key("String", EXPRESSIONS[2], "Scaling overload boundary."),
            "method_output_dir": schema_key("String", EXPRESSIONS[4], "Full overload boundary."),
            "liquid": {"type": "Variant", "status": "generated", "alias_of": "source_building_dump_liquid_input.liquid"},
            "scaling": {"type": "float", "status": "generated", "alias_of": "source_building_dump_liquid_input.scaling"},
            "output_dir": {"type": "int", "status": "generated", "alias_of": "source_building_dump_liquid_input.output_dir"},
            "overload_state": schema_key("Dictionary", EXPRESSIONS[5], "Overload and empty-liquid gate result."),
            "campaign_state": schema_key("Dictionary", EXPRESSIONS[6], "Campaign unlock result."),
            "routing_state": schema_key("Dictionary", EXPRESSIONS[7], "Proximity routing result."),
            "transfer_states_by_index": schema_key("Dictionary", EXPRESSIONS[8], "Sequential transfer results."),
            "current_liquid_amount_after": schema_key("float", EXPRESSIONS[8], "Liquid amount after sequential transfers."),
            "other_liquid_amount_by_index_after": schema_key("Array", EXPRESSIONS[8], "Destination amounts after sequential transfers."),
            "unlock_called": schema_key("bool", EXPRESSIONS[6], "Campaign unlock effect."),
            "final_cdump": schema_key("int", EXPRESSIONS[7], "Dump cursor after proximity iteration."),
        },
    })
    source_symbols.upsert_source_symbols(GODOT, dict(symbols))
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
