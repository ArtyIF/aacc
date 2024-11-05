@icon("res://addons/aacc/icons/car.svg")
## Arty's Arcadey Car Controller's main class.
##
## This is the class that stores parameters for the car and calculates
## engine and steering for it.
class_name Car extends RigidBody3D

@export_group("Acceleration")
## The top speed in meters per second when going forward.
@export var top_speed_forward: float = 50.0
## The top speed in meters per second when going in reverse.
@export var top_speed_reverse: float = 10.0
## The maximum acceleration, applied at 0 velocity.
@export var max_acceleration: float = 2000.0
## The curve applied to acceleration.
@export_exp_easing("attenuation") var acceleration_curve: float = 1.0
## The force that simulates resistance. Makes the car slow down when no
## acceleration is applied.
@export var slowdown_force: float = 200.0

@export_group("Gearbox")
## The amount of gears, not counting neutral and reverse.
## [br][br]
## NOTE: gears themselves don't affect the acceleration currently, they're only
## for visual purposes. Only the gear switching does. Later, there'll be an
## option for gears to actually affect the acceleration and top speed, as well
## as a manual gearbox option.
## TODO: aforementioned
@export var gears_amount: int = 6
## The time it takes to switch a gear. During a gear switch, acceleration forces
## are not applied.
## [br][br]
## Some caveats:[br]
## - Switching the gear from neutral happens instantly.[br]
## - If another gear switch is requested during the gear switch, the timer
##   resets.[br]
## - If the requested gear changes to the one the switch is happening from, the
##   switch gets cancelled.
@export var gear_switch_time: float = 0.1

@export_group("Steering")
## The base steer velocity per second that the car turns at when a speed of
## [member distance_between_wheels] m/s is reached.
## [br][br]
## Before reaching [member distance_between_wheels] m/s, the car steers slower,
## and after it steers faster. See also [member target_steer_velocity] and
## [member max_steer_velocity].
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var base_steer_velocity: float = deg_to_rad(30.0)
## The steer velocity per second that the car targets.
## [br][br]
## This is done by reducing the final steer input accordingly when the speed is
## high enough. See also [member base_steer_velocity] and
## [member max_steer_velocity].
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var target_steer_velocity: float = deg_to_rad(60.0)
## The maximum steer velocity per second. Used to limit handbrake turns.
## [br][br]
## For relevant steering properties, see [member base_steer_velocity] and
## [member target_steer_velocity].
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var max_steer_velocity: float = deg_to_rad(180.0)
## The distance between front and rear wheels. Used to calculate the appropriate
## steer velocity.
@export var distance_between_wheels: float = 1.5
## The speed per second at which the final steer value moves at.
@export var smooth_steer_speed: float = 10.0
## The steer tug offsets the final steer value to simulate the difficulty of
## straightening the car during a drift.
## [br][br]
## Value is the steer tug amount, input is the sideways velocity.
## [br][br]
## Default values are (TODO remove):[br]
## Left Value: 0[br]
## Right Value: 2[br]
## Max Input: 10[br]
## Input Curve: 1.00
@export var steer_tug_curve: ProceduralCurve

@export_group("Traction")
## The amount of grip applied to the side velocity (X axis) and the velocity
## length.
@export var linear_grip: float = 20000.0
## The multiple of [member linear_grip] that's applied depending on the sideways
## velocity. Currently only applied to the sideways grip.
## [br][br]
## Left value is the starting value and is usually 1. Right value is the
## reduced grip amount. Input is the sideways velocity.
## [br][br]
## Default values are (TODO remove):[br]
## Left Value: 1[br]
## Right Value: 0.5[br]
## Max Input: 5[br]
## Input Curve: 0.500
@export var reduced_grip_curve: ProceduralCurve
## The amount of grip applied to angular velocity.
## [br][br]
## The actual angular grip may change at higher speeds due to the difference
## between the wheel positions and the center of mass. Adjust accordingly.
@export var angular_grip: float = 10000.0
## The force applied when you hit brakes.
@export var brake_force: float = 4000.0

@export_group("Air Forces")
## The force applied to the car when it's mid-air to stabilize it.
@export var air_stabilization_force: float = 200.0

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
var smooth_steer: SmoothedFloat = SmoothedFloat.new()
var smooth_steer_sign: SmoothedFloat = SmoothedFloat.new()
var use_smooth_steer_sign_value: bool = false

#== GEARS ==#
var current_gear: int = 0
var target_gear: int = 0
var switching_gears: bool = false
var gear_switch_timer: float = 0.0
var revs: SmoothedFloat = SmoothedFloat.new()
var accel_amount: SmoothedFloat = SmoothedFloat.new(0.0, 2.0)

#== BURNOUT AMOUNT ==#
var burnout_amount: float = 0.0

func _ready():
	for wheel in get_children():
		if wheel is CarWheel:
			wheels.append(wheel)

#region Processing
func get_input_steer_multiplier() -> float:
	if local_linear_velocity.z > 0.0: return 1.0
	if input_handbrake: return 1.0

	var velocity_z = abs(local_linear_velocity.z)
	return min(distance_between_wheels * (target_steer_velocity / base_steer_velocity) / velocity_z, 1.0)

func process_smooth_values(delta: float):
	# TODO: slow down when handbrake is on
	smooth_steer.advance_to(input_steer * get_input_steer_multiplier(), delta)

	var target_steer_sign = sign(local_linear_velocity.z)

	if use_smooth_steer_sign_value and smooth_steer_sign.get_current_value() == target_steer_sign:
		use_smooth_steer_sign_value = false
	if input_handbrake:
		use_smooth_steer_sign_value = true
	if local_linear_velocity.length() <= 1.0:
		use_smooth_steer_sign_value = false

	# TODO: option for smooth steer sign, may be unnecessary for some cars
	if use_smooth_steer_sign_value:
		smooth_steer_sign.advance_to(target_steer_sign, delta) # TODO: configurable speed
	else:
		smooth_steer_sign.force_current_value(target_steer_sign)
#endregion

#region Acceleration
func is_reversing() -> bool:
	if local_linear_velocity.z >= 0.1:
		return true
	elif local_linear_velocity.z <= -0.1:
		return false
	else:
		return input_backward > 0.0 and input_forward == 0.0

func calculate_acceleration_multiplier() -> float:
	var relative_speed: float = abs(local_linear_velocity.z) / (top_speed_reverse if is_reversing() else top_speed_forward)
	return clamp(ease(1.0 - relative_speed, acceleration_curve), 0.0, 1.0)

func get_engine_force() -> float:
	if switching_gears: return 0.0
	if input_handbrake: return 0.0
	return (-input_backward if is_reversing() else input_forward) * max_acceleration * calculate_acceleration_multiplier()

func get_slowdown_force() -> float:
	var is_beyond_limit: bool = -local_linear_velocity.z >= top_speed_forward or -local_linear_velocity.z <= -top_speed_reverse
	var input_accel_adapted: float = 0.0 if is_beyond_limit else (input_backward if is_reversing() else input_forward)
	return clamp(local_linear_velocity.z * 10.0, -1.0, 1.0) * (1.0 - input_accel_adapted) * slowdown_force
#endregion

#region Gearbox
func update_gear(delta: float):
	if target_gear != current_gear and not switching_gears and sign(current_gear) == sign(target_gear):
		gear_switch_timer = gear_switch_time
		switching_gears = true

	if gear_switch_timer <= 0 or target_gear == current_gear:
		current_gear = target_gear
		switching_gears = false

	gear_switch_timer -= delta

func get_gear_limit(gear: int) -> float:
	return (1.0 / gears_amount) * gear

func set_current_gear():
	if input_handbrake and local_linear_velocity.length() >= 0.1:
		return
	
	if is_reversing():
		target_gear = -1
		return

	if abs(local_linear_velocity.z) < 0.1:
		if input_forward == 0 and input_backward == 0:
			target_gear = 0
		elif input_forward > 0:
			target_gear = 1
		elif input_backward > 0:
			target_gear = -1
		return

	var forward_speed_ratio: float = abs(local_linear_velocity.z / top_speed_forward)
	var lower_gear_limit_offset: float = (5.0 / 3.6) / top_speed_forward

	if target_gear > 0 and forward_speed_ratio < get_gear_limit(target_gear - 1) - lower_gear_limit_offset:
		target_gear -= 1
	if forward_speed_ratio > get_gear_limit(target_gear) and target_gear < gears_amount:
		target_gear += 1

func update_accel_amount(delta: float) -> void:
	if switching_gears:
		accel_amount.advance_to(0.0, delta)
	else:
		accel_amount.advance_to(input_backward if is_reversing() else input_forward, delta)

func update_revs(delta: float) -> void:
	var target_revs: float = 0.0
	if abs(local_linear_velocity.z) < 0.1 or ground_coefficient == 0.0:
		target_revs = accel_amount.get_current_value()
	elif not switching_gears:
		if current_gear > 0:
			target_revs = clamp(inverse_lerp(0.0, top_speed_forward * get_gear_limit(current_gear), abs(local_linear_velocity.z)), 0.0, 1.0)
		elif current_gear < 0:
			target_revs = clamp(inverse_lerp(0.0, top_speed_reverse, abs(local_linear_velocity.z)), 0.0, 1.0)

	revs.advance_to(target_revs, delta)
#endregion

#region Traction
func get_brake_force() -> float:
	var brake_speed = clamp(local_linear_velocity.z * 10.0, -1.0, 1.0)
	return brake_speed * brake_force * (1.0 if input_handbrake else (input_forward if is_reversing() else input_backward))

func get_side_grip_force() -> float:
	return -local_linear_velocity.x * mass

func update_burnout_amount():
	var burnout_colliding: float = 1.0 if ground_coefficient > 0.0 else 0.0
	var burnout_velocity: float = (abs(local_linear_velocity.x) - 0.5) / 10.0
	var burnout_handbrake: float = 0.0
	if input_handbrake:
		if linear_velocity.length() >= 0.1:
			burnout_handbrake = linear_velocity.length() / 10.0
		else:
			burnout_handbrake = revs.get_current_value()
	
	burnout_amount = clamp(burnout_colliding * (burnout_velocity + burnout_handbrake), 0.0, 1.0)
#endregion

#region Steering
func calculate_steer_coefficient() -> float:
	var velocity_multiplier: float = local_linear_velocity.length() if use_smooth_steer_sign_value else abs(local_linear_velocity.z)
	return smooth_steer_sign.get_current_value() * velocity_multiplier / distance_between_wheels

func get_steer_tug_offset() -> float:
	if not steer_tug_curve: return 0.0
	return steer_tug_curve.sample(abs(local_linear_velocity.x)) * sign(local_linear_velocity.x)

func get_steer_force() -> float:
	var steer_amount = (smooth_steer.get_current_value() * calculate_steer_coefficient()) + get_steer_tug_offset()

	var steer_velocity: float = clamp(steer_amount * base_steer_velocity, -max_steer_velocity, max_steer_velocity)
	var steer_force: float = steer_velocity - local_angular_velocity.y
	return steer_force * mass
#endregion

#region Air Stabilization
func get_air_stabilization_force() -> Vector3:
	return -local_angular_velocity * air_stabilization_force
#endregion

#region Force Conversion
func convert_linear_force(input: Vector3, delta: float) -> Vector3:
	var converted_force: Vector3 = input

	var reduced_grip: float = reduced_grip_curve.sample(abs(local_linear_velocity.x))
	# TODO: add option for this clamp
	converted_force.x = clamp(converted_force.x, -linear_grip * reduced_grip * delta, linear_grip * reduced_grip * delta)

	converted_force = global_basis * converted_force
	converted_force = Plane(average_wheel_collision_normal).project(converted_force)
	# TODO: add option for reduced grip to also affect regular grip
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
	smooth_steer.speed = smooth_steer_speed

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
		set_current_gear()
		update_gear(delta)

		var desired_linear_grip_force: Vector3 = Vector3.RIGHT * get_side_grip_force()
		var desired_engine_force: Vector3 = Vector3.FORWARD * get_engine_force() * delta
		var desired_brake_force: Vector3 = Vector3.FORWARD * get_brake_force() * delta
		var desired_slowdown_force: Vector3 = Vector3.FORWARD * get_slowdown_force() * delta

		var sum_of_linear_forces: Vector3 = convert_linear_force(desired_linear_grip_force + desired_engine_force + desired_brake_force + desired_slowdown_force, delta)
		apply_force(sum_of_linear_forces * ground_coefficient / delta, average_wheel_collision_point - global_position)

		var desired_steer_force: Vector3 = Vector3.UP * get_steer_force()

		var sum_of_angular_forces: Vector3 = convert_angular_force(desired_steer_force, delta)
		apply_torque(sum_of_angular_forces * average_wheel_collision_normal * ground_coefficient / delta)
	else:
		var desired_air_stabilization_force: Vector3 = get_air_stabilization_force() * delta

		var sum_of_angular_forces: Vector3 = convert_angular_force(desired_air_stabilization_force, delta, false)
		apply_torque(sum_of_angular_forces / delta)

	update_accel_amount(delta)
	update_revs(delta)
	update_burnout_amount()

	old_linear_velocity = linear_velocity
	old_angular_velocity = angular_velocity

func _on_body_entered(body: Node) -> void:
	pass
