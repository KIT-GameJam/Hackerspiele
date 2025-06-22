extends MicroGame

@onready var question = $Label
@onready var door1 = $Doors/Door1
@onready var door2 = $Doors/Door2
@onready var door3 = $Doors/Door3
@onready var button1 = $Doors/Door1/Button
@onready var button2 = $Doors/Door2/Button
@onready var button3 = $Doors/Door3/Button

@onready var focusButton = $Doors/Door1/Button

var quest_ans = [{
	"q":"What is the answer to everything?",
	"a1": "42",
	"a2":"69",
	"a3":"100",
	"c":"42",
},
{
	"q": "What is on the logo of the Hochschulgruppe KIT GameJam?",
	"a1": "Krabbe",
	"a2":"Controller",
	"a3":"Marmelade",
	"c":"Marmelade",
},
{
	"q": "Which Mate is the best one?",
	"a1": "Mio",
	"a2":"Club",
	"a3":"Flora",
	"c":"Flora",
},
{
	"q": "Which is the best Mate?",
	"a1": "Mio",
	"a2":"Club",
	"a3":"Flora",
	"c":"Flora",
}
]

var selected_door = null
var selected_question_id = 0
var result = null
var unlocked = true

func _ready():
	selected_question_id = randi_range(0,3)
	question.text = quest_ans[selected_question_id].q
	door1.set_answer(quest_ans[selected_question_id].a1)
	door2.set_answer(quest_ans[selected_question_id].a2)
	door3.set_answer(quest_ans[selected_question_id].a3)
	selected_door = door1
	button1.grab_focus.call_deferred()

func _process(_delta):
	if Input.is_action_just_pressed("left"):
		if selected_door.id == door2.id:
			selected_door = door1
			button1.grab_focus.call_deferred()
		elif selected_door.id == door3.id:
			selected_door = door2
			button2.grab_focus.call_deferred()
	if Input.is_action_just_pressed("right"):
		if selected_door.id == door1.id:
			selected_door = door2
			button2.grab_focus.call_deferred()
		elif selected_door.id == door2.id:
			selected_door = door3
			button3.grab_focus.call_deferred()

func click_action(door: Node, answer: String):
	if !unlocked:
		return
	unlocked = false
	if answer == quest_ans[selected_question_id].c:
		door.reveal_correct()
		result = Result.Win
		$Timer.start(1)
	else:
		door.reveal_false()
		$Timer.start(1)
		result = Result.Loss

func _on_door_1_clicked(answer: String):
	click_action(door1, answer)

func _on_door_2_clicked(answer: String):
	click_action(door2, answer)


func _on_door_3_clicked(answer: String):
	click_action(door3, answer)

func _on_timer_timeout():
	finished.emit(result)
