package main

import msdfont "../"
import msdfont_renderer "../renderers/raylib"
import "core:os"
import rl "vendor:raylib"

font: msdfont.Font
fontTexture: rl.Texture2D
fontScale: f32 = 1

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		input()
		draw()
	}
}

init :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(640, 480, "msdfont-renderer-raylib")

	msdfont_renderer.init_shader()

	fontTexture = rl.LoadTexture("src/resources/inter.png")
	rl.SetTextureFilter(fontTexture, .BILINEAR) // for some reason its not bilinear by default, which is needed for MSDF scaling

	fontData, _ := os.open("src/resources/inter.json")
	font = msdfont.parse_json_file(fontData)
}

input :: proc() {
	fontScale += rl.GetMouseWheelMove() * rl.GetFrameTime()
	if fontScale < 0.1 do fontScale = 0.1
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginShaderMode(msdfont_renderer.shader)
	msdfont_renderer.draw_text(
		font,
		fontTexture,
		"Use mouse wheel to zoom in/out!",
		{},
		rl.WHITE,
		1,
	)
	msdfont_renderer.draw_text(
		font,
		fontTexture,
		"Hellope!",
		{cast(f32)rl.GetScreenWidth() / 2.0, cast(f32)rl.GetScreenHeight() / 2.0},
		rl.WHITE,
		fontScale,
	)
	rl.EndShaderMode()

	rl.EndDrawing()
}

