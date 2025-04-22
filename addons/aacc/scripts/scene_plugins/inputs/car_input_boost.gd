class_name CarInputBoost extends ScenePluginBase

@export_group("Input Map")
@export var action_boost: StringName = &"aacc_boost"

func _physics_process(delta: float) -> void:
	update_car()
	if not car: return

	var input_boost: bool = false
	if car.linear_velocity.length() >= 0.25:
		input_boost = Input.is_action_pressed(action_boost)
	car.set_meta(&"input_boost", input_boost)
