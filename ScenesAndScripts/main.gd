extends Node2D

@onready var turtle_scene = preload("res://ScenesAndScripts/turtle.tscn")
var finished_turts = []
var amount_of_players = 4
var id_names = ["1","2","3","4",]
var start_pos = [[Vector2(2700,820)],[Vector2(4050,820)],[Vector2(5380,820)],[Vector2(6750,820)]]

func _ready():
	spawn_player(amount_of_players)
	finished_turts = []
	
func spawn_player(num_of_players):
	for i in range(num_of_players):
		var player = turtle_scene.instantiate()
		player.id = id_names[i - 1]
		player.global_position = start_pos[i - 1][0]
		add_child(player)

func _on_finish_line_body_exited(body):
	if body.is_in_group("racing"):
		finished_turts.append(body)
		body.finished = true
		body.remove_from_group("racing")
