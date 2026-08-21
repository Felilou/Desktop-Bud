extends Node

const REPO := "Felilou/Desktop-Bud"
const LATEST_RELEASE_URL := "https://api.github.com/repos/%s/releases/latest" % REPO
const CACHED_PCK_PATH := "user://desktop-bud.pck"
const DOWNLOAD_TMP_PATH := CACHED_PCK_PATH + ".new"
const VERSION_MARKER_PATH := "user://installed_version.txt"

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
	if dir.file_exists(DOWNLOAD_TMP_PATH):
		dir.remove(DOWNLOAD_TMP_PATH)

	var request := HTTPRequest.new()
	add_child(request)
	request.download_file = DOWNLOAD_TMP_PATH
	request.request_completed.connect(_on_pck_downloaded.bind(version))
	request.request(url)

func _on_pck_downloaded(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray, version: String) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return

	var dir := DirAccess.open("user://")
	if dir.rename(DOWNLOAD_TMP_PATH, CACHED_PCK_PATH) == OK:
		_write_installed_version(version)

func _read_installed_version() -> String:
	if not FileAccess.file_exists(VERSION_MARKER_PATH):
		return ""
	return FileAccess.get_file_as_string(VERSION_MARKER_PATH).strip_edges()

func _write_installed_version(version: String) -> void:
	var file := FileAccess.open(VERSION_MARKER_PATH, FileAccess.WRITE)
	file.store_string(version)
