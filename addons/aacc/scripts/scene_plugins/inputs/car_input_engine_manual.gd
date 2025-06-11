class_name CarInputEngineManual extends ScenePluginBase

@export_group("Input Map")
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_forward: StringName = &"aacc_forward"
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_backward: StringName = &"aacc_backward"
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_gear_up: StringName = &"aacc_gear_up"
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_gear_down: StringName = &"aacc_gear_down"

@export_group("Gearbox")
@export var auto_downshift: bool = true

var gear_target: int = 0

var plugin_lvp: CarLocalVelocityProcessor
var plugin_engine: CarEngine

func _on_car_changed(new_car: Car) -> void:
	super(new_car)
	if is_instance_valid(car):
		plugin_lvp = car.get_plugin(&"LocalVelocityProcessor")
		plugin_engine = car.get_plugin(&"Engine")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(car): return

	var input_forward: float = clamp(Input.get_action_strength(action_forward), 0.0, 1.0)
	var input_backward: float = clamp(Input.get_action_strength(action_backward), 0.0, 1.0)

	var local_velocity_z_sign: float = plugin_lvp.local_velocity_z_sign
	if is_zero_approx(local_velocity_z_sign):
		if input_forward > 0.0 and is_zero_approx(input_backward):
			local_velocity_z_sign = -1.0
		elif input_backward > 0.0 and is_zero_approx(input_forward):
			local_velocity_z_sign = 1.0

	if Input.is_action_just_pressed(action_gear_up):
		gear_target += 1
	if Input.is_action_just_pressed(action_gear_down):
		gear_target -= 1

	if auto_downshift and (input_backward > 0.0 or is_zero_approx(input_forward)):
		var gear_perfect_shift_down: float = AACCCurveTools.get_gear_perfect_shift_down(plugin_engine)
		if car.get_meta(&"rpm_ratio", 0.0) < gear_perfect_shift_down and gear_target > 0:
			gear_target = car.get_meta(&"gear_current", 1) - 1

	gear_target = clampi(gear_target, -1, car.get_meta(&"gearbox_gear_count", 0))
	car.set_meta(&"input_gear_target", gear_target)

	car.set_meta(&"input_accelerate", input_forward)
	car.set_meta(&"input_brake", input_backward)
