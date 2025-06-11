class_name CarSideGrip extends CarPluginBase

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func process_plugin(delta: float) -> void:
	if is_zero_approx(plugin_wp.ground_coefficient):
		return

	var force: float = -plugin_lvp.local_velocity_linear.x * car.mass
	car.set_force(&"side_grip", Vector3.RIGHT * force / delta, true)
