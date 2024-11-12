extends GPUParticles3D

@onready var car: Car = get_node("..")
@onready var car_rid: RID = car.get_rid()
@onready var collision_sound: AudioStreamPlayer3D = get_node_or_null("CollisionSound")

var last_average_contact_point: Vector3 = Vector3.ZERO

func _ready() -> void:
	get_node("..").body_entered.connect(spawn_particle)

func spawn_particle(_body: Node) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)

	var average_contact_point: Vector3 = Vector3.ZERO
	var average_contact_normal: Vector3 = Vector3.ZERO
	var average_contact_velocity: Vector3 = Vector3.ZERO
	var accepted_contact_count = 0

	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			if car.global_basis.y.dot(state.get_contact_local_normal(i)) < 0.9659:
				average_contact_point += state.get_contact_local_position(i)
				average_contact_normal += state.get_contact_local_normal(i)
				average_contact_velocity += state.get_contact_local_velocity_at_position(i)
				accepted_contact_count += 1
	
	if accepted_contact_count > 0:
		average_contact_point /= accepted_contact_count
		average_contact_normal = average_contact_normal.normalized()
		average_contact_velocity /= accepted_contact_count

		average_contact_velocity = average_contact_velocity.project(average_contact_normal)
		last_average_contact_point = average_contact_point

		if average_contact_velocity.length() > 0.1:
			global_position = average_contact_point

			var hit_amount = clamp((average_contact_velocity.length() - 0.1) / 10.0, 0.0, 1.0)
			(process_material as ParticleProcessMaterial).color = Color(Color.WHITE, hit_amount)
			emitting = true

			if collision_sound:
				collision_sound.volume_db = linear_to_db(hit_amount)
				collision_sound.play()

func _physics_process(_delta: float) -> void:
	if collision_sound:
		if collision_sound.playing:
			collision_sound.global_position = last_average_contact_point
