class_name CarSteerBasic extends CarPluginBase

@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var steer_velocity: float = deg_to_rad(90.0)

func _ready() -> void:
	car.add_input("Steer")

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var steer_speed: float = -car.get_input("Steer") * steer_velocity

	var torque: Vector3 = Vector3.UP * steer_speed
	car.add_torque("Steer", torque * car.mass / delta, true)
