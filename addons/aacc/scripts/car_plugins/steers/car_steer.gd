class_name CarSteer extends CarPluginBase

@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var base_steer_velocity: float = deg_to_rad(30.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var target_steer_velocity: float = deg_to_rad(60.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var max_steer_velocity: float = deg_to_rad(180.0)
@export var distance_between_wheels: float = 1.5
@export var max_smooth_steer_speed: float = 10.0

func _ready() -> void:
	car.add_input("Steer")
	car.add_param("DistanceBetweenWheels", distance_between_wheels)
	car.add_param("BaseSteerVelocity", base_steer_velocity)
	car.add_param("TargetSteerVelocity", target_steer_velocity)
	car.add_param("MaxSmoothSteerSpeed", max_smooth_steer_speed)

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	car.set_param("MaxSmoothSteerSpeed", max_smooth_steer_speed)

	var velocity_z_abs: float = abs(car.get_param("LocalLinearVelocity").z)
	var velocity_z_sign: float = sign(car.get_param("LocalLinearVelocity").z)

	var input_steer: float = car.get_input("Steer")

	var steer_coefficient: float = velocity_z_sign * velocity_z_abs / distance_between_wheels
	var steer_amount: float = input_steer * steer_coefficient
	
	var steer_velocity: float = clamp(steer_amount * base_steer_velocity, -max_steer_velocity, max_steer_velocity)
	var steer_force: Vector3 = Vector3.UP * steer_velocity
	car.add_torque("Steer", steer_force * car.mass / delta, true)
