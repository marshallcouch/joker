extends Node2D

var start_menu
var start_panel
var start_menu_vbox
var pieces
var camera
var start_game_button
var piece_preload = preload("res://scenes/pieces/Piece.tscn")

func _set_onready_variables() ->void:
	start_menu = $Controls/StartMenu
	start_panel = $Controls/StartMenu/StartMenuPanel
	pieces = $Pieces
	camera = $Controls/Camera
	start_game_button = $Controls/StartMenu/StartMenuVbox/StartGameButton


class Player:
	var id:String
	var hand: Array
	var name:String
	var stream: StreamPeerTCP
	func set_id():
		id = uuid.v4()
		

func _ready() -> void:
	#var _connected = get_tree().root.connect("size_changed",Callable(self,"_on_viewport_resized"))
	_set_onready_variables()
	camera.connect("show_hand",self,"_show_hand")
	camera.connect("menu",self,"_show_start_menu")
	_setup_game()


func _show_start_menu():
	if start_menu.visible:
		start_menu.hide()
	else:
		start_menu.show()


func _setup_game(player_count:int = 6):
	match player_count:
		4:
			$Boards/JokerBoard4.show()
		6:
			$Boards/JokerBoard6.show()
		8: 
			$Boards/JokerBoard8.show()
	start_menu.hide()
	for p in $Pieces.get_children():
		$Pieces.remove_child(p)
	#load pieces
	var file = File.new()
	file.open("res://assets/json/piece_locations.tres",File.READ)
	var piece_locations = file.get_as_text()
	piece_locations = piece_locations.replace("[gd_resource type=\"Resource\" format=2]","").replace("[resource]","")
	var positions = JSON.parse(piece_locations).result
	
	for i in 4:
		for j in 5:
			var piece = piece_preload.instance()
			pieces.add_child(piece)
			piece.set_base_color(i).set_icon_color(7).scale_piece(Vector2(1,1)).set_icon(i+1)
			piece.position = Vector2(positions["4_player"][i][j][0],positions["4_player"][i][j][1])
			piece.connect("new_position",self,"_update_piece_position")
	for i in 6:
		for j in 5:
			var piece = piece_preload.instance()
			pieces.add_child(piece)
			piece.set_base_color(i).set_icon_color(7).scale_piece(Vector2(1,1)).set_icon(i+1)
			piece.position = Vector2(positions["6_player"][i][j][0],positions["6_player"][i][j][1])
			piece.connect("new_position",self,"_update_piece_position")


func _input(event) -> void:
	if event.is_action_pressed("ui_menu"):
		_show_start_menu()

func _on_start_menu_button_pressed(button_pressed: String) -> void:
	if button_pressed == "start_game":
		_setup_game()
	if button_pressed == "return_to_game":
		start_menu.hide()
	if button_pressed == "quit":
		get_tree().quit()
	
