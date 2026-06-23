package msdf_font_renderer_raylib

import msdfont "../../"
import rl "vendor:raylib"

// must run init_shader() to use this
shader: rl.Shader

// run after initializing your window
init_shader :: proc() {
	shader = rl.LoadShaderFromMemory(
		nil,
		`#version 330 core

        in vec2 fragTexCoord;
        in vec4 fragColor;
        out vec4 finalColor;

        uniform sampler2D tex;
        uniform float pxRange = 2.0;

        float median(float r, float g, float b) {
            return max(min(r, g), min(max(r, g), b));
        }

        float screenPxRange() {
            vec2 unitRange = vec2(pxRange) / vec2(textureSize(tex, 0));
            vec2 screenTexSize = vec2(1.0) / fwidth(fragTexCoord);
            return max(0.5 * dot(unitRange, screenTexSize), 1.0);
        }

        void main() {
            vec3 msd = texture(tex, fragTexCoord).rgb;
            float sd = median(msd.r, msd.g, msd.b);
            float screenPxDistance = screenPxRange() * (sd - 0.5);
            float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);

            vec4 fg = vec4(1.0, 1.0, 1.0, 1.0) * fragColor; // tint (provided by raylib)
            finalColor = vec4(fg.rgb, fg.a * opacity);
        }`,
	)
}

@(private)
draw_glyph :: proc(
	font: msdfont.Font,
	texture: rl.Texture2D,
	glyph: msdfont.Glyph,
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
	font: msdfont.Font,
	texture: rl.Texture2D,
	text: string,
	pos: rl.Vector2,
	color: rl.Color,
	scale: f32 = 1.0,
) {
	if len(text) == 0 do return

	min_x, _, _, max_top := msdfont.get_text_bounds(font, text, scale)

	adv: f32
	cursor := rl.Vector2{pos.x - min_x, pos.y + max_top}
	for c in text {
		cursor.x += adv

		char := transmute(i32)c
		glyph := msdfont.getGlyph(font, char)

		adv = glyph.advance * font.atlas.size * scale

		draw_glyph(font, texture, glyph, cursor, color, scale)
	}
}

