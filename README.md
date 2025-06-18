# Häckerspiele

This is a [microgame](https://en.wikipedia.org/wiki/Minigame) collection developed with the [Godot Engine](https://godotengine.org/).
The microgames are made by participants in a [game jam](https://en.wikipedia.org/wiki/Game_jam) during the [GPN23](https://entropia.de/GPN23/en).

## Adding a new microgame

To add a new micogame, follow these steps:

1. Create a new directory for your game in `microgames/`.
2. Create your game. The script of the main scene should extend `MicroGame` and send the `finished` signal to indicate a win or a loss. When the time is up, the `on_timeout` function will be called. By default, it will return `Result.Loss`, but this behaviour can be overwritten.
3. Add your main scene to the `scenes` array in `microgames/microgames.gd`.
4. Open a PR with your changes.

For an example, take a look at `microgames/hello/`.

⚠️ **Important Note:** Only use the pre-defined actions `left`, `right`, `up`, `down` and `submit` for input methods! This way the game is playable with only keyboard or only game pad.
