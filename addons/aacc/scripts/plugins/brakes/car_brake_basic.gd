class_name CarBrakeBasic extends CarPluginBase

@export var force_amount: float = 20000.0

func process_plugin(delta: float) -> void:
	var input_brake: float = car.get_input("Brake")
	var input_handbrake: float = car.get_input("Handbrake")

	var brake_speed: float = clamp(car.get_param("LocalLinearVelocity").z, -1.0, 1.0)
	var force: Vector3 = Vector3.FORWARD * max(input_brake, input_handbrake) * brake_speed * force_amount
	car.add_force("Brake", force)
