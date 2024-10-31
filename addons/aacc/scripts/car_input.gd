@icon("res://addons/aacc/icons/car_input.svg")
## TODO: docs
class_name CarInput extends Node

@export var controlled_car: Car

func _physics_process(delta: float) -> void:
	if not controlled_car: return
	
	controlled_car.input_forward = Input.get_action_strength("aacc_forward")
	controlled_car.input_backward = Input.get_action_strength("aacc_backward")
	controlled_car.input_steer = Input.get_action_strength("aacc_steer_right") - Input.get_action_strength("aacc_steer_left")
	controlled_car.input_handbrake = Input.is_action_pressed("aacc_handbrake")
