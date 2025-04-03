class_name CarSlipProcessor extends CarPluginBase

func process_plugin(delta: float) -> void:
	var total_slip: float = 0.0

	total_slip += abs(car.get_meta(&"local_linear_velocity").x)
	total_slip /= 10.0 # TODO: configurable
	total_slip = clamp(total_slip, 0.0, 1.0)

	# TODO: forward slip
	car.set_meta(&"total_slip", total_slip)
