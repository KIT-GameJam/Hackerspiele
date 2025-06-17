class_name MicroGame
extends Node

enum Result { Loss, Win }

@warning_ignore("unused_signal")
signal finished(result: Result)

## This function is called, when the timer expires.
func on_timeout() -> Result:
	return Result.Loss
