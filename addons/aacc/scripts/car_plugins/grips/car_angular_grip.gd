class_name CarAngularGrip extends CarPluginBase

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func process_plugin(delta: float) -> void:
	if is_zero_approx(plugin_wp.ground_coefficient):
		return

	var torque: float = -plugin_lvp.local_velocity_angular.y * car.mass
	car.set_torque(&"angular_grip", Vector3.UP * torque / delta, true)
