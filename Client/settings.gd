extends Control

@onready var master_slider = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MusicVolumeSlider
@onready var background_slider = $Panel/MarginContainer/VBoxContainer/HBoxContainer3/BackgoundVolumeSlider
@onready var lead_slider = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/LeadVolumeSlider
func _ready():
	master_slider.value = 25
	master_slider.value_changed.connect(music_volume_changed.bind("Master"))
	background_slider.value = 25
	background_slider.value_changed.connect(music_volume_changed.bind("Background"))
	lead_slider.value = 25
	lead_slider.value_changed.connect(music_volume_changed.bind("Lead"))
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_PAUSABLE

func music_volume_changed(value, bus):
	var bus_index = AudioServer.get_bus_index(bus)
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func _on_music_volume_slider_value_changed(value: float) -> void:
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/Percent.text = str(int(value)) + "%"
	var bus_index = AudioServer.get_bus_index("Master")
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func _on_backgound_volume_slider_value_changed(value: float) -> void:
	$Panel/MarginContainer/VBoxContainer/HBoxContainer3/Percent.text = str(int(value)) + "%"
	var bus_index = AudioServer.get_bus_index("Background")
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func _on_lead_volume_slider_value_changed(value: float) -> void:
	$Panel/MarginContainer/VBoxContainer/HBoxContainer2/Percent.text = str(int(value)) + "%"
	var bus_index = AudioServer.get_bus_index("Lead")
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func _on_global_button_pressed() -> void:
	if $Panel.visible == false:
		$Panel.visible = true
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		$Panel.visible = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
