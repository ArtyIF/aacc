class_name CarEngine extends CarPluginBase

@export var top_speed: float = 50.0
@export var max_engine_force: float = 10000.0
@export var gears_count: int = 5
@export var gear_switch_time: float = 0.1

var current_gear: int = 0
var target_gear: int = 0
var switching_gears: bool = false
var gear_switch_timer: float = 0.0
var rpm_ratio: SmoothedFloat = SmoothedFloat.new()

func _ready() -> void:
	car.add_input("Accelerate")
	car.add_input("Reverse")
	car.add_input("Brake")
	car.add_input("Handbrake")

# TODO: rewrite this whole thing
func update_gear(delta: float):
	if target_gear != current_gear and not switching_gears and sign(current_gear) == sign(target_gear):
		gear_switch_timer = gear_switch_time
		switching_gears = true

	if gear_switch_timer <= 0 or target_gear == current_gear:
		current_gear = target_gear
		switching_gears = false
		
	if is_zero_approx(car.get_param("GroundCoefficient")):
		target_gear = current_gear
		switching_gears = false

	gear_switch_timer -= delta

func get_gear_limit(gear: int) -> float:
	return (1.0 / gears_count) * gear

func set_current_gear():
	var local_linear_velocity: Vector3 = car.get_param("LocalLinearVelocity")
	
	if (car.get_input("Handbrake") > 0.0 and local_linear_velocity.length() >= 0.25) or is_zero_approx(car.get_param("GroundCoefficient")):
		return
	
	if car.get_param("VelocityZSign") > 0:
		target_gear = -1
		return

	if abs(local_linear_velocity.z) < 0.25:
		target_gear = -car.get_param("VelocityZSign")
		return

	var forward_speed_ratio: float = abs(local_linear_velocity.z / top_speed)
	var lower_gear_limit_offset: float = (5.0 / 3.6) / top_speed # TODO: configure

	if target_gear > 0 and forward_speed_ratio < get_gear_limit(target_gear - 1) - lower_gear_limit_offset:
		target_gear -= 1
	if forward_speed_ratio > get_gear_limit(target_gear) and target_gear < gears_count:
		target_gear += 1

# TODO: rpm

func calculate_acceleration_multiplier() -> float:
	var relative_speed: float = abs(car.get_param("LocalLinearVelocity").z) / (top_speed)
	return clamp(1.0 - relative_speed, 0.0, 1.0)

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

	set_current_gear()
	update_gear(delta)

	if switching_gears:
		return

	var force: Vector3 = Vector3.ZERO
	if car.get_param("LocalLinearVelocity").z > -top_speed:
		force += Vector3.FORWARD * input_accelerate * max_engine_force * calculate_acceleration_multiplier()
	if car.get_param("LocalLinearVelocity").z < top_speed / gears_count:
		force -= Vector3.FORWARD * input_reverse * max_engine_force * calculate_acceleration_multiplier()
	car.add_force("Engine", force, true)
