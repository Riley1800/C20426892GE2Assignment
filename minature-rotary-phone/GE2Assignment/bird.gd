extends CharacterBody3D

@export var target: Node3D  # The mouse target we want to follow
var force: Vector3 = Vector3.ZERO  # Initialize force as zero
var mass: float = 1.0  # Default mass

# Maximum speed
@export var max_speed: float = 10.0

func _ready():
	# Access the parent scene (HuntingScene)
	var hunting_scene = get_tree().root.get_node("HuntingScene")  # Adjust path to "HuntingScene"
	
	if hunting_scene == null:
		print("ERROR: HuntingScene not found!")
		return
	
	# Print child nodes in the scene to debug
	print("Children of HuntingScene:", hunting_scene.get_children())

	# Access the "Mouse" node inside HuntingScene, which is your "MouseScene"
	var mouse_scene = hunting_scene.get_node("Mouse")  # Get the scene named "Mouse"
	
	if mouse_scene == null:
		print("ERROR: MouseScene (named Mouse) not found!")
		return

	# Print child nodes in MouseScene to debug
	print("Children of MouseScene:", mouse_scene.get_children())
	
	# Get the target mouse inside the MouseScene (which is also named "Mouse")
	target = mouse_scene.get_node("Mouse")  # The "Mouse" node inside the "Mouse" scene
	
	if target != null:
		print("Mouse target found: ", target.name)
	else:
		print("ERROR: Mouse target (named Mouse) not found inside MouseScene!")

func _process(delta):
	if target != null:
		# Now you can safely access the global_position of the target (Mouse)
		var target_position = target.global_position
		print("Target position: ", target_position)
		
		# Calculate the force (seek behavior)
		force = seek(target_position)
		
		# Apply the force by modifying velocity
		velocity += force / mass * delta
		
		# Limit the velocity to the maximum speed
		velocity = velocity.limit_length(max_speed)
		
		# Apply movement using move_and_slide (built-in method)
		move_and_slide()
	else:
		print("ERROR: Target is null!")

# Seek behavior to move towards the target position
func seek(target_position: Vector3) -> Vector3:
	var to_target = target_position - global_position
	var desired_velocity = to_target.normalized() * max_speed
	return desired_velocity - velocity
