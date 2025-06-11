class_name CarCollisionAudio extends CarPluginBase
@export var collision_audio_scene: PackedScene

var collision_players: Array[AudioStreamPlayer3D] = []

func _ready() -> void:
	for i in range(car.max_contacts_reported):
		collision_players.append(collision_audio_scene.instantiate())
		add_child(collision_players[i])

func process_plugin(delta: float) -> void:
	var contact_count: int = car.get_meta(&"contact_count")
	var contact_positions: PackedVector3Array = car.get_meta(&"contact_positions")
	var contact_hits: PackedFloat32Array = car.get_meta(&"contact_hits")

	for i in range(len(collision_players)):
		if i < contact_count and contact_hits[i] > 0.0:
			collision_players[i].global_position = contact_positions[i]
			collision_players[i].volume_linear = clamp(contact_hits[i], 0.0, 1.0)
			collision_players[i].play()
