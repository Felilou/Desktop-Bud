class_name PlayerAnimation
extends AnimatedSprite2D

enum Animations {WALK, IDLE}

const animation_dict = {
	Animations.WALK: "walk",
	Animations.IDLE: "idle"
}

enum Directions {NORTH, EAST, SOUTH, WEST}

const direchtion_dict = {
	Directions.NORTH: "n",
	Directions.EAST: "e",
	Directions.SOUTH: "s",
	Directions.WEST: "w"
}

var space_char = "_"

var force_dir
var force_anim

var parent

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	play(_calculate_animation_based_on_current_state_and_direchtion())
	pass

func _calculate_direction():
	if(force_dir!=null&&force_dir is Directions):
		return force_dir
	
	var dir = parent._calculate_direction_to_target()
	
	if (abs(dir).x > abs(dir).y):
		if(dir.x>0):
			return Directions.EAST
		else:
			return Directions.WEST
	elif(abs(dir).x < abs(dir).y):
		if(dir.y>0):
			return Directions.SOUTH
		else:
			return Directions.NORTH
	
	return Directions.SOUTH

func _calculate_animation():
	if(force_anim!=null&&force_anim is Animations):
		return force_anim
	
	if(parent._has_reached_target()):
		return Animations.IDLE
	return Animations.WALK

func _calculate_animation_based_on_current_state_and_direchtion():
	var state = animation_dict[_calculate_animation()]
	var dir = direchtion_dict[_calculate_direction()]
	return state+space_char+dir

func _force_direction(direction:Directions):
	if(direction==-1):
		force_dir = null
	else:
		force_dir=direction

func _force_animation(animation_param:Animations):
	if(animation_param==-1):
		force_anim = null
	else:
		force_anim=animation
