class_name ClickableArea
extends Polygon2D

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
