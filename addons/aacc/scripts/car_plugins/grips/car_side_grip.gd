class_name CarSideGrip extends CarPluginBase

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var force: float = -car.get_param("LocalLinearVelocity").x * car.mass
	car.set_force("SideGrip", Vector3.RIGHT * force / delta, true)
