extends Node

# 현재 선택된 환자
var current_patient: String = "daltooki"

# 증상 목록 (활성화된 것들)
var active_symptoms: Array = []

# 스티커 수집 현황
var collected_stickers: Dictionary = {
	"daltooki": false,
	"dalkongi": false,
	"sunny": false,
	"byeoli": false,
	"all": false,
}

# 현재 치료 완료된 증상
var treated_symptoms: Array = []

# 증상 전체 목록
const ALL_SYMPTOMS = ["fever", "wound", "runny_nose", "stomachache", "toothache", "eye_itch"]

# 증상별 사용 도구
const SYMPTOM_TOOLS = {
	"fever": "thermometer",
	"wound": "bandage",
	"runny_nose": "handkerchief",
	"stomachache": "stethoscope",
	"toothache": "toothbrush",
	"eye_itch": "eyedrop",
}

func start_treatment(patient: String):
	current_patient = patient
	treated_symptoms = []
	# 랜덤 증상 1~2개 선택 (초반은 쉽게)
	var shuffled = ALL_SYMPTOMS.duplicate()
	shuffled.shuffle()
	active_symptoms = shuffled.slice(0, randi_range(1, 2))

func mark_treated(symptom: String):
	if symptom in active_symptoms and symptom not in treated_symptoms:
		treated_symptoms.append(symptom)

func is_all_treated() -> bool:
	for s in active_symptoms:
		if s not in treated_symptoms:
			return false
	return true

func complete_treatment():
	collected_stickers[current_patient] = true
	SaveManager.save_game()
	# 모든 환자 완치 체크
	var all_done = true
	for k in ["daltooki", "dalkongi", "sunny", "byeoli"]:
		if not collected_stickers[k]:
			all_done = false
			break
	if all_done:
		collected_stickers["all"] = true
