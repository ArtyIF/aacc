extends Node3D

@export var hit_sound: PackedScene
@export var sparks: PackedScene

@onready var car: Car = get_node("..")
@onready var car_rid: RID = car.get_rid()
@onready var scrape_sound: AudioStreamPlayer3D = get_node("ScrapeSound")

var sparks_control: int = 0
var smooth_scratch_amount: SmoothedFloat = SmoothedFloat.new(0.0, 50.0, 5.0)

func play_hit_sound(_body: Node) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)

	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			var projected_velocity: Vector3 = state.get_contact_local_velocity_at_position(i).project(state.get_contact_local_normal(i))
			if projected_velocity.length() > 0.1:
				# TODO: have a globally-accessible class take care of it
				var hit_amount: float = clamp((projected_velocity.length() - 0.1) / 5.0, 0.0, 1.0)

				if AACCGlobal.can_play("Collision", car):
					var hit_instance: AudioStreamPlayer3D = hit_sound.instantiate()
					hit_instance.volume_db = linear_to_db(hit_amount)
					hit_instance.pitch_scale = randf_range(0.9, 1.1)
					add_child(hit_instance)
					hit_instance.global_position = state.get_contact_local_position(i)

				spawn_particle(i, state, hit_amount)

func spawn_particle(i: int, state: PhysicsDirectBodyState3D, scratch_amount: float) -> void:
	# TODO: have a globally-accessible class take care of it
	var sparks_instance: GPUParticles3D = sparks.instantiate()
	sparks_instance.amount_ratio = scratch_amount
	add_child(sparks_instance)
	sparks_instance.global_position = state.get_contact_local_position(i) + (Vector3(randf(), randf(), randf()) * randf_range(-0.25, 0.25))
	if not Vector3.UP.cross(state.get_contact_local_normal(i)).is_zero_approx():
		sparks_instance.global_basis = Basis.looking_at(state.get_contact_local_normal(i), Vector3.UP.rotated(state.get_contact_local_normal(i), randf_range(0.0, deg_to_rad(360.0))))
	else:
		sparks_instance.global_basis = Basis.from_euler(Vector3(0.0, randf_range(0.0, deg_to_rad(360.0)), 0.0))

func _ready() -> void:
	get_node("..").body_entered.connect(play_hit_sound)

func _physics_process(delta: float) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(car_rid)

	var total_scratch_amount: float = 0.0

	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			var scratch_amount: float = (state.get_contact_local_velocity_at_position(i).length() - 0.1) / 20.0
			total_scratch_amount += scratch_amount

			if sparks_control == 0:
				spawn_particle(i, state, scratch_amount)

		total_scratch_amount /= state.get_contact_count()

		if AACCGlobal.can_play("Scrape", car):
			if not scrape_sound.playing:
				scrape_sound.play(randf_range(0.0, scrape_sound.stream.get_length()))
			scrape_sound.pitch_scale = clamp(lerp(0.2, 1.0, total_scratch_amount), 0.2, 2.0)
		else:
			scrape_sound.stop()
	else:
		sparks_control = 0

	smooth_scratch_amount.advance_to(clamp(total_scratch_amount, 0.0, 1.0), delta)
	scrape_sound.volume_db = linear_to_db(smooth_scratch_amount.get_current_value())
	if scrape_sound.volume_db < -60.0 or car.freeze: # TODO: get from project settings
		scrape_sound.stop()
	
	# TODO: use delta
	sparks_control += 1
	if sparks_control >= 4:
		sparks_control = 0
