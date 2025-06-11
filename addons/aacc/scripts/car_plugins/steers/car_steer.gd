class_name CarSteer extends CarPluginBase

@export var distance_between_wheels: float = 1.5

@export_subgroup("Steering Velocity", "steer_velocity_")
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var steer_velocity_base: float = deg_to_rad(30.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var steer_velocity_target: float = deg_to_rad(60.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var steer_velocity_max: float = deg_to_rad(180.0)
@export var steer_velocity_invert_on_reverse: bool = true

@export_group("Smooth Steering", "smooth_steer_")
@export var smooth_steer_speed: float = 10.0
@export var smooth_steer_smooth_sign: bool = true

var smooth_steer: SmoothedFloat = SmoothedFloat.new()
var steer_sign: SmoothedFloat = SmoothedFloat.new()
var steer_sign_smooth: bool = false
var input_handbrake_prev: bool = false

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")
@onready var plugin_steer_offset: CarSteerOffsetProcessor = car.get_plugin(&"SteerOffsetProcessor")

func _ready() -> void:
	car.set_meta(&"input_steer", 0.0)

	debuggable_parameters = [
		&"smooth_steer",
		&"steer_sign",
		&"steer_sign_smooth",
	]

func process_plugin(delta: float) -> void:
	var input_steer: float = car.get_meta(&"input_steer")
	smooth_steer.speed_up = smooth_steer_speed
	smooth_steer.speed_down = smooth_steer_speed
	smooth_steer.advance_to(input_steer, delta)

	if is_zero_approx(plugin_wp.ground_coefficient):
		return

	var local_velocity_linear: Vector3 = plugin_lvp.local_velocity_linear
	var local_velocity_angular: Vector3 = plugin_lvp.local_velocity_angular
	var input_handbrake: bool = car.get_meta(&"input_handbrake")

	if smooth_steer_smooth_sign:
		if input_handbrake:
			steer_sign_smooth = input_handbrake_prev
		else:
			if steer_sign_smooth and steer_sign.get_value() == sign(local_velocity_linear.z):
				steer_sign_smooth = false
			if abs(local_velocity_angular.y) < (0.25 * steer_velocity_base / distance_between_wheels) and local_velocity_linear.length() < 0.25:
				steer_sign_smooth = false
	else:
		steer_sign_smooth = false

	var velocity_speed: float
	var velocity_sign: float
	if steer_sign_smooth:
		steer_sign.advance_to(sign(local_velocity_linear.z), delta) # TODO: configurable speed
		velocity_sign = steer_sign.get_value()
		velocity_speed = local_velocity_linear.length()
	else:
		velocity_speed = abs(local_velocity_linear.z)
		velocity_sign = sign(local_velocity_linear.z)
		steer_sign.force_current_value(sign(local_velocity_linear.z))
	if not steer_velocity_invert_on_reverse:
		velocity_sign = -1.0

	var steer_coefficient: float = velocity_sign * velocity_speed / distance_between_wheels
	var steer_amount: float = (smooth_steer.get_value() * steer_coefficient) + plugin_steer_offset.steer_offset

	if is_zero_approx(steer_amount):
		return

	var steer_velocity: float = clamp(steer_amount * steer_velocity_base, -steer_velocity_max, steer_velocity_max)
	var steer_force: Vector3 = Vector3.UP * steer_velocity
	car.set_torque(&"steer", steer_force * car.mass / delta, true)

	input_handbrake_prev = input_handbrake
