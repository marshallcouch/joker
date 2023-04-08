extends Node2D
class_name Piece
const ICONS_IN_FOLDER = 20
var base_sprite
var icon_sprite
var piece_base
var piece_id:String
var icon:String
var icon_index:int = 0

signal new_position(new_position,piece_id)

var color_array = [Color(0,0,0),Color(1,0,0), Color(0,1,0), Color(1,1,0),\
Color(0,0,1),Color(1,0,1), Color(0,1,1),Color(1,1,1)]

func _init() -> void:
	piece_id = uuid.v4()

func _ready() -> void:
	base_sprite = $PieceSprite
	icon_sprite = $PieceIconSprite
	piece_base = $PieceBase

func on_click():
	print_debug("I've been selected: " + piece_id)

func on_release():
	emit_signal("new_position", self.position, piece_id)
	print_debug("I've been released: " + piece_id)

func draggable():
	pass
	
func set_base_color(color_int:int = 7) -> Piece:
	base_sprite.modulate = color_array[color_int]
	return self

func set_icon_color (color_int:int = 7)-> Piece:
	icon_sprite.modulate = color_array[color_int]
	return self

func scale_piece(new_scale:Vector2 = Vector2(1,1)) -> Piece:
	scale = new_scale
	return self

func set_icon(index_of_image:int  = 1) -> Piece:
	var dir = Directory.new()
	dir.open("res://assets/sprites/piece_icon/")
	if dir.file_exists(str(index_of_image) + ".png"):
		icon = "res://assets/sprites/piece_icon/" + str(index_of_image) + ".png"
		icon_sprite.texture = load(icon)
		icon_index = index_of_image
	return self
	
func set_id(new_id:String) -> Piece:
	piece_id = new_id
	return self
	
func to_dictionary() ->Dictionary:
	return \
	{"id":piece_id,\
	"bc": [base_sprite.modulate.r,base_sprite.modulate.g,base_sprite.modulate.b,base_sprite.modulate.a],\
	"ic": [icon_sprite.modulate.r,icon_sprite.modulate.g,icon_sprite.modulate.b,icon_sprite.modulate.a],\
	"scl":[scale.x,scale.y],\
	"iidx": icon_index,\
	"pos": [self.position.x, self.position.y]
	}
	
func from_dictionary(piece_info:Dictionary) -> Piece:
	self.piece_id = piece_info["id"]
	base_sprite.modulate = Color(piece_info["bc"][0],piece_info["bc"][1],piece_info["bc"][2],piece_info["bc"][3])
	icon_sprite.modulate = Color(piece_info["ic"][0],piece_info["ic"][1],piece_info["ic"][2],piece_info["ic"][3])
	scale = Vector2(piece_info["scl"][0], piece_info["scl"][0])
	icon = "res://assets/sprites/piece_icon/" + str(piece_info["iidx"]) + ".png"
	icon_sprite.texture = load(icon)
	self.position.x = piece_info["pos"][0]
	self.position.y = piece_info["pos"][1]
	return self
	
func update_position(new_position: Vector2) -> void:
	self.position = new_position


func _to_string() -> String:
	var json_form = self.to_dictionary()
	return JSON.print(json_form)
	
	
