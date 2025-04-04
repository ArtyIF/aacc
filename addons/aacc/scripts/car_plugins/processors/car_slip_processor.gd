class_name CarSlipProcessor extends CarPluginBase

var smooth_takeoff_slip: SmoothedFloat = SmoothedFloat.new(0.0, 10.0, 1.0) # TODO: configurable

func process_plugin(delta: float) -> void:
	var total_slip: float = 0.0

	total_slip += abs(car.get_meta(&"local_linear_velocity", Vector3.ZERO).x)
	total_slip /= 10.0 # TODO: configurable

	if car.get_meta(&"gear_current", 0) == 0:
		var engine_desired_force_ratio: float = car.get_meta(&"engine_desired_force_ratio", 0.0)
		smooth_takeoff_slip.advance_to(engine_desired_force_ratio, delta)
		if car.get_meta(&"input_handbrake", false):
			total_slip += smooth_takeoff_slip.get_value()
	else:
		smooth_takeoff_slip.force_current_value(0.0)
		if car.get_meta(&"input_handbrake", false):
			total_slip += abs(car.get_meta(&"brake_speed", 0.0))

	total_slip = clamp(total_slip, 0.0, 1.0)
	car.set_meta(&"total_slip", total_slip)
