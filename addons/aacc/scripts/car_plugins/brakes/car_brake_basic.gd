class_name CarBrakeBasic extends CarPluginBase

@export var force_amount: float = 20000.0

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var input_brake: float = car.get_input("Brake")
	var input_handbrake: float = car.get_input("Handbrake")
	var brake_amount: float = max(input_brake, input_handbrake)

	var brake_speed: float = clamp(car.get_param("LocalLinearVelocity").z, -1.0, 1.0)
	var force: Vector3 = Vector3.FORWARD * brake_amount * brake_speed * force_amount
	car.add_force("Brake", force, true)
