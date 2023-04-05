extends Node
class_name Networking

var is_server:bool = false
var is_client:bool = false
var is_connected:bool = false
var peer = null
var player_list:Array = []
const DEFAULT_PORT = 8181
const DEFAULT_SERVER = "localhost"

func _ready() -> void:
	print_debug("networking created")

func start_game(port:int = DEFAULT_PORT):
	print_debug("hosting_game on port " + String(port) + "...")
	is_server = true
	peer = WebSocketServer.new()
	peer.connect("client_connected", self, "_peer_connected")
	peer.connect("client_disconnected", self, "_peer_disconnected")
	peer.connect("client_close_request", self, "_peer_disconnected")
	peer.connect("data_received", self, "_on_data")
	var err = peer.listen(port, ['my-protocol'], false)
	if err != OK:
		set_process(false)
		print_debug("error starting server " + String(err))


func join_game(server:String = DEFAULT_SERVER, port:int = DEFAULT_PORT, player_name:String = "player"):
	var ws_url = "ws://" + server + ":" + String(port)
	print_debug("joining game " + ws_url + "...")
	is_client = true
	peer = WebSocketClient.new()
	peer.connect("connection_closed", self, "disconnect_game")
	peer.connect("connection_error", self, "disconnect_game")
	peer.connect("connection_established", self, "_server_connected")
	peer.connect("data_received", self, "_on_data")
	var err = peer.connect_to_url(ws_url,['my-protocol'], false)
	if err != OK:
		print_debug("Unable to connect " + String(err))
		set_process(false)
	else:
		print_debug("connecting...")
	


func stop_game():
	disconnect_game()
	
#both
func disconnect_game(error = 0):
	
	#server
	if is_server:
		peer.stop()
		if peer.is_connected("client_connected", self, "_peer_connected"):
			peer.disconnect("client_connected", self, "_peer_connected")
		if peer.is_connected("client_disconnected", self, "_peer_disconnected"):
			peer.disconnect("client_disconnected", self, "_peer_disconnected")
		if peer.is_connected("client_close_request", self, "_peer_disconnected"):
			peer.disconnect("client_close_request", self, "_peer_disconnected")
		is_server = false

	#client
	if is_client:
		if peer.is_connected("connection_closed", self, "_disconnect_game"):
			peer.disconnect("connection_closed", self, "_disconnect_game")
		if peer.is_connected("connection_error", self, "_disconnect_game"):
			peer.disconnect("connection_error", self, "_disconnect_game")
		if peer.is_connected("connection_established", self, "_server_connected"):
			peer.disconnect("connection_established", self, "_server_connected")
		is_client = false
	#both
	if peer.is_connected("data_received", self, "_on_data"):
		peer.disconnect("data_received", self, "_on_data")
		
	print_debug("Disconnected")


#when the game client has connected to the server
func _server_connected(proto):
	print_debug("This client is now connected to server")
	send_packet("test packet from client")

#server has peer connected
func _peer_connected(id,proto):
	print_debug("player connected to server:" + String(id))
	player_list.append({"player_id":id,"player_name":"default"})
	send_packet("test packet from server",id)

#server has a peer disconnected
func _peer_disconnected(id):
	print_debug("peer disconnected")
	for i in player_list.size():
		if id == player_list[i]["player_id"]:
			player_list.remove(i)

func broadcast_to_peers(broadcast_content:String) -> void:
	pass

func broadcast():
	pass

func send_packet(packet_content:String,peer_id:int = 1) -> void:
	if is_client:
		peer.get_peer(peer_id).put_packet(packet_content.to_utf8())
	if is_server:
		peer.get_peer(peer_id).put_packet(packet_content.to_utf8())
	
	
func _process(_delta):
	if is_client or is_server:
		peer.poll()
		
		
func _on_data(id:int = 0) -> void:
	var pkt = peer.get_peer(id).get_packet().get_string_from_utf8()
	print_debug("Got data from client %d: %s " % [id, pkt])
#	if is_server:
#		print_debug("server got data")
#		peer.get_peer(id).get_packet().get_string_from_utf8()
#	elif is_client:
#		print_debug("client got data")
#		 String(peer.get_peer(1).get_packet().get_string_from_utf8())

