extends AnimatableBody2D

@export var speed = 400
var screen_size
@export var target = Vector2.ZERO
const offset = 2

enum Direction {NORTH, EAST, SOUTH, WEST}

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta: float):
	var vel = position.direction_to(target) * delta * speed
	var dist = position.distance_to(target)
	var dir = calc_direction_based_on_velocity(vel)
	var anim = calc_animation_based_on_direction_and_distance(dir, dist)
	$AnimatedSprite2D.play(anim)
	if  dist > offset:
		move_and_collide(vel)

func calc_direction_based_on_velocity(velocity:Vector2):
	if(velocity.x>0):
		return Direction.EAST
	if(velocity.x<0):
		return Direction.WEST
	if(velocity.y>0):
		return Direction.NORTH
	if(velocity.y<0):
		return Direction.SOUTH
	return Direction.EAST
	
func calc_animation_based_on_direction_and_distance(direction:Direction, distance:float):
	var anim;
	if(distance<offset):
		anim = "idle_"
	else:
		anim="walk_"
	
	match direction:
		Direction.NORTH:
			anim+="n"
		Direction.EAST:
			anim+="e"
		Direction.SOUTH:
			anim+="s"
		Direction.WEST:
			anim+="w"
	
	return anim
