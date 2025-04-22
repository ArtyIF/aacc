class_name CarInputEngineAuto extends ScenePluginBase

@export_group("Input Map")
@export var action_forward: StringName = &"aacc_forward"
@export var action_backward: StringName = &"aacc_backward"
# TODO: reimplement launch control toggle?

@export_group("Gearbox")
@export var shift_timeout: float = 0.5

var gear_target: int = 0
var gear_switch_timeout: SmoothedFloat = SmoothedFloat.new(-1.0)

func calculate_gear_limit(gear: int, gear_count: int) -> float:
	return float(gear) / gear_count

func calculate_gear_target(input_handbrake: bool, velocity_z_sign: float) -> int:
	var gear_target: int = car.get_meta(&"input_gear_target", 0)
	if gear_switch_timeout.get_value() > 0.0 or car.get_meta(&"gear_switching", false):
		return gear_target

	var local_linear_velocity: Vector3 = car.get_meta(&"local_linear_velocity", Vector3.ZERO)
	var ground_coefficient: float = car.get_meta(&"ground_coefficient", 1.0)

	var gear_current: int = car.get_meta(&"gear_current", 0)
	var gear_count: int = car.get_meta(&"gear_count", 0)

	if (input_handbrake and local_linear_velocity.length() >= 0.25) or is_zero_approx(ground_coefficient):
		return gear_current
	if input_handbrake and local_linear_velocity.length() < 0.25:
		return 0

	if velocity_z_sign > 0:
		return -1

	if abs(local_linear_velocity.z) < 0.25:
		return -velocity_z_sign

	var gear_perfect_shift_up: float = AACCCurveTools.get_gear_perfect_shift_up(car)
	var gear_perfect_shift_down: float = AACCCurveTools.get_gear_perfect_shift_down(car)

	# TODO: make it shift several gears up/down at once when necessary
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
	var input_handbrake: bool = car.get_meta(&"input_handbrake", false)

	var velocity_z_sign: float = car.get_meta(&"velocity_z_sign", 0.0)
	if is_zero_approx(velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			velocity_z_sign = 1.0

	var gear_target_new: int = calculate_gear_target(input_handbrake, velocity_z_sign)
	# TODO: rewrite this, causes issues
	if gear_target != gear_target_new:
		gear_switch_timeout.force_current_value(shift_timeout)
		gear_target = gear_target_new
	car.set_meta(&"input_gear_target", gear_target)

	if gear_target > 0:
		car.set_meta(&"input_accelerate", input_forward)
		car.set_meta(&"input_brake", input_backward)
	elif gear_target < 0:
		car.set_meta(&"input_accelerate", input_backward)
		car.set_meta(&"input_brake", input_forward)
	else:
		car.set_meta(&"input_accelerate", max(input_forward, input_backward))
		car.set_meta(&"input_brake", 1.0)

	if not car.get_meta(&"gear_switching", false):
		gear_switch_timeout.advance_to(-1.0, delta)
