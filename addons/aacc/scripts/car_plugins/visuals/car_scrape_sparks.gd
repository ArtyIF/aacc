class_name CarScrapeSparks extends CarPluginBase
@export var scrape_sparks_scene: PackedScene
@export var use_light: bool = true

var sparks: Array[GPUParticles3D] = []

func _ready() -> void:
	for i in range(car.max_contacts_reported):
		sparks.append(scrape_sparks_scene.instantiate())
		add_child(sparks[i])

func process_plugin(delta: float) -> void:
	var contact_count: int = car.get_meta(&"contact_count", 0)
	var contact_positions: PackedVector3Array = car.get_meta(&"contact_positions", [])
	var contact_normals: PackedVector3Array = car.get_meta(&"contact_normals", [])
	var contact_scrapes: PackedFloat32Array = car.get_meta(&"contact_scrapes", [])

	for i in range(len(sparks)):
		if i < contact_count:
			sparks[i].global_position = contact_positions[i]
			if not Vector3.UP.cross(contact_normals[i]).is_zero_approx():
				sparks[i].global_basis = Basis.looking_at(contact_normals[i], Vector3.UP.rotated(contact_normals[i], randf_range(0.0, TAU)))
			else:
				sparks[i].global_basis = Basis.from_euler(Vector3(0.0, randf_range(0.0, TAU), 0.0))
			sparks[i].amount_ratio = clamp(contact_scrapes[i], 0.0, 1.0)
		else:
			sparks[i].amount_ratio = 0.0

		sparks[i].emitting = sparks[i].amount_ratio > 0.0
		if use_light:
			sparks[i].get_node("Light").light_energy = 1.0 * sparks[i].amount_ratio # TODO: configurable
		sparks[i].get_node("Light").visible = use_light and not is_zero_approx(sparks[i].amount_ratio)
