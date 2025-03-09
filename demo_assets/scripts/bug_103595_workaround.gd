extends DirectionalLight3D
# this works around https://github.com/godotengine/godot/issues/103595

func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		visible = false
