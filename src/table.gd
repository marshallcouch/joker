extends Node2D

var start_menu
var start_panel
var start_menu_vbox
var discard_pile
var cards_in_hand_list
var hand_container
var hand_panel
var hand_canvas
var pieces
var camera
var server_label
var server_text_box
var player_name_label
var player_name_text_box
var connect_button
var join_button
var start_game_button
var disconnect_game_button
var piece_preload = preload("res://scenes/pieces/Piece.tscn")

func _set_onready_variables() ->void:
	start_menu = $Controls/StartMenu
	start_panel = $Controls/StartMenu/StartMenuPanel
	start_menu_vbox = $Controls/StartMenu/StartMenuPanel/StartMenuVbox
	discard_pile = $Cards/DiscardArea
	cards_in_hand_list = $Controls/HandCanvas/HandContainer/CardsInHand
	hand_container = $Controls/HandCanvas/HandContainer
	hand_panel = $Controls/HandCanvas/HandPanel
	hand_canvas = $Controls/HandCanvas
	pieces = $Pieces
	camera = $Controls/Camera
	server_label = $Controls/StartMenu/StartMenuVbox/ServerLabel
	server_text_box = $Controls/StartMenu/StartMenuVbox/ServerTextBox
	player_name_label = $Controls/StartMenu/StartMenuVbox/PlayerNameLabel
	player_name_text_box = $Controls/StartMenu/StartMenuVbox/PlayerNameTextBox
	connect_button = $Controls/StartMenu/StartMenuVbox/ConnectGameButton
	join_button = $Controls/StartMenu/StartMenuVbox/JoinGameButton
	start_game_button = $Controls/StartMenu/StartMenuVbox/StartGameButton
	disconnect_game_button = $Controls/StartMenu/StartMenuVbox/DisconnectGameButton

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
	for i in 8:
		for j in 5:
			var piece = piece_preload.instance()
			pieces.add_child(piece)
			piece.set_base_color(i).set_icon_color(7).scale_piece(Vector2(1,1)).set_icon(i+1)
			piece.position = Vector2(-100+(1+i)*20,-100+(1+j)*20)
			piece.connect("new_position",self,"_update_piece_position")
			print(piece)


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
	
