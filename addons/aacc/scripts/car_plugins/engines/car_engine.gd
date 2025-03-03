class_name CarEngine extends CarPluginBase

@export var top_speed: float = 50.0
@export var max_engine_force: float = 10000.0
@export var gears_count: int = 5
@export var gear_switch_time: float = 0.1

var current_gear: int = 0
var target_gear: int = 0
var switching_gears: bool = false
var gear_switch_timer: float = 0.0
var rpm_ratio: float = 0.0

func _ready() -> void:
	car.add_input("Accelerate")
	car.add_input("Reverse")
	car.add_input("TargetGear")

	car.add_param("TopSpeed", top_speed)
	car.add_param("GearsCount", gears_count)
	car.add_param("CurrentGear", current_gear)
	car.add_param("SwitchingGears", switching_gears)
	car.add_param("GearSwitchTimer", gear_switch_timer)
	car.add_param("RPMRatio", rpm_ratio)

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
	return gear / float(gears_count)

# TODO: make rpm affect acceleration
# TODO: change rpm from ratio to actual rpm
# TODO: currently manual transmision is not supported. make it supported

# this is very barebones and unsmoothed
func update_rpm_ratio(input_accelerate: float, input_reverse: float) -> void:
	var target_rpm_ratio: float = 0.0
	var local_linear_velocity: Vector3 = car.get_param("LocalLinearVelocity", Vector3.ZERO)
	var ground_coefficient: float = car.get_param("GroundCoefficient", 1.0)

	if abs(local_linear_velocity.z) < 0.25 or is_zero_approx(ground_coefficient):
		if current_gear == 0:
			target_rpm_ratio = max(input_accelerate, input_reverse)
		else:
			target_rpm_ratio = input_accelerate
	else:
		if current_gear > 0:
			target_rpm_ratio = clamp(inverse_lerp(0.0, top_speed * calculate_gear_limit(target_gear), abs(local_linear_velocity.z)), 0.0, 1.0)
		elif current_gear < 0:
			target_rpm_ratio = clamp(inverse_lerp(0.0, top_speed / gears_count, abs(local_linear_velocity.z)), 0.0, 1.0)

	rpm_ratio = target_rpm_ratio

func calculate_acceleration_multiplier() -> float:
	var multiplier: float = 1.0
	multiplier *= 1.0 - calculate_gear_limit(current_gear - 1)
	return multiplier

func process_plugin(delta: float) -> void:
	if is_zero_approx(car.get_param("GroundCoefficient")):
		return

	var input_accelerate: float = car.get_input("Accelerate")
	var input_reverse: float = car.get_input("Reverse")

	var input_brake: float = car.get_input("Brake")
	var input_handbrake: float = car.get_input("Handbrake")
	var brake_value: float = max(input_brake, input_handbrake)
	input_accelerate *= 1.0 - brake_value
	input_reverse *= 1.0 - brake_value

	target_gear = roundi(car.get_input("TargetGear"))
	update_gear(delta)
	update_rpm_ratio(input_accelerate, input_reverse)

	car.set_param("TopSpeed", top_speed)
	car.set_param("GearsCount", gears_count)
	car.set_param("CurrentGear", current_gear)
	car.set_param("SwitchingGears", switching_gears)
	car.set_param("GearSwitchTimer", gear_switch_timer)
	car.set_param("RPMRatio", rpm_ratio)

	if switching_gears:
		return

	var force: Vector3 = Vector3.ZERO
	# TODO: smooth this out
	if car.get_param("LocalLinearVelocity").z > -top_speed:
		force += Vector3.FORWARD * input_accelerate * max_engine_force * calculate_acceleration_multiplier()
	if car.get_param("LocalLinearVelocity").z < top_speed / gears_count:
		force -= Vector3.FORWARD * input_reverse * max_engine_force
	car.add_force("Engine", force, true)
