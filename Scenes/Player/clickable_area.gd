class_name ClickableArea
extends Polygon2D

signal clicked
signal drag_started
signal drag_moved(new_position: Vector2)
signal drag_ended

const DRAG_THRESHOLD := 4.0

@onready var _area: Area2D = $Area2D
@onready var _collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D

var _pressed := false
var _dragging := false
var _press_position := Vector2.ZERO

func _ready() -> void:
	_collision_polygon.polygon = polygon
	_area.input_event.connect(_on_area_input_event)

func adapt_to_shape(_shape:Shape2D) -> void:
	#TODO: Polygone an gegebene form anpassen
	pass

func get_polygons_in_screen_transform() -> PackedVector2Array:
	var screen_transform = get_viewport().get_screen_transform()
	var res = PackedVector2Array()

	for poly:Vector2 in polygon:
		poly = screen_transform * (poly+global_position)
		res.append(poly)

	return res

func _on_area_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_pressed = true
		_dragging = false
		_press_position = event.position

func _unhandled_input(event: InputEvent) -> void:
	if not _pressed:
		return

	if event is InputEventMouseMotion:
		if not _dragging and _press_position.distance_to(event.position) > DRAG_THRESHOLD:
			_dragging = true
			drag_started.emit()
		if _dragging:
			drag_moved.emit(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_pressed = false
		if _dragging:
			_dragging = false
			drag_ended.emit()
		else:
			clicked.emit()
