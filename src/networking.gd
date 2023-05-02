extends Node
class_name Networking

var is_server:bool = false
var is_client:bool = false
var is_connected:bool = false
var server: TCP_Server
var server_clients: Array = []
var http_client:HTTPClient = null
const DEFAULT_PORT:int = 8282
const DEFAULT_SERVER:String = "localhost"
var HEADERS = [ "User-Agent: Pirulo/1.0 (Godot)", "Accept: */*"]
signal data_received(data,peer_id) #dictionary of the message received, String ID of the client
signal peer_connected(peer_id)
signal peer_disconnected(peer_id)
var last_status:int = -1
var player_name:String = uuid.v4()
var debug_networking = true
var client_packet_buffer: Array = []

class Client:
	#var stream_peer: StreamPeerTCP
	var stream_peer:StreamPeerSSL
	var id: String
	var packet_buffer: Array = []
	
func _ready() -> void:
	pass

func start_server(port:int = DEFAULT_PORT) -> Networking:
	print_debug("hosting_game on port " + str(port) + "...")
	is_server = true
	server = TCP_Server.new()
	var err = server.listen(port)
	if err != OK:
		print_debug("error starting server " + str(err))
	return self

func set_player_name(new_name:String) -> Networking:
	player_name = new_name
	return self
	
func join_game(server:String = DEFAULT_SERVER, port:int = DEFAULT_PORT) -> Networking:
	var url = server + ":" + str(port)
	is_client = true
	http_client = HTTPClient.new()
	var err = http_client.connect_to_host(server, port)
	assert(err == OK)
	return self


func stop_game() -> Networking:
	if is_client:
		http_client.close()
		http_client = null
		is_client = false

	if is_server:
		server.stop()
		server = null
		is_server = false
		
	return self


func get_time()-> String:
	var t = Time.get_datetime_dict_from_system()
	var mt = Time.get_ticks_msec()
	return str(t["hour"]) +":" + str(t["minute"]) +":"+ \
	str(t["second"]) + " - " + str(mt) + " - "


func send_packet(packet_content:String,peer_id:String = "", broadcast:bool = false) -> void:
	if is_client:
		client_packet_buffer.append(packet_content)
	if is_server:
		for client in server_clients:
			if client.id == peer_id or broadcast:
				client.packet_buffer.append(packet_content)


func _process(_delta):
	if is_server:
		server_poll()
	if is_client:
		client_poll()


func client_poll():
	http_client.poll()	
	if last_status != http_client.get_status():
		last_status = http_client.get_status()
		print(http_client.get_status())
	#this is where the client polls to see if there is any updated state
	if http_client.get_status() == http_client.STATUS_CONNECTED:
		if client_packet_buffer.size() > 0:
			http_client.request(HTTPClient.METHOD_POST,"/",HEADERS,client_packet_buffer.pop_front())
		else:
			http_client.request(HTTPClient.METHOD_POST,"/",HEADERS,Utils.json_to_string({"action":"poll", "player_name":player_name}))
	if http_client.has_response():
		# If there is a response...
		var headers = http_client.get_response_headers() # Get response headers.
		print("headers: ", headers)
		print("code: ", http_client.get_response_code()) # Show response code.
		# Getting the HTTP Body
		if !http_client.is_response_chunked():
			# Or just plain Content-Length
			var bl = http_client.get_response_body_length()

		# This method works for both anyway
		var rb:PoolByteArray # Array that will hold the data.
		if http_client.get_status() == HTTPClient.STATUS_BODY:
			var chunk = http_client.read_response_body_chunk()
			if chunk.size() == 0:
				if not OS.has_feature("web"):
					OS.delay_usec(20)
				else:
					yield()
					Engine.get_main_loop()
			else:
				rb = rb + chunk # Append to read buffer.
		var message_json:String = rb.get_string_from_ascii()
		if message_json.find('"action":')>0:
			emit_signal("data_received", message_json,"")


func server_poll() -> void:
	if server.is_connection_available():
		var client = Client.new()
		client.stream_peer = server.take_connection()
		client.id = uuid.v4()
		server_clients.append(client)
		#client.stream_peer.set_no_delay(true)
		if debug_networking:
			print("Client connected: " + client.id)
#		var response:Dictionary = {"status":"Connected"}
#		client.stream_peer.put_data(write_server_http_message(JSON.stringify(response)))
		emit_signal("peer_connected", client.id)
		#client.disconnect_from_host()

	for client in server_clients:
		if client.stream_peer.get_connected_host():
			var data = client.stream_peer.get_available_bytes()
			if data > 0:
				var message = client.stream_peer.get_string(data)
				var message_json:String = message.substr(message.find("{"))
				if debug_networking == true and message_json.find('"action":"poll",') < 0:
					print("Received message: " + message)
				#client.stream_peer.put_data(write_server_http_message("Got it!"))
				
				if message_json.find('"action":"poll",') < 0:
					emit_signal("data_received",message_json,client.id)
				if client.packet_buffer.size() > 0:
					client.stream_peer.put_data(write_server_http_message(client.packet_buffer.pop_front()))
				else:
					client.stream_peer.put_data(write_server_http_message(Utils.json_to_string({"status":"connected"})))


func write_server_http_message(body:String) -> PoolByteArray:
	if debug_networking == true:
		print("message sent: " + body)
	var msg = "HTTP/1.1 200 OK\r\nAccess-Control-Allow-Origin: *"
	msg += "\r\nContent-Type: application/json\r\nContent-Length:" 
	msg += str(body.to_utf8().size())
	msg += "\r\n\r\n"
	msg += body
	return msg.to_utf8()
	
		

