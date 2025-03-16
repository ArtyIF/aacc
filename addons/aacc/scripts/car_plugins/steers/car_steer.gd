class_name CarSteer extends CarPluginBase

@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var base_steer_velocity: float = deg_to_rad(30.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var target_steer_velocity: float = deg_to_rad(60.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var max_steer_velocity: float = deg_to_rad(180.0)
@export var distance_between_wheels: float = 1.5
@export var max_smooth_steer_speed: float = 10.0
@export var enable_smooth_steer_sign: bool = true

var smooth_steer_sign: SmoothedFloat = SmoothedFloat.new()
var use_smooth_steer_sign: bool = false
var old_input_handbrake: bool = false

func _ready() -> void:
	car.set_param(&"input_steer", 0.0)
	car.set_param(&"distance_between_wheels", distance_between_wheels)
	car.set_param(&"base_steer_velocity", base_steer_velocity)
	car.set_param(&"target_steer_velocity", target_steer_velocity)
	car.set_param(&"max_smooth_steer_speed", max_smooth_steer_speed)

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
		return

	car.set_param(&"max_smooth_steer_speed", max_smooth_steer_speed)

	var local_linear_velocity: Vector3 = car.get_param(&"local_linear_velocity", Vector3.ZERO)
	var local_angular_velocity: Vector3 = car.get_param(&"local_angular_velocity", Vector3.ZERO)

	var input_steer: float = car.get_param(&"input_steer", 0.0)
	var input_handbrake: float = car.get_param(&"input_handbrake", 0.0) > 0.0

	if enable_smooth_steer_sign:
		if input_handbrake:
			use_smooth_steer_sign = old_input_handbrake
		else:
			if use_smooth_steer_sign and smooth_steer_sign.get_value() == sign(local_linear_velocity.z):
				use_smooth_steer_sign = false
			if abs(local_angular_velocity.y) < (0.25 * base_steer_velocity / distance_between_wheels) and local_linear_velocity.length() < 0.25:
				use_smooth_steer_sign = false
	else:
		use_smooth_steer_sign = false

	var velocity_speed: float
	var velocity_sign: float
	if use_smooth_steer_sign:
		smooth_steer_sign.advance_to(sign(local_linear_velocity.z), delta) # TODO: configurable speed
		velocity_sign = smooth_steer_sign.get_value()
		velocity_speed = local_linear_velocity.length()
	else:
		velocity_speed = abs(local_linear_velocity.z)
		velocity_sign = sign(local_linear_velocity.z)
		smooth_steer_sign.force_current_value(sign(local_linear_velocity.z))

	var steer_coefficient: float = velocity_sign * velocity_speed / distance_between_wheels
	var steer_amount: float = (input_steer * steer_coefficient) + car.get_param(&"steer_offset", 0.0)

	var steer_velocity: float = clamp(steer_amount * base_steer_velocity, -max_steer_velocity, max_steer_velocity)
	var steer_force: Vector3 = Vector3.UP * steer_velocity
	car.set_torque(&"steer", steer_force * car.mass / delta, true)

	old_input_handbrake = input_handbrake
