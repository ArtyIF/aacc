class_name CarInputSteer extends ScenePluginBase

@export_group("Input Map")
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_forward: StringName = &"aacc_forward"
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_backward: StringName = &"aacc_backward"
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_steer_left: StringName = &"aacc_steer_left"
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_steer_right: StringName = &"aacc_steer_right"
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_handbrake: StringName = &"aacc_handbrake"

@export_group("Steering")
@export var always_full_steer: bool = false
@export var full_steer_on_reverse: bool = true
@export var full_steer_on_handbrake: bool = true
@export var desired_smooth_steer_speed: float = 10.0

var smooth_steer: SmoothedFloat = SmoothedFloat.new()

var plugin_lvp: CarLocalVelocityProcessor
var plugin_wp: CarWheelsProcessor

func _on_car_changed(new_car: Car) -> void:
	super(new_car)
	if is_instance_valid(car):
		plugin_lvp = car.get_plugin(&"LocalVelocityProcessor")
		plugin_wp = car.get_plugin(&"WheelsProcessor")

func calculate_steer(input_steer: float, input_handbrake: bool, local_velocity_z_sign: float, delta: float) -> float:
	var input_full_steer: float = (1.0 if input_handbrake else 0.0) if full_steer_on_handbrake else 0.0
	if is_zero_approx(plugin_wp.ground_coefficient):
		input_full_steer = 1.0
	if full_steer_on_reverse and local_velocity_z_sign > 0:
		input_full_steer = 1.0

	# TODO: add an ability to have the car send the info somehow, otherwise this is delayed by a frame
	var distance_between_wheels: float = car.get_meta(&"distance_between_wheels", 1.0)
	var steer_velocity_base: float = car.get_meta(&"steer_velocity_base", 1.0)
	var steer_velocity_target: float = car.get_meta(&"steer_velocity_target", 1.0)
	var velocity_z: float = abs(plugin_lvp.local_velocity_linear.z)

	var input_steer_multiplier: float = 1.0
	if not always_full_steer:
		input_steer_multiplier = min(distance_between_wheels * (steer_velocity_target / steer_velocity_base) / velocity_z, 1.0)
		input_steer_multiplier = lerp(input_steer_multiplier, 1.0, input_full_steer)
	var input_steer_converted: float = input_steer * input_steer_multiplier

	smooth_steer.speed_up = desired_smooth_steer_speed
	smooth_steer.speed_down = desired_smooth_steer_speed
	smooth_steer.advance_to(input_steer_converted, delta)

	return smooth_steer.get_value()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(car): return

	var input_forward: float = clamp(Input.get_action_strength(action_forward), 0.0, 1.0)
	var input_backward: float = clamp(Input.get_action_strength(action_backward), 0.0, 1.0)
	var input_steer: float = clamp(Input.get_action_strength(action_steer_right) - Input.get_action_strength(action_steer_left), -1.0, 1.0)
	var input_handbrake: bool = Input.is_action_pressed(action_handbrake)

	var local_velocity_z_sign: float = plugin_lvp.local_velocity_z_sign
	if is_zero_approx(local_velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			local_velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			local_velocity_z_sign = 1.0

	car.set_meta(&"input_steer", calculate_steer(input_steer, input_handbrake, local_velocity_z_sign, delta))
