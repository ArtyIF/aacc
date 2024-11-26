extends GPUParticles3D

@onready var car: Car = get_node("..")
@onready var car_rid: RID = car.get_rid()
@onready var scratch_sound: AudioStreamPlayer3D = get_node("ScratchSound")

func _physics_process(delta: float) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)

	var average_contact_point: Vector3 = Vector3.ZERO
	var average_contact_normal: Vector3 = Vector3.ZERO
	var average_contact_velocity: float = 0.0
	var accepted_contact_count = 0

	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			if car.global_basis.y.dot(state.get_contact_local_normal(i)) < 0.9659:
				average_contact_point += state.get_contact_local_position(i)
				average_contact_normal += state.get_contact_local_normal(i)
				average_contact_velocity += state.get_contact_local_velocity_at_position(0).length()
				accepted_contact_count += 1
	
	if accepted_contact_count > 0:
		average_contact_point /= accepted_contact_count
		average_contact_normal = average_contact_normal.normalized()
		average_contact_velocity /= accepted_contact_count

		global_position = average_contact_point
		if not Vector3.UP.cross(average_contact_normal).is_zero_approx():
			global_basis = Basis.looking_at(average_contact_normal)
		else:
			global_basis = Basis.IDENTITY

		var scratch_amount: float = clamp((average_contact_velocity - 0.1) / 10.0, 0.0, 1.0)
		amount_ratio = scratch_amount
		emitting = scratch_amount > 0.0
		
		scratch_sound.global_position = average_contact_point
		if not scratch_sound.playing:
			scratch_sound.play(randf_range(0.0, scratch_sound.stream.get_length()))
		scratch_sound.volume_db = linear_to_db(scratch_amount)
		scratch_sound.pitch_scale = lerp(0.5, 1.0, clamp(scratch_amount, 0.0, 1.0))
	else:
		amount_ratio = 0.0
		emitting = false
		scratch_sound.stop()
