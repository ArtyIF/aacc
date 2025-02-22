## TODO: documentation
class_name CarTireScreechSound extends AudioStreamPlayer3D
@export var pitch_range: Vector2 = Vector2(0.5, 1.0)
@export var land_sound: PackedScene

@onready var car: Car = get_node("..")
var smooth_burnout_amount = SmoothedFloat.new(0.0, 8.0, 8.0)
var smooth_burnout_amount_land = SmoothedFloat.new(0.0, 8.0, 8.0)
var old_ground_coefficient: float = 1.0

func _physics_process(delta: float) -> void:
	smooth_burnout_amount.advance_to(clamp(car.burnout_amount * 10.0, 0.0, 1.0), delta)

	# TODO: separate into a different component
	smooth_burnout_amount_land.advance_to(0.0, delta)
	if car.ground_coefficient > old_ground_coefficient:
		var land_velocity: float = clamp(max(-car.linear_velocity.y, 0.0) * (car.ground_coefficient - old_ground_coefficient) / 5.0, 0.0, 1.0)
		if land_velocity >= 0.1:
			smooth_burnout_amount_land.force_current_value(land_velocity)
		
		if AACCGlobal.can_play("Collision", car):
			var hit_instance: AudioStreamPlayer3D = land_sound.instantiate()
			hit_instance.volume_db = linear_to_db(land_velocity)
			hit_instance.pitch_scale = randf_range(0.9, 1.1)
			add_child(hit_instance)
	
	var burnout_land: float = max(smooth_burnout_amount.get_current_value(), smooth_burnout_amount_land.get_current_value())
	pitch_scale = 1.0 if burnout_land > smooth_burnout_amount.get_current_value() else lerp(pitch_range.x, pitch_range.y, smooth_burnout_amount.get_current_value())
	volume_db = linear_to_db(clamp(burnout_land * 10.0, 0.0, 1.0))

	if AACCGlobal.can_play("TireScreech", car):
		if is_inf(volume_db) or car.freeze:
			volume_db = -80.0
		if volume_db >= -60.0 and not playing:
			play(randf_range(0.0, stream.get_length()))
		elif volume_db < -60.0 and playing:
			stop()
	else:
		stop()
	
	old_ground_coefficient = car.ground_coefficient
