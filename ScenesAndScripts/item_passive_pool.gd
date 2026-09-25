extends Node

var appendages = ["arm", "head", "shell", "legs"]
var all_buffs = ["ankle_weights", "barbell", "dumbell", "kettlebell", "punching_bag", "resistance_band"]
var all_items = {
	"arm": ["fissile_cannon", "bear_trap", "machine_gun"],
	"head": ["propreller", "bunny_ears", "dunce_hat", "m1_helmet", "kings_crown", "halo", "cyborg_eye", "clown_wig"],
	"shell": ["ammo_belt", "battery", "streaker_leaf", "suit", "angel_wings"],
	"legs": ["rollerskates", "cinderblocks", "rocketboots"]
}

var total_pool

func _ready():
	total_pool = all_items.duplicate(true)
	
func arm(item):
	match item:
		"fissile_cannon":
			return load("res://Items/fissile_cannon.tres")
		"eel_spit":
			return load("res://Items/eel_spit.tres")
		"mystery_item":
			return load("res://Items/mystery_item.tres")
		"bear_trap":
			return load("res://Items/bear_trap.tres")
		"machine_gun":
			return load("res://Items/machine_gun.tres")
		"boomerang":
			return load("res://Items/boomerang.tres")

func head(item):
	match item:
		"propreller":
			return load("res://Passives/Head/propreller.tres")
		"bunny_ears":
			return load("res://Passives/Head/bunny_ears.tres")
		"dunce_hat":
			return load("res://Passives/Head/dunce_hat.tres")
		"m1_helmet":
			return load("res://Passives/Head/m1_helmet.tres")
		"kings_crown":
			return load("res://Passives/Head/kings_crown.tres")
		"halo":
			return load("res://Passives/Head/halo.tres")
		"cyborg_eye":
			return load("res://Passives/Head/cyborg_eye.tres")
		"clown_wig":
			return load("res://Passives/Head/clown_wig.tres")

func shell(item):
	match item:
		"ammo_belt":
			return load("res://Passives/Shell/ammo_belt.tres")
		"battery":
			return load("res://Passives/Shell/battery.tres")
		"streaker_leaf":
			return load("res://Passives/Shell/streaker_leaf.tres")
		"suit":
			return load("res://Passives/Shell/suit.tres")
		"angel_wings":
			return load("res://Passives/Shell/angel_wings.tres")
		
func legs(item):
	match item:
		"rollerskates":
			return load("res://Passives/Legs/rollerskates.tres")
		"cinderblocks":
			return load("res://Passives/Legs/cinderblocks.tres")
		"rocketboots":
			return load("res://Passives/Legs/rocketboots.tres")

func stat_buff(buff):
	match buff:
		"ankle_weights":
			return load("res://StatBuffs/ankle_weight.tres")
		"barbell":
			return load("res://StatBuffs/barbell.tres")
		"dumbell":
			return load("res://StatBuffs/dumbell.tres")
		"kettlebell":
			return load("res://StatBuffs/kettlebell.tres")
		"punching_bag":
			return load("res://StatBuffs/punching_bag.tres")
		"resistance_band":
			return load("res://StatBuffs/resistance_band.tres")
