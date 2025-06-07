class_name CarInputHandbrake extends ScenePluginBase

@export_group("Input Map")
@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action_handbrake: StringName = &"aacc_handbrake"

var car: Car

func _physics_process(delta: float) -> void:
	car = AACCGlobal.car
	if not car: return

	car.set_meta(&"input_handbrake", Input.is_action_pressed(action_handbrake))
