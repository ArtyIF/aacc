class_name CarBrake extends CarPluginBase

@export var max_brake_velocity: float = 0.1
@export var brake_force: float = 20000.0

func _ready() -> void:
	car.set_meta(&"input_brake", 0.0)
	car.set_meta(&"input_handbrake", false)

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_meta(&"ground_coefficient", 0.0)):
		return

	var input_brake: float = car.get_meta(&"input_brake", 0.0)
	var input_handbrake: bool = car.get_meta(&"input_handbrake", false)
	var brake_value: float = 1.0 if input_handbrake else input_brake

	if is_zero_approx(brake_value):
		return

	var brake_speed: float = car.get_meta(&"local_linear_velocity", Vector3.ZERO).z / max_brake_velocity
	car.set_meta(&"brake_speed", brake_speed)
	var force: Vector3 = Vector3.FORWARD * brake_value * clamp(brake_speed, -1.0, 1.0) * brake_force
	car.set_force(&"brake", force, true)
