class_name CarTireRollAudio extends CarPluginBase
@export var tire_roll_scene: PackedScene

var player: AudioStreamPlayer3D

func _ready() -> void:
	player = tire_roll_scene.instantiate()
	add_child(player)

func process_plugin(delta: float) -> void:
	var volume: float = abs(car.get_meta(&"local_linear_velocity", Vector3.ZERO).z * car.get_meta(&"ground_coefficient", 0.0) / 5.0) # TODO: configurable
	player.volume_linear = volume

	if car.freeze:
		player.volume_linear = 0.0
	if player.volume_db >= -60.0:
		player.global_position = car.get_meta(&"ground_average_point")
		if not player.playing:
			player.play(randf_range(0.0, player.stream.get_length()))
	elif player.volume_db < -60.0 and player.playing:
		player.stop()
