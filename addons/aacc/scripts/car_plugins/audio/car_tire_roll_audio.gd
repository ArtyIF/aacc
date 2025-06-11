class_name CarTireRollAudio extends CarPluginBase
@export var tire_roll_scene: PackedScene

var player: AudioStreamPlayer3D

@onready var plugin_lvp: CarLocalVelocityProcessor = car.get_plugin(&"LocalVelocityProcessor")
@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func _ready() -> void:
	player = tire_roll_scene.instantiate()
	add_child(player)

func process_plugin(delta: float) -> void:
	var volume: float = abs(plugin_lvp.local_velocity_linear.z * plugin_wp.ground_coefficient / 25.0) # TODO: configurable
	player.volume_linear = volume

	if car.freeze:
		player.volume_linear = 0.0
	if player.volume_db >= -60.0:
		player.global_position = plugin_wp.ground_average_point
		if not player.playing:
			player.play(randf_range(0.0, player.stream.get_length()))
	elif player.volume_db < -60.0 and player.playing:
		player.stop()
