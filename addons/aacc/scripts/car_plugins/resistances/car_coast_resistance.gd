class_name CarCoastResistance extends CarPluginBase

@export var resistance_force: float = 1000.0
@export var resistance_force_knee: float = 10.0

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func process_plugin(delta: float) -> void:
	if is_zero_approx(plugin_wp.ground_coefficient):
		return

	var local_velocity_linear: Vector3 = plugin_lvp.local_velocity_linear
	var multiplier: float = 1.0 if car.get_meta(&"rpm_limiter") or abs(local_velocity_linear.z) > car.get_meta(&"engine_top_speed", 0.0) else (1.0 - car.get_meta(&"input_accelerate", 0.0))

	var force: float = clamp(local_velocity_linear.z / resistance_force_knee, -1.0, 1.0) * multiplier * resistance_force
	if is_zero_approx(force):
		return

	car.set_force(&"coast_resistance", Vector3.FORWARD * force, true)
