class_name CarTireScreechAudio extends CarPluginBase
@export var pitch_range: Vector2 = Vector2(0.5, 1.0)
@export var tire_screech_scene: PackedScene

var player: AudioStreamPlayer3D
# TODO: configurable
var smooth_burnout_amount_volume: SmoothedFloat = SmoothedFloat.new(0.0, 10.0, 10.0)
var smooth_burnout_amount_pitch: SmoothedFloat = SmoothedFloat.new(0.0, 10.0, 1.0)

@onready var plugin_wp: CarWheelsProcessor = car.get_plugin(&"WheelsProcessor")

func _ready() -> void:
	player = tire_screech_scene.instantiate()
	add_child(player)

func process_plugin(delta: float) -> void:
	if plugin_wp.ground_coefficient > 0.0:
		player.global_position = plugin_wp.ground_average_point

		var slip_total: float = car.get_meta(&"slip_total", 0.0)
		smooth_burnout_amount_volume.advance_to(slip_total, delta)
		smooth_burnout_amount_pitch.advance_to(slip_total, delta)
	else:
		smooth_burnout_amount_volume.advance_to(0.0, delta)
		smooth_burnout_amount_pitch.advance_to(0.0, delta)

	# TODO: screech sound on landing (separate plugin)

	player.volume_linear = clamp(smooth_burnout_amount_volume.get_value(), 0.0, 1.0)
	player.pitch_scale = lerp(pitch_range.x, pitch_range.y, smooth_burnout_amount_pitch.get_value())

	if car.freeze:
		player.volume_linear = 0.0
	if player.volume_db >= -60.0 and not player.playing:
		player.play(randf_range(0.0, player.stream.get_length()))
	elif player.volume_db < -60.0 and player.playing:
		player.stop()
