extends Node2D

func _ready():
	$GuideLabel.text = "준비 중이에요! 곧 나와요 🔨"

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")
