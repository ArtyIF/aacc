class_name CarCoastResistance extends CarPluginBase

@export var resistance_force: float = 1000.0
@export var resistance_force_knee: float = 10.0

var resistance_amount: float = 0.0

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")
@onready var plugin_engine: CarEngine = car.get_plugin(&"Engine")

func _ready() -> void:
	debuggable_parameters = [
		&"resistance_amount",
	]

func process_plugin(delta: float) -> void:
	if is_zero_approx(plugin_wp.ground_coefficient):
		return

	var local_velocity_linear: Vector3 = plugin_lvp.local_velocity_linear
	var multiplier: float = 1.0 if plugin_engine.rpm_limiter or abs(local_velocity_linear.z) > plugin_engine.engine_top_speed else (1.0 - car.get_meta(&"input_accelerate"))

	resistance_amount = clamp(local_velocity_linear.z / resistance_force_knee, -1.0, 1.0) * multiplier
	if is_zero_approx(resistance_amount):
		return

	car.set_force(&"coast_resistance", Vector3.FORWARD * resistance_force * resistance_amount, true)
