# Generated from Mindustry upstream.
# Source: mindustry/input/InputHandler.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.input"
const JAVA_KIND := "class"
const JAVA_NAME := "InputHandler"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["InputProcessor", "GestureListener"]
const JAVA_FIELDS := [{"modifiers": ["static"], "name": "queuedCommands", "type": "ObjectMap"}, {"modifiers": ["final", "static"], "name": "playerSelectRange", "type": "float"}, {"modifiers": ["final", "static"], "name": "unitSelectRadScl", "type": "float"}, {"modifiers": ["final", "static"], "name": "stancesOut", "type": "Seq"}, {"modifiers": ["final", "static"], "name": "removed", "type": "IntSeq"}, {"modifiers": ["final", "static"], "name": "intSet", "type": "IntSet"}, {"modifiers": ["final", "static"], "name": "maxLength", "type": "int"}, {"modifiers": ["final", "static"], "name": "r1", "type": "Rect"}, {"modifiers": ["final", "static"], "name": "r2", "type": "Rect"}, {"modifiers": ["final", "static"], "name": "tmpUnits", "type": "Seq"}, {"modifiers": ["final", "static"], "name": "tmpBuildings", "type": "Seq"}, {"modifiers": ["final", "static"], "name": "controlGroupBindings", "type": "KeyBind"}, {"modifiers": ["public"], "name": "logicCutscene", "type": "boolean"}, {"modifiers": ["public"], "name": "logicCamPan", "type": "Vec2"}, {"modifiers": ["public"], "name": "logicCamSpeed", "type": "float"}, {"modifiers": ["public"], "name": "logicCutsceneZoom", "type": "float"}, {"modifiers": ["public"], "name": "inputLocks", "type": "Seq"}, {"modifiers": ["public"], "name": "controlInterval", "type": "Interval"}, {"modifiers": ["public"], "name": "block", "type": "Block"}, {"modifiers": ["public"], "name": "overrideLineRotation", "type": "boolean"}, {"modifiers": ["public"], "name": "rotation", "type": "int"}, {"modifiers": ["public"], "name": "droppingItem", "type": "boolean"}, {"modifiers": ["public"], "name": "itemDepositCooldown", "type": "float"}, {"modifiers": ["public"], "name": "uiGroup", "type": "Group"}, {"modifiers": ["public"], "name": "isBuilding", "type": "boolean"}, {"modifiers": ["public"], "name": "buildWasAutoPaused", "type": "boolean"}, {"modifiers": ["public"], "name": "wasShooting", "type": "boolean"}, {"modifiers": ["public"], "name": "controlledType", "type": "UnitType"}, {"modifiers": ["public"], "name": "recentRespawnTimer", "type": "float"}, {"modifiers": ["public"], "name": "lastSchematic", "type": "Schematic"}, {"modifiers": ["public"], "name": "detector", "type": "GestureDetector"}, {"modifiers": ["public"], "name": "line", "type": "PlaceLine"}, {"modifiers": ["public"], "name": "resultplan", "type": "BuildPlan"}, {"modifiers": ["public"], "name": "bplan", "type": "BuildPlan"}, {"modifiers": ["public"], "name": "linePlans", "type": "Seq"}, {"modifiers": ["public"], "name": "selectPlans", "type": "Seq"}, {"modifiers": ["public"], "name": "lastPlans", "type": "Queue"}, {"modifiers": ["public"], "name": "lastUnit", "type": "Unit"}, {"modifiers": ["public"], "name": "spectating", "type": "Unit"}, {"modifiers": ["public"], "name": "selectedUnits", "type": "Seq"}, {"modifiers": ["public"], "name": "commandBuildings", "type": "Seq"}, {"modifiers": ["public"], "name": "commandMode", "type": "boolean"}, {"modifiers": ["public"], "name": "commandRect", "type": "boolean"}, {"modifiers": ["public"], "name": "tappedOne", "type": "boolean"}, {"modifiers": ["public"], "name": "commandRectX", "type": "float"}, {"modifiers": ["public"], "name": "commandRectY", "type": "float"}, {"modifiers": ["public"], "name": "controlGroups", "type": "IntSeq"}, {"modifiers": ["private"], "name": "plansOut", "type": "Seq"}, {"modifiers": ["private"], "name": "playerPlanTree", "type": "QuadTree"}, {"modifiers": ["private"], "name": "selectPlanTree", "type": "QuadTree"}, {"modifiers": ["final", "public"], "name": "inv", "type": "BlockInventoryFragment"}, {"modifiers": ["final", "public"], "name": "config", "type": "BlockConfigFragment"}, {"modifiers": ["final", "public"], "name": "planConfig", "type": "PlanConfigFragment"}, {"modifiers": ["private"], "name": "group", "type": "WidgetGroup"}, {"modifiers": ["private"], "name": "overlappingPlan", "type": "BuildPlan"}, {"modifiers": ["private"], "name": "overlappingPlayer", "type": "Player"}, {"modifiers": ["protected"], "name": "allPlans", "type": "Eachable"}, {"modifiers": ["protected"], "name": "allSelectLines", "type": "Eachable"}, {"modifiers": ["protected"], "name": "allRenderPlansConfig", "type": "Eachable"}, {"modifiers": ["private", "static"], "name": "sameQuadPlan", "type": "BuildPlan"}, {"modifiers": ["final", "private", "static"], "name": "sameQuadPlanFinder", "type": "Boolf"}, {"modifiers": ["private", "static"], "name": "vpIgnore", "type": "BuildPlan"}, {"modifiers": ["private", "static"], "name": "vpBlock", "type": "Block"}, {"modifiers": ["private", "static"], "name": "vpX", "type": "int"}, {"modifiers": ["private", "static"], "name": "vpY", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "vpPredicate", "type": "Boolf"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "InputHandler", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "transferItemEffect", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "to", "type": "Itemsc", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "takeItems", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "to", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "transferItemToUnit", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "to", "type": "Itemsc", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setItem", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setItems", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "items", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setTileItems", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "positions", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "clearItems", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setLiquid", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setLiquids", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "liquids", "type": "LiquidStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setTileLiquids", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "positions", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "clearLiquids", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "transferItemTo", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "deletePlans", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "positions", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "pingLocation", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "createItemTransfer", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "to", "type": "Position", "varargs": false}, {"name": "done", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "commandUnits", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "unitIds", "type": "int", "varargs": false}, {"name": "buildTarget", "type": "Building", "varargs": false}, {"name": "unitTarget", "type": "Unit", "varargs": false}, {"name": "posTarget", "type": "Vec2", "varargs": false}, {"name": "queueCommand", "type": "boolean", "varargs": false}, {"name": "finalBatch", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setUnitCommand", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "unitIds", "type": "int", "varargs": false}, {"name": "command", "type": "UnitCommand", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setUnitStance", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "unitIds", "type": "int", "varargs": false}, {"name": "stance", "type": "UnitStance", "varargs": false}, {"name": "enable", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "commandBuilding", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "buildings", "type": "int", "varargs": false}, {"name": "target", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "requestItem", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "transferInventory", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "removeQueueBlock", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "breaking", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "requestUnitPayload", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "target", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "requestBuildPayload", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "pickedUnitPayload", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "target", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "pickedBuildPayload", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}, {"name": "onGround", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "requestDropPayload", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "payloadDropped", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitEnteredPayload", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dropItem", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "angle", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "rotateBlock", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}, {"name": "direction", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "tileConfig", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "tileTap", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "buildingControlSelect", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitBuildingControlSelect", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitControl", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "unitClear", "parameters": [{"name": "player", "type": "Player", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "createPlanLists", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateSelectQuadtree", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "addLock", "parameters": [{"name": "lock", "type": "Boolp", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "locked", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "allPlans", "parameters": [], "return_type": "Eachable"}, {"modifiers": ["public"], "name": "isUsingSchematic", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "spectate", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getSyncedPlans", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkUnit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "tryPickupPayload", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "tryDropPayload", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getMouseX", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getMouseY", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "buildPlacementUI", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "buildUI", "parameters": [{"name": "group", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateState", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "multiUnitSelect", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "selectUnitsRect", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "selectTypedUnits", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "tapCommandUnit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "commandTap", "parameters": [{"name": "screenX", "type": "float", "varargs": false}, {"name": "screenY", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "commandTap", "parameters": [{"name": "screenX", "type": "float", "varargs": false}, {"name": "screenY", "type": "float", "varargs": false}, {"name": "queue", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawCommand", "parameters": [{"name": "sel", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawCommand", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawCommanded", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawCommandedTargets", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawCommanded", "parameters": [{"name": "flying", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawUnitSelection", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawOtherBuildPlans", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawBuildPlans", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawBottom", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawTop", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawOverSelect", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawSelected", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBreaking", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawOverlapCheck", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "cursorX", "type": "int", "varargs": false}, {"name": "cursorY", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "planMatches", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawBreaking", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "useSchematic", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "useSchematic", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "checkHidden", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "showSchematicSave", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "rotatePlans", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}, {"name": "direction", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "flipPlans", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}, {"name": "x", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "schemOriginX", "parameters": [], "return_type": "int"}, {"modifiers": ["protected"], "name": "schemOriginY", "parameters": [], "return_type": "int"}, {"modifiers": ["protected"], "name": "getPlan", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["protected"], "name": "getPlan", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "size", "type": "int", "varargs": false}, {"name": "skip", "type": "BuildPlan", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["protected"], "name": "drawBreakSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}, {"name": "maxLength", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawBreakSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}, {"name": "maxLength", "type": "int", "varargs": false}, {"name": "useSelectPlans", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawRebuildSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawBreakSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}, {"name": "maxLength", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}, {"name": "maxLength", "type": "int", "varargs": false}, {"name": "col1", "type": "Color", "varargs": false}, {"name": "col2", "type": "Color", "varargs": false}, {"name": "withText", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "flushSelectPlans", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "flushPlansReverse", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "flushPlans", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawOverPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawOverPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "drawPlan", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "removeSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "removeSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}, {"name": "maxLength", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "removeSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}, {"name": "flush", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "removeSelection", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}, {"name": "flush", "type": "boolean", "varargs": false}, {"name": "maxLength", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "updateLine", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "updateLine", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "checkConfigTap", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "tileTapped", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "tryTapPlayer", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "canTapPlayer", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "tryBeginMine", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "tryStopMine", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "tryStopMine", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "tryRepairDerelict", "parameters": [{"name": "selected", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "canRepairDerelict", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "canMine", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "tileAt", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "Tile"}, {"modifiers": [], "name": "rawTileX", "parameters": [], "return_type": "int"}, {"modifiers": [], "name": "rawTileY", "parameters": [], "return_type": "int"}, {"modifiers": [], "name": "tileX", "parameters": [{"name": "cursorX", "type": "float", "varargs": false}], "return_type": "int"}, {"modifiers": [], "name": "tileY", "parameters": [{"name": "cursorY", "type": "float", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "panCamera", "parameters": [{"name": "position", "type": "Vec2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "selectedBlock", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isPlacing", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isBreaking", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isRebuildSelecting", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "mouseAngle", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "selectedUnit", "parameters": [], "return_type": "Unit"}, {"modifiers": ["public"], "name": "selectedControlBuild", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "selectedCommandUnit", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "selectedEnemyUnit", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "Unit"}, {"modifiers": ["public"], "name": "selectedCommandBuildings", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "w", "type": "float", "varargs": false}, {"name": "h", "type": "float", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "selectedCommandUnits", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "w", "type": "float", "varargs": false}, {"name": "h", "type": "float", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "selectedCommandUnits", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "w", "type": "float", "varargs": false}, {"name": "h", "type": "float", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "canShoot", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "onConfigurable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isDroppingItem", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canDropItem", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "tryDropItems", "parameters": [{"name": "build", "type": "Building", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canDepositItem", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "rebuildArea", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "tryBreakBlock", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "validPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "type", "type": "Block", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "validPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "type", "type": "Block", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "ignore", "type": "BuildPlan", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "validPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "type", "type": "Block", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "ignore", "type": "BuildPlan", "varargs": false}, {"name": "ignoreUnits", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "validBreak", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "breakBlock", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArrow", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawArrow", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "iterateLine", "parameters": [{"name": "startX", "type": "int", "varargs": false}, {"name": "startY", "type": "int", "varargs": false}, {"name": "endX", "type": "int", "varargs": false}, {"name": "endY", "type": "int", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_transferItemEffect_0(_args: Array = []) -> Variant:
	return null

func java_method_takeItems_1(_args: Array = []) -> Variant:
	return null

func java_method_transferItemToUnit_2(_args: Array = []) -> Variant:
	return null

func java_method_setItem_3(_args: Array = []) -> Variant:
	return null

func java_method_setItems_4(_args: Array = []) -> Variant:
	return null

func java_method_setTileItems_5(_args: Array = []) -> Variant:
	return null

func java_method_clearItems_6(_args: Array = []) -> Variant:
	return null

func java_method_setLiquid_7(_args: Array = []) -> Variant:
	return null

func java_method_setLiquids_8(_args: Array = []) -> Variant:
	return null

func java_method_setTileLiquids_9(_args: Array = []) -> Variant:
	return null

func java_method_clearLiquids_10(_args: Array = []) -> Variant:
	return null

func java_method_transferItemTo_11(_args: Array = []) -> Variant:
	return null

func java_method_deletePlans_12(_args: Array = []) -> Variant:
	return null

func java_method_pingLocation_13(_args: Array = []) -> Variant:
	return null

func java_method_createItemTransfer_14(_args: Array = []) -> Variant:
	return null

func java_method_commandUnits_15(_args: Array = []) -> Variant:
	return null

func java_method_setUnitCommand_16(_args: Array = []) -> Variant:
	return null

func java_method_setUnitStance_17(_args: Array = []) -> Variant:
	return null

func java_method_commandBuilding_18(_args: Array = []) -> Variant:
	return null

func java_method_requestItem_19(_args: Array = []) -> Variant:
	return null

func java_method_transferInventory_20(_args: Array = []) -> Variant:
	return null

func java_method_removeQueueBlock_21(_args: Array = []) -> Variant:
	return null

func java_method_requestUnitPayload_22(_args: Array = []) -> Variant:
	return null

func java_method_requestBuildPayload_23(_args: Array = []) -> Variant:
	return null

func java_method_pickedUnitPayload_24(_args: Array = []) -> Variant:
	return null

func java_method_pickedBuildPayload_25(_args: Array = []) -> Variant:
	return null

func java_method_requestDropPayload_26(_args: Array = []) -> Variant:
	return null

func java_method_payloadDropped_27(_args: Array = []) -> Variant:
	return null

func java_method_unitEnteredPayload_28(_args: Array = []) -> Variant:
	return null

func java_method_dropItem_29(_args: Array = []) -> Variant:
	return null

func java_method_rotateBlock_30(_args: Array = []) -> Variant:
	return null

func java_method_tileConfig_31(_args: Array = []) -> Variant:
	return null

func java_method_tileTap_32(_args: Array = []) -> Variant:
	return null

func java_method_buildingControlSelect_33(_args: Array = []) -> Variant:
	return null

func java_method_unitBuildingControlSelect_34(_args: Array = []) -> Variant:
	return null

func java_method_unitControl_35(_args: Array = []) -> Variant:
	return null

func java_method_unitClear_36(_args: Array = []) -> Variant:
	return null

func java_method_createPlanLists_37(_args: Array = []) -> Variant:
	return null

func java_method_updateSelectQuadtree_38(_args: Array = []) -> Variant:
	return null

func java_method_addLock_39(_args: Array = []) -> Variant:
	return null

func java_method_locked_40(_args: Array = []) -> Variant:
	return null

func java_method_allPlans_41(_args: Array = []) -> Variant:
	return null

func java_method_isUsingSchematic_42(_args: Array = []) -> Variant:
	return null

func java_method_spectate_43(_args: Array = []) -> Variant:
	return null

func java_method_reset_44(_args: Array = []) -> Variant:
	return null

func java_method_getSyncedPlans_45(_args: Array = []) -> Variant:
	return null

func java_method_update_46(_args: Array = []) -> Variant:
	return null

func java_method_checkUnit_47(_args: Array = []) -> Variant:
	return null

func java_method_tryPickupPayload_48(_args: Array = []) -> Variant:
	return null

func java_method_tryDropPayload_49(_args: Array = []) -> Variant:
	return null

func java_method_getMouseX_50(_args: Array = []) -> Variant:
	return null

func java_method_getMouseY_51(_args: Array = []) -> Variant:
	return null

func java_method_buildPlacementUI_52(_args: Array = []) -> Variant:
	return null

func java_method_buildUI_53(_args: Array = []) -> Variant:
	return null

func java_method_updateState_54(_args: Array = []) -> Variant:
	return null

func java_method_multiUnitSelect_55(_args: Array = []) -> Variant:
	return null

func java_method_selectUnitsRect_56(_args: Array = []) -> Variant:
	return null

func java_method_selectTypedUnits_57(_args: Array = []) -> Variant:
	return null

func java_method_tapCommandUnit_58(_args: Array = []) -> Variant:
	return null

func java_method_commandTap_59(_args: Array = []) -> Variant:
	return null

func java_method_commandTap_60(_args: Array = []) -> Variant:
	return null

func java_method_drawCommand_61(_args: Array = []) -> Variant:
	return null

func java_method_drawCommand_62(_args: Array = []) -> Variant:
	return null

func java_method_drawCommanded_63(_args: Array = []) -> Variant:
	return null

func java_method_drawCommandedTargets_64(_args: Array = []) -> Variant:
	return null

func java_method_drawCommanded_65(_args: Array = []) -> Variant:
	return null

func java_method_drawUnitSelection_66(_args: Array = []) -> Variant:
	return null

func java_method_drawOtherBuildPlans_67(_args: Array = []) -> Variant:
	return null

func java_method_drawBuildPlans_68(_args: Array = []) -> Variant:
	return null

func java_method_drawBottom_69(_args: Array = []) -> Variant:
	return null

func java_method_drawTop_70(_args: Array = []) -> Variant:
	return null

func java_method_drawOverSelect_71(_args: Array = []) -> Variant:
	return null

func java_method_drawSelected_72(_args: Array = []) -> Variant:
	return null

func java_method_drawBreaking_73(_args: Array = []) -> Variant:
	return null

func java_method_drawOverlapCheck_74(_args: Array = []) -> Variant:
	return null

func java_method_planMatches_75(_args: Array = []) -> Variant:
	return null

func java_method_drawBreaking_76(_args: Array = []) -> Variant:
	return null

func java_method_useSchematic_77(_args: Array = []) -> Variant:
	return null

func java_method_useSchematic_78(_args: Array = []) -> Variant:
	return null

func java_method_showSchematicSave_79(_args: Array = []) -> Variant:
	return null

func java_method_rotatePlans_80(_args: Array = []) -> Variant:
	return null

func java_method_flipPlans_81(_args: Array = []) -> Variant:
	return null

func java_method_schemOriginX_82(_args: Array = []) -> Variant:
	return null

func java_method_schemOriginY_83(_args: Array = []) -> Variant:
	return null

func java_method_getPlan_84(_args: Array = []) -> Variant:
	return null

func java_method_getPlan_85(_args: Array = []) -> Variant:
	return null

func java_method_drawBreakSelection_86(_args: Array = []) -> Variant:
	return null

func java_method_drawBreakSelection_87(_args: Array = []) -> Variant:
	return null

func java_method_drawRebuildSelection_88(_args: Array = []) -> Variant:
	return null

func java_method_drawBreakSelection_89(_args: Array = []) -> Variant:
	return null

func java_method_drawSelection_90(_args: Array = []) -> Variant:
	return null

func java_method_drawSelection_91(_args: Array = []) -> Variant:
	return null

func java_method_flushSelectPlans_92(_args: Array = []) -> Variant:
	return null

func java_method_flushPlansReverse_93(_args: Array = []) -> Variant:
	return null

func java_method_flushPlans_94(_args: Array = []) -> Variant:
	return null

func java_method_drawOverPlan_95(_args: Array = []) -> Variant:
	return null

func java_method_drawOverPlan_96(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_97(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_98(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_99(_args: Array = []) -> Variant:
	return null

func java_method_removeSelection_100(_args: Array = []) -> Variant:
	return null

func java_method_removeSelection_101(_args: Array = []) -> Variant:
	return null

func java_method_removeSelection_102(_args: Array = []) -> Variant:
	return null

func java_method_removeSelection_103(_args: Array = []) -> Variant:
	return null

func java_method_updateLine_104(_args: Array = []) -> Variant:
	return null

func java_method_updateLine_105(_args: Array = []) -> Variant:
	return null

func java_method_checkConfigTap_106(_args: Array = []) -> Variant:
	return null

func java_method_tileTapped_107(_args: Array = []) -> Variant:
	return null

func java_method_tryTapPlayer_108(_args: Array = []) -> Variant:
	return null

func java_method_canTapPlayer_109(_args: Array = []) -> Variant:
	return null

func java_method_tryBeginMine_110(_args: Array = []) -> Variant:
	return null

func java_method_tryStopMine_111(_args: Array = []) -> Variant:
	return null

func java_method_tryStopMine_112(_args: Array = []) -> Variant:
	return null

func java_method_tryRepairDerelict_113(_args: Array = []) -> Variant:
	return null

func java_method_canRepairDerelict_114(_args: Array = []) -> Variant:
	return null

func java_method_canMine_115(_args: Array = []) -> Variant:
	return null

func java_method_tileAt_116(_args: Array = []) -> Variant:
	return null

func java_method_rawTileX_117(_args: Array = []) -> Variant:
	return null

func java_method_rawTileY_118(_args: Array = []) -> Variant:
	return null

func java_method_tileX_119(_args: Array = []) -> Variant:
	return null

func java_method_tileY_120(_args: Array = []) -> Variant:
	return null

func java_method_panCamera_121(_args: Array = []) -> Variant:
	return null

func java_method_selectedBlock_122(_args: Array = []) -> Variant:
	return null

func java_method_isPlacing_123(_args: Array = []) -> Variant:
	return null

func java_method_isBreaking_124(_args: Array = []) -> Variant:
	return null

func java_method_isRebuildSelecting_125(_args: Array = []) -> Variant:
	return null

func java_method_mouseAngle_126(_args: Array = []) -> Variant:
	return null

func java_method_selectedUnit_127(_args: Array = []) -> Variant:
	return null

func java_method_selectedControlBuild_128(_args: Array = []) -> Variant:
	return null

func java_method_selectedCommandUnit_129(_args: Array = []) -> Variant:
	return null

func java_method_selectedEnemyUnit_130(_args: Array = []) -> Variant:
	return null

func java_method_selectedCommandBuildings_131(_args: Array = []) -> Variant:
	return null

func java_method_selectedCommandUnits_132(_args: Array = []) -> Variant:
	return null

func java_method_selectedCommandUnits_133(_args: Array = []) -> Variant:
	return null

func java_method_remove_134(_args: Array = []) -> Variant:
	return null

func java_method_add_135(_args: Array = []) -> Variant:
	return null

func java_method_canShoot_136(_args: Array = []) -> Variant:
	return null

func java_method_onConfigurable_137(_args: Array = []) -> Variant:
	return null

func java_method_isDroppingItem_138(_args: Array = []) -> Variant:
	return null

func java_method_canDropItem_139(_args: Array = []) -> Variant:
	return null

func java_method_tryDropItems_140(_args: Array = []) -> Variant:
	return null

func java_method_canDepositItem_141(_args: Array = []) -> Variant:
	return null

func java_method_rebuildArea_142(_args: Array = []) -> Variant:
	return null

func java_method_tryBreakBlock_143(_args: Array = []) -> Variant:
	return null

func java_method_validPlace_144(_args: Array = []) -> Variant:
	return null

func java_method_validPlace_145(_args: Array = []) -> Variant:
	return null

func java_method_validPlace_146(_args: Array = []) -> Variant:
	return null

func java_method_validBreak_147(_args: Array = []) -> Variant:
	return null

func java_method_breakBlock_148(_args: Array = []) -> Variant:
	return null

func java_method_drawArrow_149(_args: Array = []) -> Variant:
	return null

func java_method_drawArrow_150(_args: Array = []) -> Variant:
	return null

func java_method_iterateLine_151(_args: Array = []) -> Variant:
	return null
