from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
PROOF = "/root/Main.BuildingAccessStateModuleProof"
VERSION_PROOF = "/root/Main.BuildingVersionModuleProof"
TESTS = ["test_building_access_slice.py", "test_building_update_access_slice.py"]


def schema_key(type_name: str, status: str, method: str, expr: str, rule: str) -> dict:
    return {"type": type_name, "status": status, "java_source": SOURCE, "java_method": method, "java_expr": expr, "rule": rule}


def symbol(owner: str, name: str, godot_symbol: str, method: str, expression: str, rule: str, status: str = "source-backed") -> tuple[str, dict]:
    return name, {"status": status, "godot_owner": owner, "godot_symbol": godot_symbol, "rule": rule, "tests": TESTS, "runtime_proof": PROOF, "java_source": SOURCE, "java_method": method, "java_expr": expression}


def predicate_definition(slice_id: str, predicate: str, method: str, return_expr: str, params: list[tuple[str, str, str]]) -> dict:
    owner = f"PortGame.source_building_{predicate}_state"
    prefix = f"building_{predicate}"
    input_name = f"source_building_{predicate}_input"
    result_name = f"source_building_{predicate}_result"
    input_keys = {name: schema_key(type_name, "explicit-input", method, expr, "Explicit BuildingComp dependency input.") for name, type_name, expr in params}
    result_keys = {
        "method": schema_key("String", "source-backed", method, method, "Method boundary."),
        predicate: schema_key("bool", "source-backed", method, return_expr, "Canonical predicate result."),
    }
    if predicate == "consume_trigger_valid":
        comment = '/** @return whether this building is currently "burning" a trigger consumer (an item) - if true, valid() on those will return true. */'
        result_keys["comment"] = schema_key("String", "source-backed", "consumeTriggerValid()", comment, "Consume trigger valid source comment.")
    symbols = [
        symbol(owner, f"{prefix}.method", f"{result_name}.method", method, method, "BuildingComp predicate method boundary."),
        symbol(owner, f"{prefix}.return", f"{result_name}.{predicate}", method, return_expr, "Canonical BuildingComp predicate result."),
    ]
    for name, _type_name, expr in params:
        symbols.append(symbol(owner, f"{prefix}.{name}", f"{input_name}.{name}", method, expr, "Explicit BuildingComp dependency input.", "explicit-input"))
    schemas = {
        result_name: {"status": "active", "owner": owner, "runtime_proof": PROOF, "keys": result_keys},
    }
    if input_keys:
        schemas[input_name] = {"status": "active", "owner": owner, "runtime_proof": PROOF, "keys": input_keys}
    return {
        "slice": slice_id,
        "owner": owner,
        "method": method,
        "expressions": [method, return_expr] + ([result_keys["comment"]["java_expr"]] if "comment" in result_keys else []),
        "symbols": symbols,
        "params": [{"name": name, "type": type_name, "schema": f"{input_name}.{name}"} for name, type_name, _expr in params],
        "return_keys": [predicate],
        "schemas": schemas,
    }


def main() -> None:
    # N1896/N1897 supersede the older N647/N626 registrations for these
    # predicates. Remove the legacy ownership before rebuilding the shards so
    # the component catalog has one canonical registration per behavior.
    ledger = source_symbols.load_source_slice_ledger(GODOT)
    ledger.get("slices", {}).pop("N626", None)
    ledger.get("slices", {}).pop("N647", None)
    source_ssot.write_json(GODOT, "slice_ledger", ledger)

    registry = source_symbols.load_source_symbol_registry(GODOT)
    for legacy_symbol in (
        "building_production_valid.default_return",
        "building_production_valid.production_valid",
        "building_should_consume.return_enabled",
        "building_should_consume.enabled_state",
    ):
        registry.get("symbols", {}).pop(legacy_symbol, None)
    source_ssot.write_json(GODOT, "registry", registry)

    definitions = [
        {
            "slice": "N1883",
            "owner": "PortGame.source_building_floor_state",
            "method": "floor()",
            "expressions": ["public Floor floor(){", "return tile.floor();"],
            "symbols": [
                symbol("PortGame.source_building_floor_state", "building_floor.method", "source_building_floor_result.method", "floor()", "public Floor floor(){", "BuildingComp floor method boundary."),
                symbol("PortGame.source_building_floor_state", "building_floor.return", "source_building_floor_result.floor", "floor()", "return tile.floor();", "Canonical tile.floor delegation."),
                symbol("PortGame.source_building_floor_state", "building_floor.floor_value", "source_building_floor_input.floor_value", "floor()", "tile.floor()", "Explicit tile.floor dependency input.", "explicit-input"),
            ],
            "params": [{"name": "floor_value", "type": "Variant", "schema": "source_building_floor_input.floor_value"}],
            "return_keys": ["floor"],
            "schemas": {
                "source_building_floor_input": {"status": "active", "owner": "PortGame.source_building_floor_state", "runtime_proof": PROOF, "keys": {"floor_value": schema_key("Variant", "explicit-input", "floor()", "tile.floor()", "Explicit tile.floor result.")}},
                "source_building_floor_result": {"status": "active", "owner": "PortGame.source_building_floor_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "floor()", "public Floor floor(){", "Method boundary."), "floor": schema_key("Variant", "source-backed", "floor()", "return tile.floor();", "Returned floor reference.")}},
            },
        },
        {
            "slice": "N1884",
            "owner": "PortGame.source_building_interactable_state",
            "method": "interactable(Team)",
            "expressions": ["public boolean interactable(Team team){", "return state.teams.canInteract(team, team());"],
            "symbols": [
                symbol("PortGame.source_building_interactable_state", "building_interactable.method", "source_building_interactable_result.method", "interactable(Team)", "public boolean interactable(Team team){", "BuildingComp interactability method boundary."),
                symbol("PortGame.source_building_interactable_state", "building_interactable.return", "source_building_interactable_result.interactable", "interactable(Team)", "return state.teams.canInteract(team, team());", "Canonical teams capability delegation."),
                symbol("PortGame.source_building_interactable_state", "building_interactable.can_interact", "source_building_interactable_input.can_interact", "interactable(Team)", "state.teams.canInteract(team, team())", "Explicit Teams.canInteract dependency input.", "explicit-input"),
            ],
            "params": [{"name": "can_interact", "type": "bool", "schema": "source_building_interactable_input.can_interact"}],
            "return_keys": ["interactable"],
            "schemas": {
                "source_building_interactable_input": {"status": "active", "owner": "PortGame.source_building_interactable_state", "runtime_proof": PROOF, "keys": {"can_interact": schema_key("bool", "explicit-input", "interactable(Team)", "state.teams.canInteract(team, team())", "Explicit Teams.canInteract result.")}},
                "source_building_interactable_result": {"status": "active", "owner": "PortGame.source_building_interactable_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "interactable(Team)", "public boolean interactable(Team team){", "Method boundary."), "interactable": schema_key("bool", "source-backed", "interactable(Team)", "return state.teams.canInteract(team, team());", "Returned interaction capability.")}},
            },
        },
        {
            "slice": "N1885",
            "owner": "PortGame.source_building_version_state",
            "proof": VERSION_PROOF,
            "method": "version()",
            "expressions": ["public byte version(){", "return 0;"],
            "symbols": [
                symbol("PortGame.source_building_version_state", "building_version.method", "source_building_version_result.method", "version()", "public byte version(){", "BuildingComp serialization version method boundary."),
                symbol("PortGame.source_building_version_state", "building_version.return", "source_building_version_result.version", "version()", "return 0;", "Canonical BuildingComp serialization version."),
            ],
            "params": [],
            "return_keys": ["source_owner", "source", "method", "return_expr", "version"],
            "schemas": {
                "source_building_version_result": {"status": "active", "owner": "PortGame.source_building_version_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "version()", "public byte version(){", "Method boundary."), "return_expr": schema_key("String", "source-backed", "version()", "return 0;", "Canonical return expression."), "version": schema_key("int", "source-backed", "version()", "return 0;", "Serialization version value.")}},
            },
        },
        {
            "slice": "N1886",
            "owner": "PortGame.source_building_allow_update_state",
            "proof": PROOF,
            "method": "allowUpdate()",
            "expressions": [
                "public boolean allowUpdate(){",
                "return team != Team.derelict && block.supportsEnv(state.rules.env)",
                "Rect.contains(state.rules.limitX, state.rules.limitY, state.rules.limitWidth, state.rules.limitHeight, tile.x, tile.y)",
            ],
            "symbols": [
                symbol("PortGame.source_building_allow_update_state", "building_allow_update.method", "source_building_allow_update_result.method", "allowUpdate()", "public boolean allowUpdate(){", "BuildingComp allow-update method boundary."),
                symbol("PortGame.source_building_allow_update_state", "building_allow_update.return", "source_building_allow_update_result.allow_update", "allowUpdate()", "return team != Team.derelict && block.supportsEnv(state.rules.env)", "Canonical team/environment/map predicate."),
            ],
            "params": [
                {"name": "team_is_derelict", "type": "bool", "schema": "source_building_allow_update_input.team_is_derelict"},
                {"name": "block_supports_env", "type": "bool", "schema": "source_building_allow_update_input.block_supports_env"},
                {"name": "editor_tile", "type": "bool", "schema": "source_building_allow_update_input.editor_tile"},
                {"name": "block_privileged", "type": "bool", "schema": "source_building_allow_update_input.block_privileged"},
                {"name": "limit_map_area", "type": "bool", "schema": "source_building_allow_update_input.limit_map_area"},
                {"name": "disable_outside_area", "type": "bool", "schema": "source_building_allow_update_input.disable_outside_area"},
                {"name": "tile_x", "type": "int", "schema": "source_building_allow_update_input.tile_x"},
                {"name": "tile_y", "type": "int", "schema": "source_building_allow_update_input.tile_y"},
                {"name": "limit_x", "type": "int", "schema": "source_building_allow_update_input.limit_x"},
                {"name": "limit_y", "type": "int", "schema": "source_building_allow_update_input.limit_y"},
                {"name": "limit_width", "type": "int", "schema": "source_building_allow_update_input.limit_width"},
                {"name": "limit_height", "type": "int", "schema": "source_building_allow_update_input.limit_height"},
            ],
            "return_keys": ["allow_update"],
            "schemas": {
                "source_building_allow_update_input": {"status": "active", "owner": "PortGame.source_building_allow_update_state", "runtime_proof": PROOF, "keys": {key: schema_key(type_name, "explicit-input", "allowUpdate()", expr, "Explicit BuildingComp dependency input.") for key, type_name, expr in [("team_is_derelict", "bool", "team == Team.derelict"), ("block_supports_env", "bool", "block.supportsEnv(state.rules.env)"), ("editor_tile", "bool", "tile instanceof EditorTile"), ("block_privileged", "bool", "block.privileged"), ("limit_map_area", "bool", "state.rules.limitMapArea"), ("disable_outside_area", "bool", "state.rules.disableOutsideArea"), ("tile_x", "int", "tile.x"), ("tile_y", "int", "tile.y"), ("limit_x", "int", "state.rules.limitX"), ("limit_y", "int", "state.rules.limitY"), ("limit_width", "int", "state.rules.limitWidth"), ("limit_height", "int", "state.rules.limitHeight")]}},
                "source_building_allow_update_result": {"status": "active", "owner": "PortGame.source_building_allow_update_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "allowUpdate()", "public boolean allowUpdate(){", "Method boundary."), "allow_update": schema_key("bool", "source-backed", "allowUpdate()", "return team != Team.derelict && block.supportsEnv(state.rules.env)", "Canonical result.")}},
            },
        },
        {
            "slice": "N1887",
            "owner": "PortGame.source_building_in_map_area_state",
            "proof": PROOF,
            "method": "inMapArea()",
            "expressions": [
                "public boolean inMapArea(){",
                "return !state.rules.limitMapArea || Rect.contains(state.rules.limitX * tilesize, state.rules.limitY * tilesize, state.rules.limitWidth * tilesize, state.rules.limitHeight * tilesize, x, y);",
            ],
            "symbols": [
                symbol("PortGame.source_building_in_map_area_state", "building_in_map_area.method", "source_building_in_map_area_result.method", "inMapArea()", "public boolean inMapArea(){", "BuildingComp map-area method boundary."),
                symbol("PortGame.source_building_in_map_area_state", "building_in_map_area.return", "source_building_in_map_area_result.in_map_area", "inMapArea()", "return !state.rules.limitMapArea || Rect.contains(state.rules.limitX * tilesize, state.rules.limitY * tilesize, state.rules.limitWidth * tilesize, state.rules.limitHeight * tilesize, x, y);", "Canonical world-coordinate map predicate."),
            ],
            "params": [
                {"name": "limit_map_area", "type": "bool", "schema": "source_building_in_map_area_input.limit_map_area"},
                {"name": "limit_x", "type": "float", "schema": "source_building_in_map_area_input.limit_x"},
                {"name": "limit_y", "type": "float", "schema": "source_building_in_map_area_input.limit_y"},
                {"name": "limit_width", "type": "float", "schema": "source_building_in_map_area_input.limit_width"},
                {"name": "limit_height", "type": "float", "schema": "source_building_in_map_area_input.limit_height"},
                {"name": "source_x", "type": "float", "schema": "source_building_in_map_area_input.source_x"},
                {"name": "source_y", "type": "float", "schema": "source_building_in_map_area_input.source_y"},
                {"name": "tile_size", "type": "float", "schema": "source_building_in_map_area_input.tile_size"},
            ],
            "return_keys": ["in_map_area"],
            "schemas": {
                "source_building_in_map_area_input": {"status": "active", "owner": "PortGame.source_building_in_map_area_state", "runtime_proof": PROOF, "keys": {key: schema_key(type_name, "explicit-input", "inMapArea()", expr, "Explicit BuildingComp map-area dependency input.") for key, type_name, expr in [("limit_map_area", "bool", "state.rules.limitMapArea"), ("limit_x", "float", "state.rules.limitX"), ("limit_y", "float", "state.rules.limitY"), ("limit_width", "float", "state.rules.limitWidth"), ("limit_height", "float", "state.rules.limitHeight"), ("source_x", "float", "x"), ("source_y", "float", "y"), ("tile_size", "float", "tilesize")]}},
                "source_building_in_map_area_result": {"status": "active", "owner": "PortGame.source_building_in_map_area_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "inMapArea()", "public boolean inMapArea(){", "Method boundary."), "in_map_area": schema_key("bool", "source-backed", "inMapArea()", "return !state.rules.limitMapArea || Rect.contains(state.rules.limitX * tilesize, state.rules.limitY * tilesize, state.rules.limitWidth * tilesize, state.rules.limitHeight * tilesize, x, y);", "Canonical result.")}},
            },
        },
        {
            "slice": "N1888",
            "owner": "PortGame.source_building_status_state",
            "method": "status()",
            "expressions": [
                "public BlockStatus status(){",
                "return BlockStatus.logicDisable;",
                "return BlockStatus.noOutput;",
                "return BlockStatus.noInput;",
                "return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;",
            ],
            "symbols": [
                symbol("PortGame.source_building_status_state", "building_status.method", "source_building_status_result.method", "status()", "public BlockStatus status(){", "BuildingComp status method boundary."),
                symbol("PortGame.source_building_status_state", "building_status.logic_disable", "source_building_status_result.status", "status()", "return BlockStatus.logicDisable;", "Disabled logic status branch."),
                symbol("PortGame.source_building_status_state", "building_status.no_output", "source_building_status_result.status", "status()", "return BlockStatus.noOutput;", "Non-consuming no-output status branch."),
                symbol("PortGame.source_building_status_state", "building_status.no_input", "source_building_status_result.status", "status()", "return BlockStatus.noInput;", "Invalid production no-input status branch."),
                symbol("PortGame.source_building_status_state", "building_status.active_expr", "source_building_status_result.status", "status()", "return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;", "Tick-gated active/no-input branch."),
            ],
            "params": [
                {"name": "enabled", "type": "bool", "schema": "source_building_status_input.enabled"},
                {"name": "should_consume", "type": "bool", "schema": "source_building_status_input.should_consume"},
                {"name": "efficiency", "type": "float", "schema": "source_building_status_input.efficiency"},
                {"name": "production_valid", "type": "bool", "schema": "source_building_status_input.production_valid"},
                {"name": "state_tick", "type": "float", "schema": "source_building_status_input.state_tick"},
            ],
            "return_keys": ["status"],
            "schemas": {
                "source_building_status_input": {"status": "active", "owner": "PortGame.source_building_status_state", "runtime_proof": PROOF, "keys": {key: schema_key(type_name, "explicit-input", "status()", expr, "Explicit BuildingComp status dependency input.") for key, type_name, expr in [("enabled", "bool", "enabled"), ("should_consume", "bool", "shouldConsume()"), ("efficiency", "float", "efficiency"), ("production_valid", "bool", "productionValid()"), ("state_tick", "float", "state.tick")] }},
                "source_building_status_result": {"status": "active", "owner": "PortGame.source_building_status_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "status()", "public BlockStatus status(){", "Method boundary."), "status": schema_key("String", "source-backed", "status()", "return BlockStatus.active;", "Canonical BlockStatus enum name selected by source branches.")}},
            },
        },
        {
            "slice": "N1889",
            "owner": "PortGame.source_building_sleep_state",
            "method": "sleep()",
            "expressions": ["public void sleep(){", "sleepTime += Time.delta;", "if(!sleeping && sleepTime >= timeToSleep){", "remove();", "sleeping = true;", "sleepingEntities++;"],
            "symbols": [
                symbol("PortGame.source_building_sleep_state", "building_sleep.method", "source_building_sleep_result.method", "sleep()", "public void sleep(){", "BuildingComp sleep method boundary."),
                symbol("PortGame.source_building_sleep_state", "building_sleep.time_increment", "source_building_sleep_result.sleep_time_after", "sleep()", "sleepTime += Time.delta;", "Sleep timer increment."),
                symbol("PortGame.source_building_sleep_state", "building_sleep.remove", "source_building_sleep_result.remove_called", "sleep()", "remove();", "Sleep threshold removal side effect."),
                symbol("PortGame.source_building_sleep_state", "building_sleep.entity_increment", "source_building_sleep_result.sleeping_entities_after", "sleep()", "sleepingEntities++;", "Sleeping entity count increment."),
            ],
            "params": [{"name": "sleep_time", "type": "float", "schema": "source_building_sleep_input.sleep_time"}, {"name": "time_delta", "type": "float", "schema": "source_building_sleep_input.time_delta"}, {"name": "sleeping", "type": "bool", "schema": "source_building_sleep_input.sleeping"}, {"name": "sleeping_entities", "type": "int", "schema": "source_building_sleep_input.sleeping_entities"}, {"name": "time_to_sleep", "type": "float", "schema": "source_building_sleep_input.time_to_sleep"}],
            "return_keys": ["sleep_time_after", "sleeping_after", "sleeping_entities_after", "remove_called"],
            "schemas": {
                "source_building_sleep_input": {"status": "active", "owner": "PortGame.source_building_sleep_state", "runtime_proof": PROOF, "keys": {key: schema_key(type_name, "explicit-input", "sleep()", expr, "Explicit BuildingComp sleep dependency input.") for key, type_name, expr in [("sleep_time", "float", "sleepTime"), ("time_delta", "float", "Time.delta"), ("sleeping", "bool", "sleeping"), ("sleeping_entities", "int", "sleepingEntities"), ("time_to_sleep", "float", "timeToSleep")] }},
                "source_building_sleep_result": {"status": "active", "owner": "PortGame.source_building_sleep_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "sleep()", "public void sleep(){", "Method boundary."), "sleep_time_after": schema_key("float", "source-backed", "sleep()", "sleepTime += Time.delta;", "Updated sleep timer."), "remove_called": schema_key("bool", "source-backed", "sleep()", "remove();", "Threshold removal side effect.")}},
            },
        },
        {
            "slice": "N1890",
            "owner": "PortGame.source_building_no_sleep_state",
            "method": "noSleep()",
            "expressions": ["public void noSleep(){", "sleepTime = 0f;", "if(sleeping){", "add();", "sleeping = false;", "sleepingEntities--;"],
            "symbols": [
                symbol("PortGame.source_building_no_sleep_state", "building_no_sleep.method", "source_building_no_sleep_result.method", "noSleep()", "public void noSleep(){", "BuildingComp noSleep method boundary."),
                symbol("PortGame.source_building_no_sleep_state", "building_no_sleep.reset", "source_building_no_sleep_result.sleep_time", "noSleep()", "sleepTime = 0f;", "Sleep timer reset."),
                symbol("PortGame.source_building_no_sleep_state", "building_no_sleep.add", "source_building_no_sleep_result.add_called", "noSleep()", "add();", "Wake add side effect."),
                symbol("PortGame.source_building_no_sleep_state", "building_no_sleep.entity_decrement", "source_building_no_sleep_result.sleeping_entities_after", "noSleep()", "sleepingEntities--;", "Sleeping entity count decrement."),
            ],
            "params": [{"name": "sleeping", "type": "bool", "schema": "source_building_no_sleep_input.sleeping"}, {"name": "sleeping_entities", "type": "int", "schema": "source_building_no_sleep_input.sleeping_entities"}],
            "return_keys": ["sleep_time", "sleeping_after", "sleeping_entities_after", "add_called"],
            "schemas": {
                "source_building_no_sleep_input": {"status": "active", "owner": "PortGame.source_building_no_sleep_state", "runtime_proof": PROOF, "keys": {key: schema_key(type_name, "explicit-input", "noSleep()", expr, "Explicit BuildingComp noSleep dependency input.") for key, type_name, expr in [("sleeping", "bool", "sleeping"), ("sleeping_entities", "int", "sleepingEntities")] }},
                "source_building_no_sleep_result": {"status": "active", "owner": "PortGame.source_building_no_sleep_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "noSleep()", "public void noSleep(){", "Method boundary."), "sleep_time": schema_key("float", "source-backed", "noSleep()", "sleepTime = 0f;", "Reset sleep timer."), "add_called": schema_key("bool", "source-backed", "noSleep()", "add();", "Wake add side effect.")}},
            },
        },
    ]
    definitions.extend([
        predicate_definition("N1891", "can_withdraw", "public boolean canWithdraw(){", "return true;", []),
        predicate_definition("N1892", "can_unload", "public boolean canUnload(){", "return block.unloadable;", [("block_unloadable", "bool", "block.unloadable")]),
        predicate_definition("N1893", "can_resupply", "public boolean canResupply(){", "return block.allowResupply;", [("block_allow_resupply", "bool", "block.allowResupply")]),
        predicate_definition("N1894", "payload_check", "public boolean payloadCheck(int conveyorRotation){", "return block.rotate && (rotation + 2) % 4 == conveyorRotation;", [("block_rotate", "bool", "block.rotate"), ("rotation", "int", "rotation"), ("conveyor_rotation", "int", "conveyorRotation")]),
        predicate_definition("N1895", "allow_deposit", "public boolean allowDeposit(){", "return block.alwaysAllowDeposit || !state.rules.onlyDepositCore;", [("block_always_allow_deposit", "bool", "block.alwaysAllowDeposit"), ("only_deposit_core", "bool", "state.rules.onlyDepositCore")]),
        predicate_definition("N1896", "should_consume", "public boolean shouldConsume(){", "return enabled;", [("enabled", "bool", "enabled")]),
        predicate_definition("N1897", "production_valid", "public boolean productionValid(){", "return true;", []),
        predicate_definition("N1898", "consume_trigger_valid", "public boolean consumeTriggerValid(){", "return false;", []),
    ])
    entries = {}
    for definition in definitions:
        owner = definition["owner"]
        runtime_proof = definition.get("proof", PROOF)
        source_symbols.upsert_source_slice(GODOT, definition["slice"], {"status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp", "java_method": definition["method"], "godot_owner": owner, "rule": "Canonical source-backed BuildingComp accessor with explicit runtime dependencies.", "exact_exprs": definition["expressions"], "source_symbols": [name for name, _entry in definition["symbols"]], "tests": TESTS, "runtime_proof": runtime_proof})
        source_symbols.upsert_source_api_contract(GODOT, owner, {"status": "active", "source_slice": definition["slice"], "java_source": SOURCE, "source_method": definition["method"], "params": definition["params"], "return_keys": definition["return_keys"], "tests": TESTS, "runtime_proof": runtime_proof, "rule": "Canonical BuildingComp accessor contract with explicit dependency input."})
        for name, entry in definition["symbols"]:
            entry["runtime_proof"] = runtime_proof
            entries[name] = entry
        for schema_name, schema_entry in definition["schemas"].items():
            schema_entry["runtime_proof"] = runtime_proof
            source_symbols.upsert_source_state_schema(GODOT, schema_name, schema_entry)
    source_symbols.upsert_source_symbols(GODOT, entries)
    # The component domain currently shards slices and contracts only; schemas
    # and symbols remain canonical until their registered component shards exist.
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
