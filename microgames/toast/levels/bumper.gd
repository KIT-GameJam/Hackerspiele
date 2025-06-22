extends StaticBody2D

func bumper_bumped():
    var tween = create_tween()
    tween.tween_property($Bumper, "scale", Vector2(0.15,0.15), 0.1)
    tween.tween_property($Bumper, "scale", Vector2(0.123,0.123), 0.1)
