extends Area2D

@export var speed: float = 1200
var target
var turn_speed = 200
var damage = 1
var user
var mult
var ground_trap = false

var sim_position: Vector2
var sim_rotation: float

@onready var sprite = $Fish

# Called when the node enters the scene tree for the first time.
func _ready():
	Inventory.projectiles.append(self)
	sprite.play('Swim')
	sim_position = position
	sim_rotation = rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if transform.x.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

	position = position.lerp(sim_position, 0.25)
	rotation = lerp_angle(rotation, sim_rotation, 0.25)

func tick(curr_tick, tick_rat):
	var target_pos = target.sim_position + Vector2(0, target.height)
	var to_target = (target_pos - sim_position).normalized()
	var target_angle = to_target.angle()

	sim_rotation = target_angle
	var direction = Vector2.RIGHT.rotated(sim_rotation)
	sim_position += direction * speed * tick_rat * user.projectile_speed

func hit(body):
	if body == target:
		queue_free()
		Inventory.projectiles.erase(self)
		if body.invincible == false:
			body.invin_frames()
