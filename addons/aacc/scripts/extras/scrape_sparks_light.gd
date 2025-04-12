extends GPUParticles3D

func _process(delta: float) -> void:
	$Light.light_energy = 1.0 * amount_ratio # TODO: configurable
	$Light.visible = not is_zero_approx(amount_ratio)
