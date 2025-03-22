class_name CarInput extends ScenePluginBase
# TODO: split into several plugins

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
@export var perfect_launch_threshold: float = 0.95
@export var perfect_shift_up_threshold: float = 0.2
@export var perfect_shift_down_threshold: float = 0.2
@export var auto_downshift_on_manual: bool = true

var manual_transmission: bool = false
var launch_control_engaged: bool = false
var gear_target: int = 0
var smooth_steer: SmoothedFloat = SmoothedFloat.new()

func calculate_steer(input_steer: float, input_handbrake: bool, velocity_z_sign: float, delta: float) -> float:
	var input_full_steer: float = (1.0 if input_handbrake else 0.0) if full_steer_on_handbrake else 0.0
	if is_zero_approx(car.get_meta(&"ground_coefficient", 1.0)):
		input_full_steer = 1.0
	if full_steer_on_reverse and velocity_z_sign > 0:
		input_full_steer = 1.0

	# TODO: add an ability to have the car send the info somehow, otherwise this is delayed by a frame
	var distance_between_wheels: float = car.get_meta(&"distance_between_wheels", 1.0)
	var steer_velocity_base: float = car.get_meta(&"steer_velocity_base", 1.0)
	var steer_velocity_target: float = car.get_meta(&"steer_velocity_target", 1.0)
	var velocity_z: float = abs(car.get_meta(&"local_linear_velocity", Vector3.ZERO).z)

	var input_steer_multiplier: float = 1.0
	if not always_full_steer:
		input_steer_multiplier = min(distance_between_wheels * (steer_velocity_target / steer_velocity_base) / velocity_z, 1.0)
		input_steer_multiplier = lerp(input_steer_multiplier, 1.0, input_full_steer)
	var input_steer_converted: float = input_steer * input_steer_multiplier

	smooth_steer.speed_up = min(desired_smooth_steer_speed, car.get_meta(&"smooth_steer_max_speed", desired_smooth_steer_speed))
	smooth_steer.speed_down = min(desired_smooth_steer_speed, car.get_meta(&"smooth_steer_max_speed", desired_smooth_steer_speed))
	smooth_steer.advance_to(input_steer_converted, delta)

	return smooth_steer.get_value()

func calculate_gear_limit(gear: int, gear_count: int) -> float:
	return float(gear) / gear_count

# TODO: move into helper class
func get_curve_samples(curve: Curve, ratio: float = 1.0) -> PackedVector2Array:
	var list: PackedVector2Array = []

	for i in range(0, curve.bake_resolution + 1):
		var point_x: float = float(i) / curve.bake_resolution
		var point_y: float = curve.sample_baked(point_x * ratio) * ratio
		list.append(Vector2(point_x, point_y))

	return list

# x = min range, y = actual peak, z = max range
func get_curve_samples_peak_range(samples: PackedVector2Array, range_threshold: float) -> Vector3:
	var range: Vector3 = Vector3.ZERO
	var range_x_set: bool = false
	var max_y: float = 0.0

	for point in samples:
		if point.y >= range_threshold:
			range.z = point.x
			if not range_x_set:
				range.x = point.x
				range_x_set = true
			if point.y >= max_y:
				range.y = point.x
				max_y = point.y

	return range

func get_curve_samples_intersection_range(samples_1: PackedVector2Array, samples_2: PackedVector2Array, range_threshold: float) -> Vector3:
	var range: Vector3 = Vector3.ZERO
	var range_x_set: bool = false
	var diff_sign_prev: float = 0.0

	for i in range(0, len(samples_1)):
		var point_1: Vector2 = samples_1[i]
		var point_2: Vector2 = samples_2[i]

		var diff_sign: float = sign(point_2.y - point_1.y)
		if diff_sign != diff_sign_prev and not is_zero_approx(diff_sign):
			range.y = point_1.x
		diff_sign_prev = diff_sign

		if abs(point_2.y - point_1.y) <= range_threshold:
			range.z = point_1.x
			if not range_x_set:
				range.x = point_1.x
				range_x_set = true
		else:
			range_x_set = false

	return range

func get_gear_perfect_shift_up_range(rpm_min: float = 0.0, rpm_max: float = 1.0) -> Vector3:
	var range: Vector3 = Vector3.ZERO

	var gear_current: int = car.get_meta(&"gear_current", 0)
	var ground_coefficient: float = car.get_meta(&"ground_coefficient", 0.0)
	var rpm_curve: Curve = car.get_meta(&"rpm_curve")
	var rpm_curve_samples_current: PackedVector2Array = get_curve_samples(rpm_curve)

	if gear_current == 0 or is_zero_approx(ground_coefficient):
		range = get_curve_samples_peak_range(rpm_curve_samples_current, perfect_launch_threshold)
	else:
		var current_next_ratio: float = max(float(gear_current), 1.0) / max(float(gear_current) + 1, 1.0)
		var rpm_curve_samples_next: PackedVector2Array = get_curve_samples(rpm_curve, current_next_ratio)
		range = get_curve_samples_intersection_range(rpm_curve_samples_current, rpm_curve_samples_next, perfect_shift_up_threshold)

	range.x = inverse_lerp(rpm_min, rpm_max, range.x)
	range.y = inverse_lerp(rpm_min, rpm_max, range.y)
	range.z = inverse_lerp(rpm_min, rpm_max, range.z)
	return range

func get_gear_perfect_shift_down(rpm_min: float = 0.0, rpm_max: float = 1.0) -> float:
	var perfect: float = 0.0

	var gear_current: int = car.get_meta(&"gear_current", 0)
	var rpm_curve: Curve = car.get_meta(&"rpm_curve")
	var rpm_curve_samples_current: PackedVector2Array = get_curve_samples(rpm_curve)

	if gear_current > 1:
		var current_prev_ratio: float = max(float(gear_current), 1.0) / max(float(gear_current) - 1, 1.0)
		var rpm_curve_samples_prev: PackedVector2Array = get_curve_samples(rpm_curve, current_prev_ratio)
		perfect = get_curve_samples_intersection_range(rpm_curve_samples_current, rpm_curve_samples_prev, perfect_shift_down_threshold).y

	perfect = inverse_lerp(rpm_min, rpm_max, perfect)
	return perfect

func calculate_gear_target_auto(input_handbrake: bool, velocity_z_sign: float) -> int:
	var local_linear_velocity: Vector3 = car.get_meta(&"local_linear_velocity", Vector3.ZERO)
	var ground_coefficient: float = car.get_meta(&"ground_coefficient", 1.0)

	var gear_current: int = car.get_meta(&"gear_current", 0)
	var gear_count: int = car.get_meta(&"gear_count", 0)
	var gear_target: int = car.get_meta(&"input_gear_target", 0)

	if (input_handbrake and local_linear_velocity.length() >= 0.25) or is_zero_approx(ground_coefficient):
		return gear_current
	if input_handbrake and local_linear_velocity.length() < 0.25:
		return 0

	if velocity_z_sign > 0:
		return -1

	if abs(local_linear_velocity.z) < 0.25:
		return -velocity_z_sign

	var gear_perfect_shift_up: float = get_gear_perfect_shift_up_range().y
	var gear_perfect_shift_down: float = get_gear_perfect_shift_down()

	if car.get_meta(&"rpm_ratio", 0.0) < gear_perfect_shift_down and gear_target > 0:
		return gear_target - 1
	if car.get_meta(&"rpm_ratio", 0.0) > gear_perfect_shift_up and gear_target < gear_count:
		return gear_target + 1

	return gear_target

func _physics_process(delta: float) -> void:
	update_car()
	if not car: return

	var input_forward: float = clamp(Input.get_action_strength(action_forward), 0.0, 1.0)
	var input_backward: float = clamp(Input.get_action_strength(action_backward), 0.0, 1.0)
	var input_steer: float = clamp(Input.get_action_strength(action_steer_right) - Input.get_action_strength(action_steer_left), -1.0, 1.0)
	var input_handbrake: bool = Input.is_action_pressed(action_handbrake)
	var input_boost: bool = Input.is_action_pressed(action_boost)

	if Input.is_action_just_pressed(action_trans_toggle):
		manual_transmission = not manual_transmission
	if Input.is_action_just_pressed(action_launch_toggle):
		launch_control_engaged = not launch_control_engaged

	var velocity_z_sign: float = car.get_meta(&"velocity_z_sign", 0.0)
	if is_zero_approx(velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			velocity_z_sign = 1.0

	if manual_transmission:
		if Input.is_action_just_pressed(action_gear_up):
			gear_target += 1
		if Input.is_action_just_pressed(action_gear_down):
			gear_target -= 1

		if auto_downshift_on_manual and (input_backward > 0.0 or is_zero_approx(input_forward)):
			var gear_perfect_shift_down: float = get_gear_perfect_shift_down()
			if car.get_meta(&"rpm_ratio", 0.0) < gear_perfect_shift_down and gear_target > 0:
				gear_target = car.get_meta(&"gear_current", 1) - 1

		gear_target = clampi(gear_target, -1, car.get_meta(&"gear_count", 0))

		# TODO: DRY
		var launch_control_multiplier: float = 1.0
		if gear_target == 0:
			if launch_control_engaged:
				launch_control_multiplier = get_gear_perfect_shift_up_range(car.get_meta(&"rpm_min"), 1.0).y
		else:
			launch_control_engaged = false

		car.set_meta(&"input_accelerate", input_forward * launch_control_multiplier)
		car.set_meta(&"input_brake", input_backward)
	else:
		gear_target = calculate_gear_target_auto(input_handbrake, velocity_z_sign)
		if gear_target > 0:
			launch_control_engaged = false
			car.set_meta(&"input_accelerate", input_forward)
			car.set_meta(&"input_brake", input_backward)
		elif gear_target < 0:
			launch_control_engaged = false
			car.set_meta(&"input_accelerate", input_backward)
			car.set_meta(&"input_brake", input_forward)
		else:
			# TODO: DRY
			var launch_control_multiplier: float = 1.0
			if launch_control_engaged:
				launch_control_multiplier = get_gear_perfect_shift_up_range(car.get_meta(&"rpm_min"), 1.0).y
			car.set_meta(&"input_accelerate", max(input_forward, input_backward) * launch_control_multiplier)
			car.set_meta(&"input_brake", 1.0 if is_zero_approx(input_boost) else 0.0)

	car.set_meta(&"input_gear_target", gear_target)
	car.set_meta(&"input_steer", calculate_steer(input_steer, input_handbrake, velocity_z_sign, delta))
	car.set_meta(&"input_handbrake", input_handbrake)
	car.set_meta(&"input_boost", input_boost)
