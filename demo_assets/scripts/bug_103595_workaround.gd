extends DirectionalLight3D
# this works around https://github.com/godotengine/godot/issues/103595

func _ready() -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		visible = false
		# add bias to static sunlight
		$"..".shadow_bias = 0.1
		$"..".shadow_normal_bias = 2.0
		# make the shadows work everywhere
		$"..".shadow_caster_mask = shadow_caster_mask
