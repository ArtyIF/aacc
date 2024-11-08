extends GPUParticles3D

@onready var car_rid: RID = get_node("..").get_rid()
@onready var collision_sound: AudioStreamPlayer3D = get_node_or_null("CollisionSound")

var delay_between_hits: float = 0.0

func _ready() -> void:
	get_node("..").body_entered.connect(spawn_particle)
	get_node("..").body_exited.connect(body_exited_delay)

func spawn_particle(_body: Node) -> void:
	if delay_between_hits > 0.0:
		delay_between_hits = 0.1
		return

	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)
	
	if state.get_contact_local_velocity_at_position(0).length() > 1.0:
		var average_contact_point: Vector3 = Vector3.ZERO
		var average_contact_velocity: float = 0.0
		for i in range(state.get_contact_count()):
			average_contact_point += state.get_contact_local_position(i)
			average_contact_velocity += state.get_contact_local_velocity_at_position(0).length()
		average_contact_point /= state.get_contact_count()
		average_contact_velocity /= state.get_contact_count()

		global_position = average_contact_point
		emitting = true
		# TODO: bigger/brighter depending on speed
		
		if collision_sound:
			collision_sound.global_position = average_contact_point
			collision_sound.volume_db = linear_to_db(clamp((average_contact_velocity - 1.0) / 10.0, 0.0, 1.0))
			collision_sound.play()

	delay_between_hits = 0.1


func body_exited_delay(_body: Node) -> void:
	delay_between_hits = 0.1

func _physics_process(delta: float) -> void:
	if delay_between_hits >= 0.0:
		delay_between_hits -= delta
