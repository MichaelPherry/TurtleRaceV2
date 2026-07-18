extends Node

var appendages = ["arm", "head", "shell", "legs"]
var total_pool = {
	"arm": ["fissile", "bear_trap"],
	"head": ["propreller", "bunny_ears", "dunce_hat", "m1_helmet"],
	"shell": ["ammo_belt", "arc_reactor"],
	"legs": ["rollerskates", "cinderblocks"]
}

func arm(item):
	match item:
		"fissile":
			return load("res://Items/fissile.tres")
		"eel_spit":
			return load("res://Items/eel_spit.tres")
		"mystery_item":
			return load("res://Items/mystery_item.tres")
		"bear_trap":
			return load("res://Items/bear_trap.tres")

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

func shell(item):
	match item:
		"ammo_belt":
			return load("res://Passives/Shell/ammo_belt.tres")
		"arc_reactor":
			return load("res://Passives/Shell/arc_reactor.tres")
		
func legs(item):
	match item:
		"rollerskates":
			return load("res://Passives/Legs/rollerskates.tres")
		"cinderblocks":
			return load("res://Passives/Legs/cinderblocks.tres")
