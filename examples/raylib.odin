package main

import msdfont "../"
import msdfont_renderer "../renderers/raylib"
import "core:os"
import rl "vendor:raylib"

font: msdfont_renderer.Font
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

	font.texture = rl.LoadTexture("resources/inter.png")
	rl.SetTextureFilter(font.texture, .BILINEAR) // for some reason its not bilinear by default, which is needed for MSDF scaling

	fontData, _ := os.open("resources/inter.json")
	font.font = msdfont.parse_json_file(fontData)
}

input :: proc() {
	fontScale += rl.GetMouseWheelMove() * rl.GetFrameTime()
	if fontScale < 0.1 do fontScale = 0.1
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginShaderMode(msdfont_renderer.shader)
	msdfont_renderer.draw_text(font, "Use mouse wheel to zoom in/out!", {}, rl.WHITE, 1)
	msdfont_renderer.draw_text(
		font,
		"Hellope!",
		{cast(f32)rl.GetScreenWidth() / 2.0, cast(f32)rl.GetScreenHeight() / 2.0},
		rl.WHITE,
		fontScale,
	)
	rl.EndShaderMode()

	rl.EndDrawing()
}

