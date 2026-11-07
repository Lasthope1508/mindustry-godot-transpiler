from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
PROOF = "/root/Main.BuildingConfigureStateModuleProof"
TESTS = ["test_building_configure_entry_slice.py", "test_emitter.py", "test_source_parity.py"]


def source_symbol(name: str, expression: str, method: str, owner: str, rule: str) -> tuple[str, dict]:
    return name, {
        "status": "source-backed",
        "godot_owner": owner,
        "godot_symbol": "source_building_configure_entry_result." + name.rsplit(".", 1)[-1],
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
    }


def input_key(type_name: str, expression: str) -> dict:
    return {
        "type": type_name,
        "status": "explicit-input",
        "java_source": SOURCE,
        "java_expr": expression,
    }


def main() -> None:
    definitions = [
        {
            "slice_id": "N1917",
            "method": "configure(Object)",
            "prefix": "building_configure_local",
            "owner": "PortGame.source_building_configure_local_state",
            "expressions": [
                "public void configure(Object value){",
                "block.lastConfig = value;",
                "Call.tileConfig(player, self(), value);",
            ],
            "rule": "Local configure persists block.lastConfig before tileConfig dispatches with the local player.",
            "params": [
                ("block_state", "Dictionary", "block.lastConfig = value;"),
                ("player_state", "Variant", "Call.tileConfig(player, self(), value);"),
                ("self_state", "Variant", "Call.tileConfig(player, self(), value);"),
                ("value", "Variant", "block.lastConfig = value;"),
                ("tile_config_callback", "Callable", "Call.tileConfig(player, self(), value);"),
            ],
            "return_key": "tile_config_called",
        },
        {
            "slice_id": "N1918",
            "method": "configureAny(Object)",
            "prefix": "building_configure_any",
            "owner": "PortGame.source_building_configure_any_state",
            "expressions": [
                "public void configureAny(Object value){",
                "Call.tileConfig(null, self(), value);",
            ],
            "rule": "Server configure dispatches tileConfig with null player and does not modify block.lastConfig.",
            "params": [
                ("self_state", "Variant", "Call.tileConfig(null, self(), value);"),
                ("value", "Variant", "Call.tileConfig(null, self(), value);"),
                ("tile_config_callback", "Callable", "Call.tileConfig(null, self(), value);"),
            ],
            "return_key": "tile_config_called",
        },
        {
            "slice_id": "N1919",
            "method": "deselect()",
            "prefix": "building_deselect",
            "owner": "PortGame.source_building_deselect_state",
            "expressions": [
                "public void deselect(){",
                "if(!headless && control.input.config.getSelected() == self()){",
                "control.input.config.hideConfig();",
            ],
            "rule": "Deselect hides config only on a non-headless client when this building is selected.",
            "params": [
                ("headless", "bool", "if(!headless && control.input.config.getSelected() == self()){"),
                ("selected_building", "Variant", "control.input.config.getSelected() == self()"),
                ("self_state", "Variant", "control.input.config.getSelected() == self()"),
                ("hide_config_callback", "Callable", "control.input.config.hideConfig();"),
            ],
            "return_key": "hide_config",
        },
        {
            "slice_id": "N1920",
            "method": "configTapped()",
            "prefix": "building_config_tapped",
            "owner": "PortGame.source_building_config_tapped_state",
            "expressions": [
                "public boolean configTapped(){",
                "return true;",
            ],
            "rule": "Base BuildingComp configTapped always permits configuration UI.",
            "params": [],
            "return_key": "config_tapped",
        },
    ]
    all_symbols: dict[str, dict] = {}
    for definition in definitions:
        expressions = definition["expressions"]
        entries = [
            source_symbol(
                definition["prefix"] + ".method",
                expressions[0],
                definition["method"],
                definition["owner"],
                definition["rule"],
            )
        ]
        entries.extend(
            source_symbol(
                definition["prefix"] + ".expr_" + str(index),
                expression,
                definition["method"],
                definition["owner"],
                definition["rule"],
            )
            for index, expression in enumerate(expressions[1:], start=1)
        )
        source_symbols.upsert_source_slice(GODOT, definition["slice_id"], {
            "status": "done",
            "java_source": SOURCE,
            "java_class": "mindustry.entities.comp.BuildingComp",
            "java_method": definition["method"],
            "godot_owner": definition["owner"],
            "exact_exprs": expressions,
            "source_symbols": [name for name, _entry in entries],
            "tests": TESTS,
            "runtime_proof": PROOF,
            "rule": definition["rule"],
        })
        input_schema = "source_" + definition["prefix"] + "_input"
        result_schema = "source_" + definition["prefix"] + "_result"
        params = [
            {"name": name, "type": type_name, "schema": input_schema + "." + name}
            for name, type_name, _expression in definition["params"]
        ]
        input_keys = {
            name: input_key(type_name, expression)
            for name, type_name, expression in definition["params"]
        }
        source_symbols.upsert_source_api_contract(GODOT, definition["owner"], {
            "status": "active",
            "source_slice": definition["slice_id"],
            "java_source": SOURCE,
            "source_method": definition["method"],
            "params": params,
            "return_keys": [definition["return_key"]],
            "tests": TESTS,
            "runtime_proof": PROOF,
            "rule": definition["rule"],
        })
        if input_keys:
            source_symbols.upsert_source_state_schema(GODOT, input_schema, {
                "status": "active",
                "owner": definition["owner"],
                "runtime_proof": PROOF,
                "keys": input_keys,
            })
        source_symbols.upsert_source_state_schema(GODOT, result_schema, {
            "status": "active",
            "owner": definition["owner"],
            "runtime_proof": PROOF,
            "keys": {
                definition["return_key"]: {
                    "type": "bool",
                    "status": "source-backed",
                    "java_source": SOURCE,
                    "java_expr": expressions[-1],
                }
            },
        })
        all_symbols.update(dict(entries))
    source_symbols.upsert_source_symbols(GODOT, all_symbols)
    schema = source_symbols.load_source_state_schema(GODOT)
    schema["schemas"].pop("source_building_config_tapped_input", None)
    errors = source_symbols.validate_source_state_schema(schema)
    if errors:
        raise ValueError("invalid source state schema: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", schema)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
