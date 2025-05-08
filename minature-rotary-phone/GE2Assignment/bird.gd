extends CharacterBody3D

# Movement settings
@export var max_speed := 3.0
@export var max_force := 0.3
@export var wander_radius := 2.0

# Target for seek/flee (assign in Inspector or via code)
@export var target_node: Node3D

# CSG parts (assign these in the Inspector!)
@export var left_wing: CSGBox3D
@export var right_wing: CSGBox3D

var _velocity := Vector3(0, 0, -1) * max_speed
var _wander_angle := 3.0



func _physics_process(delta: float) -> void:
	# Choose behavior (uncomment one):
	var steering := wander(delta)          # Random wandering
	# var steering := seek(target_node.global_position)  # Move toward target
	# var steering := flee(target_node.global_position)  # Run from target
	
	steering = steering.limit_length(max_force)
	_velocity = (_velocity + steering).limit_length(max_speed)
	
	# Move and animate
	velocity = _velocity  # Assign to CharacterBody3D's built-in velocity
	move_and_slide()
	_animate_wings(delta)
	#_rotate_to_velocity(delta)

# --- BEHAVIORS ---
func seek(target_pos: Vector3) -> Vector3:
	var desired = (target_pos - global_position).normalized() * max_speed
	return (desired - _velocity).normalized()

func flee(target_pos: Vector3) -> Vector3:
	var desired = (global_position - target_pos).normalized() * max_speed
	return (desired - _velocity).normalized()

func wander(delta: float) -> Vector3:
	_wander_angle += randf_range(-0.5, 0.5) * delta * 10.0
	var circle_pos = _velocity.normalized() * wander_radius
	var displacement = Vector3(cos(_wander_angle), 0, sin(_wander_angle))
	var desired = (circle_pos + displacement).normalized() * max_speed
	return (desired - _velocity).normalized()

# --- ANIMATION/ROTATION ---
func _animate_wings(delta: float) -> void:
	if !left_wing or !right_wing: return
	
	# Simple flapping based on speed
	var flap_speed = 4.0 + _velocity.length() * 0.3
	var flap_angle = sin(Time.get_ticks_msec() * 0.001 * flap_speed) * 30.0
	
	left_wing.rotation.z = deg_to_rad(flap_angle)
	right_wing.rotation.z = deg_to_rad(-flap_angle)  # Opposite wing

func _rotate_to_velocity(delta: float) -> void:
	if _velocity.length() > 0.1:
		# Face direction of movement
		rotation.y = lerp_angle(rotation.y, atan2(_velocity.x, _velocity.z), delta * 5.0)
		# Mild banking effect when turning
		rotation.z = lerp(rotation.z, -_velocity.x * 0.05, delta * 3.0)
