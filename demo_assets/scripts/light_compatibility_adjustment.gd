@tool
extends DirectionalLight3D

@export var do_not_adapt: bool = false
@export var actual_energy: float = 1.0

func _process(_delta: float) -> void:
	if ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method") == "gl_compatibility" and not do_not_adapt and shadow_enabled:
			light_energy = actual_energy / 2.5 # gives good enough results
	else:
		light_energy = actual_energy
	if not Engine.is_editor_hint():
		light_angular_distance = 0.0
