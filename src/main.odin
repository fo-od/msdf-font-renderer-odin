package main

import "arfont"
import arfont_renderer "arfont/renderers/raylib"
import "core:fmt"
import "core:os"
import rl "vendor:raylib"

msdfShader: rl.Shader
font: arfont.Font
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
	rl.InitWindow(640, 480, "arfont-renderer-raylib")

	arfont_renderer.init_shader()

	fontTexture = rl.LoadTexture("src/resources/inter.png")
	rl.SetTextureFilter(fontTexture, .BILINEAR) // for some reason its not bilinear by default, which is needed for MSDF scalinga

	fontFile, _ := os.open("src/resources/inter.json")
	font = arfont.parse_json_file(fontFile)
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginShaderMode(arfont_renderer.shader)
	arfont_renderer.draw_text(
		font,
		fontTexture,
		"Hellope",
		rl.GetMousePosition(),
		rl.WHITE,
		fontScale,
	)
	rl.EndShaderMode()

	rl.EndDrawing()
}

input :: proc() {
	fontScale += rl.GetMouseWheelMove() * rl.GetFrameTime()
	if fontScale < 0.1 do fontScale = 0.1
}

