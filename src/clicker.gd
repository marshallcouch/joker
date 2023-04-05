extends Node2D


var click_all = false
var ignore_unclickable = true
var previous_mouse_position = Vector2()
var is_dragging:bool = false
var dragging_shape
var zoom: = Vector2(1,1)
var camera = null

func _input(event):
	if !camera:
		setup_camera()
		
	if event is InputEventMouseButton and event.pressed and event.button_index == 1: # Left mouse click
		var shapes = get_world_2d().direct_space_state.intersect_point(get_global_mouse_position(), 32, [], 0x7FFFFFFF, true, true) # The last 'true' enables Area2D intersections, previous four values are all defaults
		for shape in shapes:
			if shape["collider"].has_method("on_click"):
				shape["collider"].on_click()
				dragging_shape = shape["collider"]
				if !click_all and ignore_unclickable:
					break # Thus clicks only the topmost clickable
			if !click_all and !ignore_unclickable:
				break # Thus stops on the first shape
		previous_mouse_position = event.position
		is_dragging = true
		
	if event is InputEventMouseButton and !event.pressed and event.button_index == 1: 
		dragging_shape = null
		is_dragging = false
		
	if is_dragging and event is InputEventMouseMotion and dragging_shape:
		var shapes = get_world_2d().direct_space_state.intersect_point(get_global_mouse_position(), 32, [], 0x7FFFFFFF, true, true) # The last 'true' enables Area2D intersections, previous four values are all defaults
		dragging_shape.position += (event.position - previous_mouse_position) * camera.zoom  # * get_tree().get_root().find_node("Camera2D").
		previous_mouse_position = event.position
	
			
func setup_camera():
	var viewport = get_viewport()
	var camerasGroupName = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)
	for camera in cameras:
		if camera is Camera2D and camera.current:
			self.camera = camera



