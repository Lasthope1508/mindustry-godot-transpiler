from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/type/UnitType.java"
PROOF = "/root/Main.UnitTypeCoreModuleProof"
TESTS = ["test_unit_type_stance_command_slice"]


def schema_key(type_name: str, method: str, expression: str, rule: str) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": SOURCE, "java_method": method, "java_expr": expression, "rule": rule}


def symbol(owner: str, name: str, godot_symbol: str, method: str, expression: str, rule: str) -> tuple[str, dict]:
    return name, {
        "status": "source-backed",
        "godot_owner": owner,
        "godot_symbol": godot_symbol,
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
    }


def register(slice_id: str, owner: str, method: str, expressions: list[str], symbols: list[tuple[str, dict]], params: list[dict], return_keys: list[str], schemas: dict[str, dict]) -> None:
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "status": "done", "java_source": SOURCE, "java_class": "mindustry.type.UnitType",
        "java_method": method, "godot_owner": owner, "exact_exprs": expressions,
        "source_symbols": [name for name, _entry in symbols], "tests": TESTS, "runtime_proof": PROOF,
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "status": "active", "source_slice": slice_id, "java_source": SOURCE,
        "source_method": method, "params": params, "return_keys": return_keys,
        "tests": TESTS, "runtime_proof": PROOF,
        "rule": f"Canonical UnitType runtime contract for {method}; dependencies are explicit.",
    })
    for name, entry in schemas.items():
        source_symbols.upsert_source_state_schema(GODOT, name, entry)


def main() -> None:
    source_text = (ROOT / "mindustry-upstream" / SOURCE).read_text(encoding="utf-8")
    entries: dict[str, dict] = {}
    defs = [
        (
            "N1876", "PortGame.source_unit_type_get_unit_stances_state", "UnitType.getUnitStances(Unit,Seq)",
            ["public void getUnitStances(Unit unit, Seq<UnitStance> out){", "if(!(unit.controller() instanceof CommandAI ai)) return;", "out.add(UnitStance.mineAuto);", "out.addAll(current.extraStances);"],
            [symbol("PortGame.source_unit_type_get_unit_stances_state", "unit_type_get_unit_stances.method", "source_unit_type_get_unit_stances_result.method", "UnitType.getUnitStances(Unit,Seq)", "public void getUnitStances(Unit unit, Seq<UnitStance> out){", "Method boundary."), symbol("PortGame.source_unit_type_get_unit_stances_state", "unit_type_get_unit_stances.command_guard", "source_unit_type_get_unit_stances_result.command_guard", "UnitType.getUnitStances(Unit,Seq)", "if(!(unit.controller() instanceof CommandAI ai)) return;", "CommandAI guard."), symbol("PortGame.source_unit_type_get_unit_stances_state", "unit_type_get_unit_stances.mine_auto", "source_unit_type_get_unit_stances_result.mine_auto", "UnitType.getUnitStances(Unit,Seq)", "out.add(UnitStance.mineAuto);", "Mining stance."), symbol("PortGame.source_unit_type_get_unit_stances_state", "unit_type_get_unit_stances.extra", "source_unit_type_get_unit_stances_result.extra_stances", "UnitType.getUnitStances(Unit,Seq)", "out.addAll(current.extraStances);", "Command extra stances.")],
            [{"name": "controller_is_command_ai", "type": "bool", "schema": "source_unit_type_get_unit_stances_input.controller_is_command_ai"}, {"name": "command_is_mine", "type": "bool", "schema": "source_unit_type_get_unit_stances_input.command_is_mine"}, {"name": "mine_floor", "type": "bool", "schema": "source_unit_type_get_unit_stances_input.mine_floor"}, {"name": "mine_walls", "type": "bool", "schema": "source_unit_type_get_unit_stances_input.mine_walls"}, {"name": "present_ores", "type": "Array", "schema": "source_unit_type_get_unit_stances_input.present_ores"}, {"name": "stances", "type": "Array", "schema": "source_unit_type_get_unit_stances_input.stances"}, {"name": "extra_stances", "type": "Array", "schema": "source_unit_type_get_unit_stances_input.extra_stances"}, {"name": "out", "type": "Array", "schema": "source_unit_type_get_unit_stances_input.out"}],
            ["source_owner", "source", "method", "command_guard", "mine_command_guard", "mine_auto", "extra_stances_call", "out", "returned_early", "branch"],
            {"source_unit_type_get_unit_stances_input": {"status": "active", "owner": "PortGame.source_unit_type_get_unit_stances_state", "runtime_proof": PROOF, "keys": {name: schema_key(type_name, "UnitType.getUnitStances(Unit,Seq)", name, "Explicit runtime dependency.") for name, type_name in [("controller_is_command_ai", "bool"), ("command_is_mine", "bool"), ("mine_floor", "bool"), ("mine_walls", "bool"), ("present_ores", "Array"), ("stances", "Array"), ("extra_stances", "Array"), ("out", "Array")] }}, "source_unit_type_get_unit_stances_result": {"status": "active", "owner": "PortGame.source_unit_type_get_unit_stances_state", "runtime_proof": PROOF, "keys": {"source_owner": {"type": "String", "status": "generated", "java_expr": "PortGame.source_unit_type_get_unit_stances_state", "rule": "Canonical runtime owner envelope."}, "source": {"type": "String", "status": "generated", "java_expr": "core/src/mindustry/type/UnitType.java", "rule": "Canonical upstream source envelope."}, "method": schema_key("String", "UnitType.getUnitStances(Unit,Seq)", "public void getUnitStances(Unit unit, Seq<UnitStance> out){", "Method boundary."), "command_guard": schema_key("String", "UnitType.getUnitStances(Unit,Seq)", "if(!(unit.controller() instanceof CommandAI ai)) return;", "Command controller guard."), "mine_command_guard": schema_key("String", "UnitType.getUnitStances(Unit,Seq)", "if(current == UnitCommand.mineCommand){", "Mining command branch."), "mine_auto": schema_key("String", "UnitType.getUnitStances(Unit,Seq)", "out.add(UnitStance.mineAuto);", "Mining stance."), "extra_stances_call": schema_key("String", "UnitType.getUnitStances(Unit,Seq)", "out.addAll(current.extraStances);", "Command extra stances."), "out": schema_key("Array", "UnitType.getUnitStances(Unit,Seq)", "out", "Result stance sequence."), "returned_early": schema_key("bool", "UnitType.getUnitStances(Unit,Seq)", "if(!(unit.controller() instanceof CommandAI ai)) return;", "Command controller guard."), "branch": schema_key("String", "UnitType.getUnitStances(Unit,Seq)", "current == UnitCommand.mineCommand", "Selected source branch.") }}}
        ),
        (
            "N1877", "PortGame.source_unit_type_allow_stance_state", "UnitType.allowStance(Unit,UnitStance)",
            ["public boolean allowStance(Unit unit, UnitStance stance){", "if(stance == UnitStance.stop) return true;", "getUnitStances(unit, tmpStances);", "return tmpStances.contains(stance);"],
            [symbol("PortGame.source_unit_type_allow_stance_state", "unit_type_allow_stance.method", "source_unit_type_allow_stance_result.method", "UnitType.allowStance(Unit,UnitStance)", "public boolean allowStance(Unit unit, UnitStance stance){", "Method boundary."), symbol("PortGame.source_unit_type_allow_stance_state", "unit_type_allow_stance.stop_guard", "source_unit_type_allow_stance_result.stop_guard", "UnitType.allowStance(Unit,UnitStance)", "if(stance == UnitStance.stop) return true;", "Stop stance fast path."), symbol("PortGame.source_unit_type_allow_stance_state", "unit_type_allow_stance.return", "source_unit_type_allow_stance_result.allowed", "UnitType.allowStance(Unit,UnitStance)", "return tmpStances.contains(stance);", "Canonical stance membership.")],
            [{"name": "stance", "type": "Variant", "schema": "source_unit_type_allow_stance_input.stance"}, {"name": "controller_is_command_ai", "type": "bool", "schema": "source_unit_type_allow_stance_input.controller_is_command_ai"}, {"name": "command_is_mine", "type": "bool", "schema": "source_unit_type_allow_stance_input.command_is_mine"}, {"name": "mine_floor", "type": "bool", "schema": "source_unit_type_allow_stance_input.mine_floor"}, {"name": "mine_walls", "type": "bool", "schema": "source_unit_type_allow_stance_input.mine_walls"}, {"name": "present_ores", "type": "Array", "schema": "source_unit_type_allow_stance_input.present_ores"}, {"name": "stances", "type": "Array", "schema": "source_unit_type_allow_stance_input.stances"}, {"name": "extra_stances", "type": "Array", "schema": "source_unit_type_allow_stance_input.extra_stances"}, {"name": "out", "type": "Array", "schema": "source_unit_type_allow_stance_input.out"}],
            ["source_owner", "source", "method", "stop_guard", "return_expr", "stance", "stopped", "allowed", "stances_state"],
            {"source_unit_type_allow_stance_input": {"status": "active", "owner": "PortGame.source_unit_type_allow_stance_state", "runtime_proof": PROOF, "keys": {name: schema_key(type_name, "UnitType.allowStance(Unit,UnitStance)", name, "Explicit runtime dependency.") for name, type_name in [("stance", "Variant"), ("controller_is_command_ai", "bool"), ("command_is_mine", "bool"), ("mine_floor", "bool"), ("mine_walls", "bool"), ("present_ores", "Array"), ("stances", "Array"), ("extra_stances", "Array"), ("out", "Array")] }}, "source_unit_type_allow_stance_result": {"status": "active", "owner": "PortGame.source_unit_type_allow_stance_state", "runtime_proof": PROOF, "keys": {"source_owner": {"type": "String", "status": "generated", "java_expr": "PortGame.source_unit_type_allow_stance_state", "rule": "Canonical runtime owner envelope."}, "source": {"type": "String", "status": "generated", "java_expr": "core/src/mindustry/type/UnitType.java", "rule": "Canonical upstream source envelope."}, "method": schema_key("String", "UnitType.allowStance(Unit,UnitStance)", "public boolean allowStance(Unit unit, UnitStance stance){", "Method boundary."), "stop_guard": schema_key("String", "UnitType.allowStance(Unit,UnitStance)", "if(stance == UnitStance.stop) return true;", "Stop stance fast path."), "return_expr": schema_key("String", "UnitType.allowStance(Unit,UnitStance)", "return tmpStances.contains(stance);", "Canonical stance membership."), "stance": {"type": "Variant", "status": "generated", "java_expr": "stance", "rule": "Explicit stance input propagated by canonical state."}, "stopped": {"type": "bool", "status": "generated", "java_expr": "stance == UnitStance.stop", "rule": "Canonical stop fast-path result."}, "allowed": schema_key("bool", "UnitType.allowStance(Unit,UnitStance)", "return tmpStances.contains(stance);", "Canonical result."), "stances_state": {"type": "Dictionary", "status": "generated", "java_expr": "getUnitStances(unit, tmpStances)", "rule": "Nested canonical getUnitStances state."} }}}
        ),
        (
            "N1878", "PortGame.source_unit_type_allow_command_state", "UnitType.allowCommand(Unit,UnitCommand)",
            ["public boolean allowCommand(Unit unit, UnitCommand command){", "return commands.contains(command);"],
            [symbol("PortGame.source_unit_type_allow_command_state", "unit_type_allow_command.method", "source_unit_type_allow_command_result.method", "UnitType.allowCommand(Unit,UnitCommand)", "public boolean allowCommand(Unit unit, UnitCommand command){", "Method boundary."), symbol("PortGame.source_unit_type_allow_command_state", "unit_type_allow_command.return", "source_unit_type_allow_command_result.allowed", "UnitType.allowCommand(Unit,UnitCommand)", "return commands.contains(command);", "Command membership.")],
            [{"name": "commands", "type": "Array", "schema": "source_unit_type_allow_command_input.commands"}, {"name": "command", "type": "Variant", "schema": "source_unit_type_allow_command_input.command"}],
            ["source_owner", "source", "method", "return_expr", "commands", "command", "allowed"],
            {"source_unit_type_allow_command_input": {"status": "active", "owner": "PortGame.source_unit_type_allow_command_state", "runtime_proof": PROOF, "keys": {"commands": schema_key("Array", "UnitType.allowCommand(Unit,UnitCommand)", "commands", "Explicit command sequence."), "command": schema_key("Variant", "UnitType.allowCommand(Unit,UnitCommand)", "command", "Explicit command candidate.")}}, "source_unit_type_allow_command_result": {"status": "active", "owner": "PortGame.source_unit_type_allow_command_state", "runtime_proof": PROOF, "keys": {"source_owner": {"type": "String", "status": "generated", "java_expr": "PortGame.source_unit_type_allow_command_state", "rule": "Canonical runtime owner envelope."}, "source": {"type": "String", "status": "generated", "java_expr": "core/src/mindustry/type/UnitType.java", "rule": "Canonical upstream source envelope."}, "method": schema_key("String", "UnitType.allowCommand(Unit,UnitCommand)", "public boolean allowCommand(Unit unit, UnitCommand command){", "Method boundary."), "return_expr": schema_key("String", "UnitType.allowCommand(Unit,UnitCommand)", "return commands.contains(command);", "Canonical command membership."), "commands": {"type": "Array", "status": "generated", "java_expr": "commands", "rule": "Explicit command sequence propagated by canonical state."}, "command": {"type": "Variant", "status": "generated", "java_expr": "command", "rule": "Explicit command candidate propagated by canonical state."}, "allowed": schema_key("bool", "UnitType.allowCommand(Unit,UnitCommand)", "return commands.contains(command);", "Canonical result.")}}}
        ),
    ]
    for item in defs:
        register(*item)
        entries.update(dict(item[4]))
    source_symbols.upsert_source_symbols(GODOT, entries)
    for name in ("type_slices", "type_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()

