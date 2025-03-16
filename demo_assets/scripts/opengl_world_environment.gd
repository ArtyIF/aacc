extends WorldEnvironment

@export var opengl_environment: Environment

func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		environment = opengl_environment
