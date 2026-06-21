package main

import "core:c"
import af "vend:arfont-decoder/src"
import rl "vendor:raylib"

msdfShader: rl.Shader
fontTexture: rl.Texture2D
fgColorLoc: i32

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		draw()
	}
}

init :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(640, 480, "arfont-renderer-raylib")
	msdfShader = rl.LoadShader(nil, "src/resources/msdf.glsl")
	fontTexture = rl.LoadTexture("src/resources/inter.png")

	fgColorLoc = rl.GetShaderLocation(msdfShader, "fgColor")

	fgColor := [4]f32{1.0, 1.0, 1.0, 1.0}
	rl.SetShaderValue(msdfShader, fgColorLoc, &fgColor, .VEC4)
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	// draw
	rl.BeginShaderMode(msdfShader)
	rl.DrawTexture(fontTexture, 0, 0, rl.WHITE)
	rl.EndShaderMode()

	rl.EndDrawing()
}

