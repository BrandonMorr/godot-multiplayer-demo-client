extends Control

onready var name_textbox = $MenuPanel/NameTextbox
onready var join_button = $MenuPanel/JoinButton
onready var ready_button = $LobbyPanel/ReadyButton
onready var leave_button = $LobbyPanel/LeaveButton
onready var player_list = $LobbyPanel/PlayerList
onready var status_label = $StatusPanel/StatusLabel

func _ready():
	Network.connect_to_server()
	
	Network.connect("connection_succeeded", self, "_on_connection_succeeded")
	Network.connect("server_disconnected", self, "_on_server_disconnected")
	Network.connect("connection_failed", self, "_on_connection_failed")
	Network.connect("kicked_from_game", self, "_on_kicked_from_game")
	Network.connect("players_updated", self, "_on_players_updated")


func _on_connection_succeeded():
	status_label.text = "Connected to server"
	status_label.modulate = Color.green
	
	join_button.show()
	name_textbox.show()


func _on_server_disconnected():
	status_label.text = "Server disconnected, trying to reconnect..."
	status_label.modulate = Color.red
	
	player_list.clear()
	
	$LobbyPanel.hide()
	$MenuPanel.show()
	
	join_button.hide()
	name_textbox.hide()


func _on_connection_failed():
	status_label.text = "Connection failed, trying to reconnect..."
	status_label.modulate = Color.red
	
	player_list.clear()
	
	$LobbyPanel.hide()
	$MenuPanel.show()
	
	join_button.hide()
	name_textbox.hide()


func _on_JoinButton_pressed():
	var player_name = name_textbox.text.strip_edges()
	
	# if the player name is empty, use the peer ID
	if (player_name == ""):
		player_name = str(Network.get_id())
	
	Network.join_game(player_name)
	
	$MenuPanel.hide()
	$LobbyPanel.show()


func _on_ReadyButton_pressed():
	Network.player_ready()
	
	ready_button.hide()
	leave_button.hide()


func _on_LeaveButton_pressed():
	Network.leave_game()
	
	$LobbyPanel.hide()
	$MenuPanel.show()

func _on_kicked_from_game():
	player_list.clear()
	
	status_label.text = "Booted from the game"
	status_label.modulate = Color.yellow
	
	$LobbyPanel.hide()
	$MenuPanel.show()


func _on_players_updated():
	player_list.clear()
	
	for player_id in Network.players:
		var player_name = Network.players[player_id]
		
		if player_id == Network.get_id():
			player_name += " (you)"
		
		player_list.add_item(player_name, null, false)
