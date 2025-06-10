class_name CarAngularGrip extends CarPluginBase

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_meta(&"ground_coefficient", 0.0)):
		return

	var torque: float = -plugin_lvp.local_velocity_angular.y * car.mass
	car.set_torque(&"angular_grip", Vector3.UP * torque / delta, true)
