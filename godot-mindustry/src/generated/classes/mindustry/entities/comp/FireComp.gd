# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/FireComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "FireComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Timedc", "Posc", "Syncc", "Drawc"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "frames", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "duration", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "spreadDelay", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "fireballDelay", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "ticksPerFrame", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "warmupDuration", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "damageDelay", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "tileDamage", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "unitDamage", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "regions", "type": "TextureRegion"}, {"modifiers": [], "name": "time", "type": "float"}, {"modifiers": [], "name": "lifetime", "type": "float"}, {"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "tile", "type": "Tile"}, {"modifiers": ["private", "transient"], "name": "puddleFlammability", "type": "float"}, {"modifiers": ["private", "transient"], "name": "damageTimer", "type": "float"}, {"modifiers": ["private", "transient"], "name": "spreadTimer", "type": "float"}, {"modifiers": ["private", "transient"], "name": "fireballTimer", "type": "float"}, {"modifiers": ["private", "transient"], "name": "warmup", "type": "float"}, {"modifiers": ["private", "transient"], "name": "animation", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "clipSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterRead", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterSync", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
