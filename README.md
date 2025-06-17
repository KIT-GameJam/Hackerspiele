# Häckerspiele

This is a [microgame](https://en.wikipedia.org/wiki/Minigame) collection developed with the [Godot Engine](https://godotengine.org/).
The microgames are made by participants in a [game jam](https://en.wikipedia.org/wiki/Game_jam) during the [GPN23](https://entropia.de/GPN23/en).

## Adding a new microgame

To add a new micogame, follow these steps:

1. Create a new directory for your game in `microgames/`.
2. Create your game. The script of the main scene should extend `MicroGame` and send the `win`/`loss` signals to indicate a win or a loss. After 5 seconds, the `on_timeout` function will be called. By default, it will emit `loss`, but this behaviour can be overwritten.
3. Add your main scene to the `scenes` array in `microgames/microgames.gd`.
4. Open a PR with your changes.

For an example, take a look at `microgames/hello/`.
