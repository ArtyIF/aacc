class_name CarInputBasic extends Node

func _physics_process(delta: float) -> void:
	if not AACCGlobal.car: return

	var input_forward: float = clamp(Input.get_action_strength("aacc_forward"), 0.0, 1.0)
	var input_backward: float = clamp(Input.get_action_strength("aacc_backward"), 0.0, 1.0)
	var input_steer: float = clamp(Input.get_action_strength("aacc_steer_right") - Input.get_action_strength("aacc_steer_left"), -1.0, 1.0)

	var velocity_z_sign: float = AACCGlobal.car.get_param("VelocityZSign")
	if is_zero_approx(velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			velocity_z_sign = 1.0

	if velocity_z_sign < 0.0:
		AACCGlobal.car.set_input("Accelerate", input_forward)
		AACCGlobal.car.set_input("Brake", input_backward)
	elif velocity_z_sign > 0.0:
		AACCGlobal.car.set_input("Reverse", input_backward)
		AACCGlobal.car.set_input("Brake", input_forward)
	AACCGlobal.car.set_input("Steer", input_steer)
