class_name CarSteer extends CarPluginBase

@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var base_steer_velocity: float = deg_to_rad(30.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var target_steer_velocity: float = deg_to_rad(60.0)
@export_range(0.0, 360.0, 0.1, "or_greater", "radians", "suffix:°/sec") var max_steer_velocity: float = deg_to_rad(180.0)
@export var distance_between_wheels: float = 1.5
@export var full_steer_input: String = "Handbrake"

func _ready() -> void:
	car.add_param("SteerConverted", 0.0)

func process_plugin(delta: float) -> void:
	var velocity_z_abs: float = abs(car.get_param("LocalLinearVelocity").z)
	var velocity_z_sign: float = sign(car.get_param("LocalLinearVelocity").z)

	# TODO: move that section to input
	var input_steer: float = car.get_input("Steer")
	var input_full_steer: float = 1.0 if full_steer_input.is_empty() else car.get_input(full_steer_input)
	var input_steer_multiplier: float = min(distance_between_wheels * (target_steer_velocity / base_steer_velocity) / velocity_z_abs, 1.0)
	input_steer_multiplier = lerp(input_steer_multiplier, 1.0, input_full_steer)
	var input_steer_converted: float = input_steer * input_steer_multiplier
	car.set_param("SteerConverted", input_steer_converted)

	var steer_coefficient: float = velocity_z_sign * velocity_z_abs / distance_between_wheels
	var steer_amount: float = input_steer_converted * steer_coefficient
	
	var steer_velocity: float = clamp(steer_amount * base_steer_velocity, -max_steer_velocity, max_steer_velocity)
	var steer_force: Vector3 = Vector3.UP * steer_velocity
	car.add_torque("Steer", steer_force * car.mass / delta, true)
