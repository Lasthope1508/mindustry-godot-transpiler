# Generated from Mindustry upstream.
# Source: mindustry/graphics/Drawf.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "Drawf"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "vecs", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "points", "type": "FloatSeq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "text", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "text", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "text", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}, {"name": "align", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "text", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}, {"name": "align", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "checkBleed", "parameters": [{"name": "pixmap", "type": "Pixmap", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "underwater", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "flame", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "divisions", "type": "int", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "pan", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "flameFront", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "divisions", "type": "int", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "point", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "baseX", "type": "float", "varargs": false}, {"name": "baseY", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "buildBeam", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "tx", "type": "float", "varargs": false}, {"name": "ty", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "additive", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "additive", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "additive", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "layer", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "additive", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "layer", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "additive", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "layer", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "additive", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "layer", "type": "float", "varargs": false}, {"name": "originX", "type": "float", "varargs": false}, {"name": "originY", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "limitLine", "parameters": [{"name": "start", "type": "Position", "varargs": false}, {"name": "dest", "type": "Position", "varargs": false}, {"name": "len1", "type": "float", "varargs": false}, {"name": "len2", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "limitLine", "parameters": [{"name": "start", "type": "Position", "varargs": false}, {"name": "dest", "type": "Position", "varargs": false}, {"name": "len1", "type": "float", "varargs": false}, {"name": "len2", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashLineDst", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashLine", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashLine", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "segments", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "line", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashLineBasic", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashSquare", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "size", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashRect", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "rect", "type": "Rect", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashRect", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashSquareBasic", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "size", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashRectBasic", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "target", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "target", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "text", "parameters": [], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "light", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "light", "parameters": [{"name": "pos", "type": "Position", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "light", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "light", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "opacity", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "light", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "light", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}, {"name": "tint", "type": "Color", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "selected", "parameters": [{"name": "tile", "type": "Building", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "selected", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "selected", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shadow", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "squareShadow", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shadow", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shadow", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shadow", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "shadow", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "height", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "liquid", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "liquid", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dashCircle", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "circles", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "circles", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rad", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "select", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "square", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "square", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "bgColor", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "square", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "bgColor", "type": "Color", "varargs": false}, {"name": "scaling", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "cross", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "poly", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "sides", "type": "int", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "fillPoly", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "sides", "type": "int", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "fillPoly", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "sides", "type": "int", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "bgColor", "type": "Color", "varargs": false}, {"name": "scl", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "square", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "square", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "square", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "arrow", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "arrow", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "laser", "parameters": [{"name": "line", "type": "TextureRegion", "varargs": false}, {"name": "edge", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "laser", "parameters": [{"name": "line", "type": "TextureRegion", "varargs": false}, {"name": "start", "type": "TextureRegion", "varargs": false}, {"name": "end", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "laser", "parameters": [{"name": "line", "type": "TextureRegion", "varargs": false}, {"name": "edge", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "laser", "parameters": [{"name": "line", "type": "TextureRegion", "varargs": false}, {"name": "start", "type": "TextureRegion", "varargs": false}, {"name": "end", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "laser", "parameters": [{"name": "line", "type": "TextureRegion", "varargs": false}, {"name": "start", "type": "TextureRegion", "varargs": false}, {"name": "end", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}, {"name": "light", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "tri", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "construct", "parameters": [{"name": "t", "type": "Building", "varargs": false}, {"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "progress", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "time", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "construct", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "progress", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "time", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "construct", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "progress", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "time", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "construct", "parameters": [{"name": "t", "type": "Building", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "progress", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "time", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "construct", "parameters": [{"name": "t", "type": "Building", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "progress", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "time", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "construct", "parameters": [{"name": "t", "type": "Building", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "progress", "type": "float", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}, {"name": "time", "type": "float", "varargs": false}, {"name": "size", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "spinSprite", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "r", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_text_0(_args: Array = []) -> Variant:
	return null

func java_method_text_1(_args: Array = []) -> Variant:
	return null

func java_method_text_2(_args: Array = []) -> Variant:
	return null

func java_method_text_3(_args: Array = []) -> Variant:
	return null

func java_method_checkBleed_4(_args: Array = []) -> Variant:
	return null

func java_method_underwater_5(_args: Array = []) -> Variant:
	return null

func java_method_flame_6(_args: Array = []) -> Variant:
	return null

func java_method_flameFront_7(_args: Array = []) -> Variant:
	return null

func java_method_point_8(_args: Array = []) -> Variant:
	return null

func java_method_buildBeam_9(_args: Array = []) -> Variant:
	return null

func java_method_additive_10(_args: Array = []) -> Variant:
	return null

func java_method_additive_11(_args: Array = []) -> Variant:
	return null

func java_method_additive_12(_args: Array = []) -> Variant:
	return null

func java_method_additive_13(_args: Array = []) -> Variant:
	return null

func java_method_additive_14(_args: Array = []) -> Variant:
	return null

func java_method_additive_15(_args: Array = []) -> Variant:
	return null

func java_method_limitLine_16(_args: Array = []) -> Variant:
	return null

func java_method_limitLine_17(_args: Array = []) -> Variant:
	return null

func java_method_dashLineDst_18(_args: Array = []) -> Variant:
	return null

func java_method_dashLine_19(_args: Array = []) -> Variant:
	return null

func java_method_dashLine_20(_args: Array = []) -> Variant:
	return null

func java_method_line_21(_args: Array = []) -> Variant:
	return null

func java_method_dashLineBasic_22(_args: Array = []) -> Variant:
	return null

func java_method_dashSquare_23(_args: Array = []) -> Variant:
	return null

func java_method_dashRect_24(_args: Array = []) -> Variant:
	return null

func java_method_dashRect_25(_args: Array = []) -> Variant:
	return null

func java_method_dashSquareBasic_26(_args: Array = []) -> Variant:
	return null

func java_method_dashRectBasic_27(_args: Array = []) -> Variant:
	return null

func java_method_target_28(_args: Array = []) -> Variant:
	return null

func java_method_target_29(_args: Array = []) -> Variant:
	return null

func java_method_text_30(_args: Array = []) -> Variant:
	return null

func java_method_light_31(_args: Array = []) -> Variant:
	return null

func java_method_light_32(_args: Array = []) -> Variant:
	return null

func java_method_light_33(_args: Array = []) -> Variant:
	return null

func java_method_light_34(_args: Array = []) -> Variant:
	return null

func java_method_light_35(_args: Array = []) -> Variant:
	return null

func java_method_light_36(_args: Array = []) -> Variant:
	return null

func java_method_selected_37(_args: Array = []) -> Variant:
	return null

func java_method_selected_38(_args: Array = []) -> Variant:
	return null

func java_method_selected_39(_args: Array = []) -> Variant:
	return null

func java_method_shadow_40(_args: Array = []) -> Variant:
	return null

func java_method_squareShadow_41(_args: Array = []) -> Variant:
	return null

func java_method_shadow_42(_args: Array = []) -> Variant:
	return null

func java_method_shadow_43(_args: Array = []) -> Variant:
	return null

func java_method_shadow_44(_args: Array = []) -> Variant:
	return null

func java_method_shadow_45(_args: Array = []) -> Variant:
	return null

func java_method_liquid_46(_args: Array = []) -> Variant:
	return null

func java_method_liquid_47(_args: Array = []) -> Variant:
	return null

func java_method_dashCircle_48(_args: Array = []) -> Variant:
	return null

func java_method_circles_49(_args: Array = []) -> Variant:
	return null

func java_method_circles_50(_args: Array = []) -> Variant:
	return null

func java_method_select_51(_args: Array = []) -> Variant:
	return null

func java_method_square_52(_args: Array = []) -> Variant:
	return null

func java_method_square_53(_args: Array = []) -> Variant:
	return null

func java_method_square_54(_args: Array = []) -> Variant:
	return null

func java_method_cross_55(_args: Array = []) -> Variant:
	return null

func java_method_poly_56(_args: Array = []) -> Variant:
	return null

func java_method_fillPoly_57(_args: Array = []) -> Variant:
	return null

func java_method_fillPoly_58(_args: Array = []) -> Variant:
	return null

func java_method_square_59(_args: Array = []) -> Variant:
	return null

func java_method_square_60(_args: Array = []) -> Variant:
	return null

func java_method_square_61(_args: Array = []) -> Variant:
	return null

func java_method_arrow_62(_args: Array = []) -> Variant:
	return null

func java_method_arrow_63(_args: Array = []) -> Variant:
	return null

func java_method_laser_64(_args: Array = []) -> Variant:
	return null

func java_method_laser_65(_args: Array = []) -> Variant:
	return null

func java_method_laser_66(_args: Array = []) -> Variant:
	return null

func java_method_laser_67(_args: Array = []) -> Variant:
	return null

func java_method_laser_68(_args: Array = []) -> Variant:
	return null

func java_method_tri_69(_args: Array = []) -> Variant:
	return null

func java_method_construct_70(_args: Array = []) -> Variant:
	return null

func java_method_construct_71(_args: Array = []) -> Variant:
	return null

func java_method_construct_72(_args: Array = []) -> Variant:
	return null

func java_method_construct_73(_args: Array = []) -> Variant:
	return null

func java_method_construct_74(_args: Array = []) -> Variant:
	return null

func java_method_construct_75(_args: Array = []) -> Variant:
	return null

func java_method_spinSprite_76(_args: Array = []) -> Variant:
	return null
