extends MicroGame
var comb_in_cat = false
var angery = false
var combtime = 0
@export var maxcombtime = 7
signal cat_angry()
signal cat_calm()

func _ready() -> void:
	finished.emit(Result.Win)

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
	cat_angry.emit()
	finished.emit(Result.Loss)
	
func _combing_stopped()-> void:
	comb_in_cat = false
	angery = false
	combtime = 0
	cat_calm.emit()
	pass

func _on_killzone_entered(body: Node2D) -> void:
	_die()
 # Replace with function body.





func _on_catboday_body_entered(body: Node2D) -> void:
	comb_in_cat = true
	print("comb on cat") # Replace with function body.


func _on_catboday_body_exited(body: Node2D) -> void:
	_combing_stopped()
	print("comb off cat")
	
