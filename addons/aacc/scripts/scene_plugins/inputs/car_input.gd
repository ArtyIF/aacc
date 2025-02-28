class_name CarInput extends Node

@export var full_steer_on_handbrake: bool = true

func _physics_process(delta: float) -> void:
	if not AACCGlobal.car: return

	AACCGlobal.car.set_input("Accelerate", clamp(Input.get_action_strength("aacc_forward"), 0.0, 1.0))
	AACCGlobal.car.set_input("Brake", clamp(Input.get_action_strength("aacc_backward"), 0.0, 1.0))
	AACCGlobal.car.set_input("Handbrake", 1.0 if Input.is_action_pressed("aacc_handbrake") else 0.0)

	var input_steer: float = clamp(Input.get_action_strength("aacc_steer_right") - Input.get_action_strength("aacc_steer_left"), -1.0, 1.0)
	var input_full_steer: float = Input.is_action_pressed("aacc_handbrake") if full_steer_on_handbrake else 0.0
	
	var distance_between_wheels: float = AACCGlobal.car.get_param("DistanceBetweenWheels", 1.0)
	var base_steer_velocity: float = AACCGlobal.car.get_param("BaseSteerVelocity", 0.0)
	var target_steer_velocity: float = AACCGlobal.car.get_param("TargetSteerVelocity", 0.0)
	var velocity_z: float = abs(AACCGlobal.car.get_param("LocalLinearVelocity", Vector3.ZERO).z)

	var input_steer_multiplier: float = min(distance_between_wheels * (target_steer_velocity / base_steer_velocity) / velocity_z, 1.0)
	input_steer_multiplier = lerp(input_steer_multiplier, 1.0, input_full_steer)
	var input_steer_converted: float = input_steer * input_steer_multiplier

	AACCGlobal.car.set_input("Steer", input_steer_converted)
