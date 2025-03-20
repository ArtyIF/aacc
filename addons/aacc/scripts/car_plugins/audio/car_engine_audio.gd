class_name CarEngineAudio extends CarPluginBase
@export_range(0.0, 1.0) var min_volume: float = 0.15
@export_range(0.01, 4.0) var max_pitch: float = 1.0
@export var engine_audio_scene: PackedScene

var player: AudioStreamPlayer3D
var engine_volume: SmoothedFloat = SmoothedFloat.new(0.0, 10.0)

func _ready() -> void:
	player = engine_audio_scene.instantiate()
	add_child(player)

	player.volume_linear = min_volume
	player.pitch_scale = max_pitch

func _physics_process(delta: float) -> void:
	var rpm_ratio: float = car.get_meta(&"rpm_ratio", 1.0)
	var gear_switching: bool = car.get_meta(&"gear_switching", false)
	var rpm_limiter: bool = car.get_meta(&"rpm_limiter", false)
	var input_accelerate: float = car.get_meta(&"input_accelerate", 0.0)

	engine_volume.advance_to(min_volume if (gear_switching or rpm_limiter) else lerp(min_volume, 1.0, input_accelerate), delta)
	player.volume_linear = engine_volume.get_value()
	if rpm_ratio > 0.0:
		player.pitch_scale = rpm_ratio * max_pitch

	if car.freeze and player.playing:
		player.stop()
	elif not car.freeze and not player.playing:
		player.play()
