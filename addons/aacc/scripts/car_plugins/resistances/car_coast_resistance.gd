class_name CarCoastResistance extends CarPluginBase

@export var resistance_force: float = 1000.0
@export var resistance_force_knee: float = 10.0

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
		return

	# TODO: use RPM limiter status
	var local_linear_velocity: Vector3 = car.get_param(&"local_linear_velocity", Vector3.ZERO)
	var top_speed: float = car.get_param(&"top_speed", 0.0)
	var gear_count: int = car.get_param(&"gear_count", 1)
	var is_beyond_limit: bool = local_linear_velocity.z <= -top_speed or local_linear_velocity.z >= top_speed / gear_count
	var multiplier: float = 1.0 if is_beyond_limit else (1.0 - car.get_param(&"input_accelerate", 0.0))

	var force: float = clamp(local_linear_velocity.z / resistance_force_knee, -1.0, 1.0) * multiplier * resistance_force
	if is_zero_approx(force):
		return

	car.set_force(&"coast_resistance", Vector3.FORWARD * force, true)
