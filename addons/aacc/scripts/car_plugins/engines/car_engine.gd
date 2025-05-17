class_name CarEngine extends CarPluginBase

@export_group("Engine", "engine_")
@export var engine_max_force: float = 10000.0
@export var engine_top_speed: float = 50.0

@export_group("Gearbox", "gearbox_")
@export var gearbox_gear_count: int = 5
@export var gearbox_switch_time: float = 0.1
@export var gearbox_allow_reverse: bool = true

@export_group("RPM", "rpm_")
@export var rpm_curve: Curve
@export var rpm_min: float = 0.1
@export var rpm_max: float = 0.9
@export var rpm_limiter_offset: float = 0.05
@export var rpm_speed_up: float = 1.0
@export var rpm_speed_down: float = 0.5

var gear_current: int = 0
var gear_target: int = 0
var gear_switch_timer: SmoothedFloat = SmoothedFloat.new(-1.0)
var gear_switching: bool = false
var rpm_ratio: SmoothedFloat = SmoothedFloat.new()
var rpm_limiter: bool = false # TODO: rewrite rpm limiters

func _ready() -> void:
	car.set_meta(&"input_accelerate", 0.0)
	car.set_meta(&"input_gear_target", 0)
	update_meta()

func update_meta():
	car.set_meta(&"engine_top_speed", engine_top_speed)
	car.set_meta(&"engine_max_force", engine_max_force)

	# TODO: gearbox_
	car.set_meta(&"gear_count", gearbox_gear_count)
	car.set_meta(&"gear_allow_reverse", gearbox_allow_reverse)
	car.set_meta(&"gear_current", gear_current)
	car.set_meta(&"gear_switching", gear_switching)
	car.set_meta(&"gear_switch_timer", gear_switch_timer.get_value())

	car.set_meta(&"rpm_ratio", rpm_ratio.get_value())
	car.set_meta(&"rpm_curve", rpm_curve)
	car.set_meta(&"rpm_min", rpm_min)
	car.set_meta(&"rpm_max", rpm_max)
	car.set_meta(&"rpm_limiter", rpm_limiter)

func update_gear(delta: float):
	gear_target = clampi(gear_target, -1 if gearbox_allow_reverse else 0, gearbox_gear_count)

	if not gear_switching and gear_target != gear_current and not gear_current == 0:
		gear_switching = true
		gear_switch_timer.force_current_value(gearbox_switch_time)

	if gear_switch_timer.get_value() <= 0.0 or gear_target == gear_current:
		gear_current = gear_target
		if gear_switching:
			gear_switching = false

	gear_switch_timer.advance_to(-1.0, delta)

func calculate_gear_limit(gear: int) -> float:
	return abs(gear) / float(gearbox_gear_count)

func update_rpm_ratio(input_accelerate: float, delta: float) -> void:
	rpm_ratio.speed_up = rpm_speed_up
	rpm_ratio.speed_down = rpm_speed_down

	var rpm_ratio_target: float = 0.0
	var local_linear_velocity: Vector3 = car.get_meta(&"local_linear_velocity", Vector3.ZERO)
	var ground_coefficient: float = car.get_meta(&"ground_coefficient", 0.0)

	if rpm_limiter:
		rpm_ratio_target = rpm_min
	elif gear_current == 0 or is_zero_approx(ground_coefficient):
		rpm_ratio_target = lerp(rpm_min, 1.0, input_accelerate)
	else:
		var speed_ratio = abs(local_linear_velocity.z) / engine_top_speed
		var upper_limit: float = 1.0
		if gear_target > 0 and gear_target <= gearbox_gear_count:
			upper_limit = calculate_gear_limit(gear_target)
		elif gear_target < 0:
			upper_limit = 1.0 / gearbox_gear_count
		rpm_ratio_target = clamp(remap(speed_ratio, 0.0, upper_limit, rpm_min, rpm_max), 0.0, 1.0)

	rpm_ratio.advance_to(rpm_ratio_target, delta)

func calculate_acceleration_multiplier(speed_ratio: float) -> float:
	var multiplier: float = 1.0
	multiplier *= rpm_curve.sample_baked(rpm_ratio.get_value())
	multiplier *= 1.0 - calculate_gear_limit(max(0.0, gear_current - 1))

	if gear_current < 0 and gearbox_allow_reverse:
		multiplier *= -1.0

	if rpm_ratio.get_value() >= rpm_max:
		multiplier = 0.0

	return multiplier

func process_plugin(delta: float) -> void:
	var input_accelerate: float = car.get_meta(&"input_accelerate", 0.0)

	gear_target = car.get_meta(&"input_gear_target", 0)
	update_gear(delta)
	update_rpm_ratio(input_accelerate, delta)
	update_meta()

	if not is_zero_approx(rpm_limiter_offset) and ((gear_current >= 0 and not gear_current == gearbox_gear_count) or is_zero_approx(car.get_meta(&"ground_coefficient", 0.0))):
		if rpm_ratio.get_value() >= rpm_max:
			rpm_limiter = true
		elif rpm_ratio.get_value() <= rpm_max - rpm_limiter_offset:
			rpm_limiter = false
	else:
		rpm_limiter = false
	car.set_meta(&"rpm_limiter", rpm_limiter)

	car.set_meta(&"engine_desired_force_ratio", 0.0)
	if gear_switching or rpm_limiter:
		return
	if is_zero_approx(input_accelerate):
		return

	var acceleration_multiplier: float = calculate_acceleration_multiplier(abs(car.get_meta(&"local_linear_velocity", Vector3.ZERO).z) / engine_top_speed)
	var force_ratio: float = input_accelerate * acceleration_multiplier
	car.set_meta(&"engine_desired_force_ratio", force_ratio)

	if gear_current == 0:
		return

	if is_zero_approx(force_ratio):
		return

	car.set_force(&"engine", Vector3.FORWARD * force_ratio * engine_max_force, true)
