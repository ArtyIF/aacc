class_name CarContactProcessor extends CarPluginBase

@export var ignore_shapes: Array[CollisionShape3D]

var max_contacts: int = 0
var process_hits: bool = false

var contact_count: int = 0
var contact_positions: PackedVector3Array = []
var contact_normals: PackedVector3Array = []
var contact_velocities: PackedVector3Array = []
var contact_hits: PackedFloat32Array = []
var contact_scrapes: PackedFloat32Array = []

func _ready() -> void:
	car.body_entered.connect(enable_process_hits)

	debuggable_parameters = [
		&"max_contacts",
		&"process_hits",
		&"contact_count",
		&"contact_positions",
		&"contact_normals",
		&"contact_velocities",
		&"contact_hits",
		&"contact_scrapes",
	]

func enable_process_hits(_body: Node) -> void:
	process_hits = true

func process_plugin(delta: float) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car.get_rid())

	contact_count = 0
	if car.max_contacts_reported != max_contacts:
		max_contacts = car.max_contacts_reported
		contact_positions.resize(max_contacts)
		contact_normals.resize(max_contacts)
		contact_velocities.resize(max_contacts)
		contact_hits.resize(max_contacts)
		contact_scrapes.resize(max_contacts)

	# TODO: maybe some scene-level management for contacts? merge close contacts into one?
	var valid_contact_i: int = -1
	for i in range(state.get_contact_count()):
		var shape_owner: CollisionShape3D = car.shape_owner_get_owner(car.shape_find_owner(state.get_contact_local_shape(i)))
		if shape_owner in ignore_shapes:
			continue

		valid_contact_i += 1
		contact_count += 1

		var contact_position: Vector3 = state.get_contact_collider_position(valid_contact_i)
		var contact_normal: Vector3 = state.get_contact_local_normal(valid_contact_i)

		var local_velocity: Vector3 = state.get_contact_local_velocity_at_position(valid_contact_i)
		var collider_velocity: Vector3 = state.get_contact_collider_velocity_at_position(valid_contact_i)
		var contact_velocity: Vector3 = local_velocity - collider_velocity

		var contact_hit: float = 0.0
		if process_hits:
			var projected_velocity: Vector3 = contact_velocity.project(contact_normal)
			if projected_velocity.length() > 0.1:
				contact_hit = max((projected_velocity.length() - 0.1) / 10.0, 0.0) # TODO: configurable

		var scrape_speed: float = contact_velocity.cross(contact_normal).length()
		var contact_scrape: float = max((scrape_speed - 0.1) / 20.0, 0.0) # TODO: configurable

		contact_positions[valid_contact_i] = contact_position
		contact_normals[valid_contact_i] = contact_normal
		contact_velocities[valid_contact_i] = contact_velocity
		contact_hits[valid_contact_i] = contact_hit
		contact_scrapes[valid_contact_i] = contact_scrape

	process_hits = false
