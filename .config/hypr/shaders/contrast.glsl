precision highp float;

uniform sampler2D tex;
varying vec2 v_texcoord;

vec3 remap(vec3 col, vec3 min, vec3 max) {
    return (col - min) / (max - min);
}

void main() {
    vec4 col = texture2D(tex, v_texcoord);
    col.rgb = remap(col.rgb, vec3(16) / 255.0, vec3(235) / 255.0);
    gl_FragColor = col;
}