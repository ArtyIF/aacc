extends MeshInstance3D
var material: ShaderMaterial

func _ready() -> void:
	material = mesh.surface_get_material(0).duplicate()
	set_surface_override_material(0, material)

func _process(delta: float) -> void:
	if AACCGlobal:
		material.set_shader_parameter("shadow_intensity", AACCGlobal.current_shadow_intensity)
