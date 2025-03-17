class_name CarSteer extends CarPluginBase

@export var distance_between_wheels: float = 1.5
@export_subgroup("Steering Velocity", "steer_velocity_")
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var steer_velocity_base: float = deg_to_rad(30.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var steer_velocity_target: float = deg_to_rad(60.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var steer_velocity_max: float = deg_to_rad(180.0)

@export_group("Smooth Steering", "smooth_steer_")
@export var smooth_steer_max_speed: float = 10.0
@export var smooth_steer_smooth_sign: bool = true

var smooth_sign: SmoothedFloat = SmoothedFloat.new()
var use_smooth_sign: bool = false
var old_input_handbrake: bool = false

func _ready() -> void:
	car.set_param(&"input_steer", 0.0)

	# TODO: DRY
	car.set_param(&"distance_between_wheels", distance_between_wheels)
	car.set_param(&"steer_velocity_base", steer_velocity_base)
	car.set_param(&"steer_velocity_target", steer_velocity_target)
	car.set_param(&"smooth_steer_max_speed", smooth_steer_max_speed)

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
		return

	# TODO: DRY
	car.set_param(&"distance_between_wheels", distance_between_wheels)
	car.set_param(&"steer_velocity_base", steer_velocity_base)
	car.set_param(&"steer_velocity_target", steer_velocity_target)
	car.set_param(&"smooth_steer_max_speed", smooth_steer_max_speed)

	var local_linear_velocity: Vector3 = car.get_param(&"local_linear_velocity", Vector3.ZERO)
	var local_angular_velocity: Vector3 = car.get_param(&"local_angular_velocity", Vector3.ZERO)

	var input_steer: float = car.get_param(&"input_steer", 0.0)
	var input_handbrake: float = car.get_param(&"input_handbrake", 0.0) > 0.0

	if smooth_steer_smooth_sign:
		if input_handbrake:
			use_smooth_sign = old_input_handbrake
		else:
			if use_smooth_sign and smooth_sign.get_value() == sign(local_linear_velocity.z):
				use_smooth_sign = false
			if abs(local_angular_velocity.y) < (0.25 * steer_velocity_base / distance_between_wheels) and local_linear_velocity.length() < 0.25:
				use_smooth_sign = false
	else:
		use_smooth_sign = false

	var velocity_speed: float
	var velocity_sign: float
	if use_smooth_sign:
		smooth_sign.advance_to(sign(local_linear_velocity.z), delta) # TODO: configurable speed
		velocity_sign = smooth_sign.get_value()
		velocity_speed = local_linear_velocity.length()
	else:
		velocity_speed = abs(local_linear_velocity.z)
		velocity_sign = sign(local_linear_velocity.z)
		smooth_sign.force_current_value(sign(local_linear_velocity.z))

	var steer_coefficient: float = velocity_sign * velocity_speed / distance_between_wheels
	var steer_amount: float = (input_steer * steer_coefficient) + car.get_param(&"steer_offset", 0.0)

	if is_zero_approx(steer_amount):
		return

	var steer_velocity: float = clamp(steer_amount * steer_velocity_base, -steer_velocity_max, steer_velocity_max)
	var steer_force: Vector3 = Vector3.UP * steer_velocity
	car.set_torque(&"steer", steer_force * car.mass / delta, true)

	old_input_handbrake = input_handbrake
