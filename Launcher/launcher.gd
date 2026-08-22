extends Node

const GAME_MAIN_SCENE := "res://Scenes/global.tscn"

func _ready() -> void:
	_promote_pending_update()

	var using_bundled := not FileAccess.file_exists(LauncherPaths.CACHED_PCK_PATH)
	var pck_path := _bundled_pck_path() if using_bundled else LauncherPaths.CACHED_PCK_PATH

	if not ProjectSettings.load_resource_pack(pck_path):
		printerr("Launcher: failed to load game pack at ", pck_path)
		if using_bundled:
			return

		printerr("Launcher: falling back to the bundled pack")
		using_bundled = true
		if not ProjectSettings.load_resource_pack(_bundled_pck_path()):
			printerr("Launcher: bundled pack failed to load too, nothing to run")
			return

	if using_bundled:
		_record_bundled_version()

	get_tree().change_scene_to_file.call_deferred(GAME_MAIN_SCENE)

func _promote_pending_update() -> void:
	var dir := DirAccess.open("user://")
	if dir.file_exists(LauncherPaths.PENDING_PCK_PATH):
		# Nothing has this session's pck open yet at this point, so the
		# rename that failed inside update_checker.gd's own session (the
		# active pck was still loaded and locked) can succeed here instead.
		dir.rename(LauncherPaths.PENDING_PCK_PATH, LauncherPaths.CACHED_PCK_PATH)

func _bundled_pck_path() -> String:
	return OS.get_executable_path().get_base_dir().path_join(LauncherPaths.BUNDLED_PCK_NAME)

func _bundled_version_path() -> String:
	return OS.get_executable_path().get_base_dir().path_join(LauncherPaths.BUNDLED_VERSION_NAME)

func _record_bundled_version() -> void:
	var version_path := _bundled_version_path()
	if not FileAccess.file_exists(version_path):
		return

	var version := FileAccess.get_file_as_string(version_path).strip_edges()
	if version == "":
		return

	var file := FileAccess.open(LauncherPaths.VERSION_MARKER_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(version)
