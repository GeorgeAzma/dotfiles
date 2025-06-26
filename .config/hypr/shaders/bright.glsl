precision highp float;

uniform sampler2D tex;
varying vec2 v_texcoord;

vec3 remap(vec3 col, vec3 min, vec3 max) {
    return (col - min) / (max - min);
}

void main() {
    vec4 col = texture2D(tex, v_texcoord);
    vec3 c = col.rgb;
    c *= c;
    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    c *= 2.0 - sqrt(luma);
    c = sqrt(c);
    c = remap(c, vec3(16) / 255.0, vec3(255) / 255.0);
    gl_FragColor = vec4(c, col.a);
}