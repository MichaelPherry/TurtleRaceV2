extends Node

#Format grabbed from server
#	"id" : {
#		"items" : {
#		"leftArm" : null,
#		"rightArm" : null,
#		"head" : null,
#		"shell" : null,
#		"legs" : null,
#		"slot" : integer
#		},
#		"base_stats" : {
#			"acceleration" : integer,
#			"resilience" : percentage,
#			"max_speed" : integer,
#			"fire_rate" : integer,
#			"projectile_speed" : integer,
#			"luck" : integer
#		},
#		"econ" : {
#			"gold" : integer,
#			"turtle1_stock" : integer,
#			"turtle2_stock" : integer,
#			"turtle3_stock" : integer,
#			"turtle4_stock" : integer
#		},
		#"results": {
			#"first": 0,
			#"second": 0,
			#"third": 0,
			#"fourth": 0
		#}
#	}

var appendages = ["head", "shell", "legs", "leftArm", "rightArm"]
var stats = ["acceleration", "resilience", "max_speed", "fire_rate", "projectile_speed", "luck"]
var econ = ["gold"]
var results = ["first", "second", "third", "fourth"]
var what_pos = {}
var race_order = []
var race_complete = false

var main_hud = true
var rng_calls = 0
var mode
var id_list
var id_name_list
var local_turtle = {}
var server_turtles = {}
var start_time
var projectiles = []
var end_items = []
var race_started = false
var start = false
var tick_controller_ref
var wins_needed_for_boss = 3

var item_1
var item_2
var item_3

var buff_1
var buff_2
var buff_3

var boss_player_name
var boss_id 
var boss_name_tag = "Rabbit"
var seed

#currently not in use
func reset_turtles():
	var server_keys = server_turtles.keys()
	for id in server_keys:
		for body_part in appendages:
			server_turtles[id][body_part] = null
		server_turtles[id]["slot"] = null
		
func set_turtles(turtles):
	var server_keys = turtles.keys()
	for id in server_keys:
		for body_part in appendages:	
			server_turtles.get_or_add(id, {}).get_or_add("items", {})[body_part] = turtles[id]["build"]["items"][body_part]
		for stat in stats:
			server_turtles.get_or_add(id, {}).get_or_add("base_stats", {})[stat] = turtles[id]["build"]["base_stats"][stat]
		for security in econ:
			server_turtles.get_or_add(id, {}).get_or_add("econ", {})[security] = turtles[id]["build"]["econ"][security]
		for place in results:
			server_turtles.get_or_add(id, {}).get_or_add("results", {})[place] = turtles[id]["build"]["results"][place]
		var server_slot = turtles.get(id, {}).get("slot", 2)
		server_turtles[id]["slot"] = server_slot
		#server_turtles[id]["slot"] = turtles[id]["slot"]

func seconds_to_ticks(seconds, tick_rate):
	return round (seconds / tick_rate)
	
func wait_ticks(user, amt_of_seconds_to_wait):
	var amt_of_ticks_to_wait = seconds_to_ticks(amt_of_seconds_to_wait, user.tick_rat)
	var target_tick = user.curr_tick + amt_of_ticks_to_wait
	while user.curr_tick < target_tick:
		await tick_controller_ref.tick_sig

func dupe_remover(duped_list):
	var unique_list = []
	for element in duped_list:
		if element not in unique_list:
			unique_list.append(element)
	return unique_list

func label_finder(server_id):
	var gamer_tag = null
	for sid in Inventory.id_name_list:
		if server_id == sid[0]:
			gamer_tag = sid[1]
			break
	return gamer_tag

func sid_finder(gamer_tag):
	var sid = null
	for tag in Inventory.id_name_list:
		if gamer_tag == tag[1]:
			sid = tag[0]
			break
	return sid
