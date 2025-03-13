class_name CarAirDrag extends CarPluginBase

@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var max_target_velocity: float = deg_to_rad(10.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec²") var max_drag_amount: float = deg_to_rad(30.0)

func process_plugin(delta: float) -> void:
	if car.get_param("GroundCoefficient", 0.0) > 0.0: return

	# TODO: make it move towards a certain up vector, maybe just up or cast a ray down and use the normal
	if car.angular_velocity.length() > max_target_velocity:
		car.set_torque("AirDrag", (-car.angular_velocity / delta).limit_length(max_drag_amount) * car.mass)
