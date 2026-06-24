package artery_font

FontFlags :: enum {
	Bold         = 0x01,
	Light        = 0x02,
	ExtraBold    = 0x04,
	Condensed    = 0x08,
	Italic       = 0x10,
	SmallCaps    = 0x20,
	Iconographic = 0x0100,
	SansSerif    = 0x0200,
	Serif        = 0x0400,
	Monospace    = 0x1000,
	Cursive      = 0x2000,
}

CodepointType :: enum {
	Unspecified  = 0,
	Unicode      = 1,
	Indexed      = 2,
	Iconographic = 14,
}

MetadataFormat :: enum {
	None      = 0,
	Plaintext = 1,
	Json      = 2,
}

ImageType :: enum {
	None            = 0,
	SrgbImage       = 1,
	LinearMask      = 2,
	MaskedSrgbImage = 3,
	Sdf             = 4,
	Psdf            = 5,
	Msdf            = 6,
	Mtsdf           = 7,
	MixedContent    = 255,
}

PixelFormat :: enum {
	Unknown   = 0,
	Boolean1  = 1,
	Unsigned8 = 8,
	Float32   = 32,
}

ImageEncoding :: enum {
	UnknownEncoding = 0,
	RawBinary       = 1,
	Bmp             = 4,
	Tiff            = 5,
	Png             = 8,
	Tga             = 9,
}

ImageOrientation :: enum {
	TopDown  = 1,
	BottomUp = -1,
}

