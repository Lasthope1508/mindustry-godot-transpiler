from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/UnitComp.java"
PROOF = "/root/Main.UnitCompGeneratedRuntimeModuleProof"
TESTS = [
    "test_unit_controller_runtime_block_matches_upstream_source",
    "test_unit_comp_controller_block_is_registered_and_generated",
]


def schema_key(type_name: str, status: str, method: str, expr: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expr,
        "rule": rule,
    }


def register_slice(slice_id: str, owner: str, method: str, expressions: list[str], symbols: list[str], params: list[dict], return_keys: list[str], schemas: dict[str, dict]) -> None:
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "status": "done",
        "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.UnitComp",
        "java_method": method,
        "godot_owner": owner,
        "exact_exprs": expressions,
        "source_symbols": symbols,
        "tests": TESTS,
        "runtime_proof": PROOF,
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "status": "active",
        "source_slice": slice_id,
        "java_source": SOURCE,
        "source_method": method,
        "params": params,
        "return_keys": return_keys,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": f"Canonical runtime contract for {method} with explicit dependencies supplied at call time.",
    })
    for name, entry in schemas.items():
        source_symbols.upsert_source_state_schema(GODOT, name, entry)


def symbol(owner: str, name: str, godot_symbol: str, method: str, expression: str, rule: str, status: str = "source-backed") -> tuple[str, dict]:
    return name, {
        "status": status,
        "godot_owner": owner,
        "godot_symbol": godot_symbol,
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
    }


def main() -> None:
    entries: dict[str, dict] = {}
    defs = [
        (
            "N1858", "PortGame.source_unit_collision_state", "UnitComp.collision(Hitboxc,float,float)",
            ["public void collision(Hitboxc other, float x, float y){", "if(other instanceof Bullet bullet){", "controller.hit(bullet);"],
            [
                symbol("PortGame.source_unit_collision_state", "unit_collision.method", "source_unit_collision_result.controller_hit_called", "UnitComp.collision(Hitboxc,float,float)", "public void collision(Hitboxc other, float x, float y){", "Method boundary."),
                symbol("PortGame.source_unit_collision_state", "unit_collision.bullet_guard", "source_unit_collision_result.controller_hit_called", "UnitComp.collision(Hitboxc,float,float)", "if(other instanceof Bullet bullet){", "Bullet dispatch guard."),
                symbol("PortGame.source_unit_collision_state", "unit_collision.controller_hit", "source_unit_collision_result.controller_hit", "UnitComp.collision(Hitboxc,float,float)", "controller.hit(bullet);", "Dispatches collision bullet to the controller."),
            ],
            [{"name": "other_is_bullet", "type": "bool", "schema": "source_unit_collision_input.other_is_bullet"}, {"name": "bullet", "type": "Variant", "schema": "source_unit_collision_input.bullet"}],
            ["other_is_bullet", "bullet", "controller_hit_called", "controller_hit"],
            {
                "source_unit_collision_input": {"status": "active", "owner": "port_game.source_unit_collision_state", "runtime_proof": PROOF, "keys": {"other_is_bullet": schema_key("bool", "explicit-input", "UnitComp.collision(Hitboxc,float,float)", "other instanceof Bullet bullet", "Explicit runtime type projection."), "bullet": schema_key("Variant", "explicit-input", "UnitComp.collision(Hitboxc,float,float)", "bullet", "Explicit bullet dependency.")}},
                "source_unit_collision_result": {"status": "active", "owner": "port_game.source_unit_collision_state", "runtime_proof": PROOF, "keys": {"other_is_bullet": schema_key("bool", "explicit-input", "UnitComp.collision(Hitboxc,float,float)", "other instanceof Bullet bullet", "Type guard input."), "bullet": schema_key("Variant", "explicit-input", "UnitComp.collision(Hitboxc,float,float)", "bullet", "Bullet projection."), "controller_hit_called": schema_key("bool", "source-backed", "UnitComp.collision(Hitboxc,float,float)", "if(other instanceof Bullet bullet){", "Whether source dispatch executes."), "controller_hit": schema_key("Variant", "source-backed", "UnitComp.collision(Hitboxc,float,float)", "controller.hit(bullet);", "Canonical controller hit call.")}},
            },
        ),
        (
            "N1859", "PortGame.source_unit_controller_set_state", "UnitComp.controller(UnitController)",
            ["public void controller(UnitController next){", "this.controller = next;", "if(controller.unit() != self()) controller.unit(self());"],
            [
                symbol("PortGame.source_unit_controller_set_state", "unit_controller_set.method", "source_unit_controller_set_result.controller", "UnitComp.controller(UnitController)", "public void controller(UnitController next){", "Method boundary."),
                symbol("PortGame.source_unit_controller_set_state", "unit_controller_set.assign", "source_unit_controller_set_result.controller", "UnitComp.controller(UnitController)", "this.controller = next;", "Controller assignment."),
                symbol("PortGame.source_unit_controller_set_state", "unit_controller_set.sync", "source_unit_controller_set_result.unit_sync_required", "UnitComp.controller(UnitController)", "if(controller.unit() != self()) controller.unit(self());", "Controller-unit synchronization guard."),
            ],
            [{"name": "next_controller", "type": "Variant", "schema": "source_unit_controller_set_input.next_controller"}, {"name": "controller_unit", "type": "Variant", "schema": "source_unit_controller_set_input.controller_unit"}, {"name": "self_unit", "type": "Variant", "schema": "source_unit_controller_set_input.self_unit"}],
            ["controller", "controller_unit", "unit_sync_required", "call_order"],
            {
                "source_unit_controller_set_input": {"status": "active", "owner": "port_game.source_unit_controller_set_state", "runtime_proof": PROOF, "keys": {"next_controller": schema_key("Variant", "explicit-input", "UnitComp.controller(UnitController)", "next", "Controller candidate."), "controller_unit": schema_key("Variant", "explicit-input", "UnitComp.controller(UnitController)", "controller.unit()", "Existing controller unit."), "self_unit": schema_key("Variant", "explicit-input", "UnitComp.controller(UnitController)", "self()", "Current unit identity.")}},
                "source_unit_controller_set_result": {"status": "active", "owner": "port_game.source_unit_controller_set_state", "runtime_proof": PROOF, "keys": {"controller": schema_key("Variant", "source-backed", "UnitComp.controller(UnitController)", "this.controller = next;", "Assigned controller."), "controller_unit": schema_key("Variant", "source-backed", "UnitComp.controller(UnitController)", "controller.unit(self());", "Synchronized controller unit."), "unit_sync_required": schema_key("bool", "source-backed", "UnitComp.controller(UnitController)", "if(controller.unit() != self()) controller.unit(self());", "Whether synchronization executes."), "call_order": schema_key("Array", "source-backed", "UnitComp.controller(UnitController)", "this.controller = next;", "Canonical mutation order.")}},
            },
        ),
        (
            "N1860", "PortGame.source_unit_controller_get_state", "UnitComp.controller()",
            ["public UnitController controller(){", "return controller;"],
            [symbol("PortGame.source_unit_controller_get_state", "unit_controller_get.method", "source_unit_controller_get_result.controller", "UnitComp.controller()", "public UnitController controller(){", "Method boundary."), symbol("PortGame.source_unit_controller_get_state", "unit_controller_get.return", "source_unit_controller_get_result.controller", "UnitComp.controller()", "return controller;", "Canonical controller return.")],
            [{"name": "controller", "type": "Variant", "schema": "source_unit_controller_get_input.controller"}], ["controller"],
            {"source_unit_controller_get_input": {"status": "active", "owner": "port_game.source_unit_controller_get_state", "runtime_proof": PROOF, "keys": {"controller": schema_key("Variant", "explicit-input", "UnitComp.controller()", "controller", "Controller projection.")}}, "source_unit_controller_get_result": {"status": "active", "owner": "port_game.source_unit_controller_get_state", "runtime_proof": PROOF, "keys": {"controller": schema_key("Variant", "source-backed", "UnitComp.controller()", "return controller;", "Canonical controller return.")}}},
        ),
        (
            "N1861", "PortGame.source_unit_reset_controller_state", "UnitComp.resetController()",
            ["public void resetController(){", "controller(type.createController(self()));"],
            [symbol("PortGame.source_unit_reset_controller_state", "unit_reset_controller.method", "source_unit_reset_controller_result.controller", "UnitComp.resetController()", "public void resetController(){", "Method boundary."), symbol("PortGame.source_unit_reset_controller_state", "unit_reset_controller.create", "source_unit_reset_controller_result.controller", "UnitComp.resetController()", "controller(type.createController(self()));", "Creates and assigns the default controller.")],
            [{"name": "created_controller", "type": "Variant", "schema": "source_unit_reset_controller_input.created_controller"}], ["created_controller", "controller", "create_controller_call"],
            {"source_unit_reset_controller_input": {"status": "active", "owner": "port_game.source_unit_reset_controller_state", "runtime_proof": PROOF, "keys": {"created_controller": schema_key("Variant", "explicit-input", "UnitComp.resetController()", "type.createController(self())", "Factory result.")}}, "source_unit_reset_controller_result": {"status": "active", "owner": "port_game.source_unit_reset_controller_state", "runtime_proof": PROOF, "keys": {"created_controller": schema_key("Variant", "explicit-input", "UnitComp.resetController()", "type.createController(self())", "Factory result."), "controller": schema_key("Variant", "source-backed", "UnitComp.resetController()", "controller(type.createController(self()));", "Assigned default controller."), "create_controller_call": schema_key("String", "source-backed", "UnitComp.resetController()", "type.createController(self())", "Controller factory call.")}}},
        ),
        (
            "N1862", "PortGame.source_unit_set_state", "UnitComp.set(UnitType,UnitController)",
            ["public void set(UnitType def, UnitController controller){", "if(this.type != def){", "setType(def);", "controller(controller);"],
            [symbol("PortGame.source_unit_set_state", "unit_set.method", "source_unit_set_result.type_changed", "UnitComp.set(UnitType,UnitController)", "public void set(UnitType def, UnitController controller){", "Method boundary."), symbol("PortGame.source_unit_set_state", "unit_set.type_guard", "source_unit_set_result.type_changed", "UnitComp.set(UnitType,UnitController)", "if(this.type != def){", "Type-change guard."), symbol("PortGame.source_unit_set_state", "unit_set.type_call", "source_unit_set_result.set_type_called", "UnitComp.set(UnitType,UnitController)", "setType(def);", "Conditional type update."), symbol("PortGame.source_unit_set_state", "unit_set.controller_call", "source_unit_set_result.controller", "UnitComp.set(UnitType,UnitController)", "controller(controller);", "Controller assignment.")],
            [{"name": "current_type", "type": "Variant", "schema": "source_unit_set_input.current_type"}, {"name": "definition", "type": "Variant", "schema": "source_unit_set_input.definition"}, {"name": "controller", "type": "Variant", "schema": "source_unit_set_input.controller"}, {"name": "controller_unit", "type": "Variant", "schema": "source_unit_set_input.controller_unit"}, {"name": "self_unit", "type": "Variant", "schema": "source_unit_set_input.self_unit"}],
            ["type", "type_changed", "set_type_called", "controller", "controller_unit", "controller_unit_sync_required", "call_order"],
            {"source_unit_set_input": {"status": "active", "owner": "port_game.source_unit_set_state", "runtime_proof": PROOF, "keys": {name: schema_key("Variant", "explicit-input", "UnitComp.set(UnitType,UnitController)", expr, "Explicit source dependency projection.") for name, expr in {"current_type": "this.type", "definition": "def", "controller": "controller", "controller_unit": "controller.unit()", "self_unit": "self()"}.items()}}, "source_unit_set_result": {"status": "active", "owner": "port_game.source_unit_set_state", "runtime_proof": PROOF, "keys": {"type": schema_key("Variant", "source-backed", "UnitComp.set(UnitType,UnitController)", "setType(def);", "Updated or retained type."), "type_changed": schema_key("bool", "source-backed", "UnitComp.set(UnitType,UnitController)", "if(this.type != def){", "Whether type changes."), "set_type_called": schema_key("bool", "source-backed", "UnitComp.set(UnitType,UnitController)", "setType(def);", "Whether setType executes."), "controller": schema_key("Variant", "source-backed", "UnitComp.set(UnitType,UnitController)", "controller(controller);", "Assigned controller."), "controller_unit": schema_key("Variant", "source-backed", "UnitComp.set(UnitType,UnitController)", "controller.unit(self());", "Controller unit after synchronization."), "controller_unit_sync_required": schema_key("bool", "source-backed", "UnitComp.set(UnitType,UnitController)", "if(controller.unit() != self()) controller.unit(self());", "Synchronization guard result."), "call_order": schema_key("Array", "source-backed", "UnitComp.set(UnitType,UnitController)", "controller(controller);", "Canonical mutation order.")}}},
        ),
        (
            "N1863", "PortGame.source_unit_collision_layer_state", "UnitComp.collisionLayer()",
            ["public int collisionLayer(){", "return type.allowLegStep && type.legPhysicsLayer ? PhysicsProcess.layerLegs : isGrounded() ? PhysicsProcess.layerGround : PhysicsProcess.layerFlying;"],
            [symbol("PortGame.source_unit_collision_layer_state", "unit_collision_layer.method", "source_unit_collision_layer_result.collision_layer", "UnitComp.collisionLayer()", "public int collisionLayer(){", "Method boundary."), symbol("PortGame.source_unit_collision_layer_state", "unit_collision_layer.return", "source_unit_collision_layer_result.collision_layer", "UnitComp.collisionLayer()", "return type.allowLegStep && type.legPhysicsLayer ? PhysicsProcess.layerLegs : isGrounded() ? PhysicsProcess.layerGround : PhysicsProcess.layerFlying;", "Canonical physics layer selection.")],
            [{"name": name, "type": type_name, "schema": f"source_unit_collision_layer_input.{name}"} for name, type_name in [("type_allow_leg_step", "bool"), ("type_leg_physics_layer", "bool"), ("is_grounded", "bool"), ("layer_legs", "int"), ("layer_ground", "int"), ("layer_flying", "int")]], ["collision_layer", "branch"],
            {"source_unit_collision_layer_input": {"status": "active", "owner": "port_game.source_unit_collision_layer_state", "runtime_proof": PROOF, "keys": {name: schema_key(type_name, "explicit-input", "UnitComp.collisionLayer()", expr, "Explicit layer-selection dependency.") for name, type_name, expr in [("type_allow_leg_step", "bool", "type.allowLegStep"), ("type_leg_physics_layer", "bool", "type.legPhysicsLayer"), ("is_grounded", "bool", "isGrounded()"), ("layer_legs", "int", "PhysicsProcess.layerLegs"), ("layer_ground", "int", "PhysicsProcess.layerGround"), ("layer_flying", "int", "PhysicsProcess.layerFlying")]}}, "source_unit_collision_layer_result": {"status": "active", "owner": "port_game.source_unit_collision_layer_state", "runtime_proof": PROOF, "keys": {"collision_layer": schema_key("int", "source-backed", "UnitComp.collisionLayer()", "return type.allowLegStep && type.legPhysicsLayer ? PhysicsProcess.layerLegs : isGrounded() ? PhysicsProcess.layerGround : PhysicsProcess.layerFlying;", "Selected physics layer."), "branch": schema_key("String", "source-backed", "UnitComp.collisionLayer()", "return type.allowLegStep && type.legPhysicsLayer ? PhysicsProcess.layerLegs : isGrounded() ? PhysicsProcess.layerGround : PhysicsProcess.layerFlying;", "Selected source branch.")}}},
        ),
        (
            "N1864", "PortGame.source_unit_get_controller_name_state", "UnitComp.getControllerName()",
            ["/** @return name of direct or indirect player controller. */", "public @Nullable String getControllerName(){", "if(isPlayer()) return getPlayer().coloredName();", "if(controller instanceof LogicAI ai && ai.controller != null) return ai.controller.lastAccessed;", "return null;"],
            [
                symbol("PortGame.source_unit_get_controller_name_state", "unit_get_controller_name.comment", "source_unit_get_controller_name_result.comment", "UnitComp.getControllerName()", "/** @return name of direct or indirect player controller. */", "Method documentation."),
                symbol("PortGame.source_unit_get_controller_name_state", "unit_get_controller_name.method", "source_unit_get_controller_name_result.method", "UnitComp.getControllerName()", "public @Nullable String getControllerName(){", "Method boundary."),
                symbol("PortGame.source_unit_get_controller_name_state", "unit_get_controller_name.player_guard", "source_unit_get_controller_name_result.branch", "UnitComp.getControllerName()", "if(isPlayer()) return getPlayer().coloredName();", "Direct player controller branch."),
                symbol("PortGame.source_unit_get_controller_name_state", "unit_get_controller_name.logic_guard", "source_unit_get_controller_name_result.branch", "UnitComp.getControllerName()", "if(controller instanceof LogicAI ai && ai.controller != null) return ai.controller.lastAccessed;", "Indirect LogicAI controller branch."),
                symbol("PortGame.source_unit_get_controller_name_state", "unit_get_controller_name.null_return", "source_unit_get_controller_name_result.controller_name", "UnitComp.getControllerName()", "return null;", "No controller name branch."),
            ],
            [
                {"name": "is_player", "type": "bool", "schema": "source_unit_get_controller_name_input.is_player"},
                {"name": "player_colored_name", "type": "String", "schema": "source_unit_get_controller_name_input.player_colored_name"},
                {"name": "controller_is_logic_ai", "type": "bool", "schema": "source_unit_get_controller_name_input.controller_is_logic_ai"},
                {"name": "logic_controller_exists", "type": "bool", "schema": "source_unit_get_controller_name_input.logic_controller_exists"},
                {"name": "logic_controller_last_accessed", "type": "String", "schema": "source_unit_get_controller_name_input.logic_controller_last_accessed"},
            ],
            ["controller_name", "branch"],
            {
                "source_unit_get_controller_name_input": {"status": "active", "owner": "port_game.source_unit_get_controller_name_state", "runtime_proof": PROOF, "keys": {
                    "is_player": schema_key("bool", "explicit-input", "UnitComp.getControllerName()", "isPlayer()", "Player predicate."),
                    "player_colored_name": schema_key("String", "explicit-input", "UnitComp.getControllerName()", "getPlayer().coloredName()", "Colored player name."),
                    "controller_is_logic_ai": schema_key("bool", "explicit-input", "UnitComp.getControllerName()", "controller instanceof LogicAI ai", "LogicAI predicate."),
                    "logic_controller_exists": schema_key("bool", "explicit-input", "UnitComp.getControllerName()", "ai.controller != null", "Indirect controller existence."),
                    "logic_controller_last_accessed": schema_key("String", "explicit-input", "UnitComp.getControllerName()", "ai.controller.lastAccessed", "Last accessed controller name."),
                }},
                "source_unit_get_controller_name_result": {"status": "active", "owner": "port_game.source_unit_get_controller_name_state", "runtime_proof": PROOF, "keys": {
                    "comment": schema_key("String", "source-backed", "UnitComp.getControllerName()", "/** @return name of direct or indirect player controller. */", "Method documentation."),
                    "method": schema_key("String", "source-backed", "UnitComp.getControllerName()", "public @Nullable String getControllerName(){", "Method boundary."),
                    "controller_name": schema_key("String", "source-backed", "UnitComp.getControllerName()", "return getPlayer().coloredName(); or return ai.controller.lastAccessed;", "Selected controller name."),
                    "branch": schema_key("String", "source-backed", "UnitComp.getControllerName()", "if(isPlayer()) ...; if(controller instanceof LogicAI ai && ai.controller != null) ...;", "Selected source branch."),
                }},
            },
        ),
        (
            "N1865", "PortGame.source_unit_display_state", "UnitComp.display(Table)",
            ["public void display(Table table){", "type.display(self(), table);"],
            [
                symbol("PortGame.source_unit_display_state", "unit_display.method", "source_unit_display_result.method", "UnitComp.display(Table)", "public void display(Table table){", "Method boundary."),
                symbol("PortGame.source_unit_display_state", "unit_display.call", "source_unit_display_result.call", "UnitComp.display(Table)", "type.display(self(), table);", "Delegates unit display to UnitType."),
            ],
            [{"name": "table", "type": "Variant", "schema": "source_unit_display_input.table"}], ["method", "call", "table"],
            {"source_unit_display_input": {"status": "active", "owner": "port_game.source_unit_display_state", "runtime_proof": PROOF, "keys": {"table": schema_key("Variant", "explicit-input", "UnitComp.display(Table)", "table", "UI table dependency.")}}, "source_unit_display_result": {"status": "active", "owner": "port_game.source_unit_display_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "UnitComp.display(Table)", "public void display(Table table){", "Method boundary."), "call": schema_key("String", "source-backed", "UnitComp.display(Table)", "type.display(self(), table);", "UnitType display delegation."), "table": schema_key("Variant", "explicit-input", "UnitComp.display(Table)", "table", "Forwarded table dependency.")}}},
        ),
        (
            "N1866", "PortGame.source_unit_draw_state", "UnitComp.draw()",
            ["public void draw(){", "type.draw(self());"],
            [
                symbol("PortGame.source_unit_draw_state", "unit_draw.method", "source_unit_draw_result.method", "UnitComp.draw()", "public void draw(){", "Method boundary."),
                symbol("PortGame.source_unit_draw_state", "unit_draw.call", "source_unit_draw_result.call", "UnitComp.draw()", "type.draw(self());", "Delegates unit rendering to UnitType."),
            ],
            [], ["method", "call"],
            {"source_unit_draw_result": {"status": "active", "owner": "port_game.source_unit_draw_state", "runtime_proof": PROOF, "keys": {"method": schema_key("String", "source-backed", "UnitComp.draw()", "public void draw(){", "Method boundary."), "call": schema_key("String", "source-backed", "UnitComp.draw()", "type.draw(self());", "UnitType draw delegation.")}}},
        ),
        (
            "N1867", "PortGame.source_unit_is_player_state", "UnitComp.isPlayer()",
            ["public boolean isPlayer(){", "return controller instanceof Player;"],
            [
                symbol("PortGame.source_unit_is_player_state", "unit_is_player.method", "source_unit_is_player_result.method", "UnitComp.isPlayer()", "public boolean isPlayer(){", "Method boundary."),
                symbol("PortGame.source_unit_is_player_state", "unit_is_player.return", "source_unit_is_player_result.is_player", "UnitComp.isPlayer()", "return controller instanceof Player;", "Canonical Player controller predicate."),
            ],
            [{"name": "controller_is_player", "type": "bool", "schema": "source_unit_is_player_input.controller_is_player"}],
            ["method", "return", "is_player"],
            {
                "source_unit_is_player_input": {"status": "active", "owner": "port_game.source_unit_is_player_state", "runtime_proof": PROOF, "keys": {
                    "controller_is_player": schema_key("bool", "explicit-input", "UnitComp.isPlayer()", "controller instanceof Player", "Explicit controller type projection."),
                }},
                "source_unit_is_player_result": {"status": "active", "owner": "port_game.source_unit_is_player_state", "runtime_proof": PROOF, "keys": {
                    "method": schema_key("String", "source-backed", "UnitComp.isPlayer()", "public boolean isPlayer(){", "Method boundary."),
                    "return": schema_key("bool", "source-backed", "UnitComp.isPlayer()", "return controller instanceof Player;", "Canonical Player controller predicate."),
                    "is_player": schema_key("bool", "source-backed", "UnitComp.isPlayer()", "return controller instanceof Player;", "Whether the controller is a Player."),
                }},
            },
        ),
        (
            "N1868", "PortGame.source_unit_get_player_state", "UnitComp.getPlayer()",
            ["public Player getPlayer(){", "return isPlayer() ? (Player)controller : null;"],
            [
                symbol("PortGame.source_unit_get_player_state", "unit_get_player.method", "source_unit_get_player_result.method", "UnitComp.getPlayer()", "public Player getPlayer(){", "Method boundary."),
                symbol("PortGame.source_unit_get_player_state", "unit_get_player.return", "source_unit_get_player_result.player", "UnitComp.getPlayer()", "return isPlayer() ? (Player)controller : null;", "Canonical Player projection with null fallback."),
            ],
            [{"name": "controller_is_player", "type": "bool", "schema": "source_unit_get_player_input.controller_is_player"}, {"name": "controller", "type": "Variant", "schema": "source_unit_get_player_input.controller"}],
            ["method", "return", "player", "is_player"],
            {
                "source_unit_get_player_input": {"status": "active", "owner": "port_game.source_unit_get_player_state", "runtime_proof": PROOF, "keys": {
                    "controller_is_player": schema_key("bool", "explicit-input", "UnitComp.getPlayer()", "isPlayer()", "Explicit isPlayer() result."),
                    "controller": schema_key("Variant", "explicit-input", "UnitComp.getPlayer()", "(Player)controller", "Explicit controller projection."),
                }},
                "source_unit_get_player_result": {"status": "active", "owner": "port_game.source_unit_get_player_state", "runtime_proof": PROOF, "keys": {
                    "method": schema_key("String", "source-backed", "UnitComp.getPlayer()", "public Player getPlayer(){", "Method boundary."),
                    "return": schema_key("String", "source-backed", "UnitComp.getPlayer()", "return isPlayer() ? (Player)controller : null;", "Canonical Player projection expression."),
                    "player": schema_key("Variant", "source-backed", "UnitComp.getPlayer()", "return isPlayer() ? (Player)controller : null;", "Player controller or null."),
                    "is_player": schema_key("bool", "source-backed", "UnitComp.getPlayer()", "isPlayer()", "Predicate reused by the source expression."),
                }},
            },
        ),
        (
            "N1869", "PortGame.source_unit_to_string_state", "UnitComp.toString()",
            ["@Override", "@Replace", "public String toString(){", "return \"Unit#\" + id() + \":\" + type + \" (\" + x + \", \" + y + \")\";"],
            [
                symbol("PortGame.source_unit_to_string_state", "unit_to_string.override", "source_unit_to_string_result.method", "UnitComp.toString()", "@Override", "Override annotation."),
                symbol("PortGame.source_unit_to_string_state", "unit_to_string.replace", "source_unit_to_string_result.method", "UnitComp.toString()", "@Replace", "Replacement annotation."),
                symbol("PortGame.source_unit_to_string_state", "unit_to_string.method", "source_unit_to_string_result.method", "UnitComp.toString()", "public String toString(){", "Method boundary."),
                symbol("PortGame.source_unit_to_string_state", "unit_to_string.return", "source_unit_to_string_result.to_string", "UnitComp.toString()", "return \"Unit#\" + id() + \":\" + type + \" (\" + x + \", \" + y + \")\";", "Canonical unit identity string."),
            ],
            [{"name": "unit_id", "type": "int", "schema": "source_unit_to_string_input.unit_id"}, {"name": "unit_type", "type": "Variant", "schema": "source_unit_to_string_input.unit_type"}, {"name": "unit_x", "type": "float", "schema": "source_unit_to_string_input.unit_x"}, {"name": "unit_y", "type": "float", "schema": "source_unit_to_string_input.unit_y"}],
            ["method", "return", "id", "type", "x", "y", "to_string"],
            {
                "source_unit_to_string_input": {"status": "active", "owner": "port_game.source_unit_to_string_state", "runtime_proof": PROOF, "keys": {
                    "unit_id": schema_key("int", "explicit-input", "UnitComp.toString()", "id()", "Explicit unit id."),
                    "unit_type": schema_key("Variant", "explicit-input", "UnitComp.toString()", "type", "Explicit unit type projection."),
                    "unit_x": schema_key("float", "explicit-input", "UnitComp.toString()", "x", "Explicit x coordinate."),
                    "unit_y": schema_key("float", "explicit-input", "UnitComp.toString()", "y", "Explicit y coordinate."),
                }},
                "source_unit_to_string_result": {"status": "active", "owner": "port_game.source_unit_to_string_state", "runtime_proof": PROOF, "keys": {
                    "method": schema_key("String", "source-backed", "UnitComp.toString()", "public String toString(){", "Method boundary."),
                    "return": schema_key("String", "source-backed", "UnitComp.toString()", "return \"Unit#\" + id() + \":\" + type + \" (\" + x + \", \" + y + \")\";", "Canonical return expression."),
                    "id": schema_key("int", "explicit-input", "UnitComp.toString()", "id()", "Unit id used in identity string."),
                    "type": schema_key("Variant", "explicit-input", "UnitComp.toString()", "type", "Unit type used in identity string."),
                    "x": schema_key("float", "explicit-input", "UnitComp.toString()", "x", "Unit x coordinate."),
                    "y": schema_key("float", "explicit-input", "UnitComp.toString()", "y", "Unit y coordinate."),
                    "to_string": schema_key("String", "source-backed", "UnitComp.toString()", "return \"Unit#\" + id() + \":\" + type + \" (\" + x + \", \" + y + \")\";", "Rendered unit identity string."),
                }},
            },
        ),
        (
            "N1870", "PortGame.source_unit_update_state", "UnitComp.update()",
            [
                "public void update(){", "type.update(self());", "if(type.bounded){", "if(Float.isNaN(health)){",
                "updateDrowning();", "for(Ability a : abilities){", "drag = type.drag * (isGrounded() ? (floorOn().dragMultiplier) : 1f) * dragMultiplier * state.rules.dragMultiplier;",
                "if(dead || health <= 0){", "if(tile != null && tile.build != null){", "if(!net.client() && !dead && shouldUpdateController()){", "if(spawnedByCore && !isPlayer() && !dead){",
            ],
            [
                symbol("PortGame.source_unit_update_state", "unit_update.method", "source_unit_update_result.call_order", "UnitComp.update()", "public void update(){", "Method boundary."),
                symbol("PortGame.source_unit_update_state", "unit_update.type_hook", "source_unit_update_result.stages.type_update", "UnitComp.update()", "type.update(self());", "First update stage."),
                symbol("PortGame.source_unit_update_state", "unit_update.drowning", "source_unit_update_result.stages.drowning", "UnitComp.update()", "updateDrowning();", "Drowning stage after walk effects."),
                symbol("PortGame.source_unit_update_state", "unit_update.ability_loop", "source_unit_update_result.stages.abilities", "UnitComp.update()", "for(Ability a : abilities){", "Ability update loop."),
                symbol("PortGame.source_unit_update_state", "unit_update.drag", "source_unit_update_result.stages.drag", "UnitComp.update()", "drag = type.drag * (isGrounded() ? (floorOn().dragMultiplier) : 1f) * dragMultiplier * state.rules.dragMultiplier;", "Drag stage."),
                symbol("PortGame.source_unit_update_state", "unit_update.falling", "source_unit_update_result.stages.falling_descent", "UnitComp.update()", "if(dead || health <= 0){", "Falling simulation stage."),
                symbol("PortGame.source_unit_update_state", "unit_update.controller", "source_unit_update_result.stages.controller_update", "UnitComp.update()", "if(!net.client() && !dead && shouldUpdateController()){", "Server-side controller stage."),
                symbol("PortGame.source_unit_update_state", "unit_update.core_despawn", "source_unit_update_result.stages.spawned_core_despawn", "UnitComp.update()", "if(spawnedByCore && !isPlayer() && !dead){", "Core-spawn cleanup stage."),
            ],
            [{"name": "context", "type": "Dictionary", "schema": "source_unit_update_input.context"}],
            ["deferred", "missing_dependencies", "call_order", "stages"],
            {
                "source_unit_update_input": {"status": "active", "owner": "port_game.source_unit_update_state", "runtime_proof": PROOF, "keys": {
                    "context": schema_key("Dictionary", "explicit-input", "UnitComp.update()", "UnitComp field and runtime dependencies", "Explicit runtime dependency bag; no gameplay defaults are invented."),
                }},
                "source_unit_update_result": {"status": "active", "owner": "port_game.source_unit_update_state", "runtime_proof": PROOF, "keys": {
                    "deferred": schema_key("bool", "source-backed", "UnitComp.update()", "UnitComp update dependencies", "Reports incomplete runtime adapter input."),
                    "missing_dependencies": schema_key("Array", "source-backed", "UnitComp.update()", "UnitComp update dependencies", "Lists missing explicit dependencies."),
                    "call_order": schema_key("Array", "source-backed", "UnitComp.update()", "type.update(self()); ... Call.unitDespawn(self());", "Canonical Java stage order."),
                    "stages": schema_key("Dictionary", "source-backed", "UnitComp.update()", "UnitComp.update() body", "Results of canonical stage modules."),
                }},
            },
        ),
    ]
    for slice_id, owner, method, expressions, symbols, params, return_keys, schemas in defs:
        entries.update(dict(symbols))
        register_slice(slice_id, owner, method, expressions, [name for name, _ in symbols], params, return_keys, schemas)
    source_symbols.upsert_source_symbols(GODOT, entries)
    for name in ("unit_comp_slices", "unit_comp_api_contracts", "unit_comp_state_schema", "unit_comp_symbols"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
