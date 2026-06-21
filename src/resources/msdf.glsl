#version 330 core

// modified from https://github.com/Blatko1/awesome-msdf#basic-msdf-usage
in vec2 fragTexCoord;
in vec4 fragColor;
out vec4 finalColor;

uniform sampler2D tex;
uniform float pxRange = 2.0;
uniform vec4 fgColor = vec4(1.0, 1.0, 1.0, 1.0); // fallback color

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

    vec4 fg = fgColor * fragColor; // tint (provided by raylib)
    finalColor = vec4(fg.rgb, fg.a * opacity);
}
