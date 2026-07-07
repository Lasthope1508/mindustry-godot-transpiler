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
	var consume_builder_contains: bool = bool(_args[0] if _args.size() > 0 else false)
	var cons: Variant = _args[1] if _args.size() > 1 else null
	return {"source_owner": "PortGame.source_block_has_consumer_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean hasConsumer(Consume cons){", "return_expr": "return consumeBuilder.contains(cons);", "consumeBuilder_contains": consume_builder_contains, "cons": cons, "has_consumer": consume_builder_contains}

func java_method_removeConsumer_97(_args: Array = []) -> Variant:
	var consumers_length: int = int(_args[0] if _args.size() > 0 else 0)
	var cons: Variant = _args[1] if _args.size() > 1 else null
	var illegal_state_exception_thrown: bool = consumers_length > 0
	var consume_builder_remove_called: bool = not illegal_state_exception_thrown
	return {"source_owner": "PortGame.source_block_remove_consumer_state", "source": "core/src/mindustry/world/Block.java", "method": "public void removeConsumer(Consume cons){", "guard_expr": "if(consumers.length > 0){", "exception_expr": "throw new IllegalStateException(\"You can only remove consumers before init(). After init(), all consumers have already been initialized.\");", "exception_message": "You can only remove consumers before init(). After init(), all consumers have already been initialized.", "remove_expr": "consumeBuilder.remove(cons);", "consumers_length": consumers_length, "cons": cons, "illegal_state_exception_thrown": illegal_state_exception_thrown, "consume_builder_remove_called": consume_builder_remove_called}

func java_method_removeConsumers_98(_args: Array = []) -> Variant:
	var consume_builder_contains_power_after_remove: bool = bool(_args[0] if _args.size() > 0 else false)
	var b: Variant = _args[1] if _args.size() > 1 else null
	var cons_power_cleared: bool = not consume_builder_contains_power_after_remove
	return {"source_owner": "PortGame.source_block_remove_consumers_state", "source": "core/src/mindustry/world/Block.java", "method": "public void removeConsumers(Boolf<Consume> b){", "remove_all_expr": "consumeBuilder.removeAll(b);", "comment": "//the power was removed, unassign it", "power_guard_expr": "if(!consumeBuilder.contains(c -> c instanceof ConsumePower)){", "cons_power_expr": "consPower = null;", "consumeBuilder_contains_power_after_remove": consume_builder_contains_power_after_remove, "b": b, "consume_builder_remove_all_called": true, "cons_power_cleared": cons_power_cleared}

func java_method_consumeLiquid_99(_args: Array = []) -> Variant:
	var liquid: Variant = _args[0] if _args.size() > 0 else null
	var amount: float = float(_args[1] if _args.size() > 1 else 0.0)
	var constructed_consume: Dictionary = {"type": "ConsumeLiquid", "liquid": liquid, "amount": amount}
	return {"source_owner": "PortGame.source_block_consume_liquid_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeLiquid consumeLiquid(Liquid liquid, float amount){", "return_expr": "return consume(new ConsumeLiquid(liquid, amount));", "constructor_expr": "new ConsumeLiquid(liquid, amount)", "consume_call_expr": "consume(new ConsumeLiquid(liquid, amount))", "liquid": liquid, "amount": amount, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumeLiquids_100(_args: Array = []) -> Variant:
	var stacks: Variant = _args[0] if _args.size() > 0 else []
	var constructed_consume: Dictionary = {"type": "ConsumeLiquids", "stacks": stacks}
	return {"source_owner": "PortGame.source_block_consume_liquids_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeLiquids consumeLiquids(LiquidStack... stacks){", "return_expr": "return consume(new ConsumeLiquids(stacks));", "constructor_expr": "new ConsumeLiquids(stacks)", "consume_call_expr": "consume(new ConsumeLiquids(stacks))", "stacks": stacks, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumePower_101(_args: Array = []) -> Variant:
	var power_per_tick: float = float(_args[0] if _args.size() > 0 else 0.0)
	var constructed_consume: Dictionary = {"type": "ConsumePower", "powerPerTick": power_per_tick, "capacity": 0.0, "buffered": false}
	return {"source_owner": "PortGame.source_block_consume_power_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which directly uses power without buffering it.", "param": "@param powerPerTick The amount of power which is required each tick for 100% efficiency.", "method": "public ConsumePower consumePower(float powerPerTick){", "return_expr": "return consume(new ConsumePower(powerPerTick, 0.0f, false));", "constructor_expr": "new ConsumePower(powerPerTick, 0.0f, false)", "consume_call_expr": "consume(new ConsumePower(powerPerTick, 0.0f, false))", "powerPerTick": power_per_tick, "capacity": 0.0, "buffered": false, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumePowerCond_102(_args: Array = []) -> Variant:
	var usage: float = float(_args[0] if _args.size() > 0 else 0.0)
	var cons: Variant = _args[1] if _args.size() > 1 else null
	var constructed_consume: Dictionary = {"type": "ConsumePowerCondition", "usage": usage, "condition": cons}
	return {"source_owner": "PortGame.source_block_consume_power_cond_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which only consumes power when the condition is met.", "method": "public <T extends Building> ConsumePower consumePowerCond(float usage, Boolf<T> cons){", "return_expr": "return consume(new ConsumePowerCondition(usage, (Boolf<Building>)cons));", "constructor_expr": "new ConsumePowerCondition(usage, (Boolf<Building>)cons)", "condition_cast_expr": "(Boolf<Building>)cons", "consume_call_expr": "consume(new ConsumePowerCondition(usage, (Boolf<Building>)cons))", "usage": usage, "condition": cons, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumePowerDynamic_103(_args: Array = []) -> Variant:
	var usage: Variant = _args[0] if _args.size() > 0 else null
	var constructed_consume: Dictionary = {"type": "ConsumePowerDynamic", "usage": usage}
	return {"source_owner": "PortGame.source_block_consume_power_dynamic_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer that consumes a dynamic amount of power.", "method": "public <T extends Building> ConsumePower consumePowerDynamic(Floatf<T> usage){", "return_expr": "return consume(new ConsumePowerDynamic((Floatf<Building>)usage));", "constructor_expr": "new ConsumePowerDynamic((Floatf<Building>)usage)", "usage_cast_expr": "(Floatf<Building>)usage", "consume_call_expr": "consume(new ConsumePowerDynamic((Floatf<Building>)usage))", "usage": usage, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumePowerDynamic_104(_args: Array = []) -> Variant:
	var displayed: float = float(_args[0] if _args.size() > 0 else 0.0)
	var usage: Variant = _args[1] if _args.size() > 1 else null
	var constructed_consume: Dictionary = {"type": "ConsumePowerDynamic", "displayed": displayed, "usage": usage}
	return {"source_owner": "PortGame.source_block_consume_power_dynamic_displayed_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer that consumes a dynamic amount of power.", "method": "public <T extends Building> ConsumePower consumePowerDynamic(float displayed, Floatf<T> usage){", "return_expr": "return consume(new ConsumePowerDynamic(displayed, (Floatf<Building>)usage));", "constructor_expr": "new ConsumePowerDynamic(displayed, (Floatf<Building>)usage)", "usage_cast_expr": "(Floatf<Building>)usage", "consume_call_expr": "consume(new ConsumePowerDynamic(displayed, (Floatf<Building>)usage))", "displayed": displayed, "usage": usage, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumePowerBuffered_105(_args: Array = []) -> Variant:
	var power_capacity: float = float(_args[0] if _args.size() > 0 else 0.0)
	var constructed_consume: Dictionary = {"type": "ConsumePower", "powerPerTick": 0.0, "capacity": power_capacity, "buffered": true}
	return {"source_owner": "PortGame.source_block_consume_power_buffered_state", "source": "core/src/mindustry/world/Block.java", "comment": "Creates a consumer which stores power.", "param": "@param powerCapacity The maximum capacity in power units.", "method": "public ConsumePower consumePowerBuffered(float powerCapacity){", "return_expr": "return consume(new ConsumePower(0f, powerCapacity, true));", "constructor_expr": "new ConsumePower(0f, powerCapacity, true)", "consume_call_expr": "consume(new ConsumePower(0f, powerCapacity, true))", "powerCapacity": power_capacity, "powerPerTick": 0.0, "buffered": true, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumeItem_106(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_block_consume_item_single_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItem(Item item){", "return_expr": "return consumeItem(item, 1);", "delegate_call_expr": "consumeItem(item, 1)", "item": item, "amount": 1, "delegate_called": true}

func java_method_consumeItem_107(_args: Array = []) -> Variant:
	var item: Variant = _args[0] if _args.size() > 0 else null
	var amount: int = int(_args[1] if _args.size() > 1 else 0)
	var item_stack: Dictionary = {"type": "ItemStack", "item": item, "amount": amount}
	var constructed_consume: Dictionary = {"type": "ConsumeItems", "items": [item_stack]}
	return {"source_owner": "PortGame.source_block_consume_item_amount_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItem(Item item, int amount){", "return_expr": "return consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}));", "item_stack_expr": "new ItemStack(item, amount)", "item_stack_array_expr": "new ItemStack[]{new ItemStack(item, amount)}", "constructor_expr": "new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)})", "consume_call_expr": "consume(new ConsumeItems(new ItemStack[]{new ItemStack(item, amount)}))", "item": item, "amount": amount, "item_stack": item_stack, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumeItems_108(_args: Array = []) -> Variant:
	var items: Array = _args
	var constructed_consume: Dictionary = {"type": "ConsumeItems", "items": items}
	return {"source_owner": "PortGame.source_block_consume_items_varargs_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeItems consumeItems(ItemStack... items){", "return_expr": "return consume(new ConsumeItems(items));", "constructor_expr": "new ConsumeItems(items)", "consume_call_expr": "consume(new ConsumeItems(items))", "items": items, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumeCoolant_109(_args: Array = []) -> Variant:
	var amount: float = float(_args[0] if _args.size() > 0 else 0.0)
	var constructed_consume: Dictionary = {"type": "ConsumeCoolant", "amount": amount}
	return {"source_owner": "PortGame.source_block_consume_coolant_single_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeCoolant consumeCoolant(float amount){", "return_expr": "return consume(new ConsumeCoolant(amount));", "constructor_expr": "new ConsumeCoolant(amount)", "consume_call_expr": "consume(new ConsumeCoolant(amount))", "amount": amount, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consumeCoolant_110(_args: Array = []) -> Variant:
	var amount: float = float(_args[0] if _args.size() > 0 else 0.0)
	var allow_liquid: bool = bool(_args[1] if _args.size() > 1 else false)
	var allow_gas: bool = bool(_args[2] if _args.size() > 2 else false)
	var constructed_consume: Dictionary = {"type": "ConsumeCoolant", "amount": amount, "allowLiquid": allow_liquid, "allowGas": allow_gas}
	return {"source_owner": "PortGame.source_block_consume_coolant_filtered_state", "source": "core/src/mindustry/world/Block.java", "method": "public ConsumeCoolant consumeCoolant(float amount, boolean allowLiquid, boolean allowGas){", "return_expr": "return consume(new ConsumeCoolant(amount, allowLiquid, allowGas));", "constructor_expr": "new ConsumeCoolant(amount, allowLiquid, allowGas)", "consume_call_expr": "consume(new ConsumeCoolant(amount, allowLiquid, allowGas))", "amount": amount, "allowLiquid": allow_liquid, "allowGas": allow_gas, "constructed_consume": constructed_consume, "consume_called": true}

func java_method_consume_111(_args: Array = []) -> Variant:
	var consume: Variant = _args[0] if _args.size() > 0 else null
	var consume_is_power: bool = bool(_args[1] if _args.size() > 1 else false)
	var consume_builder_before: Array = (_args[2] if _args.size() > 2 else []) as Array
	var consume_builder_without_power: Array = (_args[3] if _args.size() > 3 else []) as Array
	var cons_power_before: Variant = _args[4] if _args.size() > 4 else null
	var consume_builder_after: Array = consume_builder_without_power.duplicate() if consume_is_power else consume_builder_before.duplicate()
	consume_builder_after.append(consume)
	var remove_power_called: bool = consume_is_power
	var cons_power_after: Variant = consume if consume_is_power else cons_power_before
	return {"source_owner": "PortGame.source_block_consume_generic_state", "source": "core/src/mindustry/world/Block.java", "method": "public <T extends Consume> T consume(T consume){", "power_guard_expr": "if(consume instanceof ConsumePower){", "comment": "//there can only be one power consumer", "remove_power_expr": "consumeBuilder.removeAll(b -> b instanceof ConsumePower);", "cons_power_expr": "consPower = (ConsumePower)consume;", "add_expr": "consumeBuilder.add(consume);", "return_expr": "return consume;", "consume": consume, "consume_is_power": consume_is_power, "consume_builder_before": consume_builder_before, "consume_builder_without_power": consume_builder_without_power, "consume_builder_after": consume_builder_after, "cons_power_before": cons_power_before, "cons_power_after": cons_power_after, "remove_power_called": remove_power_called, "add_called": true, "returned_consume": consume}

func java_method_setupRequirements_112(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var stacks: Variant = _args[1] if _args.size() > 1 else null
	return {"source_owner": "PortGame.source_block_setup_requirements_simple_state", "source": "core/src/mindustry/world/Block.java", "method": "public void setupRequirements(Category cat, ItemStack[] stacks){", "delegate_call_expr": "requirements(cat, stacks)", "cat": cat, "stacks": stacks, "delegate_called": true}

func java_method_setupRequirements_113(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var build_visibility: Variant = _args[1] if _args.size() > 1 else null
	var stacks: Variant = _args[2] if _args.size() > 2 else null
	return {"source_owner": "PortGame.source_block_setup_requirements_visible_state", "source": "core/src/mindustry/world/Block.java", "method": "public void setupRequirements(Category cat, BuildVisibility visible, ItemStack[] stacks){", "delegate_call_expr": "requirements(cat, visible, stacks)", "cat": cat, "visible": build_visibility, "stacks": stacks, "delegate_called": true}

func java_method_requirements_114(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var stacks: Variant = _args[1] if _args.size() > 1 else null
	var unlocked: bool = bool(_args[2] if _args.size() > 2 else false)
	return {"source_owner": "PortGame.source_block_requirements_unlocked_state", "source": "core/src/mindustry/world/Block.java", "method": "public void requirements(Category cat, ItemStack[] stacks, boolean unlocked){", "delegate_call_expr": "requirements(cat, BuildVisibility.shown, stacks)", "always_unlocked_assignment_expr": "this.alwaysUnlocked = unlocked;", "cat": cat, "build_visibility": "BuildVisibility.shown", "stacks": stacks, "unlocked": unlocked, "delegate_called": true, "always_unlocked_assigned": true, "always_unlocked_after": unlocked}

func java_method_requirements_115(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var stacks: Variant = _args[1] if _args.size() > 1 else null
	return {"source_owner": "PortGame.source_block_requirements_simple_state", "source": "core/src/mindustry/world/Block.java", "method": "public void requirements(Category cat, ItemStack[] stacks){", "delegate_call_expr": "requirements(cat, BuildVisibility.shown, stacks)", "cat": cat, "build_visibility": "BuildVisibility.shown", "stacks": stacks, "delegate_called": true}

func java_method_requirements_116(_args: Array = []) -> Variant:
	var cat: Variant = _args[0] if _args.size() > 0 else null
	var build_visibility: Variant = _args[1] if _args.size() > 1 else null
	var stacks: Variant = _args[2] if _args.size() > 2 else null
	var requirements_after: Variant = stacks
	requirements_after.sort_custom(func(left, right):
		return int(left["item"]["id"]) < int(right["item"]["id"])
	)
	return {"source_owner": "PortGame.source_block_requirements_visible_state", "source": "core/src/mindustry/world/Block.java", "method": "public void requirements(Category cat, BuildVisibility visible, ItemStack[] stacks){", "comment": "/** Sets up requirements. Use only this method to set up requirements. */", "category_assignment_expr": "this.category = cat;", "requirements_assignment_expr": "this.requirements = stacks;", "build_visibility_assignment_expr": "this.buildVisibility = visible;", "sort_expr": "Arrays.sort(requirements, Structs.comparingInt(i -> i.item.id));", "cat": cat, "visible": build_visibility, "stacks": stacks, "category_after": cat, "requirements_after": requirements_after, "build_visibility_after": build_visibility, "sort_called": true}

func java_method_initBuilding_117(_args: Array = []) -> Variant:
	var build_type_before: Variant = _args[0] if _args.size() > 0 else null
	var default_assigned: bool = build_type_before == null
	var build_type_after: Variant = "Building::create" if default_assigned else build_type_before
	return {"source_owner": "PortGame.source_block_init_building_default_state", "source": "core/src/mindustry/world/Block.java", "method": "protected void initBuilding(){", "default_guard_expr": "if(buildType == null){", "default_comment": "//assign default value", "default_assignment_expr": "buildType = Building::create;", "build_type_before": build_type_before, "build_type_after": build_type_after, "default_assigned": default_assigned}

func java_method_researchRequirements_118(_args: Array = []) -> Variant:
	var research_cost: Variant = _args[0] if _args.size() > 0 else null
	var research_cost_multiplier: float = float(_args[1] if _args.size() > 1 else 1.0)
	var returned_early: bool = research_cost != null
	var returned_requirements: Variant = research_cost if returned_early else null
	if _args.size() <= 1:
		return {"source_owner": "PortGame.source_block_research_requirements_research_cost_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "return_expr": "return researchCost;", "research_cost": research_cost, "returned_requirements": returned_requirements, "returned_early": returned_early}
	var returned_empty: bool = research_cost == null and research_cost_multiplier <= 0.0
	var returned_requirements_after_multiplier: Variant = "ItemStack.empty" if returned_empty else returned_requirements
	if _args.size() <= 2:
		return {"source_owner": "PortGame.source_block_research_requirements_empty_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "empty_guard_expr": "if(researchCostMultiplier <= 0f) return ItemStack.empty;", "empty_return_expr": "return ItemStack.empty;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "returned_requirements": returned_requirements_after_multiplier, "returned_empty": returned_empty}
	var requirements: Array = _args[2] if _args.size() > 2 else []
	var allocation_reached: bool = research_cost == null and research_cost_multiplier > 0.0
	var allocated_out_length: int = requirements.size() if allocation_reached else 0
	var loop_indices: Array = []
	for i in range(allocated_out_length):
		loop_indices.append(i)
	if _args.size() <= 3:
		return {"source_owner": "PortGame.source_block_research_requirements_loop_shape_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "override_expr": "@Override", "research_cost_guard_expr": "if(researchCost != null) return researchCost;", "empty_guard_expr": "if(researchCostMultiplier <= 0f) return ItemStack.empty;", "out_alloc_expr": "ItemStack[] out = new ItemStack[requirements.length];", "loop_expr": "for(int i = 0; i < out.length; i++){", "return_out_expr": "return out;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "requirements": requirements, "allocation_reached": allocation_reached, "allocated_out_length": allocated_out_length, "loop_indices": loop_indices}
	var research_cost_multipliers: Dictionary = _args[3] if _args.size() > 3 else {}
	var quantity_values: Array = []
	var multiplier_values: Array = []
	var amount_power_values: Array = []
	for requirement in requirements:
		if not allocation_reached:
			continue
		var item_key: String = str(requirement.get("item", ""))
		var cost_multiplier: float = float(research_cost_multipliers.get(item_key, 1.0))
		var amount_power: float = pow(float(requirement.get("amount", 0.0)), 1.11)
		var quantity_float: float = 60.0 * research_cost_multiplier + amount_power * 20.0 * research_cost_multiplier * cost_multiplier
		var quantity: int = int(quantity_float / 10.0) * 10
		multiplier_values.append(cost_multiplier)
		amount_power_values.append(amount_power)
		quantity_values.append(quantity)
	if _args.size() <= 4:
		return {"source_owner": "PortGame.source_block_research_requirements_quantity_formula_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "quantity_expr": "int quantity = Mathf.round(60 * researchCostMultiplier + Mathf.pow(requirements[i].amount, 1.11f) * 20 * researchCostMultiplier * researchCostMultipliers.get(requirements[i].item, 1f), 10);", "mathf_round_expr": "Mathf.round(value, 10)", "mathf_round_step_expr": "return (int)(value / step) * step;", "research_cost": research_cost, "research_cost_multiplier": research_cost_multiplier, "requirements": requirements, "research_cost_multipliers": research_cost_multipliers, "quantity_values": quantity_values, "multiplier_values": multiplier_values, "amount_power_values": amount_power_values}
	var rounded_amount_values: Array = []
	for quantity in quantity_values:
		var rounded_amount: int = int(quantity)
		if rounded_amount >= 1000000000:
			rounded_amount = int(float(rounded_amount) / 100000000.0) * 100000000
		elif rounded_amount >= 1000000:
			rounded_amount = int(float(rounded_amount) / 100000.0) * 100000
		elif rounded_amount >= 10000:
			rounded_amount = int(float(rounded_amount) / 1000.0) * 1000
		elif rounded_amount >= 1000:
			rounded_amount = int(float(rounded_amount) / 100.0) * 100
		elif rounded_amount >= 100:
			rounded_amount = int(float(rounded_amount) / 100.0) * 100
		elif rounded_amount >= 10:
			rounded_amount = int(float(rounded_amount) / 10.0) * 10
		rounded_amount_values.append(rounded_amount)
	if _args.size() <= 5:
		return {"source_owner": "PortGame.source_block_research_requirements_round_amount_state", "source": "core/src/mindustry/world/Block.java", "ui_source": "core/src/mindustry/core/UI.java", "method": "public ItemStack[] researchRequirements(){", "round_amount_expr": "UI.roundAmount(quantity)", "ui_round_amount_method": "public static int roundAmount(int number){", "mathf_round_int_step_expr": "return (value / step) * step;", "quantity_values": quantity_values, "rounded_amount_values": rounded_amount_values}
	var output_requirements: Array = []
	for i in range(rounded_amount_values.size()):
		var requirement: Dictionary = requirements[i] if i < requirements.size() else {}
		output_requirements.append({"item": requirement.get("item"), "amount": rounded_amount_values[i]})
	return {"source_owner": "PortGame.source_block_research_requirements_output_fill_state", "source": "core/src/mindustry/world/Block.java", "method": "public ItemStack[] researchRequirements(){", "itemstack_fill_expr": "out[i] = new ItemStack(requirements[i].item, UI.roundAmount(quantity));", "return_out_expr": "return out;", "quantity_values": quantity_values, "rounded_amount_values": rounded_amount_values, "output_requirements": output_requirements, "returned_requirements": output_requirements}

func java_method_getDependencies_119(_args: Array = []) -> Variant:
	var requirements: Array = _args[0] if _args.size() > 0 else []
	var dependency_items: Array = []
	for requirement in requirements:
		dependency_items.append(requirement.get("item"))
	if _args.size() <= 1:
		return {"source_owner": "PortGame.source_block_get_dependencies_requirements_state", "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "requirements_comment": "//just requires items", "requirements_loop_expr": "for(ItemStack stack : requirements){", "cons_get_item_expr": "cons.get(stack.item);", "requirements": requirements, "dependency_items": dependency_items}
	var consume_builder: Array = _args[1] if _args.size() > 1 else []
	var consume_loop_indices: Array = []
	var skipped_optional_indices: Array = []
	var non_optional_indices: Array = []
	for i in range(consume_builder.size()):
		consume_loop_indices.append(i)
		var consume: Dictionary = consume_builder[i]
		if bool(consume.get("optional", false)):
			skipped_optional_indices.append(i)
			continue
		non_optional_indices.append(i)
	if _args.size() <= 2:
		return {"source_owner": "PortGame.source_block_get_dependencies_consume_builder_optional_state", "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "inputs_comment": "//also requires inputs", "consume_builder_loop_expr": "for(var c : consumeBuilder){", "optional_guard_expr": "if(c.optional) continue;", "requirements": requirements, "dependency_items": dependency_items, "consume_builder": consume_builder, "consume_loop_indices": consume_loop_indices, "skipped_optional_indices": skipped_optional_indices, "non_optional_indices": non_optional_indices}
	var consume_items_indices: Array = []
	var consume_item_dependency_items: Array = []
	for i in range(consume_builder.size()):
		var consume: Dictionary = consume_builder[i]
		if bool(consume.get("optional", false)):
			continue
		if str(consume.get("type", "")) != "ConsumeItems":
			continue
		consume_items_indices.append(i)
		for stack in consume.get("items", []):
			consume_item_dependency_items.append(stack.get("item"))
			dependency_items.append(stack.get("item"))
	return {"source_owner": "PortGame.source_block_get_dependencies_consume_items_state", "source": "core/src/mindustry/world/Block.java", "method": "public void getDependencies(Cons<UnlockableContent> cons){", "consume_items_guard_expr": "if(c instanceof ConsumeItems i){", "consume_items_loop_expr": "for(ItemStack stack : i.items){", "consume_items_cons_get_item_expr": "cons.get(stack.item);", "requirements": requirements, "dependency_items": dependency_items, "consume_builder": consume_builder, "consume_loop_indices": consume_loop_indices, "skipped_optional_indices": skipped_optional_indices, "non_optional_indices": non_optional_indices, "consume_items_indices": consume_items_indices, "consume_item_dependency_items": consume_item_dependency_items}

func java_method_getContentType_120(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_block_get_content_type_state", "source": "core/src/mindustry/world/Block.java", "method": "public ContentType getContentType(){", "content_type_return_expr": "return ContentType.block;", "content_type": "ContentType.block"}

func java_method_logicVisible_121(_args: Array = []) -> Variant:
	var build_visibility_value: String = str(_args[0] if _args.size() > 0 else "")
	var logic_visible: bool = build_visibility_value != "BuildVisibility.hidden"
	return {"source_owner": "PortGame.source_block_logic_visible_state", "source": "core/src/mindustry/world/Block.java", "method": "public boolean logicVisible(){", "logic_visible_return_expr": "return buildVisibility != BuildVisibility.hidden;", "build_visibility": build_visibility_value, "logic_visible": logic_visible}

func java_method_postInit_122(_args: Array = []) -> Variant:
	if _args.size() <= 2:
		pass
	else:
		var requirements: Array = _args[0] if _args.size() > 0 else []
		var shown_planets_before: Array = _args[1] if _args.size() > 1 else []
		var content_planets: Array = _args[2] if _args.size() > 2 else []
		var shown_planets_after: Array = shown_planets_before.duplicate()
		var auto_assign_guard_passed: bool = requirements.size() > 0 and shown_planets_before.is_empty()
		var evaluated_planets: Array = []
		var landable_planets: Array = []
		var added_planets: Array = []
		var blocked_planets: Array = []
		if auto_assign_guard_passed:
			for planet in content_planets:
				var planet_name: String = str(planet.get("name", ""))
				evaluated_planets.append(planet_name)
				if not bool(planet.get("is_landable", false)):
					continue
				landable_planets.append(planet_name)
				var blocking_requirement_indices: Array = []
				for i in range(requirements.size()):
					var stack: Dictionary = requirements[i]
					var is_on_planets: Array = stack.get("is_on_planets", [])
					if not is_on_planets.has(planet_name):
						blocking_requirement_indices.append(i)
				if blocking_requirement_indices.is_empty():
					shown_planets_after.append(planet_name)
					added_planets.append(planet_name)
				else:
					blocked_planets.append({"planet": planet_name, "blocking_requirement_indices": blocking_requirement_indices})
		return {"source_owner": "PortGame.source_block_post_init_shown_planets_state", "source": "core/src/mindustry/world/Block.java", "method": "public void postInit(){", "shown_planets_comment": "//usually, an empty set of planets is a configuration error. auto-assign based on requirements", "auto_assign_guard_expr": "if(requirements.length > 0 && shownPlanets.isEmpty()){", "content_planets_loop_expr": "for(Planet planet : content.planets()){", "planet_landable_guard_expr": "if(planet.isLandable()){", "structs_contains_guard_expr": "if(!Structs.contains(requirements, s -> !s.item.isOnPlanet(planet))){", "shown_planets_add_expr": "shownPlanets.add(planet);", "requirements": requirements, "shown_planets_before": shown_planets_before, "content_planets": content_planets, "shown_planets_after": shown_planets_after, "auto_assign_guard_passed": auto_assign_guard_passed, "evaluated_planets": evaluated_planets, "landable_planets": landable_planets, "added_planets": added_planets, "blocked_planets": blocked_planets}
	var database_tag_before: Variant = _args[0] if _args.size() > 0 else null
	var category_name: String = str(_args[1] if _args.size() > 1 else "")
	var database_tag_after: Variant = database_tag_before
	var database_tag_assigned: bool = database_tag_before == null or str(database_tag_before).is_empty()
	if database_tag_assigned:
		database_tag_after = category_name
	return {"source_owner": "PortGame.source_block_post_init_database_tag_state", "source": "core/src/mindustry/world/Block.java", "method": "public void postInit(){", "database_tag_guard_expr": "if(databaseTag == null || databaseTag.isEmpty()){", "database_tag_assign_expr": "databaseTag = category.name();", "super_post_init_expr": "super.postInit();", "database_tag_before": database_tag_before, "category_name": category_name, "database_tag_after": database_tag_after, "database_tag_assigned": database_tag_assigned}

func java_method_init_123(_args: Array = []) -> Variant:
	var init_bridge_mode: String = str(get_meta("mindustry_init_bridge_mode", "destroy_sound"))
	if init_bridge_mode == "custom_shadow":
		var custom_shadow: bool = bool(_args[0] if _args.size() > 0 else false)
		var has_shadow_before: bool = bool(_args[1] if _args.size() > 1 else true)
		var has_shadow_after: bool = has_shadow_before
		var has_shadow_assigned: bool = custom_shadow
		if has_shadow_assigned:
			has_shadow_after = false
		return {"source_owner": "PortGame.source_block_init_custom_shadow_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "custom_shadow_comment": "//disable standard shadow", "custom_shadow_guard_expr": "if(customShadow){", "has_shadow_assign_expr": "hasShadow = false;", "custom_shadow": custom_shadow, "has_shadow_before": has_shadow_before, "has_shadow_after": has_shadow_after, "has_shadow_assigned": has_shadow_assigned}
	if init_bridge_mode == "under_bullets":
		var under_bullets: bool = bool(_args[0] if _args.size() > 0 else false)
		var priority_before: Variant = _args[1] if _args.size() > 1 else null
		var priority_after: Variant = priority_before
		var priority_assigned: bool = under_bullets
		if priority_assigned:
			priority_after = "TargetPriority.under"
		return {"source_owner": "PortGame.source_block_init_under_bullets_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "under_bullets_guard_expr": "if(underBullets){", "priority_assign_expr": "priority = TargetPriority.under;", "target_priority_under_expr": "TargetPriority.under", "under_bullets": under_bullets, "priority_before": priority_before, "priority_after": priority_after, "priority_assigned": priority_assigned}
	if init_bridge_mode == "fog_radius_flag":
		var fog_radius: int = int(_args[0] if _args.size() > 0 else -1)
		var flags_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
		var flags_after: Array = flags_before.duplicate()
		var has_fog_radius_flag_added: bool = fog_radius > 0
		if has_fog_radius_flag_added and not flags_after.has("BlockFlag.hasFogRadius"):
			flags_after.append("BlockFlag.hasFogRadius")
		return {"source_owner": "PortGame.source_block_init_fog_radius_flag_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "fog_radius_guard_expr": "if(fogRadius > 0){", "flags_assign_expr": "flags = flags.with(BlockFlag.hasFogRadius);", "block_flag_has_fog_radius_expr": "BlockFlag.hasFogRadius", "fog_radius": fog_radius, "flags_before": flags_before, "flags_after": flags_after, "has_fog_radius_flag_added": has_fog_radius_flag_added}
	if init_bridge_mode == "sync_flag":
		var sync_value: bool = bool(_args[0] if _args.size() > 0 else false)
		var flags_before: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
		var flags_after: Array = flags_before.duplicate()
		var synced_flag_added: bool = sync_value
		if synced_flag_added and not flags_after.has("BlockFlag.synced"):
			flags_after.append("BlockFlag.synced")
		return {"source_owner": "PortGame.source_block_init_sync_flag_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "sync_guard_expr": "if(sync){", "flags_assign_expr": "flags = flags.with(BlockFlag.synced);", "block_flag_synced_expr": "BlockFlag.synced", "sync": sync_value, "flags_before": flags_before, "flags_after": flags_after, "synced_flag_added": synced_flag_added}
	if init_bridge_mode == "health_scaled":
		var health_before: int = int(_args[0] if _args.size() > 0 else -1)
		var health_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		var scaled_health: float = float(_args[2] if _args.size() > 2 else 0.0)
		var health_after: int = health_before
		var health_assigned: bool = health_before == -1 and scaled_health >= 0.0
		if health_assigned:
			health_after = int(health_size_value * health_size_value * scaled_health)
		return {"source_owner": "PortGame.source_block_init_health_scaled_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "health_comment": "//initialize default health based on size", "health_guard_expr": "if(health == -1){", "round_init_expr": "boolean round = false;", "scaled_health_negative_guard_expr": "if(scaledHealth < 0){", "health_assign_expr": "health = round ? Mathf.round(size * size * scaledHealth, 5) : (int)(size * size * scaledHealth);", "int_cast_expr": "(int)(size * size * scaledHealth)", "health_before": health_before, "size": health_size_value, "scaled_health": scaled_health, "round": false, "health_after": health_after, "health_assigned": health_assigned}
	if init_bridge_mode == "health_requirements_scaling":
		var health_before: int = int(_args[0] if _args.size() > 0 else -1)
		var requirements_health_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		var scaled_health_before: float = float(_args[2] if _args.size() > 2 else -1.0)
		var requirement_health_scalings: Array = (_args[3] as Array).duplicate() if _args.size() > 3 and _args[3] is Array else []
		var health_assigned: bool = health_before == -1 and scaled_health_before < 0.0
		var scaling: float = 1.0
		for health_scaling in requirement_health_scalings:
			scaling += float(health_scaling)
		var scaled_health_after: float = 40.0 * scaling if health_assigned else scaled_health_before
		var health_after: int = health_before
		if health_assigned:
			health_after = int(float(requirements_health_size_value * requirements_health_size_value) * scaled_health_after / 5.0) * 5
		return {"source_owner": "PortGame.source_block_init_health_requirements_scaling_state", "source": "core/src/mindustry/world/Block.java", "item_source": "core/src/mindustry/type/Item.java", "arc_mathf_source": "arc-core/src/arc/math/Mathf.java", "method": "public void init(){", "super_init_expr": "super.init();", "health_comment": "//initialize default health based on size", "health_guard_expr": "if(health == -1){", "scaled_health_negative_guard_expr": "if(scaledHealth < 0){", "scaled_health_default_expr": "scaledHealth = 40;", "scaling_init_expr": "float scaling = 1f;", "requirements_loop_expr": "for(var stack : requirements){", "health_scaling_add_expr": "scaling += stack.item.healthScaling;", "item_health_scaling_field_expr": "public float healthScaling = 0f;", "scaled_health_multiply_expr": "scaledHealth *= scaling;", "round_true_expr": "round = true;", "mathf_round_expr": "Mathf.round(size * size * scaledHealth, 5)", "mathf_round_step_expr": "return (int)(value / step) * step;", "health_before": health_before, "size": requirements_health_size_value, "scaled_health_before": scaled_health_before, "requirement_health_scalings": requirement_health_scalings, "scaling": scaling, "scaled_health_after": scaled_health_after, "round": health_assigned, "health_after": health_after, "health_assigned": health_assigned}
	if init_bridge_mode == "clip_size":
		var clip_size_before: float = float(_args[0] if _args.size() > 0 else 0.0)
		var clip_size_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		var source_tilesize: float = float(_args[2] if _args.size() > 2 else 8.0)
		var size_tilesize: float = float(clip_size_size_value) * source_tilesize
		var clip_size_after: float = max(clip_size_before, size_tilesize)
		return {"source_owner": "PortGame.source_block_init_clip_size_state", "source": "core/src/mindustry/world/Block.java", "vars_source": "core/src/mindustry/Vars.java", "method": "public void init(){", "super_init_expr": "super.init();", "clip_size_expr": "clipSize = Math.max(clipSize, size * tilesize);", "tilesize_comment": "/** size of tiles in units */", "tilesize_field_expr": "public static final int tilesize = 8;", "clip_size_before": clip_size_before, "size": clip_size_size_value, "source_tilesize": source_tilesize, "size_tilesize": size_tilesize, "clip_size_after": clip_size_after}
	if init_bridge_mode == "light_clip_size":
		var light_clip_size_before: float = float(_args[0] if _args.size() > 0 else 0.0)
		var clip_size: float = float(_args[1] if _args.size() > 1 else 0.0)
		var light_clip_size_after: float = max(light_clip_size_before, clip_size)
		return {"source_owner": "PortGame.source_block_init_light_clip_size_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "clip_size_expr": "clipSize = Math.max(clipSize, size * tilesize);", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, clipSize);", "light_clip_size_before": light_clip_size_before, "clip_size": clip_size, "light_clip_size_after": light_clip_size_after}
	if init_bridge_mode == "liquid_light":
		var has_liquids: bool = bool(_args[0] if _args.size() > 0 else false)
		var draw_liquid_light: bool = bool(_args[1] if _args.size() > 1 else false)
		var emit_light_before: bool = bool(_args[2] if _args.size() > 2 else false)
		var light_clip_size_before: float = float(_args[3] if _args.size() > 3 else 0.0)
		var liquid_light_size_value: int = int(_args[4] if _args.size() > 4 else 1)
		var liquid_light_gate: bool = has_liquids and draw_liquid_light
		var liquid_light_clip_size: float = float(liquid_light_size_value) * 30.0 * 2.0
		var emit_light_after: bool = true if liquid_light_gate else emit_light_before
		var light_clip_size_after: float = max(light_clip_size_before, liquid_light_clip_size) if liquid_light_gate else light_clip_size_before
		return {"source_owner": "PortGame.source_block_init_liquid_light_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "liquid_light_guard_expr": "if(hasLiquids && drawLiquidLight){", "emit_light_assign_expr": "emitLight = true;", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, size * 30f * 2f);", "has_liquids": has_liquids, "draw_liquid_light": draw_liquid_light, "emit_light_before": emit_light_before, "light_clip_size_before": light_clip_size_before, "size": liquid_light_size_value, "liquid_light_gate": liquid_light_gate, "liquid_light_clip_size": liquid_light_clip_size, "emit_light_after": emit_light_after, "light_clip_size_after": light_clip_size_after}
	if init_bridge_mode == "liquid_capacity_default":
		var liquid_capacity_before: float = float(_args[0] if _args.size() > 0 else -1.0)
		var liquid_capacity_assigned: bool = liquid_capacity_before < 0.0
		var consume_amount: float = 1.0
		var liquid_capacity_after: int = int(10.0 * consume_amount + 16384.5) - 16384 if liquid_capacity_assigned else int(liquid_capacity_before)
		return {"source_owner": "PortGame.source_block_init_liquid_capacity_default_state", "source": "core/src/mindustry/world/Block.java", "arc_mathf_source": "arc-core/src/arc/math/Mathf.java", "method": "public void init(){", "super_init_expr": "super.init();", "liquid_capacity_comment": "//some blocks don't have hasLiquids, but have liquid consumers/liquid capacity", "liquid_capacity_guard_expr": "if(liquidCapacity < 0){", "consume_amount_default_expr": "float consumeAmount = 1f;", "consume_builder_loop_expr": "for(var cons : consumeBuilder){", "liquid_capacity_assign_expr": "liquidCapacity = Mathf.round(10f * consumeAmount);", "mathf_round_expr": "return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;", "liquid_capacity_before": liquid_capacity_before, "consume_amount": consume_amount, "liquid_capacity_assigned": liquid_capacity_assigned, "liquid_capacity_after": liquid_capacity_after}
	if init_bridge_mode == "emit_light_radius":
		var emit_light: bool = bool(_args[0] if _args.size() > 0 else false)
		var light_clip_size_before: float = float(_args[1] if _args.size() > 1 else 0.0)
		var light_radius: float = float(_args[2] if _args.size() > 2 else 0.0)
		var light_radius_clip_size: float = light_radius * 2.0
		var light_clip_size_after: float = max(light_clip_size_before, light_radius_clip_size) if emit_light else light_clip_size_before
		return {"source_owner": "PortGame.source_block_init_emit_light_radius_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "emit_light_guard_expr": "if(emitLight){", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, lightRadius * 2f);", "emit_light": emit_light, "light_clip_size_before": light_clip_size_before, "light_radius": light_radius, "light_radius_clip_size": light_radius_clip_size, "light_clip_size_after": light_clip_size_after}
	if init_bridge_mode == "accepts_items":
		var block_group: Variant = _args[0] if _args.size() > 0 else ""
		var category_value: Variant = _args[1] if _args.size() > 1 else ""
		var accepts_items_before: bool = bool(_args[2] if _args.size() > 2 else false)
		var accepts_items_gate: bool = block_group == "BlockGroup.transportation" or category_value == "Category.distribution"
		var accepts_items_after: bool = true if accepts_items_gate else accepts_items_before
		return {"source_owner": "PortGame.source_block_init_accepts_items_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "accepts_items_guard_expr": "if(group == BlockGroup.transportation || category == Category.distribution){", "accepts_items_assign_expr": "acceptsItems = true;", "block_group": block_group, "category": category_value, "accepts_items_before": accepts_items_before, "accepts_items_gate": accepts_items_gate, "accepts_items_after": accepts_items_after}
	if init_bridge_mode == "offset":
		var offset_size_value: int = int(_args[0] if _args.size() > 0 else 1)
		var source_tilesize: float = float(_args[1] if _args.size() > 1 else 8.0)
		var offset_after: float = float((offset_size_value + 1) % 2) * source_tilesize / 2.0
		var size_offset_after: int = -int(float(offset_size_value - 1) / 2.0)
		return {"source_owner": "PortGame.source_block_init_offset_state", "source": "core/src/mindustry/world/Block.java", "vars_source": "core/src/mindustry/Vars.java", "method": "public void init(){", "super_init_expr": "super.init();", "offset_expr": "offset = ((size + 1) % 2) * tilesize / 2f;", "size_offset_expr": "sizeOffset = -((size - 1) / 2);", "tilesize_field_expr": "public static final int tilesize = 8;", "size": offset_size_value, "source_tilesize": source_tilesize, "offset_after": offset_after, "size_offset_after": size_offset_after}
	if init_bridge_mode == "build_time_requirements":
		var build_time_before: float = float(_args[0] if _args.size() > 0 else -1.0)
		var requirement_stacks: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
		var requirements_length: int = requirement_stacks.size()
		var build_time_assigned: bool = requirement_stacks.size() > 0 and build_time_before < 0.0
		var build_time_after: float = 0.0 if build_time_assigned else build_time_before
		if build_time_assigned:
			for stack in requirement_stacks:
				if stack is Dictionary:
					build_time_after += float(stack.get("amount", 0)) * float(stack.get("cost", 1.0))
		return {"source_owner": "PortGame.source_block_init_build_time_requirements_state", "source": "core/src/mindustry/world/Block.java", "item_source": "core/src/mindustry/type/Item.java", "item_stack_source": "core/src/mindustry/type/ItemStack.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_time_guard_expr": "if(requirements.length > 0 && buildTime < 0){", "build_time_zero_expr": "buildTime = 0f;", "requirements_loop_expr": "for(ItemStack stack : requirements){", "build_time_add_expr": "buildTime += stack.amount * stack.item.cost;", "item_cost_field_expr": "public float cost = 1f;", "itemstack_amount_field_expr": "public int amount = 0;", "build_time_before": build_time_before, "requirement_stacks": requirement_stacks, "requirements_length": requirements_length, "build_time_assigned": build_time_assigned, "build_time_after": build_time_after}
	if init_bridge_mode == "build_time_default":
		var default_build_time_before: float = float(_args[0] if _args.size() > 0 else -1.0)
		var build_time_assigned: bool = default_build_time_before < 0.0
		var build_time_after: float = 20.0 if build_time_assigned else default_build_time_before
		return {"source_owner": "PortGame.source_block_init_build_time_default_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_time_guard_expr": "if(buildTime < 0){", "build_time_default_expr": "buildTime = 20f;", "build_time_before": default_build_time_before, "build_time_assigned": build_time_assigned, "build_time_after": build_time_after}
	if init_bridge_mode == "build_time_multiplier":
		var multiplier_build_time_before: float = float(_args[0] if _args.size() > 0 else 20.0)
		var build_cost_multiplier: float = float(_args[1] if _args.size() > 1 else 1.0)
		var build_time_after: float = multiplier_build_time_before * build_cost_multiplier
		return {"source_owner": "PortGame.source_block_init_build_time_multiplier_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_cost_multiplier_field_expr": "public float buildCostMultiplier = 1f;", "build_time_multiplier_expr": "buildTime *= buildCostMultiplier;", "build_time_before": multiplier_build_time_before, "build_cost_multiplier": build_cost_multiplier, "build_time_after": build_time_after}
	if init_bridge_mode == "consumer_arrays":
		var consumer_builder_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
		var consumers: Array = consumer_builder_entries.duplicate()
		var optional_consumers: Array = []
		var non_optional_consumers: Array = []
		var update_consumers: Array = []
		for consumer in consumer_builder_entries:
			if not consumer is Dictionary:
				continue
			var ignored: bool = bool(consumer.get("ignored", false))
			if bool(consumer.get("optional", false)) and not ignored:
				optional_consumers.append(consumer)
			if not bool(consumer.get("optional", false)) and not ignored:
				non_optional_consumers.append(consumer)
			if bool(consumer.get("update", true)) and not ignored:
				update_consumers.append(consumer)
		var has_consumers: bool = consumers.size() > 0
		return {"source_owner": "PortGame.source_block_init_consumer_arrays_state", "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void init(){", "super_init_expr": "super.init();", "consumers_expr": "consumers = consumeBuilder.toArray(Consume.class);", "optional_consumers_expr": "optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);", "non_optional_consumers_expr": "nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);", "update_consumers_expr": "updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);", "has_consumers_expr": "hasConsumers = consumers.length > 0;", "consume_optional_field_expr": "public boolean optional;", "consume_update_field_expr": "public boolean update = true;", "consume_ignore_method_expr": "public boolean ignore(){", "consume_builder": consumer_builder_entries, "consumers": consumers, "optional_consumers": optional_consumers, "non_optional_consumers": non_optional_consumers, "update_consumers": update_consumers, "has_consumers": has_consumers}
	if init_bridge_mode == "item_liquid_filters":
		var content_items_size: int = int(_args[0] if _args.size() > 0 else 0)
		var content_liquids_size: int = int(_args[1] if _args.size() > 1 else 0)
		var item_filter: Array = []
		for _i in range(max(content_items_size, 0)):
			item_filter.append(false)
		var liquid_filter: Array = []
		for _i in range(max(content_liquids_size, 0)):
			liquid_filter.append(false)
		return {"source_owner": "PortGame.source_block_init_item_liquid_filters_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "item_filter_expr": "itemFilter = new boolean[content.items().size];", "liquid_filter_expr": "liquidFilter = new boolean[content.liquids().size];", "content_items_size": content_items_size, "content_liquids_size": content_liquids_size, "item_filter": item_filter, "liquid_filter": liquid_filter, "item_filter_size": item_filter.size(), "liquid_filter_size": liquid_filter.size()}
	if init_bridge_mode == "consumer_apply_loop":
		var consumer_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
		var apply_calls: Array = []
		for consumer in consumer_entries:
			apply_calls.append({"call": "cons.apply(this);", "consumer": consumer, "block_arg": "this"})
		return {"source_owner": "PortGame.source_block_init_consumer_apply_loop_state", "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void init(){", "super_init_expr": "super.init();", "consumers_loop_expr": "for(Consume cons : consumers){", "consume_apply_expr": "cons.apply(this);", "consume_apply_method_expr": "public void apply(Block block){", "consumers": consumer_entries, "apply_calls": apply_calls, "apply_call_count": apply_calls.size()}
	if init_bridge_mode == "set_bars_call":
		var set_bars_call: Dictionary = {"call": "setBars();", "method": "public void setBars(){"}
		return {"source_owner": "PortGame.source_block_init_set_bars_call_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "set_bars_expr": "setBars();", "set_bars_method_expr": "public void setBars(){", "health_bar_expr": "addBar(\"health\", entity -> new Bar(\"stat.health\", Pal.health, entity::healthf).blink(Color.white));", "set_bars_call": set_bars_call, "set_bars_called": true}
	if init_bridge_mode == "stats_categories":
		var stats_use_categories_before: bool = bool(_args[0] if _args.size() > 0 else false)
		var stats_use_categories_after: bool = true
		return {"source_owner": "PortGame.source_block_init_stats_categories_state", "source": "core/src/mindustry/world/Block.java", "stats_source": "core/src/mindustry/world/meta/Stats.java", "method": "public void init(){", "super_init_expr": "super.init();", "stats_use_categories_expr": "stats.useCategories = true;", "stats_use_categories_field_expr": "public boolean useCategories = false;", "stats_use_categories_before": stats_use_categories_before, "stats_use_categories_after": stats_use_categories_after}
	if init_bridge_mode == "logic_configurable":
		var logic_configurable_before: bool = bool(_args[0] if _args.size() > 0 else false)
		var config_key_assignable_to_unlockable_content: bool = bool(_args[1] if _args.size() > 1 else false)
		var logic_configurable_after: bool = logic_configurable_before or config_key_assignable_to_unlockable_content
		return {"source_owner": "PortGame.source_block_init_logic_configurable_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "logic_configurable_field_expr": "public boolean logicConfigurable = false;", "logic_configurable_guard_expr": "if(!logicConfigurable){", "configurations_each_expr": "configurations.each((key, val) -> {", "unlockable_assignable_expr": "if(UnlockableContent.class.isAssignableFrom(key)){", "logic_configurable_assignment_expr": "logicConfigurable = true;", "logic_configurable_before": logic_configurable_before, "config_key_assignable_to_unlockable_content": config_key_assignable_to_unlockable_content, "logic_configurable_after": logic_configurable_after}
	if init_bridge_mode == "buffered_power":
		var outputs_power: bool = bool(_args[0] if _args.size() > 0 else false)
		var has_cons_power: bool = bool(_args[1] if _args.size() > 1 else false)
		var cons_power_buffered_before: bool = bool(_args[2] if _args.size() > 2 else false)
		var buffered_power_disabled: bool = (not outputs_power) and has_cons_power and cons_power_buffered_before
		var cons_power_buffered_after: bool = false if buffered_power_disabled else cons_power_buffered_before
		return {"source_owner": "PortGame.source_block_init_buffered_power_state", "source": "core/src/mindustry/world/Block.java", "consume_power_source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public void init(){", "super_init_expr": "super.init();", "outputs_power_field_expr": "public boolean outputsPower = false;", "cons_power_field_expr": "public @Nullable ConsumePower consPower;", "consume_power_buffered_field_expr": "public boolean buffered;", "buffered_power_guard_expr": "if(!outputsPower && consPower != null && consPower.buffered){", "buffered_power_warn_expr": "Log.warn(\"Consumer using buffered power: @. Disabling buffered power.\", name);", "buffered_power_disable_expr": "consPower.buffered = false;", "outputs_power": outputs_power, "has_cons_power": has_cons_power, "cons_power_buffered_before": cons_power_buffered_before, "buffered_power_disabled": buffered_power_disabled, "cons_power_buffered_after": cons_power_buffered_after}
	if init_bridge_mode == "sandbox_visibility":
		var build_visibility: String = str(_args[0] if _args.size() > 0 else "BuildVisibility.hidden")
		var hide_details_before: bool = bool(_args[1] if _args.size() > 1 else true)
		var sandbox_visibility_applied: bool = build_visibility == "BuildVisibility.sandboxOnly"
		var hide_details_after: bool = false if sandbox_visibility_applied else hide_details_before
		return {"source_owner": "PortGame.source_block_init_sandbox_visibility_state", "source": "core/src/mindustry/world/Block.java", "build_visibility_source": "core/src/mindustry/world/meta/BuildVisibility.java", "unlockable_content_source": "core/src/mindustry/ctype/UnlockableContent.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_visibility_field_expr": "public BuildVisibility buildVisibility = BuildVisibility.hidden;", "hide_details_field_expr": "public boolean hideDetails = true;", "sandbox_visibility_guard_expr": "if(buildVisibility == BuildVisibility.sandboxOnly){", "sandbox_only_expr": "sandboxOnly = new BuildVisibility(() -> Vars.state == null || Vars.state.rules.infiniteResources),", "hide_details_assign_expr": "hideDetails = false;", "build_visibility": build_visibility, "hide_details_before": hide_details_before, "sandbox_visibility_applied": sandbox_visibility_applied, "hide_details_after": hide_details_after}
	if init_bridge_mode == "place_sound":
		var place_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"
		var place_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		var place_sound_after: Variant = place_sound_before
		var place_sound_assigned: bool = place_sound_before == "Sounds.unset"
		if place_sound_assigned:
			if place_size_value >= 3:
				place_sound_after = "Sounds.blockPlace3"
			elif place_size_value >= 2:
				place_sound_after = "Sounds.blockPlace2"
			else:
				place_sound_after = "Sounds.blockPlace1"
		return {"source_owner": "PortGame.source_block_init_place_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "place_sound_guard_expr": "if(placeSound == Sounds.unset){", "place_sound_assign_expr": "placeSound =", "place_sound_size_3_expr": "size >= 3 ? Sounds.blockPlace3 :", "place_sound_size_2_expr": "size >= 2 ? Sounds.blockPlace2 :", "place_sound_size_1_expr": "Sounds.blockPlace1;", "place_sound_before": place_sound_before, "size": place_size_value, "place_sound_after": place_sound_after, "place_sound_assigned": place_sound_assigned}
	if init_bridge_mode == "break_sound":
		var break_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"
		var break_size_value: int = int(_args[1] if _args.size() > 1 else 1)
		var break_sound_after: Variant = break_sound_before
		var break_sound_assigned: bool = break_sound_before == "Sounds.unset"
		if break_sound_assigned:
			if break_size_value >= 3:
				break_sound_after = "Sounds.blockBreak3"
			elif break_size_value >= 2:
				break_sound_after = "Sounds.blockBreak2"
			else:
				break_sound_after = "Sounds.blockBreak1"
		return {"source_owner": "PortGame.source_block_init_break_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "break_sound_guard_expr": "if(breakSound == Sounds.unset){", "break_sound_assign_expr": "breakSound =", "break_sound_size_3_expr": "size >= 3 ? Sounds.blockBreak3 :", "break_sound_size_2_expr": "size >= 2 ? Sounds.blockBreak2 :", "break_sound_size_1_expr": "Sounds.blockBreak1;", "break_sound_before": break_sound_before, "size": break_size_value, "break_sound_after": break_sound_after, "break_sound_assigned": break_sound_assigned}
	var destroy_sound_before: Variant = _args[0] if _args.size() > 0 else "Sounds.unset"
	var size_value: int = int(_args[1] if _args.size() > 1 else 1)
	var destroy_sound_after: Variant = destroy_sound_before
	var destroy_sound_assigned: bool = destroy_sound_before == "Sounds.unset"
	if destroy_sound_assigned:
		if size_value >= 3:
			destroy_sound_after = "Sounds.blockExplode3"
		elif size_value >= 2:
			destroy_sound_after = {"type": "RandomSound", "sounds": ["Sounds.blockExplode2", "Sounds.blockExplode2Alt"]}
		else:
			destroy_sound_after = {"type": "RandomSound", "sounds": ["Sounds.blockExplode1", "Sounds.blockExplode1Alt"]}
	return {"source_owner": "PortGame.source_block_init_destroy_sound_state", "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "destroy_sound_guard_expr": "if(destroySound == Sounds.unset){", "destroy_sound_assign_expr": "destroySound =", "destroy_sound_size_3_expr": "size >= 3 ? Sounds.blockExplode3 :", "destroy_sound_size_2_expr": "size >= 2 ? new RandomSound(Sounds.blockExplode2, Sounds.blockExplode2Alt) :", "destroy_sound_size_1_expr": "new RandomSound(Sounds.blockExplode1, Sounds.blockExplode1Alt);", "destroy_sound_before": destroy_sound_before, "size": size_value, "destroy_sound_after": destroy_sound_after, "destroy_sound_assigned": destroy_sound_assigned}

func java_method_reinitializeConsumers_124(_args: Array = []) -> Variant:
	var reinitialize_bridge_mode: String = str(get_meta("mindustry_reinitialize_consumers_bridge_mode", "consumer_arrays"))
	if reinitialize_bridge_mode == "consumer_apply_loop":
		var consumer_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
		var apply_calls: Array = []
		for consumer in consumer_entries:
			apply_calls.append({"call": "cons.apply(this);", "consumer": consumer, "block_arg": "this"})
		return {"source_owner": "PortGame.source_block_reinitialize_consumers_apply_loop_state", "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void reinitializeConsumers(){", "consumers_loop_expr": "for(Consume cons : consumers){", "consume_apply_expr": "cons.apply(this);", "consume_apply_method_expr": "public void apply(Block block){", "consumers": consumer_entries, "apply_calls": apply_calls, "apply_call_count": apply_calls.size()}
	if reinitialize_bridge_mode == "outputs_power":
		var outputs_power: bool = bool(_args[0] if _args.size() > 0 else false)
		var has_power_before: bool = bool(_args[1] if _args.size() > 1 else false)
		var has_power_after: bool = true if outputs_power else has_power_before
		return {"source_owner": "PortGame.source_block_reinitialize_consumers_outputs_power_state", "source": "core/src/mindustry/world/Block.java", "method": "public void reinitializeConsumers(){", "outputs_power_expr": "if(outputsPower) hasPower = true;", "outputs_power": outputs_power, "has_power_before": has_power_before, "has_power_after": has_power_after}
	if reinitialize_bridge_mode == "item_liquid_filters":
		var content_items_size: int = int(_args[0] if _args.size() > 0 else 0)
		var content_liquids_size: int = int(_args[1] if _args.size() > 1 else 0)
		var item_filter: Array = []
		for _i in range(max(content_items_size, 0)):
			item_filter.append(false)
		var liquid_filter: Array = []
		for _i in range(max(content_liquids_size, 0)):
			liquid_filter.append(false)
		return {"source_owner": "PortGame.source_block_reinitialize_consumers_item_liquid_filters_state", "source": "core/src/mindustry/world/Block.java", "method": "public void reinitializeConsumers(){", "item_filter_expr": "itemFilter = new boolean[content.items().size];", "liquid_filter_expr": "liquidFilter = new boolean[content.liquids().size];", "content_items_size": content_items_size, "content_liquids_size": content_liquids_size, "item_filter": item_filter, "liquid_filter": liquid_filter, "item_filter_size": item_filter.size(), "liquid_filter_size": liquid_filter.size()}
	var consumer_builder_entries: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var consumers: Array = consumer_builder_entries.duplicate()
	var cons_power: Variant = null
	var optional_consumers: Array = []
	var non_optional_consumers: Array = []
	var update_consumers: Array = []
	for consumer in consumer_builder_entries:
		if not consumer is Dictionary:
			continue
		var ignored: bool = bool(consumer.get("ignored", false))
		if cons_power == null and bool(consumer.get("is_consume_power", false)):
			cons_power = consumer
		if bool(consumer.get("optional", false)) and not ignored:
			optional_consumers.append(consumer)
		if not bool(consumer.get("optional", false)) and not ignored:
			non_optional_consumers.append(consumer)
		if bool(consumer.get("update", true)) and not ignored:
			update_consumers.append(consumer)
	var has_consumers: bool = consumers.size() > 0
	return {"source_owner": "PortGame.source_block_reinitialize_consumers_arrays_state", "source": "core/src/mindustry/world/Block.java", "consume_source": "core/src/mindustry/world/consumers/Consume.java", "method": "public void reinitializeConsumers(){", "consumers_expr": "consumers = consumeBuilder.toArray(Consume.class);", "cons_power_expr": "consPower = (ConsumePower)Structs.find(consumers, c -> c instanceof ConsumePower);", "optional_consumers_expr": "optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);", "non_optional_consumers_expr": "nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);", "update_consumers_expr": "updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);", "has_consumers_expr": "hasConsumers = consumers.length > 0;", "consume_optional_field_expr": "public boolean optional;", "consume_update_field_expr": "public boolean update = true;", "consume_ignore_method_expr": "public boolean ignore(){", "consume_is_power_expr": "c instanceof ConsumePower", "consume_builder": consumer_builder_entries, "consumers": consumers, "cons_power": cons_power, "optional_consumers": optional_consumers, "non_optional_consumers": non_optional_consumers, "update_consumers": update_consumers, "has_consumers": has_consumers}

func java_method_checkContentArrayCapacity_125(_args: Array = []) -> Variant:
	var item_filter: Array = (_args[0] as Array).duplicate() if _args.size() > 0 and _args[0] is Array else []
	var liquid_filter: Array = (_args[1] as Array).duplicate() if _args.size() > 1 and _args[1] is Array else []
	var items: int = int(_args[2] if _args.size() > 2 else item_filter.size())
	var liquids: int = int(_args[3] if _args.size() > 3 else liquid_filter.size())
	var item_filter_after: Array = []
	for i in range(max(items, 0)):
		item_filter_after.append(bool(item_filter[i]) if i < item_filter.size() else false)
	var liquid_filter_after: Array = []
	for i in range(max(liquids, 0)):
		liquid_filter_after.append(bool(liquid_filter[i]) if i < liquid_filter.size() else false)
	return {"source_owner": "PortGame.source_block_check_content_array_capacity_state", "source": "core/src/mindustry/world/Block.java", "method": "public void checkContentArrayCapacity(int items, int liquids){", "liquid_resize_expr": "if(liquidFilter.length != liquids) liquidFilter = Arrays.copyOf(liquidFilter, liquids);", "item_resize_expr": "if(itemFilter.length != items) itemFilter = Arrays.copyOf(itemFilter, items);", "item_filter_before": item_filter, "liquid_filter_before": liquid_filter, "items": items, "liquids": liquids, "item_filter_after": item_filter_after, "liquid_filter_after": liquid_filter_after}

func java_method_load_126(_args: Array = []) -> Variant:
	var name_value: String = str(_args[0] if _args.size() > 0 else "")
	var region_value: String = "Core.atlas.find(%s)" % name_value
	return {"source_owner": "PortGame.source_block_load_base_regions_state", "source": "core/src/mindustry/world/Block.java", "method": "public void load(){", "super_load_expr": "super.load();", "region_expr": "region = Core.atlas.find(name);", "content_regions_expr": "ContentRegions.loadRegions(this);", "name": name_value, "region": region_value, "super_load_called": true, "content_regions_loaded": true}

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
