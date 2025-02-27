class_name CarWheel extends AACCPluginBase

@export_group("Shape")
@export var wheel_radius: float = 0.3
@export var wheel_width: float = 0.3
@export_flags_3d_physics var collision_mask: int = 1

@export_group("Suspension")
@export var suspension_length: float = 0.1
@export var suspension_spring: float = 3000.0
@export var suspension_damper: float = 300.0

#== NODES ==#
var raycast_instance_1: RayCast3D
var raycast_instance_2: RayCast3D

#== COMPRESSION ==#
var compression: float = 0.0
var last_compression: float = 0.0
var last_compression_set: bool = false

#== EXTERNAL ==#
var is_colliding: bool = false
var collision_point: Vector3 = Vector3.ZERO
var collision_normal: Vector3 = Vector3.ZERO
var distance: float = 0.0

func _ready() -> void:
	raycast_instance_1 = RayCast3D.new()
	add_child(raycast_instance_1)
	raycast_instance_2 = RayCast3D.new()
	add_child(raycast_instance_2)
	configure_raycasts()

	car.add_param("TotalWheels", 0)
	car.add_param("LandedWheels", 0)

func configure_raycasts() -> void:
	raycast_instance_1.target_position = (Vector3.DOWN * (wheel_radius + suspension_length))
	raycast_instance_1.enabled = true
	raycast_instance_1.hit_from_inside = false
	raycast_instance_1.hit_back_faces = false
	raycast_instance_1.collision_mask = collision_mask
	raycast_instance_1.process_physics_priority = -1000
	raycast_instance_1.position = Vector3.RIGHT * wheel_width

	raycast_instance_2.target_position = (Vector3.DOWN * (wheel_radius + suspension_length))
	raycast_instance_2.enabled = true
	raycast_instance_2.hit_from_inside = false
	raycast_instance_2.hit_back_faces = false
	raycast_instance_1.collision_mask = collision_mask
	raycast_instance_2.process_physics_priority = -1000

func set_raycast_values() -> void:
	# TODO: apply forces per raycast
	var collision_point_1: Vector3 = raycast_instance_1.get_collision_point()
	var collision_normal_1: Vector3 = raycast_instance_1.get_collision_normal()
	var distance_1: float = raycast_instance_1.global_position.distance_to(collision_point_1)

	var collision_point_2: Vector3 = raycast_instance_2.get_collision_point()
	var collision_normal_2: Vector3 = raycast_instance_2.get_collision_normal()
	var distance_2: float = raycast_instance_2.global_position.distance_to(collision_point_2)

	if raycast_instance_1.is_colliding() and raycast_instance_2.is_colliding():
		collision_point = (collision_point_1 + collision_point_2) / 2.0
		collision_normal = (collision_normal_1 + collision_normal_2).normalized()
		distance = lerp(distance_1, distance_2, 0.5)
	elif raycast_instance_1.is_colliding():
		collision_point = collision_point_1
		collision_normal = collision_normal_1
		distance = distance_1
	elif raycast_instance_2.is_colliding():
		collision_point = collision_point_2
		collision_normal = collision_normal_2
		distance = distance_2

func process_plugin(delta: float) -> void:
	car.set_param("TotalWheels", car.get_param("TotalWheels") + 1)
	car.set_param_reset_value("TotalWheels", 0)
	
	if raycast_instance_1.is_colliding() or raycast_instance_2.is_colliding():
		is_colliding = true
		car.set_param("LandedWheels", car.get_param("LandedWheels") + 1)
		car.set_param_reset_value("LandedWheels", 0)

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

		if not car.freeze:
			car.add_force(name, collision_normal * suspension_magnitude, collision_point - car.global_position)
	else:
		is_colliding = false
		last_compression = 0.0
