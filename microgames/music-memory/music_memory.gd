extends MicroGame

@onready var tiles := [
	[$MemoryTile, $MemoryTile2, $MemoryTile3], 
	[$MemoryTile4, $MemoryTile5, $MemoryTile6], 
	[$MemoryTile7, $MemoryTile8, $MemoryTile9]
]

var x := 1
var y := 1
var rand_order: Array = []
var animation_played := false
var LENGHT_OF_RAND := 3
var cur_animation_pos := 0
var time_since_last_animation : float = -0.5

var input_pos := 0

func _ready() -> void:
	for i in range(LENGHT_OF_RAND):
		var random_tuple = [randi_range(0, 2), randi_range(0, 2)]
	
		while rand_order.size() > 0 and random_tuple == rand_order[-1]:
			random_tuple = [randi_range(0, 2), randi_range(0, 2)]
			
		rand_order.append(random_tuple)
	
	print(rand_order) 
	
	tiles[rand_order[0][0]][rand_order[0][1]].select(true)
	tiles[rand_order[0][0]][rand_order[0][1]].showBorder(true)

func _process(delta: float) -> void:
	if animation_played:
		tiles[y][x].select(false)
		if Input.is_action_just_pressed("left"):
			x = clamp(x - 1, 0, 2)
		
		if Input.is_action_just_pressed("right"):
			x = clamp(x + 1, 0, 2)
			
		if Input.is_action_just_pressed("up"):
			y = clamp(y - 1, 0, 2)
			
		if Input.is_action_just_pressed("down"):
			y = clamp(y + 1, 0, 2)
			
		tiles[y][x].select(true)
		
		if Input.is_action_just_pressed("submit"):
			if y == rand_order[input_pos][0] && x == rand_order[input_pos][1]:
				input_pos += 1
				if input_pos == LENGHT_OF_RAND:
					finished.emit(Result.Win)
					print("Win")
			else:
				finished.emit(Result.Loss)
				print("Loss")
	
	else:
		time_since_last_animation += delta
		
		if time_since_last_animation > 0.7:
			time_since_last_animation = 0.0 
			
			if cur_animation_pos + 1 < LENGHT_OF_RAND:
				tiles[rand_order[cur_animation_pos][0]][rand_order[cur_animation_pos][1]].select(false)
				tiles[rand_order[cur_animation_pos][0]][rand_order[cur_animation_pos][1]].showBorder(false)
				cur_animation_pos += 1
				tiles[rand_order[cur_animation_pos][0]][rand_order[cur_animation_pos][1]].select(true)
				tiles[rand_order[cur_animation_pos][0]][rand_order[cur_animation_pos][1]].showBorder(true)
			else:
				animation_played = true
				tiles[rand_order[cur_animation_pos][0]][rand_order[cur_animation_pos][1]].select(false)
				tiles[rand_order[cur_animation_pos][0]][rand_order[cur_animation_pos][1]].showBorder(false)
				tiles[y][x].select(true)
