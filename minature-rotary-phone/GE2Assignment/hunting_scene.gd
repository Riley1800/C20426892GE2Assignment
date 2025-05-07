extends Node3D

# Debug Drawing Configuration
var custom_font: Font
var text_size := 30

# Grid Visualization
var grid_size := 5000.0
var grid_subdivisions := 50

func _ready():
	# Initialize font
	custom_font = load("res://fonts/Hyperspace Bold.otf")
	if not custom_font:
		push_error("Failed to load custom font")
		return
	
	# Setup DebugDraw2D configuration
	DebugDraw2D.config.text_custom_font = custom_font
	DebugDraw2D.config.text_default_size = text_size
	DebugDraw2D.config.text_background_color = Color.TRANSPARENT
	
	get_window().set_current_screen(1)
	
	# Create FPS graph
	var fps_graph = _create_fps_graph(
		Vector2i(500, 110),
		DebugDraw2DGraph.POSITION_LEFT_TOP if Engine.is_editor_hint() else DebugDraw2DGraph.POSITION_RIGHT_TOP
	)
	fps_graph.frame_time_mode = false

func _process(delta):
	on_draw_gizmos()

func on_draw_gizmos():
	DebugDraw3D.draw_grid(
		Vector3.ZERO,
		Vector3.RIGHT * grid_size,
		Vector3.BACK * grid_size,
		Vector2(grid_subdivisions, grid_subdivisions),
		Color.WHITE
	)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _create_fps_graph(size: Vector2i, position: int) -> DebugDraw2DGraph:
	var graph = DebugDraw2D.create_fps_graph("FPS")
	if graph:
		graph.size = size
		graph.buffer_size = 50
		graph.corner = position
		graph.show_title = false
		graph.show_text_flags = (
			DebugDraw2DGraph.TEXT_CURRENT | 
			DebugDraw2DGraph.TEXT_AVG | 
			DebugDraw2DGraph.TEXT_MAX | 
			DebugDraw2DGraph.TEXT_MIN
		)
		graph.custom_font = custom_font
		graph.text_color = Color.CHARTREUSE
		graph.background_color = Color.TRANSPARENT
		graph.text_size = text_size
		graph.set_parent("", DebugDraw2DGraph.SIDE_BOTTOM)
	return graph
