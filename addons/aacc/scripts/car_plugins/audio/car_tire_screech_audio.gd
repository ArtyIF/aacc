class_name CarTireScreechAudio extends CarPluginBase
@export var pitch_range: Vector2 = Vector2(0.5, 1.0)
@export var tire_screech_scene: PackedScene

var player: AudioStreamPlayer3D
var smooth_burnout_amount: SmoothedFloat = SmoothedFloat.new(0.0, 8.0, 8.0)

func _ready() -> void:
	player = tire_screech_scene.instantiate()
	add_child(player)

	player.volume_linear = 0.0
	player.pitch_scale = pitch_range.x

func _physics_process(delta: float) -> void:
	if is_zero_approx(car.get_meta(&"ground_coefficient", 0.0)):
		player.stop()
		return

	# TODO: burnout amount plugin
	smooth_burnout_amount.advance_to(clamp(abs(car.get_meta(&"local_linear_velocity").x) / 5.0, 0.0, 1.0), delta)

	# TODO: screech sound on landing (separate plugin?)

	player.pitch_scale = lerp(pitch_range.x, pitch_range.y, smooth_burnout_amount.get_value())
	player.volume_linear = clamp(smooth_burnout_amount.get_value(), 0.0, 1.0)

	if car.freeze:
		player.volume_linear = 0.0
	if player.volume_db >= -60.0 and not player.playing:
		player.play(randf_range(0.0, player.stream.get_length()))
	elif player.volume_db < -60.0 and player.playing:
		player.stop()
