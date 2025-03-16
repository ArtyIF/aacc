class_name CarSideGrip extends CarPluginBase

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
		return

	var force: float = -car.get_param(&"local_linear_velocity", Vector3.ZERO).x * car.mass
	car.set_force(&"side_grip", Vector3.RIGHT * force / delta, true)
