extends Node3D

@export var hit_sound: PackedScene
@export var land_sound: PackedScene
@export var sparks: PackedScene

@onready var car: Car = get_node("..")
@onready var car_rid: RID = car.get_rid()
@onready var scratch_sound: AudioStreamPlayer3D = get_node("ScratchSound")

var sparks_control: int = 0

func play_hit_sound(_body: Node) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)

	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			var projected_velocity: Vector3 = state.get_contact_local_velocity_at_position(i).project(state.get_contact_local_normal(i))
			if projected_velocity.length() > 0.1:
				# TODO: have a globally-accessible class take care of it
				var hit_instance: AudioStreamPlayer3D
				var hit_amount: float = clamp((projected_velocity.length() - 0.1) / 5.0, 0.0, 1.0)
				if car.global_basis.y.dot(state.get_contact_local_normal(i)) < 0.9659:
					hit_instance = hit_sound.instantiate()
				else:
					hit_instance = land_sound.instantiate()
				hit_instance.volume_db = linear_to_db(hit_amount)
				hit_instance.pitch_scale = randf_range(0.9, 1.1)
				add_child(hit_instance)
				hit_instance.global_position = state.get_contact_local_position(i)


func _ready() -> void:
	get_node("..").body_entered.connect(play_hit_sound)

func _physics_process(delta: float) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)

	var average_contact_velocity: float = 0.0
	var total_scratch_amount: float = 0.0

	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			average_contact_velocity += state.get_contact_local_velocity_at_position(i).length()
			var scratch_amount: float = clamp((state.get_contact_local_velocity_at_position(i).length() - 0.1) / 10.0, 0.0, 1.0)
			total_scratch_amount += scratch_amount

			if sparks_control == 0:
				# TODO: have a globally-accessible class take care of it
				var sparks_instance: GPUParticles3D = sparks.instantiate()
				sparks_instance.amount_ratio = scratch_amount
				add_child(sparks_instance)
				sparks_instance.global_position = state.get_contact_local_position(i)
				if not Vector3.UP.cross(state.get_contact_local_normal(i)).is_zero_approx():
					sparks_instance.global_basis = Basis.looking_at(state.get_contact_local_normal(i))
				else:
					# Since the initial velocity direction is (0.0, 1.0, -1.0), this makes the sparks face up
					sparks_instance.global_basis = Basis.from_euler(Vector3(deg_to_rad(45.0), 0.0, 0.0))

		total_scratch_amount = clamp(total_scratch_amount, 0.0, 1.0)
		if not scratch_sound.playing:
			scratch_sound.play(randf_range(0.0, scratch_sound.stream.get_length()))
		scratch_sound.volume_db = linear_to_db(total_scratch_amount)
		scratch_sound.pitch_scale = lerp(0.5, 1.0, clamp(total_scratch_amount, 0.0, 1.0))
	else:
		scratch_sound.stop()
		sparks_control = 0
	
	sparks_control += 1
	if sparks_control >= 4:
		sparks_control = 0
