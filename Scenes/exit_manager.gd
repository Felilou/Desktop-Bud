class_name ExitManager extends Node

signal exit_requested

const APP_ICON := preload("res://icon.svg")

var _indicator_id: int
var _popup: PopupMenu

func _ready() -> void:
	_popup = PopupMenu.new()
	_popup.add_item("Beenden", 0)
	_popup.id_pressed.connect(_on_popup_id_pressed)
	add_child(_popup)

	_indicator_id = DisplayServer.create_status_indicator(APP_ICON, "desktop-bud", _on_indicator_activated)

func _on_indicator_activated(_mouse_button: int, position: Vector2i) -> void:
	_popup.popup(Rect2i(position, Vector2i.ZERO))

func _on_popup_id_pressed(id: int) -> void:
	if id == 0:
		exit_requested.emit()

func _exit_tree() -> void:
	DisplayServer.delete_status_indicator(_indicator_id)
