extends Node

# defaults
const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 3000

var players = {}

# signals
signal connection_failed
signal connection_succeeded
signal server_disconnected
signal kicked_from_game
signal players_updated

func _ready():
	get_tree().connect("connected_to_server", self, "_on_server_connected")
	get_tree().connect("connection_failed", self, "_on_server_failure")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")


# called when network peer has connected to server
func _on_server_connected():
	emit_signal("connection_succeeded")


# called when network peer fails to establish connection
func _on_server_failure():
	# remove peer
	get_tree().set_network_peer(null)
	
	emit_signal("connection_failed")
	
	# try to reconnect
	connect_to_server()


# called when network peer has disconnected from server
func _on_server_disconnected():
	# clear out players dictionary
	players.clear()
	
	emit_signal("server_disconnected")
	
	# try to reconnect
	connect_to_server()


# create a connection to the server
func connect_to_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


# add new player to registry
puppet func register_player(player_id: int, player_name: String):
	players[player_id] = player_name
	
	emit_signal("players_updated")

# remove player from registry
puppet func unregister_player(id: int):
	players.erase(id)
	
	emit_signal("players_updated")


# player has been kicked, clear out game data
puppet func player_kicked():
	players.clear()
	
	emit_signal("kicked_from_game")


# join a game session
func join_game(player_name: String):
	rpc_id(1, "register_player", player_name)


# leave a game session
func leave_game():
	rpc_id(1, "player_left", get_id())


puppet func pre_start_game():
	get_node("/root/Menu").hide()
	
	var game = load("res://game_scene/game_scene.tscn").instance()
	get_tree().get_root().add_child(game)
	
	rpc_id(1, "post_start_game")


func player_ready():
	rpc_id(1, "player_ready")


func get_player_names():
	return players.values()


func get_player_ids():
	return players.keys()


func get_id():
	return get_tree().get_network_unique_id()
