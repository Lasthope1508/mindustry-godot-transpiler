# Generated from Mindustry upstream.
# Source: mindustry/world/Block.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world"
const JAVA_KIND := "class"
const JAVA_NAME := "Block"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := ["Senseable"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "hasItems", "type": "boolean"}, {"modifiers": ["public"], "name": "hasLiquids", "type": "boolean"}, {"modifiers": ["public"], "name": "hasPower", "type": "boolean"}, {"modifiers": ["public"], "name": "outputsLiquid", "type": "boolean"}, {"modifiers": ["public"], "name": "consumesPower", "type": "boolean"}, {"modifiers": ["public"], "name": "outputsPower", "type": "boolean"}, {"modifiers": ["public"], "name": "connectedPower", "type": "boolean"}, {"modifiers": ["public"], "name": "conductivePower", "type": "boolean"}, {"modifiers": ["public"], "name": "outputsPayload", "type": "boolean"}, {"modifiers": ["public"], "name": "acceptsUnitPayloads", "type": "boolean"}, {"modifiers": ["public"], "name": "acceptsPayload", "type": "boolean"}, {"modifiers": ["public"], "name": "acceptsItems", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysAllowDeposit", "type": "boolean"}, {"modifiers": ["public"], "name": "depositCooldown", "type": "float"}, {"modifiers": ["public"], "name": "separateItemCapacity", "type": "boolean"}, {"modifiers": ["public"], "name": "itemCapacity", "type": "int"}, {"modifiers": ["public"], "name": "liquidCapacity", "type": "float"}, {"modifiers": ["public"], "name": "liquidPressure", "type": "float"}, {"modifiers": ["public"], "name": "outputFacing", "type": "boolean"}, {"modifiers": ["public"], "name": "noSideBlend", "type": "boolean"}, {"modifiers": ["public"], "name": "displayFlow", "type": "boolean"}, {"modifiers": ["public"], "name": "inEditor", "type": "boolean"}, {"modifiers": ["public"], "name": "editorConfigurable", "type": "boolean"}, {"modifiers": ["public"], "name": "lastConfig", "type": "Object"}, {"modifiers": ["public"], "name": "saveConfig", "type": "boolean"}, {"modifiers": ["public"], "name": "copyConfig", "type": "boolean"}, {"modifiers": ["public"], "name": "clearOnDoubleTap", "type": "boolean"}, {"modifiers": ["public"], "name": "update", "type": "boolean"}, {"modifiers": ["public"], "name": "destructible", "type": "boolean"}, {"modifiers": ["public"], "name": "unloadable", "type": "boolean"}, {"modifiers": ["public"], "name": "isDuct", "type": "boolean"}, {"modifiers": ["public"], "name": "allowResupply", "type": "boolean"}, {"modifiers": ["public"], "name": "solid", "type": "boolean"}, {"modifiers": ["public"], "name": "solidifes", "type": "boolean"}, {"modifiers": ["public"], "name": "teamPassable", "type": "boolean"}, {"modifiers": ["public"], "name": "underBullets", "type": "boolean"}, {"modifiers": ["public"], "name": "rotate", "type": "boolean"}, {"modifiers": ["public"], "name": "rotateDraw", "type": "boolean"}, {"modifiers": ["public"], "name": "rotateDrawEditor", "type": "boolean"}, {"modifiers": ["public"], "name": "visualRotationOffset", "type": "float"}, {"modifiers": ["public"], "name": "lockRotation", "type": "boolean"}, {"modifiers": ["public"], "name": "ignoreLineRotation", "type": "boolean"}, {"modifiers": ["public"], "name": "invertFlip", "type": "boolean"}, {"modifiers": ["public"], "name": "variants", "type": "int"}, {"modifiers": ["public"], "name": "drawArrow", "type": "boolean"}, {"modifiers": ["public"], "name": "drawTeamOverlay", "type": "boolean"}, {"modifiers": ["public"], "name": "saveData", "type": "boolean"}, {"modifiers": ["public"], "name": "breakable", "type": "boolean"}, {"modifiers": ["public"], "name": "unitMoveBreakable", "type": "boolean"}, {"modifiers": ["public"], "name": "rebuildable", "type": "boolean"}, {"modifiers": ["public"], "name": "privileged", "type": "boolean"}, {"modifiers": ["public"], "name": "requiresWater", "type": "boolean"}, {"modifiers": ["public"], "name": "placeableLiquid", "type": "boolean"}, {"modifiers": ["public"], "name": "placeablePlayer", "type": "boolean"}, {"modifiers": ["public"], "name": "placeableOn", "type": "boolean"}, {"modifiers": ["public"], "name": "insulated", "type": "boolean"}, {"modifiers": ["public"], "name": "squareSprite", "type": "boolean"}, {"modifiers": ["public"], "name": "absorbLasers", "type": "boolean"}, {"modifiers": ["public"], "name": "enableDrawStatus", "type": "boolean"}, {"modifiers": ["public"], "name": "drawDisabled", "type": "boolean"}, {"modifiers": ["public"], "name": "autoResetEnabled", "type": "boolean"}, {"modifiers": ["public"], "name": "noUpdateDisabled", "type": "boolean"}, {"modifiers": ["public"], "name": "updateInUnits", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysUpdateInUnits", "type": "boolean"}, {"modifiers": ["public"], "name": "canPickup", "type": "boolean"}, {"modifiers": ["public"], "name": "deconstructDropAllLiquid", "type": "boolean"}, {"modifiers": ["public"], "name": "useColor", "type": "boolean"}, {"modifiers": ["public"], "name": "itemDrop", "type": "Item"}, {"modifiers": ["public"], "name": "playerUnmineable", "type": "boolean"}, {"modifiers": ["public"], "name": "attributes", "type": "Attributes"}, {"modifiers": ["public"], "name": "scaledHealth", "type": "float"}, {"modifiers": ["public"], "name": "health", "type": "int"}, {"modifiers": ["public"], "name": "armor", "type": "float"}, {"modifiers": ["public"], "name": "baseExplosiveness", "type": "float"}, {"modifiers": ["public"], "name": "explosivenessScale", "type": "float"}, {"modifiers": ["public"], "name": "flammabilityScale", "type": "float"}, {"modifiers": ["public"], "name": "baseShake", "type": "float"}, {"modifiers": ["public"], "name": "destroyBullet", "type": "BulletType"}, {"modifiers": ["public"], "name": "destroyBulletSameTeam", "type": "boolean"}, {"modifiers": ["public"], "name": "lightLiquid", "type": "Liquid"}, {"modifiers": ["public"], "name": "drawCracks", "type": "boolean"}, {"modifiers": ["public"], "name": "createRubble", "type": "boolean"}, {"modifiers": ["public"], "name": "floating", "type": "boolean"}, {"modifiers": ["public"], "name": "size", "type": "int"}, {"modifiers": ["public"], "name": "offset", "type": "float"}, {"modifiers": ["public"], "name": "sizeOffset", "type": "int"}, {"modifiers": ["public"], "name": "clipSize", "type": "float"}, {"modifiers": ["public"], "name": "lightClipSize", "type": "float"}, {"modifiers": ["public"], "name": "placeOverlapRange", "type": "float"}, {"modifiers": ["public"], "name": "crushDamageMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "crushFragile", "type": "boolean"}, {"modifiers": ["public"], "name": "timers", "type": "int"}, {"modifiers": ["public"], "name": "cacheLayer", "type": "CacheLayer"}, {"modifiers": ["public"], "name": "drawDynamic", "type": "boolean"}, {"modifiers": ["public"], "name": "drawCached", "type": "boolean"}, {"modifiers": ["public"], "name": "buildingCacheLayer", "type": "BuildingCacheLayer"}, {"modifiers": ["public"], "name": "fillsTile", "type": "boolean"}, {"modifiers": ["public"], "name": "forceDark", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysReplace", "type": "boolean"}, {"modifiers": ["public"], "name": "replaceable", "type": "boolean"}, {"modifiers": ["public"], "name": "group", "type": "BlockGroup"}, {"modifiers": ["public"], "name": "flags", "type": "EnumSet"}, {"modifiers": ["public"], "name": "priority", "type": "float"}, {"modifiers": ["public"], "name": "unitCapModifier", "type": "int"}, {"modifiers": ["public"], "name": "configurable", "type": "boolean"}, {"modifiers": ["public"], "name": "configureSound", "type": "Sound"}, {"modifiers": ["public"], "name": "ignoreResizeConfig", "type": "boolean"}, {"modifiers": ["public"], "name": "commandable", "type": "boolean"}, {"modifiers": ["public"], "name": "allowConfigInventory", "type": "boolean"}, {"modifiers": ["public"], "name": "selectionRows", "type": "int"}, {"modifiers": ["public"], "name": "selectionColumns", "type": "int"}, {"modifiers": ["public"], "name": "logicConfigurable", "type": "boolean"}, {"modifiers": ["public"], "name": "delayLandingConfig", "type": "boolean"}, {"modifiers": ["public"], "name": "consumesTap", "type": "boolean"}, {"modifiers": ["public"], "name": "drawLiquidLight", "type": "boolean"}, {"modifiers": ["public"], "name": "envRequired", "type": "int"}, {"modifiers": ["public"], "name": "envEnabled", "type": "int"}, {"modifiers": ["public"], "name": "envDisabled", "type": "int"}, {"modifiers": ["public"], "name": "sync", "type": "boolean"}, {"modifiers": ["public"], "name": "conveyorPlacement", "type": "boolean"}, {"modifiers": ["public"], "name": "allowDiagonal", "type": "boolean"}, {"modifiers": ["public"], "name": "swapDiagonalPlacement", "type": "boolean"}, {"modifiers": ["public"], "name": "allowRectanglePlacement", "type": "boolean"}, {"modifiers": ["public"], "name": "schematicPriority", "type": "int"}, {"modifiers": ["public"], "name": "mapColor", "type": "Color"}, {"modifiers": ["public"], "name": "hasColor", "type": "boolean"}, {"modifiers": ["public"], "name": "targetable", "type": "boolean"}, {"modifiers": ["public"], "name": "attacks", "type": "boolean"}, {"modifiers": ["public"], "name": "suppressable", "type": "boolean"}, {"modifiers": ["public"], "name": "canOverdrive", "type": "boolean"}, {"modifiers": ["public"], "name": "outlineColor", "type": "Color"}, {"modifiers": ["public"], "name": "outlineIcon", "type": "boolean"}, {"modifiers": ["public"], "name": "outlineRadius", "type": "int"}, {"modifiers": ["public"], "name": "outlinedIcon", "type": "int"}, {"modifiers": ["public"], "name": "hasShadow", "type": "boolean"}, {"modifiers": ["public"], "name": "customShadow", "type": "boolean"}, {"modifiers": ["public"], "name": "placePitchChange", "type": "boolean"}, {"modifiers": ["public"], "name": "breakPitchChange", "type": "boolean"}, {"modifiers": ["public"], "name": "placeSound", "type": "Sound"}, {"modifiers": ["public"], "name": "breakSound", "type": "Sound"}, {"modifiers": ["public"], "name": "destroySound", "type": "Sound"}, {"modifiers": ["public"], "name": "destroySoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "destroyPitchMin", "type": "float"}, {"modifiers": ["public"], "name": "destroyPitchMax", "type": "float"}, {"modifiers": ["public"], "name": "albedo", "type": "float"}, {"modifiers": ["public"], "name": "lightColor", "type": "Color"}, {"modifiers": ["public"], "name": "emitLight", "type": "boolean"}, {"modifiers": ["public"], "name": "obstructsLight", "type": "boolean"}, {"modifiers": ["public"], "name": "lightRadius", "type": "float"}, {"modifiers": ["public"], "name": "fogRadius", "type": "int"}, {"modifiers": ["public"], "name": "ambientSound", "type": "Sound"}, {"modifiers": ["public"], "name": "ambientSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "requirements", "type": "ItemStack"}, {"modifiers": ["public"], "name": "category", "type": "Category"}, {"modifiers": ["public"], "name": "buildTime", "type": "float"}, {"modifiers": ["public"], "name": "buildVisibility", "type": "BuildVisibility"}, {"modifiers": ["public"], "name": "buildCostMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "deconstructThreshold", "type": "float"}, {"modifiers": ["public"], "name": "instantDeconstruct", "type": "boolean"}, {"modifiers": ["public"], "name": "instantBuild", "type": "boolean"}, {"modifiers": ["public"], "name": "ignoreBuildDarkness", "type": "boolean"}, {"modifiers": ["public"], "name": "placeEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "breakEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "destroyEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "researchCostMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "researchCostMultipliers", "type": "ObjectFloatMap"}, {"modifiers": ["public"], "name": "researchCost", "type": "ItemStack"}, {"modifiers": ["public"], "name": "forceTeam", "type": "Team"}, {"modifiers": ["public"], "name": "instantTransfer", "type": "boolean"}, {"modifiers": ["public"], "name": "quickRotate", "type": "boolean"}, {"modifiers": ["public"], "name": "allowDerelictRepair", "type": "boolean"}, {"modifiers": ["public"], "name": "subclass", "type": "Class"}, {"modifiers": ["public"], "name": "selectScroll", "type": "float"}, {"modifiers": ["public"], "name": "buildType", "type": "Prov"}, {"modifiers": ["public"], "name": "configurations", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "itemFilter", "type": "boolean"}, {"modifiers": ["public"], "name": "liquidFilter", "type": "boolean"}, {"modifiers": ["public"], "name": "consumers", "type": "Consume"}, {"modifiers": ["public"], "name": "optionalConsumers", "type": "Consume"}, {"modifiers": ["public"], "name": "nonOptionalConsumers", "type": "Consume"}, {"modifiers": ["public"], "name": "updateConsumers", "type": "Consume"}, {"modifiers": ["public"], "name": "hasConsumers", "type": "boolean"}, {"modifiers": ["public"], "name": "consPower", "type": "ConsumePower"}, {"modifiers": ["protected"], "name": "barMap", "type": "OrderedMap"}, {"modifiers": ["protected"], "name": "consumeBuilder", "type": "Seq"}, {"modifiers": ["protected"], "name": "generatedIcons", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "regionRotated1", "type": "int"}, {"modifiers": ["public"], "name": "regionRotated2", "type": "int"}, {"modifiers": ["public"], "name": "region", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "customShadowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "teamRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "teamRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "variantRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "variantShadowRegions", "type": "TextureRegion"}, {"modifiers": ["final", "protected", "static"], "name": "tempTiles", "type": "Seq"}, {"modifiers": ["final", "protected", "static"], "name": "tempBuilds", "type": "Seq"}, {"modifiers": ["final", "protected"], "name": "timerDump", "type": "int"}, {"modifiers": ["public"], "name": "dumpTime", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Block", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "drawBase", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawBaseCached", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawShadow", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "percentSolid", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "drawEnvironmentLight", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawSideRegion", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPotentialLinks", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlaceText", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "drawPlaceText", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "drawLine", "type": "boolean", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "drawOverlay", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "displayShadow", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "sumAttribute", "parameters": [{"name": "attr", "type": "Attribute", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getDisplayIcon", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getDisplayName", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "String"}, {"modifiers": ["public"], "name": "minimapColor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "getColor", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Color"}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canBreak", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "fromX", "type": "int", "varargs": false}, {"name": "fromY", "type": "int", "varargs": false}, {"name": "destination", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "synthetic", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "checkForceDark", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isDarkened", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "addBar", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "sup", "type": "Func", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeBar", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "listBars", "parameters": [], "return_type": "Iterable"}, {"modifiers": ["public"], "name": "addLiquidBar", "parameters": [{"name": "liq", "type": "Liquid", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addLiquidBar", "parameters": [{"name": "current", "type": "Func", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "consumesItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "consumesLiquid", "parameters": [{"name": "liq", "type": "Liquid", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canReplace", "parameters": [{"name": "other", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getReplacement", "parameters": [{"name": "req", "type": "BuildPlan", "varargs": false}, {"name": "plans", "type": "Seq", "varargs": false}], "return_type": "Block"}, {"modifiers": ["public"], "name": "changePlacementPath", "parameters": [{"name": "points", "type": "Seq", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "diagonalOn", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "changePlacementPath", "parameters": [{"name": "points", "type": "Seq", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "handlePlacementLine", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "configSenseable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "nextConfig", "parameters": [], "return_type": "Object"}, {"modifiers": ["public"], "name": "onNewPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawOtherPlayerPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawDefaultPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "findPlan", "parameters": [{"name": "list", "type": "Eachable", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["public", "static"], "name": "findPlan", "parameters": [{"name": "list", "type": "Eachable", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "size", "type": "int", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["public"], "name": "getPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "drawPlanConfig", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigCenter", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "content", "type": "Object", "varargs": false}, {"name": "region", "type": "String", "varargs": false}, {"name": "cross", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigCenter", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "content", "type": "Object", "varargs": false}, {"name": "region", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfigTop", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "planConfigClipSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "pointConfig", "parameters": [{"name": "config", "type": "Object", "varargs": false}, {"name": "transformer", "type": "Cons", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "configClear", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "config", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "config", "type": "Cons2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isAccessible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "nearbySide", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "index", "type": "int", "varargs": false}, {"name": "out", "type": "Point2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getEdges", "parameters": [], "return_type": "Point2"}, {"modifiers": ["public"], "name": "getInsideEdges", "parameters": [], "return_type": "Point2"}, {"modifiers": ["public"], "name": "iterateTaken", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "placer", "type": "Intc2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "makeIconRegions", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["protected"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getGeneratedIcons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "resetGeneratedIcons", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "variantRegions", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "hasBuilding", "parameters": [], "return_type": "boolean"}, {"modifiers": ["final", "public"], "name": "newBuilding", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "updateClipRadius", "parameters": [{"name": "radiusInWorldUnits", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "bounds", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rect", "type": "Rect", "varargs": false}], "return_type": "Rect"}, {"modifiers": ["public"], "name": "isMultiblock", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isVisible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isPlaceable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isBanned", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "supportsEnv", "parameters": [{"name": "env", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "buildEditorConfig", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onPicked", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getConfig", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "blockChanged", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeBegan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "previous", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeBegan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "previous", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeEnded", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "beforePlaceBegan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "previous", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "editorPicked", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isFloor", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isOverlay", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "asFloor", "parameters": [], "return_type": "Floor"}, {"modifiers": ["public"], "name": "isAir", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canBeBuilt", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "environmentBuildable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isStatic", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "findConsumer", "parameters": [{"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "hasConsumer", "parameters": [{"name": "cons", "type": "Consume", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "removeConsumer", "parameters": [{"name": "cons", "type": "Consume", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeConsumers", "parameters": [{"name": "b", "type": "Boolf", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "consumeLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": "ConsumeLiquid"}, {"modifiers": ["public"], "name": "consumeLiquids", "parameters": [{"name": "stacks", "type": "LiquidStack", "varargs": true}], "return_type": "ConsumeLiquids"}, {"modifiers": ["public"], "name": "consumePower", "parameters": [{"name": "powerPerTick", "type": "float", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumePowerCond", "parameters": [{"name": "usage", "type": "float", "varargs": false}, {"name": "cons", "type": "Boolf", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumePowerDynamic", "parameters": [{"name": "usage", "type": "Floatf", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumePowerDynamic", "parameters": [{"name": "displayed", "type": "float", "varargs": false}, {"name": "usage", "type": "Floatf", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumePowerBuffered", "parameters": [{"name": "powerCapacity", "type": "float", "varargs": false}], "return_type": "ConsumePower"}, {"modifiers": ["public"], "name": "consumeItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "ConsumeItems"}, {"modifiers": ["public"], "name": "consumeItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": "ConsumeItems"}, {"modifiers": ["public"], "name": "consumeItems", "parameters": [{"name": "items", "type": "ItemStack", "varargs": true}], "return_type": "ConsumeItems"}, {"modifiers": ["public"], "name": "consumeCoolant", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": "ConsumeCoolant"}, {"modifiers": ["public"], "name": "consumeCoolant", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "allowLiquid", "type": "boolean", "varargs": false}, {"name": "allowGas", "type": "boolean", "varargs": false}], "return_type": "ConsumeCoolant"}, {"modifiers": ["public"], "name": "consume", "parameters": [{"name": "consume", "type": "T", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "setupRequirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setupRequirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "visible", "type": "BuildVisibility", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}, {"name": "unlocked", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "requirements", "parameters": [{"name": "cat", "type": "Category", "varargs": false}, {"name": "visible", "type": "BuildVisibility", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "initBuilding", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "researchRequirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "getDependencies", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public"], "name": "logicVisible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "postInit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reinitializeConsumers", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkContentArrayCapacity", "parameters": [{"name": "items", "type": "int", "varargs": false}, {"name": "liquids", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "createIcons", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "planRotation", "parameters": [{"name": "rot", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "flipRotation", "parameters": [{"name": "req", "type": "BuildPlan", "varargs": false}, {"name": "x", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getPlanConfigs", "parameters": [{"name": "options", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "content", "type": "Content", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "senseObject", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "Object"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_drawBase_0(_args: Array = []) -> Variant:
	return null

func java_method_drawBaseCached_1(_args: Array = []) -> Variant:
	return null

func java_method_drawShadow_2(_args: Array = []) -> Variant:
	return null

func java_method_percentSolid_3(_args: Array = []) -> Variant:
	return null

func java_method_drawEnvironmentLight_4(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_5(_args: Array = []) -> Variant:
	return null

func java_method_drawSideRegion_6(_args: Array = []) -> Variant:
	return null

func java_method_drawPotentialLinks_7(_args: Array = []) -> Variant:
	return null

func java_method_drawPlaceText_8(_args: Array = []) -> Variant:
	return null

func java_method_drawPlaceText_9(_args: Array = []) -> Variant:
	return null

func java_method_drawOverlay_10(_args: Array = []) -> Variant:
	return null

func java_method_displayShadow_11(_args: Array = []) -> Variant:
	return null

func java_method_sumAttribute_12(_args: Array = []) -> Variant:
	return null

func java_method_getDisplayIcon_13(_args: Array = []) -> Variant:
	return null

func java_method_getDisplayName_14(_args: Array = []) -> Variant:
	return null

func java_method_minimapColor_15(_args: Array = []) -> Variant:
	return null

func java_method_getColor_16(_args: Array = []) -> Variant:
	return null

func java_method_outputsItems_17(_args: Array = []) -> Variant:
	var has_items: bool = bool(_args[0] if _args.size() > 0 else false)
	return {"source_owner": "PortGame.source_block_outputs_items_state", "source": "core/src/mindustry/world/Block.java", "field_comment": "/** If true, buildings have an ItemModule. */", "field_expr": "public @NoPatch boolean hasItems;", "method": "public boolean outputsItems(){", "return_expr": "return hasItems;", "has_items": has_items, "outputs_items": has_items}

func java_method_canPlaceOn_18(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	var team: Variant = _args[1] if _args.size() > 1 else null
	var rotation: int = int(_args[2] if _args.size() > 2 else 0)
	return {"source_owner": "PortGame.source_block_can_place_on_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** @return whether this block can be placed on the specified tile. */", "method": "public boolean canPlaceOn(Tile tile, Team team, int rotation){", "return_expr": "return true;", "tile": tile, "team": team, "rotation": rotation, "can_place": true}

func java_method_canBreak_19(_args: Array = []) -> Variant:
	var tile: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_block_can_break_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** @return whether this block can be broken on the specified tile. */", "method": "public boolean canBreak(Tile tile){", "return_expr": "return true;", "tile": tile, "can_break": true}

func java_method_rotatedOutput_20(_args: Array = []) -> Variant:
	var rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var x_value: int = int(_args[1] if _args.size() > 1 else 0)
	var y_value: int = int(_args[2] if _args.size() > 2 else 0)
	return {"source_owner": "PortGame.source_block_rotated_output_state", "source": "core/src/mindustry/world/Block.java", "field_comment": "/** whether this is rotatable */", "field_expr": "public boolean rotate;", "method": "public boolean rotatedOutput(int x, int y){", "return_expr": "return rotate;", "rotate": rotate_value, "x": x_value, "y": y_value, "rotated_output": rotate_value}

func java_method_rotatedOutput_21(_args: Array = []) -> Variant:
	var rotate_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var from_x: int = int(_args[1] if _args.size() > 1 else 0)
	var from_y: int = int(_args[2] if _args.size() > 2 else 0)
	var destination: Variant = _args[3] if _args.size() > 3 else null
	var base_state := {"source_owner": "PortGame.source_block_rotated_output_state", "source": "core/src/mindustry/world/Block.java", "field_comment": "/** whether this is rotatable */", "field_expr": "public boolean rotate;", "method": "public boolean rotatedOutput(int x, int y){", "return_expr": "return rotate;", "rotate": rotate_value, "x": from_x, "y": from_y, "rotated_output": rotate_value}
	return {"source_owner": "PortGame.source_block_rotated_output_tile_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean rotatedOutput(int fromX, int fromY, Tile destination){", "delegate_call": "rotatedOutput(fromX, fromY)", "return_expr": "return rotatedOutput(fromX, fromY);", "rotate": rotate_value, "fromX": from_x, "fromY": from_y, "destination": destination, "base_state": base_state, "rotated_output": base_state["rotated_output"]}

func java_method_synthetic_22(_args: Array = []) -> Variant:
	var update_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var destructible_value: bool = bool(_args[1] if _args.size() > 1 else false)
	var synthetic_value: bool = update_value or destructible_value
	return {"source_owner": "PortGame.source_block_synthetic_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean synthetic(){", "return_expr": "return update || destructible;", "update": update_value, "destructible": destructible_value, "synthetic": synthetic_value}

func java_method_checkForceDark_23(_args: Array = []) -> Variant:
	var force_dark_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var tile: Variant = _args[1] if _args.size() > 1 else null
	return {"source_owner": "PortGame.source_block_check_force_dark_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean checkForceDark(Tile tile){", "return_expr": "return forceDark;", "force_dark": force_dark_value, "tile": tile, "check_force_dark": force_dark_value}

func java_method_isDarkened_24(_args: Array = []) -> Variant:
	var solid_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var update_value: bool = bool(_args[1] if _args.size() > 1 else false)
	var destructible_value: bool = bool(_args[2] if _args.size() > 2 else false)
	var fills_tile_value: bool = bool(_args[3] if _args.size() > 3 else false)
	var force_dark_value: bool = bool(_args[4] if _args.size() > 4 else false)
	var tile: Variant = _args[5] if _args.size() > 5 else null
	var synthetic_state := {"source_owner": "PortGame.source_block_synthetic_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean synthetic(){", "return_expr": "return update || destructible;", "update": update_value, "destructible": destructible_value, "synthetic": update_value or destructible_value}
	var check_force_dark_state := {"source_owner": "PortGame.source_block_check_force_dark_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean checkForceDark(Tile tile){", "return_expr": "return forceDark;", "force_dark": force_dark_value, "tile": tile, "check_force_dark": force_dark_value}
	var is_darkened_value: bool = solid_value and ((not bool(synthetic_state["synthetic"]) and fills_tile_value) or bool(check_force_dark_state["check_force_dark"]))
	return {"source_owner": "PortGame.source_block_is_darkened_state", "source": "core/src/mindustry/world/Block.java", "comment": "/** If true, the 'map edge' darkness will be applied to this block. */", "method": "public boolean isDarkened(Tile tile){", "return_expr": "return solid && ((!synthetic() && fillsTile) || checkForceDark(tile));", "solid": solid_value, "fillsTile": fills_tile_value, "synthetic_state": synthetic_state, "check_force_dark_state": check_force_dark_state, "tile": tile, "is_darkened": is_darkened_value}

func java_method_setStats_25(_args: Array = []) -> Variant:
	return null

func java_method_addBar_26(_args: Array = []) -> Variant:
	return null

func java_method_removeBar_27(_args: Array = []) -> Variant:
	return null

func java_method_listBars_28(_args: Array = []) -> Variant:
	return null

func java_method_addLiquidBar_29(_args: Array = []) -> Variant:
	return null

func java_method_addLiquidBar_30(_args: Array = []) -> Variant:
	return null

func java_method_setBars_31(_args: Array = []) -> Variant:
	return null

func java_method_afterPatch_32(_args: Array = []) -> Variant:
	return null

func java_method_consumesItem_33(_args: Array = []) -> Variant:
	var item_filter: Array = _args[0] if _args.size() > 0 else []
	var item_id: int = int(_args[1] if _args.size() > 1 else 0)
	var item: Variant = _args[2] if _args.size() > 2 else null
	var consumes_item_value: bool = bool(item_filter[item_id])
	return {"source_owner": "PortGame.source_block_consumes_item_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean consumesItem(Item item){", "return_expr": "return itemFilter[item.id];", "itemFilter": item_filter, "item_id": item_id, "item": item, "consumes_item": consumes_item_value}

func java_method_consumesLiquid_34(_args: Array = []) -> Variant:
	var liquid_filter: Array = _args[0] if _args.size() > 0 else []
	var liquid_id: int = int(_args[1] if _args.size() > 1 else 0)
	var liq: Variant = _args[2] if _args.size() > 2 else null
	var consumes_liquid_value: bool = bool(liquid_filter[liquid_id])
	return {"source_owner": "PortGame.source_block_consumes_liquid_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean consumesLiquid(Liquid liq){", "return_expr": "return liquidFilter[liq.id];", "liquidFilter": liquid_filter, "liq_id": liquid_id, "liq": liq, "consumes_liquid": consumes_liquid_value}

func java_method_canReplace_35(_args: Array = []) -> Variant:
	return null

func java_method_getReplacement_36(_args: Array = []) -> Variant:
	return null

func java_method_changePlacementPath_37(_args: Array = []) -> Variant:
	return null

func java_method_changePlacementPath_38(_args: Array = []) -> Variant:
	return null

func java_method_handlePlacementLine_39(_args: Array = []) -> Variant:
	return null

func java_method_configSenseable_40(_args: Array = []) -> Variant:
	return null

func java_method_nextConfig_41(_args: Array = []) -> Variant:
	return null

func java_method_onNewPlan_42(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_43(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_44(_args: Array = []) -> Variant:
	return null

func java_method_drawOtherPlayerPlan_45(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_46(_args: Array = []) -> Variant:
	return null

func java_method_drawDefaultPlanRegion_47(_args: Array = []) -> Variant:
	return null

func java_method_findPlan_48(_args: Array = []) -> Variant:
	return null

func java_method_findPlan_49(_args: Array = []) -> Variant:
	return null

func java_method_getPlanRegion_50(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanConfig_51(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanConfigCenter_52(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanConfigCenter_53(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanConfigTop_54(_args: Array = []) -> Variant:
	return null

func java_method_planConfigClipSize_55(_args: Array = []) -> Variant:
	return null

func java_method_pointConfig_56(_args: Array = []) -> Variant:
	return null

func java_method_configClear_57(_args: Array = []) -> Variant:
	return null

func java_method_config_58(_args: Array = []) -> Variant:
	return null

func java_method_isAccessible_59(_args: Array = []) -> Variant:
	return null

func java_method_nearbySide_60(_args: Array = []) -> Variant:
	return null

func java_method_getEdges_61(_args: Array = []) -> Variant:
	return null

func java_method_getInsideEdges_62(_args: Array = []) -> Variant:
	return null

func java_method_iterateTaken_63(_args: Array = []) -> Variant:
	return null

func java_method_makeIconRegions_64(_args: Array = []) -> Variant:
	return null

func java_method_icons_65(_args: Array = []) -> Variant:
	return null

func java_method_getRegionsToOutline_66(_args: Array = []) -> Variant:
	return null

func java_method_getGeneratedIcons_67(_args: Array = []) -> Variant:
	return null

func java_method_resetGeneratedIcons_68(_args: Array = []) -> Variant:
	return null

func java_method_variantRegions_69(_args: Array = []) -> Variant:
	return null

func java_method_hasBuilding_70(_args: Array = []) -> Variant:
	var destructible_value: bool = bool(_args[0] if _args.size() > 0 else false)
	var update_value: bool = bool(_args[1] if _args.size() > 1 else false)
	var has_building_value: bool = destructible_value or update_value
	return {"source_owner": "PortGame.source_block_has_building_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean hasBuilding(){", "return_expr": "return destructible || update;", "destructible": destructible_value, "update": update_value, "has_building": has_building_value}

func java_method_newBuilding_71(_args: Array = []) -> Variant:
	return null

func java_method_updateClipRadius_72(_args: Array = []) -> Variant:
	return null

func java_method_bounds_73(_args: Array = []) -> Variant:
	return null

func java_method_isMultiblock_74(_args: Array = []) -> Variant:
	var size_value: int = int(_args[0] if _args.size() > 0 else 0)
	var is_multiblock_value: bool = size_value > 1
	return {"source_owner": "PortGame.source_block_is_multiblock_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean isMultiblock(){", "return_expr": "return size > 1;", "size": size_value, "is_multiblock": is_multiblock_value}

func java_method_isVisible_75(_args: Array = []) -> Variant:
	return null

func java_method_isPlaceable_76(_args: Array = []) -> Variant:
	return null

func java_method_isBanned_77(_args: Array = []) -> Variant:
	return null

func java_method_supportsEnv_78(_args: Array = []) -> Variant:
	return null

func java_method_buildEditorConfig_79(_args: Array = []) -> Variant:
	return null

func java_method_onPicked_80(_args: Array = []) -> Variant:
	return null

func java_method_getConfig_81(_args: Array = []) -> Variant:
	return null

func java_method_blockChanged_82(_args: Array = []) -> Variant:
	return null

func java_method_placeBegan_83(_args: Array = []) -> Variant:
	return null

func java_method_placeBegan_84(_args: Array = []) -> Variant:
	return null

func java_method_placeEnded_85(_args: Array = []) -> Variant:
	return null

func java_method_beforePlaceBegan_86(_args: Array = []) -> Variant:
	return null

func java_method_editorPicked_87(_args: Array = []) -> Variant:
	return null

func java_method_isFloor_88(_args: Array = []) -> Variant:
	return null

func java_method_isOverlay_89(_args: Array = []) -> Variant:
	return null

func java_method_asFloor_90(_args: Array = []) -> Variant:
	return null

func java_method_isAir_91(_args: Array = []) -> Variant:
	var id_value: int = int(_args[0] if _args.size() > 0 else 0)
	var is_air_value: bool = id_value == 0
	return {"source_owner": "PortGame.source_block_is_air_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean isAir(){", "return_expr": "return id == 0;", "id": id_value, "is_air": is_air_value}

func java_method_canBeBuilt_92(_args: Array = []) -> Variant:
	var build_visibility_value: String = str(_args[0] if _args.size() > 0 else "shown")
	var can_be_built_value: bool = build_visibility_value != "hidden" and build_visibility_value != "debugOnly"
	return {"source_owner": "PortGame.source_block_can_be_built_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean canBeBuilt(){", "return_expr": "return buildVisibility != BuildVisibility.hidden && buildVisibility != BuildVisibility.debugOnly;", "buildVisibility": build_visibility_value, "hidden_constant": "BuildVisibility.hidden", "debug_only_constant": "BuildVisibility.debugOnly", "can_be_built": can_be_built_value}

func java_method_environmentBuildable_93(_args: Array = []) -> Variant:
	return null

func java_method_isStatic_94(_args: Array = []) -> Variant:
	var cache_layer_value: String = str(_args[0] if _args.size() > 0 else "normal")
	var is_static_value: bool = cache_layer_value == "walls"
	return {"source_owner": "PortGame.source_block_is_static_state", "source": "core/src/mindustry/world/Block.java", "cache_layer_source": "core/src/mindustry/graphics/CacheLayer.java", "method": "public boolean isStatic(){", "return_expr": "return cacheLayer == CacheLayer.walls;", "cacheLayer": cache_layer_value, "walls_constant": "CacheLayer.walls", "is_static": is_static_value}

func java_method_findConsumer_95(_args: Array = []) -> Variant:
	return null

func java_method_hasConsumer_96(_args: Array = []) -> Variant:
	return null

func java_method_removeConsumer_97(_args: Array = []) -> Variant:
	return null

func java_method_removeConsumers_98(_args: Array = []) -> Variant:
	return null

func java_method_consumeLiquid_99(_args: Array = []) -> Variant:
	return null

func java_method_consumeLiquids_100(_args: Array = []) -> Variant:
	return null

func java_method_consumePower_101(_args: Array = []) -> Variant:
	return null

func java_method_consumePowerCond_102(_args: Array = []) -> Variant:
	return null

func java_method_consumePowerDynamic_103(_args: Array = []) -> Variant:
	return null

func java_method_consumePowerDynamic_104(_args: Array = []) -> Variant:
	return null

func java_method_consumePowerBuffered_105(_args: Array = []) -> Variant:
	return null

func java_method_consumeItem_106(_args: Array = []) -> Variant:
	return null

func java_method_consumeItem_107(_args: Array = []) -> Variant:
	return null

func java_method_consumeItems_108(_args: Array = []) -> Variant:
	return null

func java_method_consumeCoolant_109(_args: Array = []) -> Variant:
	return null

func java_method_consumeCoolant_110(_args: Array = []) -> Variant:
	return null

func java_method_consume_111(_args: Array = []) -> Variant:
	return null

func java_method_setupRequirements_112(_args: Array = []) -> Variant:
	return null

func java_method_setupRequirements_113(_args: Array = []) -> Variant:
	return null

func java_method_requirements_114(_args: Array = []) -> Variant:
	return null

func java_method_requirements_115(_args: Array = []) -> Variant:
	return null

func java_method_requirements_116(_args: Array = []) -> Variant:
	return null

func java_method_initBuilding_117(_args: Array = []) -> Variant:
	return null

func java_method_researchRequirements_118(_args: Array = []) -> Variant:
	return null

func java_method_getDependencies_119(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_120(_args: Array = []) -> Variant:
	return null

func java_method_logicVisible_121(_args: Array = []) -> Variant:
	return null

func java_method_postInit_122(_args: Array = []) -> Variant:
	return null

func java_method_init_123(_args: Array = []) -> Variant:
	return null

func java_method_reinitializeConsumers_124(_args: Array = []) -> Variant:
	return null

func java_method_checkContentArrayCapacity_125(_args: Array = []) -> Variant:
	return null

func java_method_load_126(_args: Array = []) -> Variant:
	return null

func java_method_isHidden_127(_args: Array = []) -> Variant:
	return null

func java_method_createIcons_128(_args: Array = []) -> Variant:
	return null

func java_method_planRotation_129(_args: Array = []) -> Variant:
	return null

func java_method_flipRotation_130(_args: Array = []) -> Variant:
	return null

func java_method_getPlanConfigs_131(_args: Array = []) -> Variant:
	return null

func java_method_sense_132(_args: Array = []) -> Variant:
	return null

func java_method_sense_133(_args: Array = []) -> Variant:
	return null

func java_method_senseObject_134(_args: Array = []) -> Variant:
	return null
