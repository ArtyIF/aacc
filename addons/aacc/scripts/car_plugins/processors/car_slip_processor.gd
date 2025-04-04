class_name CarSlipProcessor extends CarPluginBase

var smooth_takeoff_slip: SmoothedFloat = SmoothedFloat.new(0.0, 10.0, 1.0) # TODO: configurable

func process_plugin(delta: float) -> void:
	var slip_side: float = 0.0
	var slip_forward: float = 0.0
	var slip_total: float = 0.0

	slip_side += abs(car.get_meta(&"local_linear_velocity", Vector3.ZERO).x)
	slip_side /= 10.0 # TODO: configurable
	slip_total += slip_side

	if car.get_meta(&"gear_current", 0) == 0:
		var engine_desired_force_ratio: float = car.get_meta(&"engine_desired_force_ratio", 0.0)
		smooth_takeoff_slip.advance_to(engine_desired_force_ratio, delta)
		if car.get_meta(&"input_handbrake", false):
			slip_forward += smooth_takeoff_slip.get_value()
	else:
		smooth_takeoff_slip.force_current_value(0.0)
		if car.get_meta(&"input_handbrake", false):
			slip_forward += abs(car.get_meta(&"brake_speed", 0.0))
	slip_total += slip_forward

	slip_side = clamp(slip_side, 0.0, 1.0)
	slip_forward = clamp(slip_forward, 0.0, 1.0)
	slip_total = clamp(slip_total, 0.0, 1.0)
	car.set_meta(&"slip_side", slip_side)
	car.set_meta(&"slip_forward", slip_forward)
	car.set_meta(&"slip_total", slip_total)
