class_name CarInput extends Node

@export_group("Input Map")
@export var action_forward: StringName = &"aacc_forward"
@export var action_backward: StringName = &"aacc_backward"
@export var action_handbrake: StringName = &"aacc_handbrake"
@export var action_steer_left: StringName = &"aacc_steer_left"
@export var action_steer_right: StringName = &"aacc_steer_right"

@export_group("Steering")
@export var always_full_steer: bool = false
@export var full_steer_on_handbrake: bool = true
@export var desired_smooth_steer_speed: float = 10.0

var smooth_steer: SmoothedFloat = SmoothedFloat.new()

func calculate_steer(input_steer: float, delta: float) -> float:
	var input_full_steer: float = Input.is_action_pressed("aacc_handbrake") if full_steer_on_handbrake else 0.0
	if is_zero_approx(AACCGlobal.car.get_param("GroundCoefficient", 1.0)):
		input_full_steer = 1.0

	# TODO: add an ability to have the car send the info somehow, otherwise this is delayed by a frame
	var distance_between_wheels: float = AACCGlobal.car.get_param("DistanceBetweenWheels", 1.0)
	var base_steer_velocity: float = AACCGlobal.car.get_param("BaseSteerVelocity", 1.0)
	var target_steer_velocity: float = AACCGlobal.car.get_param("TargetSteerVelocity", 1.0)
	var velocity_z: float = abs(AACCGlobal.car.get_param("LocalLinearVelocity", Vector3.ZERO).z)

	var input_steer_multiplier: float = 1.0
	if not always_full_steer:
		input_steer_multiplier = min(distance_between_wheels * (target_steer_velocity / base_steer_velocity) / velocity_z, 1.0)
		input_steer_multiplier = lerp(input_steer_multiplier, 1.0, input_full_steer)
	var input_steer_converted: float = input_steer * input_steer_multiplier

	smooth_steer.speed_up = min(desired_smooth_steer_speed, AACCGlobal.car.get_param("MaxSmoothSteerSpeed", desired_smooth_steer_speed))
	smooth_steer.speed_down = min(desired_smooth_steer_speed, AACCGlobal.car.get_param("MaxSmoothSteerSpeed", desired_smooth_steer_speed))
	smooth_steer.advance_to(input_steer_converted, delta)

	return smooth_steer.get_value()

func calculate_gear_limit(gear: int, gears_count: int) -> float:
	return (1.0 / gears_count) * gear

func calculate_target_gear_auto(input_handbrake: float) -> int:
	var local_linear_velocity: Vector3 = AACCGlobal.car.get_param("LocalLinearVelocity", Vector3.ZERO)
	var ground_coefficient: float = AACCGlobal.car.get_param("GroundCoefficient", 1.0)
	var velocity_z_sign: float = AACCGlobal.car.get_param("VelocityZSign", 0.0)

	var current_gear: int = AACCGlobal.car.get_param("CurrentGear", 0)
	var top_speed: float = AACCGlobal.car.get_param("TopSpeed")
	var gears_count: int = AACCGlobal.car.get_param("GearsCount")
	var current_target_gear: int = roundi(AACCGlobal.car.get_input("TargetGear"))
	
	if (input_handbrake > 0.0 and local_linear_velocity.length() >= 0.25) or is_zero_approx(ground_coefficient):
		return current_gear
	
	if velocity_z_sign > 0:
		return -1

	if abs(local_linear_velocity.z) < 0.25:
		return -velocity_z_sign

	var forward_speed_ratio: float = abs(local_linear_velocity.z / top_speed)
	var lower_gear_limit_offset: float = (5.0 / 3.6) / top_speed # TODO: configure 5.0

	# TODO: make this part more clear
	if current_target_gear > 0 and forward_speed_ratio < calculate_gear_limit(current_target_gear - 1, gears_count) - lower_gear_limit_offset:
		return current_gear - 1
	if forward_speed_ratio > calculate_gear_limit(current_target_gear, gears_count) and current_target_gear < gears_count:
		return current_gear + 1
	return current_target_gear

func _physics_process(delta: float) -> void:
	if not AACCGlobal.car: return

	var input_forward: float = clamp(Input.get_action_strength(action_forward), 0.0, 1.0)
	var input_backward: float = clamp(Input.get_action_strength(action_backward), 0.0, 1.0)
	var input_handbrake: float = 1.0 if Input.is_action_pressed(action_handbrake) else 0.0
	var input_steer: float = clamp(Input.get_action_strength(action_steer_right) - Input.get_action_strength(action_steer_left), -1.0, 1.0)

	var velocity_z_sign: float = AACCGlobal.car.get_param("VelocityZSign")
	if is_zero_approx(velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			velocity_z_sign = 1.0

	if velocity_z_sign <= 0.0:
		AACCGlobal.car.set_input("Accelerate", input_forward)
		AACCGlobal.car.set_input("Reverse", 0.0)
		AACCGlobal.car.set_input("Brake", input_backward)
	elif velocity_z_sign > 0.0:
		AACCGlobal.car.set_input("Accelerate", 0.0)
		AACCGlobal.car.set_input("Reverse", input_backward)
		AACCGlobal.car.set_input("Brake", input_forward)
	AACCGlobal.car.set_input("Handbrake", input_handbrake)
	AACCGlobal.car.set_input("Steer", calculate_steer(input_steer, delta))

	AACCGlobal.car.set_input("TargetGear", calculate_target_gear_auto(input_handbrake))
