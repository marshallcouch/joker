extends Camera2D

var zoom_min = Vector2(.1,.1)
var zoom_max = Vector2(2,2)
var zoom_speed = Vector2(.5, .5)
var previous_mouse_position = Vector2()
var is_dragging = false
var over_something = false
var scroll_zooming_enabled = true
const PAN_SPEED = 10
signal show_hand
signal menu
var camera_action: String = ""

func _ready() -> void:
	get_tree().root.connect("size_changed",self,"_on_viewport_size_changed")
	_on_viewport_size_changed()
	
func set_server_info_label(new_text:String) ->void:
	$ActionPanel/ServerInfoLabel.text = new_text

func _on_viewport_size_changed():
	if get_viewport().size.x < 1000:
		$ActionPanel.transform = Transform2D(0,Vector2(
			get_viewport().size.x *.5 - (.5*$ActionPanel/HBoxContainer.rect_size.x)\
			,get_viewport().size.y - 100))
		zoom = Vector2(1080/get_viewport().size.y,1080/get_viewport().size.y)
	else:
		$ActionPanel.transform = Transform2D(0,Vector2(20,20))


func _on_recenter_button_pressed() -> void:
	position.x = 0
	position.y = 0
	zoom = Vector2(1080/get_viewport().size.y,1080/get_viewport().size.y)

func _process(delta):
	if camera_action == "zoom_in":
		zoom -= zoom_speed * delta
	elif camera_action == "zoom_out":
		zoom += zoom_speed * delta 

func _on_HandButton_pressed() -> void:
	emit_signal("show_hand")


func _on_ActionButtonMenu_pressed() -> void:
	emit_signal("menu") # Replace with function body.


func _on_move_button_down(action:String)-> void:
	self.camera_action = action


func _on_move_button_up():
	camera_action = "" # Replace with function body.

