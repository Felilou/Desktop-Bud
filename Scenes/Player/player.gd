class_name Player
extends Node2D

var body:PhysicsBody
var animator:AnimatedPlayerSprite
var clickable_area:ClickableArea
var speech_bubble:SpeechBubble

@export var target:Vector2 = Vector2.ZERO
@export var speed:float = 2000
@export var target_offset:float = 2

var _current_state:State
enum State {WALKING, WAITING_FOR_NEW_TASK, SITTING, WAITING, TALKING, DRAGGING}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_node("PhysicsBody")
	animator = get_node("PhysicsBody/Animation")
	clickable_area = get_node("PhysicsBody/Clickable Area")
	speech_bubble = get_node("PhysicsBody/SpeechBubble")
	clickable_area.clicked.connect(_on_clicked)
	clickable_area.drag_started.connect(_on_drag_started)
	clickable_area.drag_moved.connect(_on_drag_moved)
	clickable_area.drag_ended.connect(_on_drag_ended)
	_current_state = State.WAITING_FOR_NEW_TASK

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match _current_state:
		
		State.WAITING_FOR_NEW_TASK:
			animator.animate_waiting()
		
		State.WALKING:
			if(body.has_reached_target(target, target_offset)):
				_current_state = State.WAITING_FOR_NEW_TASK
			else:
				body.move_towards_target(target, speed)
				animator.animate_walking(body.calculate_direction_to_target(target))
		
		State.WAITING:
			if(animator.timer_ellapsed()):
				_current_state = State.WAITING_FOR_NEW_TASK
			else:
				animator.animate_waiting()
		
		State.TALKING:
			if(animator.timer_ellapsed()):
				_current_state = State.WAITING_FOR_NEW_TASK
			else:
				animator.animate_talking()

		State.DRAGGING, State.SITTING:
			animator.animate_waiting()

func go_to_target(new_target:Vector2) -> void:
	print("going to ", new_target)
	target = new_target
	_current_state = State.WALKING

func say_something(message:String, seconds:float) -> void:
	print("saying \"", message, "\" for ", seconds, " seconds")
	_current_state = State.TALKING
	animator.say_something(message, seconds)

func wait(seconds:float) -> void:
	print("waiting for ", seconds, " seconds")
	_current_state = State.WAITING
	animator.wait_x_seconds(seconds)

func get_current_state() -> State:
	return _current_state

func _on_clicked() -> void:
	if _current_state == State.SITTING:
		_current_state = State.WAITING_FOR_NEW_TASK

func _on_drag_started() -> void:
	animator.cancel_active_timer()
	_current_state = State.DRAGGING

func _on_drag_moved(new_position:Vector2) -> void:
	body.position = new_position

func _on_drag_ended() -> void:
	_current_state = State.SITTING
