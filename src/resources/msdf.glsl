#version 330 core

in vec2 fragTexCoord;
in vec4 fragColor;
out vec4 finalColor;

uniform sampler2D texture0;
uniform vec4 bgColor = vec4(0.0, 0.0, 0.0, 0.0); // fallback color
uniform vec4 fgColor = vec4(1.0, 1.0, 1.0, 1.0); // fallback color

float median(float r, float g, float b) {
    return max(min(r, g), min(max(r, g), b));
}

float screenPxRange() {
    return 1.0;
}

void main() {
    vec3 msd = texture(texture0, fragTexCoord).rgb;
    float sd = median(msd.r, msd.g, msd.b);
    float screenPxDistance = screenPxRange() * (sd - 0.5);
    float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);
    finalColor = mix(bgColor, fgColor * fragColor, opacity);
}
