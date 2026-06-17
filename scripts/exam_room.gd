extends Node2D

const SYMPTOM_EMOJI = {
	"fever":       "🌡️ 열이 나요",
	"wound":       "🩹 무릎을 다쳤어요",
	"runny_nose":  "🤧 콧물이 나요",
	"stomachache": "💊 배가 아파요",
	"toothache":   "🦷 이가 아파요",
	"eye_itch":    "👁️ 눈이 가려워요",
}

const TOOL_SCENE = {
	"fever":       "res://scenes/minigames/Thermometer.tscn",
	"wound":       "res://scenes/minigames/Bandage.tscn",
	"runny_nose":  "res://scenes/minigames/Handkerchief.tscn",
	"stomachache": "res://scenes/minigames/Stethoscope.tscn",
	"toothache":   "res://scenes/minigames/Toothbrush.tscn",
	"eye_itch":    "res://scenes/minigames/EyeDrop.tscn",
}

const TOOL_EMOJI = {
	"fever":       "🌡️",
	"wound":       "🩹",
	"runny_nose":  "🤧",
	"stomachache": "💊",
	"toothache":   "🦷",
	"eye_itch":    "💧",
}

func _ready():
	_update_symptom_display()
	_update_tool_tray()
	_update_patient_char()
	_play_entry_animations()
	UIAnimations.connect_buttons(self)

func _play_entry_animations():
	# 증상 박스: 왼쪽에서 슬라이드인
	UIAnimations.fly_in_from_left($SymptomBox, 120.0, 0.1)
	# 환자 침대: 위에서 bounce 착지
	var bed_origin_y = $PatientBed.position.y
	UIAnimations.bounce_land($PatientBed, bed_origin_y - 300.0, bed_origin_y, 0.05)
	# 도구 트레이: 아래에서 슬라이드업
	UIAnimations.fly_in_from_bottom($ToolTrayBg, 100.0, 0.3)

func _update_patient_char():
	var names = {"daltooki":"달토끼 🐰","dalkongi":"달콩이 👶","sunny":"써니 ☀️","byeoli":"별이 ⭐"}
	$PatientBed/PatientLabel.text = names.get(GameManager.current_patient, "환자") + "\n😣"

func _update_symptom_display():
	var text = ""
	for s in GameManager.active_symptoms:
		var done = s in GameManager.treated_symptoms
		var mark = "✅ " if done else "• "
		text += mark + SYMPTOM_EMOJI.get(s, s) + "\n"
	$SymptomBox/SymptomList.text = text

func _update_tool_tray():
	# 도구 버튼 동적 생성
	for child in $ToolTrayBg/ToolTray.get_children():
		child.queue_free()
	for symptom in GameManager.active_symptoms:
		if symptom in GameManager.treated_symptoms:
			continue
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(200, 200)
		btn.add_theme_font_size_override("font_size", 60)
		btn.text = TOOL_EMOJI.get(symptom, "?")
		btn.pressed.connect(_on_tool_pressed.bind(symptom))
		$ToolTrayBg/ToolTray.add_child(btn)

func _on_tool_pressed(symptom: String):
	SoundManager.play_sfx("sfx_click")
	var scene_path = TOOL_SCENE.get(symptom, "")
	if scene_path != "":
		SceneTransition.change_scene(scene_path)

func _on_back_button_pressed():
	SceneTransition.change_scene("res://scenes/PatientSelect.tscn")

# 미니게임에서 돌아왔을 때 호출
func refresh():
	_update_symptom_display()
	_update_tool_tray()
	if GameManager.is_all_treated():
		SceneTransition.change_scene_success("res://scenes/Recovery.tscn")

