extends GPUParticles3D

@export var very_low_quality: BaseMaterial3D
@export var low_quality: BaseMaterial3D
@export var medium_quality: BaseMaterial3D
@export var high_quality: BaseMaterial3D
@export var ultra_quality: BaseMaterial3D

var _last_quality: AACCGlobal.BurnoutParticlesQuality = AACCGlobal.BurnoutParticlesQuality.LOW

func _process(delta: float) -> void:
	if AACCGlobal.current_burnout_particles_quality != _last_quality:
		match AACCGlobal.current_burnout_particles_quality:
			AACCGlobal.BurnoutParticlesQuality.OFF:
				visible = false
			AACCGlobal.BurnoutParticlesQuality.VERY_LOW:
				visible = true
				material_override = very_low_quality
			AACCGlobal.BurnoutParticlesQuality.LOW:
				visible = true
				material_override = low_quality
			AACCGlobal.BurnoutParticlesQuality.MEDIUM:
				visible = true
				material_override = medium_quality
			AACCGlobal.BurnoutParticlesQuality.HIGH:
				visible = true
				material_override = high_quality
			AACCGlobal.BurnoutParticlesQuality.ULTRA:
				visible = true
				material_override = ultra_quality
		_last_quality = AACCGlobal.current_burnout_particles_quality
