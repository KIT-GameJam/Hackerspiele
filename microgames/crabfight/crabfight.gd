extends MicroGame

const SPLIT_SPEED := Vector2(5000.0, -1000.0)

func _ready() -> void:
	$BadFerris.competitor = $GoodFerris
	$GoodFerris.progress = find_child("YourLife")
	$BadFerris.progress = find_child("OpponentLife")
	update_lifes_of($GoodFerris)
	update_lifes_of($BadFerris)
	$GoodFerris.competitor = $BadFerris
	$GoodFerris.enable_mark()

func knife_collide() -> void:
	var mul := 1.0 if $BadFerris.position > $GoodFerris.position else 1.0
	$BadFerris.velocity = SPLIT_SPEED * Vector2(mul, 1.0)
	$GoodFerris.velocity = SPLIT_SPEED * Vector2(-mul, 1.0)

func update_lifes_of(ferris) -> void:
	ferris.progress.max_value = ferris.max_lifes
	ferris.progress.value = ferris.lifes
