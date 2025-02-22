## TODO: documentation
class_name CarTireRollSound extends AudioStreamPlayer3D

@onready var car: Car = get_node("..")

var smooth_volume: SmoothedFloat = SmoothedFloat.new(0.0, 50.0, 5.0)

func _physics_process(delta: float) -> void:
	var target_value: float = abs(car.local_linear_velocity.z / 15.0)
	smooth_volume.advance_to(clamp(target_value * car.ground_coefficient, 0.0, 1.0), delta)
	volume_db = linear_to_db(smooth_volume.get_current_value())
	
	if target_value > 0.01:
		pitch_scale = clamp(target_value, 0.01, 10.0)

	if AACCGlobal.can_play("TireRoll", car):
		if is_inf(volume_db) or car.freeze:
			volume_db = -80.0
		if volume_db >= -60.0 and not playing:
			play(randf_range(0.0, stream.get_length()))
		elif volume_db < -60.0 and playing:
			stop()
	else:
		stop()
