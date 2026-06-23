package arfont_renderer_raylib

import "../../../arfont"
import rl "vendor:raylib"

drawGlyph :: proc(
	font: arfont.Font,
	texture: rl.Texture2D,
	char: i32,
	pos: rl.Vector2,
	color: rl.Color,
) {
	glyph := arfont.getGlyph(font, char)
	if font.atlas.yOrigin == "bottom" {
		rl.DrawTextureRec(
			texture,
			{
				glyph.atlasBounds.left,
				glyph.atlasBounds.bottom,
				glyph.atlasBounds.right - glyph.atlasBounds.left,
				glyph.atlasBounds.top - glyph.atlasBounds.bottom,
			},
			pos,
			color,
		)
	} else {
		rl.DrawTextureRec(
			texture,
			{
				glyph.atlasBounds.left,
				glyph.atlasBounds.top,
				glyph.atlasBounds.right - glyph.atlasBounds.left,
				glyph.atlasBounds.bottom - glyph.atlasBounds.top,
			},
			pos,
			color,
		)
	}
}

