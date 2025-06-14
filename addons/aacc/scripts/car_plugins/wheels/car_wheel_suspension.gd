class_name CarWheelSuspension extends CarPluginBase

@export_group("Shape", "wheel_")
@export var wheel_radius: float = 0.3
@export var wheel_width: float = 0.3
@export_flags_3d_physics var wheel_collision_mask: int = 1

@export_group("Suspension", "suspension_")
@export var suspension_length: float = 0.1
@export var suspension_spring: float = 10000.0
@export var suspension_damper: float = 1000.0

var raycast_instance: RayCast3D

var is_landed: bool = false
var collision_point: Vector3 = Vector3.ZERO
var collision_normal: Vector3 = Vector3.ZERO
var distance: float = 0.0

var compression: float = 0.0
var compression_prev: float = 0.0
var compression_prev_set: bool = false

func _ready() -> void:
	raycast_instance = RayCast3D.new()
	add_child(raycast_instance)
	configure_raycasts()

	debuggable_parameters = [
		&"is_landed",
		&"collision_point",
		&"collision_normal",
		&"distance",
		&"compression",
		&"compression_prev",
		&"compression_prev_set",
	]

func configure_raycasts() -> void:
	raycast_instance.position = Vector3.RIGHT * wheel_width
	raycast_instance.target_position = (Vector3.DOWN * (wheel_radius + suspension_length))
	raycast_instance.enabled = true
	raycast_instance.hit_from_inside = false
	raycast_instance.hit_back_faces = false
	raycast_instance.collision_mask = wheel_collision_mask
	raycast_instance.process_physics_priority = -1000

func set_raycast_values() -> void:
	if raycast_instance.is_colliding():
		collision_point = raycast_instance.get_collision_point()
		collision_normal = raycast_instance.get_collision_normal()
		distance = raycast_instance.global_position.distance_to(collision_point)

func process_plugin(delta: float) -> void:
	if raycast_instance.is_colliding():
		is_landed = true

		set_raycast_values()

		compression = 1.0 - ((distance - wheel_radius) / suspension_length)
		compression = clamp(compression, 0.0, 1.0) # TODO: choice between this and max(compression, 0.0)
		if not compression_prev_set:
			compression_prev = compression
			compression_prev_set = true

		var suspension_magnitude: float = 0.0
		suspension_magnitude += compression * suspension_spring

		var compression_delta: float = (compression - compression_prev) / delta
		suspension_magnitude += compression_delta * suspension_damper
		compression_prev = compression

		suspension_magnitude *= collision_normal.dot(global_basis.y)

		car.set_force(name, collision_normal * suspension_magnitude, false, collision_point - car.global_position)
	else:
		is_landed = false
		compression = 0.0
		compression_prev = 0.0
