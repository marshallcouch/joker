class_name Utils
static func setup_standard_deck(with_jokers:bool = false,unlimited:bool = false)->Dictionary:
	var new_deck_cards:Array = []
	var suit_name = ""
	for i in 4:
		if i == 0:
			suit_name = "Spades"
		elif i == 1:
			suit_name = "Hearts"
		elif i == 2:
			suit_name = "Clubs"
		elif i == 3:
			suit_name = "Diamonds"
			
		for j in range(2,11):
			new_deck_cards.append({"name": str(j) + " of " + suit_name})
		
		new_deck_cards.append({"name": "Ace" + " of " + suit_name})
		new_deck_cards.append({"name": "King" + " of " + suit_name})
		new_deck_cards.append({"name": "Queen" + " of " + suit_name})
		new_deck_cards.append({"name": "Jack" + " of " + suit_name})
	if with_jokers:
		new_deck_cards.append({"name": "Joker"})
		new_deck_cards.append({"name": "Joker"})
	randomize()
	if unlimited:
		var unlimited_deck_cards: Array = []
		for i in 20: #20 decks seems pretty unlimited...
			new_deck_cards.shuffle()
			unlimited_deck_cards.append_array(new_deck_cards)
		new_deck_cards = unlimited_deck_cards
	else:
		new_deck_cards.shuffle()
	
	return {"type":"standard","name":"standard","cards":new_deck_cards, \
	"jokers":with_jokers, "unlimited":unlimited}


static func json_to_string(json:Dictionary) -> String:
	return JSON.print(json)
	
static func string_to_json(json:String) -> Dictionary:
	var p = JSON.parse(json)
	return p.result
