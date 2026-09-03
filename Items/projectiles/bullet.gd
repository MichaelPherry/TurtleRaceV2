extends Area2D

@export var speed: float = 1200
var target
var user

var direction
var sim_position: Vector2
var last_distace = 7777777
var sim_rotation: float
var keyword_attributes
var damage = 5
var players
var hit_radius = 200
var positions = []
@onready var sprite = $Fish


func _ready():
	self.visible = true
	Inventory.projectiles.append(self)
	$AnimatedSprite2D.play('default')
	sim_position = global_position
	players = get_tree().get_nodes_in_group("racing")
	
func _process(delta):
	position = position.lerp(sim_position, 0.25)
	
	
func tick(curr_tick, tick_rat):
	sim_position += direction * speed * tick_rat * user.projectile_speed
	if sim_position.distance_to(target.sim_position) > last_distace and abs(last_distace) > 3500:
		queue_free()
		Inventory.projectiles.erase(self)
	last_distace = sim_position.distance_to(target.sim_position)
	for player in players:
		positions.append([player.global_position.x, player.global_position.y + player.height, player])
	
	for player_positions in positions:
		if sim_position.distance_to(Vector2(player_positions[0], player_positions[1])) < hit_radius:
			hit(player_positions[2])
	
func hit(body):
	if body != user:
		queue_free()
		Inventory.projectiles.erase(self)
		if body.invincible == false:
			body.invin_frames(damage, keyword_attributes)
