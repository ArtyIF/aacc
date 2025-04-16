extends DirectionalLight3D

func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		light_energy /= 3.0
