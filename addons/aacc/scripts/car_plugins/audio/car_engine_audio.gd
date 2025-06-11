class_name CarEngineAudio extends CarPluginBase
@export_range(0.0, 1.0) var min_volume: float = 0.2
@export_range(0.0, 1.0) var min_volume_limit: float = 0.5
@export_range(0.0, 4.0) var max_volume: float = 1.0
@export_range(0.0, 4.0) var max_volume_limit: float = 2.0
@export_range(0.01, 4.0) var max_pitch: float = 1.0
@export var engine_audio_scene: PackedScene

var player: AudioStreamPlayer3D
var engine_volume: SmoothedFloat = SmoothedFloat.new(0.0, 10.0)

@onready var plugin_engine: CarEngine = car.get_plugin(&"Engine")

func _ready() -> void:
	player = engine_audio_scene.instantiate()
	add_child(player)

	player.volume_db = linear_to_db(min_volume)
	player.max_db = linear_to_db(min_volume_limit)
	player.pitch_scale = max_pitch

func process_plugin(delta: float) -> void:
	var rpm_ratio: float = plugin_engine.rpm_ratio.get_value()
	var gear_switching: bool = plugin_engine.gear_switching
	var rpm_limiter: bool = plugin_engine.rpm_limiter
	var input_accelerate: float = car.get_meta(&"input_accelerate")

	engine_volume.advance_to(0.0 if (gear_switching or rpm_limiter) else lerp(0.0, 1.0, input_accelerate), delta)
	player.volume_db = linear_to_db(lerp(min_volume, max_volume, engine_volume.get_value()))
	player.max_db = linear_to_db(lerp(min_volume_limit, max_volume_limit, engine_volume.get_value()))
	if rpm_ratio > 0.0:
		player.pitch_scale = rpm_ratio * max_pitch

	if car.freeze and player.playing:
		player.stop()
	elif not car.freeze and not player.playing:
		player.play()
