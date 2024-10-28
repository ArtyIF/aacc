@icon("res://addons/aacc/icons/car_wheel.svg")
class_name CarWheel extends Node3D

@export_group("Shape")
## The radius of the wheel. Half of the wheel's size.
@export var wheel_radius: float = 0.3
## The extra radius of the wheel to make the car stick to the ground more.
@export var buffer_radius: float = 0.1
## The width of the wheel.
##
## AACC's wheels currently use 2 raycasts for the wheels.
@export var wheel_width: float = 0.3

@export_group("Suspension")
## The maximum length of the suspension.
##
## If the suspension length gets exceeded (because of the
## [member buffer_radius]), the suspension starts working in reverse, pulling
## the car to the ground instead of pushing it away from it. This can be useful
## to make the car stick to the ground better.
@export var suspension_length: float = 0.1
## The spring force the suspension applies.
@export var suspension_spring: float = 3000.0
## The damper applied to the spring force the suspension applies so it wasn't
## too springy and out of control.
@export var suspension_damper: float = 300.0

@export_group("Visuals")
@export var visual_node: Node3D
@export var steerable: bool = false
@export var limit_top: bool = false
@export var limit_bottom: bool = false

#== NODES ==#
var raycast_instance_1: RayCast3D
var raycast_instance_2: RayCast3D
var parent_car: Car

#== COMPRESSION ==#
var compression: float = 0.0
var last_compression: float = 0.0
var last_compression_set: bool = false

#== VISUALS ==#
var initial_visual_node_transform: Transform3D

#== EXTERNAL ==#
var is_colliding: bool = false
var collision_point: Vector3
var collision_normal: Vector3
var distance: float

func _ready():
	raycast_instance_1 = RayCast3D.new()
	add_child(raycast_instance_1)
	raycast_instance_2 = RayCast3D.new()
	add_child(raycast_instance_2)
	configure_raycasts()

	parent_car = get_parent() as Car
	if visual_node:
		initial_visual_node_transform = visual_node.transform

func configure_raycasts():
	raycast_instance_1.target_position = (Vector3.DOWN * (wheel_radius + suspension_length + buffer_radius))
	raycast_instance_1.enabled = true
	raycast_instance_1.hit_from_inside = false
	raycast_instance_1.hit_back_faces = false
	raycast_instance_1.collision_mask = 1
	raycast_instance_1.process_physics_priority = -1000
	raycast_instance_1.position = Vector3.RIGHT * wheel_width

	raycast_instance_2.target_position = (Vector3.DOWN * (wheel_radius + suspension_length + buffer_radius))
	raycast_instance_2.enabled = true
	raycast_instance_2.hit_from_inside = false
	raycast_instance_2.hit_back_faces = false
	raycast_instance_2.collision_mask = 1
	raycast_instance_2.process_physics_priority = -1000

func set_raycast_values():
	var collision_point_1: Vector3 = raycast_instance_1.get_collision_point()
	var collision_normal_1: Vector3 = raycast_instance_1.get_collision_normal()
	var distance_1: float = raycast_instance_1.global_position.distance_to(collision_point_1)

	var collision_point_2: Vector3 = raycast_instance_2.get_collision_point()
	var collision_normal_2: Vector3 = raycast_instance_2.get_collision_normal()
	var distance_2: float = raycast_instance_2.global_position.distance_to(collision_point_2)

	if raycast_instance_1.is_colliding() and raycast_instance_2.is_colliding():
		collision_point = collision_point_1.lerp(collision_point_2, 0.5)
		collision_normal = collision_normal_1.slerp(collision_normal_2, 0.5)
		distance = lerp(distance_1, distance_2, 0.5)
	elif raycast_instance_1.is_colliding():
		collision_point = collision_point_1
		collision_normal = collision_normal_1
		distance = distance_1
	elif raycast_instance_2.is_colliding():
		collision_point = collision_point_2
		collision_normal = collision_normal_2
		distance = distance_2

func update_visuals():
	if !visual_node: return

	var new_transform: Transform3D = initial_visual_node_transform

	var suspension_translation: Vector3 = suspension_length * Vector3.DOWN
	if is_colliding:
		var compression_translation = 1.0 - compression
		if limit_top:
			compression_translation = max(0.0, compression_translation)
		if limit_bottom:
			compression_translation = min(0.0, compression_translation)
		suspension_translation *= compression_translation

	var steer_rotation: float = 0.0
	if steerable:
		steer_rotation = -parent_car.smooth_steer.get_current_value() * parent_car.base_steer_degrees

	new_transform = new_transform.translated_local(suspension_translation)
	new_transform = new_transform.rotated_local(Vector3.UP, steer_rotation)

	visual_node.transform = new_transform

func _physics_process(delta: float):
	if raycast_instance_1.is_colliding() or raycast_instance_2.is_colliding():
		is_colliding = true
		set_raycast_values()

		compression = 1.0 - ((distance - wheel_radius) / suspension_length)
		if not last_compression_set:
			last_compression = compression
			last_compression_set = true

		if not parent_car.freeze:
			var suspension_magnitude: float = 0.0
			suspension_magnitude += compression * suspension_spring

			var compression_delta: float = (compression - last_compression) / delta
			suspension_magnitude += compression_delta * suspension_damper
			last_compression = compression

			suspension_magnitude *= collision_normal.dot(global_basis.y)
			parent_car.apply_force(collision_normal * suspension_magnitude, collision_point - parent_car.global_position)
	else:
		is_colliding = false
		last_compression = 0.0

	update_visuals()
