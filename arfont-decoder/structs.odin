package artery_font

Glyph :: struct #packed {
	codepoint:                u32,
	image:                    u32,
	planeBounds, imageBounds: struct #packed {
		l, b, r, t: f32,
	},
	advance:                  struct #packed {
		h, v: f32,
	},
}

KernPair :: struct #packed {
	codepoint1, codepoint2: u32,
	advance:                struct #packed {
		h, v: f32,
	},
}

FontVariant :: struct #packed {
	flags:           u32,
	weight:          u32,
	codepointType:   CodepointType,
	imageType:       ImageType,
	fallbackVariant: u32,
	fallbackGlyph:   u32,
	metrics:         struct #packed {
		// In pixels:
		fontSize:                       f32,
		distanceRange:                  f32,
		// Proportional to font size:
		emSize:                         f32,
		ascender, descender:            f32,
		lineHeight:                     f32,
		underlineY, underlineThickness: f32,
		// In pixels:
		distanceRangeMiddle:            f32,
		reserved:                       [23]f32,
	},
	name:            string,
	metadata:        string,
	glyphs:          []Glyph,
	kernPairs:       []KernPair,
}

FontImage :: struct #packed {
	flags:           u32,
	encoding:        ImageEncoding,
	width, height:   u32,
	channels:        u32,
	pixelFormat:     PixelFormat,
	imageType:       ImageType,
	rawBinaryFormat: struct #packed {
		rowLength:   u32,
		orientation: ImageOrientation,
	},
	childImages:     u32,
	textureFlags:    u32,
	metadata:        string,
	// the image data (you can write this byte array into a file and it'll work)
	data:            []u8,
}

FontAppendix :: struct #packed {
	metadata: string,
	data:     []u8,
}

ArteryFont :: struct #packed {
	metadataFormat: MetadataFormat,
	metadata:       string,
	variants:       []FontVariant,
	images:         []FontImage,
	appendices:     []FontAppendix,
}

