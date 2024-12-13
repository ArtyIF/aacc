@icon("res://addons/aacc/icons/car_input.svg")
## TODO: docs
class_name CarInput extends Node

@export var enabled: bool = true
@onready var _car: Car = AACCGlobal.current_car

func _ready() -> void:
	AACCGlobal.current_car_input = self

func _physics_process(delta: float) -> void:
	if not enabled: return
	if not _car: return
	
	_car.input_forward = clamp(Input.get_action_strength("aacc_forward"), 0.0, 1.0)
	_car.input_backward = clamp(Input.get_action_strength("aacc_backward"), 0.0, 1.0)
	_car.input_steer = clamp(Input.get_action_strength("aacc_steer_right") - Input.get_action_strength("aacc_steer_left"), -1.0, 1.0)
	_car.input_handbrake = Input.is_action_pressed("aacc_handbrake")
