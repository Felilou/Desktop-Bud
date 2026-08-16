class_name PlayerTaskManager extends Node

signal goto(new_target:Vector2)
signal wait(seconds:float)
signal speak(message:String, seconds:float)
var signals : Array[Signal]

var rng:RandomNumberGenerator

func _create_random_target() -> Vector2:
	return Vector2(rng.randi_range(0, GlobalManager.viewport_manager_instance.screen_size.x), rng.randi_range(0, GlobalManager.viewport_manager_instance.screen_size.y))
	
func _random_seconds() -> float:
	return 3

func _init(player:Player):
	
	goto.connect(player.go_to_target)
	wait.connect(player.wait)
	speak.connect(player.say_something)

	signals.append(goto)
	signals.append(wait)
	signals.append(speak)
	
	rng = RandomNumberGenerator.new()

func give_random_task_to_player():
	var id = rng.randi_range(0, signals.size()-1)
	print("task id: ", id)
	match id:
		0: goto.emit(_create_random_target())
		1: wait.emit(_random_seconds())
		2: speak.emit("some message", _random_seconds())
