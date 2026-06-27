#version 330 core

// modified from https://github.com/Blatko1/awesome-msdf#basic-msdf-usage
in vec2 fragTexCoord;
in vec4 fragColor;
out vec4 finalColor;

uniform sampler2D tex;
uniform float pxRange = 2.0;

float median(vec3 rgb) {
    return max(min(rgb.r, rgb.g), min(max(rgb.r, rgb.g), rgb.b));
}

float screenPxRange() {
    vec2 unitRange = vec2(pxRange) / vec2(textureSize(tex, 0));
    vec2 screenTexSize = vec2(1.0) / fwidth(fragTexCoord);
    return max(0.5 * dot(unitRange, screenTexSize), 1.0);
}

void main() {
    float sd = median(texture(tex, fragTexCoord).rgb);
    float screenPxDistance = screenPxRange() * (sd - 0.5);
    float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);

    finalColor = vec4(fragColor.rgb, fragColor.a * opacity);
}
