extends CharacterBody3D

## Flight parameters
@export var max_speed := 10.0
@export var min_speed := 5.0
@export var acceleration := 0.5
@export var rotation_speed := 1.5
@export var lift_factor := 0.5
@export var gravity := 9.8
@export var min_altitude := 3.0

## Wing parameters
@export var left_wing: Node3D
@export var right_wing: Node3D
@export var max_flap_angle := 35.0
@export var flap_speed := 3.5
@export var banking_visible := 0.15

## Behavior parameters
@export var wander_radius := 12.0
@export var target_node: Node3D
@export var ground_avoid_distance := 10.0

## Camera reference (MUST assign in Inspector)
@export var camera_manager : CameraManager


var _velocity := Vector3.FORWARD * min_speed
var _wander_angle := 0.0
var _current_flap_phase := 0.0
var _target_direction := Vector3.FORWARD
var _current_rotation := Vector3.ZERO

func _ready():
	# Initialize flight parameters
	_velocity = -global_transform.basis.z * min_speed
	_velocity.y = min_speed * 0.2
	_target_direction = _velocity.normalized()
	_current_rotation = rotation
	
	# Register with camera system
	# Attempt to find the CameraManager if not set via Inspector
	if camera_manager == null:
		camera_manager = get_tree().get_current_scene().find_child("CameraManager", true, false)


	# Initialize flight parameters
	_velocity = -global_transform.basis.z * min_speed
	_velocity.y = min_speed * 0.2
	_target_direction = _velocity.normalized()
	_current_rotation = rotation
	
	# Register with camera system
	if camera_manager:
		var bird_camera = get_node_or_null("Camera3D")
		if bird_camera:
			camera_manager.register_bird(self)
		else:
			printerr("Camera3D node missing in ", name)
	else:
		printerr("CameraManager not assigned in ", name)

func _physics_process(delta: float) -> void:
	# Calculate steering
	var steering = _calculate_steering(delta)
	
	# Apply movement forces
	_apply_movement_forces(steering, delta)
	
	# Update rotation
	_update_orientation(delta)
	
	# Execute movement
	velocity = _velocity
	move_and_slide()
	
	# Update wing animation
	_animate_wings(delta)

func _input(event):
	if event.is_action_pressed("switch_camera") and camera_manager:
		var my_camera = get_node("Camera3D")
		camera_manager = get_tree().get_root().find_node("CameraManager", true, false)
		if camera_manager == null:
			print("ERROR: CameraManager not assigned in Bird")

# Helper functions --------------------------------------------------
func _calculate_steering(delta: float) -> Vector3:
	var steering: Vector3
	
	if target_node and target_node.is_inside_tree():
		steering = _seek(target_node.global_position)
	else:
		steering = _wander(delta)
	
	steering += _avoid_ground()
	return steering.limit_length(acceleration)

func _apply_movement_forces(steering: Vector3, delta: float):
	var new_velocity = (_velocity + steering).limit_length(max_speed)
	
	if new_velocity.length() < min_speed:
		new_velocity = new_velocity.normalized() * min_speed
	
	if new_velocity.length() > 0.5:
		_velocity = new_velocity
		_target_direction = _velocity.normalized()
	
	var lift = _calculate_lift()
	_velocity.y += (-gravity + lift) * delta
	
	if global_position.y < min_altitude:
		_velocity.y = max(_velocity.y, 0.5)
		global_position.y = max(global_position.y, min_altitude)

func _update_orientation(delta: float):
	if _velocity.length() > 0.5:
		var target_yaw = atan2(_target_direction.x, _target_direction.z)
		_current_rotation.y = lerp_angle(_current_rotation.y, target_yaw, delta * rotation_speed)
		rotation = Vector3(0, _current_rotation.y, 0)

func _animate_wings(delta: float):
	if !left_wing or !right_wing:
		return
	
	_current_flap_phase += delta * flap_speed
	var flap_angle = sin(_current_flap_phase) * max_flap_angle
	var turn_direction = sign(_current_rotation.y - rotation.y)
	var banking_effect = turn_direction * banking_visible * clamp(_velocity.length()/max_speed, 0, 1)
	
	left_wing.rotation.x = deg_to_rad(flap_angle + banking_effect)
	right_wing.rotation.x = deg_to_rad(-flap_angle + banking_effect)

func _seek(target_pos: Vector3) -> Vector3:
	var to_target = (target_pos - global_position).normalized()
	var desired = to_target * max_speed
	if to_target.y > 0:
		desired.y = to_target.y * max_speed * 0.5
	return (desired - _velocity).limit_length(acceleration)

func _wander(delta: float) -> Vector3:
	_wander_angle += randf_range(-0.3, 0.3) * delta
	var forward = _velocity.normalized()
	if forward.length_squared() < 0.1:
		forward = -global_transform.basis.z
	
	var circle_pos = forward * wander_radius
	var displacement = Vector3(cos(_wander_angle) * 2.5, sin(_wander_angle) * 0.2, 0)
	return (circle_pos + displacement).normalized() * max_speed - _velocity

func _avoid_ground() -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * ground_avoid_distance,
		collision_mask
	)
	var result = space_state.intersect_ray(query)
	
	if result:
		var distance = global_position.y - result.position.y
		if distance < min_altitude:
			var strength = 1.0 - (distance / min_altitude)
			return Vector3.UP * strength * acceleration * 1.5
	return Vector3.ZERO

func _calculate_lift() -> float:
	return lift_factor * ((sin(_current_flap_phase * 1.5) + 1) / 2.0 * inverse_lerp(min_speed, max_speed, _velocity.length()))
