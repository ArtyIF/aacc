extends Node

@export var very_low_quality: BaseMaterial3D
@export var low_quality: BaseMaterial3D
@export var medium_quality: BaseMaterial3D
@export var high_quality: BaseMaterial3D
@export var ultra_quality: BaseMaterial3D

@onready var _particles: GPUParticles3D = get_parent()
var _last_quality: AACCGlobal.BurnoutParticlesQuality = AACCGlobal.BurnoutParticlesQuality.LOW

func _process(delta: float) -> void:
	if AACCGlobal.current_burnout_particles_quality != _last_quality:
		match AACCGlobal.current_burnout_particles_quality:
			AACCGlobal.BurnoutParticlesQuality.OFF:
				_particles.visible = false
			AACCGlobal.BurnoutParticlesQuality.VERY_LOW:
				_particles.visible = true
				_particles.material_override = very_low_quality
			AACCGlobal.BurnoutParticlesQuality.LOW:
				_particles.visible = true
				_particles.material_override = low_quality
			AACCGlobal.BurnoutParticlesQuality.MEDIUM:
				_particles.visible = true
				_particles.material_override = medium_quality
			AACCGlobal.BurnoutParticlesQuality.HIGH:
				_particles.visible = true
				_particles.material_override = high_quality
			AACCGlobal.BurnoutParticlesQuality.ULTRA:
				_particles.visible = true
				_particles.material_override = ultra_quality
		_last_quality = AACCGlobal.current_burnout_particles_quality
