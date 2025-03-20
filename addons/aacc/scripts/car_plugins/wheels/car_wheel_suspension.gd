class_name CarWheelSuspension extends CarPluginBase

@export_group("Shape", "wheel_")
@export var wheel_radius: float = 0.3
@export var wheel_buffer_radius: float = 0.3
@export var wheel_width: float = 0.3
@export_flags_3d_physics var wheel_collision_mask: int = 1

@export_group("Suspension", "suspension_")
@export var suspension_length: float = 0.1
@export var suspension_spring: float = 10000.0
@export var suspension_damper: float = 1000.0

var raycast_instance: RayCast3D

var compression: float = 0.0
var last_compression: float = 0.0
var last_compression_set: bool = false

var is_landed: bool = false
var collision_point: Vector3 = Vector3.ZERO
var collision_normal: Vector3 = Vector3.ZERO
var distance: float = 0.0

func _ready() -> void:
	raycast_instance = RayCast3D.new()
	add_child(raycast_instance)
	configure_raycasts()

func configure_raycasts() -> void:
	raycast_instance.target_position = (Vector3.DOWN * (wheel_radius + suspension_length + wheel_buffer_radius))
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
		compression = clamp(compression, 0.0, 1.0)
		if not last_compression_set:
			last_compression = compression
			last_compression_set = true

		var suspension_magnitude: float = 0.0
		suspension_magnitude += compression * suspension_spring

		var compression_delta: float = (compression - last_compression) / delta
		suspension_magnitude += compression_delta * suspension_damper
		last_compression = compression

		suspension_magnitude *= collision_normal.dot(global_basis.y)

		car.set_force(name, collision_normal * suspension_magnitude, false, collision_point - car.global_position)
	else:
		is_landed = false
		last_compression = 0.0
