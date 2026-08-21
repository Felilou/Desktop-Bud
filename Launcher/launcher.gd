extends Node

const BUNDLED_PCK_NAME := "desktop-bud.pck"
const CACHED_PCK_PATH := "user://desktop-bud.pck"
const GAME_MAIN_SCENE := "res://Scenes/global.tscn"

func _ready() -> void:
	var pck_path := CACHED_PCK_PATH if FileAccess.file_exists(CACHED_PCK_PATH) else _bundled_pck_path()

	if not ProjectSettings.load_resource_pack(pck_path):
		printerr("Launcher: failed to load game pack at ", pck_path)
		return

	get_tree().change_scene_to_file.call_deferred(GAME_MAIN_SCENE)

func _bundled_pck_path() -> String:
	return OS.get_executable_path().get_base_dir().path_join(BUNDLED_PCK_NAME)
