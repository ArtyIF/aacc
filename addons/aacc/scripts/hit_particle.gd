extends GPUParticles3D
@onready var car_rid: RID = get_node("..").get_rid()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("..").body_entered.connect(spawn_particle)

func spawn_particle(_body: Node) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)
	
	if state.get_contact_local_velocity_at_position(0).length() > 1.0:
		var average_contact_point: Vector3 = state.get_contact_local_position(0)
		global_position = average_contact_point
		emitting = true
		# TODO: bigger/brighter depending on speed
