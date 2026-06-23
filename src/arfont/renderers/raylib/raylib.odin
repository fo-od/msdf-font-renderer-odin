package arfont_renderer_raylib

import "../../../arfont"
import rl "vendor:raylib"

@(private)
draw_glyph :: proc(
	font: arfont.Font,
	texture: rl.Texture2D,
	glyph: arfont.Glyph,
	pos: rl.Vector2,
	color: rl.Color,
	scale: f32 = 1.0,
) {
	// Source rectangle in the texture atlas
	source_rec: rl.Rectangle
	if font.atlas.yOrigin == "bottom" {
		source_rec = {
			glyph.atlasBounds.left,
			f32(font.atlas.height) - glyph.atlasBounds.top,
			glyph.atlasBounds.right - glyph.atlasBounds.left,
			glyph.atlasBounds.top - glyph.atlasBounds.bottom,
		}
	} else {
		source_rec = {
			glyph.atlasBounds.left,
			glyph.atlasBounds.top,
			glyph.atlasBounds.right - glyph.atlasBounds.left,
			glyph.atlasBounds.bottom - glyph.atlasBounds.top,
		}
	}

	// Destination rectangle on the screen
	dest_rec := rl.Rectangle {
		pos.x + (glyph.planeBounds.left * font.atlas.size * scale),
		pos.y - (glyph.planeBounds.top * font.atlas.size * scale),
		source_rec.width * scale,
		source_rec.height * scale,
	}

	rl.DrawTexturePro(texture, source_rec, dest_rec, {}, 0, color)
}

draw_text :: proc(
	font: arfont.Font,
	texture: rl.Texture2D,
	text: string,
	pos: rl.Vector2,
	color: rl.Color,
	scale: f32 = 1.0,
) {
	adv: f32
	cursor := pos
	for c in text {
		cursor.x += adv

		char := transmute(i32)c
		glyph := arfont.getGlyph(font, char)

		adv = glyph.advance * font.atlas.size * scale

		draw_glyph(font, texture, glyph, cursor, color, scale)
	}
}

