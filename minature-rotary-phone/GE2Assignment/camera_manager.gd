extends Node

@export var transition_speed := 3.0
@export var follow_distance := 2.0  # For non-mounted cameras

var current_target : Node3D
var current_camera : Camera3D
var camera_pivot : Node3D

func _ready():
	# Create smooth follow pivot
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	
	# Get viewport's current camera and disable it
	var viewport_cam = get_viewport().get_camera_3d()
	if viewport_cam and viewport_cam.get_parent() != self:
		viewport_cam.current = false

func switch_to_entity_camera(entity: Node3D):
	if !entity: return
	
	# Find camera in entity's children
	var new_camera : Camera3D
	for child in entity.get_children():
		if child is Camera3D:
			new_camera = child
			break
	
	if new_camera:
		# Handle transition
		_transition_to_camera(new_camera, entity)
		current_target = entity

func _transition_to_camera(target_cam: Camera3D, target_entity: Node3D):
	if current_camera:
		current_camera.current = false
	
	# Two transition modes:
	if target_cam.get_parent() == target_entity:
		# 1. For mounted cameras (birds/mice)
		target_cam.current = true
		current_camera = target_cam
		
		# Optional: Make camera inherit parent rotation 
		target_cam.top_level = false  # Follow parent's transform
	else:
		# 2. For free cameras
		camera_pivot.global_transform = target_cam.global_transform
		current_camera = camera_pivot.get_node("Camera3D")
		current_camera.current = true

func _process(delta):
	# Smooth follow for non-mounted cameras
	if current_target and !current_camera.is_inside_tree():
		var target_pos = current_target.global_position
		var offset = -current_target.global_transform.basis.z * follow_distance
		camera_pivot.global_position = camera_pivot.global_position.lerp(
			target_pos + offset,
			transition_speed * delta
		)
		camera_pivot.look_at(target_pos)
