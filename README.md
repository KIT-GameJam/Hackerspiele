# Häckerspiele

This is a [microgame](https://en.wikipedia.org/wiki/Minigame) collection developed with the [Godot Engine](https://godotengine.org/).
The microgames are made by participants in a [game jam](https://en.wikipedia.org/wiki/Game_jam) during the [GPN23](https://entropia.de/GPN23/en).

## Adding a new microgame

To add a new micogame, follow these steps:

1. Fork this repository.
2. Create a new directory for your game in `microgames/`.
3. Create your game. The script of the main scene should extend the `MicroGame` class and send the `finished` signal to indicate a win or a loss. When the time is up, the `on_timeout` function will be called. By default, it will return `Result.Loss`, but this behaviour can be overwritten. You can also adjust the default time by editing the `time` export var.
4. Add your main scene to the `scenes` array in `microgames/microgames.gd`.
5. Open a PR with your changes.

For an example, take a look at `microgames/hello/`.

⚠️ **Important Note:** Only use the pre-defined actions `left`, `right`, `up`, `down` and `submit` for input methods! This way the game is playable with only keyboard or only game pad.

### The `MicroGame` class

The `MicroGame` class provides the interface for a microgame.

* `signal finished`

  This signal must be emitted on a win (`finished.emit(Result.Win))`) or loss (`finished.emit(Result.Loss))`). Only the first signal emitted will be considered.
* `func timeout`

  This function is called, when the timer expires. By default, it returns `Result.Loss` (i.e. you loose if the time ri). You can overwrite this behaviour, for example to check a condition on timeout.
* `@export var time`

  The default time for your microgame. This time will get scaled down the more microgames you complete (currently to a maximum of 0.4). Since this is an export var, it should be changed in your main scene via the properties editor.
* `storage`

  A dictionary that is persistent per run (i.e. it will be reset when you're at the scoreboard). For example, it can be used to track how often your microgame was played in the current run.
