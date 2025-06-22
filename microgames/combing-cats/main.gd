extends MicroGame
var comb_in_cat = false
var angery = false
var combtime = 0
var maxcombtime = 1.7
var knostoncat=0
signal cat_angry()
signal scratch()
signal cat_calm()

func _ready() -> void:
	_no_knots_left_on_cat()

func _process(delta: float) -> void:

	if(comb_in_cat):
		combtime += delta


	if (combtime > maxcombtime/2 and not angery):
		_get_angery()


	if(combtime > maxcombtime):
		_die()


func _get_angery()->void:
	print("walk away buster")
	cat_angry.emit()
	angery = true

func _die()-> void:
	print("ded")
	scratch.emit()

func _combing_stopped()-> void:
	comb_in_cat = false
	angery = false
	combtime = 0
	cat_calm.emit()
	pass

func _on_killzone_entered(_body: Node2D) -> void:
	_die()
 # Replace with function body.

func _no_knots_left_on_cat() -> bool:
	return knostoncat <=0



func _win_game()->void:
	print("you win")
	finished.emit(Result.Win)

func _on_catboday_body_entered(body: Node2D) -> void:
	print(body)
	if (body is CharacterBody2D):
		comb_in_cat = true
		print("comb on cat")
	else:
		print("knot on cat")
		knostoncat+=1
		 # Replace with function body.


func _on_catboday_body_exited(body: Node2D) -> void:
	print(body)
	if (body is CharacterBody2D):
		_combing_stopped()
	else:
		knostoncat-=1

	if(_no_knots_left_on_cat()):
		_win_game()

	print("comb off cat")
