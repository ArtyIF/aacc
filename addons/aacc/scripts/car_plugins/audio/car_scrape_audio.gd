class_name CarScrapeAudio extends CarPluginBase
@export var scrape_audio_scene: PackedScene

var players: Array[AudioStreamPlayer3D] = []
var smooth_scrape_volumes: Array[SmoothedFloat] = []

func _ready() -> void:
	for i in range(car.max_contacts_reported):
		players.append(scrape_audio_scene.instantiate())
		add_child(players[i])

		smooth_scrape_volumes.append(SmoothedFloat.new(0.0, 10.0, 10.0))

func process_plugin(delta: float) -> void:
	var contact_count: int = car.get_meta(&"contact_count")
	var contact_positions: PackedVector3Array = car.get_meta(&"contact_positions")
	var contact_normals: PackedVector3Array = car.get_meta(&"contact_normals")
	var contact_scrapes: PackedFloat32Array = car.get_meta(&"contact_scrapes")

	# BUG: contacts' sorting isn't stable, which breaks doppler
	for i in range(len(players)):
		if i < contact_count:
			players[i].global_position = contact_positions[i]
			smooth_scrape_volumes[i].advance_to(clamp(contact_scrapes[i], 0.0, 1.0), delta)
		else:
			smooth_scrape_volumes[i].advance_to(0.0, delta)

		players[i].volume_linear = smooth_scrape_volumes[i].get_value()

		if car.freeze:
			players[i].volume_linear = 0.0
		if players[i].volume_db >= -60.0 and not players[i].playing:
			players[i].play(randf_range(0.0, players[i].stream.get_length()))
		elif players[i].volume_db < -60.0 and players[i].playing:
			players[i].stop()
