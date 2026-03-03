extends CharacterBody2D

var SPEED = 100
var multiplier
var finished = false
var invincible = false
var id
@onready var sprite = $AnimatedSprite2D

func _ready():
	add_to_group("players")
	multiplier = randi_range(1,5)
	
func _physics_process(delta):
	velocity.y = SPEED * multiplier
	move_and_slide()
