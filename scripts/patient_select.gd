extends Node2D

const PATIENTS = ["daltooki", "dalkongi", "sunny", "byeoli"]
const PATIENT_NAMES = {
	"daltooki": "달토끼",
	"dalkongi": "달콩이",
	"sunny": "써니",
	"byeoli": "별이",
}
const PATIENT_COLORS = {
	"daltooki": Color(1.0, 0.95, 0.8),
	"dalkongi": Color(0.8, 0.95, 1.0),
	"sunny":    Color(1.0, 1.0, 0.7),
	"byeoli":   Color(0.9, 0.8, 1.0),
}

func _ready():
	_play_entry_animations()
	UIAnimations.connect_buttons(self)

func _play_entry_animations():
	$Title.modulate.a = 0.0
	UIAnimations.fly_in_from_top($Title, 50.0, 0.05)
	var cards = [$PatientGrid/DaltooBt, $PatientGrid/DalkongiBt,
				 $PatientGrid/SunnyBt, $PatientGrid/ByeoliBt]
	UIAnimations.stagger_pop_in(cards, 0.2, 0.13)

func _on_patient_pressed(patient_id: String):
	SoundManager.play_sfx("sfx_click")
	GameManager.start_treatment(patient_id)
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")

func _on_back_button_pressed():
	SceneTransition.change_scene("res://scenes/Main.tscn")
