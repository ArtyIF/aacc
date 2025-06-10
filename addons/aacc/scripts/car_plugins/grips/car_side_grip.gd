class_name CarSideGrip extends CarPluginBase

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_meta(&"ground_coefficient", 0.0)):
		return

	var force: float = -plugin_lvp.local_velocity_linear.x * car.mass
	car.set_force(&"side_grip", Vector3.RIGHT * force / delta, true)
