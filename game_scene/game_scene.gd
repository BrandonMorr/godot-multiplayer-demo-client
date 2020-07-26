extends Spatial

onready var Player = preload("res://player/player.tscn")

onready var spawn_points = $SpawnPoints.get_children()

puppet func add_players(_players: Dictionary):
	for player_id in _players:
		var player = Player.instance()
		player.set_network_master(player_id)
		player.name = str(player_id)
		player.hide()
		
		$Players.add_child(player)


puppet func add_player(player_id: int):
	var player = Player.instance()
	player.set_network_master(player_id)
	player.name = str(player_id)
	player.hide()
	
	$Players.add_child(player)


puppet func remove_player(player_id: int):
	$Players.get_node(str(player_id)).queue_free()


puppet func spawn_player(player_id: int, spawn_position: Vector3):
	var player = $Players.get_node(str(player_id))
	
	if player:
		player.set_translation(spawn_position)
		player.activate()
		player.show()
