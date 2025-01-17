## TODO: documentation
class_name CarTireScreechSound extends AudioStreamPlayer3D
@export var pitch_range: Vector2 = Vector2(0.5, 1.0)

@onready var car: Car = get_node("..")
var smooth_burnout_amount = SmoothedFloat.new(0.0, 4.0, 4.0)

func _physics_process(delta: float) -> void:
	smooth_burnout_amount.advance_to(clamp(car.burnout_amount * 10.0, 0.0, 1.0), delta)
	pitch_scale = lerp(pitch_range.x, pitch_range.y, smooth_burnout_amount.get_current_value())
	volume_db = linear_to_db(clamp(car.burnout_amount * 10.0, 0.0, 1.0))

	if is_inf(volume_db) or car.freeze:
		volume_db = -80.0
	if volume_db >= -60.0 and not playing:
		play(randf_range(0.0, stream.get_length()))
	elif volume_db < -60.0 and playing:
		stop()
