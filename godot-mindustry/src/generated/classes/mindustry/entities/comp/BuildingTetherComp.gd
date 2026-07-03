# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/BuildingTetherComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "BuildingTetherComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Unitc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": ["public"], "name": "building", "type": "Building"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_update_0(_args: Array = []) -> Variant:
	var building_exists := bool(_args[0] if _args.size() > 0 else false)
	var building_is_valid := bool(_args[1] if _args.size() > 1 else false)
	var building_team_value: Variant = _args[2] if _args.size() > 2 else null
	var team_value: Variant = _args[3] if _args.size() > 3 else null
	var unit_id := int(_args[4] if _args.size() > 4 else 0)
	var guard: bool = (not building_exists) or (not building_is_valid) or building_team_value != team_value
	var despawn_call: Variant = null
	if guard:
		despawn_call = {"call": "Call.unitDespawn(self())", "unit": unit_id}
	return {"source_owner": "PortGame.source_building_tether_update_state", "method": "public void update(){", "guard_expr": "if(building == null || !building.isValid() || building.team != team){", "building_exists": building_exists, "building_is_valid": building_is_valid, "building_team_value": building_team_value, "team_value": team_value, "guard": guard, "despawn": despawn_call}
