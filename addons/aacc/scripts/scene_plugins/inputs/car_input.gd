class_name CarInput extends Node

@export var always_full_steer: bool = false
@export var full_steer_on_handbrake: bool = true

func _physics_process(delta: float) -> void:
	if not AACCGlobal.car: return

	var input_forward: float = clamp(Input.get_action_strength("aacc_forward"), 0.0, 1.0)
	var input_backward: float = clamp(Input.get_action_strength("aacc_backward"), 0.0, 1.0)
	var input_handbrake: float = 1.0 if Input.is_action_pressed("aacc_handbrake") else 0.0
	var input_steer: float = clamp(Input.get_action_strength("aacc_steer_right") - Input.get_action_strength("aacc_steer_left"), -1.0, 1.0)

	var velocity_z_sign: float = AACCGlobal.car.get_param("VelocityZSign")
	if is_zero_approx(velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			velocity_z_sign = 1.0

	if velocity_z_sign <= 0.0:
		AACCGlobal.car.set_input("Accelerate", input_forward)
		AACCGlobal.car.set_input("Reverse", 0.0)
		AACCGlobal.car.set_input("Brake", input_backward)
	elif velocity_z_sign > 0.0:
		AACCGlobal.car.set_input("Accelerate", 0.0)
		AACCGlobal.car.set_input("Reverse", input_backward)
		AACCGlobal.car.set_input("Brake", input_forward)
	AACCGlobal.car.set_input("Handbrake", input_handbrake)

	var input_full_steer: float = Input.is_action_pressed("aacc_handbrake") if full_steer_on_handbrake else 0.0

	# TODO: add an ability to have the car send the info somehow, otherwise this is delayed by a frame
	var distance_between_wheels: float = AACCGlobal.car.get_param("DistanceBetweenWheels", 1.0)
	var base_steer_velocity: float = AACCGlobal.car.get_param("BaseSteerVelocity", 1.0)
	var target_steer_velocity: float = AACCGlobal.car.get_param("TargetSteerVelocity", 1.0)
	var velocity_z: float = abs(AACCGlobal.car.get_param("LocalLinearVelocity", Vector3.ZERO).z)

	var input_steer_multiplier: float = 1.0
	if not always_full_steer:
		input_steer_multiplier = min(distance_between_wheels * (target_steer_velocity / base_steer_velocity) / velocity_z, 1.0)
		input_steer_multiplier = lerp(input_steer_multiplier, 1.0, input_full_steer)
	var input_steer_converted: float = input_steer * input_steer_multiplier

	AACCGlobal.car.set_input("Steer", input_steer_converted)
