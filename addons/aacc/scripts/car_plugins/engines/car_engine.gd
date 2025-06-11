class_name CarEngine extends CarPluginBase

@export_group("Engine", "engine_")
@export var engine_max_force: float = 10000.0
@export var engine_top_speed: float = 50.0

@export_group("Start Boost", "boost_")
@export var boost_multiplier: float = 2.0
@export var boost_power_threshold: float = 0.8
@export var boost_duration: float = 1.0

@export_group("Gearbox", "gearbox_")
@export var gearbox_gear_count: int = 5
@export var gearbox_switch_time: float = 0.1
@export var gearbox_allow_reverse: bool = true

@export_group("RPM", "rpm_")
@export var rpm_curve: Curve
@export var rpm_min: float = 0.1
@export var rpm_max: float = 0.9
@export var rpm_limiter_offset: float = 0.05
@export var rpm_speed_up: float = 10.0
@export var rpm_speed_down: float = 5.0
@export var rpm_speed_up_idle: float = 2.0
@export var rpm_speed_down_idle: float = 1.0

var gear_current: int = 0
var gear_target: int = 0
var gear_switch_timer: SmoothedFloat = SmoothedFloat.new(-1.0)
var gear_switching: bool = false

var boost_amount: SmoothedFloat = SmoothedFloat.new()

var rpm_ratio: SmoothedFloat = SmoothedFloat.new()
var rpm_limiter: bool = false # TODO: rewrite rpm limiters

var force_ratio: float = 0.0

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func _ready() -> void:
	car.set_meta(&"input_accelerate", 0.0)
	car.set_meta(&"input_gear_target", 0)

	debuggable_parameters = [
		&"gear_current",
		&"gear_target",
		&"gear_switch_timer",
		&"gear_switching",
		&"boost_amount",
		&"rpm_ratio",
		&"rpm_limiter",
		&"force_ratio",
	]

func update_gear(delta: float):
	gear_target = clampi(gear_target, -1 if gearbox_allow_reverse else 0, gearbox_gear_count)

	if gear_current == 0 and gear_target != 0 and rpm_curve.sample_baked(rpm_ratio.get_value()) >= boost_power_threshold:
		boost_amount.force_current_value(rpm_curve.sample_baked(rpm_ratio.get_value()))

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

func update_rpm_ratio(input_accelerate: float, ground_coefficient: float, local_velocity_linear: Vector3, delta: float) -> void:
	if gear_current == 0 or gear_switching or rpm_limiter or is_zero_approx(ground_coefficient):
		rpm_ratio.speed_up = rpm_speed_up_idle
		rpm_ratio.speed_down = rpm_speed_down_idle
	else:
		rpm_ratio.speed_up = rpm_speed_up
		rpm_ratio.speed_down = rpm_speed_down

	var rpm_ratio_target: float = 0.0

	if rpm_limiter or gear_switching:
		rpm_ratio_target = rpm_min
	elif gear_current == 0 or is_zero_approx(ground_coefficient):
		rpm_ratio_target = lerp(rpm_min, 1.0, input_accelerate)
	else:
		var speed_ratio = abs(local_velocity_linear.z) / engine_top_speed
		var upper_limit: float = 1.0
		if gear_target > 0 and gear_target <= gearbox_gear_count:
			upper_limit = calculate_gear_limit(gear_target)
		elif gear_target < 0:
			upper_limit = 1.0 / gearbox_gear_count
		rpm_ratio_target = clamp(remap(speed_ratio, 0.0, upper_limit, rpm_min, rpm_max), 0.0, 1.0)

	var delta_multiplier: float = 1.0
	if rpm_ratio.get_value() >= rpm_min:
		if rpm_ratio_target > rpm_ratio.get_value():
			delta_multiplier = rpm_curve.sample_baked(rpm_ratio.get_value())
		else:
			delta_multiplier = rpm_ratio.get_value()
	rpm_ratio.advance_to(rpm_ratio_target, delta * delta_multiplier)

func calculate_acceleration_multiplier(speed_ratio: float) -> float:
	var multiplier: float = 1.0
	multiplier *= rpm_curve.sample_baked(rpm_ratio.get_value())
	multiplier *= 1.0 - calculate_gear_limit(max(0.0, gear_current - 1))
	multiplier *= lerp(1.0, boost_multiplier, boost_amount.get_value())

	if gear_current < 0 and gearbox_allow_reverse:
		multiplier *= -1.0

	return multiplier

func process_plugin(delta: float) -> void:
	var input_accelerate: float = car.get_meta(&"input_accelerate")
	var ground_coefficient: float = plugin_wp.ground_coefficient
	var local_velocity_linear: Vector3 = plugin_lvp.local_velocity_linear

	gear_target = car.get_meta(&"input_gear_target")
	update_gear(delta)
	update_rpm_ratio(input_accelerate, ground_coefficient, local_velocity_linear, delta)

	if not is_zero_approx(rpm_limiter_offset) and ((gear_current >= 0 and not gear_current == gearbox_gear_count) or is_zero_approx(ground_coefficient)):
		if rpm_ratio.get_value() >= rpm_max:
			rpm_limiter = true
		elif rpm_ratio.get_value() <= rpm_max - rpm_limiter_offset:
			rpm_limiter = false
	else:
		rpm_limiter = false

	boost_amount.advance_to(0.0, delta / boost_duration)

	force_ratio = 0.0
	if gear_switching or rpm_limiter:
		return
	if is_zero_approx(input_accelerate):
		return

	var acceleration_multiplier: float = calculate_acceleration_multiplier(abs(local_velocity_linear.z) / engine_top_speed)
	force_ratio = input_accelerate * acceleration_multiplier

	if gear_current == 0:
		return

	if is_zero_approx(force_ratio):
		return

	car.set_force(&"engine", Vector3.FORWARD * force_ratio * engine_max_force, true)
