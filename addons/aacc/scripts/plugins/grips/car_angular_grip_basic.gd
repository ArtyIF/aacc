class_name CarAngularGripBasic extends CarPluginBase

func process_plugin(delta: float) -> void:
	var torque: float = -car.get_param("LocalAngularVelocity").y * car.mass
	car.add_torque("AngularGrip", Vector3.UP * torque / delta, true)
