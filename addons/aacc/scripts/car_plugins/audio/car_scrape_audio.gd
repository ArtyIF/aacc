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
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car.get_rid())

	# TODO: separate scrape calculation into a separate plugin
	# TODO: maybe some scene-level management for scrapes? merge close contacts into one
	# BUG: contacts' sorting isn't stable, which breaks doppler
	var total_scrape_amount: float = 0.0
	var average_scrape_position: Vector3 = Vector3.ZERO
	for i in range(len(players)):
		if i < state.get_contact_count():
			players[i].global_position = state.get_contact_collider_position(i)
			# TODO: configurable
			var scrape_amount: float = (state.get_contact_local_velocity_at_position(i).length() - 0.1) / 20.0
			smooth_scrape_volumes[i].advance_to(clamp(scrape_amount, 0.0, 1.0), delta)
		else:
			smooth_scrape_volumes[i].advance_to(0.0, delta)

		players[i].volume_linear = smooth_scrape_volumes[i].get_value()

		if car.freeze:
			players[i].volume_linear = 0.0
		if players[i].volume_db >= -60.0 and not players[i].playing:
			players[i].play(randf_range(0.0, players[i].stream.get_length()))
		elif players[i].volume_db < -60.0 and players[i].playing:
			players[i].stop()
