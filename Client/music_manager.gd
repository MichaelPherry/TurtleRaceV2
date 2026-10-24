extends Node2D

var current_lead
var duration = 2.0
var background_vol = 0
var lead_vol = 0

@onready var mainmenu = $Mainmenu
@onready var bass = $Bass
@onready var organ = $Organ
@onready var piano = $Piano
@onready var trumpet = $Trumpet
@onready var whistle = $Whistle
@onready var soundeffects = $Soundeffects
var instruments = [organ, piano, trumpet, whistle]

var effect_dict = {
	"button_click": [preload("res://Art/SoundEffects/pop.wav"), 0],
	"button_error": [preload("res://Art/SoundEffects/error.mp3"), 10],
	"open_hud": [preload("res://Art/SoundEffects/bamboo_whoosh.wav"), 0],
	"close_hud": [preload("res://Art/SoundEffects/long_whoosh.wav"), 0]
}

func _ready():
	current_lead = organ
	mainmenu.play()
	mainmenu.volume_db = 10
	bass.play()
	organ.play()
	piano.play()
	trumpet.play()
	whistle.play()
	
func switch(switch_lead):
	organ.volume_db = -80.0
	piano.volume_db = -80.0
	trumpet.volume_db = -80.0
	whistle.volume_db = -80.0
	switch_lead.volume_db = lead_vol

func fade_in():
	if bass.volume_db < lead_vol:
		var tween = create_tween()
		tween.tween_property(bass, "volume_db", lead_vol, duration)
		current_lead = fade_in

func play_effect(sound):
	var effect = effect_dict[sound]
	soundeffects.volume_db = effect[1]
	soundeffects.stream = effect[0]
	soundeffects.play()

func _on_mainmenu_finished() -> void:
	mainmenu.play(10.0)
	
