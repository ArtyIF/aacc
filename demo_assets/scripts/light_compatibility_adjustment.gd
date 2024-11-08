@tool
extends DirectionalLight3D

@export var disable: bool = false
@export var actual_energy: float = 1.0

func _process(_delta: float) -> void:
	if disable: return
	if ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method") == "gl_compatibility":
		if shadow_enabled:
			light_energy = actual_energy / 2.5 # gives good enough results
		else:
			light_energy = actual_energy
