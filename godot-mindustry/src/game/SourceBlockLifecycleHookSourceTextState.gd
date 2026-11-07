extends RefCounted
class_name SourceBlockLifecycleHookSourceTextState

const SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE := "core/src/mindustry/world/Block.java"

const SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_COMMENT := "/** Called to set up configuration UI in the editor. {@link #editorConfigurable} must be true. Config value should be assigned to lastConfig.*/"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_METHOD := "public void buildEditorConfig(Table table){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_JAVA_METHOD := "java_method_buildEditorConfig_79"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_GENERATED_OWNER := "block.java_method_buildEditorConfig_79"

const SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_COMMENT := "/** Called when the block is picked (middle click). Clientside only! */"
const SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_METHOD := "public void onPicked(Tile tile){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_JAVA_METHOD := "java_method_onPicked_80"
const SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_GENERATED_OWNER := "block.java_method_onPicked_80"

const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_COMMENT := "/** @return the config value returned when this block is picked on a certain tile. This is only called for non-buildings. */"
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_METHOD := "public Object getConfig(Tile tile){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_RETURN_EXPR := "return null;"
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_JAVA_METHOD := "java_method_getConfig_81"
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_GENERATED_OWNER := "block.java_method_getConfig_81"

const SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_COMMENT := "/** Called when this block is set on the specified tile. */"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_METHOD := "public void blockChanged(Tile tile){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_JAVA_METHOD := "java_method_blockChanged_82"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_GENERATED_OWNER := "block.java_method_blockChanged_82"

const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_COMMENT := "/** Called when building of this block begins. */"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_METHOD := "public void placeBegan(Tile tile, Block previous){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_JAVA_METHOD := "java_method_placeBegan_83"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_GENERATED_OWNER := "block.java_method_placeBegan_83"

const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_METHOD := "public void placeBegan(Tile tile, Block previous, @Nullable Unit builder){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_DELEGATE_EXPR := "placeBegan(tile, previous);"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_JAVA_METHOD := "java_method_placeBegan_84"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_GENERATED_OWNER := "block.java_method_placeBegan_84"

const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_COMMENT := "/** Called when building of this block ends. */"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_METHOD := "public void placeEnded(Tile tile, @Nullable Unit builder, int rotation, @Nullable Object config){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_JAVA_METHOD := "java_method_placeEnded_85"
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_GENERATED_OWNER := "block.java_method_placeEnded_85"

const SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_COMMENT := "/** Called right before building of this block begins. */"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_METHOD := "public void beforePlaceBegan(Tile tile, Block previous){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_JAVA_METHOD := "java_method_beforePlaceBegan_86"
const SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_GENERATED_OWNER := "block.java_method_beforePlaceBegan_86"

const SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_COMMENT := "/** Called when pick blocked in the editor. */"
const SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_METHOD := "public void editorPicked(Tile tile){"
const SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_JAVA_METHOD := "java_method_editorPicked_87"
const SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_GENERATED_OWNER := "block.java_method_editorPicked_87"
