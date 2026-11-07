extends RefCounted
class_name SourceConstructBlockSourceTextState

const SOURCE_CONSTRUCT_BLOCK_SOURCE := "core/src/mindustry/world/blocks/ConstructBlock.java"
const SOURCE_CONSTRUCT_BUILD_CLASS_EXPR := "public class ConstructBuild extends Building{"

const SOURCE_CONSTRUCT_BLOCK_GET_METHOD := "public static ConstructBlock get(int size){"
const SOURCE_CONSTRUCT_BLOCK_GET_MAX_BLOCK_SIZE_GUARD_EXPR := "if(size > maxBlockSize) throw new IllegalArgumentException(\"No. Don't place ConstructBlocks of size greater than \" + maxBlockSize);"
const SOURCE_CONSTRUCT_BLOCK_GET_RETURN_EXPR := "return consBlocks[size - 1];"

const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_METHOD := "static boolean shouldPlay(){"
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_GUARD_EXPR := "if(Time.timeSinceMillis(lastPlayed) >= 32){"
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_LAST_PLAYED_EXPR := "lastPlayed = Time.millis();"
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_RETURN_TRUE_EXPR := "return true;"
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_RETURN_FALSE_EXPR := "return false;"

const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_METHOD := "static float calcPitch(boolean up){"
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_WINDOW_GUARD_EXPR := "if(Time.timeSinceMillis(lastTime) < 16 * 30){"
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_LAST_TIME_EXPR := "lastTime = Time.millis();"
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_INCREMENT_EXPR := "pitchSeq ++;"
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_RESET_GUARD_EXPR := "if(pitchSeq > 30){"
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_SEQUENCE_RETURN_EXPR := "return 1f + Mathf.clamp(pitchSeq / 30f) * (up ? 1.9f : -0.4f);"
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_RANDOM_RETURN_EXPR := "return Mathf.random(0.7f, 1.3f);"

const SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_METHOD := "public static void playRepairSound(Team team, Tile tile){"
const SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_EXPR := "if(!headless && shouldPlay() && fogControl.isVisibleTile(team, tile.x, tile.y)) Sounds.blockRepair.at(tile, calcPitch(true));"

const SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_METHOD := "public boolean isHidden(){"
const SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_RETURN_EXPR := "return true;"

const SOURCE_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_JAVA_METHOD := "java_method_deconstructFinish_1"
const SOURCE_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_JAVA_METHOD := "java_method_constructFinish_2"
const SOURCE_CONSTRUCT_BLOCK_CONSTRUCTED_JAVA_METHOD := "java_method_constructed_6"
const SOURCE_CONSTRUCT_BLOCK_GET_JAVA_METHOD := "java_method_get_0"
const SOURCE_CONSTRUCT_BLOCK_SHOULD_PLAY_JAVA_METHOD := "java_method_shouldPlay_3"
const SOURCE_CONSTRUCT_BLOCK_CALC_PITCH_JAVA_METHOD := "java_method_calcPitch_4"
const SOURCE_CONSTRUCT_BLOCK_PLAY_REPAIR_SOUND_JAVA_METHOD := "java_method_playRepairSound_5"
const SOURCE_CONSTRUCT_BLOCK_IS_HIDDEN_JAVA_METHOD := "java_method_isHidden_7"
const SOURCE_CONSTRUCT_BLOCK_DECONSTRUCT_FINISH_GENERATED_OWNER := "construct_block.java_method_deconstructFinish_1"
const SOURCE_CONSTRUCT_BLOCK_CONSTRUCT_FINISH_GENERATED_OWNER := "construct_block.java_method_constructFinish_2"
const SOURCE_CONSTRUCT_BLOCK_CONSTRUCTED_GENERATED_OWNER := "construct_block.java_method_constructed_6"
const SOURCE_CONSTRUCT_BLOCK_STATIC_HELPERS_GENERATED_OWNER := "construct_block.static_helpers"
