class_name CarEngine extends CarPluginBase

@export_group("Engine", "engine_")
@export var engine_force: float = 10000.0
@export var engine_top_speed: float = 50.0

@export_group("Gearbox", "gearbox_")
@export var gearbox_gear_count: int = 5
@export var gearbox_switch_time: float = 0.1

@export_group("RPM", "rpm_")
@export var rpm_curve: Curve
@export var rpm_min: float = 0.1
@export var rpm_max: float = 0.9
@export var rpm_speed_up: float = 1.0
@export var rpm_speed_down: float = 0.5

var gear_current: int = 0
var gear_target: int = 0
var gear_switch_timer: float = 0.0
var gear_switching: bool = false
var rpm_ratio: SmoothedFloat = SmoothedFloat.new()

func _ready() -> void:
	car.set_param(&"input_accelerate", 0.0)
	car.set_param(&"input_gear_target", 0)
	update_params()
	update_gear_perfect_switch()

func update_params():
	car.set_param(&"top_speed", engine_top_speed)
	car.set_param(&"gear_count", gearbox_gear_count)
	car.set_param(&"gear_current", gear_current)
	car.set_param(&"gear_switching", gear_switching)
	car.set_param(&"gear_switch_timer", gear_switch_timer)
	car.set_param(&"rpm_ratio", rpm_ratio.get_value())
	car.set_param(&"rpm_curve", rpm_curve)
	car.set_param(&"rpm_min", rpm_min)
	car.set_param(&"rpm_max", rpm_max)

func update_gear_perfect_switch():
	var gear_perfect_switch: float = 0.0

	if gear_current == 0 or is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
		var rpm_curve_peak_value: float = 0.0
		for i in range(0, rpm_curve.bake_resolution + 1):
			var point_x: float = float(i) / rpm_curve.bake_resolution
			var point_y: float = rpm_curve.sample_baked(point_x)

			if point_y >= rpm_curve_peak_value:
				gear_perfect_switch = point_x
				rpm_curve_peak_value = point_y
	else:
		var current_next_ratio: float = max(float(gear_current), 1.0) / max(float(gear_current) + 1, 1.0)
		for i in range(0, rpm_curve.bake_resolution + 1):
			var point_x_1: float = float(i) / rpm_curve.bake_resolution
			var point_y_1: float = rpm_curve.sample_baked(point_x_1)
			var point_x_2: float = float(i) * current_next_ratio / rpm_curve.bake_resolution
			var point_y_2: float = rpm_curve.sample_baked(point_x_2) * current_next_ratio

			if point_y_2 >= point_y_1 and point_y_1 > 0.0 and point_y_2 > 0.0:
				gear_perfect_switch = point_x_1
				break

	car.set_param(&"gear_perfect_switch", gear_perfect_switch)

func update_gear(delta: float):
	if gear_target != gear_current and not gear_switching:
		gear_switching = true
		if not gear_current == 0:
			gear_switch_timer = gearbox_switch_time
			if sign(gear_current) == -sign(gear_target):
				gear_switch_timer *= 2.0

	if gear_switch_timer <= 0.0 or gear_target == gear_current:
		gear_current = gear_target
		if gear_switching:
			gear_switching = false
			update_gear_perfect_switch()

	if gear_switch_timer >= 0.0:
		gear_switch_timer -= delta

func calculate_gear_limit(gear: int) -> float:
	return abs(gear) / float(gearbox_gear_count)

func update_rpm_ratio(input_accelerate: float, delta: float) -> void:
	rpm_ratio.speed_up = rpm_speed_up
	rpm_ratio.speed_down = rpm_speed_down

	var target_rpm_ratio: float = 0.0
	var local_linear_velocity: Vector3 = car.get_param(&"local_linear_velocity", Vector3.ZERO)
	var ground_coefficient: float = car.get_param(&"ground_coefficient", 0.0)

	if gear_current == 0 or is_zero_approx(ground_coefficient):
		target_rpm_ratio = lerp(rpm_min, rpm_max, input_accelerate)
	elif gear_switching:
		target_rpm_ratio = rpm_min
	else:
		var speed_ratio = abs(local_linear_velocity.z) / engine_top_speed
		var upper_limit: float = 1.0
		if gear_current > 0 and gear_current < gearbox_gear_count:
			upper_limit = calculate_gear_limit(gear_current)
		elif gear_current < 0:
			upper_limit = 1.0 / gearbox_gear_count
		target_rpm_ratio = clamp(remap(speed_ratio, 0.0, upper_limit, rpm_min, rpm_max), 0.0, 1.0)
	# TODO: RPM limiter

	rpm_ratio.advance_to(target_rpm_ratio, delta)

func calculate_acceleration_multiplier(speed_ratio: float) -> float:
	var multiplier: float = 1.0
	multiplier *= rpm_curve.sample_baked(rpm_ratio.get_value())
	multiplier *= 1.0 - calculate_gear_limit(max(0.0, gear_current - 1))

	if gear_current < 0:
		multiplier *= -1.0

	if rpm_ratio.get_value() >= rpm_max:
		multiplier = 0.0

	return multiplier

func process_plugin(delta: float) -> void:
	var input_accelerate: float = car.get_param(&"input_accelerate", 0.0)
	var input_brake: float = car.get_param(&"input_brake", 0.0)
	var input_handbrake: float = car.get_param(&"input_handbrake", 0.0)

	var brake_value: float = max(input_brake, input_handbrake)
	if gear_current != 0:
		input_accelerate *= 1.0 - brake_value

	gear_target = car.get_param(&"input_gear_target", 0)
	update_params()
	update_gear(delta)
	update_rpm_ratio(input_accelerate, delta)

	if gear_switching:
		return
	if gear_current == 0:
		return
	if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
		update_gear_perfect_switch()
		return
	if is_zero_approx(input_accelerate):
		return

	var acceleration_multiplier: float = calculate_acceleration_multiplier(abs(car.get_param(&"local_linear_velocity", Vector3.ZERO).z) / engine_top_speed)
	var force: float = input_accelerate * engine_force * acceleration_multiplier
	if is_zero_approx(force):
		return

	car.set_force(&"engine", Vector3.FORWARD * force, true)
