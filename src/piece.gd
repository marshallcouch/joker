extends Node2D

const ICONS_IN_FOLDER = 20
onready var base_sprite = $PieceSprite
onready var icon_sprite = $PieceIconSprite
onready var piece_base = $PieceBase

var piece_id = null

func _ready() -> void:
	piece_id = uuid.v4()
	pass
#	set_base_color()
#	set_icon_color()
#	scale_piece(Vector2(.4,.4))
#	set_icon_image(2)

func on_click():
	print_debug("I've been clicked! piece")

func set_base_color(color = Color(1,1,1,1)):
	base_sprite.modulate = color

func set_icon_color (color = Color(0,0,0,1)):
	icon_sprite.modulate = color

func scale_piece(new_scale:Vector2 = Vector2(1,1)):
	scale = new_scale
#	piece_base.scale = new_scale
#	base_sprite.scale = new_scale
#	icon_sprite.scale = new_scale

func set_icon_image(index_of_image:int  = 1):
	var dir = Directory.new()
	dir.open("res://assets/sprites/piece_icon/")
	if dir.file_exists(String(index_of_image) + ".png"):
		var image = Image.new()
		image.load("res://assets/sprites/piece_icon/" + String(index_of_image) + ".png")
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		icon_sprite.texture = texture
	
