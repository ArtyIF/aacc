class_name CarBrakeSquealAudio extends CarPluginBase
@export var brake_audio_scene: PackedScene

var player: AudioStreamPlayer3D
var brake_volume: SmoothedFloat = SmoothedFloat.new(0.0, 10.0)

@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")
@onready var plugin_brake: CarBrake = car.get_plugin(&"Brake")
@onready var plugin_engine: CarEngine = car.get_plugin(&"Engine")

func _ready() -> void:
	player = brake_audio_scene.instantiate()
	add_child(player)

func process_plugin(delta: float) -> void:
	var target_value: float = 0.0
	if plugin_engine.gear_current != 0 and not car.get_meta(&"input_handbrake"):
		target_value = car.get_meta(&"input_brake") * abs(plugin_brake.brake_speed) * plugin_wp.ground_coefficient
	brake_volume.advance_to(clamp(target_value, 0.0, 1.0), delta)
	player.volume_linear = brake_volume.get_value()

	if car.freeze:
		player.volume_linear = 0.0
	if player.volume_db >= -60.0 and not player.playing:
		player.play(randf_range(0.0, player.stream.get_length()))
	elif player.volume_db < -60.0 and player.playing:
		player.stop()
