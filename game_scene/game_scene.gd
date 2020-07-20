extends Spatial

onready var Player = load("res://player/player.tscn")

onready var spawn_points = $SpawnPoints
onready var players = $Players

puppet func add_players(_players: Dictionary):
	# create player objects and 
	for player_id in _players:
		var player = Player.instance()
		
		player.name = str(player_id)
		player.set_network_master(player_id)
		
		$Players.add_child(player)


puppet func add_player(player_id: int):
	var player = Player.instance()
	
	player.name = str(player_id)
	player.set_network_master(player_id)
	
	$Players.add_child(player)


puppet func remove_player(id):
	$Players.get_node(str(id)).queue_free()


puppet func spawn_player(random_position, id):
	var player = Player.instance()
	
	player.position = random_position
	player.name = str(id)
	player.set_network_master(id)
	
	$Players.add_child(player)
