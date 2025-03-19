class_name CarInput extends ScenePluginBase

# TODO: sort some of this?
@export_group("Input Map")
@export var action_forward: StringName = &"aacc_forward"
@export var action_backward: StringName = &"aacc_backward"
@export var action_steer_left: StringName = &"aacc_steer_left"
@export var action_steer_right: StringName = &"aacc_steer_right"
@export var action_handbrake: StringName = &"aacc_handbrake"
@export var action_boost: StringName = &"aacc_boost"
@export var action_launch_toggle: StringName = &"aacc_launch_toggle"
@export var action_trans_toggle: StringName = &"aacc_trans_toggle"
@export var action_gear_up: StringName = &"aacc_gear_up"
@export var action_gear_down: StringName = &"aacc_gear_down"

@export_group("Steering")
@export var always_full_steer: bool = false
@export var full_steer_on_reverse: bool = true
@export var full_steer_on_handbrake: bool = true
@export var desired_smooth_steer_speed: float = 10.0

@export_group("Gearbox")
@export var auto_trans_downshift_offset: float = 2.0

var manual_transmission: bool = false
var launch_control_engaged: bool = false
var target_gear: int = 0
var smooth_steer: SmoothedFloat = SmoothedFloat.new()

func calculate_steer(input_steer: float, input_handbrake: float, velocity_z_sign: float, delta: float) -> float:
	var input_full_steer: float = input_handbrake if full_steer_on_handbrake else 0.0
	if is_zero_approx(car.get_param(&"ground_coefficient", 1.0)):
		input_full_steer = 1.0
	if full_steer_on_reverse and velocity_z_sign > 0:
		input_full_steer = 1.0

	# TODO: add an ability to have the car send the info somehow, otherwise this is delayed by a frame
	var distance_between_wheels: float = car.get_param(&"distance_between_wheels", 1.0)
	var steer_velocity_base: float = car.get_param(&"steer_velocity_base", 1.0)
	var steer_velocity_target: float = car.get_param(&"steer_velocity_target", 1.0)
	var velocity_z: float = abs(car.get_param(&"local_linear_velocity", Vector3.ZERO).z)

	var input_steer_multiplier: float = 1.0
	if not always_full_steer:
		input_steer_multiplier = min(distance_between_wheels * (steer_velocity_target / steer_velocity_base) / velocity_z, 1.0)
		input_steer_multiplier = lerp(input_steer_multiplier, 1.0, input_full_steer)
	var input_steer_converted: float = input_steer * input_steer_multiplier

	smooth_steer.speed_up = min(desired_smooth_steer_speed, car.get_param(&"smooth_steer_max_speed", desired_smooth_steer_speed))
	smooth_steer.speed_down = min(desired_smooth_steer_speed, car.get_param(&"smooth_steer_max_speed", desired_smooth_steer_speed))
	smooth_steer.advance_to(input_steer_converted, delta)

	return smooth_steer.get_value()

func calculate_gear_limit(gear: int, gear_count: int) -> float:
	return float(gear) / gear_count

func calculate_target_gear_auto(input_handbrake: float, velocity_z_sign: float) -> int:
	var local_linear_velocity: Vector3 = car.get_param(&"local_linear_velocity", Vector3.ZERO)
	var ground_coefficient: float = car.get_param(&"ground_coefficient", 1.0)

	var current_gear: int = car.get_param(&"current_gear", 0)
	var top_speed: float = car.get_param(&"top_speed", 0.0)
	var gear_count: int = car.get_param(&"gear_count", 0)
	var current_target_gear: int = car.get_param(&"input_target_gear", 0)

	if car.get_param(&"switching_gears", false):
		return current_target_gear

	if (input_handbrake > 0.0 and local_linear_velocity.length() >= 0.25) or is_zero_approx(ground_coefficient):
		return current_gear
	if input_handbrake > 0.0 and local_linear_velocity.length() < 0.25:
		return 0
	
	if velocity_z_sign > 0:
		return -1

	if abs(local_linear_velocity.z) < 0.25:
		return -velocity_z_sign

	var forward_speed_ratio: float = abs(local_linear_velocity.z / top_speed)
	# TODO: DRY
	var gear_perfect_switch: float = car.get_param(&"gear_perfect_switch", 1.0)
	var gear_perfect_switch_adjusted: float = inverse_lerp(car.get_param(&"rpm_min"), car.get_param(&"rpm_max"), gear_perfect_switch)

	var gear_limit: float = calculate_gear_limit(current_gear, gear_count)
	var gear_limit_lower_offset: float = auto_trans_downshift_offset / top_speed
	var gear_limit_lower: float = calculate_gear_limit(current_gear - 1, gear_count) - gear_limit_lower_offset

	# TODO: use rpm
	if forward_speed_ratio < gear_limit_lower * gear_perfect_switch_adjusted and current_target_gear > 0:
		return current_gear - 1
	if forward_speed_ratio > gear_limit * gear_perfect_switch_adjusted and current_target_gear < gear_count:
		return current_gear + 1

	return current_target_gear

func _physics_process(delta: float) -> void:
	update_car()
	if not car: return

	var input_forward: float = clamp(Input.get_action_strength(action_forward), 0.0, 1.0)
	var input_backward: float = clamp(Input.get_action_strength(action_backward), 0.0, 1.0)
	var input_steer: float = clamp(Input.get_action_strength(action_steer_right) - Input.get_action_strength(action_steer_left), -1.0, 1.0)
	var input_handbrake: float = 1.0 if Input.is_action_pressed(action_handbrake) else 0.0
	var input_boost: float = 1.0 if Input.is_action_pressed(action_boost) else 0.0

	if Input.is_action_just_pressed(action_trans_toggle):
		manual_transmission = not manual_transmission
	if Input.is_action_just_pressed(action_launch_toggle):
		launch_control_engaged = not launch_control_engaged

	var velocity_z_sign: float = car.get_param(&"velocity_z_sign", 0.0)
	if is_zero_approx(velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			velocity_z_sign = 1.0

	if manual_transmission:
		if Input.is_action_just_pressed(action_gear_up):
			target_gear += 1
		if Input.is_action_just_pressed(action_gear_down):
			target_gear -= 1
		target_gear = clampi(target_gear, -1, car.get_param(&"gear_count", 0))
		var launch_control_multiplier: float = 1.0
		if target_gear == 0:
			# TODO: DRY
			if launch_control_engaged:
				var gear_perfect_switch: float = car.get_param(&"gear_perfect_switch", 1.0)
				launch_control_multiplier = inverse_lerp(car.get_param(&"rpm_min"), car.get_param(&"rpm_max"), gear_perfect_switch)
		else:
			launch_control_engaged = false
		car.set_param(&"input_accelerate", input_forward * launch_control_multiplier)
		car.set_param(&"input_brake", input_backward)
	else:
		target_gear = calculate_target_gear_auto(input_handbrake, velocity_z_sign)
		if target_gear > 0:
			launch_control_engaged = false
			car.set_param(&"input_accelerate", input_forward)
			car.set_param(&"input_brake", input_backward)
		elif target_gear < 0:
			launch_control_engaged = false
			car.set_param(&"input_accelerate", input_backward)
			car.set_param(&"input_brake", input_forward)
		else:
			# TODO: DRY
			var launch_control_multiplier: float = 1.0
			if launch_control_engaged:
				var gear_perfect_switch: float = car.get_param(&"gear_perfect_switch", 1.0)
				launch_control_multiplier = inverse_lerp(car.get_param(&"rpm_min"), car.get_param(&"rpm_max"), gear_perfect_switch)
			car.set_param(&"input_accelerate", max(input_forward, input_backward) * launch_control_multiplier)
			car.set_param(&"input_brake", 1.0)

	car.set_param(&"input_target_gear", target_gear)
	car.set_param(&"input_steer", calculate_steer(input_steer, input_handbrake, velocity_z_sign, delta))
	car.set_param(&"input_handbrake", input_handbrake)
	car.set_param(&"input_boost", input_boost)
