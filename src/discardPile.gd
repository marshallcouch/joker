extends Area2D

var discard_pile: Array = []
onready var discard_pile_list = $DiscardPile

func _ready() -> void:
	pass

func on_click():
	pass

func discard(card_to_discard:Dictionary) -> void:
	discard_pile_list.add_item(card_to_discard["name"])
	discard_pile_list.move_item(discard_pile.size(),0)
	discard_pile.push_front(card_to_discard)
	
func draw_selected() -> Dictionary:
	var item = discard_pile_list.get_selected_items()[0]
	discard_pile_list.items.pop_at(item)
	return discard_pile.pop_at(item)
