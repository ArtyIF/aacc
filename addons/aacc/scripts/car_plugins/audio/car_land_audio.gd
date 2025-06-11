class_name CarLandAudio extends CarPluginBase
@export var land_audio_scene: PackedScene

var land_player: AudioStreamPlayer3D

@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func _ready() -> void:
	land_player = land_audio_scene.instantiate()
	add_child(land_player)

func process_plugin(delta: float) -> void:
	if plugin_wp.ground_coefficient > plugin_wp.ground_coefficient_prev:
		var land_velocity: float = max(-car.linear_velocity.y, 0.0) * (plugin_wp.ground_coefficient - plugin_wp.ground_coefficient_prev) / 5.0 # TODO: configurable
		if land_velocity > 0.1:
			land_player.volume_linear = clamp(land_velocity, 0.0, 1.0)
			land_player.play()
