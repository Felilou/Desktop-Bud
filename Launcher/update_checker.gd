extends Node

const REPO := "Felilou/Desktop-Bud"
const LATEST_RELEASE_URL := "https://api.github.com/repos/%s/releases/latest" % REPO

func _ready() -> void:
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_latest_release_received)
	request.request(LATEST_RELEASE_URL, ["User-Agent: desktop-bud-launcher"])

func _on_latest_release_received(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return

	var release = JSON.parse_string(body.get_string_from_utf8())
	if typeof(release) != TYPE_DICTIONARY:
		return

	var latest_version := String(release.get("tag_name", ""))
	if latest_version == "" or latest_version == _read_installed_version():
		return

	var pck_url := _find_pck_asset_url(release.get("assets", []))
	if pck_url == "":
		return

	_download_pck(pck_url, latest_version)

func _find_pck_asset_url(assets: Array) -> String:
	for asset in assets:
		if typeof(asset) == TYPE_DICTIONARY and String(asset.get("name", "")).ends_with(".pck"):
			return String(asset.get("browser_download_url", ""))
	return ""

func _download_pck(url: String, version: String) -> void:
	var dir := DirAccess.open("user://")
	if dir.file_exists(LauncherPaths.PENDING_PCK_PATH):
		dir.remove(LauncherPaths.PENDING_PCK_PATH)

	var request := HTTPRequest.new()
	add_child(request)
	request.download_file = LauncherPaths.PENDING_PCK_PATH
	request.request_completed.connect(_on_pck_downloaded.bind(version))
	request.request(url)

func _on_pck_downloaded(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray, version: String) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return

	# The pending file is promoted to the active cache path on the NEXT
	# launch (launcher.gd, before anything loads it) rather than here - the
	# engine keeps this session's active .pck open for its whole run, and
	# renaming over an open file can silently fail on Windows.
	_write_installed_version(version)

func _read_installed_version() -> String:
	if not FileAccess.file_exists(LauncherPaths.VERSION_MARKER_PATH):
		return ""
	return FileAccess.get_file_as_string(LauncherPaths.VERSION_MARKER_PATH).strip_edges()

func _write_installed_version(version: String) -> void:
	var file := FileAccess.open(LauncherPaths.VERSION_MARKER_PATH, FileAccess.WRITE)
	if file == null:
		printerr("UpdateChecker: failed to write ", LauncherPaths.VERSION_MARKER_PATH)
		return
	file.store_string(version)
