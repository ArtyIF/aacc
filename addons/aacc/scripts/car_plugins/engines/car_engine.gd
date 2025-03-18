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
@export var rpm_speed_up: float = 2.0
@export var rpm_speed_down: float = 1.0
# TODO: RPM to torque curve

var current_gear: int = 0
var target_gear: int = 0
var switching_gears: bool = false
var gear_switch_timer: float = 0.0
var rpm_ratio: SmoothedFloat = SmoothedFloat.new()

func _ready() -> void:
	car.set_param(&"input_accelerate", 0.0)
	car.set_param(&"input_target_gear", 0)

	# TODO: DRY
	car.set_param(&"top_speed", engine_top_speed)
	car.set_param(&"gear_count", gearbox_gear_count)
	car.set_param(&"current_gear", current_gear)
	car.set_param(&"switching_gears", switching_gears)
	car.set_param(&"gear_switch_timer", gear_switch_timer)
	car.set_param(&"rpm_ratio", rpm_ratio.get_value())
	car.set_param(&"rpm_curve", rpm_curve)
	car.set_param(&"rpm_min", rpm_min)
	car.set_param(&"rpm_max", rpm_max)

	var rpm_curve_peak: float = rpm_curve.min_domain
	var rpm_curve_peak_value: float = rpm_curve.min_value
	for i in range(0, rpm_curve.bake_resolution + 1):
		var point: float = float(i) / rpm_curve.bake_resolution
		if rpm_curve.sample_baked(point) > rpm_curve_peak_value:
			rpm_curve_peak = point
			rpm_curve_peak_value = rpm_curve.sample_baked(point)
	car.set_param(&"rpm_curve_peak", rpm_curve_peak)

func update_gear(delta: float):
	# TODO: think out the behavior for current and target gear comparison
	if target_gear != current_gear and not switching_gears and sign(current_gear) == sign(target_gear):
		gear_switch_timer = gearbox_switch_time
		switching_gears = true

	if gear_switch_timer <= 0.0 or target_gear == current_gear:
		current_gear = target_gear
		switching_gears = false

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

	if current_gear == 0 or is_zero_approx(ground_coefficient):
		target_rpm_ratio = lerp(rpm_min, rpm_max, input_accelerate)
	elif switching_gears:
		target_rpm_ratio = rpm_min
	else:
		var speed_ratio = abs(local_linear_velocity.z) / engine_top_speed
		var upper_limit: float = 1.0
		if current_gear > 0 and current_gear < gearbox_gear_count:
			upper_limit = calculate_gear_limit(current_gear)
		elif current_gear < 0:
			upper_limit = 1.0 / gearbox_gear_count
		target_rpm_ratio = clamp(remap(speed_ratio, 0.0, upper_limit, rpm_min, rpm_max), 0.0, 1.0)
	# TODO: RPM limiter

	rpm_ratio.advance_to(target_rpm_ratio, delta)

func calculate_acceleration_multiplier(speed_ratio: float) -> float:
	var multiplier: float = 1.0
	multiplier *= rpm_curve.sample_baked(rpm_ratio.get_value())
	multiplier *= 1.0 - calculate_gear_limit(max(0.0, current_gear - 1))

	if current_gear < 0:
		multiplier *= -1.0

	if rpm_ratio.get_value() >= rpm_max:
		multiplier = 0.0

	return multiplier

func process_plugin(delta: float) -> void:
	var input_accelerate: float = car.get_param(&"input_accelerate", 0.0)
	var input_brake: float = car.get_param(&"input_brake", 0.0)
	var input_handbrake: float = car.get_param(&"input_handbrake", 0.0)

	var brake_value: float = max(input_brake, input_handbrake)
	if current_gear != 0:
		input_accelerate *= 1.0 - brake_value

	target_gear = car.get_param(&"input_target_gear", 0)
	update_gear(delta)
	update_rpm_ratio(input_accelerate, delta)

	# TODO: DRY
	car.set_param(&"top_speed", engine_top_speed)
	car.set_param(&"gear_count", gearbox_gear_count)
	car.set_param(&"current_gear", current_gear)
	car.set_param(&"switching_gears", switching_gears)
	car.set_param(&"gear_switch_timer", gear_switch_timer)
	car.set_param(&"rpm_ratio", rpm_ratio.get_value())
	car.set_param(&"rpm_curve", rpm_curve)
	car.set_param(&"rpm_min", rpm_min)
	car.set_param(&"rpm_max", rpm_max)

	if switching_gears:
		return
	if current_gear == 0:
		return
	if is_zero_approx(car.get_param(&"ground_coefficient", 0.0)):
		return
	if is_zero_approx(input_accelerate):
		return

	var acceleration_multiplier: float = calculate_acceleration_multiplier(abs(car.get_param(&"local_linear_velocity", Vector3.ZERO).z) / engine_top_speed)
	var force: Vector3 = Vector3.FORWARD * input_accelerate * engine_force * acceleration_multiplier
	car.set_force(&"engine", force, true)
