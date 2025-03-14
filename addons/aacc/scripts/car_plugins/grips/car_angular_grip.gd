class_name CarAngularGrip extends CarPluginBase

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("ground_coefficient")):
		return

	var torque: float = -car.get_param("local_angular_velocity").y * car.mass
	car.set_torque("AngularGrip", Vector3.UP * torque / delta, true)
