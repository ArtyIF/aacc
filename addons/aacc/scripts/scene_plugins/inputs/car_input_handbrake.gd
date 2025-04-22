class_name CarInputHandbrake extends ScenePluginBase

@export_group("Input Map")
@export var action_handbrake: StringName = &"aacc_handbrake"

func _physics_process(delta: float) -> void:
	update_car()
	if not car: return

	car.set_meta(&"input_handbrake", Input.is_action_pressed(action_handbrake))
