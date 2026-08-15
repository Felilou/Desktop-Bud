class_name Hitbox extends CollisionShape2D

var clickable_area:Polygon2D
var screen_transform:Transform2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clickable_area = get_node("Clickable Area")
	screen_transform = get_viewport().get_screen_transform()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _get_clickable_area_polygons():
	var pols = clickable_area.polygon
	var res = PackedVector2Array()
	
	for vec:Vector2 in pols:
		vec = screen_transform * (vec+global_position)
		res.append(vec)
		
	return res
