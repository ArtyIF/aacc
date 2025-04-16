class_name CarContactProcessor extends CarPluginBase

@export var ignore_shapes: Array[CollisionShape3D]

var process_hits: bool = false

func _ready() -> void:
	car.body_entered.connect(enable_process_hits)

func enable_process_hits(_body: Node) -> void:
	process_hits = true

func process_plugin(delta: float) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car.get_rid())

	var contact_positions: PackedVector3Array = []
	var contact_normals: PackedVector3Array = []
	var contact_velocities: PackedVector3Array = []
	var contact_hits: PackedFloat32Array = []
	var contact_scrapes: PackedFloat32Array = []

	# TODO: maybe some scene-level management for contacts? merge close contacts into one?
	for i in range(state.get_contact_count()):
		var contact_position: Vector3 = state.get_contact_collider_position(i)
		var contact_normal: Vector3 = state.get_contact_local_normal(i)
		contact_positions.append(contact_position)
		contact_normals.append(contact_normal)

		var count_contact: bool = true
		var contact_velocity: Vector3 = Vector3.ZERO
		var contact_hit: float = 0.0
		var contact_scrape: float = 0.0

		var shape_owner: CollisionShape3D = car.shape_owner_get_owner(car.shape_find_owner(state.get_contact_local_shape(i)))
		if shape_owner in ignore_shapes:
			count_contact = false

		if count_contact:
			var local_velocity: Vector3 = state.get_contact_local_velocity_at_position(i)
			var collider_velocity: Vector3 = state.get_contact_collider_velocity_at_position(i)
			contact_velocity = local_velocity - collider_velocity

			if process_hits:
				var projected_velocity: Vector3 = contact_velocity.project(contact_normal)
				if projected_velocity.length() > 0.1:
					contact_hit = max((projected_velocity.length() - 0.1) / 10.0, 0.0) # TODO: configurable

			var scrape_speed: float = contact_velocity.cross(contact_normal).length()
			contact_scrape = max((scrape_speed - 0.1) / 20.0, 0.0) # TODO: configurable

		contact_velocities.append(contact_velocity)
		contact_hits.append(contact_hit)
		contact_scrapes.append(contact_scrape)

	car.set_meta(&"contact_count", state.get_contact_count())
	car.set_meta(&"contact_positions", contact_positions)
	car.set_meta(&"contact_normals", contact_normals)
	car.set_meta(&"contact_velocities", contact_velocities)
	car.set_meta(&"contact_hits", contact_hits)
	car.set_meta(&"contact_scrapes", contact_scrapes)

	process_hits = false
