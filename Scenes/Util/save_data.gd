class_name SaveData

const SAVE_PATH := "user://savegame.cfg"
const SECTION := "player"
const KEY_LAST_POSITION := "last_position"

static func save_last_position(pos: Vector2) -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, KEY_LAST_POSITION, pos)
	config.save(SAVE_PATH)

static func load_last_position() -> Variant:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return null
	return config.get_value(SECTION, KEY_LAST_POSITION, null)
