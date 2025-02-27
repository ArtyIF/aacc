class_name Car extends RigidBody3D

# TODO: split into plugins

@export_group("Acceleration")
@export var top_speed_forward: float = 50.0
@export var top_speed_reverse: float = 10.0
@export var max_acceleration: float = 2000.0
@export_exp_easing("attenuation") var acceleration_curve: float = 1.0

@export_group("Steering")
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var base_steer_velocity: float = deg_to_rad(30.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var target_steer_velocity: float = deg_to_rad(60.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var max_steer_velocity: float = deg_to_rad(180.0)
@export var distance_between_wheels: float = 1.5
@export var smooth_steer_speed: float = 10.0

@export_group("Traction")
@export var linear_grip: float = 20000.0
@export var angular_grip: float = 10000.0
@export var brake_force: float = 4000.0

#== NODES ==#
var wheels: Array[CarWheel]

#== INPUT ==#
var input_forward: float = 0.0
var input_backward: float = 0.0
var input_steer: float = 0.0
var input_handbrake: bool = false
var old_input_handbrake: bool = false

#== VELOCITIES ==#
var local_linear_velocity: Vector3 = Vector3.ZERO
var local_angular_velocity: Vector3 = Vector3.ZERO
var old_linear_velocity: Vector3 = Vector3.ZERO
var old_angular_velocity: Vector3 = Vector3.ZERO

#== GROUND ==#
var ground_coefficient: float = 1.0
var average_wheel_collision_point: Vector3 = Vector3.ZERO
var average_wheel_collision_normal: Vector3 = Vector3.ZERO

#== SMOOTH VALUES ==#
var smooth_steer: SmoothedFloat = SmoothedFloat.new()

func _ready():
	for wheel in get_children():
		if wheel is CarWheel:
			wheels.append(wheel)

## Resets every dynamically-updated value to their initial value. Exported
## values that are user-editable are not affected.
func reset() -> void:
	#== INPUT ==#
	input_forward = 0.0
	input_backward = 0.0
	input_steer = 0.0
	input_handbrake = false
	old_input_handbrake = false

	#== VELOCITIES ==#
	local_linear_velocity = Vector3.ZERO
	local_angular_velocity = Vector3.ZERO
	old_linear_velocity = Vector3.ZERO
	old_angular_velocity = Vector3.ZERO

	#== GROUND ==#
	ground_coefficient = 1.0
	average_wheel_collision_point = Vector3.ZERO
	average_wheel_collision_normal = Vector3.ZERO

	#== SMOOTH VALUES ==#
	smooth_steer = SmoothedFloat.new()
	
	#== WHEELS ==#
	for wheel in wheels:
		wheel.reset()

#region Processing
func get_input_steer_multiplier() -> float:
	if local_linear_velocity.z > 0.0: return 1.0
	if input_handbrake: return 1.0

	var velocity_z = abs(local_linear_velocity.z)
	return min(distance_between_wheels * (target_steer_velocity / base_steer_velocity) / velocity_z, 1.0)

func process_smooth_values(delta: float):
	smooth_steer.advance_to(input_steer * (get_input_steer_multiplier() if ground_coefficient > 0.0 else 1.0), delta)
#endregion

#region Acceleration
func is_reversing() -> bool:
	if local_linear_velocity.z >= 0.25:
		return true
	elif local_linear_velocity.z <= -0.25:
		return false
	else:
		return input_backward > 0.0 and input_forward == 0.0

func calculate_acceleration_multiplier() -> float:
	var relative_speed: float = abs(local_linear_velocity.z) / (top_speed_reverse if is_reversing() else top_speed_forward)
	return clamp(ease(1.0 - relative_speed, acceleration_curve), 0.0, 1.0)

func get_engine_force() -> float:
	if input_handbrake: return 0.0
	return (-input_backward if is_reversing() else input_forward) * max_acceleration * calculate_acceleration_multiplier()
#endregion

#region Traction
func get_brake_force() -> float:
	var brake_speed = clamp(local_linear_velocity.z, -1.0, 1.0)
	return brake_speed * brake_force * (1.0 if input_handbrake else (input_forward if is_reversing() else input_backward))

func get_side_grip_force() -> float:
	return -local_linear_velocity.x * mass
#endregion

#region Steering
func calculate_steer_coefficient() -> float:
	var velocity_multiplier: float = abs(local_linear_velocity.z)
	return sign(local_linear_velocity.z) * velocity_multiplier / distance_between_wheels

func get_steer_force() -> float:
	var steer_amount = smooth_steer.get_current_value() * calculate_steer_coefficient()

	var steer_velocity: float = clamp(steer_amount * base_steer_velocity, -max_steer_velocity, max_steer_velocity)
	var steer_force: float = steer_velocity - local_angular_velocity.y
	return steer_force * mass
#endregion

#region Force Conversion
func convert_linear_force(input: Vector3, delta: float) -> Vector3:
	var converted_force: Vector3 = input
	converted_force = global_basis * converted_force
	converted_force = Plane(average_wheel_collision_normal).project(converted_force)
	converted_force = converted_force.limit_length(linear_grip * delta)

	return converted_force

func convert_angular_force(input: Vector3, delta: float, limit_length: bool = true) -> Vector3:
	var converted_force: Vector3 = input

	converted_force = global_basis * converted_force
	if limit_length:
		converted_force = converted_force.limit_length(angular_grip)

	return converted_force
#endregion

func _physics_process(delta: float) -> void:
	smooth_steer.speed_up = smooth_steer_speed
	smooth_steer.speed_down = smooth_steer_speed

	ground_coefficient = 0.0
	average_wheel_collision_point = Vector3.ZERO
	average_wheel_collision_normal = Vector3.ZERO

	for wheel in wheels:
		if wheel.is_colliding:
			ground_coefficient += 1
			average_wheel_collision_point += wheel.collision_point
			average_wheel_collision_normal += wheel.collision_normal

	if ground_coefficient > 0:
		average_wheel_collision_point /= ground_coefficient
		average_wheel_collision_normal = average_wheel_collision_normal.normalized()
		ground_coefficient /= len(wheels)

	local_linear_velocity = global_transform.basis.inverse() * linear_velocity
	local_angular_velocity = global_transform.basis.inverse() * angular_velocity

	process_smooth_values(delta)

	if ground_coefficient > 0.0:
		var desired_linear_grip_force: Vector3 = Vector3.RIGHT * get_side_grip_force()
		var desired_engine_force: Vector3 = Vector3.FORWARD * get_engine_force() * delta
		var desired_brake_force: Vector3 = Vector3.FORWARD * get_brake_force() * delta

		var sum_of_linear_forces: Vector3 = convert_linear_force(desired_linear_grip_force + desired_engine_force + desired_brake_force, delta)
		apply_force(sum_of_linear_forces * ground_coefficient / delta, average_wheel_collision_point - global_position)

		var desired_steer_force: Vector3 = Vector3.UP * get_steer_force()
		var sum_of_angular_forces: Vector3 = convert_angular_force(desired_steer_force, delta)
		apply_torque(sum_of_angular_forces.project(average_wheel_collision_normal) * ground_coefficient / delta)

	old_linear_velocity = linear_velocity
	old_angular_velocity = angular_velocity
	old_input_handbrake = input_handbrake
