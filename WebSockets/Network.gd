extends Node

# Imports
const NetworkClient = preload("res://WebSockets/websockets_client.gd")
const Packet = preload("res://WebSockets/packet.gd")

@onready var _network_client = NetworkClient.new()

signal _on_connected
signal _on_error
signal _on_disconnected

var is_connected = false

func _ready():
	#_network_client.connect_to_server("127.0.0.1", 8081)
	return
	
func connect_server(server = "127.0.0.1"):
	_network_client.connected.connect(_handle_client_connected)
	_network_client.disconnected.connect(_handle_client_disconnected)
	_network_client.error.connect(_handle_network_error)
	_network_client.data.connect(_handle_network_data)
	add_child(_network_client)
	_network_client.connect_to_server(server, 8081)

signal _on_update_price(fishes_price)

func PLAY(p):
	match p.action:
		"Update_price":
			_on_update_price.emit(p.payloads[0])
			print("receive: ", p.payloads[0])


func _handle_client_connected():
	_on_connected.emit()
	is_connected = true
	#print("Client connected to server!")


func _handle_client_disconnected(was_clean: bool):
	_on_disconnected.emit()
	#OS.alert("Disconnected %s" % ["cleanly" if was_clean else "unexpectedly"])
	#get_tree().quit()


func _handle_network_data(data: String):
	#print("Received server data: ", data)
	var action_payloads: Array = Packet.json_to_action_payloads(data)
	var p: Packet = Packet.new(action_payloads[0], action_payloads[1])
	# Pass the packet to our current state
	PLAY(p)


func _handle_network_error():
	_on_error.emit()
	OS.alert("There was an error")

func ask_price(fishes = []):
	var p: Packet = Packet.new("Update_price", fishes)
	return _network_client.send_packet(p)

