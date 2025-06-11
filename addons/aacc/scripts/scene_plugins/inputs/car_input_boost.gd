class_name CarInputBoost extends ScenePluginBase

@export_group("Input Map")
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_boost: StringName = &"aacc_boost"

var plugin_wp: CarWheelsProcessor

func _on_car_changed(new_car: Car):
	super(new_car)
	if is_instance_valid(car):
		plugin_wp = car.get_plugin(&"WheelsProcessor")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(car): return

	var input_boost: bool = false
	if car.linear_velocity.length() >= 0.25 or is_zero_approx(plugin_wp.ground_coefficient):
		input_boost = Input.is_action_pressed(action_boost)
	car.set_meta(&"input_boost", input_boost)
