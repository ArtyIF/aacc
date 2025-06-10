class_name CarInputEngineAuto extends ScenePluginBase

@export_group("Input Map")
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_forward: StringName = &"aacc_forward"
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_backward: StringName = &"aacc_backward"

@export_group("Gearbox")
@export var downshift_offset: float = 0.1

var gear_target: int = 0

var plugin_lvp: CarLocalVelocityProcessor

func update_car(new_car: Car) -> void:
	super(new_car)
	plugin_lvp = car.get_plugin(&"LocalVelocityProcessor")

func calculate_gear_limit(gear: int, gear_count: int) -> float:
	return float(gear) / gear_count

func calculate_gear_target(input_handbrake: bool, local_velocity_z_sign: float) -> int:
	var gear_target_car: int = car.get_meta(&"input_gear_target", 0)

	var local_velocity_linear: Vector3 = plugin_lvp.local_velocity_linear
	var ground_coefficient: float = car.get_meta(&"ground_coefficient", 1.0)

	var gear_current: int = car.get_meta(&"gear_current", 0)
	var gear_count: int = car.get_meta(&"gearbox_gear_count", 0)
	var engine_top_speed: float = car.get_meta(&"engine_top_speed", 0.0)

	if (input_handbrake and local_velocity_linear.length() >= 0.25) or is_zero_approx(ground_coefficient):
		return gear_target_car
	if input_handbrake and local_velocity_linear.length() < 0.25:
		return 0

	if abs(local_velocity_linear.z) < 0.25:
		return -local_velocity_z_sign

	if local_velocity_z_sign > 0:
		return -1

	var gear_perfect_shift_up: float = AACCCurveTools.get_gear_perfect_shift_up(car)
	var gear_perfect_shift_down: float = AACCCurveTools.get_gear_perfect_shift_down(car) - downshift_offset
	var rpm_ratio: float = abs(local_velocity_linear.z) / (engine_top_speed * calculate_gear_limit(gear_current, gear_count))
	rpm_ratio = lerp(car.get_meta(&"rpm_min"), car.get_meta(&"rpm_max"), rpm_ratio)

	if rpm_ratio < gear_perfect_shift_down and gear_target_car > 0:
		return gear_current - 1
	if rpm_ratio > gear_perfect_shift_up and gear_target_car < gear_count:
		return gear_current + 1

	return gear_target_car

func _physics_process(delta: float) -> void:
	if not is_instance_valid(car): return

	var input_forward: float = clamp(Input.get_action_strength(action_forward), 0.0, 1.0)
	var input_backward: float = clamp(Input.get_action_strength(action_backward), 0.0, 1.0)
	var input_handbrake: bool = car.get_meta(&"input_handbrake", false)

	var local_velocity_z_sign: float = plugin_lvp.local_velocity_z_sign
	if is_zero_approx(local_velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			local_velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			local_velocity_z_sign = 1.0

	gear_target = calculate_gear_target(input_handbrake, local_velocity_z_sign)
	var gear_allow_reverse: bool = car.get_meta(&"gearbox_allow_reverse", false)
	if not gear_allow_reverse:
		gear_target = max(0, gear_target)
	car.set_meta(&"input_gear_target", gear_target)

	if gear_target == 0 or (sign(gear_target) != sign(car.get_meta(&"gear_current", 0))):
		car.set_meta(&"input_accelerate", max(input_forward, input_backward) if gear_allow_reverse else input_forward)
		car.set_meta(&"input_brake", 1.0)
	elif gear_target > 0:
		car.set_meta(&"input_accelerate", input_forward)
		car.set_meta(&"input_brake", input_backward)
	elif gear_target < 0:
		car.set_meta(&"input_accelerate", input_backward)
		car.set_meta(&"input_brake", input_forward)
