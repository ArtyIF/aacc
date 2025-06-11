class_name CarSlipProcessor extends CarPluginBase

var slip_takeoff_smooth: SmoothedFloat = SmoothedFloat.new(0.0, 10.0, 1.0) # TODO: configurable

var slip_side: float = 0.0
var slip_forward: float = 0.0
var slip_total: float = 0.0

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_engine: CarEngine = car.get_plugin(&"Engine")

func _ready() -> void:
	debuggable_parameters = [
		&"slip_takeoff_smooth",
		&"slip_side",
		&"slip_forward",
		&"slip_total",
	]

func process_plugin(delta: float) -> void:
	slip_side = 0.0
	slip_forward = 0.0
	slip_total = 0.0

	slip_side += abs(plugin_lvp.local_velocity_linear.x)
	slip_side -= 0.5
	slip_side /= 10.0 # TODO: configurable

	if plugin_engine.gear_current == 0:
		var engine_force_ratio: float = 0.0
		if car.get_meta(&"input_handbrake"):
			engine_force_ratio = plugin_engine.force_ratio
		slip_takeoff_smooth.advance_to(engine_force_ratio, delta)
	else:
		slip_takeoff_smooth.force_current_value(0.0)
		if car.get_meta(&"input_handbrake"):
			slip_forward += abs(plugin_lvp.local_velocity_linear.z)
			slip_forward /= 10.0 # TODO: configurable
	slip_forward += slip_takeoff_smooth.get_value()

	slip_side = clamp(slip_side, 0.0, 1.0)
	slip_forward = clamp(slip_forward, 0.0, 1.0)
	slip_total = clamp(slip_side + slip_forward, 0.0, 1.0)
