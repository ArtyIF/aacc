@icon("res://addons/aacc/icons/car_input.svg")
## TODO: docs
class_name CarInput extends Node

@onready var _car: Car = AACCGlobal.current_car

func _physics_process(delta: float) -> void:
	if not _car: return
	
	_car.input_forward = Input.get_action_strength("aacc_forward")
	_car.input_backward = Input.get_action_strength("aacc_backward")
	_car.input_steer = Input.get_action_strength("aacc_steer_right") - Input.get_action_strength("aacc_steer_left")
	_car.input_handbrake = Input.is_action_pressed("aacc_handbrake")
