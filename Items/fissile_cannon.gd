extends Node2D
var user
var fissile_scene = load("res://Items/fissile.tscn")
var fissile 
var flip = false

@onready var firepoint = $AnimatedSprite2D/Firepoint
@onready var sprite = $AnimatedSprite2D

func _ready():
	if flip:
		sprite.flip_h = true

func _process(delta):
	pass
	
func fire(target):
	fissile = fissile_scene.instantiate()
	fissile.user = user
	fissile.target = target
	fissile.global_position = user.global_position
	add_child(fissile)
