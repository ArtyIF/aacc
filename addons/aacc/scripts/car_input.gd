## TODO: docs
class_name CarInput extends Node

@export var enabled: bool = true

func _ready() -> void:
	AACCGlobal.car_input = self

func _physics_process(delta: float) -> void:
	if not enabled: return
	if not AACCGlobal.car: return

	AACCGlobal.car.add_or_set_input("Forward", clamp(Input.get_action_strength("aacc_forward"), 0.0, 1.0))
	AACCGlobal.car.add_or_set_input("Backward", clamp(Input.get_action_strength("aacc_backward"), 0.0, 1.0))
	AACCGlobal.car.add_or_set_input("Steer", clamp(Input.get_action_strength("aacc_steer_right") - Input.get_action_strength("aacc_steer_left"), -1.0, 1.0))
	AACCGlobal.car.add_or_set_input("Handbrake", 1.0 if Input.is_action_pressed("aacc_handbrake") else 0.0)
