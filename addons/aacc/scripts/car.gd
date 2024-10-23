## Arty's Arcadey Car Controller's main class.
##
## This is the class that stores parameters for the car and calculates
## engine and steering for it.
@icon("res://addons/aacc/icons/car.svg")
class_name Car extends RigidBody3D

# TODO: split all this up into separate classes for better customization
@export_group("Engine")
## The top speed in meters per second when going forward.
@export var top_speed_forward: float = 50.0
## The top speed in meters per second when going in reverse.
@export var top_speed_reverse: float = 10.0
## The maximum acceleration at first gear.
## TODO: implement gears
@export var max_acceleration: float = 2000.0
## The curve applied to acceleration for each gear.
## TODO: implement gears
@export_exp_easing("attenuation") var acceleration_curve: float = 1.0
## The force that simulates resistance. Makes the car slow down when no
## acceleration is applied.
@export var slowdown_force: float = 200.0

@export_group("Steering")
## The base steer velocity per second that the car turns at when a speed of
## [member distance_between_wheels] m/s is reached.
## [br][br]
## Before reaching [member distance_between_wheels] m/s, the car steers slower,
## and after it steers faster. See also [member target_steer_velocity] and 
## [member max_steer_velocity].
## TODO: rename to base_steer_velocity
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var base_steer_degrees: float = deg_to_rad(30.0)
## The steer velocity per second that the car targets.
## [br][br]
## This is done by reducing the final steer input accordingly when the speed is
## high enough. See also [member base_steer_degrees] and
## [member max_steer_velocity].
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var target_steer_velocity: float = deg_to_rad(60.0)
## The maximum steer velocity per second. Used to limit steer tug.
## [br][br]
## For relevant steering properties, see [member base_steer_degrees] and 
## [member target_steer_velocity]. For steer tug properties, see
## [member steer_tug_slide] and [member max_steer_tug].
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var max_steer_velocity: float = deg_to_rad(180.0)
## The distance between front and rear wheels. Used to calculate the appropriate
## steer velocity.
@export var distance_between_wheels: float = 1.5
## The speed per second at which the final steer value moves at.
@export var smooth_steer_speed: float = 10.0
## The slide velocity at which the steer tug becomes 1.
## [br][br]
## The steer tug offsets the final steer value to simulate the difficulty of
## straightening the car during a drift.
## TODO: rewrite steer tug properties to be more clear
@export var steer_tug_slide: float = 5.0
## The maximum allowed steer tug.
@export var max_steer_tug: float = 2.0

@export_group("Traction")
## The amount of grip applied to the side velocity (X axis) and the velocity
## length.
@export var linear_grip: float = 20000.0
## The minimum multiple of [member linear_grip] that can be applied to the side
## velocity.
@export_range(0.0, 1.0) var min_side_grip: float = 0.5
## The speed along the X axis where the side grip becomes
## [member min_side_grip].
@export var min_side_grip_sideways_speed: float = 5.0
## The amount of grip applied to angular velocity.
## [br][br]
## The actual angular grip may change at higher speeds due to the difference
## between the wheel positions and the center of mass. Adjust accordingly.
@export var angular_grip: float = 10000.0
## The force applied when you hit brakes.
@export var brake_force: float = 4000.0

#== NODES ==#
var wheels: Array[CarWheel]

#== INPUT ==#
var input_forward: float = 0.0
var input_backward: float = 0.0
var input_steer: float = 0.0
var input_handbrake: bool = false

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
var smooth_steer_tug_reverse_coefficient: SmoothedFloat = SmoothedFloat.new()
var smooth_steer: SmoothedFloat = SmoothedFloat.new()


func _ready():
	for wheel in get_children():
		if wheel is CarWheel:
			wheels.append(wheel)


func is_reversing() -> bool:
	if local_linear_velocity.z >= 0.1:
		return true
	elif local_linear_velocity.z <= -0.1:
		return false
	else:
		return input_backward > 0.0 and input_forward == 0.0


func calculate_acceleration_multiplier() -> float:
	# TODO: make it actually account the gear?
	var relative_speed: float = (
		abs(local_linear_velocity.z) / (top_speed_reverse if is_reversing() else top_speed_forward)
	)

	return clamp(ease(1.0 - relative_speed, acceleration_curve), 0.0, 1.0)


func get_side_grip_force(delta: float) -> float:
	return -local_linear_velocity.x * mass / delta


func get_engine_force() -> float:
	return (
		(-input_backward if is_reversing() else input_forward)
		* max_acceleration
		* calculate_acceleration_multiplier()
	)


func get_brake_force() -> float:
	return (
		clamp(local_linear_velocity.z * 10.0, -1.0, 1.0)
		* (1.0 if input_handbrake else (input_forward if is_reversing() else input_backward))
		* brake_force
	)


func get_slowdown_force() -> float:
	var is_beyond_limit: bool = (
		-local_linear_velocity.z >= top_speed_forward
		or -local_linear_velocity.z <= -top_speed_reverse
	)
	var input_accel_adapted: float = (
		0.0 if is_beyond_limit else (input_backward if is_reversing() else input_forward)
	)

	return clamp(local_linear_velocity.z * 10, -1, 1) * (1 - input_accel_adapted) * slowdown_force


func convert_linear_force(input: Vector3, delta: float) -> Vector3:
	var converted_force: Vector3 = input
	var side_grip: float = lerp(
		1.0,
		min_side_grip,
		clamp(sqrt(abs(local_linear_velocity.x) / min_side_grip_sideways_speed), 0.0, 1.0)
	)
	
	converted_force.x = clamp(converted_force.x, -linear_grip * side_grip, linear_grip * side_grip)
	converted_force = converted_force.limit_length(linear_grip)

	converted_force = global_transform.basis * converted_force
	converted_force = Plane(average_wheel_collision_normal).project(converted_force)
	converted_force *= delta

	return converted_force


func calculate_steer_coefficient() -> float:
	var steer_sign_coefficient: float = sign(local_linear_velocity.z)
	return abs(local_linear_velocity.z) / distance_between_wheels * steer_sign_coefficient


func get_steer_tug_offset() -> float:
	return clamp(
		local_linear_velocity.x
		/ steer_tug_slide
		* smooth_steer_tug_reverse_coefficient.get_current_value(),
		-max_steer_tug,
		max_steer_tug
	)


func get_steer_force(delta: float) -> float:
	var steer_amount = (
		(smooth_steer.get_current_value() * calculate_steer_coefficient() * get_input_steer_multiplier()) + get_steer_tug_offset()
	)
	
	var steer_velocity: float = clamp(steer_amount * base_steer_degrees, -max_steer_velocity, max_steer_velocity)
	var steer_force: float = steer_velocity - local_angular_velocity.y
	return steer_force * mass / delta


func get_input_steer_multiplier() -> float:
	if local_linear_velocity.z > 0: return 1.0
	if input_handbrake: return 1.0
	var velocity_z = abs(local_linear_velocity.z)
	return min(
		distance_between_wheels * (target_steer_velocity / base_steer_degrees) / velocity_z,
		1.0
	)


func _physics_process(delta: float):
	smooth_steer.speed = smooth_steer_speed
	input_forward = Input.get_action_strength("aacc_forward")
	input_backward = Input.get_action_strength("aacc_backward")
	input_steer = Input.get_action_strength("aacc_steer_right") - Input.get_action_strength("aacc_steer_left")
	input_handbrake = Input.is_action_pressed("aacc_handbrake")

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

	smooth_steer.advance_to(input_steer, delta)
	smooth_steer_tug_reverse_coefficient.advance_to(0.0 if is_reversing() else 1.0, delta)

	if ground_coefficient > 0:
		var desired_linear_grip_force: Vector3 = Vector3.RIGHT * get_side_grip_force(delta)
		var desired_engine_force: Vector3 = Vector3.FORWARD * get_engine_force()
		var desired_brake_force: Vector3 = Vector3.FORWARD * get_brake_force()
		var desired_slowdown_force: Vector3 = Vector3.FORWARD * get_slowdown_force()
		var sum_of_linear_forces: Vector3 = convert_linear_force(
			(
				desired_linear_grip_force
				+ desired_engine_force
				+ desired_brake_force
				+ desired_slowdown_force
			), delta
		)
		apply_impulse(
			sum_of_linear_forces * ground_coefficient,
			average_wheel_collision_point - to_global(Vector3.ZERO)
		)

		# TODO: rewrite in line with linear force
		var angular_force_to_apply: Vector3 = Vector3.ZERO
		angular_force_to_apply += (
			get_steer_force(delta) * average_wheel_collision_normal * ground_coefficient
		)
		# TODO: mid-air control?

		var final_angular_force: Vector3 = angular_force_to_apply
		final_angular_force = global_transform.basis * final_angular_force
		final_angular_force = final_angular_force.limit_length(angular_grip)
		final_angular_force *= delta
		apply_torque_impulse(final_angular_force)

	old_linear_velocity = linear_velocity
	old_angular_velocity = angular_velocity
