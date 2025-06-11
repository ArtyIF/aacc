class_name CarSlipProcessor extends CarPluginBase

var smooth_takeoff_slip: SmoothedFloat = SmoothedFloat.new(0.0, 10.0, 1.0) # TODO: configurable

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_engine: CarEngine = car.get_plugin(&"Engine")

func process_plugin(delta: float) -> void:
	var slip_side: float = 0.0
	var slip_forward: float = 0.0
	var slip_total: float = 0.0

	slip_side += abs(plugin_lvp.local_velocity_linear.x)
	slip_side -= 0.5
	slip_side /= 10.0 # TODO: configurable

	if plugin_engine.gear_current == 0:
		var engine_force_ratio: float = 0.0
		if car.get_meta(&"input_handbrake"):
			engine_force_ratio = plugin_engine.force_ratio
		smooth_takeoff_slip.advance_to(engine_force_ratio, delta)
	else:
		smooth_takeoff_slip.force_current_value(0.0)
		if car.get_meta(&"input_handbrake"):
			slip_forward += abs(plugin_lvp.local_velocity_linear.z)
			slip_forward /= 10.0 # TODO: configurable
	slip_forward += smooth_takeoff_slip.get_value()

	slip_side = clamp(slip_side, 0.0, 1.0)
	slip_forward = clamp(slip_forward, 0.0, 1.0)
	slip_total = clamp(slip_side + slip_forward, 0.0, 1.0)
	car.set_meta(&"slip_side", slip_side)
	car.set_meta(&"slip_forward", slip_forward)
	car.set_meta(&"slip_total", slip_total)
