class_name CarEngine extends CarPluginBase

# TODO: more detailed?

@export var top_speed: float = 50.0
@export var max_engine_force: float = 10000.0
@export var gears_count: int = 5
@export var gear_switch_time: float = 0.1
# this applies a smooth drop-off to the engine force when the speed is over the
# current gear's top speed
@export var gear_upper_limit_offset_ratio: float = 0.1
@export var rpm_ratio_speed_up: float = 2.0
@export var rpm_ratio_speed_down: float = 1.0

var current_gear: int = 0
var target_gear: int = 0
var switching_gears: bool = false
var gear_switch_timer: float = 0.0
var rpm_ratio: SmoothedFloat = SmoothedFloat.new()

func _ready() -> void:
	car.set_input("Accelerate", 0.0)
	car.set_input("TargetGear", 0.0)

	car.set_param("TopSpeed", top_speed)
	car.set_param("GearsCount", gears_count)
	car.set_param("CurrentGear", current_gear)
	car.set_param("SwitchingGears", switching_gears)
	car.set_param("GearSwitchTimer", gear_switch_timer)
	car.set_param("RPMRatio", rpm_ratio)
	car.set_param("RPMLimiter", 1.0 - gear_upper_limit_offset_ratio)

func update_gear(delta: float):
	# TODO: think out the behavior for current and target gear comparison
	if target_gear != current_gear and not switching_gears and sign(current_gear) == sign(target_gear):
		gear_switch_timer = gear_switch_time
		switching_gears = true

	if gear_switch_timer <= 0.0 or target_gear == current_gear:
		current_gear = target_gear
		switching_gears = false

	if gear_switch_timer >= 0.0:
		gear_switch_timer -= delta

func calculate_gear_limit(gear: int) -> float:
	return abs(gear) / float(gears_count)

func update_rpm_ratio(input_accelerate: float, delta: float) -> void:
	rpm_ratio.speed_up = rpm_ratio_speed_up
	rpm_ratio.speed_down = rpm_ratio_speed_down

	var target_rpm_ratio: float = 0.0
	var local_linear_velocity: Vector3 = car.get_param("LocalLinearVelocity")
	var ground_coefficient: float = car.get_param("GroundCoefficient", 1.0)

	if current_gear == 0 or is_zero_approx(ground_coefficient):
		target_rpm_ratio = input_accelerate
	elif switching_gears:
		target_rpm_ratio = 0.0
	else:
		var upper_limit: float = 0.0
		if current_gear > 0 and current_gear < gears_count:
			var max_speed: float = min(top_speed * calculate_gear_limit(current_gear), top_speed)
			var gear_upper_limit_offset: float = gear_upper_limit_offset_ratio * max_speed
			upper_limit = top_speed * calculate_gear_limit(current_gear) + gear_upper_limit_offset
		elif current_gear == gears_count:
			upper_limit = top_speed
		elif current_gear < 0:
			upper_limit = top_speed / gears_count
		target_rpm_ratio = clamp(inverse_lerp(0.0, upper_limit, abs(local_linear_velocity.z)), 0.0, 1.0)
	# TODO: add a minimum RPM sort of thing
	# TODO: RPM limiter

	rpm_ratio.advance_to(target_rpm_ratio, delta)

func calculate_acceleration_multiplier(speed: float) -> float:
	var multiplier: float = 1.0
	# TODO: use that but with an RPM-to-power/torque curve
	#multiplier *= 1.0 - rpm_ratio.get_value()
	#multiplier *= 1.0 - calculate_gear_limit(max(0.0, current_gear - 1))
	#return multiplier

	if current_gear > 0:
		multiplier = 1.0 - min(speed / top_speed, 1.0)
		multiplier = min(multiplier, 1.0 - calculate_gear_limit(max(0.0, current_gear - 1)))

		var max_speed: float = min(top_speed * calculate_gear_limit(current_gear), top_speed)
		if speed >= max_speed:
			multiplier *= min(inverse_lerp(max_speed + (gear_upper_limit_offset_ratio * max_speed), max_speed, speed), 1.0)
	else:
		multiplier = 1.0 - min(speed * gears_count / top_speed, 1.0)
		multiplier *= -1.0

	return multiplier

func process_plugin(delta: float) -> void:
	var input_accelerate: float = car.get_input("Accelerate")
	var input_brake: float = car.get_input("Brake")
	var input_handbrake: float = car.get_input("Handbrake")

	var brake_value: float = max(input_brake, input_handbrake)
	if current_gear != 0:
		input_accelerate *= 1.0 - brake_value

	target_gear = roundi(car.get_input("TargetGear"))
	update_gear(delta)
	update_rpm_ratio(input_accelerate, delta)

	car.set_param("TopSpeed", top_speed)
	car.set_param("GearsCount", gears_count)
	car.set_param("CurrentGear", current_gear)
	car.set_param("SwitchingGears", switching_gears)
	car.set_param("GearSwitchTimer", gear_switch_timer)
	car.set_param("RPMRatio", rpm_ratio.get_value())
	car.set_param("RPMLimiter", 1.0 - gear_upper_limit_offset_ratio)

	if switching_gears:
		return
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var force: Vector3 = Vector3.ZERO
	var max_speed: float = min(top_speed * calculate_gear_limit(current_gear), top_speed)
	var gear_upper_limit_offset: float = gear_upper_limit_offset_ratio * max_speed
	if car.get_param("LocalLinearVelocity").z + gear_upper_limit_offset > -max_speed and car.get_param("LocalLinearVelocity").z < top_speed / gears_count:
		force += Vector3.FORWARD * input_accelerate * max_engine_force * calculate_acceleration_multiplier(abs(car.get_param("LocalLinearVelocity").z))
	car.set_force("Engine", force, true)
