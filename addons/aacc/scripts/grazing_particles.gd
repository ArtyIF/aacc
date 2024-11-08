extends GPUParticles3D
@onready var car_rid: RID = get_node("..").get_rid()

func _physics_process(delta: float) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)
	if state.get_contact_count() > 0:
		var average_contact_point: Vector3 = state.get_contact_local_position(0)
		var average_contact_normal: Vector3 = state.get_contact_local_normal(0)

		global_position = average_contact_point
		if not Vector3.UP.cross(average_contact_normal).is_zero_approx():
			global_basis = Basis.looking_at(average_contact_normal)
		else:
			global_basis = Basis.IDENTITY

		amount_ratio = clamp((state.get_contact_local_velocity_at_position(0).length() - 0.1) / 10.0, 0.0, 1.0)
		emitting = amount_ratio > 0
	else:
		amount_ratio = 0
		emitting = false
