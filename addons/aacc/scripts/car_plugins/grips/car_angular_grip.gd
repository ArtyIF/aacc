class_name CarAngularGrip extends CarPluginBase

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var torque: float = -car.get_param("LocalAngularVelocity").y * car.mass
	car.add_torque("AngularGrip", Vector3.UP * torque / delta, true)
