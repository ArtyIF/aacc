class_name CarAngularGrip extends CarPluginBase

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
		return

	var torque: float = -car.get_param(&"local_angular_velocity", Vector3.ZERO).y * car.mass
	car.set_torque(&"angular_grip", Vector3.UP * torque / delta, true)
