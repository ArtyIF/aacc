class_name CarBrake extends CarPluginBase

@export var max_brake_velocity: float = 0.1
@export var brake_force: float = 20000.0

func _ready() -> void:
	car.set_param("input_brake", 0.0)
	car.set_param("input_handbrake", 0.0)

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("ground_coefficient")):
		return

	var input_brake: float = car.get_param("input_brake", 0.0)
	var input_handbrake: float = car.get_param("input_handbrake", 0.0)
	var brake_value: float = max(input_brake, input_handbrake)

	var brake_speed: float = clamp(car.get_param("local_linear_velocity").z, -max_brake_velocity, max_brake_velocity) / max_brake_velocity
	var force: Vector3 = Vector3.FORWARD * brake_value * brake_speed * brake_force
	car.set_force("brake", force, true)
