class_name CarSideGripBasic extends CarPluginBase

func process_plugin(delta: float) -> void:
	var force: float = -car.get_param("LocalLinearVelocity").x * car.mass
	car.add_force("SideGrip", Vector3.RIGHT * force / delta, true)
