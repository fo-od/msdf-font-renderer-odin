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

	msdfShader = rl.LoadShader(nil, "src/resources/msdf.glsl")

	fontTexture = rl.LoadTexture("src/resources/inter.png")
	rl.SetTextureFilter(fontTexture, .BILINEAR) // for some reason its not bilinear by default, which is needed for MSDF scalinga

	fontFile, _ := os.open("src/resources/inter.json")
	font = arfont.parse_json_file(fontFile)

	fgColor := [4]f32{1.0, 1.0, 1.0, 1.0}
	rl.SetShaderValue(msdfShader, fgColorLoc, &fgColor, .VEC4)
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	// draw
	rl.BeginShaderMode(msdfShader)
	arfont_renderer.drawGlyph(font, fontTexture, 'A', {}, rl.WHITE)
	rl.EndShaderMode()

	rl.EndDrawing()
}

input :: proc() {
	if rl.IsKeyDown(.UP) {
		fontScale += 0.5 * rl.GetFrameTime()
	}
	if rl.IsKeyDown(.DOWN) {
		fontScale -= 0.5 * rl.GetFrameTime()
	}
	if fontScale < 0.1 do fontScale = 0.1
}

