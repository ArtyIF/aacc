class_name CarSteerBasic extends CarPluginBase

@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var steer_velocity: float = deg_to_rad(30.0)
@export var distance_between_wheels: float = 1.5

func process_plugin(delta: float) -> void:
	var steer_amount: float = -car.get_input("Steer") * abs(car.get_param("LocalLinearVelocity").z) / distance_between_wheels
	var steer_force: Vector3 = Vector3.UP * steer_amount * steer_velocity
	car.add_torque("Steer", steer_force * car.mass / delta, true)
