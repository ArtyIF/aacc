class_name CarContactProcessor extends CarPluginBase

func process_plugin(delta: float) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car.get_rid())

	var contact_positions: PackedVector3Array = []
	var contact_normals: PackedVector3Array = []
	var contact_speeds: PackedFloat32Array = []
	var contact_scrapes: PackedFloat32Array = []

	# TODO: maybe some scene-level management for contacts? merge close contacts into one?
	for i in range(state.get_contact_count()):
		var contact_position: Vector3 = state.get_contact_collider_position(i)
		var contact_normal: Vector3 = state.get_contact_local_normal(i)
		contact_positions.append(contact_position)
		contact_normals.append(contact_normal)

		var local_velocity: Vector3 = state.get_contact_local_velocity_at_position(i)
		var collider_velocity: Vector3 = state.get_contact_collider_velocity_at_position(i)
		var contact_speed: float = (local_velocity - collider_velocity).length()
		contact_speeds.append(contact_speed)

		var scrape_amount: float = (contact_speed - 0.1) / 20.0 # TODO: configurable
		contact_scrapes.append(scrape_amount)

	car.set_meta(&"contact_count", state.get_contact_count())
	car.set_meta(&"contact_positions", contact_positions)
	car.set_meta(&"contact_normals", contact_normals)
	car.set_meta(&"contact_speeds", contact_speeds)
	car.set_meta(&"contact_scrapes", contact_scrapes)
