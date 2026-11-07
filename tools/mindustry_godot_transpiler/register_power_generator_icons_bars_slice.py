from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerGenerator.java"


def source_key(owner: str, method: str, expression: str, type_name: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [owner.lower()],
    }


def alias(owner: str, schema_name: str, name: str, type_name: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": f"{schema_name}.{name}",
        "used_by": [owner.lower()],
    }


def register_icons() -> None:
    owner = "PortGame.source_power_generator_icons_state"
    proof = "/root/Main.source_power_generator_icons_state"
    method = "icons()"
    slice_id = "N1927"
    symbols = {
        "power_generator_icons.method": {
            "godot_owner": owner,
            "godot_symbol": "source_power_generator_icons_result.method",
            "java_expr": "public TextureRegion[] icons(){",
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerGenerator.icons method boundary.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
        },
        "power_generator_icons.drawer_final_icons": {
            "godot_owner": owner,
            "godot_symbol": "source_power_generator_icons_result.drawer_final_icons_expr",
            "java_expr": "return drawer.finalIcons(this);",
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerGenerator delegates icon production to its drawer.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
        },
    }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "exact_exprs": ["public TextureRegion[] icons(){", "return drawer.finalIcons(this);"],
        "deferred_exprs": ["Drawer texture production remains an injected runtime dependency."],
        "godot_owner": owner,
        "java_class": "mindustry.world.blocks.power.PowerGenerator",
        "java_method": method,
        "java_source": SOURCE,
        "rule": "Registers source-backed PowerGenerator.icons delegation state.",
        "runtime_proof": proof,
        "source_symbols": list(symbols),
        "status": "done",
        "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "java_source": SOURCE,
        "params": [{"name": "drawer_icons", "schema": "source_power_generator_icons_input.drawer_icons", "type": "Array"}],
        "return_keys": ["method", "drawer_final_icons_expr", "icons"],
        "rule": "Public runtime contract for PowerGenerator.icons with injected drawer result.",
        "runtime_proof": proof,
        "source_method": method,
        "source_slice": slice_id,
        "status": "source-backed",
        "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_icons_input", {
        "keys": {"drawer_icons": source_key(owner, method, "drawer.finalIcons(this)", "Array", "Injected drawer icon result.")},
        "owner": owner,
        "rule": "Inputs for PowerGenerator.icons state.",
        "runtime_proof": proof,
        "source_slice": slice_id,
        "status": "source-backed",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_icons_result", {
        "keys": {
            "method": source_key(owner, method, "public TextureRegion[] icons(){", "String", "Result method boundary."),
            "drawer_final_icons_expr": source_key(owner, method, "return drawer.finalIcons(this);", "String", "Drawer icon delegation."),
            "icons": alias(owner, "source_power_generator_icons_input", "drawer_icons", "Array"),
        },
        "owner": owner,
        "rule": "Result schema for PowerGenerator.icons state.",
        "runtime_proof": proof,
        "source_slice": slice_id,
        "status": "source-backed",
    })


def register_set_bars() -> None:
    owner = "PortGame.source_power_generator_set_bars_state"
    proof = "/root/Main.source_power_generator_set_bars_state"
    method = "setBars()"
    slice_id = "N1928"
    symbols = {
        "power_generator_set_bars.method": {
            "godot_owner": owner,
            "godot_symbol": "source_power_generator_set_bars_result.method",
            "java_expr": "public void setBars(){",
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerGenerator.setBars method boundary.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
        },
        "power_generator_set_bars.super_set_bars": {
            "godot_owner": owner,
            "godot_symbol": "source_power_generator_set_bars_result.super_set_bars_expr",
            "java_expr": "super.setBars();",
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerGenerator delegates superclass bar setup first.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
        },
        "power_generator_set_bars.guard": {
            "godot_owner": owner,
            "godot_symbol": "source_power_generator_set_bars_result.guard_expr",
            "java_expr": "if(hasPower && outputsPower){",
            "java_method": method,
            "java_source": SOURCE,
            "rule": "Power bar is registered only when the generator has and outputs power.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
        },
        "power_generator_set_bars.add_bar": {
            "godot_owner": owner,
            "godot_symbol": "source_power_generator_set_bars_result.add_bar_expr",
            "java_expr": 'addBar("power", (GeneratorBuild entity) -> new Bar(() ->',
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerGenerator registers the power output bar.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
        },
        "power_generator_set_bars.value": {
            "godot_owner": owner,
            "godot_symbol": "source_power_generator_set_bars_result.value_expr",
            "java_expr": "Strings.fixed(entity.getPowerProduction() * 60 * entity.timeScale(), 1)",
            "java_method": method,
            "java_source": SOURCE,
            "rule": "Power bar text uses the exact upstream production and time-scale expression.",
            "runtime_proof": proof,
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
        },
    }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "exact_exprs": [
            "public void setBars(){",
            "super.setBars();",
            "if(hasPower && outputsPower){",
            'addBar("power", (GeneratorBuild entity) -> new Bar(() ->',
            'Core.bundle.format("bar.poweroutput",',
            "Strings.fixed(entity.getPowerProduction() * 60 * entity.timeScale(), 1)",
            "() -> Pal.powerBar,",
            "() -> entity.productionEfficiency));",
        ],
        "deferred_exprs": ["Bar UI callbacks remain explicit runtime inputs; no Godot texture/UI implementation is guessed here."],
        "godot_owner": owner,
        "java_class": "mindustry.world.blocks.power.PowerGenerator",
        "java_method": method,
        "java_source": SOURCE,
        "rule": "Registers source-backed PowerGenerator.setBars guard and bar contract.",
        "runtime_proof": proof,
        "source_symbols": list(symbols),
        "status": "done",
        "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "java_source": SOURCE,
        "params": [
            {"name": "has_power", "schema": "source_power_generator_set_bars_input.has_power", "type": "bool"},
            {"name": "outputs_power", "schema": "source_power_generator_set_bars_input.outputs_power", "type": "bool"},
            {"name": "super_set_bars_state", "schema": "source_power_generator_set_bars_input.super_set_bars_state", "type": "Dictionary"},
            {"name": "power_production", "schema": "source_power_generator_set_bars_input.power_production", "type": "float"},
            {"name": "time_scale", "schema": "source_power_generator_set_bars_input.time_scale", "type": "float"},
            {"name": "production_efficiency", "schema": "source_power_generator_set_bars_input.production_efficiency", "type": "float"},
        ],
        "return_keys": ["method", "super_set_bars_expr", "super_set_bars_state", "guard_expr", "add_bar_expr", "format_expr", "value_expr", "color_expr", "progress_expr", "has_power", "outputs_power", "power_production", "time_scale", "production_efficiency", "add_power_bar", "power_bar"],
        "rule": "Public runtime contract for PowerGenerator.setBars with explicit UI callback inputs.",
        "runtime_proof": proof,
        "source_method": method,
        "source_slice": slice_id,
        "status": "source-backed",
        "tests": ["test_power_generator_icons_and_set_bars_match_upstream_source"],
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_set_bars_input", {
        "keys": {
            "has_power": source_key(owner, method, "hasPower", "bool", "Injected generator power availability."),
            "outputs_power": source_key(owner, method, "outputsPower", "bool", "Injected generator output capability."),
            "super_set_bars_state": source_key(owner, method, "super.setBars();", "Dictionary", "Injected superclass bar state."),
            "power_production": source_key(owner, method, "entity.getPowerProduction()", "float", "Injected generator output value."),
            "time_scale": source_key(owner, method, "entity.timeScale()", "float", "Injected build time scale."),
            "production_efficiency": source_key(owner, method, "entity.productionEfficiency", "float", "Injected build production efficiency."),
        },
        "owner": owner,
        "rule": "Explicit inputs for PowerGenerator.setBars state.",
        "runtime_proof": proof,
        "source_slice": slice_id,
        "status": "source-backed",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_power_generator_set_bars_result", {
        "keys": {
            "method": source_key(owner, method, "public void setBars(){", "String", "Result method boundary."),
            "super_set_bars_expr": source_key(owner, method, "super.setBars();", "String", "Superclass bar call."),
            "super_set_bars_state": alias(owner, "source_power_generator_set_bars_input", "super_set_bars_state", "Dictionary"),
            "guard_expr": source_key(owner, method, "if(hasPower && outputsPower){", "String", "Power bar guard."),
            "add_bar_expr": source_key(owner, method, 'addBar("power", (GeneratorBuild entity) -> new Bar(() ->', "String", "Power bar registration."),
            "format_expr": source_key(owner, method, 'Core.bundle.format("bar.poweroutput",', "String", "Power bar label formatter."),
            "value_expr": source_key(owner, method, "Strings.fixed(entity.getPowerProduction() * 60 * entity.timeScale(), 1)", "String", "Power bar output value."),
            "color_expr": source_key(owner, method, "() -> Pal.powerBar,", "String", "Power bar palette callback."),
            "progress_expr": source_key(owner, method, "() -> entity.productionEfficiency));", "String", "Power bar progress callback."),
            "has_power": alias(owner, "source_power_generator_set_bars_input", "has_power", "bool"),
            "outputs_power": alias(owner, "source_power_generator_set_bars_input", "outputs_power", "bool"),
            "power_production": alias(owner, "source_power_generator_set_bars_input", "power_production", "float"),
            "time_scale": alias(owner, "source_power_generator_set_bars_input", "time_scale", "float"),
            "production_efficiency": alias(owner, "source_power_generator_set_bars_input", "production_efficiency", "float"),
            "add_power_bar": {"type": "bool", "status": "derived", "java_source": SOURCE, "java_method": method, "java_expr": "hasPower && outputsPower", "rule": "Guard result for power bar registration.", "used_by": [owner.lower()]},
            "power_bar": {"type": "Dictionary", "status": "derived", "java_source": SOURCE, "java_method": method, "java_expr": 'addBar("power", (GeneratorBuild entity) -> new Bar(() ->', "rule": "Explicit representation of the registered bar callback.", "used_by": [owner.lower()]},
        },
        "owner": owner,
        "rule": "Result schema for PowerGenerator.setBars state.",
        "runtime_proof": proof,
        "source_slice": slice_id,
        "status": "source-backed",
    })


def main() -> None:
    register_icons()
    register_set_bars()
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
